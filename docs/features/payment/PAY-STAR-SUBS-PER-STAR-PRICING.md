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


# PAY-STAR-SUBS-PER-STAR-PRICING — スター単位サブスク可変価格仕様

Status: draft  
Last-Updated: 2025-11-07  
Source-of-Truth: Flutter code (`lib/src/features/subscription/**`) + 新規要件

## 1. 目的

- 現状の共通プラン課金（`subscription_plans`）をスター単位へ拡張し、スターごとに価格を設定できるようにする。  
- 価格は可変であり、成人ファン向けと未成年ファン向けで推奨レンジ／注意文言を切り替える。  
- 新仕様は Flutter / Supabase / OPS / QA 各仕様へ横断的に反映し、Day4 以降の SoT とする。

## 2. スコープ

- **UI**: スター詳細画面、購読ボタン、価格入力コンポーネント（モバイル/Web）。  
- **データ**: `star_subscriptions`（新規） or `subscription_plans` 拡張、`entitlements` への `star_id` 追加。  
- **検証**: 価格範囲、通貨、税、居住地域、年齢確認。  
- **監査**: 価格提示・選択・確定イベントを OPS ログへ送出。  
- **依存仕様**: AUTH-OAUTH-001（購読権限同期）、SEC-RLS-SYNC-001、UI-HOME-001、OPS-MONITORING-001、QA-E2E-001。

## 3. UI 仕様

| 状態 | 表示/動作 |
| --- | --- |
| スター詳細画面 | `スター名`, `スター単位サブスク` セクション、成人/未成年向けの推奨価格レンジ表示、注意ラベル。 |
| 価格入力 | スライダー＋テキスト入力。成人: Light 980〜30,000円 / Standard 1,980〜50,000円 / Premium 2,980〜100,000円（推奨）。未成年: Light 100〜300円 / Standard 300〜500円 / Premium 500〜1,000円（推奨）。初期値はスターが設定。下限 100円、上限 100,000円。10円刻み、税込表示。 |
| 未成年ラベル | 「未成年ファンは保護者同意のもと決済してください」＋ `guides/Starlist 表現ガイド` に準拠した注意文。 |
| CTA ボタン | 「このスターを購読する」「推奨価格を参考に設定しました」など、過大表現は禁止。 |

### 3.1 価格レンジ仕様

- **min**: 100円（税込）
- **max**: 100,000円（成人プレミアムプランのハード上限）
- **default**: スター側設定値（成人向け: 3,000円 / 未成年向け: 1,000円）
- **UIスライダー**: 10円刻みでドラッグ可能、リアルタイム価格表示
- **端数処理**: 整数値のみ（小数点以下は四捨五入せず入力拒否）
- **税表示**: 価格入力欄は税込表記（決済確認画面も税込表示）

## 4. 文言・表現ルール

- 過大・誇張表現は禁止（例: 「絶対に得する」 NG）。  
- 成人向け: 「成人ファン向け推奨レンジ: Light 980〜30,000円 / Standard 1,980〜50,000円 / Premium 2,980〜100,000円（推奨値はそれぞれ 980円・1,980円・2,980円）」。
- 未成年向け: 「未成年ファン向け推奨レンジ: Light 100〜300円 / Standard 300〜500円 / Premium 500〜1,000円（推奨値 100円・200円・500円）／保護者同意が必要です」。
- UI-HOME-001 にリンクし、ホーム／マイページでも同じ文言ガイドを使用。

## 5. 年齢確認フロー

### 5.1 UIフロー
- **入力方式**: トグルボタン（成人/未成年）または生年月日入力（自動判定）
- **初期状態**: 未選択時 → 成人向け推奨価格を表示
- **切替時**: 未成年選択 → 保護者同意注意文を表示、価格レンジを未成年向けに変更
- **RLS側判定**: Supabase RLSで `age_category` を参照し、未成年価格上限（1,000円）を超える場合アクセス拒否

