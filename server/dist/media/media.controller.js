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
import { Controller, Get, Query, BadRequestException, Param } from '@nestjs/common';
import { supabase, BUCKET, SIGNED_TTL } from '../shared/supabase.js';
let MediaController = class MediaController {
    async signedUrl(key) {
        if (!key) {
            throw new BadRequestException('key required');
        }
        const { data, error } = await supabase.storage
            .from(BUCKET)
            .createSignedUrl(key, SIGNED_TTL);
        if (error) {
            throw new BadRequestException(error.message);
        }
        return { signedUrl: data?.signedUrl };
    }
    async byKey(key) {
        if (!key) {
            throw new BadRequestException('key required');
        }
        const [ocr, items, signed] = await Promise.all([
            supabase.from('media_ocr').select('*').eq('media_key', key).single(),
            supabase.from('media_items').select('*').eq('media_key', key).order('line_no'),
            supabase.storage.from(BUCKET).createSignedUrl(key, SIGNED_TTL),
        ]);
        if (ocr.error && ocr.error.code !== 'PGRST116') {
            throw new BadRequestException(ocr.error.message);
        }
        if (items.error) {
            throw new BadRequestException(items.error.message);
        }
        return {
            key,
            signedUrl: signed.data?.signedUrl,
            ocr: ocr.data ?? null,
            items: items.data ?? [],
        };
    }
};
__decorate([
    Get('signed-url'),
    __param(0, Query('key')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], MediaController.prototype, "signedUrl", null);
__decorate([
    Get(':key'),
    __param(0, Param('key')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], MediaController.prototype, "byKey", null);
MediaController = __decorate([
    Controller('media')
], MediaController);
export { MediaController };
