import { Module } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';
import { IngestModule } from './ingest/ingest.module.js';
import { MediaController } from './media/media.controller.js';
import { HealthController } from './health/health.controller.js';
import { MetricsController } from './metrics/metrics.controller.js';

@Module({
  imports: [
    BullModule.forRoot({
      connection: process.env.REDIS_URL || 'redis://localhost:6379',
    }),
    IngestModule,
  ],
  controllers: [MediaController, HealthController, MetricsController],
})
export class AppModule {}
