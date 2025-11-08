// Status:: in-progress
// Source-of-Truth:: supabase/functions/ops-slack-summary/index.ts
// Spec-State:: 確定済み（自動閾値調整＋週次レポート可視化）
// Last-Updated:: 2025-11-08

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface SummaryQuery {
  dryRun?: boolean;
  period?: string; // '14d' (default)
}

interface NotificationStats {
  day: string;
  level: string;
  notification_count: number;
  avg_success_rate: number | null;
  avg_p95_ms: number | null;
  total_errors: number;
  delivered_count: number;
  failed_count: number;
}

interface ThresholdStats {
  meanNotifications: number;
  stdDev: number;
  newThreshold: number;
  criticalThreshold: number;
}

interface WeeklySummary {
  normal: number;
  warning: number;
  critical: number;
  normalChange: string;
  warningChange: string;
  criticalChange: string;
}

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

// Compute ISO week number in JST (YYYY-Wnn format)
function isoWeekJST(date: Date = jstNow()): string {
  const d = new Date(date);
  d.setHours(d.getHours() - 9); // Convert JST to UTC for calculation
  const dayNum = d.getUTCDay() || 7;
  d.setUTCDate(d.getUTCDate() + 4 - dayNum);
  const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
  const weekNum = Math.ceil((((d.getTime() - yearStart.getTime()) / 86400000) + 1) / 7);
  return `${d.getUTCFullYear()}-W${weekNum.toString().padStart(2, "0")}`;
}

