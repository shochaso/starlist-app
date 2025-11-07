import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const misconfigured = () => new Response("Server configuration error", { status: 500 });

serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  const body = await req.json().catch(() => null);
  if (!body || !body.app || !body.env || !body.event || typeof body.ok !== "boolean") {
    return new Response("Bad Request", { status: 400 });
  }

  const supabaseDbUrl = Deno.env.get("SUPABASE_DB_URL");
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
  if (!supabaseDbUrl || !supabaseAnonKey) {
    console.error("[telemetry] Missing SUPABASE_DB_URL or SUPABASE_ANON_KEY");
    return misconfigured();
  }

  const { app, env, event, ok, latency_ms, err_code, extra } = body;
  const sql =
    `insert into public.ops_metrics(app, env, event, ok, latency_ms, err_code, extra)
     values($1,$2,$3,$4,$5,$6,$7)`;
  const args = [app, env, event, ok, latency_ms ?? null, err_code ?? null, extra ?? null];

  const resp = await fetch(supabaseDbUrl, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${supabaseAnonKey}`,
    },
    body: JSON.stringify({ query: sql, args }),
  }).catch((error) => {
    console.error("[telemetry] fetch error", error);
    return null;
  });

  if (!resp) return new Response("Insert failed", { status: 500 });

  if (!resp.ok) {
    const text = await resp.text().catch(() => "");
    console.error("[telemetry] insert failed", resp.status, text);
    return new Response("Insert failed", { status: 500 });
  }

  return new Response(null, { status: 201 });
});
