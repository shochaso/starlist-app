import express from 'express';
import process from 'node:process';
import { DocumentProcessorServiceClient } from '@google-cloud/documentai';

const app = express();
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

app.post('/ocr:process', async (req, res) => {

  const { mimeType, contentBase64 } = req.body ?? {};
  if (!mimeType || !contentBase64) {
    return res
      .status(400)
      .json({ error: 'mimeType と contentBase64 は必須です。' });
  }

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
  const client = new DocumentProcessorServiceClient();

  try {
    const [result] = await client.processDocument({
      name,
      rawDocument: {
        content: Buffer.from(contentBase64, 'base64'),
        mimeType,
      },
    });

    const document = result.document ?? {};
    const text = document.text ?? '';

    return res.json({
      text,
      document,
    });
  } catch (error) {
    const message = String(error?.message ?? error);
    let status = 500;
    if (message.includes('PERMISSION_DENIED')) status = 403;
    if (message.includes('NOT_FOUND')) status = 404;
    return res.status(status).json({
      error: message,
    });
  }
});

const port = process.env.PORT ?? 8080;
app.listen(port, () => {
  console.log(`OCR proxy listening on port ${port}`);
});
