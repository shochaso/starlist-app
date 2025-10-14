import { Processor, Process } from '@nestjs/bullmq';
import { Job } from 'bullmq';

import { BUCKET, SIGNED_TTL, supabase } from '../../shared/supabase.js';
import type { EnrichJob } from '../dto/job.dto.js';
import { Q_ENRICH } from '../queue.tokens.js';
import { enrichItemsBasic } from '../services/enrich.service.js';
import { metricsService } from '../../metrics/metrics.service.js';

@Processor(Q_ENRICH)
export class EnrichProcessor {
  @Process({ name: 'run', concurrency: 2 })
  async handle(job: Job<EnrichJob>) {
    const startedAt = Date.now();
    try {
      job.updateProgress({ step: 'enrich:items' });
      const enriched = await enrichItemsBasic(job.data.ocr.items);

      await supabase.from('media_items').delete().eq('media_key', job.data.filePath);

      if (enriched.length) {
        const rows = enriched.map((item, index) => ({
          media_key: job.data.filePath,
          line_no: index + 1,
          name: item.name,
          qty: item.qty ?? null,
          price: item.price ?? null,
          jan: item.jan ?? null,
          score: item.score ?? null,
        }));
        await supabase.from('media_items').insert(rows);
      }

      await supabase
        .from('media_objects')
        .update({ status: 'matched' })
        .eq('file_key', job.data.filePath);

      const { data, error } = await supabase.storage
        .from(BUCKET)
        .createSignedUrl(job.data.filePath, SIGNED_TTL);
      if (error) {
        throw error;
      }

      job.updateProgress({ step: 'done', preview: Boolean(data?.signedUrl) });
      return { ok: true, url: data?.signedUrl, items: enriched };
    } catch (error) {
      metricsService.incrementError('ENRICH_ERROR');
      throw error;
    } finally {
      metricsService.recordJobDuration('enrich', Date.now() - startedAt);
    }
  }
}
