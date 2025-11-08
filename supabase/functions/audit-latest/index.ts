import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

serve(async () => {
  const data = await Deno.readTextFile("./data/latest.json").catch(()=> "{}");
  return new Response(data, { headers: { "content-type":"application/json" }});
});