### 5.2 RLS側の年齢境界扱い
- **境界値**: 18歳未満を未成年と判定（日本法準拠）
- **保存形式**: `age_category` カラム（'adult'/'minor'）
- **アクセス制御**: 未成年ユーザーが未成年上限を超える価格設定を試みると `rls.access.denied` イベント発火

## 6. 既存契約の扱い

- **価格改定時**: 既存サブスクリプションは据置（変更なし）
- **次回更新時**: 新価格を適用（Stripe webhookで自動反映）
- **途中変更**: ユーザー操作での価格変更は不可（契約継続前提）
- **解約再入会**: 新価格で再契約可能

## 7. バリデーション

- **価格**: 下限 100円、上限 100,000円、整数のみ（通貨: JPY）。プラン別のハードレンジ（Adult: Light 980〜30,000／Standard 1,980〜50,000／Premium 2,980〜100,000、Minor: Light 100〜300／Standard 300〜500／Premium 500〜1,000）も UI/バリデーションで併せて検証。
- **税**: 価格入力時に税率 <country-based> を自動計算（将来拡張）。表示は税込。
- **年齢区分**: フォームで「成人/未成年」を選択 → 注意文表示／推奨価格レンジを切替。
- **地域**: 通貨は JPY 固定。海外展開時は別仕様で扱う。
- **監査**: 価格入力・確定時に以下イベントを発火。
  - `ops.subscription.price_set` `{ user_id, star_id, price, age_category }`
  - `ops.subscription.price_changed` `{ subscription_id, star_id, old_price, new_price }`
  - `ops.subscription.price_denied` `{ user_id, star_id, price, reason }`

## 6. RLS / データモデル

- `star_subscriptions` (新規)  
  ```
  star_id uuid references stars(id)
  fan_user_id uuid references auth.users(id)
  price integer
  age_category text check (in ('adult','minor'))
  status text (active/pending/cancelled)
  ```
- `entitlements` に `star_id`, `price`, `age_category` を追加し、`v_entitlements_effective` でスター単位の購読を判定。  
- RLS: `star_id = target_star` を条件に `exists` 判定。SEC-RLS-SYNC-001 に記載。

## 7. 監査・OPS 連携

- OPS-MONITORING-001 で定義した `auth.*` + `ops.subscription.*` イベントを使用。  
- サンプリング: 通常 1.0、エラー時は全件。  
- Slack / PagerDuty へ通知する閾値:  
  - price_selected → price_confirmed が 5 分以内に 80% 未満 → warn。  
  - 未成年ユーザーの価格設定が 1,000円を超えた場合 → info ログ + UI 警告。

## 8. QA / テスト

- QA-E2E-001 へ以下シナリオを追加。  
  1. 成人ユーザー: 3,000 円で購読 → OPS ログ `ops.subscription.price_selected`/`price_confirmed` を確認。  
  2. 未成年ユーザー: 2,000 円を入力 → バリデーションエラー表示。  
  3. スターA と スターB を別価格で購読 → UI にスター別バッジが表示。  
- Feature Flag: `AUTH_OAUTH_V1`, `AUTH_SYNC_DRY_RUN` に加え `STAR_PER_SUB_PRICING_V1` を設け段階導入。

## 9. 完了条件

- 本仕様が SoT レビューで承認され、Mermaid / 索引 / Day4 仕様から参照される。  
- `.env.example` に `STAR_PER_SUB_PRICING_V1=false` を追加。  
- QA シナリオが `docs/features/day4/QA-E2E-001.md` へ反映。  
- OPS 監査イベント命名が `OPS-MONITORING-001.md` で固定化。

## 差分サマリ

- **新規**: 従来の全体プラン課金からスター単位可変価格へ拡張。  
- **追加要件**: 成人/未成年の推奨価格レンジ、注意文言、OPS/QA/SEC 仕様とのリンク。  
- **今後**: Flutter 実装と Supabase DDL を別タスクで対応。Feature Flag で段階的に有効化する。

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
