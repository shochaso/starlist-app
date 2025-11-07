Status:: 
Source-of-Truth:: (TBD)
Spec-State:: 
Last-Updated:: 


# AUTH-OAUTH-001 — OAuth統合仕様（Supabase Auth + Google / Apple）

Status: aligned-with-Flutter  
Last-Updated: 2025-11-07  
Source-of-Truth: Flutter code (`lib/src/features/auth/**`)

**ドメイン:** auth / security / ui  
**対象リリース:** MVP（Day4）  
**責任者:** ティム（COO/PM）／実装：マイン（コード修正担当）

---

## 共通前提（SoT=Flutter/RLS原則/OPS命名）

- **Source of Truth**: Flutter実装を最優先とし、仕様は実装追従
- **RLS原則**: Supabase AuthセッションとPostgres RLSを完全同期、`v_entitlements_effective` で購読判定
- **OPS命名**: 監査イベントを統一（`auth.*`, `auth.sync.dryrun`, `rls.access.denied`, `ops.subscription.price_*`）
- **依存**: PAY-STAR-SUBS-PER-STAR-PRICING（スター単位可変価格）

## 1. 目的・範囲

- **目的:** Google/AppleのOAuthをSupabase Authで統合し、**認証セッション**と**RLS（行レベルセキュリティ）**、**購読権限（entitlements）**を一貫したトラストチェーンで接続する。
- **適用範囲:** Web/PWA（Flutter Web）＋将来的なモバイル（iOS/Android）の両対応。
- **非目標:** 独自のIDP実装、SNS以外の追加プロバイダ（LINE/Twitter等）は本仕様外。

**現状 (Flutter Reality)**
1. Supabase email/パスワード認証のみ実装。`AuthProvider` は Google / Apple ロジックを持たず、`auth-sync` も未呼び出し。
2. 認証後の再認証モーダルや 401 リトライは未実装。
3. プロフィール同期は Supabase への直接参照で賄っており、Edge Function 経由の RLS 同期は未導入。  

**達成基準（Exit Criteria / TODO）**
1. Google/Apple サインイン／リンク／アンリンク UI を Supabase OAuth で完結。  
2. トークン失効・再認証時も RLS が正しく適用されること。  
3. `auth-sync` Edge で `user_profiles` と `entitlements` を idempotent に同期。  
4. 主要フローが `audit_auth` に記録され、OPS 監視イベント（`auth.*`）と連携。

---

## 2. アーキテクチャ＆フロー（Mermaid・計画 vs 現状）

```mermaid
flowchart TB
  U[ユーザー] -->|Sign in with Google/Apple| A[Supabase Auth]
  A -->|ID Token/JWT| FE[Flutter App]
  FE -->|/session| RLS[(Postgres RLS)]
  RLS --> DB[(Tables: user_profiles, entitlements, v_entitlements_effective)]
  FE -->|/edge/auth/sync| EDGE[Edge Function: auth-sync]
  EDGE -->|SELECT/UPSERT| DB
  FE -->|/edge/metrics| METRICS[Edge: telemetry]
  A --> LOG[audit_auth]
```

**実装状況**

- 現在は Supabase email/パスワードログインを `AuthService` が提供し、`AuthProvider` はメールログインのローディング/エラー状態のみ管理。  
- Google/Apple ボタン・OAuth シーケンスは未実装。  
- `auth-sync` Edge Function は存在せず、Flutter から直接 `Supabase.instance.client` を参照してプロフィールやサブスクリプションを取得している。  
- 将来的に上図のフローへ移行し、Edge 側で Dry-run → 本番モードを切替える。

---

## 3. データモデル & RLS 設計

### 3.1 関連テーブル

```sql
create table if not exists public.user_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  avatar_url text,
  locale text default 'ja-JP',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
```

> `entitlements` と `v_entitlements_effective` は Day2 定義を流用。  
> 例: `entitlements(user_id, star_id, plan_tier, starts_at, ends_at, canceled_at, source)`

### 3.2 RLS ポリシー（抜粋）

```sql
alter table public.user_profiles enable row level security;

create policy user_profiles_select on public.user_profiles
for select using (auth.uid() = user_id);

create policy user_profiles_update on public.user_profiles
for update using (auth.uid() = user_id);
```

> 有料可視性は `v_entitlements_effective` による `exists` 判定を利用。

### 3.3 監査ログ（auth）

```sql
create table if not exists public.audit_auth (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  event text,
  provider text,
  ip inet,
  user_agent text,
  created_at timestamptz default now()
);
```

---

## 4. Edge Functions / API 設計

### 4.1 `edge/auth-sync`

- **目的:** サインイン／トークン更新直後に**プロフィール/購読権限**を整合。  
- **入力:** `user_id`, `provider`, `profile`, `entitlements_hint`。  
- **処理:** `user_profiles` upsert → `entitlements` 期限チェック → `audit_auth` 記録。  
- **出力:** `{ ok, has_active_entitlements, stars[] }`

