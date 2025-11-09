// CSP Report endpoint for Content-Security-Policy-Report-Only
// Deploy: supabase functions deploy csp-report

Deno.serve(async (req: Request) => {
  try {
    if (req.method !== 'POST') {
      return new Response('Method Not Allowed', { status: 405 });
    }

    const body = await req.text();
    const timestamp = new Date().toISOString();
    
    console.log('[CSP REPORT]', timestamp, body);

    // Optional: Save to Supabase (uncomment if needed)
    // const { createClient } = await import('https://esm.sh/@supabase/supabase-js@2');
    // const supabase = createClient(
    //   Deno.env.get('SUPABASE_URL') ?? '',
    //   Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    // );
    // await supabase.from('csp_reports').insert({
    //   report: body,
    //   created_at: timestamp,
    //   user_agent: req.headers.get('user-agent') ?? null,
    //   ip: req.headers.get('x-forwarded-for') ?? null,
    // });

    return new Response(null, { status: 204 });
  } catch (e) {
    console.error('[CSP REPORT ERROR]', e);
    return new Response(null, { status: 500 });
  }
});

