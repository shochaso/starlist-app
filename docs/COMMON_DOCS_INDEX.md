# STARLIST Documentation Index

最終更新: 2025-11-07

## 機能仕様一覧

### 🔄 自動生成された仕様スタブ (Draft)

| ドキュメント | ステータス | コード参照 | 最終更新 |
|-------------|-----------|-----------|----------|
| [AUTO-1](features/__stubs__/AUTO-1.spec.md) | draft | lib/main.dart#13 | 2025-11-07 |
| [AUTO-10](features/__stubs__/AUTO-10.spec.md) | draft | lib/screens/fan_register_screen.dart#246 | 2025-11-07 |
| [AUTO-11](features/__stubs__/AUTO-11.spec.md) | draft | lib/src/data/repositories/transaction_repository.dart#53 | 2025-11-07 |
| [AUTO-12](features/__stubs__/AUTO-12.spec.md) | draft | lib/src/data/repositories/transaction_repository.dart#60 | 2025-11-07 |
| [AUTO-13](features/__stubs__/AUTO-13.spec.md) | draft | lib/src/data/repositories/transaction_repository.dart#67 | 2025-11-07 |
| [AUTO-14](features/__stubs__/AUTO-14.spec.md) | draft | lib/src/data/repositories/transaction_repository.dart#74 | 2025-11-07 |
| [AUTO-15](features/__stubs__/AUTO-15.spec.md) | draft | lib/src/data/repositories/transaction_repository.dart#81 | 2025-11-07 |
| [AUTO-16](features/__stubs__/AUTO-16.spec.md) | draft | lib/src/data/repositories/transaction_repository.dart#93 | 2025-11-07 |
| [AUTO-17](features/__stubs__/AUTO-17.spec.md) | draft | lib/src/data/repositories/transaction_repository.dart#103 | 2025-11-07 |
| [AUTO-18](features/__stubs__/AUTO-18.spec.md) | draft | lib/src/data/repositories/transaction_repository.dart#120 | 2025-11-07 |
| [AUTO-19](features/__stubs__/AUTO-19.spec.md) | draft | lib/src/data/repositories/transaction_repository.dart#128 | 2025-11-07 |
| [AUTO-2](features/__stubs__/AUTO-2.spec.md) | draft | lib/screens/star_home_screen.dart#20 | 2025-11-07 |
| [AUTO-20](features/__stubs__/AUTO-20.spec.md) | draft | lib/src/data/repositories/transaction_repository.dart#135 | 2025-11-07 |
| [AUTO-3](features/__stubs__/AUTO-3.spec.md) | draft | lib/screens/star_home_screen.dart#26 | 2025-11-07 |
| [AUTO-4](features/__stubs__/AUTO-4.spec.md) | draft | lib/screens/star_home_screen.dart#32 | 2025-11-07 |
| [AUTO-5](features/__stubs__/AUTO-5.spec.md) | draft | lib/screens/star_home_screen.dart#71 | 2025-11-07 |
| [AUTO-6](features/__stubs__/AUTO-6.spec.md) | draft | lib/screens/help_center_screen.dart#121 | 2025-11-07 |
| [AUTO-7](features/__stubs__/AUTO-7.spec.md) | draft | lib/screens/help_center_screen.dart#398 | 2025-11-07 |
| [AUTO-8](features/__stubs__/AUTO-8.spec.md) | draft | lib/screens/help_center_screen.dart#416 | 2025-11-07 |
| [AUTO-9](features/__stubs__/AUTO-9.spec.md) | draft | lib/widgets/star_content_management.dart#87 | 2025-11-07 |

### 📋 正仕様 (Source of Truth)

| ドキュメント | ステータス | コード参照 | 最終更新 |
|-------------|-----------|-----------|----------|
| *未定* | - | - | - |

## 同期ステータス

- ✅ 仕様スキャン完了 (112件の未定義仕様検出)
- ✅ スタブ自動生成完了 (20件)
- 🔄 インデックス自動更新完了

