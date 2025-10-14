import { createHash } from 'node:crypto';

import LRUCache from 'lru-cache';
import { createWorker } from 'tesseract.js';

const cache = new LRUCache<string, OCRResult>({ max: 500, ttl: 1000 * 60 * 60 });
const langs = process.env.TESS_LANGS || 'jpn+eng';
const dataPath = process.env.TESSDATA_URL;
const confMin = Number(process.env.OCR_CONFIDENCE_MIN || '0.7');
const concurrency = Math.max(1, Number(process.env.TESS_WORKER_CONCURRENCY || '1'));

type WorkerWrapper = {
  worker: Awaited<ReturnType<typeof createWorker>>;
  busy: boolean;
};

export type ReceiptItem = { name: string; qty?: number; price?: number };

export type OCRResult = {
  raw: string;
  avgConf: number;
  store?: string;
  date?: string;
  items: ReceiptItem[];
};

let poolPromise: Promise<WorkerWrapper[]> | null = null;
const waitQueue: Array<(wrapper: WorkerWrapper) => void> = [];

async function createWorkerWrapper(): Promise<WorkerWrapper> {
  const worker = await createWorker({
    langPath: dataPath,
    logger: () => {},
  });
  await worker.load();
  await worker.loadLanguage(langs);
  await worker.initialize(langs);
  return { worker, busy: false };
}

async function getPool(): Promise<WorkerWrapper[]> {
  if (!poolPromise) {
    poolPromise = Promise.all(Array.from({ length: concurrency }, () => createWorkerWrapper()));
  }
  return poolPromise;
}

async function acquireWorker(): Promise<WorkerWrapper> {
  const pool = await getPool();
  const free = pool.find((entry) => !entry.busy);
  if (free) {
    free.busy = true;
    return free;
  }
  return new Promise<WorkerWrapper>((resolve) => {
    waitQueue.push(resolve);
  });
}

function releaseWorker(wrapper: WorkerWrapper) {
  const next = waitQueue.shift();
  if (next) {
    next(wrapper);
  } else {
    wrapper.busy = false;
  }
}

export function parseReceiptText(text: string): Pick<OCRResult, 'raw' | 'items' | 'store' | 'date'> {
  const sanitized = text.replace(/\r/g, '');
  const lines = sanitized
    .split('\n')
    .map((line) => line.trim())
    .filter(Boolean);

  const items: ReceiptItem[] = [];
  for (const line of lines) {
    const match = line.match(/^(.+?)\s*(x?\d+)?\s+(\d+)(?:円)?$/);
    if (match) {
      const qty = Number((match[2] || '1').replace('x', '')) || 1;
      items.push({ name: match[1], qty, price: Number(match[3]) });
    }
  }

  return {
    raw: sanitized,
    items,
    store: undefined,
    date: undefined,
  };
}

export async function ocrImageBuffer(buffer: Buffer): Promise<OCRResult> {
  const key = `sha1:${createHash('sha1').update(buffer).digest('hex')}`;
  const cached = cache.get(key);
  if (cached) {
    return cached;
  }

  const wrapper = await acquireWorker();
  try {
    const { data } = await wrapper.worker.recognize(buffer);
    const avgConf = (data?.confidence ?? 0) / 100;
    const parsed = parseReceiptText(data?.text ?? '');

    const result: OCRResult = {
      raw: parsed.raw,
      avgConf,
      store: parsed.store,
      date: parsed.date,
      items: parsed.items,
    };

    cache.set(key, result);
    return result;
  } finally {
    releaseWorker(wrapper);
  }
}

export function isLowConfidence(avgConf: number): boolean {
  return avgConf < confMin;
}
