import { compress } from "https://deno.land/x/zlib@v0.1.2/mod.ts";

// Rate limit: IP-based sliding window (100 requests per minute)
const rateLimitMap = new Map<string, { count: number; resetAt: number }>();
const RATE_LIMIT_WINDOW_MS = 60_000; // 1 minute
const RATE_LIMIT_MAX = 100;

// Mask sensitive data in JSON
function maskSensitiveData(text: string): string {
  // Mask tokens, secrets, auth values
  return text
    .replace(/"token"\s*:\s*"[^"]+"/gi, '"token":"***MASKED***"')
    .replace(/"secret"\s*:\s*"[^"]+"/gi, '"secret":"***MASKED***"')
    .replace(/"auth"\s*:\s*"[^"]+"/gi, '"auth":"***MASKED***"')
    .replace(/"authorization"\s*:\s*"[^"]+"/gi, '"authorization":"***MASKED***"')
    .replace(/Bearer\s+[A-Za-z0-9\-._~+/]+/gi, 'Bearer ***MASKED***')
    .replace(/api[_-]?key["\s:=]+([A-Za-z0-9\-._~+/]+)/gi, 'api_key="***MASKED***"');
}

// Get client IP from request
function getClientIP(req: Request): string {
  return req.headers.get('x-forwarded-for')?.split(',')[0]?.trim() ||
         req.headers.get('x-real-ip') ||
         'unknown';
}

// Rate limit check
function checkRateLimit(ip: string): boolean {
  const now = Date.now();
  const record = rateLimitMap.get(ip);
  
  if (!record || now > record.resetAt) {
    rateLimitMap.set(ip, { count: 1, resetAt: now + RATE_LIMIT_WINDOW_MS });
    return true;
  }
  
  if (record.count >= RATE_LIMIT_MAX) {
    return false;
  }
  
  record.count++;
  return true;
}

Deno.serve(async (req: Request) => {
  try {
    if (req.method !== 'POST') {
      return new Response('Method Not Allowed', { status: 405 });
    }

    const clientIP = getClientIP(req);
    
    // Rate limit check
    if (!checkRateLimit(clientIP)) {
      return new Response('Too Many Requests', { status: 429 });
    }

    const body = await req.text();
    const timestamp = new Date().toISOString();
    
    // Mask sensitive data
    const maskedBody = maskSensitiveData(body);
    
    // Compress body for logging
    const compressed = compress(new TextEncoder().encode(maskedBody));
    const compressedSize = compressed.length;
    const originalSize = body.length;
    
    console.log(`[CSP REPORT] ${timestamp} IP=${clientIP} size=${originalSize} compressed=${compressedSize} ratio=${((compressedSize/originalSize)*100).toFixed(1)}%`);
    console.log(`[CSP REPORT BODY]`, maskedBody.substring(0, 500)); // Log first 500 chars

    return new Response(null, { status: 204 });
  } catch (e) {
    console.error('[CSP REPORT ERROR]', e);
    return new Response(null, { status: 500 });
  }
});
