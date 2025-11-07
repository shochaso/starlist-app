// Status:: in-progress
// Source-of-Truth:: supabase/functions/ops-alert/index.ts
// Spec-State:: 確定済み（dryRun）
// Last-Updated:: 2025-11-07

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface AlertQuery {
  dry_run?: boolean;
  minutes?: number; // 監視期間（デフォルト15分）
}

serve(async (req) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const query = req.method === "GET" 
      ? Object.fromEntries(new URL(req.url).searchParams.entries())
      : await req.json().catch(() => ({})) as AlertQuery;

    const dryRun = query.dry_run !== false; // デフォルトtrue

    // Authentication check (skip for dryRun mode in CI/testing)
    const authHeader = req.headers.get("authorization");
    if (!dryRun && !authHeader) {
      return new Response(
        JSON.stringify({ error: "Unauthorized: Missing authorization header" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    
    // Create client with user's JWT for RLS validation (if provided)
    const supabase = createClient(supabaseUrl, supabaseServiceKey, 
      authHeader ? { global: { headers: { Authorization: authHeader } } } : {}
    );

    // Verify the user is authenticated (skip for dryRun)
    if (!dryRun) {
      const { data: { user }, error: authError } = await supabase.auth.getUser();
      if (authError || !user) {
        return new Response(
          JSON.stringify({ error: "Unauthorized: Invalid or expired token" }),
          { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
    }
    const minutes = Number(query.minutes) || 15;

    // 直近N分のデータを取得（v_ops_5minビューを使用）
    const since = new Date(Date.now() - minutes * 60 * 1000).toISOString();

    const { data: metrics, error } = await supabase
      .from("ops_metrics")
      .select("*")
      .gte("ts_ingested", since)
      .order("ts_ingested", { ascending: false });

    if (error) {
      console.error("[ops-alert] Query error:", error);
      return new Response(
        JSON.stringify({ error: "Query failed", details: error.message }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 集計計算
    const total = metrics?.length || 0;
    const failures = metrics?.filter(m => !m.ok).length || 0;
    const failureRate = total > 0 ? (failures / total) * 100 : 0;
    const latencies = metrics?.filter(m => m.latency_ms != null).map(m => m.latency_ms) || [];
    const p95Latency = latencies.length > 0
      ? latencies.sort((a, b) => a - b)[Math.floor(latencies.length * 0.95)]
      : null;

    // 閾値チェック（例: 失敗率10%以上、p95遅延500ms以上）
    const failureThreshold = 10.0; // 10%
    const latencyThreshold = 500; // 500ms

    const alerts: string[] = [];
    if (failureRate >= failureThreshold) {
      alerts.push(`High failure rate: ${failureRate.toFixed(2)}% (threshold: ${failureThreshold}%)`);
    }
    if (p95Latency != null && p95Latency >= latencyThreshold) {
      alerts.push(`High p95 latency: ${p95Latency}ms (threshold: ${latencyThreshold}ms)`);
    }

    const result = {
      ok: true,
      dryRun,
      period_minutes: minutes,
      metrics: {
        total,
        failures,
        failure_rate: failureRate.toFixed(2),
        p95_latency_ms: p95Latency,
      },
      alerts: alerts.length > 0 ? alerts : null,
    };

    if (dryRun) {
      console.log("[ops-alert] dryRun result:", JSON.stringify(result, null, 2));
    } else {
      // 本番時はSlack Webhook等に通知
      // TODO: Slack通知実装
      console.log("[ops-alert] Alerts detected:", alerts);
    }

    return new Response(
      JSON.stringify(result),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("[ops-alert] Error:", error);
    return new Response(
      JSON.stringify({ error: String(error), dryRun: true }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});


