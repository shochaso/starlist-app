// Status:: in-progress
// Source-of-Truth:: supabase/functions/ops-health/index.ts
// Spec-State:: 確定済み（期間別・サービス別集計）
// Last-Updated:: 2025-11-07

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { HttpError, buildCorsHeaders, enforceOpsSecret, jsonResponse, requireUser, safeLog } from "./shared.ts";

interface HealthQuery {
  period?: string; // '1h', '6h', '24h', '7d'
  app?: string;
  env?: string;
  event?: string;
}

interface HealthAggregation {
  app: string | null;
  env: string | null;
  event: string | null;
  uptime_percent: number;
  mean_p95_ms: number | null;
  alert_count: number;
  alert_trend: 'increasing' | 'decreasing' | 'stable';
}

serve(async (req) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const query = req.method === "GET" 
      ? Object.fromEntries(new URL(req.url).searchParams.entries())
      : await req.json().catch(() => ({})) as HealthQuery;

    enforceOpsSecret(req);

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const { supabase } = await requireUser(req, supabaseUrl, supabaseServiceKey, { requireOpsClaim: true });

    const period = query.period || '24h';
    const periodMinutes: Record<string, number> = {
      '1h': 60,
      '6h': 360,
      '24h': 1440,
      '7d': 10080,
    };
    const minutes = periodMinutes[period] || 1440;
    const since = new Date(Date.now() - minutes * 60 * 1000).toISOString();

    // Get alert history
    let alertQuery = supabase
      .from('ops_alerts_history')
      .select('*')
      .gte('alerted_at', since)
      .order('alerted_at', { ascending: false });

    if (query.app) {
      alertQuery = alertQuery.eq('app', query.app);
    }
    if (query.env) {
      alertQuery = alertQuery.eq('env', query.env);
    }
    if (query.event) {
      alertQuery = alertQuery.eq('event', query.event);
    }

    const { data: alerts, error: alertsError } = await alertQuery;

    if (alertsError) {
      safeLog("ops-health", "Alert history query error", alertsError);
      throw alertsError;
    }

    // Get metrics from v_ops_5min
    let metricsQuery = supabase
      .from('v_ops_5min')
      .select('*')
      .gte('bucket_5m', since)
      .order('bucket_5m', { ascending: true });

    if (query.app) {
      metricsQuery = metricsQuery.eq('app', query.app);
    }
    if (query.env) {
      metricsQuery = metricsQuery.eq('env', query.env);
    }
    if (query.event) {
      metricsQuery = metricsQuery.eq('event', query.event);
    }

    const { data: metrics, error: metricsError } = await metricsQuery;

    if (metricsError) {
      safeLog("ops-health", "Metrics query error", metricsError);
      throw metricsError;
    }

    // Aggregate health metrics
    const aggregations = aggregateHealthMetrics(alerts || [], metrics || [], query);

    return jsonResponse({ ok: true, period, aggregations }, 200, req);
  } catch (error) {
    if (error instanceof HttpError) {
      return jsonResponse({ error: error.message }, error.status, req);
    }
    safeLog("ops-health", "Error", error);
    return jsonResponse({ error: "Internal server error" }, 500, req);
  }
});

function aggregateHealthMetrics(
  alerts: any[],
  metrics: any[],
  query: HealthQuery
): HealthAggregation[] {
  // Group metrics by app/env/event
  const groups = new Map<string, {
    app: string | null;
    env: string | null;
    event: string | null;
    metrics: any[];
    alerts: any[];
  }>();

  for (const metric of metrics) {
    const key = `${metric.app || 'unknown'}:${metric.env || 'unknown'}:${metric.event || 'unknown'}`;
    if (!groups.has(key)) {
      groups.set(key, {
        app: metric.app || null,
        env: metric.env || null,
        event: metric.event || null,
        metrics: [],
        alerts: [],
      });
    }
    groups.get(key)!.metrics.push(metric);
  }

  // Group alerts by app/env/event
  for (const alert of alerts) {
    const key = `${alert.app || 'unknown'}:${alert.env || 'unknown'}:${alert.event || 'unknown'}`;
    if (!groups.has(key)) {
      groups.set(key, {
        app: alert.app || null,
        env: alert.env || null,
        event: alert.event || null,
        metrics: [],
        alerts: [],
      });
    }
    groups.get(key)!.alerts.push(alert);
  }

  // Calculate aggregations
  const aggregations: HealthAggregation[] = [];

  for (const [key, group] of groups) {
    // Calculate uptime %: (1 - failure_rate) * 100
    const totalRequests = group.metrics.reduce((sum, m) => sum + (m.total || 0), 0);
    const totalFailures = group.metrics.reduce((sum, m) => sum + (m.total || 0) * (m.failure_rate || 0), 0);
    const failureRate = totalRequests > 0 ? totalFailures / totalRequests : 0;
    const uptimePercent = (1 - failureRate) * 100;

    // Calculate mean p95 latency
    const p95Latencies = group.metrics
      .map(m => m.p95_latency_ms)
      .filter((v): v is number => v != null);
    const meanP95Ms = p95Latencies.length > 0
      ? p95Latencies.reduce((sum, v) => sum + v, 0) / p95Latencies.length
      : null;

    // Calculate alert trend
    const alertCount = group.alerts.length;
    const firstHalf = Math.floor(group.alerts.length / 2);
    const firstHalfCount = group.alerts.slice(0, firstHalf).length;
    const secondHalfCount = group.alerts.slice(firstHalf).length;
    
    let alertTrend: 'increasing' | 'decreasing' | 'stable' = 'stable';
    if (alertCount > 1) {
      if (secondHalfCount > firstHalfCount * 1.2) {
        alertTrend = 'increasing';
      } else if (secondHalfCount < firstHalfCount * 0.8) {
        alertTrend = 'decreasing';
      }
    }

    aggregations.push({
      app: group.app,
      env: group.env,
      event: group.event,
      uptime_percent: Math.round(uptimePercent * 100) / 100,
      mean_p95_ms: meanP95Ms ? Math.round(meanP95Ms) : null,
      alert_count: alertCount,
      alert_trend: alertTrend,
    });
  }

  return aggregations;
}
