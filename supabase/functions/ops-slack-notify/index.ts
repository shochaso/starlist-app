// Status:: in-progress
// Source-of-Truth:: supabase/functions/ops-slack-notify/index.ts
// Spec-State:: 確定済み（Slack日次通知）
// Last-Updated:: 2025-11-08

import { serve } from "std/http/server.ts";
import { createClient } from "supabase-js";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface SlackNotifyQuery {
  range?: string; // '24h' | 'yesterday' (default: '24h')
  dryRun?: boolean;
}

interface Metrics24h {
  successRate: number;
  p95Ms: number | null;
  errorCount: number;
  topErrorEndpoint?: string;
  topErrorRate?: number;
}

interface SlackMessage {
  text: string;
  blocks?: Array<Record<string, unknown>>;
}

type AlertLevel = "NORMAL" | "WARNING" | "CRITICAL";

// Environment variable reader
function getEnv(key: string, required = true): string {
  const value = Deno.env.get(key);
  if (required && !value) {
    throw new Error(`missing env: ${key}`);
  }
  return value || "";
}

// Get current time in JST (UTC+9)
function jstNow(): Date {
  return new Date(Date.now() + 9 * 60 * 60 * 1000);
}

// Format JST date string (YYYY-MM-DD HH:mm JST)
function formatJST(date: Date = jstNow()): string {
  const jst = new Date(date.getTime() + 9 * 60 * 60 * 1000);
  const year = jst.getUTCFullYear();
  const month = String(jst.getUTCMonth() + 1).padStart(2, "0");
  const day = String(jst.getUTCDate()).padStart(2, "0");
  const hours = String(jst.getUTCHours()).padStart(2, "0");
  const minutes = String(jst.getUTCMinutes()).padStart(2, "0");
  return `${year}-${month}-${day} ${hours}:${minutes} JST`;
}

// Fetch 24h metrics from database
async function fetchMetrics24h(
  supabaseUrl: string,
  anonKey: string,
  range: string = "24h",
): Promise<Metrics24h> {
  const supabase = createClient(supabaseUrl, anonKey);

  // Calculate time range
  const now = new Date();
  let since: Date;
  if (range === "yesterday") {
    // Yesterday 00:00 JST to 23:59 JST
    const yesterday = new Date(now.getTime() - 24 * 60 * 60 * 1000);
    since = new Date(
      Date.UTC(
        yesterday.getUTCFullYear(),
        yesterday.getUTCMonth(),
        yesterday.getUTCDate(),
        0,
        0,
        0,
      ),
    );
    since.setTime(since.getTime() - 9 * 60 * 60 * 1000); // Convert to UTC
  } else {
    // Last 24 hours
    since = new Date(now.getTime() - 24 * 60 * 60 * 1000);
  }

  const sinceISO = since.toISOString();

  // Query v_ops_5min for aggregated metrics
  const { data: metrics, error: metricsError } = await supabase
    .from("v_ops_5min")
    .select("*")
    .gte("bucket_5m", sinceISO)
    .order("bucket_5m", { ascending: true });

  if (metricsError) {
    console.error("[ops-slack-notify] Failed to fetch metrics:", metricsError);
    throw metricsError;
  }

  if (!metrics || metrics.length === 0) {
    // Return safe defaults if no data
    return {
      successRate: 99.9,
      p95Ms: null,
      errorCount: 0,
    };
  }

  // Aggregate metrics
  let totalRequests = 0;
  let totalErrors = 0;
  const p95Latencies: number[] = [];
  const errorByEndpoint: Record<string, number> = {};

  for (const m of metrics) {
    const total = (m.total as number) || 0;
    const failureRate = (m.failure_rate as number) || 0;
    const p95 = m.p95_latency_ms as number | null;
    const endpoint = m.endpoint as string | null;

    totalRequests += total;
    totalErrors += Math.round(total * failureRate);

    if (p95 != null) {
      p95Latencies.push(p95);
    }

    if (endpoint && failureRate > 0) {
      errorByEndpoint[endpoint] = (errorByEndpoint[endpoint] || 0) +
        Math.round(total * failureRate);
    }
  }

  const successRate = totalRequests > 0
    ? ((totalRequests - totalErrors) / totalRequests) * 100
    : 100.0;

  const meanP95 = p95Latencies.length > 0
    ? Math.round(
      p95Latencies.reduce((sum, v) => sum + v, 0) / p95Latencies.length,
    )
    : null;

  // Find top error endpoint
  let topErrorEndpoint: string | undefined;
  let topErrorRate: number | undefined;
  if (Object.keys(errorByEndpoint).length > 0) {
    const sorted = Object.entries(errorByEndpoint)
      .sort(([, a], [, b]) => b - a);
    const [endpoint, count] = sorted[0];
    topErrorEndpoint = endpoint;
    topErrorRate = totalRequests > 0 ? (count / totalRequests) * 100 : 0;
  }

  return {
    successRate: Math.round(successRate * 100) / 100,
    p95Ms: meanP95,
    errorCount: totalErrors,
    topErrorEndpoint,
    topErrorRate: topErrorRate
      ? Math.round(topErrorRate * 100) / 100
      : undefined,
  };
}

