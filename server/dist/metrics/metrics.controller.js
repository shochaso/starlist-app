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
var _a;
import { Controller, Get, Res } from '@nestjs/common';
import { Queue } from 'bullmq';
import IORedis from 'ioredis';
import { Response } from 'express';
import { metricsService } from './metrics.service.js';
const redisUrl = process.env.REDIS_URL || 'redis://localhost:6379';
const queueNames = ['ingest:image', 'ocr:receipt', 'enrich:search'];
let MetricsController = class MetricsController {
    async read() {
        const redis = new IORedis(redisUrl);
        const pong = await redis.ping();
        const queues = await this.collectQueueCounts(redis);
        await redis.quit();
        return { redis: pong, queues };
    }
    async prom(res) {
        const redis = new IORedis(redisUrl);
        let redisUp = 0;
        try {
            const pong = await redis.ping();
            redisUp = pong === 'PONG' ? 1 : 0;
        }
        catch (error) {
            metricsService.incrementError('REDIS_PING_FAILED');
        }
        const queues = await this.collectQueueCounts(redis);
        await redis.quit();
        const lines = [];
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
    async collectQueueCounts(redis) {
        return Promise.all(queueNames.map(async (name) => {
            const queue = new Queue(name, { connection: redis });
            const counts = await queue.getJobCounts('waiting', 'active', 'completed', 'failed', 'delayed');
            await queue.close();
            return { name, ...counts };
        }));
    }
};
__decorate([
    Get(),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], MetricsController.prototype, "read", null);
__decorate([
    Get('prom'),
    __param(0, Res()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [typeof (_a = typeof Response !== "undefined" && Response) === "function" ? _a : Object]),
    __metadata("design:returntype", Promise)
], MetricsController.prototype, "prom", null);
MetricsController = __decorate([
    Controller('metrics')
], MetricsController);
export { MetricsController };
