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


# DAY4_SOT_DIFFS — Flutter Reality vs Spec Drift

Status: in-progress  
Last-Updated: 2025-11-07  
Source-of-Truth: Flutter code (`lib/…`)

| ID | 領域 | コードで確認できる挙動 | 仕様との差分 / 修正方針 | 参照ファイル |
| -- | --- | --- | --- | --- |
| A1 | OAuthフロー | `lib/src/features/auth/` には Supabase email/password ログインのみ。`AuthProvider` は Google/Apple 未実装で、`auth-sync` 呼び出しもない。 | AUTH-OAUTH-001 を「Google/Apple 完備」→「Supabase email+password + 将来対応」で書き換え。OAuthのDry-run/Edgeフローは TODO として整理し、実装に合わせて `Status: reviewed` を付与。 | `lib/src/features/auth/services/auth_service.dart`, `lib/src/features/auth/providers/auth_provider.dart` |
| A2 | 再認証/401 handling | Flutter 側で 401/403 を捕捉し再認証モーダルを出す処理が存在しない。 | AUTH-OAUTH-001 / UI-HOME-001 / QA-E2E-001 の「非ブロッキング再認証」を「未実装（Spec TODO）」に修正。モーダルワイヤーの要件は「将来項目」として差分サマリに明記。 | 上記 + `lib/src/features/auth/presentation` |
| B1 | 購読/課金モデル | `subscription_plans` は単一テーブルで、スター単位ではなく共通プラン (`SubscriptionPlanModel`) を参照。 | 仕様の「スター別課金」を今回追加する `PAY-STAR-SUBS-PER-STAR-PRICING` で定義し、既存 Day4 仕様からグローバル記述を削除。コード側未実装である旨を差分サマリに記載。 | `lib/src/features/subscription/services/subscription_service.dart`, `docs/features/payment_current_state.md` |
| B2 | 可変価格/成人・未成年 | Flutter UI は固定価格（`SubscriptionPlan.price`）表示のみ。年齢別メッセージや可変入力は無し。 | 新規仕様で「推奨価格（成人/未成年）」のUI/バリデーション/監査要件を追加し、UI-HOME-001 と QA-E2E-001 へリンク。実装差分は `TODO` として残す。 | `lib/src/features/subscription/presentation/screens/payment_method_screen.dart` |
| C1 | `auth-sync`/RLS | コードに `auth-sync` Edge 呼び出し無し。Flutter から Supabase へ直接アクセスしており、RLSは DB 側に依存。 | SEC-RLS-SYNC-001 で「実装状況=未着手」「現状は Supabase 直接参照」へ書き換え。Edge/Dry-run フローを TODO として整理。 | `lib/src/features/subscription/services/subscription_service.dart`, `docs/features/day4/SEC-RLS-SYNC-001.md` |
| D1 | OPS 監視イベント | 実装からは `auth.*` ログ送信が確認できない（Flutter からログ送信なし、Edge 未実装）。 | OPS-MONITORING-001 に「命名規約の確定」「実装は未」「Dry-runログ期待値」を明記。 | `docs/features/day4/OPS-MONITORING-001.md` |
| E1 | QA E2E | コードに Feature Flag `AUTH_OAUTH_V1` / Dry-run モックは存在しない (`.env.example` にも無い)。 | QA-E2E-001 を「FF未配備」表記へ修正し、`.env.example` へ新フラグを追加する次アクションを仕様に書く。 | `.env.example`, `docs/features/day4/QA-E2E-001.md` |

### AUTH-OAUTH-001
- Before: Supabase OAuth (Google/Apple) と `auth-sync` が完了している前提でフローを記述。
- After : Flutter Reality（メール/パスワードのみ・OAuth未実装・Edge未導入）を反映し、TODO としてロードマップ化。
- Reason: SoT = Flutter 実装。現在は email login + Supabase 直アクセスのみ。
- CodeRefs: `lib/src/features/auth/services/auth_service.dart`, `lib/src/features/auth/providers/auth_provider.dart`
- Impact: 仕様の期待値/文言を現状に合わせ、再認証モーダルや Edge 呼び出しは「将来実装」として QA/OPS/Review Kit へ展開。

### SEC-RLS-SYNC-001
- Before: entitlements ベースの RLS 同期が既に導入済みという前提。
- After : Supabase `subscriptions` への直接アクセス、Edge未導入の現実を反映し、Dry-run環境変数と移行手順を明記。
- Reason: SoT = Flutter (SubscriptionService が Supabase を直接参照)。
- CodeRefs: `lib/src/features/subscription/services/subscription_service.dart`
- Impact: RLS/Edge の TODO を明文化し、OPS の `rls.access.denied` ログおよび新規課金仕様との連携を明示。

### UI-HOME-001
- Before: OAuth後の再認証モーダル／スター単位可変価格 UI が存在すると記述。
- After : 現実（メールログイン＋固定価格）を起点にし、PAY-STAR-SUBS-PER-STAR-PRICING の表示仕様と年齢別ラベルを追加。
- Reason: SoT = Flutter (`PaymentMethodScreen` と `subscriptionProvider` のみ)。
- CodeRefs: `lib/src/features/subscription/presentation/screens/payment_method_screen.dart`, `lib/src/features/subscription/providers/subscription_provider.dart`
- Impact: UI文言・状態遷移・テスト観点を再定義。価格入力や年齢別注意文の導入により QA/OPS が参照可能。

### OPS-MONITORING-001
- Before: `auth.*` ログや監視ダッシュボードが稼働済みと仮定。
- After : 現状（ログ送信なし）を記し、イベント命名/Slack通知/OPSダッシュボードを正準 `docs/ops/` に集約。
- Reason: SoT = Flutter（ログ出力なし） + 未実装 Edge。
- CodeRefs: `docs/ops/OPS-MONITORING-001.md`
- Impact: 監査イベント命名 (`auth.*`, `auth.sync.dryrun`, `rls.access.denied`, `ops.subscription.price_*`) を固定し、QA/Day4シェルとの役割分担を明確化。

### QA-E2E-001
- Before: OAuth UI・再認証モーダル・可変価格テストが存在する前提でシナリオを記述。
- After : 現状（メールログイン / 固定価格のみ）を反映し、Feature Flag + Dry-run モックで段階的にテストする計画を追記。
- Reason: SoT = Flutter（`AUTH_OAUTH_V1` などのFF未導入）。
- CodeRefs: `docs/features/day4/QA-E2E-001.md`, `.env.example`
- Impact: QA項目を FF ON/OFF に分割し、可変価格・年齢ラベルのUI検証を追加。OPSログ検証も連携。

> OPEN QUESTIONS  
> - Supabase OAuth (Google/Apple) 実装のターゲット時期  
> - Edge Functions (`auth-sync`, `auth-link`) の Dry-run API 仕様  
> - 個人スター課金のテーブル設計（`subscription_plans` を拡張か、新テーブルか）

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
