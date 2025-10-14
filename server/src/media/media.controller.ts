import { Controller, Get, Query, BadRequestException, Param } from '@nestjs/common';
import { supabase, BUCKET, SIGNED_TTL } from '../shared/supabase.js';

@Controller('media')
export class MediaController {
  @Get('signed-url')
  async signedUrl(@Query('key') key?: string) {
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

  @Get(':key')
  async byKey(@Param('key') key: string) {
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
}
