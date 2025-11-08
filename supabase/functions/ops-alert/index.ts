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

    // 閾値チェック（環境変数から取得、デフォルト値あり）
    const failureThreshold = Number(Deno.env.get("FAILURE_RATE_THRESHOLD")) || 10.0; // 10%
    const latencyThreshold = Number(Deno.env.get("P95_LATENCY_THRESHOLD")) || 500; // 500ms

    const alerts: Array<{ type: string; message: string; value: number; threshold: number }> = [];
    if (failureRate >= failureThreshold) {
      alerts.push({
        type: "failure_rate",
        message: `High failure rate: ${failureRate.toFixed(2)}%`,
        value: failureRate,
        threshold: failureThreshold,
      });
    }
    if (p95Latency != null && p95Latency >= latencyThreshold) {
      alerts.push({
        type: "p95_latency",
        message: `High p95 latency: ${p95Latency}ms`,
        value: p95Latency,
        threshold: latencyThreshold,
      });
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
      console.log("[ops-alert] Alerts detected:", alerts);
      
      // Save alert history to ops_alerts_history table
      if (alerts.length > 0) {
        try {
          const alertHistoryRecords = alerts.map(alert => ({
            alert_type: alert.type,
            value: alert.value,
            threshold: alert.threshold,
            period_minutes: minutes,
            metrics: result.metrics,
          }));

          const { error: insertError } = await supabase
            .from('ops_alerts_history')
            .insert(alertHistoryRecords);

          if (insertError) {
            console.error("[ops-alert] Failed to save alert history:", insertError);
          } else {
            console.log("[ops-alert] Alert history saved:", alertHistoryRecords.length, "records");
          }
        } catch (historyError) {
          console.error("[ops-alert] Error saving alert history:", historyError);
        }
      }
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


