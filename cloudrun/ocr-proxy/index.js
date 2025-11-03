import express from 'express';
import process from 'node:process';
import { DocumentProcessorServiceClient } from '@google-cloud/documentai';

const app = express();
const OCR_ENDPOINTS = ['/ocr/process', '/ocr:process'];
app.use(
  express.json({
    limit: '10mb',
  }),
);

const allowOriginEnv = process.env.CORS_ALLOW_ORIGIN || '';
const ALLOW_ORIGINS = allowOriginEnv
  .split(',')
  .map((value) => value.trim())
  .filter(Boolean);

app.use((req, res, next) => {
  const reqOrigin = req.headers.origin;
  const allow =
    ALLOW_ORIGINS.includes('*') ||
    (reqOrigin && ALLOW_ORIGINS.includes(reqOrigin));

  if (allow) {
    res.set('Access-Control-Allow-Origin', reqOrigin || '*');
    res.set('Vary', 'Origin');
    res.set('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
    res.set(
      'Access-Control-Allow-Headers',
      'Content-Type, Authorization, X-Requested-With',
    );
  }

  if (req.method === 'OPTIONS') {
    return res.status(204).end();
  }

  return next();
});

const handleOcrRequest = async (req, res) => {
  const { mimeType, contentBase64, originalMimeType } = req.body ?? {};
  if (!mimeType || !contentBase64) {
    return res
      .status(400)
      .json({ error: 'mimeType と contentBase64 は必須です。' });
  }

  const sanitizedBase64 = String(contentBase64)
    .replace(/^data:[^;]+;base64,/, '')
    .replace(/\s+/g, '');

  console.log('[OCR] === incoming payload ===');
  console.log('[OCR] mimeType:', mimeType);
  console.log('[OCR] originalMimeType:', originalMimeType ?? null);
  console.log('[OCR] base64Length:', sanitizedBase64.length);
  console.log('[OCR] === end incoming payload ===');

  let binary;
  try {
    binary = Buffer.from(sanitizedBase64, 'base64');
    console.log('[OCR] binary decoded successfully, size:', binary.length);
  } catch (decodeError) {
    console.error('[OCR Error] base64 decode failed', {
      message: decodeError?.message ?? decodeError,
    });
    return res.status(400).json({
      error: '画像データのデコードに失敗しました。base64 形式を確認してください。',
    });
  }

  if (!binary.length) {
    console.error('[OCR Error] binary data is empty');
    return res.status(400).json({
      error: '画像データが空です。base64 形式を確認してください。',
    });
  }
  
  console.log('[OCR] binary data size:', binary.length, 'bytes');
  console.log('[OCR] binary first 20 bytes:', binary.slice(0, 20).toString('hex'));

  const projectId = process.env.DOCUMENT_AI_PROJECT_ID;
  const location = process.env.DOCUMENT_AI_LOCATION;
  const processorId = process.env.DOCUMENT_AI_PROCESSOR_ID;

  if (!projectId || !location || !processorId) {
    return res.status(500).json({
      error:
        'Document AI 用の環境変数 (DOCUMENT_AI_PROJECT_ID / DOCUMENT_AI_LOCATION / DOCUMENT_AI_PROCESSOR_ID) が設定されていません。',
    });
  }

  const name = `projects/${projectId}/locations/${location}/processors/${processorId}`;
  console.log('[OCR] processor name:', name);
  console.log('[OCR] sending to Document AI:', {
    processorName: name,
    mimeType,
    contentSize: binary.length,
  });
  
  const client = new DocumentProcessorServiceClient();

  try {
    const [result] = await client.processDocument({
      name,
      rawDocument: {
        content: binary,
        mimeType,
      },
    });

    const document = result.document ?? {};
    const text = document.text ?? '';
    console.log('[OCR] Document AI success', {
      characters: text.length,
      mimeType,
    });

    return res.json({
      text,
      document,
    });
  } catch (error) {
    const message = String(error?.message ?? error);
    const stack = error?.stack ?? '';
    const code = error?.code;
    const details = error?.details;
    let badRequest = null;
    try {
      const metadata = error?.metadata?.get?.('google.rpc.BadRequest');
      if (metadata && metadata.length > 0) {
        badRequest = metadata.map((entry) => entry.toString());
      }
    } catch (_) {
      badRequest = null;
    }
    // より詳細なエラーメタデータの取得
    let errorMetadata = null;
    try {
      if (error?.metadata) {
        errorMetadata = {};
        // metadataはMap形式の可能性がある
        if (typeof error.metadata.getMap === 'function') {
          const metadataMap = error.metadata.getMap();
          for (const [key, value] of metadataMap) {
            errorMetadata[key] = Array.isArray(value) 
              ? value.map(v => v.toString())
              : value.toString();
          }
        } else if (error.metadata instanceof Map) {
          for (const [key, value] of error.metadata) {
            errorMetadata[key] = Array.isArray(value) 
              ? value.map(v => v.toString())
              : value.toString();
          }
        } else {
          errorMetadata = error.metadata;
        }
      }
    } catch (metaError) {
      console.error('[OCR Error] Failed to extract metadata', metaError);
    }

    console.error('[OCR Error]', {
      message,
      code,
      details,
      badRequest,
      errorMetadata,
      processorName: name,
      mimeType,
      originalMimeType: originalMimeType ?? null,
      binarySize: binary.length,
      stack,
      error: error?.toString(),
    });
    let status = 500;
    if (message.includes('PERMISSION_DENIED')) status = 403;
    if (message.includes('NOT_FOUND')) status = 404;
    if (String(code) === '3' || message.includes('INVALID_ARGUMENT')) {
      status = 422;
    }
    return res.status(status).json({
      error: message,
      details,
      badRequest,
      errorMetadata,
      processorInfo: {
        projectId,
        location,
        processorId,
      },
    });
  }
};

OCR_ENDPOINTS.forEach((path) => {
  app.post(path, handleOcrRequest);
});

const port = process.env.PORT ?? 8080;
app.listen(port, () => {
  console.log(`OCR proxy listening on port ${port}`);
});
