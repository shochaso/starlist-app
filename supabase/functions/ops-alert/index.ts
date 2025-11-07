import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

serve(async () => {
  console.log("[ops-alert] dryRun OK");
  return new Response(JSON.stringify({ ok: true, dryRun: true }), { status: 200 });
});
