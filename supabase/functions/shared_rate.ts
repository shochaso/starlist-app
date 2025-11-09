const bucket = new Map<string, { c: number; t: number }>();
const seen = new Set<string>();

export function rateLimit(key: string, limit = 30, windowMs = 60_000) {
  const now = Date.now();
  const rec = bucket.get(key) ?? { c: 0, t: now };
  if (now - rec.t > windowMs) {
    rec.c = 0;
    rec.t = now;
  }
  if (++rec.c > limit) throw new Error("rate_limit");
  bucket.set(key, rec);
}

export function assertIdempotent(id: string) {
  if (!id) throw new Error("missing_id");
  if (seen.has(id)) throw new Error("duplicate");
  seen.add(id);
}
