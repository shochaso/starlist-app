var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
import { Module } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';
import { Q_INGEST, Q_OCR, Q_ENRICH } from './queue.tokens.js';
import { IngestController } from './ingest.controller.js';
import { IngestProcessor } from './processors/ingest.processor.js';
import { OcrProcessor } from './processors/ocr.processor.js';
import { EnrichProcessor } from './processors/enrich.processor.js';
let IngestModule = class IngestModule {
};
IngestModule = __decorate([
    Module({
        imports: [
            BullModule.registerQueue({ name: Q_INGEST, defaultJobOptions: { attempts: 3 } }, { name: Q_OCR, defaultJobOptions: { attempts: 3 } }, { name: Q_ENRICH, defaultJobOptions: { attempts: 3 } }),
        ],
        controllers: [IngestController],
        providers: [IngestProcessor, OcrProcessor, EnrichProcessor],
    })
], IngestModule);
export { IngestModule };
