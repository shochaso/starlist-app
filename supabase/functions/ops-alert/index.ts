// Status:: in-progress
// Source-of-Truth:: supabase/functions/ops-alert/index.ts
// Spec-State:: 確定済み（dryRun）
// Last-Updated:: 2025-11-07

import { serve } from "std/http/server.ts";
import type { SupabaseClient } from "supabase-js";
import {
  buildCorsHeaders,
  createServiceClient,
  enforceOpsSecret,
  HttpError,
  jsonResponse,
  requireUser,
  safeLog,
} from "./shared.ts";

interface AlertQuery {
  dry_run?: boolean;
  minutes?: number; // 監視期間（デフォルト15分）
}

serve(async (req) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: buildCorsHeaders(req) });
  }

  try {
    const query = req.method === "GET"
      ? Object.fromEntries(new URL(req.url).searchParams.entries())
      : await req.json().catch(() => ({})) as AlertQuery;

    const dryRun = query.dry_run !== false; // デフォルトtrue

    enforceOpsSecret(req);

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    let supabase: SupabaseClient;
    if (!dryRun) {
      const auth = await requireUser(req, supabaseUrl, supabaseServiceKey, {
        requireOpsClaim: true,
      });
      supabase = auth.supabase;
    } else {
      supabase = createServiceClient(supabaseUrl, supabaseServiceKey);
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
      safeLog("ops-alert", "Query error", error);
      return jsonResponse(
        { error: "Query failed", details: error.message },
        500,
        req,
      );
    }

    // 集計計算
    const total = metrics?.length || 0;
    const failures = metrics?.filter((m) => !m.ok).length || 0;
    const failureRate = total > 0 ? (failures / total) * 100 : 0;
    const latencies = metrics?.filter((m) =>
      m.latency_ms != null
    ).map((m) => m.latency_ms) || [];
    const p95Latency = latencies.length > 0
      ? latencies.sort((a, b) => a - b)[Math.floor(latencies.length * 0.95)]
      : null;

    // 閾値チェック（環境変数から取得、デフォルト値あり）
    const failureThreshold = Number(Deno.env.get("FAILURE_RATE_THRESHOLD")) ||
      10.0; // 10%
    const latencyThreshold = Number(Deno.env.get("P95_LATENCY_THRESHOLD")) ||
      500; // 500ms

    const alerts: Array<
      { type: string; message: string; value: number; threshold: number }
    > = [];
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
      console.log(
        "[ops-alert] dryRun result:",
        JSON.stringify(result, null, 2),
      );
    } else {
      console.log("[ops-alert] Alerts detected:", alerts);

      // Save alert history to ops_alerts_history table
      if (alerts.length > 0) {
        try {
          const alertHistoryRecords = alerts.map((alert) => ({
            alert_type: alert.type,
            value: alert.value,
            threshold: alert.threshold,
            period_minutes: minutes,
            metrics: result.metrics,
          }));

          const { error: insertError } = await supabase
            .from("ops_alerts_history")
            .insert(alertHistoryRecords);

          if (insertError) {
            safeLog("ops-alert", "Failed to save alert history", insertError);
          } else {
            console.log(
              "[ops-alert] Alert history saved:",
              alertHistoryRecords.length,
              "records",
            );
          }
        } catch (historyError) {
          safeLog("ops-alert", "Error saving alert history", historyError);
        }
      }
    }

    return jsonResponse(result, 200, req);
  } catch (error) {
    if (error instanceof HttpError) {
      return jsonResponse({ error: error.message }, error.status, req);
    }
    safeLog("ops-alert", "Error", error);
    return jsonResponse(
      { error: "Internal server error", dryRun: true },
      500,
      req,
    );
  }
});