// Format JST date string (YYYY-MM-DD)
function formatJSTDate(date: Date = jstNow()): string {
  const jst = new Date(date.getTime() + 9 * 60 * 60 * 1000);
  const year = jst.getUTCFullYear();
  const month = String(jst.getUTCMonth() + 1).padStart(2, "0");
  const day = String(jst.getUTCDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}

// Get next Monday in JST
function getNextMondayJST(): string {
  const jst = jstNow();
  const dayOfWeek = jst.getUTCDay();
  const daysUntilMonday = dayOfWeek === 0 ? 1 : 8 - dayOfWeek;
  const nextMonday = new Date(jst.getTime() + daysUntilMonday * 24 * 60 * 60 * 1000);
  return formatJSTDate(nextMonday);
}

// Fetch notification statistics from v_ops_notify_stats view
async function fetchStats(
  supabaseUrl: string,
  anonKey: string,
  period: string = "14d"
): Promise<NotificationStats[]> {
  const supabase = createClient(supabaseUrl, anonKey);

  const { data: stats, error: statsError } = await supabase
    .from("v_ops_notify_stats")
    .select("*")
    .order("day", { ascending: false });

  if (statsError) {
    console.error("[ops-slack-summary] Failed to fetch stats:", statsError);
    throw statsError;
  }

  return (stats || []) as NotificationStats[];
}

// Calculate thresholds using mean ± standard deviation
function calculateThresholds(stats: NotificationStats[]): ThresholdStats {
  if (stats.length === 0) {
    // Return default thresholds if no data
    return {
      meanNotifications: 0,
      stdDev: 0,
      newThreshold: 0,
      criticalThreshold: 0,
    };
  }

  const notifications = stats.map((s) => s.notification_count);
  const mean = notifications.reduce((a, b) => a + b, 0) / notifications.length;
  const variance =
    notifications.reduce((sum, n) => sum + Math.pow(n - mean, 2), 0) / notifications.length;
  const stdDev = Math.sqrt(variance);

  const newThreshold = mean + 2 * stdDev;
  const criticalThreshold = mean + 3 * stdDev;

  return {
    meanNotifications: Math.round(mean * 100) / 100,
    stdDev: Math.round(stdDev * 100) / 100,
    newThreshold: Math.round(newThreshold * 100) / 100,
    criticalThreshold: Math.round(criticalThreshold * 100) / 100,
  };
}

// Generate weekly summary with week-over-week comparison
function generateWeeklySummary(stats: NotificationStats[]): WeeklySummary {
  // Current week (last 7 days)
  const now = new Date();
  const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
  const currentWeekStats = stats.filter(
    (s) => new Date(s.day) >= sevenDaysAgo && new Date(s.day) <= now
  );

  // Previous week (7-14 days ago)
  const fourteenDaysAgo = new Date(now.getTime() - 14 * 24 * 60 * 60 * 1000);
  const previousWeekStats = stats.filter(
    (s) => new Date(s.day) >= fourteenDaysAgo && new Date(s.day) < sevenDaysAgo
  );

  // Count by level for current week
  const currentNormal = currentWeekStats
    .filter((s) => s.level === "NORMAL")
    .reduce((sum, s) => sum + s.notification_count, 0);
  const currentWarning = currentWeekStats
    .filter((s) => s.level === "WARNING")
    .reduce((sum, s) => sum + s.notification_count, 0);
  const currentCritical = currentWeekStats
    .filter((s) => s.level === "CRITICAL")
    .reduce((sum, s) => sum + s.notification_count, 0);

  // Count by level for previous week
  const previousNormal = previousWeekStats
    .filter((s) => s.level === "NORMAL")
    .reduce((sum, s) => sum + s.notification_count, 0);
  const previousWarning = previousWeekStats
    .filter((s) => s.level === "WARNING")
    .reduce((sum, s) => sum + s.notification_count, 0);
  const previousCritical = previousWeekStats
    .filter((s) => s.level === "CRITICAL")
    .reduce((sum, s) => sum + s.notification_count, 0);

  // Calculate percentage changes
  const normalChange =
    previousNormal > 0
      ? `${((currentNormal - previousNormal) / previousNormal * 100).toFixed(1)}%`
      : currentNormal > 0
      ? "+100%"
      : "±0";
  const warningChange =
    previousWarning > 0
      ? `${((currentWarning - previousWarning) / previousWarning * 100).toFixed(1)}%`
      : currentWarning > 0
      ? "+100%"
      : "±0";
  const criticalChange =
    previousCritical > 0
      ? `${((currentCritical - previousCritical) / previousCritical * 100).toFixed(1)}%`
      : currentCritical > 0
      ? "+100%"
      : "±0";

  return {
    normal: currentNormal,
    warning: currentWarning,
    critical: currentCritical,
    normalChange: normalChange.startsWith("-") ? normalChange : `+${normalChange}`,
    warningChange: warningChange.startsWith("-") ? warningChange : `+${warningChange}`,
    criticalChange: criticalChange.startsWith("-") ? criticalChange : `+${criticalChange}`,
  };
}

// Generate Slack message
function generateSlackMessage(
  reportWeek: string,
  thresholds: ThresholdStats,
  weeklySummary: WeeklySummary,
  nextDate: string
): string {
  const { meanNotifications, stdDev, newThreshold } = thresholds;
  const { normal, warning, critical, normalChange, warningChange, criticalChange } =
    weeklySummary;

  // Generate comment based on trends
  let comment = "通知数は安定傾向。";
  if (critical > 0) {
    comment = "重大通知あり。要調査。";
  } else if (warning > 5) {
    comment = "警告通知が増加傾向。監視強化。";
  } else if (normal < 10) {
    comment = "通知数が少ない。閾値見直し検討。";
  }

  return `📊 OPS Summary Report（${reportWeek}）
────────────────────────────
✅ 正常通知：${normal}件（前週比 ${normalChange}）
⚠ 警告通知：${warning}件（${warningChange}）
🔥 重大通知：${critical}件（${criticalChange}）

📈 通知平均：${meanNotifications}件 / σ=${stdDev}
🔧 新閾値：${newThreshold}件（μ+2σ）

📅 次回自動閾値再算出：${nextDate}（月）
────────────────────────────
🧠 コメント：${comment}`;
}

// Send message to Slack with retry and exponential backoff
async function sendToSlack(
  webhookUrl: string,
  message: string,
  maxRetries: number = 3
): Promise<{ success: boolean; status: number; body: string }> {
  const delays = [250, 1000, 3000]; // ms

  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      const response = await fetch(webhookUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ text: message }),
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

serve(async (req: Request): Promise<Response> => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Validate required environment variables
    const supabaseUrl = getEnv("supabase_url", true);
    const supabaseAnonKey = getEnv("supabase_anon_key", true);
    const slackWebhook = getEnv("slack_webhook_ops_summary", false);

    // Parse request
    const query = req.method === "GET"
      ? Object.fromEntries(new URL(req.url).searchParams.entries())
      : await req.json().catch(() => ({})) as SummaryQuery;

    const period = query.period || "14d";
    const dryRun = query.dryRun === true || query.dryRun === "true" || query.dryRun === "1";

    // Fetch statistics
    const stats = await fetchStats(supabaseUrl, supabaseAnonKey, period);

    // Calculate thresholds
    const thresholds = calculateThresholds(stats);

    // Generate weekly summary
    const weeklySummary = generateWeeklySummary(stats);

    // Generate report week and next date
    const reportWeek = isoWeekJST();
    const nextDate = getNextMondayJST();

    // Generate Slack message
    const message = generateSlackMessage(reportWeek, thresholds, weeklySummary, nextDate);

    // DryRun mode: return preview only
    if (dryRun) {
      return new Response(
        JSON.stringify({
          ok: true,
          dryRun: true,
          period,
          stats: {
            mean_notifications: thresholds.meanNotifications,
            std_dev: thresholds.stdDev,
            new_threshold: thresholds.newThreshold,
            critical_threshold: thresholds.criticalThreshold,
          },
          weekly_summary: {
            normal: weeklySummary.normal,
            warning: weeklySummary.warning,
            critical: weeklySummary.critical,
            normal_change: weeklySummary.normalChange,
            warning_change: weeklySummary.warningChange,
            critical_change: weeklySummary.criticalChange,
          },
          message,
        }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 200,
        }
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
        }
      );
    }

    // Send to Slack
    const sendResult = await sendToSlack(slackWebhook, message);

    const sentAtUtc = new Date();
    const sentAtJst = jstNow();

    // Return response
    if (sendResult.success) {
      return new Response(
        JSON.stringify({
          ok: true,
          sent: true,
          period,
          stats: {
            mean_notifications: thresholds.meanNotifications,
            std_dev: thresholds.stdDev,
            new_threshold: thresholds.newThreshold,
            critical_threshold: thresholds.criticalThreshold,
          },
          weekly_summary: {
            normal: weeklySummary.normal,
            warning: weeklySummary.warning,
            critical: weeklySummary.critical,
            normal_change: weeklySummary.normalChange,
            warning_change: weeklySummary.warningChange,
            critical_change: weeklySummary.criticalChange,
          },
          message,
          sent_at_utc: sentAtUtc.toISOString(),
          sent_at_jst: sentAtJst.toISOString(),
        }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 200,
        }
      );
    }

    // Slack send failed
    return new Response(
      JSON.stringify({
        ok: true,
        sent: false,
        period,
        stats: {
          mean_notifications: thresholds.meanNotifications,
          std_dev: thresholds.stdDev,
          new_threshold: thresholds.newThreshold,
          critical_threshold: thresholds.criticalThreshold,
        },
        weekly_summary: {
          normal: weeklySummary.normal,
          warning: weeklySummary.warning,
          critical: weeklySummary.critical,
          normal_change: weeklySummary.normalChange,
          warning_change: weeklySummary.warningChange,
          critical_change: weeklySummary.criticalChange,
        },
        message,
        error: `Slack send failed: ${sendResult.status} ${sendResult.body}`,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200, // HTTP 200 but sent: false
      }
    );
  } catch (error) {
    console.error("[ops-slack-summary] Error:", error);
    return new Response(
      JSON.stringify({
        ok: false,
        error: String(error),
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: error instanceof Error && error.message.includes("missing env") ? 500 : 502,
      }
    );
  }
});

