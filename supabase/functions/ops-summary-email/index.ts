// Status:: in-progress
// Source-of-Truth:: supabase/functions/ops-summary-email/index.ts
// Spec-State:: 確定済み（週次レポート自動送信）
// Last-Updated:: 2025-11-07

<<<<<<< HEAD
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";
import { HttpError, buildCorsHeaders, createServiceClient, enforceOpsSecret, jsonResponse, requireUser, safeLog } from "./shared.ts";
=======
import { serve } from "std/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};
>>>>>>> 8abb626 (feat(ops): add ultra pack enhancements — Makefile, audit bundle, risk register, RACI matrix)

interface SummaryQuery {
  dryRun?: boolean;
  period?: string; // '7d' (default)
}

// Get ISO week number (YYYY-Wnn format)
function getReportWeek(date: Date): string {
  const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
  const dayNum = d.getUTCDay() || 7;
  d.setUTCDate(d.getUTCDate() + 4 - dayNum);
  const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
<<<<<<< HEAD
  const weekNum = Math.ceil((((d.getTime() - yearStart.getTime()) / 86400000) + 1) / 7);
  return `${d.getUTCFullYear()}-W${weekNum.toString().padStart(2, '0')}`;
}

// Convert UTC to JST (UTC+9)
function toJST(utcDate: Date): Date {
  return new Date(utcDate.getTime() + 9 * 60 * 60 * 1000);
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: buildCorsHeaders(req) });
=======
  const weekNum = Math.ceil(
    (((d.getTime() - yearStart.getTime()) / 86400000) + 1) / 7,
  );
  return `${d.getUTCFullYear()}-W${weekNum.toString().padStart(2, "0")}`;
}

// Ensure all recipients are @starlist.jp domain
function ensureStarlistRecipients(list: string[]): string[] {
  return list.filter((email) => {
    const trimmed = email.trim();
    if (!trimmed.includes("@starlist.jp")) {
      console.warn(
        `[ops-summary-email] Dropping non-starlist recipient: ${trimmed}`,
      );
      return false;
    }
    return true;
  });
}

