import { Processor, Process, InjectQueue } from '@nestjs/bullmq';
import { Job, Queue } from 'bullmq';

import { BUCKET, supabase } from '../../shared/supabase.js';
import type { EnrichJob, OcrJob } from '../dto/job.dto.js';
import { Q_ENRICH, Q_OCR } from '../queue.tokens.js';
import { isLowConfidence, ocrImageBuffer, parseReceiptText } from '../services/ocr.service.js';
import { ExternalOcrProvider } from '../services/ocr.external.js';
import { metricsService } from '../../metrics/metrics.service.js';

async function fetchBufferFromStorage(key: string): Promise<Buffer> {
  const { data, error } = await supabase.storage.from(BUCKET).download(key);
  if (error) {
    throw error;
  }
  // @ts-ignore Blob on Deno/Node fetch
  return Buffer.from(await data.arrayBuffer());
}

@Processor(Q_OCR)
export class OcrProcessor {
  constructor(@InjectQueue(Q_ENRICH) private readonly qEnrich: Queue) {}

  @Process({ name: 'run', concurrency: Number(process.env.TESS_WORKER_CONCURRENCY || '2') })
  async handle(job: Job<OcrJob>) {
    const startedAt = Date.now();
    const allowFallback = process.env.USE_EXTERNAL_OCR_WHEN_LOWCONF === 'true';
    const useExternalPrimary = process.env.USE_EXTERNAL_OCR_PRIMARY === 'true';
    try {
      job.updateProgress({ step: 'ocr:download' });
      const buffer = await fetchBufferFromStorage(job.data.filePath);

      const runTesseract = async () => ocrImageBuffer(buffer);
      const runExternal = async () => {
        const provider = new ExternalOcrProvider();
        const alt = await provider.recognize(buffer);
        const parsed = parseReceiptText(alt.text);
        metricsService.incrementExternalUsage();
        return {
          raw: parsed.raw,
          avgConf: alt.avgConf,
          store: parsed.store,
          date: parsed.date,
          items: parsed.items,
        };
      };

      job.updateProgress({ step: 'ocr:run' });
      let result;
      let lowConfidence = false;
      let tesseractAttempted = false;

      try {
        if (useExternalPrimary) {
          result = await runExternal();
        } else {
          result = await runTesseract();
          tesseractAttempted = true;
        }
      } catch (error) {
        if (useExternalPrimary) {
          metricsService.incrementError('OCR_EXTERNAL_PRIMARY_FAILED');
          job.updateProgress({
            step: 'ocr:external_primary_failed',
            reason: error instanceof Error ? error.message : 'unknown error',
          });
          result = await runTesseract();
          tesseractAttempted = true;
        } else {
          metricsService.incrementError('OCR_TESSERACT_FAILED');
          throw error;
        }
      }

      lowConfidence = isLowConfidence(result.avgConf);
      if (lowConfidence) {
        metricsService.incrementLowConfidence();
      }

      if (lowConfidence && allowFallback) {
        if (useExternalPrimary && !tesseractAttempted) {
          try {
            const alt = await runTesseract();
            tesseractAttempted = true;
            if (alt.avgConf > result.avgConf) {
              result = alt;
              lowConfidence = isLowConfidence(result.avgConf);
              job.updateProgress({ step: 'ocr:fallback_used', conf: alt.avgConf });
            }
          } catch (error) {
            metricsService.incrementError('OCR_TESSERACT_FALLBACK_FAILED');
            job.updateProgress({
              step: 'ocr:fallback_failed',
              reason: error instanceof Error ? error.message : 'unknown error',
            });
          }
        } else if (!useExternalPrimary) {
          try {
            const alt = await runExternal();
            if (alt.avgConf > result.avgConf) {
              result = alt;
              lowConfidence = isLowConfidence(result.avgConf);
              job.updateProgress({ step: 'ocr:fallback_used', conf: alt.avgConf });
            }
          } catch (error) {
            metricsService.incrementError('OCR_EXTERNAL_FALLBACK_FAILED');
            job.updateProgress({
              step: 'ocr:fallback_failed',
              reason: error instanceof Error ? error.message : 'unknown error',
            });
          }
        }
      }

      await supabase.from('media_ocr').upsert(
        {
          media_key: job.data.filePath,
          avg_conf: result.avgConf,
          store: result.store ?? null,
          date: result.date ?? null,
          raw: result.raw ?? null,
        },
        { onConflict: 'media_key' },
      );

      await supabase
        .from('media_objects')
        .update({ status: 'ocr_done' })
        .eq('file_key', job.data.filePath);

      const next: EnrichJob = {
        ...job.data,
        ocr: {
          store: result.store,
          date: result.date,
          items: result.items,
          raw: result.raw,
        },
      };

      job.updateProgress({ step: 'queue:enrich', low_conf: lowConfidence });
      await this.qEnrich.add('run', next, { timeout: 45_000 });
      return { lines: result.items.length, avgConf: result.avgConf, lowConf: lowConfidence };
    } catch (error) {
      metricsService.incrementError('OCR_ERROR');
      throw error;
    } finally {
      metricsService.recordJobDuration('ocr', Date.now() - startedAt);
    }
  }
}
