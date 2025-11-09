const ALLOWED = ['image/jpeg','image/png','image/webp','application/pdf'];
const MAX = 5 * 1024 * 1024;

export function validateFile(meta: { mime: string; size: number }) {
  if (!ALLOWED.includes(meta.mime)) throw new Error('mime_not_allowed');
  if (meta.size > MAX) throw new Error('file_too_large');
}

// EXIF除去はアップロード後のCDN/画像処理段で実施する前提（Sharp/Cloudflare Images 等）