// Fetch metrics from ops-health function or return defaults
async function fetchMetrics(
  supabaseUrl: string,
  anonKey: string,
  period: string = "7d",
): Promise<Metrics> {
  try {
    const url = `${supabaseUrl}/functions/v1/ops-health?period=${period}`;
    const response = await fetch(url, {
      headers: {
        "Authorization": `Bearer ${anonKey}`,
        "Content-Type": "application/json",
      },
    });

    if (!response.ok) {
      throw new Error(`ops-health returned ${response.status}`);
    }

    const data = await response.json();
    if (data.ok && data.aggregations && data.aggregations.length > 0) {
      // Aggregate across all services/apps/envs
      const aggregations = data.aggregations;
      const avgUptime =
        aggregations.reduce((sum: number, agg: { uptime_percent: number }) =>
          sum + agg.uptime_percent, 0) / aggregations.length;
      const avgP95 = aggregations
        .map((agg: { mean_p95_ms: number | null }) =>
          agg.mean_p95_ms
        )
        .filter((v: number | null): v is number =>
          v != null
        );
      const meanP95 = avgP95.length > 0
        ? Math.round(avgP95.reduce((sum, v) => sum + v, 0) / avgP95.length)
        : null;
      const totalAlerts = aggregations.reduce(
        (sum: number, agg: { alert_count: number }) => sum + agg.alert_count,
        0,
      );

      return {
        uptimePct: Math.round(avgUptime * 100) / 100,
        meanP95Ms: meanP95,
        alertTrend: [{
          date: new Date().toISOString().slice(0, 10),
          count: totalAlerts,
        }],
        degraded: false,
      };
    }
  } catch (error) {
    console.error(
      "[ops-summary-email] Failed to fetch metrics from ops-health:",
      error,
    );
>>>>>>> 8abb626 (feat(ops): add ultra pack enhancements — Makefile, audit bundle, risk register, RACI matrix)
  }

  try {
    const query = req.method === "GET"
      ? Object.fromEntries(new URL(req.url).searchParams.entries())
      : await req.json().catch(() => ({})) as SummaryQuery;

<<<<<<< HEAD
    const dryRun = query.dryRun === true || query.dryRun === "true";
    const period = query.period || "7d";

    enforceOpsSecret(req);
=======
// Render email HTML with metrics
function renderEmail(metrics: Metrics, reportWeek: string): EmailContent {
  const { uptimePct, meanP95Ms, alertTrend } = metrics;
  const alertCount = alertTrend.reduce((sum, t) => sum + t.count, 0);
  const preheader = `Weekly health: ${uptimePct.toFixed(2)}% uptime, ${
    meanP95Ms ? `${meanP95Ms}ms` : "N/A"
  } p95, ${alertCount} alerts`;

  const subject = `STARLIST OPS Weekly – ${reportWeek} (Uptime ${
    uptimePct.toFixed(2)
  }%, p95 ${meanP95Ms ? `${meanP95Ms}ms` : "N/A"})`;
>>>>>>> 8abb626 (feat(ops): add ultra pack enhancements — Makefile, audit bundle, risk register, RACI matrix)

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    let supabase: SupabaseClient;
    if (!dryRun) {
      const auth = await requireUser(req, supabaseUrl, supabaseServiceKey, { requireOpsClaim: true });
      supabase = auth.supabase;
    } else {
      supabase = createServiceClient(supabaseUrl, supabaseServiceKey);
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
      safeLog("ops-summary-email", "Metrics query error", metricsError);
      throw metricsError;
    }

    // Get alert history
    const { data: alerts, error: alertsError } = await supabase
      .from("ops_alerts_history")
      .select("*")
      .gte("alerted_at", since)
      .order("alerted_at", { ascending: false });

    if (alertsError) {
      safeLog("ops-summary-email", "Alert history query error", alertsError);
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
    
    // Compare with previous period (7 days before the current period)
    const previousSince = new Date(Date.now() - days * 2 * 24 * 60 * 60 * 1000).toISOString();
    const { data: previousAlerts } = await supabase
      .from("ops_alerts_history")
      .select("*")
      .gte("alerted_at", previousSince)
      .lt("alerted_at", since)
      .order("alerted_at", { ascending: false });
    
    const previousAlertCount = previousAlerts?.length || 0;
    const alertTrend = alertCount < previousAlertCount ? "↓" : alertCount > previousAlertCount ? "↑" : "→";
    const alertChange = Math.abs(alertCount - previousAlertCount);

    // Generate HTML template with List-Unsubscribe header and preheader
    const reportWeek = getReportWeek(new Date());
    const preheader = `Uptime: ${uptimePercent.toFixed(2)}% | Mean P95: ${meanP95Ms ? `${meanP95Ms}ms` : 'N/A'} | Alerts: ${alertCount} (${alertTrend}${alertChange} WoW)`;
    
    const html = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <!-- Preheader (hidden text for email clients) -->
  <div style="display: none; font-size: 1px; color: #fefefe; line-height: 1px; font-family: Arial, sans-serif; max-height: 0px; max-width: 0px; opacity: 0; overflow: hidden;">
    ${preheader}
  </div>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; }
    .header { background: #2563eb; color: white; padding: 20px; text-align: center; }
    .content { padding: 20px; }
    .metric { margin: 20px 0; padding: 15px; background: #f3f4f6; border-radius: 8px; }
    .metric-label { font-weight: bold; color: #6b7280; }
    .metric-value { font-size: 24px; color: #111827; margin-top: 5px; }
    .trend { color: ${alertCount < previousAlertCount ? "#10b981" : alertCount > previousAlertCount ? "#ef4444" : "#6b7280"}; }
    .footer { padding: 20px; text-align: center; color: #6b7280; font-size: 12px; }
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
  <div class="footer">
    <p>STARLIST OPS Team</p>
    <p><a href="mailto:ops@starlist.jp?subject=Unsubscribe">Unsubscribe</a> | <a href="https://starlist.jp/ops">View Dashboard</a></p>
  </div>
</body>
</html>
    `.trim();

<<<<<<< HEAD
    if (dryRun) {
      return jsonResponse({
        ok: true,
        dryRun: true,
        preview: html,
        report_week: reportWeek,
        metrics: {
          uptime_percent: uptimePercent,
          mean_p95_ms: meanP95Ms,
          alert_count: alertCount,
          alert_trend: alertTrend,
          alert_change: alertChange,
        },
      }, 200, req);
    }

    // Check idempotency: prevent duplicate sends for the same week
    const { data: existingLog } = await supabase
      .from("ops_summary_email_logs")
      .select("*")
      .eq("report_week", reportWeek)
      .eq("channel", "email")
      .limit(1)
      .single();

    if (existingLog && existingLog.ok) {
      console.log(`[ops-summary-email] Skipped: already sent for week ${reportWeek}`);
      return jsonResponse({
        ok: true,
        skipped: true,
        message: `Already sent for week ${reportWeek}`,
        existing_log: existingLog,
      }, 200, req);
    }

    // Send email via Resend or SendGrid
    const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
    const RESEND_FROM = Deno.env.get("RESEND_FROM") ?? "STARLIST OPS <ops@starlist.jp>";
    const RESEND_TO_LIST = (Deno.env.get("RESEND_TO_LIST") ?? "").split(",").map(s => s.trim()).filter(Boolean);

    const SENDGRID_API_KEY = Deno.env.get("SENDGRID_API_KEY");
    const SENDGRID_FROM = Deno.env.get("SENDGRID_FROM") ?? "ops@starlist.jp";
    const SENDGRID_TO_LIST = (Deno.env.get("SENDGRID_TO_LIST") ?? "").split(",").map(s => s.trim()).filter(Boolean);

    let emailSent = false;
    let emailError: string | null = null;
    let emailProvider: string | null = null;
    let emailMessageId: string | null = null;
    let emailToCount = 0;
    const startTime = Date.now();

    // Validate recipient domain (safety: only @starlist.jp allowed)
    const validateRecipients = (recipients: string[]): boolean => {
      return recipients.every(email => email.includes("@starlist.jp"));
    };

    // Try Resend first (preferred)
    if (RESEND_API_KEY && RESEND_TO_LIST.length > 0) {
      if (!validateRecipients(RESEND_TO_LIST)) {
        throw new Error("Invalid recipient domain: only @starlist.jp allowed");
      }

      try {
        const payload = {
          from: RESEND_FROM,
          to: RESEND_TO_LIST,
          subject: `STARLIST OPS Weekly (${new Date().toISOString().slice(0, 10)})`,
          html,
          headers: {
            "List-Unsubscribe": `<mailto:ops@starlist.jp?subject=Unsubscribe>, <https://starlist.jp/ops/unsubscribe>`,
            "List-Unsubscribe-Post": "List-Unsubscribe=One-Click",
          },
        };

        const res = await fetch("https://api.resend.com/emails", {
          method: "POST",
          headers: {
            "Authorization": `Bearer ${RESEND_API_KEY}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify(payload),
        });

        if (!res.ok) {
          const text = await res.text();
          throw new Error(`Resend error: ${res.status} ${text}`);
        }

        const result = await res.json();
        emailSent = true;
        emailProvider = "resend";
        emailMessageId = result.id || null;
        emailToCount = RESEND_TO_LIST.length;
        console.log("[ops-summary-email] Email sent via Resend:", result);
      } catch (e) {
        emailError = String(e);
        safeLog("ops-summary-email", "Resend error", e);
      }
    }

    // Fallback to SendGrid if Resend failed or not configured
    if (!emailSent && SENDGRID_API_KEY && SENDGRID_TO_LIST.length > 0) {
      if (!validateRecipients(SENDGRID_TO_LIST)) {
        throw new Error("Invalid recipient domain: only @starlist.jp allowed");
=======
  return { subject, html, preheader };
}

// Insert audit log (idempotency check)
async function logInsert(
  supabaseUrl: string,
  anonKey: string,
  reportWeek: string,
  channel: string,
  provider: string,
): Promise<{ inserted: boolean; existingId?: string }> {
  try {
    const url = `${supabaseUrl}/rest/v1/ops_summary_email_logs`;
    const payload = {
      report_week: reportWeek,
      channel,
      provider,
      to_count: 0,
      subject: "",
      sent_at_utc: new Date().toISOString(),
      ok: false,
    };

    const response = await fetch(url, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${anonKey}`,
        "Content-Type": "application/json",
        "apikey": anonKey,
        "Prefer": "return=representation",
      },
      body: JSON.stringify(payload),
    });

    if (response.status === 201 || response.status === 200) {
      const data = await response.json();
      return { inserted: true, existingId: data[0]?.id };
    }

    // Check if conflict (duplicate)
    if (response.status === 409 || response.status === 400) {
      const errorText = await response.text();
      if (errorText.includes("duplicate") || errorText.includes("unique")) {
        return { inserted: false };
      }
    }

    console.warn(`[ops-summary-email] logInsert returned ${response.status}`);
    return { inserted: true }; // Continue even if logging fails
  } catch (error) {
    console.error("[ops-summary-email] logInsert error:", error);
    return { inserted: true }; // Continue even if logging fails
  }
}

// Update audit log with send result
async function logUpdate(
  supabaseUrl: string,
  anonKey: string,
  reportWeek: string,
  channel: string,
  provider: string,
  messageId: string | null,
  toCount: number,
  subject: string,
  ok: boolean,
  errorMessage?: string,
): Promise<void> {
  try {
    const url =
      `${supabaseUrl}/rest/v1/ops_summary_email_logs?report_week=eq.${reportWeek}&channel=eq.${channel}&provider=eq.${provider}`;
    const payload: Record<string, unknown> = {
      message_id: messageId,
      to_count: toCount,
      subject,
      sent_at_utc: new Date().toISOString(),
      ok,
    };
    if (errorMessage) {
      payload.error_message = errorMessage;
    }

    await fetch(url, {
      method: "PATCH",
      headers: {
        "Authorization": `Bearer ${anonKey}`,
        "Content-Type": "application/json",
        "apikey": anonKey,
      },
      body: JSON.stringify(payload),
    });
  } catch (error) {
    console.error("[ops-summary-email] logUpdate error:", error);
    // Non-critical, continue
  }
}

// Send email via Resend
async function sendViaResend(
  apiKey: string,
  from: string,
  to: string[],
  subject: string,
  html: string,
): Promise<{ success: boolean; messageId: string | null; error?: string }> {
  try {
    const response = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from,
        to,
        subject,
        html,
        headers: {
          "List-Unsubscribe": "<mailto:ops@starlist.jp?subject=unsubscribe>",
        },
      }),
    });

    if (!response.ok) {
      const text = await response.text();
      throw new Error(`Resend API error: ${response.status} ${text}`);
    }

    const data = await response.json();
    return { success: true, messageId: data.id || null };
  } catch (error) {
    return { success: false, messageId: null, error: String(error) };
  }
}

