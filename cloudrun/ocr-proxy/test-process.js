#!/usr/bin/env node
/*
 * 手動テスト用スクリプト。
 * 必要な環境変数：
 *   - GOOGLE_APPLICATION_CREDENTIALS
 *   - PROJECT / GCP_PROJECT / GOOGLE_CLOUD_PROJECT のいずれか
 *   - LOCATION または DOCAI_LOCATION
 *   - PROCESSOR または PROCESSOR_ID
 *   - FILE (ローカルの入力画像パス)
 *   - 任意: OCR_GCS_BUCKET (2MB超ファイル用)
 */

const fs = require('fs');
const path = require('path');
const { randomUUID } = require('crypto');
const { DocumentProcessorServiceClient } = require('@google-cloud/documentai');
const { Storage } = require('@google-cloud/storage');

const THRESHOLD_BYTES = 2 * 1024 * 1024; // 2MB

const log = (label, payload) => {
  console.log('[OCR:test]', label, JSON.stringify(payload));
};

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

const guessMimeType = (filePath) => {
  const ext = path.extname(filePath).toLowerCase();
  const table = {
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.gif': 'image/gif',
    '.webp': 'image/webp',
    '.tiff': 'image/tiff',
    '.tif': 'image/tiff',
    '.pdf': 'application/pdf',
  };
  return table[ext] || 'application/octet-stream';
};

(async () => {
  try {
    const { projectId, location, processorId } = resolveEnv();
    if (!projectId || !location || !processorId) {
      throw new Error('PROJECT / LOCATION / PROCESSOR の環境変数が不足しています');
    }

    const filePath = process.env.FILE;
    if (!filePath) {
      throw new Error('FILE 環境変数に入力ファイルパスを指定してください');
    }

    const absPath = path.resolve(filePath);
    const fileBytes = await fs.promises.readFile(absPath);
    const mimeType = process.env.MIME_TYPE || guessMimeType(absPath);

    const name = `projects/${projectId}/locations/${location}/processors/${processorId}`;
    log('config', { name, mimeType, fileBytes: fileBytes.length, filePath: absPath });

    const docClient = new DocumentProcessorServiceClient();
    const storage = new Storage();

    let docRequest;
    let gcsUri = null;
    let gcsFile = null;

    if (fileBytes.length > THRESHOLD_BYTES) {
      const bucketName = process.env.OCR_GCS_BUCKET;
      if (!bucketName) {
        throw new Error('入力ファイルが 2MB を超えています。OCR_GCS_BUCKET を設定してください');
      }

      const bucket = storage.bucket(bucketName);
      const objectPath = `uploads/${new Date().toISOString().replace(/[:.]/g, '-')}-${randomUUID()}`;
      gcsFile = bucket.file(objectPath);
      await gcsFile.save(fileBytes, { contentType: mimeType, resumable: false });
      gcsUri = `gs://${bucketName}/${objectPath}`;
      log('upload', { bucket: bucketName, objectPath, bytes: fileBytes.length });

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
          content: fileBytes,
          mimeType,
        },
      };
    }

    log('request', { transport: gcsUri ? 'gcsDocument' : 'rawDocument', gcsUri });

    const [result] = await docClient.processDocument(docRequest);
    const document = result.document ?? {};
    const text = document.text ?? '';

    log('result', {
      pagesLength: Array.isArray(document.pages) ? document.pages.length : 0,
      textLength: text.length,
      textPreview: text.slice(0, 2000),
    });

    if (gcsFile) {
      await gcsFile.delete({ ignoreNotFound: true }).catch((cleanupError) => {
        log('cleanup_error', { message: cleanupError?.message ?? String(cleanupError), gcsUri });
      });
    }

    console.log('\n=== OCR RESULT TEXT (truncated 2000 chars) ===');
    console.log(text.slice(0, 2000));
    console.log('=== END RESULT TEXT ===');
  } catch (error) {
    const message = String(error?.message ?? error);
    const stack = error?.stack ?? '';
    const code = error?.code ?? null;
    const details = error?.details ?? null;

    log('error', {
      message,
      code,
      details,
      shortStack: stack.split('\n').slice(0, 6).join(' | '),
    });

    process.exitCode = 1;
  }
})();
