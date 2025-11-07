// Status:: in-progress
// Source-of-Truth:: supabase/functions/telemetry/index.ts
// Spec-State:: 確定済み
// Last-Updated:: 2025-11-07

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

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
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method Not Allowed" }),
      { status: 405, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    
    // Service role keyを使用してRLSをバイパス（Edge Functions用）
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const body = await req.json().catch(() => null) as TelemetryPayload | null;

    // バリデーション
    if (!body || !body.app || !body.env || !body.event || typeof body.ok !== "boolean") {
      return new Response(
        JSON.stringify({ error: "Bad Request: app, env, event, ok are required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // env値の検証
    if (!["dev", "stg", "prod"].includes(body.env)) {
      return new Response(
        JSON.stringify({ error: "Bad Request: env must be dev, stg, or prod" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
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
      console.error("[telemetry] Insert error:", error);
      return new Response(
        JSON.stringify({ error: "Insert failed", details: error.message }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({ ok: true }),
      { status: 201, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("[telemetry] Error:", error);
    return new Response(
      JSON.stringify({ error: String(error) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});

