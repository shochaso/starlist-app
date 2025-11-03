# スター単位サブスクリプション全面移行 要件定義

Supabase と Flutter を前提としたスター単位の定期課金モデルへ全面移行するための要件をまとめる。決済ゲートウェイは Stripe / KOMOJU / Paygent いずれにも対応できる抽象化層を設計する。

---

## 1. スコープ / 目的
- **目的**：課金単位を「ユーザー全体」から「スター単位」へ変更し、推しごとの購読／収益分析を実現する。
- **対象**：データモデル、API、アクセス制御、決済フロー、フロント UI、通知、計測、移行プラン。
- **非対象**：スター自身が自由価格を設定する機能（将来拡張に備えた設計フックのみ用意）。

---

## 2. ドメインモデル（ERD 概要）

| テーブル | 主なカラム | 説明 |
| --- | --- | --- |
| `users` | `user_id` | エンドユーザー（ファン）。既存テーブルを継続利用。 |
| `stars` | `star_id`, `owner_user_id`, `display_name`, ... | スター（クリエイター）。オーナーは運営 or スター本人。 |
| `plans` | `plan_id`, `code`, `tier`, `default_price_jpy`, `features[]` | グローバル共通プラン。LITE / STANDARD / PREMIUM を定義。 |
| `star_plan_overrides` | `star_id`, `plan_id`, `price_jpy?`, `is_enabled` | スター個別のプラン有効化／価格上書き。 |
| `subscriptions` | `subscription_id`, `user_id`, `star_id`, `plan_id`, `status`, `started_at`, `current_period_end`, `cancel_at_period_end`, `gateway`, `gateway_sub_id`, `meta` | ユーザーとスターの紐付け。status は `pending` / `active` / `trial` / `cancelled` / `expired` 等を想定。 |
| `payments` | `payment_id`, `subscription_id`, `method`, `amount_jpy`, `fee_jpy`, `currency`, `status`, `paid_at`, `gateway`, `gateway_payment_id`, `raw_payload` | 決済イベントの記録。 |
| `entitlements` | `entitlement_id`, `star_id`, `plan_id`, `key`, `rule` | プランに紐づく機能フラグ。 |
| `audit_logs` | ... | 重要イベントの記録。 |

### 主キー / 一意制約
- `subscriptions`: `unique(user_id, star_id, plan_id, status)` （ `status` が `active` or `trial` の行に限定できるよう制約を実装 ）。
- `star_plan_overrides`: `unique(star_id, plan_id)`.
- `payments`: `unique(gateway, gateway_payment_id)` で重複受信を防止。

### インデックス
- `subscriptions(user_id)`, `subscriptions(star_id)`.
- `payments(subscription_id, paid_at desc)`.
- `entitlements(star_id, plan_id)`.

### 共通メタ仕様
- Supabase 側では JSONB カラムを活用し `meta` フィールドにゲートウェイ固有情報を格納。
- `raw_payload` は Webhook 受信データの完全保存用（監査・トラブルシュート）。

---

## 3. アクセス制御（閲覧権限）
- コンテンツごとに `visibility = public | followers | premium` を保持（既存仕様を踏襲）。
- **表示可否（ファン視点）**
  - `public`: 誰でも閲覧可能。
  - `followers`: 当該スターをフォロー済みなら閲覧可能。
  - `premium`: `subscriptions.status='active'` かつ `subscriptions.star_id` がコンテンツの `star_id` と一致する場合のみ閲覧できる。
- **キャッシュ**：`viewer_subscribed_star_ids` を 5〜15 分キャッシュしてアクセス判定を高速化（Supabase Edge Functions / Cloudflare KV などを選択可）。

---

## 4. プラン / 価格設計
- **ベースプラン**：`plans` テーブルに LITE / STANDARD / PREMIUM を定義。`features[]` はインデックス化可能な JSON 配列または関連テーブルで管理。
- **スター個別調整**：`star_plan_overrides` によって提供プランの有効化／価格上書きを実現。`price_jpy` が `NULL` の場合は `plans.default_price_jpy` を使用。
- **将来拡張**：スターが完全自由価格を設定できるよう `custom_price_jpy` カラムの追加余地を確保。API 層は `resolved_price_jpy` を返し、クライアントの複雑化を防ぐ。

---

## 5. 決済フロー（スター単位）

### 5.1 チェックアウト
- ユーザー導線：`/star/:starId/plan` → プラン選択 → 支払い方法選択（クレカ / コンビニ / キャリア等）。
- API：`POST /api/checkout/session`
  - 入力: `{ star_id, plan_id, method }`.
  - 出力: `{ redirect_url | payment_code, checkout_session_id }`.
  - 生成処理:
    1. `subscriptions` 行を `pending` 状態で作成（`idempotency_key` 必須）。
    2. `payments` 行も `pending` 状態で作成し、ゲートウェイ用セッション情報を保持。
    3. 各ゲートウェイ SDK/REST を抽象化した Service 層に委譲。

