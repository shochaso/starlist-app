import LRUCache from 'lru-cache';

export type EnrichedItem = {
  name: string;
  qty?: number;
  price?: number;
  jan?: string;
  thumbnailUrl?: string;
  score?: number;
};

const cache = new LRUCache<string, Omit<EnrichedItem, 'name' | 'qty' | 'price'>>({
  max: 2000,
  ttl: 1000 * 60 * 60 * 24,
});

function normalizeName(name: string): string {
  return name
    .toLowerCase()
    .replace(/[Ａ-Ｚａ-ｚ０-９]/g, (s) => String.fromCharCode(s.charCodeAt(0) - 0xfee0))
    .replace(/["'\-]/g, ' ')
    .replace(/[^\p{L}\p{N}\s]+/gu, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

/**
 * アイテムデータをエンリッチメント（改善: データ検証とスコアリングを追加）
 */
export async function enrichItemsBasic(
  items: Array<{ name: string; qty?: number; price?: number }>,
): Promise<EnrichedItem[]> {
  const output: EnrichedItem[] = [];
  
  for (const item of items) {
    // データ検証: 必須フィールドと妥当性チェック
    if (!item.name || item.name.trim().length === 0) {
      continue; // 無効なアイテムをスキップ
    }
    
    if (item.price !== undefined && (item.price < 0 || item.price > 1000000)) {
      continue; // 異常な価格をスキップ
    }
    
    if (item.qty !== undefined && (item.qty < 1 || item.qty > 1000)) {
      continue; // 異常な数量をスキップ
    }

    const key = `n:${normalizeName(item.name)}`;
    const cached = cache.get(key);
    if (cached) {
      output.push({ ...item, ...cached });
      continue;
    }

    // スコアリング: データの完全性に基づいてスコアを計算
    let score = 0.9; // デフォルトスコア
    if (item.price === undefined) score -= 0.1;
    if (item.qty === undefined) score -= 0.05;
    if (item.name.length < 2) score -= 0.1;
    
    const enriched: Omit<EnrichedItem, 'name' | 'qty' | 'price'> = {
      jan: undefined,
      thumbnailUrl: undefined,
      score: Math.max(0.5, score), // 最小スコア0.5を保証
    };
    cache.set(key, enriched);
    output.push({ ...item, ...enriched });
  }
  
  return output;
}
