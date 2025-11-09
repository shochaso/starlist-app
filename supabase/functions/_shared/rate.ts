// Rate limiting and idempotency helpers
// Usage: import { rateLimit, assertIdempotent } from "../_shared/rate.ts";

const bucket = new Map<string, { c: number; t: number }>();
const seen = new Set<string>();

/**
 * Rate limit check (sliding window)
 * @param key - Unique identifier (e.g., IP address)
 * @param limit - Maximum requests per window
 * @param windowMs - Window size in milliseconds
 * @throws Error if rate limit exceeded
 */
export function rateLimit(key: string, limit = 30, windowMs = 60_000) {
  const now = Date.now();
  const rec = bucket.get(key) ?? { c: 0, t: now };
  if (now - rec.t > windowMs) {
    rec.c = 0;
    rec.t = now;
  }
  if (++rec.c > limit) {
    throw new Error("rate_limit");
  }
  bucket.set(key, rec);
}

/**
 * Assert idempotency (prevent duplicate processing)
 * @param id - Unique identifier
 * @throws Error if id already seen
 */
export function assertIdempotent(id: string) {
  if (!id) {
    throw new Error("missing_id");
  }
  if (seen.has(id)) {
    throw new Error("duplicate");
  }
  seen.add(id);
}
<<<<<<< HEAD

// Usage: import { rateLimit, assertIdempotent } from "../_shared/rate.ts";

const bucket = new Map<string, { c: number; t: number }>();
const seen = new Set<string>();

/**
 * Rate limit check (sliding window)
 * @param key - Unique identifier (e.g., IP address)
 * @param limit - Maximum requests per window
 * @param windowMs - Window size in milliseconds
 * @throws Error if rate limit exceeded
 */
export function rateLimit(key: string, limit = 30, windowMs = 60_000) {
  const now = Date.now();
  const rec = bucket.get(key) ?? { c: 0, t: now };
  if (now - rec.t > windowMs) {
    rec.c = 0;
    rec.t = now;
  }
  if (++rec.c > limit) {
    throw new Error('rate_limit');
  }
  bucket.set(key, rec);
}

/**
 * Assert idempotency (prevent duplicate processing)
 * @param id - Unique identifier
 * @throws Error if id already seen
 */
export function assertIdempotent(id: string) {
  if (!id) {
    throw new Error('missing_id');
  }
  if (seen.has(id)) {
    throw new Error('duplicate');
  }
  seen.add(id);
}

=======
>>>>>>> 8abb626 (feat(ops): add ultra pack enhancements — Makefile, audit bundle, risk register, RACI matrix)
