const express = require('express');
const { DocumentProcessorServiceClient } = require('@google-cloud/documentai');
const { Storage } = require('@google-cloud/storage');
const { randomUUID } = require('crypto');

const app = express();
const OCR_ENDPOINTS = ['/ocr/process', '/ocr:process'];
const THRESHOLD_BYTES = 2 * 1024 * 1024; // 2MB

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

const logInfo = (label, payload) => {
  console.log('[OCR]', label, JSON.stringify(payload));
};

const logError = (label, payload) => {
  console.error('[OCR]', label, JSON.stringify(payload));
};

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

const docClient = new DocumentProcessorServiceClient();
const storage = new Storage();

const resolveEnv = () => {
  const projectId =
    process.env.PROJECT ||
    process.env.GCP_PROJECT ||
    process.env.GOOGLE_CLOUD_PROJECT ||
    process.env.DOCUMENT_AI_PROJECT_ID;

  const location =
    process.env.DOCAI_LOCATION ||
    process.env.LOCATION ||
    process.env.DOCUMENT_AI_LOCATION;

  const processorId =
    process.env.PROCESSOR ||
    process.env.PROCESSOR_ID ||
    process.env.DOCUMENT_AI_PROCESSOR_ID;

  return { projectId, location, processorId };
};

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

  let binary;
  try {
    binary = Buffer.from(sanitizedBase64, 'base64');
  } catch (decodeError) {
    logError('error', {
      stage: 'decode_base64',
      message: decodeError?.message ?? String(decodeError),
    });
    return res.status(400).json({
      error: '画像データのデコードに失敗しました。base64 形式を確認してください。',
    });
  }

  if (!binary.length) {
    logError('error', {
      stage: 'decode_base64',
      message: 'binary data is empty',
    });
    return res.status(400).json({
      error: '画像データが空です。base64 形式を確認してください。',
    });
  }

  const { projectId, location, processorId } = resolveEnv();
  if (!projectId || !location || !processorId) {
    return res.status(500).json({
      error:
        'Document AI 用の環境変数 (PROJECT / LOCATION / PROCESSOR など) が設定されていません。',
    });
  }

  const name = `projects/${projectId}/locations/${location}/processors/${processorId}`;
  const incomingLog = {
    name,
    incomingMime: mimeType,
    originalMime: originalMimeType ?? null,
    convertedMime: mimeType,
    base64Length: sanitizedBase64.length,
    convertedBytesLength: binary.length,
  };
  logInfo('incoming', incomingLog);

  const bucketName = process.env.OCR_GCS_BUCKET;
  let gcsFile;
  let gcsUri = null;
  let docRequest;

  if (binary.length > THRESHOLD_BYTES) {
    if (!bucketName) {
      logError('error', {
        stage: 'size_check',
        message: 'payload exceeds threshold but OCR_GCS_BUCKET is unset',
        payloadBytes: binary.length,
      });
      return res.status(413).json({
        error:
          '画像データが 2MB を超えています。OCR_GCS_BUCKET を設定して再試行してください。',
      });
    }

    const bucket = storage.bucket(bucketName);
    const objectPath = `uploads/${new Date().toISOString().replace(/[:.]/g, '-')}-${randomUUID()}`;
    gcsFile = bucket.file(objectPath);
    await gcsFile.save(binary, {
      contentType: mimeType,
      resumable: false,
    });
    gcsUri = `gs://${bucketName}/${objectPath}`;
    logInfo('upload', {
      bucket: bucketName,
      objectPath,
      payloadBytes: binary.length,
    });

    docRequest = {
      name,
      gcsDocument: {
        gcsUri,
        mimeType,
      },
    };
  } else {
    docRequest = {
      name,
      rawDocument: {
        content: binary,
        mimeType,
      },
    };
  }

  try {
    const [result] = await docClient.processDocument(docRequest);
    const document = result.document ?? {};
    const text = document.text ?? '';
    const pagesLength = Array.isArray(document.pages) ? document.pages.length : 0;
    const logPayload = {
      pagesLength,
      textLength: text.length,
      textPreview: text.slice(0, 2000),
      transport: gcsUri ? 'gcsDocument' : 'rawDocument',
      gcsUri,
    };
    logInfo('result', logPayload);

    return res.json({
      text,
      document,
    });
  } catch (error) {
    const message = String(error?.message ?? error);
    const stack = error?.stack ?? '';
    const code = error?.code ?? null;
    const details = error?.details ?? null;
    let errorMetadata = null;

    try {
      if (error?.metadata) {
        if (typeof error.metadata.getMap === 'function') {
          errorMetadata = {};
          const mapEntries = error.metadata.getMap();
          for (const [key, value] of mapEntries) {
            errorMetadata[key] = Array.isArray(value)
              ? value.map((v) => v.toString())
              : value.toString();
          }
        } else if (error.metadata instanceof Map) {
          errorMetadata = {};
          for (const [key, value] of error.metadata) {
            errorMetadata[key] = Array.isArray(value)
              ? value.map((v) => v.toString())
              : value.toString();
          }
        } else {
          errorMetadata = error.metadata;
        }
      }
    } catch (metaError) {
      logError('error', {
        stage: 'metadata_extraction',
        message: metaError?.message ?? String(metaError),
      });
    }

    const shortStack = stack.split('\n').slice(0, 6).join(' | ');
    logError('error', {
      message,
      code,
      details,
      errorMetadata,
      shortStack,
      name,
      mimeType,
      originalMimeType: originalMimeType ?? null,
      payloadBytes: binary.length,
      transport: gcsUri ? 'gcsDocument' : 'rawDocument',
      gcsUri,
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
      errorMetadata,
      processorInfo: {
        projectId,
        location,
        processorId,
      },
    });
  } finally {
    if (gcsFile) {
      try {
        await gcsFile.delete({ ignoreNotFound: true });
      } catch (cleanupError) {
        logError('error', {
          stage: 'cleanup',
          message: cleanupError?.message ?? String(cleanupError),
          gcsUri,
        });
      }
    }
  }
};

OCR_ENDPOINTS.forEach((path) => {
  app.post(path, handleOcrRequest);
});

const port = Number(process.env.PORT) || 8080;
app.listen(port, () => {
  console.log(`OCR proxy listening on port ${port}`);
});