### 4.2 `edge/auth/link`

- 既存ユーザーに Google/Apple をリンク。  
- 成功時 `audit_auth(event=provider_link)` を記録。

### 4.3 `edge/metrics`

- 認証関連のページ遷移・再認証試行を記録し `searchTelemetryProvider` と突合。

---

## 5. UI 連携要件

### 5.1 ログイン画面（Flutter）

- **現状:** email + password のフォームのみ。Supabase OAuth ボタンは未実装。  
- **仕様:** Google / Apple ボタンを `AUTH_OAUTH_V1` フラグ下で追加し、`auth.sync.dryrun` イベントを発火。  
- エラー分類（`USER_CANCELLED` など）は UI 文言だけ先行で定義し、実装未完了である旨を明記。

### 5.2 マイページ

- 連携状況バッジと解除ボタン。  
- `v_entitlements_effective.active` を基に購読状態を表示。

### 5.3 文言例（現行 + 追加）

- 現行: 「サインインしました」「ログインに失敗しました: {message}」  
- 追加予定: 「Googleでサインイン中…」「キャンセルしました」「再認証が必要です」 等

---

## 6. セキュリティ・運用（Reality vs Roadmap）

- **現在**: Supabase email 認証の標準挙動に依存。401/403 の再認証制御・PII マスキングは未管理。  
- **計画**: Apple Private Relay メールをそのまま保存し、`audit_auth` に `auth.login.success/failure`, `auth.reauth.triggered` を記録。  
- `auth-sync` Edge でセッション失効時に購読整合性を回復させる。

---

## 7. 設定・インフラ

### 7.1 リダイレクトURI

- 開発: `http://localhost:5173/auth/callback`  
- 本番: `https://app.starlist.jp/auth/callback`

### 7.2 環境変数

```
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
SUPABASE_SERVICE_ROLE_KEY=...
OAUTH_GOOGLE_CLIENT_ID=...
OAUTH_GOOGLE_CLIENT_SECRET=...
OAUTH_APPLE_CLIENT_ID=...
OAUTH_APPLE_TEAM_ID=...
OAUTH_APPLE_KEY_ID=...
OAUTH_APPLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----"
```

---

## 8. 例外・エラー設計

| コード | 原因 | UI 表示 | リトライ | ログ |
| --- | --- | --- | --- | --- |
| `USER_CANCELLED` | 同意画面キャンセル | 「キャンセルしました」 | 不要 | info |
| `PROVIDER_DENIED` | 権限拒否/不足 | 「権限が不足しています」 | スコープ案内 | warn |
| `TOKEN_EXPIRED` | トークン期限切れ | 「再認証が必要です」 | 自動→手動 | warn |
| `ACCOUNT_LINK_CONFLICT` | 既存アカウント競合 | 「既存アカウントにリンクしますか？」 | yes | warn |
| `NETWORK_ERROR` | 通信障害 | 「接続できません」 | バックオフ | error |

---

## 9. テスト計画（QA-E2E-001連携）

- Google/Apple で Sign in → 再読込 → セッション維持。  
- 購読RLSテスト（可視/不可視差）。  
- プロバイダリンク/解除後の再ログイン。  
- トークン失効 + サイレントリフレッシュ回帰。

---

## 10. 完了条件 & PR チェックリスト（現状ステータス）

- [ ] Google/Apple サインイン/リンク/解除 → **未実装**  
- [ ] `auth-sync` でプロフィール & entitlements 同期 → **未実装**  
- [ ] `audit_auth` に主要イベント追加 → **テーブル定義のみ**  
- [ ] RLS整合テスト（有料/無料差） → 現在は `subscriptions` 参照のみ  
- [ ] README/環境変数/リダイレクトURI更新 → 要追加  
- [x] Mermaid ノード → 追加済み（Day4 クラスタ）

---

## 差分サマリ (Before/After)

- **Before**: Google/Apple OAuth が実装済みである前提で仕様記述。`auth-sync` や再認証モーダル、OPS ログも「完了」と扱っていた。  
- **After**: Flutter Reality に合わせ、メール/パスワードのみ実装であること、OAuth 各要素が TODO であることを明記。Edge/監査/再認証は計画フェーズとして整理。  
- **追加**: 監査イベント命名（`auth.*`）と `AUTH_OAUTH_V1` フラグ導入、OPS/QA 等他仕様への参照を更新。

---

## 付録 A. 実装タスクリスト（指名：マイン）

- [ ] Flutter: OAuth UI（Google/Appleボタン・エラーUI）  
- [ ] Edge: `auth-sync` 実装 & idempotent upsert  
- [ ] DB: `audit_auth` 追加 & ポリシー  
- [ ] Docs: 本仕様を *source_of_truth* に昇格（Day4完了時）
