// Status:: in-progress
// Source-of-Truth:: supabase/functions/telemetry/index.ts
// Spec-State:: 確定済み
// Last-Updated:: 2025-11-07

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { HttpError, buildCorsHeaders, enforceOpsSecret, jsonResponse, requireUser, safeLog } from "./shared.ts";

interface TelemetryPayload {
  app: string;
  env: "dev" | "stg" | "prod";
  event: string;
  ok: boolean;
  latency_ms?: number;
  err_code?: string;
  extra?: Record<string, unknown>;
}

serve(async (req) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: buildCorsHeaders(req) });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method Not Allowed" }, 405, req);
  }

  try {
    enforceOpsSecret(req);
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    const { supabase } = await requireUser(req, supabaseUrl, supabaseServiceKey, { requireOpsClaim: true });

    const body = await req.json().catch(() => null) as TelemetryPayload | null;

    // バリデーション
    if (!body || !body.app || !body.env || !body.event || typeof body.ok !== "boolean") {
      return jsonResponse({ error: "Bad Request: app, env, event, ok are required" }, 400, req);
    }

    // env値の検証
    if (!["dev", "stg", "prod"].includes(body.env)) {
      return jsonResponse({ error: "Bad Request: env must be dev, stg, or prod" }, 400, req);
    }

    const { app, env, event, ok, latency_ms, err_code, extra } = body;

    // ops_metricsテーブルに挿入
    const { error } = await supabase
      .from("ops_metrics")
      .insert({
        app,
        env,
        event,
        ok,
        latency_ms: latency_ms ?? null,
        err_code: err_code ?? null,
        extra: extra ?? null,
      });

    if (error) {
      safeLog("telemetry", "Insert error", error);
      return jsonResponse({ error: "Insert failed", details: error.message }, 500, req);
    }

    return jsonResponse({ ok: true }, 201, req);
  } catch (error) {
    if (error instanceof HttpError) {
      return jsonResponse({ error: error.message }, error.status, req);
    }
    safeLog("telemetry", "Error", error);
    return jsonResponse({ error: "Internal server error" }, 500, req);
  }
});
