import { serve } from "std/http/server.ts";

serve(async () => {
  const data = await Deno.readTextFile("./data/latest.json").catch(() => "{}");
  return new Response(data, {
    headers: { "content-type": "application/json" },
  });
});
<<<<<<< HEAD



serve(async () => {
  const data = await Deno.readTextFile("./data/latest.json").catch(()=> "{}");
  return new Response(data, { headers: { "content-type":"application/json" }});
});


=======
>>>>>>> 8abb626 (feat(ops): add ultra pack enhancements — Makefile, audit bundle, risk register, RACI matrix)
