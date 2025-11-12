var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
var _a, _b;
import { Processor, Process, InjectQueue } from '@nestjs/bullmq';
import { Job, Queue } from 'bullmq';
import sharp from 'sharp';
import imghash from 'imghash';
import crypto from 'node:crypto';
import { supabase, BUCKET } from '../../shared/supabase.js';
import { Q_INGEST, Q_OCR } from '../queue.tokens.js';
import { metricsService } from '../../metrics/metrics.service.js';
let IngestProcessor = class IngestProcessor {
    qOcr;
    constructor(qOcr) {
        this.qOcr = qOcr;
    }
    async handle(job) {
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
                .upsert({
                user_id: userId,
                file_key: key1600,
                phash,
                width: meta.width ?? 0,
                height: meta.height ?? 0,
                bytes: variant1600.byteLength,
                status: 'preprocessed',
            }, { onConflict: 'file_key' });
            const next = {
                ...job.data,
                filePath: key1600,
                width: meta.width,
                height: meta.height,
                hash,
            };
            job.updateProgress({ step: 'queue:ocr', fileKey: key1600 });
            await this.qOcr.add('run', next, { timeout: 60_000 });
            return { key: key1600, phash };
        }
        catch (error) {
            metricsService.incrementError('INGEST_ERROR');
            throw error;
        }
        finally {
            metricsService.recordJobDuration('ingest', Date.now() - startedAt);
        }
    }
};
__decorate([
    Process('start'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [typeof (_b = typeof Job !== "undefined" && Job) === "function" ? _b : Object]),
    __metadata("design:returntype", Promise)
], IngestProcessor.prototype, "handle", null);
IngestProcessor = __decorate([
    Processor(Q_INGEST),
    __param(0, InjectQueue(Q_OCR)),
    __metadata("design:paramtypes", [typeof (_a = typeof Queue !== "undefined" && Queue) === "function" ? _a : Object])
], IngestProcessor);
export { IngestProcessor };
