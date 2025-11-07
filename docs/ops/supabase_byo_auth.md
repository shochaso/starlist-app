Status:: 
Source-of-Truth:: (TBD)
Spec-State:: 
Last-Updated:: 


# Supabase BYO Auth Exchange

Notes for running the `exchange` edge function with external identity providers (Auth0 + LINE).

## Client usage

- Treat this flow as **Bring Your Own Auth**. Do **not** call `supabaseClient.auth.setSession`.
- Request a Supabase-signed JWT from the edge function and attach it as an `Authorization` header when creating the client instance.

```ts
import { createClient } from '@supabase/supabase-js';

const { supabase_jwt } = await fetch('/functions/exchange', {
  method: 'POST',
  headers: { 'content-type': 'application/json' },
  body: JSON.stringify({ id_token }),
}).then((r) => r.json());

export const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
  { global: { headers: { Authorization: `Bearer ${supabase_jwt}` } } },
);
```

The same pattern applies to Flutter/Dart: instantiate `SupabaseClient` with custom headers and reuse the short-lived JWT. When the API returns `401`, trigger a refresh by calling `/functions/exchange` again.

## Edge function deployment

- Deploy with JWT verification disabled because the function performs its own validation of the external token:  
  `supabase functions deploy exchange --no-verify-jwt`
- Consider adding an allow-list (origin/IP or secret header) before production rollout.

## Environment variables

- `AUTH0_DOMAIN` must be the issuer URL with a trailing slash, e.g. `https://your-tenant.us.auth0.com/`.
- `AUTH0_AUDIENCE` (optional) is enforced if supplied.
- `SUPABASE_JWT_SECRET` comes from Supabase **Project Settings → API → JWT Secret**.
- `SUPABASE_JWT_AUD` defaults to `authenticated` if omitted.
- `SUPABASE_JWT_EXPIRES_IN` (seconds) controls how long the exchanged token is valid. Keep this short (15–60 minutes).
- `CORS_ALLOW_*` variables remain available for per-environment tuning.

The exchange function now resolves the issuer from `AUTH0_DOMAIN`, fetches JWKS from `https://<tenant>.auth0.com/.well-known/jwks.json`, and returns the Supabase JWT as `supabase_jwt`.

## RLS policy example

```sql
alter table public.user_data enable row level security;

create policy "owner can read own rows"
on public.user_data for select
using (user_id = (current_setting('request.jwt.claims', true)::jsonb ->> 'sub'));
```

Match your table schema (`user_id` in the example) and rely on the `sub` claim populated during the exchange.

## Token refresh strategy

- Keep the Supabase JWT lifetime short.
- On expiry, re-run the exchange using the latest Auth0 session (`id_token`).
- Automate the refresh (e.g. intercept `401` responses and retry once after reissuing the token).

---

## Doc-share バケット運用手順

大容量ドキュメント（ChatGPT 等へ共有する資料）を Supabase Storage で管理するための手順。

1. **バケット作成**
   ```bash
   supabase storage create-bucket doc-share --public=false
   ```
   - Dashboard から作成する場合も `doc-share` 名で Public を無効にする。
2. **権限設定**
   - Supabase プロジェクト設定 → Policies → `storage.objects` で `doc-share` を対象に、社内ロール（例: `authenticated`）へ読み書き権限を付与。
   - 外部公開は行わない。必要に応じてサービスロール/API Key を使用。
3. **ファイルアップロード**
   ```bash
   supabase storage upload doc-share/path/to/file.pdf ./file.pdf
   ```
   - Dashboard からアップロードする場合も同じ階層構造を推奨（`YYYY/MM/` 等）。
4. **署名付き URL 発行**
   ```bash
   supabase storage sign-url doc-share/path/to/file.pdf --expires-in 3600
   ```
   - `--expires-in` は秒指定。ChatGPT 共有用途では 1〜6 時間程度を目安に短めとする。
5. **共有と削除**
   - 発行した URL を `docs/CHATGPT_SHARE_GUIDE.md` の手順に従って共有。
   - 共有終了後は不要ファイルを削除しストレージを整理。
6. **監査**
   - 月次で `supabase storage list doc-share --prefix` を利用して不要ファイルを確認。

これらの手順を更新した場合は `docs/COMPANY_SETUP_GUIDE.md` および `docs/CHATGPT_SHARE_GUIDE.md` も合わせて更新すること。
