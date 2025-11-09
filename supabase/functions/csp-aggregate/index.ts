// CSP Report集計関数（小規模テーブルローテ前提）
// Usage: GET /csp-aggregate?days=7&threshold=10

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

interface CSPReport {
  timestamp: string;
  blocked_uri?: string;
  effective_directive?: string;
  document_uri?: string;
  violated_directive?: string;
}

interface CSPAggregation {
  directive: string;
  blocked_uri: string;
  count: number;
  first_seen: string;
  last_seen: string;
}

Deno.serve(async (req: Request) => {
  try {
    const url = new URL(req.url);
    const days = parseInt(url.searchParams.get("days") || "7", 10);
    const threshold = parseInt(url.searchParams.get("threshold") || "10", 10);

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Fetch CSP reports from logs (last N days)
    // Note: This assumes CSP reports are stored in a table or view
    // For now, we'll aggregate from Edge Function logs
    const since = new Date(Date.now() - days * 24 * 60 * 60 * 1000).toISOString();

    // Query CSP reports (assuming they're stored in a table)
    const { data: reports, error } = await supabase
      .from("csp_reports")
      .select("*")
      .gte("created_at", since)
      .order("created_at", { ascending: false });

    if (error) {
      console.error("[CSP AGGREGATE] Query error:", error);
      return new Response(JSON.stringify({ error: "Query failed", details: error.message }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Aggregate by directive and blocked_uri
    const aggregationMap = new Map<string, CSPAggregation>();

    for (const report of (reports || []) as CSPReport[]) {
      const directive = report.effective_directive || report.violated_directive || "unknown";
      const blockedUri = report.blocked_uri || "unknown";
      const key = `${directive}:${blockedUri}`;

      if (!aggregationMap.has(key)) {
        aggregationMap.set(key, {
          directive,
          blocked_uri: blockedUri,
          count: 0,
          first_seen: report.timestamp || new Date().toISOString(),
          last_seen: report.timestamp || new Date().toISOString(),
        });
      }

      const agg = aggregationMap.get(key)!;
      agg.count++;
      if (report.timestamp && report.timestamp < agg.first_seen) {
        agg.first_seen = report.timestamp;
      }
      if (report.timestamp && report.timestamp > agg.last_seen) {
        agg.last_seen = report.timestamp;
      }
    }

    // Filter by threshold and sort by count
    const aggregations = Array.from(aggregationMap.values())
      .filter(agg => agg.count >= threshold)
      .sort((a, b) => b.count - a.count);

    // Format as table (Markdown)
    const tableRows = aggregations.map(agg => 
      `| ${agg.directive} | ${agg.blocked_uri} | ${agg.count} | ${agg.first_seen} | ${agg.last_seen} |`
    );

    const markdown = `# CSP Report Aggregation (Last ${days} days)

| Directive | Blocked URI | Count | First Seen | Last Seen |
|-----------|-------------|-------|-----------|-----------|
${tableRows.join("\n")}

**Threshold**: ${threshold} violations
**Generated**: ${new Date().toISOString()}
`;

    return new Response(markdown, {
      headers: { "Content-Type": "text/markdown" },
    });
  } catch (e) {
    console.error("[CSP AGGREGATE] Error:", e);
    return new Response(JSON.stringify({ error: "Internal server error", details: String(e) }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});