// Send email via SendGrid (fallback)
async function sendViaSendGrid(
  apiKey: string,
  from: string,
  to: string[],
  subject: string,
  html: string,
): Promise<{ success: boolean; messageId: string | null; error?: string }> {
  try {
    const response = await fetch("https://api.sendgrid.com/v3/mail/send", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        personalizations: [{ to: to.map((email) => ({ email })) }],
        from: {
          email: from.replace(/.*<(.+)>.*/, "$1") || from,
          name: "STARLIST OPS",
        },
        subject,
        content: [{ type: "text/html", value: html }],
        headers: {
          "List-Unsubscribe": "<mailto:ops@starlist.jp?subject=unsubscribe>",
        },
      }),
    });

    if (!response.ok) {
      const text = await response.text();
      throw new Error(`SendGrid API error: ${response.status} ${text}`);
    }

    const messageId = response.headers.get("x-message-id") || "unknown";
    return { success: true, messageId };
  } catch (error) {
    return { success: false, messageId: null, error: String(error) };
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

    // Parse request
    const query = req.method === "GET"
      ? Object.fromEntries(new URL(req.url).searchParams.entries())
      : await req.json().catch(() => ({})) as SummaryQuery;

    const dryRun = query.dryRun === true || query.dryRun === "true" ||
      query.dryRun === "1";
    const period = query.period || "7d";
    const reportWeek = isoWeekJST();

    // Fetch metrics
    const metrics = await fetchMetrics(supabaseUrl, supabaseAnonKey, period);

    // Render email
    const emailContent = renderEmail(metrics, reportWeek);

    // DryRun mode: return preview only
    if (dryRun) {
      return new Response(
        JSON.stringify({
          ok: true,
          dryRun: true,
          report_week: reportWeek,
          metrics: {
            uptime_percent: metrics.uptimePct,
            mean_p95_ms: metrics.meanP95Ms,
            alert_count: metrics.alertTrend.reduce(
              (sum, t) => sum + t.count,
              0,
            ),
            degraded: metrics.degraded || false,
          },
          preview_html: emailContent.html,
        }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 200,
        },
      );
    }

    // Production mode: send email
    // Check idempotency
    const channel = "email";
    const logResult = await logInsert(
      supabaseUrl,
      supabaseAnonKey,
      reportWeek,
      channel,
      "resend",
    );
    if (!logResult.inserted) {
      return new Response(
        JSON.stringify({
          ok: true,
          skipped: true,
          reason: "duplicate",
          report_week: reportWeek,
        }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 200,
        },
      );
    }

    // Determine recipients
    let recipients: string[] = [];
    if (query.toOverride && Array.isArray(query.toOverride)) {
      recipients = ensureStarlistRecipients(query.toOverride);
    } else {
      recipients = ensureStarlistRecipients(getEnvArray("resend_to_list", []));
    }

    if (recipients.length === 0) {
      throw new Error(
        "No valid recipients found. Set resend_to_list or provide toOverride.",
      );
    }

    // Try Resend first
    const resendApiKey = getEnv("resend_api_key", false);
    const resendFrom = getEnv("resend_from", false) ||
      "STARLIST OPS <ops@starlist.jp>";
    let sendResult: {
      success: boolean;
      messageId: string | null;
      error?: string;
    } | null = null;
    let provider = "resend";

    if (resendApiKey) {
      sendResult = await sendViaResend(
        resendApiKey,
        resendFrom,
        recipients,
        emailContent.subject,
        emailContent.html,
      );
    }

    // Fallback to SendGrid if Resend failed or not configured
    if (!sendResult || !sendResult.success) {
      const sendgridApiKey = getEnv("sendgrid_api_key", false);
      const sendgridFrom = getEnv("sendgrid_from", false) || "ops@starlist.jp";
      if (sendgridApiKey) {
        provider = "sendgrid";
        sendResult = await sendViaSendGrid(
          sendgridApiKey,
          sendgridFrom,
          recipients,
          emailContent.subject,
          emailContent.html,
        );
>>>>>>> 8abb626 (feat(ops): add ultra pack enhancements — Makefile, audit bundle, risk register, RACI matrix)
      }

<<<<<<< HEAD
      try {
        const sgPayload = {
          personalizations: [{ to: SENDGRID_TO_LIST.map(e => ({ email: e })) }],
          from: { email: SENDGRID_FROM, name: "STARLIST OPS" },
          subject: `STARLIST OPS Weekly (${new Date().toISOString().slice(0, 10)})`,
          content: [{ type: "text/html", value: html }],
          headers: {
            "List-Unsubscribe": `<mailto:ops@starlist.jp?subject=Unsubscribe>, <https://starlist.jp/ops/unsubscribe>`,
            "List-Unsubscribe-Post": "List-Unsubscribe=One-Click",
          },
        };

        const res = await fetch("https://api.sendgrid.com/v3/mail/send", {
          method: "POST",
          headers: {
            "Authorization": `Bearer ${SENDGRID_API_KEY}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify(sgPayload),
        });

        if (!res.ok) {
          const text = await res.text();
          throw new Error(`SendGrid error: ${res.status} ${text}`);
        }

        emailSent = true;
        emailProvider = "sendgrid";
        emailMessageId = null; // SendGrid doesn't return message ID in response
        emailToCount = SENDGRID_TO_LIST.length;
        console.log("[ops-summary-email] Email sent via SendGrid");
      } catch (e) {
        emailError = String(e);
        safeLog("ops-summary-email", "SendGrid error", e);
      }
    }

    const durationMs = Date.now() - startTime;
    const sentAtUtc = new Date();
    const sentAtJst = toJST(sentAtUtc);

    // Log email send (upsert for idempotency)
    if (emailSent && emailProvider) {
      try {
        const { error: logError } = await supabase
          .from("ops_summary_email_logs")
          .upsert({
            report_week: reportWeek,
            channel: "email",
            provider: emailProvider,
            message_id: emailMessageId,
            to_count: emailToCount,
            subject: `STARLIST OPS Weekly (${new Date().toISOString().slice(0, 10)})`,
            sent_at_utc: sentAtUtc.toISOString(),
            sent_at_jst: sentAtJst.toISOString(),
            duration_ms: durationMs,
            ok: true,
            error_code: null,
            error_message: null,
          }, {
            onConflict: "report_week,channel,provider",
          });

        if (logError) {
          safeLog("ops-summary-email", "Failed to log email send", logError);
        }
      } catch (logError) {
        safeLog("ops-summary-email", "Log error", logError);
      }
    } else if (emailError) {
      // Log failure
      try {
        await supabase
          .from("ops_summary_email_logs")
          .insert({
            report_week: reportWeek,
            channel: "email",
            provider: emailProvider || "unknown",
            to_count: 0,
            subject: `STARLIST OPS Weekly (${new Date().toISOString().slice(0, 10)})`,
            sent_at_utc: sentAtUtc.toISOString(),
            sent_at_jst: sentAtJst.toISOString(),
            duration_ms: durationMs,
            ok: false,
            error_code: "SEND_FAILED",
            error_message: emailError,
          });
      } catch (logError) {
        safeLog("ops-summary-email", "Failed to log error", logError);
      }
    }

    if (!emailSent) {
      return jsonResponse({
        ok: false,
        error: emailError || "No email service configured. Set RESEND_API_KEY or SENDGRID_API_KEY.",
      }, 500, req);
    }

    return jsonResponse({
      ok: true,
      sent: true,
      message: "Email sent successfully",
      provider: emailProvider,
      message_id: emailMessageId,
      to_count: emailToCount,
      report_week: reportWeek,
      sent_at_utc: sentAtUtc.toISOString(),
      sent_at_jst: sentAtJst.toISOString(),
      duration_ms: durationMs,
    }, 200, req);
  } catch (e) {
    if (e instanceof HttpError) {
      return jsonResponse({ error: e.message }, e.status, req);
    }
    safeLog("ops-summary-email", "Error", e);
    return jsonResponse({ ok: false, error: String(e), dryRun: true }, 500, req);
=======
    if (!sendResult || !sendResult.success) {
      await logUpdate(
        supabaseUrl,
        supabaseAnonKey,
        reportWeek,
        channel,
        provider,
        null,
        0,
        emailContent.subject,
        false,
        sendResult?.error || "No email provider configured",
      );
      return new Response(
        JSON.stringify({
          ok: false,
          error: sendResult?.error || "No email provider configured",
          provider,
        }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 502,
        },
      );
    }

    // Update audit log
    await logUpdate(
      supabaseUrl,
      supabaseAnonKey,
      reportWeek,
      channel,
      provider,
      sendResult.messageId,
      recipients.length,
      emailContent.subject,
      true,
    );

    return new Response(
      JSON.stringify({
        ok: true,
        provider,
        report_week: reportWeek,
        message_id: sendResult.messageId,
        to_count: recipients.length,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      },
    );
  } catch (error) {
    console.error("[ops-summary-email] Error:", error);
    return new Response(
      JSON.stringify({
        ok: false,
        error: String(error),
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: error instanceof Error && error.message.includes("missing env")
          ? 500
          : 500,
      },
    );
>>>>>>> 8abb626 (feat(ops): add ultra pack enhancements — Makefile, audit bundle, risk register, RACI matrix)
  }
});
