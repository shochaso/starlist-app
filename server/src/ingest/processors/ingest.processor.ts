import { Processor, Process, InjectQueue } from '@nestjs/bullmq';
import { Job, Queue } from 'bullmq';
import sharp from 'sharp';
import imghash from 'imghash';
import crypto from 'node:crypto';
import { supabase, BUCKET } from '../../shared/supabase.js';
import { Q_INGEST, Q_OCR } from '../queue.tokens.js';
import type { IngestJob, OcrJob } from '../dto/job.dto.js';
import { metricsService } from '../../metrics/metrics.service.js';

@Processor(Q_INGEST)
export class IngestProcessor {
  constructor(@InjectQueue(Q_OCR) private readonly qOcr: Queue) {}

  @Process('start')
  async handle(job: Job<IngestJob>) {
    const startedAt = Date.now();
    const { filePath, userId } = job.data;
    job.updateProgress({ step: 'preprocess' });
    try {
      const baseImage = sharp(filePath);
      const rotated = await baseImage.rotate();
      const buffer = await rotated.toBuffer();

      const hash = crypto.createHash('sha256').update(buffer).digest('hex');
      const phash = await imghash.hash(buffer, 16, 'hex');

      const variant1600 = await sharp(buffer)
        .resize({ width: 1600, withoutEnlargement: true })
        .webp({ quality: 85 })
        .toBuffer();
      const variant512 = await sharp(buffer)
        .resize({ width: 512, withoutEnlargement: true })
        .webp({ quality: 85 })
        .toBuffer();
      const meta = await sharp(variant1600).metadata();

      const baseKey = `u/${userId}/r/${hash}`;
      const key1600 = `${baseKey}_1600.webp`;
      const key512 = `${baseKey}_512.webp`;

      const upload1600 = await supabase.storage
        .from(BUCKET)
        .upload(key1600, variant1600, { upsert: false, contentType: 'image/webp' });
      if (upload1600.error && !upload1600.error.message.includes('duplicate')) {
        throw upload1600.error;
      }

      const upload512 = await supabase.storage
        .from(BUCKET)
        .upload(key512, variant512, { upsert: false, contentType: 'image/webp' });
      if (upload512.error && !upload512.error.message.includes('duplicate')) {
        throw upload512.error;
      }

      await supabase
        .from('media_objects')
        .upsert(
          {
            user_id: userId,
            file_key: key1600,
            phash,
            width: meta.width ?? 0,
            height: meta.height ?? 0,
            bytes: variant1600.byteLength,
            status: 'preprocessed',
          },
          { onConflict: 'file_key' },
        );

      const next: OcrJob = {
        ...job.data,
        filePath: key1600,
        width: meta.width,
        height: meta.height,
        hash,
      };

      job.updateProgress({ step: 'queue:ocr', fileKey: key1600 });
      await this.qOcr.add('run', next, { timeout: 60_000 });
      return { key: key1600, phash };
    } catch (error) {
      metricsService.incrementError('INGEST_ERROR');
      throw error;
    } finally {
      metricsService.recordJobDuration('ingest', Date.now() - startedAt);
    }
  }
}
