---
doc_id: PAY-CAR-CORE-001
domain: payment_carrier
status: draft
source_of_truth: false
owner: mine
code_refs:
  - lib/features/payment/carrier_flow.dart#L1-L200
  - edge/functions/carrier/callback.ts#L1-L160
  - supabase/tables/payments.sql#L1-L200
last_updated: 2025-11-07
---

# キャリア決済：購読フロー（スター単位・重複防止）

## 目的 / スコープ

- スター単位の継続課金を**キャリア支払い**で成立させる。二重申込・通信切断・非同期確定の揺れに強い。
- 返金ポリシーは**原則不可**。やむを得ない例外のみ別途フロー（監査ログ必須）。

## 状態遷移 / フロー

```mermaid
flowchart TD
  S[開始: スターの購読選択] --> C[キャリア選択/同意]
  C --> P[pending(外部決済ハンドオフ)]
  P -->|成功コールバック| A[active(購読有効)]
  P -->|失敗/キャンセル| F[failed]
  P -->|タイムアウト| T[timeout(再開トークン発行)]
  A --> R[更新/解約/期限切れ処理]
```

* **再開トークン**: ハンドオフ中に離脱した場合、同一セッション復帰を許可（UIに「続きから再開」）。
* **二重防止**: `(user_id, star_id, plan_id)` で**idempotency_key**を生成し、`payments.pending` にユニーク制約。

## 入出力 / 依存

* **Inputs**: `user_id, star_id, plan_id, device_id, consent_flags`
* **Outputs**: `payments{ id, status, method='carrier', external_txn_id, next_renew_at }`
* **依存**: Supabase(RLS/Storage), Edge Functions(`/carrier/start`, `/carrier/callback`), 外部キャリアAPI

## キャンセル実装ルール（確定案）

### 1) 基本方針（標準）

* **ユーザー操作でできること**：

  「**自動更新を停止**」＝**今期末まで閲覧可**、**次回以降は課金しない**。

  （＝Stripe: `cancel_at_period_end = true`／キャリア: 事業者規約に合わせて"次回以降停止"）

* **できないこと（原則）**：

  即時停止＋当期返金（※例外はサポート裁量。根拠ログ必須）

* **可視化ルール**：

  * 新規購読 → **即時可視化**（支払成功／承認で権限ON）

  * 自動更新停止 → **period_end まで可視**、**期日到達で不可視**（自動）

### 2) サポート例外（やむを得ない理由のみ）

* **即時停止（サポ断）**：当日で不可視化（返金有無はケース別）

  例）重複課金／明確な事業者起因障害／不正利用（請求元盗用 等）

* **返金判断**：

  * 原則不可

  * **当社起因**（二重請求・システム障害等）は**全額返金**

  * 実務は**監査ログ（audit_payments）**を根拠に。返金時は**監査ID紐づけ必須**

* **監査**：`audit_entitlements` に「誰が・いつ・どの理由で即時停止したか」を必ず記録

## データモデル／状態遷移

### Entitlement（購読権限）テーブル

```sql
entitlements (
  id                uuid PK,
  user_id           uuid,
  star_id           uuid,
  provider          text,      -- 'stripe' | 'carrier'
  status            text,      -- 'active'|'pending_cancel'|'canceled'|'revoked'|'past_due'
  access_from       timestamptz,
  access_until      timestamptz,   -- 期末（自動停止ならここまで可視）
  will_cancel_at    timestamptz,   -- = period_end（自動更新停止時にセット）
  revoked_at        timestamptz,   -- 例外即時停止時
  termination_reason text,         -- 例外理由（enum/テキスト）
  last_event_id     text,          -- Stripe/キャリアの原本イベントID
  created_at        timestamptz,
  updated_at        timestamptz
)
```

### 可視/不可視の判定ビュー（RLSが見る"真実"）

```sql
view v_entitlements_effective as
select *,
  case
    when status='revoked' then false
    when now() < access_until then true
    else false
  end as is_visible
from entitlements;
```

* **通常解約**：`status='pending_cancel', `will_cancel_at=period_end`。CRON/Webhookで期日到達→`status='canceled'` & `access_until=will_cancel_at`

* **即時停止（サポ断）**：`status='revoked', `revoked_at=now()`, `access_until=now()`