### 5.2 Webhook / Return 処理
- **成功**：`payments.status = 'paid'` に更新 → `subscriptions.status = 'active'` 、`started_at` / `current_period_end` を計算（プランの `billing_cycle` から算出）。
- **失敗 / 取消**：`payments.status = 'failed' | 'canceled'` に更新、`subscriptions` は `pending` から `canceled` へ。
- **継続課金**：自動課金型はゲートウェイからの更新イベントで `current_period_end` を延長。重複更新を避けるため `gateway_sub_id` + `billing_period` で冪等性を担保。
- **コンビニ決済**：初回課金専用とし、継続課金はクレカ・キャリア決済へ誘導 or 都度課金に制限（運用判断が必要）。

---

## 6. API 仕様（要点）
- `POST /subscriptions`
  - Body: `{ star_id, plan_id, method }`
  - 役割: チェックアウトセッション作成（5.1 のエンドポイントをラップ）。
- `GET /subscriptions/my`
  - 応答: 購読中スターのリスト（スター名、プラン、価格、次回更新日、解約リンク）。
- `POST /subscriptions/:id/cancel`
  - 処理: `cancel_at_period_end = true` に更新。即時解約が必要な場合は別アクションを用意。
- `GET /stars/:id/entitlements`
  - UI 表示制御のため、スター単位で有効な機能一覧を返却。
- **認可**：全エンドポイントで JWT から `user_id` を抽出し、`subscriptions.user_id` と一致することを Supabase RLS でも API 層でも検証。

---

## 7. UI / UX 変更

### 7.1 スター詳細ページ
- ヘッダーに購読状態バッジ（`Active` / `Trial` / `未加入`）。
- CTA ボタン：「◯◯を応援する（プラン選択）」。

### 7.2 プラン選択モーダル / ページ
- タイトル：「{スター名} を応援するプラン」。
- `star_plan_overrides` の価格を反映。
- プラン選択 → 支払い方法選択 → 決済導線。
- 注意喚起：「この課金は {スター名} のみに適用されます」。

### 7.3 マイページ
- 「購読中のスター」セクション
  - 各行：アイコン、スター名、プラン、金額、次回更新日、解約・変更リンク。
- 領収書ダウンロード（`payments` 明細を PDF / メールで配信）。

### 7.4 コンテンツリスト
- `premium` コンテンツカードにロック表現と「{スター名} の購読で解放」の CTA を表示。

---

## 8. 通知・リマインド
- **加入完了**：スター名／プラン名／金額／次回更新日をメール・プッシュで通知。
- **更新前**：自動更新対象に 7 日前・3 日前・前日リマインド（Supabase Functions + Cron）。
- **支払い失敗**：再試行案内とカード更新リンク。
- **解約完了**：有効期限まで閲覧可能である旨を通知。

---

## 9. 計測（イベント設計）
- `sub_checkout_view` `{ star_id, plan_id, method_options[] }`
- `sub_checkout_submit` `{ star_id, plan_id, method }`
- `sub_activated` `{ star_id, plan_id, amount_jpy, method, gateway }`
- `sub_canceled` `{ star_id, plan_id, reason }`
- ダッシュボード指標：Star LTV / ARPU / Churn / Conversion（view→activate）。

---

## 10. セキュリティ / 法務対応
- Webhook 署名検証と `idempotency_key` 運用で重複課金を防止。
- 未成年向けの親権者同意表示・特商法表記・返金方針を購入フローに組み込み。
- 請求データは最小限保持し、カード番号などの PCI 領域はゲートウェイに委託。

---

## 11. 既存ユーザー移行案
- 現行「全体サブスク」を `star_id = 'official_all'` の仮スターに一時的に紐付ける。
- メール／アプリ内で「推しスターを選んで移行」導線を設置。
- 猶予期間後は仮スターの購読を終了（事前告知と移行特典の有無は別途決定）。

---

## 12. 受け入れ基準（抜粋）
- [ ] `subscriptions` に `user_id` + `star_id` 単位で `active` レコードが作成・更新される。
- [ ] `premium` コンテンツは該当スターを購読しているユーザーのみ閲覧できる。
- [ ] 同一ユーザーが複数スターを同時購読できる。
- [ ] 料金・更新日・領収書が UI / メールで一致する。
- [ ] Webhook の再送でも二重課金・二重有効化が発生しない。
- [ ] 計測イベントがスター軸で集計可能。

---

## 13. 実装ガイド（マイン向けタスク分解）
1. **DB マイグレーション**：ERD に基づきテーブル／制約を追加。既存 `user_plan` は非推奨化。
2. **RLS / Policy**：Supabase の `subscriptions` に本人のみ参照・更新できる RLS を設定。
3. **API 実装**：`/subscriptions` 系エンドポイントを新設し、戻り値の `return_url` に署名を付与。
4. **Entitlement Gate**：フロントで `useEntitlements(star_id)` を共通フック化し表示制御を一本化。
5. **UI 改修**：スター詳細 → プラン選択 → 支払い → 完了の新フローを実装。
6. **通知ジョブ**：更新前 / 失敗 / 解約のメール送信スケジュールを Supabase Edge Functions で実装。
7. **計測**：イベント発火とダッシュボード指標（Star LTV など）を分析基盤に追加。

---

## 14. オープン事項（要決）
- 決済ゲートウェイの本命選定（Stripe 優先か、KOMOJU 併用か）。
- コンビニ決済で継続課金をどう扱うか（初回のみ or 都度課金運用）。
- スター別価格の自由度（初期段階の上限/下限ルール設定）。
- 既存グローバル課金ユーザーへの移行特典の有無。