// Determine alert level based on thresholds
function determineLevel(metrics: Metrics24h): AlertLevel {
  const { successRate, p95Ms } = metrics;

  // Critical: success_rate < 98.0% OR p95_ms >= 1500
  if (successRate < 98.0 || (p95Ms != null && p95Ms >= 1500)) {
    return "CRITICAL";
  }

  // Warning: 98.0% ≤ success_rate < 99.5% OR 1000 ≤ p95_ms < 1500
  if (
    (successRate >= 98.0 && successRate < 99.5) ||
    (p95Ms != null && p95Ms >= 1000 && p95Ms < 1500)
  ) {
    return "WARNING";
  }

  return "NORMAL";
}

// Build Slack message text
function buildSlackMessage(
  level: AlertLevel,
  metrics: Metrics24h,
  jstTime: string,
): SlackMessage {
  const { successRate, p95Ms, errorCount, topErrorEndpoint, topErrorRate } =
    metrics;

  // Emoji based on level
  const emoji = level === "CRITICAL" ? "🔥" : level === "WARNING" ? "⚠️" : "✅";

  // Build message text
  let text = `${emoji} OPS Monitor — ${jstTime}\n`;
  text += `Status: ${level}\n`;
  text += `Success: ${successRate.toFixed(2)}%\n`;
  text += `P95: ${p95Ms ? `${p95Ms}ms` : "N/A"}\n`;
  text += `Errors: ${errorCount}`;

  if (topErrorEndpoint && topErrorRate) {
    text += ` (top: ${topErrorEndpoint} ${topErrorRate.toFixed(1)}%)`;
  }

  text += `\nNext check: ${jstTime.split(" ")[0]} 09:00 JST`;

  // Add notes for Critical/Warning
  if (level === "CRITICAL" || level === "WARNING") {
    const notes: string[] = [];
    if (successRate < 98.0) {
      notes.push(`Investigate low success rate (${successRate.toFixed(2)}%)`);
    }
    if (p95Ms != null && p95Ms >= 1000) {
      notes.push(`Investigate high latency (P95: ${p95Ms}ms)`);
    }
    if (topErrorEndpoint) {
      notes.push(`Top error endpoint: ${topErrorEndpoint}`);
    }
    if (notes.length > 0) {
      text += `\nNotes: ${notes.join("; ")}`;
    }
  }

  return { text };
}

// Send message to Slack with retry and exponential backoff
async function sendToSlack(
  webhookUrl: string,
  message: SlackMessage,
  maxRetries: number = 3,
): Promise<{ success: boolean; status: number; body: string }> {
  const delays = [250, 1000, 3000]; // ms

  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      const response = await fetch(webhookUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(message),
        signal: AbortSignal.timeout(5000), // 5s timeout
      });

      const body = await response.text();

      if (response.ok) {
        return { success: true, status: response.status, body };
      }

      // If not last attempt, retry with backoff
      if (attempt < maxRetries - 1) {
        await new Promise((resolve) => setTimeout(resolve, delays[attempt]));
        continue;
      }

      return { success: false, status: response.status, body };
    } catch (error) {
      // If not last attempt, retry with backoff
      if (attempt < maxRetries - 1) {
        await new Promise((resolve) => setTimeout(resolve, delays[attempt]));
        continue;
      }

      return {
        success: false,
        status: 0,
        body: String(error),
      };
    }
  }

  return { success: false, status: 0, body: "Max retries exceeded" };
}

