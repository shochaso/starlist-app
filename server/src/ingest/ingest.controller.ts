import { Controller, Post, UseInterceptors, UploadedFile, Body, Get, Param } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import crypto from 'node:crypto';
import fs from 'node:fs/promises';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';
import { Q_INGEST, Q_OCR, Q_ENRICH } from './queue.tokens.js';
import type { IngestJob } from './dto/job.dto.js';

@Controller('ingest')
export class IngestController {
  constructor(@InjectQueue(Q_INGEST) private readonly qIngest: Queue) {}

  @Post('upload')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: 'uploads/',
        filename: (_, file, cb) => cb(null, `${Date.now()}-${file.originalname}`),
      }),
      limits: { fileSize: 10 * 1024 * 1024 },
      fileFilter: (_, file, cb) => {
        const ok = /image\/(png|jpe?g|webp)/.test(file.mimetype);
        cb(ok ? null : new Error('invalid file'), ok);
      },
    }),
  )
  async upload(@UploadedFile() file: Express.Multer.File, @Body('userId') userId: string) {
    const fileBuffer = await fs.readFile(file.path);
    const hash = crypto.createHash('sha256').update(fileBuffer).digest('hex');
    const data: IngestJob = { userId, filePath: file.path, hash };
    const jobId = `${userId}:${hash}`;
    const job = await this.qIngest.add('start', data, {
      jobId,
      timeout: 20_000,
      attempts: 3,
      backoff: { type: 'exponential', delay: 1_500 },
      removeOnComplete: 50,
      removeOnFail: 100,
    });
    return { jobId: job.id };
  }

  @Get(':id/status')
  async status(@Param('id') id: string) {
    const queues = [Q_INGEST, Q_OCR, Q_ENRICH];
    const found: Array<{ name: string; state: string; progress: unknown }> = [];
    for (const name of queues) {
      const queue = new Queue(name, { connection: process.env.REDIS_URL! });
      const job = await queue.getJob(id);
      if (job) {
        const state = await job.getState();
        found.push({ name, state, progress: job.progress });
      }
      await queue.close();
    }
    return found.length ? found : { state: 'unknown' };
  }
}
