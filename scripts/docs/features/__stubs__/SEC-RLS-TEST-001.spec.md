---

spec_id: PAY-STR-RLS-ONEPAGER

scope: Stripe決済／RLSアクセス制御／共通返金ポリシー

status: draft

source_of_truth: true

last_updated: 2025-11-07 JST

relates:

  - PAY-STR-WEBHOOK

  - PAY-STR-AUDIT

  - PAY-STR-SUBSCRIPTION

  - RLS-ACCESS-POLICY

  - RLS-STORAGE

  - RLS-ROLE-MATRIX

  - REFUND-POLICY

owners:

  - pm: Tim

  - impl: Mine

review_flow: AI(stripe_rlsプリセット) -> Tim(最終)

---

# 要約（まずここだけ読めばOK）

- **Stripeでできること：**

  クレジットカード・Apple Pay・Google Payで安全に購読決済できる。  

  成功後はスターの有料情報を見られる（サブスク型／単発課金どちらも対応）。

- **返金ポリシー：**

  原則不可。ただし二重請求やシステム障害など、当社責任の場合は全額返金。  

  → 文言はキャリア決済と完全に統一。

- **安全設計の要：**

  ① Webhookの重複防止  

  ② 監査ログによる全履歴記録  

  ③ RLSでアクセス範囲を厳密に制御

---

## Stripe側の仕組み（3点だけ）

1. **Webhook重複防止：**  

   Stripeから同じイベントIDが複数届いても、**1回しか処理されない**  

   → `event.id` に UNIQUE制約＋idempotent upsert

2. **監査ログ：**  

   すべての通知イベントを `audit_payments` に保存（原文JSON・署名結果・回数・タイムスタンプ）  

   → このテーブルが**唯一の信頼記録**

3. **サブスク状態同期：**  

   定期課金の「有効／停止」を Supabase のユーザ権限に反映（RLSと連携）

`code_refs:` webhook handler / audit schema / cron job : `<TODO>`

---

## RLS（行レベルセキュリティ）設計

| ロール | 読み取り | 書き込み | ストレージ閲覧 | 備考 |

|:--|:--:|:--:|:--:|:--|

| anonymous | ✖ | ✖ | ✖ | ログイン前 |

| free_user | 一部可 | ✖ | ✖ | 無料スター情報のみ |

| paid_user | ◎ | 一部 | ◎ | 自分が購読したスターの範囲のみ |

| star | ◎ | ◎ | ◎ | 自分の投稿・売上のみ |

| admin | ◎ | ◎ | ◎ | 全件管理権限 |

- 署名URL寿命：**60秒**（購読者のみ付与）  

- 管理権限操作はすべて**監査対象**

`code_refs:` RLS policy SQL / storage policy : `<TODO>`

---

## 返金ポリシー（キャリア決済と共通）

- 原則返金不可  

- 当社原因（重複課金・決済障害）は全額返金  

- 返金は**監査ログ＋Stripe Dashboard記録**で照合後、Stripe APIで処理  

- ポリシー文言は PAY-CAR-POLICY と**完全一致**させること

`code_refs:` policy text / refund handler : `<TODO>`

---

## ログ・計測

- Stripeイベント件数／再送件数／平均反映時間／返金件数 を収集  

- 90日で自動アーカイブ  

- メトリクスは Prometheus + Grafana で可視化

`code_refs:` metrics exporter : `<TODO>`

---

## この1ページのゴール

Stripe／RLS／返金ポリシーが**同じ思想・同じ言葉**で動いている状態を保証。  

ここに矛盾がなければ、関連7仕様を `source_of_truth:true` に昇格可能。

---

