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

/**
 * レシートテキストを解析して構造化データを抽出
 * 改善: より柔軟なパターンマッチングとデータ検証を追加
 */
export function parseReceiptText(text: string): Pick<OCRResult, 'raw' | 'items' | 'store' | 'date'> {
  const sanitized = text.replace(/\r/g, '');
  const lines = sanitized
    .split('\n')
    .map((line) => line.trim())
    .filter(Boolean);

  const items: ReceiptItem[] = [];
  let store: string | undefined;
  let date: string | undefined;

  // 店舗名の抽出（最初の数行から店舗名らしきものを検出）
  for (let i = 0; i < Math.min(5, lines.length); i++) {
    const line = lines[i];
    // 店舗名のパターン: 全角カタカナ、漢字、英数字が含まれる行で、金額パターンがない
    if (
      line.length > 2 &&
      line.length < 50 &&
      !line.match(/\d{4}[年\/\-]\d{1,2}[月\/\-]\d{1,2}/) && // 日付パターンでない
      !line.match(/\d+円/) && // 金額パターンでない
      (line.match(/[ァ-ヶー]/) || line.match(/[一-龯]/) || line.match(/[A-Za-z]/))
    ) {
      store = line;
      break;
    }
  }

  // 日付の抽出（YYYY/MM/DD, YYYY-MM-DD, YYYY年MM月DD日などのパターン）
  const datePatterns = [
    /(\d{4})[年\/\-](\d{1,2})[月\/\-](\d{1,2})/,
    /(\d{4})(\d{2})(\d{2})/,
  ];
  for (const line of lines) {
    for (const pattern of datePatterns) {
      const match = line.match(pattern);
      if (match) {
        date = match[0];
        break;
      }
    }
    if (date) break;
  }

  // アイテム行の抽出（改善されたパターンマッチング）
  for (const line of lines) {
    // パターン1: "商品名 x数量 価格円" または "商品名 価格円"
    let match = line.match(/^(.+?)\s+(?:[x×]\s*)?(\d+)\s*[個本枚]\s+(\d+)(?:円|¥)?$/);
    if (match) {
      const qty = Number(match[2]) || 1;
      const price = Number(match[3]);
      if (price > 0 && price < 1000000) {
        // 妥当性チェック: 価格が0より大きく100万円未満
        items.push({ name: match[1].trim(), qty, price });
        continue;
      }
    }

    // パターン2: "商品名 価格円"（数量なし、デフォルト1）
    match = line.match(/^(.+?)\s+(\d{1,6})(?:円|¥)?$/);
    if (match) {
      const price = Number(match[2]);
      // 価格が妥当な範囲で、商品名が空でない場合
      if (price > 0 && price < 1000000 && match[1].trim().length > 0) {
        items.push({ name: match[1].trim(), qty: 1, price });
        continue;
      }
    }

    // パターン3: "商品名 x数量 価格"（円マークなし）
    match = line.match(/^(.+?)\s+[x×]\s*(\d+)\s+(\d+)$/);
    if (match) {
      const qty = Number(match[2]) || 1;
      const price = Number(match[3]);
      if (price > 0 && price < 1000000) {
        items.push({ name: match[1].trim(), qty, price });
        continue;
      }
    }
  }

  return {
    raw: sanitized,
    items,
    store,
    date,
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
