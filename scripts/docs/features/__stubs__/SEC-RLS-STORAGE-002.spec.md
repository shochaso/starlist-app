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
doc_id: SEC-RLS-STORAGE-002
domain: rls
status: draft
source_of_truth: true
owner: tim
code_refs:
  - supabase/policies/storage_policies.sql#L1-L200
  - lib/features/storage/upload_service.dart#L1-L120
  - supabase/storage/buckets_config.sql#L1-L80
last_updated: 2025-11-07
---

# Supabase Storage：バケット別アクセス制御

## 目的 / スコープ

- 画像/動画/ドキュメント等のファイルを安全に管理。
- 署名URLの適切な権限設定と有効期限制御。
- パスベースの推測耐性確保。

## バケット設計

### avatars（プロフィール画像）
- **公開アクセス**: プロフィール表示用（署名不要）
- **アップロード**: 本人のみ
- **削除**: 本人のみ
- **パス**: `avatars/{user_id}/{filename}`

### content（コンテンツ画像/動画）
- **公開アクセス**: 購読者または購入者のみ
- **アップロード**: スター本人のみ
- **削除**: スター本人のみ
- **パス**: `content/{star_id}/{content_id}/{filename}`

### receipts（レシート画像）
- **アップロード**: ユーザー自身のみ
- **閲覧**: 本人＋運営（サポート時）
- **削除**: 本人＋運営
- **パス**: `receipts/{user_id}/{timestamp}/{filename}`

### temp（一時アップロード）
- **アップロード**: 認証済みユーザーのみ
- **有効期限**: 24時間で自動削除
- **パス**: `temp/{user_id}/{session_id}/{filename}`

## 署名URLポリシー

### 生成条件
```typescript
// 閲覧用署名URL
const signedUrl = await supabase.storage
  .from('content')
  .createSignedUrl(filePath, 3600, {
    download: true,
    // transform: { width: 300, height: 300 } // リサイズ可能
  });
```

### 有効期限
- **公開コンテンツ**: 7日間
- **非公開コンテンツ**: 1時間
- **一時ファイル**: 24時間

### 権限レベル
- **read**: 閲覧のみ（ダウンロード可）
- **write**: アップロードのみ
- **delete**: 削除のみ
- **full**: 全権限（管理者専用）

## セキュリティ対策

### パス推測耐性
- **ランダム化**: `crypto.randomUUID()` を使用
- **ハッシュ化**: user_id/star_id をハッシュ化
- **タイムスタンプ**: アップロード時刻をパスに含む

### ファイル検証
- **MIMEチェック**: 許可拡張子のみ（jpg, png, mp4, pdf等）
- **サイズ制限**: バケット別に最大サイズ設定
- **ウイルスチェック**: アップロード時スキャン（将来）

## RLSポリシー実装

### avatarsバケット
```sql
-- 自分のアバターのみ管理
CREATE POLICY "avatars_select" ON storage.objects
FOR SELECT USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "avatars_insert" ON storage.objects  
FOR INSERT WITH CHECK (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "avatars_delete" ON storage.objects
FOR DELETE USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);
```

### contentバケット
```sql
-- 購読者または購入者のみ閲覧
CREATE POLICY "content_select" ON storage.objects
FOR SELECT USING (
  bucket_id = 'content' 
  AND (
    -- スター本人は全アクセス
    (storage.foldername(name))[1] IN (
      SELECT star_user_id::text FROM stars WHERE user_id = auth.uid()
    )
    -- 購読者は購読中スターのコンテンツ
    OR EXISTS (
      SELECT 1 FROM subscriptions s 
      WHERE s.user_id = auth.uid() 
      AND s.star_id::text = (storage.foldername(name))[1]
      AND s.status = 'active'
    )
  )
);
```

## アップロードフロー

### クライアント側
1. **事前検証**: ファイルサイズ/MIMEチェック
2. **パス生成**: 安全なパス作成
3. **アップロード**: Supabase Storage API
4. **検証**: アップロード成功確認

### サーバー側
1. **RLSチェック**: アップロード権限確認
2. **ファイル検証**: セキュリティスキャン
3. **メタデータ保存**: DBにファイル情報記録
4. **クリーンアップ**: 失敗時はアップロードファイル削除

## 監査・ログ

- **アップロードログ**: user_id, bucket_id, file_path, size, mime_type
- **アクセスログ**: signed_url生成時のuser_id, file_path, expiry
- **削除ログ**: 削除操作の記録
- **保持期間**: 監査ログは3年保持

## エラー処理

- **権限エラー**: 「アップロード権限がありません」
- **サイズ超過**: 「ファイルサイズが大きすぎます（最大: XXMB）」
- **形式不正**: 「対応していないファイル形式です」
- **ストレージ満杯**: 「ストレージ容量が不足しています」

## テストケース

- **権限テスト**: 各ロールのアクセス可否
- **署名URL**: 有効期限切れ、権限不足
- **同時アップロード**: 複数ファイルの一括処理
- **エラー回復**: アップロード失敗時のクリーンアップ
