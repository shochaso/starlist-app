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
var _a, _b, _c;
import { Controller, Post, UseInterceptors, UploadedFile, Body, Get, Param } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import crypto from 'node:crypto';
import fs from 'node:fs/promises';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';
import { Q_INGEST, Q_OCR, Q_ENRICH } from './queue.tokens.js';
let IngestController = class IngestController {
    qIngest;
    constructor(qIngest) {
        this.qIngest = qIngest;
    }
    async upload(file, userId) {
        const fileBuffer = await fs.readFile(file.path);
        const hash = crypto.createHash('sha256').update(fileBuffer).digest('hex');
        const data = { userId, filePath: file.path, hash };
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
    async status(id) {
        const queues = [Q_INGEST, Q_OCR, Q_ENRICH];
        const found = [];
        for (const name of queues) {
            const queue = new Queue(name, { connection: process.env.REDIS_URL });
            const job = await queue.getJob(id);
            if (job) {
                const state = await job.getState();
                found.push({ name, state, progress: job.progress });
            }
            await queue.close();
        }
        return found.length ? found : { state: 'unknown' };
    }
};
__decorate([
    Post('upload'),
    UseInterceptors(FileInterceptor('file', {
        storage: diskStorage({
            destination: 'uploads/',
            filename: (_, file, cb) => cb(null, `${Date.now()}-${file.originalname}`),
        }),
        limits: { fileSize: 10 * 1024 * 1024 },
        fileFilter: (_, file, cb) => {
            const ok = /image\/(png|jpe?g|webp)/.test(file.mimetype);
            cb(ok ? null : new Error('invalid file'), ok);
        },
    })),
    __param(0, UploadedFile()),
    __param(1, Body('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [typeof (_c = typeof Express !== "undefined" && (_b = Express.Multer) !== void 0 && _b.File) === "function" ? _c : Object, String]),
    __metadata("design:returntype", Promise)
], IngestController.prototype, "upload", null);
__decorate([
    Get(':id/status'),
    __param(0, Param('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], IngestController.prototype, "status", null);
IngestController = __decorate([
    Controller('ingest'),
    __param(0, InjectQueue(Q_INGEST)),
    __metadata("design:paramtypes", [typeof (_a = typeof Queue !== "undefined" && Queue) === "function" ? _a : Object])
], IngestController);
export { IngestController };
