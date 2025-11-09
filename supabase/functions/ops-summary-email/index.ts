// Status:: verified
// Source-of-Truth:: supabase/functions/ops-summary-email/index.ts
// Spec-State:: 確定済み（週次レポート自動送信）
// Last-Updated:: 2025-11-08

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface SummaryQuery {
  dryRun?: boolean;
  toOverride?: string[];
  period?: string; // '7d' (default)
}

interface Metrics {
  uptimePct: number;
  meanP95Ms: number | null;
  alertTrend: Array<{ date: string; count: number }>;
  degraded?: boolean;
}

interface EmailContent {
  subject: string;
  html: string;
  preheader: string;
}

// Import type-safe environment helpers
import { getEnv, getEnvArray } from "../_shared/env.ts";

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

// Ensure all recipients are @starlist.jp domain
function ensureStarlistRecipients(list: string[]): string[] {
  return list.filter((email) => {
    const trimmed = email.trim();
    if (!trimmed.includes("@starlist.jp")) {
      console.warn(`[ops-summary-email] Dropping non-starlist recipient: ${trimmed}`);
      return false;
    }
    return true;
  });
}

// Fetch metrics from ops-health function or return defaults
async function fetchMetrics(supabaseUrl: string, anonKey: string, period: string = "7d"): Promise<Metrics> {
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
      const avgUptime = aggregations.reduce((sum: number, agg: { uptime_percent: number }) => 
        sum + agg.uptime_percent, 0) / aggregations.length;
      const avgP95 = aggregations
        .map((agg: { mean_p95_ms: number | null }) => agg.mean_p95_ms)
        .filter((v: number | null): v is number => v != null);
      const meanP95 = avgP95.length > 0 
        ? Math.round(avgP95.reduce((sum, v) => sum + v, 0) / avgP95.length)
        : null;
      const totalAlerts = aggregations.reduce((sum: number, agg: { alert_count: number }) => 
        sum + agg.alert_count, 0);

      return {
        uptimePct: Math.round(avgUptime * 100) / 100,
        meanP95Ms: meanP95,
        alertTrend: [{ date: new Date().toISOString().slice(0, 10), count: totalAlerts }],
        degraded: false,
      };
    }
  } catch (error) {
    console.error("[ops-summary-email] Failed to fetch metrics from ops-health:", error);
  }

  // Return safe defaults if fetch fails
  return {
    uptimePct: 99.0,
    meanP95Ms: null,
    alertTrend: [],
    degraded: true,
  };
}

// Render email HTML with metrics
function renderEmail(metrics: Metrics, reportWeek: string): EmailContent {
  const { uptimePct, meanP95Ms, alertTrend } = metrics;
  const alertCount = alertTrend.reduce((sum, t) => sum + t.count, 0);
  const preheader = `Weekly health: ${uptimePct.toFixed(2)}% uptime, ${meanP95Ms ? `${meanP95Ms}ms` : "N/A"} p95, ${alertCount} alerts`;

  const subject = `STARLIST OPS Weekly – ${reportWeek} (Uptime ${uptimePct.toFixed(2)}%, p95 ${meanP95Ms ? `${meanP95Ms}ms` : "N/A"})`;

  const html = `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>STARLIST OPS Weekly Summary</title>
  <!-- Preheader (hidden) -->
  <div style="display: none; font-size: 1px; color: #fefefe; line-height: 1px; font-family: Arial, sans-serif; max-height: 0px; max-width: 0px; opacity: 0; overflow: hidden;">
    ${preheader}
  </div>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; }
    .header { background: #2563eb; color: white; padding: 20px; text-align: center; }
    .content { padding: 20px; max-width: 600px; margin: 0 auto; }
    .kpi-tile { margin: 20px 0; padding: 15px; background: #f3f4f6; border-radius: 8px; }
    .kpi-label { font-weight: bold; color: #6b7280; font-size: 14px; }
    .kpi-value { font-size: 24px; color: #111827; margin-top: 5px; }
    .footer { padding: 20px; text-align: center; color: #6b7280; font-size: 12px; }
  </style>
</head>
<body>
  <div class="header">
    <h1>STARLIST OPS Weekly Summary</h1>
    <p>Week: ${reportWeek}</p>
  </div>
  <div class="content">
    <div class="kpi-tile">
      <div class="kpi-label">Uptime</div>
      <div class="kpi-value">${uptimePct.toFixed(2)}%</div>
    </div>
    <div class="kpi-tile">
      <div class="kpi-label">Mean P95 Latency</div>
      <div class="kpi-value">${meanP95Ms ? `${meanP95Ms}ms` : "N/A"}</div>
    </div>
    <div class="kpi-tile">
      <div class="kpi-label">Alerts</div>
      <div class="kpi-value">${alertCount}</div>
    </div>
  </div>
  <div class="footer">
    <p>STARLIST OPS Team</p>
    <p><a href="mailto:ops@starlist.jp?subject=Unsubscribe">Unsubscribe</a> | <a href="https://starlist.jp/ops">View Dashboard</a></p>
  </div>
</body>
</html>`;

  return { subject, html, preheader };
}

// Insert audit log (idempotency check)
async function logInsert(
  supabaseUrl: string,
  anonKey: string,
  reportWeek: string,
  channel: string,
  provider: string
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
  errorMessage?: string
): Promise<void> {
  try {
    const url = `${supabaseUrl}/rest/v1/ops_summary_email_logs?report_week=eq.${reportWeek}&channel=eq.${channel}&provider=eq.${provider}`;
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
  html: string
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
  html: string
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
        from: { email: from.replace(/.*<(.+)>.*/, "$1") || from, name: "STARLIST OPS" },
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

    const dryRun = query.dryRun === true || query.dryRun === "true" || query.dryRun === "1";
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
            alert_count: metrics.alertTrend.reduce((sum, t) => sum + t.count, 0),
            degraded: metrics.degraded || false,
          },
          preview_html: emailContent.html,
        }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 200,
        }
      );
    }

    // Production mode: send email
    // Check idempotency
    const channel = "email";
    const logResult = await logInsert(supabaseUrl, supabaseAnonKey, reportWeek, channel, "resend");
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
        }
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
      throw new Error("No valid recipients found. Set resend_to_list or provide toOverride.");
    }

    // Try Resend first
    const resendApiKey = getEnv("resend_api_key", false);
    const resendFrom = getEnv("resend_from", false) || "STARLIST OPS <ops@starlist.jp>";
    let sendResult: { success: boolean; messageId: string | null; error?: string } | null = null;
    let provider = "resend";

    if (resendApiKey) {
      sendResult = await sendViaResend(
        resendApiKey,
        resendFrom,
        recipients,
        emailContent.subject,
        emailContent.html
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
          emailContent.html
        );
      }
    }

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
        sendResult?.error || "No email provider configured"
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
        }
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
      true
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
      }
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
        status: error instanceof Error && error.message.includes("missing env") ? 500 : 500,
      }
    );
  }
});

        sendResult = await sendViaSendGrid(
          sendgridApiKey,
          sendgridFrom,
          recipients,
          emailContent.subject,
          emailContent.html
        );
      }
    }

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
        sendResult?.error || "No email provider configured"
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
        }
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
      true
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
      }
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
        status: error instanceof Error && error.message.includes("missing env") ? 500 : 500,
      }
    );
  }
});
