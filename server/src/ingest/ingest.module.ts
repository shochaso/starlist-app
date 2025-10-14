import { Module } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';
import { Q_INGEST, Q_OCR, Q_ENRICH } from './queue.tokens.js';
import { IngestController } from './ingest.controller.js';
import { IngestProcessor } from './processors/ingest.processor.js';
import { OcrProcessor } from './processors/ocr.processor.js';
import { EnrichProcessor } from './processors/enrich.processor.js';

@Module({
  imports: [
    BullModule.registerQueue(
      { name: Q_INGEST, defaultJobOptions: { attempts: 3 } },
      { name: Q_OCR, defaultJobOptions: { attempts: 3 } },
      { name: Q_ENRICH, defaultJobOptions: { attempts: 3 } },
    ),
  ],
  controllers: [IngestController],
  providers: [IngestProcessor, OcrProcessor, EnrichProcessor],
})
export class IngestModule {}
