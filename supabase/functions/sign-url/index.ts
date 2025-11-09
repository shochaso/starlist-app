import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { buildCorsHeaders } from "./shared.ts";

type Body =
  | { mode: "path"; path: string; expiresIn?: number }
  | { mode: "asset"; assetId: number; expiresIn?: number };

const json = (data: unknown, status = 200, req?: Request) =>
  new Response(JSON.stringify(data), {
    status,
    headers: {
      "Content-Type": "application/json",
      ...buildCorsHeaders(req),
    },
  });

serve(async (req) => {
  if (req.method === "OPTIONS") return json({ ok: true }, 200, req);

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const authHeader = req.headers.get("Authorization") ?? "";

    // クライアントJWTをそのまま転送
    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    // 認証
    const { data: userRes, error: userErr } = await supabase.auth.getUser();
    if (userErr || !userRes.user) return json({ error: "Unauthorized" }, 401, req);
    const user = userRes.user;

    const body = (await req.json()) as Body;
    const expiresIn = Math.min(Math.max((body as any).expiresIn ?? 600, 60), 3600); // 60s〜3600s

    // 署名URLを作るヘルパ
    const sign = async (path: string) => {
      const { data, error } = await supabase.storage
        .from("private-originals")
        .createSignedUrl(path, expiresIn);
    if (error || !data?.signedUrl) return json({ error: "Sign error" }, 500, req);
    return json({ url: data.signedUrl, ttl: expiresIn }, 200, req);
    };

    if (body.mode === "path") {
      const path = body.path?.trim();
      if (!path || path.startsWith("/") || path.includes(".."))
        return json({ error: "Bad path" }, 400, req);

      // 所有者チェック（storage.objects の metadata.owner_id）
      const { data: objs, error } = await supabase
        .from("storage.objects")
        .select("name, bucket_id, metadata")
        .eq("bucket_id", "private-originals")
        .eq("name", path)
        .limit(1);
      if (error) return json({ error: "Lookup error" }, 500, req);
      if (!objs?.length) return json({ error: "Not Found" }, 404, req);

      const obj = objs[0] as any;
      const ownerId = obj.metadata?.owner_id;
      if (ownerId !== user.id) return json({ error: "Forbidden" }, 403, req);

      return await sign(path);
    }

    if (body.mode === "asset") {
      const assetId = Number((body as any).assetId);
      if (!Number.isFinite(assetId)) return json({ error: "Bad assetId" }, 400, req);

      // media_assets -> (post_id, owner_id, bucket, path)
      const { data: assets, error: aErr } = await supabase
        .from("app_public.media_assets")
        .select("id, post_id, owner_id, bucket, path")
        .eq("id", assetId)
        .limit(1);
      if (aErr) return json({ error: "Lookup error" }, 500, req);
      if (!assets?.length) return json({ error: "Not Found" }, 404, req);

      const a = assets[0] as any;
      if (a.bucket !== "private-originals") return json({ error: "Only private-originals allowed" }, 403, req);

      // アクセス可否：
      // 1) 所有者ならOK
      // 2) post_id があり、fn_can_view_post(post_id, user.id) が true ならOK
      let allowed = a.owner_id === user.id;
      if (!allowed && a.post_id != null) {
        const { data: canView, error: vErr } = await supabase
          .rpc("fn_can_view_post", { post_id: a.post_id, uid: user.id });
        if (vErr) return json({ error: "Visibility check error" }, 500, req);
        allowed = !!canView;
      }
      if (!allowed) return json({ error: "Forbidden" }, 403, req);

      const path = String(a.path);
      if (!path || path.startsWith("/") || path.includes(".."))
        return json({ error: "Bad path" }, 400, req);

      return await sign(path);
    }

    return json({ error: "Bad mode" }, 400, req);
  } catch (e) {
    return json({ error: String(e) }, 500, req);
  }
});
