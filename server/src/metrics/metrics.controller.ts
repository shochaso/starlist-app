import { Controller, Get, Res } from '@nestjs/common';
import { Queue } from 'bullmq';
import IORedis from 'ioredis';
import { Response } from 'express';
import { metricsService } from './metrics.service.js';

const redisUrl = process.env.REDIS_URL || 'redis://localhost:6379';
const queueNames = ['ingest:image', 'ocr:receipt', 'enrich:search'];

@Controller('metrics')
export class MetricsController {
  @Get()
  async read() {
    const redis = new IORedis(redisUrl);
    const pong = await redis.ping();
    const queues = await this.collectQueueCounts(redis);
    await redis.quit();
    return { redis: pong, queues };
  }

  @Get('prom')
  async prom(@Res() res: Response) {
    const redis = new IORedis(redisUrl);
    let redisUp = 0;
    try {
      const pong = await redis.ping();
      redisUp = pong === 'PONG' ? 1 : 0;
    } catch (error) {
      metricsService.incrementError('REDIS_PING_FAILED');
    }

    const queues = await this.collectQueueCounts(redis);
    await redis.quit();

    const lines: string[] = [];
    lines.push('# HELP starlist_redis_up 1 if Redis ping ok');
    lines.push('# TYPE starlist_redis_up gauge');
    lines.push(`starlist_redis_up ${redisUp}`);

    lines.push('# HELP starlist_queue_jobs Number of jobs by state');
    lines.push('# TYPE starlist_queue_jobs gauge');
    for (const q of queues) {
      const { name, ...counts } = q;
      for (const [state, value] of Object.entries(counts)) {
        lines.push(`starlist_queue_jobs{queue="${name}",state="${state}"} ${value}`);
      }
    }

    const customMetrics = metricsService.renderPrometheus();
    if (customMetrics) {
      lines.push(customMetrics);
    }

    res.setHeader('Content-Type', 'text/plain; version=0.0.4');
    res.send(`${lines.join('\n')}\n`);
  }

  private async collectQueueCounts(redis: IORedis.Redis) {
    return Promise.all(
      queueNames.map(async (name) => {
        const queue = new Queue(name, { connection: redis });
        const counts = await queue.getJobCounts('waiting', 'active', 'completed', 'failed', 'delayed');
        await queue.close();
        return { name, ...counts };
      }),
    );
  }
}