---
doc_id: SEC-RLS-TEST-001
domain: rls
status: draft
source_of_truth: true
owner: tim
code_refs:
  - supabase/migrations/2025-rls.sql#L1-L400
  - supabase/policies/*.sql
  - tests/rls/rls_e2e.spec.ts#L1-L220
last_updated: 2025-11-07
---

# RLS 5ロール テスト仕様（Supabase）

## 目的 / スコープ

- 全主要テーブルに対し **匿名 / 非購読 / 購読 / スター本人 / 管理者** の5ロールで **SELECT/INSERT/UPDATE/DELETE** を検証し、**データ分離（tenant isolation）** と **最小権限** を保証する。

## 対象ロール

1. **anonymous**：未ログイン

2. **viewer**：ログイン済・非購読ユーザー

3. **subscriber**：特定スターの購読者

4. **star_owner**：スター本人（自分のデータのみ）

5. **admin**：運営（サービスロール想定・最小化）

## 対象テーブル（例）

- `profiles`（公開プロフィール）

- `stars`（スター基本情報）

- `subscriptions`（購読関係）

- `payments`（支払い記録・金額は非公開）

- `posts`（スター投稿・可視性 tierつき）

- `assets`（Storageメタ）

- ストレージバケット：`avatars/`, `content/`, `receipts/`, `temp/`

## 基本原則

- **行レベル分離**：`star_id` / `user_id` / `project_id` 等のキーで完全分離

- **機微列マスク**：金額・メール等はRLSで非表示 or 0/NULL

- **サービスロール最小化**：管理機能のみ、利用時は監査必須

- **署名URL**：有効期限・スコープを厳格化、推測耐性（予測不能キー）

## RLS可否マトリクス（抜粋・テーブル=posts）

| ロール \ 操作 | SELECT | INSERT | UPDATE | DELETE |

|---|---:|---:|---:|---:|

| anonymous     | ✖︎（無料範囲のみ△可） | ✖︎ | ✖︎ | ✖︎ |

| viewer        | △（無料のみ） | ✖︎ | ✖︎ | ✖︎ |

| subscriber    | ○（購読スターの有料含む） | ✖︎ | ✖︎ | ✖︎ |

| star_owner    | ○（自分の全投稿） | ○（自分のみ） | ○（自分のみ） | ○（自分のみ） |

| admin         | ○ | ○ | ○ | ○ |

> 実テーブルごとにこの表を用意（`profiles/payments/subscriptions/...`）。`payments` は **subscriberでもSELECT不可（集計ビューのみ）** など、最小化を徹底。

## ストレージ規約

- `content/`：購読者のみ署名URLで取得可（該当スターのリソースに限定）

- `receipts/`：**運営のみ**、署名URLの寿命は短く（例：60秒）

- `avatars/`：公開可（低解像度）、原本はスター本人/運営のみ

## テスト戦術（E2E）

- テストフレームワーク：`tests/rls/rls_e2e.spec.ts`

- ユーザーフィクスチャ：`anon`, `viewerA`, `subB`, `starX`, `admin`

- データシード：`starX` の投稿 N件、有料/無料の混在

### 代表テスト（posts）

1. **匿名**：無料投稿のみ SELECT可、有料は403/空

2. **viewer**：匿名と同等、購読スターの有料は不可

3. **subscriber(B→X)**：`starX` の有料投稿を SELECT可、他スターは不可

4. **star_owner(X)**：`starX` の INSERT/UPDATE/DELETE 可、他は不可

5. **admin**：全操作可（監査に記録）

### 代表テスト（payments）

- **subscriber**：自分の支払いレコード **SELECT不可**（集計ビュー `v_payments_summary` のみ）

- **admin**：SELECT可、金額等は監査対象

- **star_owner**：自スターの売上集計ビューのみ参照可（個票は不可）

## 監査ログ

- `audit_access`：`who/when/what/table/op/row_keys/success`

- サービスロール利用時は **必須記録**、しきい値超過でアラート

## 受入条件（Definition of Done）

- 主要テーブル＋ストレージで **5ロール×CRUD** のテストが**緑**（失敗0）

- マスク列が**意図通り**（例：paymentsのamountはビュー以外で不可視）

- 署名URLの**期限/権限**がテストで検証済み

- 監査ログが**全アクセス**を記録

## 付録：テスト擬似コード

```ts
// pseudo (supabase-js)
const as = role => supabaseClientFor(role);

test('subscriber sees paid posts of subscribed star only', async () => {
  const { data, error } = await as('subscriberB').from('posts')
    .select('*').eq('star_id','starX').eq('tier','paid');
  expect(error).toBeNull();
  expect(data.length).toBeGreaterThan(0);
  // cross-star leakage check
  const { data: other } = await as('subscriberB').from('posts')
    .select('*').neq('star_id','starX').eq('tier','paid');
  expect(other.length).toBe(0);
});
```
