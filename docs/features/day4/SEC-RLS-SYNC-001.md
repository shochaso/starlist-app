# SEC-RLS-SYNC-001 — RLS同期強化仕様

Status: aligned-with-Flutter  
Last-Updated: 2025-11-07  
Source-of-Truth: Flutter code (`lib/src/features/subscription/**`)

> 責任者: ティム（COO/PM）／実装: TBD

## 共通前提（SoT=Flutter/RLS原則/OPS命名）

- **Source of Truth**: Flutter実装を最優先とし、仕様は実装追従
- **RLS原則**: Supabase AuthセッションとPostgres RLSを完全同期、`v_entitlements_effective` で購読判定
- **OPS命名**: 監査イベントを統一（`auth.*`, `auth.sync.dryrun`, `rls.access.denied`, `ops.subscription.price_*`）
- **依存**: PAY-STAR-SUBS-PER-STAR-PRICING（スター単位可変価格）

## 1. 目的

- **現状**: Flutter は Supabase の `subscriptions` テーブルを直接参照し、RLS は Supabase 既定の `auth.uid()` 制御のみに依存している。`entitlements` ビューや `auth-sync` は未導入。
- **目的**: Supabase Auth セッションと Postgres RLS 判定を完全同期させ、OAuth 由来の権限差分をゼロにする。`v_entitlements_effective` のリアルタイム性を高め、再認証・解約時のギャップを解消。

## 2. スコープ

- 対象: `entitlements`, `v_entitlements_effective`, `subscriptions`, `audit_auth`, `auth-sync` Edge Function。  
- 非対象: 決済フロー自体の改善（別仕様：PAY-STAR-SUBS-PER-STAR-PRICING / UI-HOME-001）。

## 3. 仕様要点（Reality → Target）

- 現状は `SubscriptionService.getCurrentSubscription()` が `subscriptions` を直接参照し、RLS は Supabase の行レベル制御のみ。  
- Target: Edge の `auth-sync` で Supabase `entitlements` を idempotent upsert → `v_entitlements_effective` を `exists` 判定に統一。  
- `audit_auth` と Supabase セッション ID を紐づけて差分検証を可能にする。  
- スター単位課金（PAY-STAR-SUBS-PER-STAR-PRICING）に合わせ、`entitlements` に `star_id`／推奨価格帯を保存。

## 4. 依存関係

- AUTH-OAUTH-001（OAuth 統合仕様）
- QA-E2E-001（再認証と RLS テスト）
- 既存の Supabase マイグレーション一式

## 5. テスト観点

- 現状: `subscriptions` を直接参照するため、RLSテストは Supabase 側の `select` 権限確認のみ。  
- Target: 解約/再開後のアクセス権限が 30 秒以内に `v_entitlements_effective` に反映されること。  
- 未購読ユーザーがスター別有料データへアクセスできないこと。  
- 監査ログ (`auth.sync.dryrun`, `rls.access.denied`) で判定結果を追跡できること。

## 6. 完了条件

- 仕様レビュー合格（source_of_truth 昇格）。  
- Mermaid Day4 クラスタで `SEC-RLS-SYNC-001` と PAY-STAR-SUBS-PER-STAR-PRICING のリンクが有効。  
- 実装 PR（SQL/Edge）を Draft 状態で作成し、QA ケースを `QA-E2E-001` へリンク。  
- `.env.example` に `AUTH_SYNC_DRY_RUN` を追加し、Dry-run → 本番モードの切替手順を docs/development に記載。

---

## 差分サマリ (Before/After)

- **Before**: entitlements ベースの RLS 同期が実装済みという前提で記述。  
- **After**: Flutter Reality（`subscriptions` 直接参照、Edge 未導入）を反映し、必要な移行ステップと Dry-run 環境変数を明記。  
- **追加**: スター単位課金仕様への依存と、OPS監査イベント（`rls.access.denied`）の利用を追記。
