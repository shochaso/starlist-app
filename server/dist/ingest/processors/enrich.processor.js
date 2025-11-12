var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var _a;
import { Processor, Process } from '@nestjs/bullmq';
import { Job } from 'bullmq';
import { BUCKET, SIGNED_TTL, supabase } from '../../shared/supabase.js';
import { Q_ENRICH } from '../queue.tokens.js';
import { enrichItemsBasic } from '../services/enrich.service.js';
import { metricsService } from '../../metrics/metrics.service.js';
let EnrichProcessor = class EnrichProcessor {
    async handle(job) {
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
        }
        catch (error) {
            metricsService.incrementError('ENRICH_ERROR');
            throw error;
        }
        finally {
            metricsService.recordJobDuration('enrich', Date.now() - startedAt);
        }
    }
};
__decorate([
    Process({ name: 'run', concurrency: 2 }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [typeof (_a = typeof Job !== "undefined" && Job) === "function" ? _a : Object]),
    __metadata("design:returntype", Promise)
], EnrichProcessor.prototype, "handle", null);
EnrichProcessor = __decorate([
    Processor(Q_ENRICH)
], EnrichProcessor);
export { EnrichProcessor };
