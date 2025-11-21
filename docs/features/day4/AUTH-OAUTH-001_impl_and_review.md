---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



Status:: 
Source-of-Truth:: (TBD)
Spec-State:: 
Last-Updated:: 


# AUTH-OAUTH-001 Implementation & Review Kit

`docs/features/auth/AUTH-OAUTH-001.md` を source_of_truth として運用するための **実装プロンプト**と**レビュー準備パッケージ**。マイン（実装担当）およびレビュワーはこのファイルを参照して即作業を開始できる。

---

## 1. Implementation Prompts（マイン向け）

### 1.1 Flutter（Auth UI / 再認証 / Link）

```
# Prompt: Flutter実装（Auth UI + 再認証 + Link/Unlink）
目標:
- Google/Appleのサインイン/リンク/解除を実装（Supabase Auth）。
- 401/403 時は非ブロッキング再認証モーダルを表示。
- サインイン後に edge/auth-sync を呼び、profile & entitlements を同期。
- RLSアクセスに失敗した場合は再認証→再試行。

作業:
1) lib/src/features/auth/
   - widgets/signin_buttons.dart: Google/Apple ボタン（ローディング/失敗表示）
   - pages/signin_page.dart: 成功→auth-sync→マイページ遷移
   - widgets/relogin_modal.dart: 401/403 捕捉モーダル（自動リフレッシュ→失敗なら手動）
   - account_link_section.dart: 現在のリンク状態バッジ／Link／Unlink

2) providers/auth_provider.dart
   - supabase.session() 監視
   - onAuthStateChange: edge/auth-sync 呼び出し（idempotent）
   - エラーコード分類: USER_CANCELLED / PROVIDER_DENIED / TOKEN_EXPIRED / NETWORK_ERROR

3) i18n: 成功/失敗文言（仕様書の文言例に準拠）

動作確認:
- Google/Apple でサインイン→再読込→セッション継続
- 401 → モーダル→再認証→直前操作の再試行
- 既存メールと競合 → Link 確認モーダル→ edge/auth/link 実行
```

### 1.2 Edge Functions（`auth-sync` / `auth-link`）

```
# Prompt: Edge Functions実装（auth-sync / auth-link）
目標:
- /edge/auth-sync: user_profiles upsert, entitlements 状態のスナップショット返却, audit_auth 記録
- /edge/auth/link: provider + oauth_token を受けて Supabase Auth の link 実行, 監査ログ

作業:
1) supabase/functions/auth-sync/index.ts
   - input: { user_id, provider, profile{display_name,avatar_url,locale}, entitlements_hint }
   - tx: user_profiles upsert(idempotent)
   - entitlements read-only照合（Stripe/Carrierミラー）
   - output: { ok, has_active_entitlements, stars: [...] }
   - audit_auth(event='sign_in'|'refresh')

2) supabase/functions/auth-link/index.ts
   - input: { user_id, provider, oauth_token }
   - supabase.auth.admin.linkIdentity(...) 相当処理
   - audit_auth(event='provider_link')

3) エラーマップ:
   - USER_CANCELLED / PROVIDER_DENIED / TOKEN_EXPIRED / ACCOUNT_LINK_CONFLICT / NETWORK_ERROR
   - 仕様書のエラーテーブルへ合わせて HTTP 4xx/5xx を整形
```

### 1.3 SQL（`user_profiles` / `audit_auth` / RLS）

```
-- user_profiles
create table if not exists public.user_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  avatar_url text,
  locale text default 'ja-JP',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
alter table public.user_profiles enable row level security;
create policy user_profiles_select on public.user_profiles
  for select using (auth.uid() = user_id);
create policy user_profiles_update on public.user_profiles
  for update using (auth.uid() = user_id);

-- audit_auth
create table if not exists public.audit_auth (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  event text,      -- sign_in / sign_out / provider_link / provider_unlink / refresh
  provider text,   -- google / apple
  ip inet,
  user_agent text,
  created_at timestamptz default now()
);

-- entitlements / v_entitlements_effective は既存定義を再利用
-- UI 判定: exists (
--   select 1 from v_entitlements_effective vee
--   where vee.user_id = auth.uid()
--     and vee.star_id = :target_star
--     and vee.active
-- )
```

---

## 2. Source_of_truth Review Kit

### 2.1 チェックリスト

- [ ] 仕様カバレッジ：目的／フロー図／データモデル／RLS／Edge／UI／セキュリティ運用／環境変数／エラー／テスト／PRチェックリストが揃っているか  
- [ ] 命名一貫性：`docs/features/auth/AUTH-OAUTH-001.md` と `docs/Mermaid.md` のノード名・パス一致  
- [ ] 依存境界：`SEC-RLS-SYNC-001` に委譲すべき記述が重複していないか  
- [ ] ログ方針：`audit_auth` と telemetry の関連キー（user_id / session_id）が明示されているか  
- [ ] プライバシー：PII マスキング方針・Apple Private Relay メール取り扱いが明記されているか  
- [ ] Exit Criteria：自動/手動テストの合格条件が具体的か  
- [ ] 参照リンク：COMMON_DOCS_INDEX / STARLIST_OVERVIEW / Mermaid の関連箇所が壊れていないか

### 2.2 docs-only PR テンプレ

```
title: docs(auth): add AUTH-OAUTH-001 assets and Day4 mapping
body:
- add docs/features/auth/AUTH-OAUTH-001.md (source_of_truth spec)
- add day4 implementation/review kit for AUTH-OAUTH-001
- update Mermaid diagrams with Day4 nodes
- documentation-only change; no runtime impact
checks:
- [ ] Paths/names consistent
- [ ] Mermaid renders
- [ ] Markdown lint passes
labels: [docs, auth, day4]
```

---

## 3. 推奨フロー

1. **レビュー依頼**：上記チェックリストでセルフチェック→source_of_truth レビューへ。  
2. **承認後**：本ファイルの Implementation Prompts をマインへ共有し、Flutter / Edge / SQL の 3 並行タスクを開始。  
3. **完了時**：AUTH-OAUTH-001 の Exit Criteria を満たしたら Day4 Gate を更新し、Mermaid ノードのステータスを最新化。

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
