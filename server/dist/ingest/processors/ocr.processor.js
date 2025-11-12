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
import { BUCKET, supabase } from '../../shared/supabase.js';
import { Q_ENRICH, Q_OCR } from '../queue.tokens.js';
import { isLowConfidence, ocrImageBuffer, parseReceiptText } from '../services/ocr.service.js';
import { ExternalOcrProvider } from '../services/ocr.external.js';
import { metricsService } from '../../metrics/metrics.service.js';
async function fetchBufferFromStorage(key) {
    const { data, error } = await supabase.storage.from(BUCKET).download(key);
    if (error) {
        throw error;
    }
    // @ts-ignore Blob on Deno/Node fetch
    return Buffer.from(await data.arrayBuffer());
}
let OcrProcessor = class OcrProcessor {
    qEnrich;
    constructor(qEnrich) {
        this.qEnrich = qEnrich;
    }
    async handle(job) {
        const startedAt = Date.now();
        const allowFallback = process.env.USE_EXTERNAL_OCR_WHEN_LOWCONF === 'true';
        const useExternalPrimary = process.env.USE_EXTERNAL_OCR_PRIMARY === 'true';
        try {
            job.updateProgress({ step: 'ocr:download' });
            const buffer = await fetchBufferFromStorage(job.data.filePath);
            const runTesseract = async () => ocrImageBuffer(buffer);
            const runExternal = async () => {
                const provider = new ExternalOcrProvider();
                const alt = await provider.recognize(buffer);
                const parsed = parseReceiptText(alt.text);
                metricsService.incrementExternalUsage();
                return {
                    raw: parsed.raw,
                    avgConf: alt.avgConf,
                    store: parsed.store,
                    date: parsed.date,
                    items: parsed.items,
                };
            };
            job.updateProgress({ step: 'ocr:run' });
            let result;
            let lowConfidence = false;
            let tesseractAttempted = false;
            try {
                if (useExternalPrimary) {
                    result = await runExternal();
                }
                else {
                    result = await runTesseract();
                    tesseractAttempted = true;
                }
            }
            catch (error) {
                if (useExternalPrimary) {
                    metricsService.incrementError('OCR_EXTERNAL_PRIMARY_FAILED');
                    job.updateProgress({
                        step: 'ocr:external_primary_failed',
                        reason: error instanceof Error ? error.message : 'unknown error',
                    });
                    result = await runTesseract();
                    tesseractAttempted = true;
                }
                else {
                    metricsService.incrementError('OCR_TESSERACT_FAILED');
                    throw error;
                }
            }
            lowConfidence = isLowConfidence(result.avgConf);
            if (lowConfidence) {
                metricsService.incrementLowConfidence();
            }
            if (lowConfidence && allowFallback) {
                if (useExternalPrimary && !tesseractAttempted) {
                    try {
                        const alt = await runTesseract();
                        tesseractAttempted = true;
                        if (alt.avgConf > result.avgConf) {
                            result = alt;
                            lowConfidence = isLowConfidence(result.avgConf);
                            job.updateProgress({ step: 'ocr:fallback_used', conf: alt.avgConf });
                        }
                    }
                    catch (error) {
                        metricsService.incrementError('OCR_TESSERACT_FALLBACK_FAILED');
                        job.updateProgress({
                            step: 'ocr:fallback_failed',
                            reason: error instanceof Error ? error.message : 'unknown error',
                        });
                    }
                }
                else if (!useExternalPrimary) {
                    try {
                        const alt = await runExternal();
                        if (alt.avgConf > result.avgConf) {
                            result = alt;
                            lowConfidence = isLowConfidence(result.avgConf);
                            job.updateProgress({ step: 'ocr:fallback_used', conf: alt.avgConf });
                        }
                    }
                    catch (error) {
                        metricsService.incrementError('OCR_EXTERNAL_FALLBACK_FAILED');
                        job.updateProgress({
                            step: 'ocr:fallback_failed',
                            reason: error instanceof Error ? error.message : 'unknown error',
                        });
                    }
                }
            }
            await supabase.from('media_ocr').upsert({
                media_key: job.data.filePath,
                avg_conf: result.avgConf,
                store: result.store ?? null,
                date: result.date ?? null,
                raw: result.raw ?? null,
            }, { onConflict: 'media_key' });
            await supabase
                .from('media_objects')
                .update({ status: 'ocr_done' })
                .eq('file_key', job.data.filePath);
            const next = {
                ...job.data,
                ocr: {
                    store: result.store,
                    date: result.date,
                    items: result.items,
                    raw: result.raw,
                },
            };
            job.updateProgress({ step: 'queue:enrich', low_conf: lowConfidence });
            await this.qEnrich.add('run', next, { timeout: 45_000 });
            return { lines: result.items.length, avgConf: result.avgConf, lowConf: lowConfidence };
        }
        catch (error) {
            metricsService.incrementError('OCR_ERROR');
            throw error;
        }
        finally {
            metricsService.recordJobDuration('ocr', Date.now() - startedAt);
        }
    }
};
__decorate([
    Process({ name: 'run', concurrency: Number(process.env.TESS_WORKER_CONCURRENCY || '2') }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [typeof (_b = typeof Job !== "undefined" && Job) === "function" ? _b : Object]),
    __metadata("design:returntype", Promise)
], OcrProcessor.prototype, "handle", null);
OcrProcessor = __decorate([
    Processor(Q_OCR),
    __param(0, InjectQueue(Q_ENRICH)),
    __metadata("design:paramtypes", [typeof (_a = typeof Queue !== "undefined" && Queue) === "function" ? _a : Object])
], OcrProcessor);
export { OcrProcessor };
