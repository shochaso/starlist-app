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
doc_id: SEC-RLS-CORE-001
domain: rls
status: draft
source_of_truth: true
owner: tim
code_refs:
  - supabase/migrations/2025-rls-policies.sql#L1-L400
  - supabase/policies/*.sql
  - lib/features/auth/rls_helpers.dart#L1-L100
last_updated: 2025-11-07
---

# Supabase RLS：コアアクセス制御ポリシー

## 目的 / スコープ

- 全テーブルで適切なアクセス制御を実装し、データ漏洩を防止。
- 匿名ユーザー、購読者、非購読者、スター本人、運営の各ロールで適切なアクセス権限を定義。

## 分離キー設計

### 基本原則
- **user_id**: 個人データの分離（プロフィール、設定、個人履歴）
- **star_id**: スター関連データの分離（コンテンツ、購読情報）
- **project_id**: システム全体の論理分離（将来的なマルチテナント対応）

### ロール定義
- **anonymous**: 未ログイン状態（公開情報のみ）
- **authenticated**: ログイン済み一般ユーザー
- **subscriber**: 有料購読者（追加コンテンツアクセス）
- **star**: スター本人（自身のコンテンツ管理）
- **admin**: 運営管理者（全アクセス＋監査）

## 主要テーブル別ポリシー

### users（ユーザー情報）
```sql
-- 自分の情報のみ編集可能
-- 購読者は詳細情報閲覧可
-- 一般公開情報は全員閲覧可
```

### posts（コンテンツ）
```sql
-- スター本人のみ作成・編集
-- 購読者または購入者は閲覧可
-- 非購読者は無料部分のみ
```

### subscriptions（購読情報）
```sql
-- 本人のみ閲覧・管理
-- スターは自身の購読者情報を集計閲覧
-- 運営は監査目的のみ
```

### payments（決済情報）
```sql
-- 本人のみ閲覧
-- 運営は障害対応時のみ
-- ログは暗号化・最小限保存
```

## auth.uid()利用原則

- **主体確認**: 全ポリシーで `auth.uid() = user_id` を基本
- **サービスロール**: 最小限使用、エッジ関数経由のみ
- **監査**: サービスロール使用時はログ記録

## 5ロールCRUD可否表

| テーブル | 操作 | anonymous | authenticated | subscriber | star | admin |
|------|------|-----------|---------------|------------|------|-------|
| users | SELECT | 公開情報のみ | 全情報 | 全情報 | 全情報 | 全 |
| users | UPDATE | ❌ | 自分のみ | ❌ | ❌ | 全 |
| posts | SELECT | 無料部分 | 無料部分 | 全 | 全 | 全 |
| posts | INSERT | ❌ | ❌ | ❌ | 自分のみ | 全 |
| subscriptions | SELECT | ❌ | 自分のみ | ❌ | 自分の購読者 | 全 |
| payments | SELECT | ❌ | 自分のみ | ❌ | ❌ | 監査時 |

## ポリシー実装パターン

### 基本パターン
```sql
-- 自分のデータのみ
CREATE POLICY "users_select_own" ON users
FOR SELECT USING (auth.uid() = id);

-- 購読者のみ
CREATE POLICY "posts_select_subscribers" ON posts  
FOR SELECT USING (
  is_free = true 
  OR EXISTS (SELECT 1 FROM subscriptions s WHERE s.user_id = auth.uid() AND s.star_id = posts.star_id AND s.status = 'active')
);
```

### スター本人パターン
```sql
-- 自身のコンテンツ管理
CREATE POLICY "posts_manage_own" ON posts
FOR ALL USING (auth.uid() = star_user_id);
```

## テストケース

### 単体テスト
- **匿名ユーザー**: 公開情報のみアクセス可能
- **非購読者**: 無料コンテンツのみ閲覧可能
- **購読者**: 購読中スターの全コンテンツ閲覧可能
- **スター本人**: 自身のコンテンツ作成・編集可能
- **管理者**: 全データアクセス可能

### 統合テスト
- **クロステーブル**: subscriptions経由のpostsアクセス
- **複合条件**: 複数ポリシーのAND/OR条件
- **エッジケース**: NULL値、削除データ、ステータス遷移

## 監査・ログ

- **アクセスログ**: SELECT/INSERT/UPDATE/DELETEの各操作を記録
- **who/what/when**: user_id, table_name, operation, record_id, timestamp
- **PII最小化**: ログに個人情報非保持
- **保持期間**: 監査ログは7年保持

## セキュリティ/PII

- **最小権限**: 各ロールの必要最小限アクセス
- **暗号化**: 機微データの保存時暗号化
- **ログ**: アクセスログにPII非保持