## 次のアクション
## 1.4 データ連携／インポート詳細

- **Flutter 側 UI**: `lib/src/features/data_integration/screens/` に各サービス用画面、`support_matrix.dart` で対応状況を管理。
- **データ処理**: `lib/src/features/ingest/` でアップロード／解析、`lib/src/features/import_diagnose/` で診断フロー。
- **補足資料**: `docs/reports/COMPLETE_FILE_MANAGEMENT_GUIDE.md` にファイル連携の全体像、旧資料 `docs/planning/Starlist まとめ.md` に要件記録。


- **Flutter 側 UI**: `lib/src/features/data_integration/screens/` に各サービス用画面、`support_matrix.dart` で対応状況を管理。
- **データ処理**: `lib/src/features/ingest/` でアップロード／解析、`lib/src/features/import_diagnose/` で診断フロー。
- **補足資料**: `docs/reports/COMPLETE_FILE_MANAGEMENT_GUIDE.md` にファイル連携の全体像、旧資料 `docs/planning/Starlist まとめ.md` に要件記録。

#### 🆕 Day3 Source of Truth 仕様（2025-11-07）

| ID | タイトル | ドメイン | 概要 |
|----|-----------|----------|------|
| **ING-PIPE-CORE-001** | Ingestパイプラインコア | ingest | ingest_jobs / audit_ingest テーブル設計。pHash＋ファイルハッシュで重複防止。PIIマスキングと再試行制御を統一。 |
| **ING-OCR-IMAGE-002** | OCR画像解析 | ingest | Google Cloud Vision API を使用。信頼度70%未満は再解析。レシートに加えYouTube／音楽／ゲーム／学習スクショなども対象。 |
| **ING-SCREENSHOT-003** | スクリーンショット処理 | ingest | UI要素（ヘッダー・ナビゲーション）除去とレイアウト構造化。品質評価を自動＋手動で実施。 |
| **ING-YT-PIPE-004** | YouTubeデータ連携 | ingest | Data API v3でチャンネル・動画メタデータ取得。OAuth統合済みでライブ配信も検知。 |
| **共通機能** | - | - | 重複防止／PII自動マスキング／OCR信頼度閾値／再試行（タイムアウトのみ）／監査ログ保存。 |

#### 📦 OCR入力の対象範囲

OCR解析は「購買情報」だけでなく、日常行動の証跡となるスクリーンショット全般を対象とする。

| 種類 | 例 | 主な抽出項目 |
|------|----|--------------|
| 🧾 レシート／明細書 | スーパー・Amazon・PayPay | 店舗名、日付、金額、商品名 |
| 📺 YouTube視聴スクショ | 再生履歴・チャンネル画面 | 動画タイトル、チャンネル名、再生時間 |
| 🎵 音楽アプリ | Spotify・Apple Music | 曲名、アーティスト、再生時間 |
| 🎮 ゲームアプリ | Switch／Steam／PSN履歴 | ゲーム名、プレイ時間 |
| 📚 学習・記事スクショ | note／Kindle／Udemy等 | タイトル、著者、学習時間 |

#### 🔍 監査ログスキーマ（共通）

```sql
audit_ingest (
  id uuid PK,
  user_id uuid,
  source_type text, -- receipt/screenshot/youtube/music/game/learn
  result jsonb,
  duration_ms int,
  retries int,
  error text,
  created_at timestamptz
)
```

> **更新履歴:** 2025-11-07 ティム（COO/PM） — Day3 ingest仕様を source_of_truth に昇格し、OCR対象範囲を拡張。


### データ取り込み仕様群（Day3完了）

