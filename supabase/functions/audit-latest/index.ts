import { serve } from "std/http/server.ts";

serve(async () => {
  const data = await Deno.readTextFile("./data/latest.json").catch(() => "{}");
  return new Response(data, {
    headers: { "content-type": "application/json" },
  });
});
