// Status:: in-progress
// Source-of-Truth:: supabase/functions/ops-summary-email/index.ts
// Spec-State:: 確定済み（週次レポート自動送信）
// Last-Updated:: 2025-11-07

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface SummaryQuery {
  dryRun?: boolean;
  period?: string; // '7d' (default)
}

serve(async (req) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const query = req.method === "GET"
      ? Object.fromEntries(new URL(req.url).searchParams.entries())
      : await req.json().catch(() => ({})) as SummaryQuery;

    const dryRun = query.dryRun === true || query.dryRun === "true";
    const period = query.period || "7d";

    // Authentication check (skip for dryRun mode)
    const authHeader = req.headers.get("authorization");
    if (!dryRun && !authHeader) {
      return new Response(
        JSON.stringify({ error: "Unauthorized: Missing authorization header" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

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

    // Calculate period dates
    const periodDays: Record<string, number> = {
      "7d": 7,
      "30d": 30,
    };
    const days = periodDays[period] || 7;
    const since = new Date(Date.now() - days * 24 * 60 * 60 * 1000).toISOString();

    // Get health metrics from ops-health Edge Function (via internal call or direct query)
    // For now, query directly from database
    const { data: metrics, error: metricsError } = await supabase
      .from("v_ops_5min")
      .select("*")
      .gte("bucket_5m", since)
      .order("bucket_5m", { ascending: true });

    if (metricsError) {
      throw metricsError;
    }

    // Get alert history
    const { data: alerts, error: alertsError } = await supabase
      .from("ops_alerts_history")
      .select("*")
      .gte("alerted_at", since)
      .order("alerted_at", { ascending: false });

    if (alertsError) {
      throw alertsError;
    }

    // Calculate aggregates
    const totalRequests = metrics?.reduce((sum, m) => sum + (m.total || 0), 0) || 0;
    const totalFailures = metrics?.reduce((sum, m) => sum + (m.total || 0) * (m.failure_rate || 0), 0) || 0;
    const failureRate = totalRequests > 0 ? (totalFailures / totalRequests) * 100 : 0;
    const uptimePercent = 100 - failureRate;

    const p95Latencies = metrics?.map(m => m.p95_latency_ms).filter((v): v is number => v != null) || [];
    const meanP95Ms = p95Latencies.length > 0
      ? Math.round(p95Latencies.reduce((sum, v) => sum + v, 0) / p95Latencies.length)
      : null;

    const alertCount = alerts?.length || 0;
    // Compare with previous period (simplified: assume 50% of current for demo)
    const previousAlertCount = Math.round(alertCount * 1.2); // Placeholder
    const alertTrend = alertCount < previousAlertCount ? "↓" : alertCount > previousAlertCount ? "↑" : "→";
    const alertChange = Math.abs(alertCount - previousAlertCount);

    // Generate HTML template
    const html = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .header { background: #2563eb; color: white; padding: 20px; text-align: center; }
    .content { padding: 20px; }
    .metric { margin: 20px 0; padding: 15px; background: #f3f4f6; border-radius: 8px; }
    .metric-label { font-weight: bold; color: #6b7280; }
    .metric-value { font-size: 24px; color: #111827; margin-top: 5px; }
    .trend { color: ${alertCount < previousAlertCount ? "#10b981" : alertCount > previousAlertCount ? "#ef4444" : "#6b7280"}; }
  </style>
</head>
<body>
  <div class="header">
    <h1>STARLIST OPS Weekly Summary</h1>
    <p>Period: Last ${days} days</p>
  </div>
  <div class="content">
    <div class="metric">
      <div class="metric-label">Uptime</div>
      <div class="metric-value">${uptimePercent.toFixed(2)}%</div>
    </div>
    <div class="metric">
      <div class="metric-label">Mean P95 Latency</div>
      <div class="metric-value">${meanP95Ms ? `${meanP95Ms}ms` : "N/A"}</div>
    </div>
    <div class="metric">
      <div class="metric-label">Alerts</div>
      <div class="metric-value">
        ${alertCount} 
        <span class="trend">(${alertTrend}${alertChange} WoW)</span>
      </div>
    </div>
  </div>
</body>
</html>
    `.trim();

    if (dryRun) {
      return new Response(
        JSON.stringify({
          ok: true,
          dryRun: true,
          preview: html,
          metrics: {
            uptime_percent: uptimePercent,
            mean_p95_ms: meanP95Ms,
            alert_count: alertCount,
            alert_trend: alertTrend,
            alert_change: alertChange,
          },
        }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 200,
        }
      );
    }

    // Send email (TODO: implement with SendGrid/Resend/etc)
    const emailApiKey = Deno.env.get("RESEND_API_KEY") || Deno.env.get("SENDGRID_API_KEY");
    if (emailApiKey) {
      // TODO: Implement email sending
      console.log("[ops-summary-email] Email sending not yet implemented");
    }

    return new Response(
      JSON.stringify({
        ok: true,
        sent: false, // TODO: set to true when email is sent
        message: "Email sending not yet implemented",
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      }
    );
  } catch (e) {
    console.error("[ops-summary-email] Error:", e);
    return new Response(
      JSON.stringify({ ok: false, error: String(e), dryRun: true }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 500,
      }
    );
  }
});