| 仕様ID | タイトル | ステータス | コード参照 | 最終更新 |
|--------|----------|------------|------------|----------|
| [ING-PIPE-CORE-001](features/__stubs__/ING-PIPE-CORE-001.spec.md) | Ingestパイプラインコア | source_of_truth | supabase/functions/ingest/index.ts#L1-L150 | 2025-11-07 |
| [ING-OCR-IMAGE-002](features/__stubs__/ING-OCR-IMAGE-002.spec.md) | OCR画像解析 | source_of_truth | supabase/functions/ocr/worker.ts#L1-L200 | 2025-11-07 |
| [ING-SCREENSHOT-003](features/__stubs__/ING-SCREENSHOT-003.spec.md) | スクリーンショット処理 | source_of_truth | lib/utils/phash.ts#L1-L80 | 2025-11-07 |
| [ING-YT-PIPE-004](features/__stubs__/ING-YT-PIPE-004.spec.md) | YouTubeデータ連携 | source_of_truth | supabase/functions/ingest/retry.ts#L1-L100 | 2025-11-07 |

### 主要機能
- **重複防止**: pHash + ファイルハッシュによる同一コンテンツ検知
- **PII保護**: 自動マスキング（メール・電話・住所）
- **OCR解析**: Google Cloud Vision API + 信頼度管理
- **監査ログ**: 全操作の `audit_ingest` テーブル追跡

### 統合アーキテクチャ
- **ingest_jobs**: 処理ジョブ管理
- **audit_ingest**: 操作監査ログ
- **60秒署名URL**: 購読者限定アクセス
- **3回再試行**: TIMEOUT時のみ指数バックオフ


- [ ] 新しい __stubs__ のリンクを各正仕様へ統合
- [ ] Status列に "draft" を明記
- [ ] 1週間以内に本仕様へ昇格予定とコメント

| [PAY-STR-WEBHOOK-003](features/__stubs__/PAY-STR-WEBHOOK-003.spec.md) | source_of_truth | supabase/functions/stripe/webhook/index.ts#L1-L220 | 2025-11-07 |
| [PAY-STR-CORE-001](features/__stubs__/PAY-STR-CORE-001.spec.md) | source_of_truth | lib/features/payment/stripe_checkout.dart#L1-L160 | 2025-11-07 |
| [PAY-STR-SUBS-002](features/__stubs__/PAY-STR-SUBS-002.spec.md) | source_of_truth | supabase/functions/stripe/webhook/index.ts#L1-L220 | 2025-11-07 |
| [SEC-RLS-CORE-001](features/__stubs__/SEC-RLS-CORE-001.spec.md) | source_of_truth | supabase/migrations/2025-rls.sql#L1-L400 | 2025-11-07 |
| [SEC-RLS-STORAGE-002](features/__stubs__/SEC-RLS-STORAGE-002.spec.md) | source_of_truth | supabase/policies/storage_policies.sql#L1-L100 | 2025-11-07 |
| [SEC-RLS-TEST-001](features/__stubs__/SEC-RLS-TEST-001.spec.md) | source_of_truth | tests/rls/rls_e2e.spec.ts#L1-L220 | 2025-11-07 |
| [PAY-POLICY-COMMON-001](features/__stubs__/PAY-POLICY-COMMON-001.spec.md) | source_of_truth | lib/features/payment/refund_policy.ts#L1-L50 | 2025-11-07 |


| [ING-PIPE-CORE-001](features/__stubs__/ING-PIPE-CORE-001.spec.md) | source_of_truth | supabase/functions/ingest/index.ts#L1-L150 | 2025-11-07 |
| [ING-OCR-IMAGE-002](features/__stubs__/ING-OCR-IMAGE-002.spec.md) | source_of_truth | supabase/functions/ocr/worker.ts#L1-L200 | 2025-11-07 |
| [ING-SCREENSHOT-003](features/__stubs__/ING-SCREENSHOT-003.spec.md) | source_of_truth | lib/utils/phash.ts#L1-L80 | 2025-11-07 |
| [ING-YT-PIPE-004](features/__stubs__/ING-YT-PIPE-004.spec.md) | source_of_truth | supabase/functions/ingest/retry.ts#L1-L100 | 2025-11-07 |