### Webhook/同期の要点

* **Stripe**

  * 自動更新停止: `subscription.updated(cancel_at_period_end=true)` → `pending_cancel` へ

  * 終了: `subscription.deleted` or `status='canceled'` → `canceled` + `access_until=period_end`

* **キャリア**

  * 月次/日次の**リコンシリエーション**で `pending_cancel`→`canceled` を確定

  * 事業者仕様で「即時停止」がない場合は**常に期末停止**で統一

## UI/文言（そのまま使える）

### 設定ページ（自動更新）

* ボタン文言：**「自動更新を停止」**

* 確認モーダル：

  * 見出し：**自動更新を停止しますか？**

  * 本文：

    ```
    いま停止すると、次回から請求は行われません。
    現在の購読は 〈YYYY/MM/DD HH:mm JST〉 まで閲覧できます。
    ※当期の返金は行われません。
    ```

  * 主要ボタン：**停止する**／**やめる**

### プラン表示

* バッジ：`〈YYYY/MM/DD〉まで有効（自動更新オフ）`

### 即時停止（サポ断）時の通知（テンプレ）

```
サポートにて購読を停止しました。閲覧権限はこの時点で終了しています。
[チケットID: ####-####] ご不明点は本メールにご返信ください。
```

## RLS/セキュリティ

* アプリ側の表示は**必ず** `v_entitlements_effective.is_visible=true` を前提に

* 画像/添付は**署名URL 60秒**・購読者のみ払い出し（Day2と統一）

* 期末や即時停止で**URLは即無効化**（`access_until` を過ぎたら発行不可）

## スモークテスト（最小で効く3本）

1. **自動更新停止→期末で不可視化**

* 期待：停止直後は閲覧可／`period_end+1秒`で不可視

2. **Stripe再送×3**（停止→更新→終了）

* 期待：`entitlements` は**一貫**、`audit_payments` に履歴は3行

3. **サポ例外：即時停止**

* 期待：停止操作直後に不可視／`audit_entitlements` に理由・操作者・時刻

## サポート運用（判断フロー）

```
ユーザー申告受付
  └─ 監査確認（重複請求？障害影響？）
       ├─ 当社起因 Yes → 即時停止 + 返金（全額） + 監査ID紐づけ
       ├─ 当社起因 No  → 原則は期末停止案内（テンプレ返信）
       └─ 不正/盗用   → 即時停止 + 返金可否はカード会社/キャリア手続に準拠
```

**必要証跡**：`audit_payments.event_id`／通信ログ／エラーレポート番号

**記録**：`support_tickets` に「判断根拠」「最終処理」「対応者」を保存

## 注意（法務ニュアンス）

* デジタル配信は一般に**当期返金対象外**の運用が多いが、**最終判断は自社規約＋法務確認前提**に。

* 表記は**一貫**させる：Day1・Day2の返金文言（句読点・語尾まで）と同一。


## エラーと例外

* `timeout`: 「一定時間応答がありません。［再開］で続きから処理を再開できます。」
* `duplicate`: 「同じスターのプランに加入手続き中です。完了をお待ちください。」
* `limit/age`: 「年齢/ご利用限度により承認できませんでした。」（詳細非表示、サポート導線）
* すべて監査ログ：`audit_payments(user_id, star_id, err_code, ctx)`

## 返金/ポリシー

* 原則返金不可の明示（利用規約の該当条項リンク）
* 例外: 二重決済・法令要請等。**手数料差引**あり得る/サポート窓口・チケットID採番。

## 計測・監査

* 計測: 開始→pending→success/fail 各率、再開回数、二重防止ヒット数
* 監査: who/when/what、外部応答ID、署名/検証結果

## セキュリティ/PII

* 承認番号/取引IDのみ保存。**個人情報は保持しない**。ログはマスク済み。

## テスト（受入）

* pending→success/failed/timeout の全分岐を E2E
* 二重申込: 連打/別タブ/別デバイスで排他
* 戻る/再読み込みで**再開トークン**が機能
