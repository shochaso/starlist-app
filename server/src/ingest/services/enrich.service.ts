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

export async function enrichItemsBasic(
  items: Array<{ name: string; qty?: number; price?: number }>,
): Promise<EnrichedItem[]> {
  const output: EnrichedItem[] = [];
  for (const item of items) {
    const key = `n:${normalizeName(item.name)}`;
    const cached = cache.get(key);
    if (cached) {
      output.push({ ...item, ...cached });
      continue;
    }

    const enriched: Omit<EnrichedItem, 'name' | 'qty' | 'price'> = {
      jan: undefined,
      thumbnailUrl: undefined,
      score: 0.9,
    };
    cache.set(key, enriched);
    output.push({ ...item, ...enriched });
  }
  return output;
}
