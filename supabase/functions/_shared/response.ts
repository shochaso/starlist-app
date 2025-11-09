// HTTP response helpers
// Usage: import { jsonResponse, errorResponse } from "../_shared/response.ts";

export interface JsonResponse<T = unknown> {
  ok: boolean;
  data?: T;
  error?: string;
}

/**
 * Create JSON response
 */
export function jsonResponse<T>(
  data: T,
  status: number = 200,
  headers: Record<string, string> = {}
): Response {
  return new Response(
    JSON.stringify({ ok: true, data }),
    {
      status,
      headers: {
        'Content-Type': 'application/json',
        ...headers,
      },
    }
  );
}

/**
 * Create error response
 */
export function errorResponse(
  error: string,
  status: number = 500,
  headers: Record<string, string> = {}
): Response {
  return new Response(
    JSON.stringify({ ok: false, error }),
    {
      status,
      headers: {
        'Content-Type': 'application/json',
        ...headers,
      },
    }
  );
}