// Save audit log to database
async function saveAuditLog(
  supabaseUrl: string,
  anonKey: string,
  level: AlertLevel,
  metrics: Metrics24h,
  message: SlackMessage,
  delivered: boolean,
  responseStatus: number,
  responseBody: string,
): Promise<void> {
  try {
    const supabase = createClient(supabaseUrl, anonKey);

    await supabase.from("ops_slack_notify_logs").insert({
      level,
      success_rate: metrics.successRate,
      p95_ms: metrics.p95Ms,
      error_count: metrics.errorCount,
      payload: message,
      delivered,
      response_status: responseStatus,
      response_body: responseBody,
    });
  } catch (error) {
    console.error("[ops-slack-notify] Failed to save audit log:", error);
    // Non-critical, continue
  }
}

serve(async (req: Request): Promise<Response> => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Validate required environment variables
    const supabaseUrl = getEnv("supabase_url", true);
    const supabaseAnonKey = getEnv("supabase_anon_key", true);
    const slackWebhook = getEnv("SLACK_WEBHOOK_OPS", false);

    // Parse request
    const query = req.method === "GET"
      ? Object.fromEntries(new URL(req.url).searchParams.entries())
      : await req.json().catch(() => ({})) as SlackNotifyQuery;

    const range = query.range || "24h";
    const dryRun = query.dryRun === true || query.dryRun === "true" ||
      query.dryRun === "1";

    // Fetch metrics
    const metrics = await fetchMetrics24h(supabaseUrl, supabaseAnonKey, range);

    // Determine alert level
    const level = determineLevel(metrics);

    // Build Slack message
    const jstTime = formatJST();
    const message = buildSlackMessage(level, metrics, jstTime);

    // DryRun mode: return preview only
    if (dryRun) {
      return new Response(
        JSON.stringify({
          ok: true,
          dryRun: true,
          level,
          metrics: {
            success_rate: metrics.successRate,
            p95_ms: metrics.p95Ms,
            error_count: metrics.errorCount,
            top_error_endpoint: metrics.topErrorEndpoint,
            top_error_rate: metrics.topErrorRate,
          },
          message: message.text,
        }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 200,
        },
      );
    }

    // Production mode: send to Slack
    if (!slackWebhook) {
      return new Response(
        JSON.stringify({
          ok: false,
          error: "missing webhook",
        }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 400,
        },
      );
    }

    // Send to Slack
    const sendResult = await sendToSlack(slackWebhook, message);

    // Save audit log
    await saveAuditLog(
      supabaseUrl,
      supabaseAnonKey,
      level,
      metrics,
      message,
      sendResult.success,
      sendResult.status,
      sendResult.body,
    );

    // Return response
    if (sendResult.success) {
      return new Response(
        JSON.stringify({
          ok: true,
          delivered: true,
          level,
          stats: {
            success_rate: metrics.successRate,
            p95_ms: metrics.p95Ms,
            error_count: metrics.errorCount,
          },
        }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 200,
        },
      );
    }

    // Slack send failed but log saved
    return new Response(
      JSON.stringify({
        ok: true,
        delivered: false,
        level,
        stats: {
          success_rate: metrics.successRate,
          p95_ms: metrics.p95Ms,
          error_count: metrics.errorCount,
        },
        error: `Slack send failed: ${sendResult.status} ${sendResult.body}`,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200, // HTTP 200 but delivered: false
      },
    );
  } catch (error) {
    console.error("[ops-slack-notify] Error:", error);
    return new Response(
      JSON.stringify({
        ok: false,
        error: String(error),
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: error instanceof Error && error.message.includes("missing env")
          ? 500
          : 502,
      },
    );
  }
});
