# UI-HOME-001 — Home / MyPage 統合UI仕様

Status: aligned-with-Flutter  
Last-Updated: 2025-11-07  
Source-of-Truth: Flutter code (`lib/src/features/app/**`, `lib/src/features/subscription/**`)

> 責任者: ティム（COO/PM）／実装: マイン（Flutter）

## 1. 目的

- 現行 Flutter (Home/Subscription UI) を SoT とし、仕様側を現実に同期。  
- OAuth ログイン後のホーム体験とマイページ設定を Day4 仕様に合わせて統合し、将来的にスター単位課金・年齢別推奨価格を表示できる UI を設計する。

## 2. スコープ

- Flutter Web / Mobile の Home, MyPage, Subscription 画面。  
- `SubscriptionPlansScreen`, `PaymentMethodScreen`, `ProfileScreen` 等での状態表示。  
- 認証モーダル（※UI部品未実装だが仕様で定義）、Link/Unlink UI、購読バッジ、年齢別注意文言。

## 3. 仕様要点（Reality → Target）

- 現状: `subscriptionProvider` が Supabase からプランと契約状況を取得し、`PaymentMethodScreen` で決済。Auth 状態の判定は `AuthProvider` のメールログインのみ。  
- 状態分岐: 未ログイン（CTAのみ）／ログイン済み（プラン一覧＋購読状態カード）／再認証要求（未実装、仕様のみ）。  
- `edge/auth-sync` 完了まではスケルトン表示予定だが、現状は即表示。  
- 連携プロバイダのバッジ表示と解除ボタンは未実装。`AUTH_OAUTH_V1` フラグ ON 時に追加予定。  
- **価格表示拡張**: スター詳細画面に「スター単位のサブスク価格」「成人/未成年向け推奨レンジ」を表示し、価格入力コンポーネントを呼び出す（PAY-STAR-SUBS-PER-STAR-PRICING 参照）。

## 4. 依存関係

- AUTH-OAUTH-001（OAuth UI 要件）
- SEC-RLS-SYNC-001（購読情報の鮮度）
- PAY-STAR-SUBS-PER-STAR-PRICING（スター単位価格・文言）
- QA-E2E-001（UI回帰テスト）

## 5. テスト観点

- Feature Flag `AUTH_OAUTH_V1` ON/OFF 時の表示切替（現在は OFF のみ動作）。  
- Google/Apple 連携状態の正しい表示（実装後）。  
- 401/403 発生時の再認証モーダル遷移（仕様のみ、QA は Dry-runモックでカバー）。  
- スター単位価格の表示／成人・未成年推奨ラベル／入力ガード（新規仕様）。  
- 可変価格を入力した場合にバリデーションエラーが表示されること（下限/上限/数値形式）。

## 6. 完了条件

- Figma/デザイン仕様と実装の差異がないこと。  
- Mermaid Day4 クラスタで `UI-HOME-001` と PAY-STAR-SUBS-PER-STAR-PRICING のリンクが有効。  
- QA-E2E ケースがグリーンで通過。  
- 成人/未成年向けの文言ガイド（表現ガイドライン準拠）を `guides/` に追記。

---

## 差分サマリ (Before/After)

- **Before**: OAuth UI・再認証モーダル・スター別価格表示が実装済みと仮定していた。  
- **After**: Flutter Reality（メールログイン＋固定価格）に合わせ、未実装箇所を TODO 化し、PAY-STAR-SUBS-PER-STAR-PRICING と連動する価格/文言要件を追加。  
- **追加**: `AUTH_OAUTH_V1` フラグの出し分け、成人/未成年ラベルの表示仕様、テスト観点を明記。
