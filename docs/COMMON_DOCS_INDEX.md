# Starlist 共通ドキュメント索引

Starlist 関連リポジトリ／プロジェクトに共通して参照したい資料を集約したインデックス。ChatGPT など外部ツールに概要を渡す際は、本ファイルとリンク先の要約を共有すると効率的です。

---

## 1. プロジェクト構成の俯瞰

| 区分 | 主な内容 | 代表ディレクトリ／参照ドキュメント |
| --- | --- | --- |
| フロントエンド | Flutter 製クライアントアプリ全般。画面・ウィジェット・状態管理・テーマ・マルチプラットフォームビルド。 | ディレクトリ: `lib/`, `android/`, `ios/`, `macos/`, `linux/`, `windows/`, `web/` / 主要資料: `docs/development/DEVELOPMENT_GUIDE.md`, `docs/design/site_specification/` |
| Web 実行補助 | Chrome 実行スクリプト、BrowserSync 設定、Codex 用ユーティリティなどローカル開発支援。 | ディレクトリ: `scripts/`, `run_chrome.sh`, `bs-config.js` / 補足: `scripts/README.md` |
| バックエンド | NestJS ベースの API／ジョブ処理・メディア変換・メトリクス収集。 | ディレクトリ: `server/src/`（`app.module.ts`, `ingest/`, `media/`, `metrics/` 等） / 主要資料: `docs/architecture/`, `docs/development/DEPLOYMENT_CHECKLIST.md` |
| Supabase | DB スキーマ、RLS ポリシー、エッジ関数。 | ディレクトリ: `supabase/migrations/`, `supabase/functions/` / 主要資料: `docs/api/PAYMENT_SYSTEM_INTEGRATION_STRATEGY.md`, `supabase_setup.sql` |
| データ連携・インポート | 外部サービスからの取り込み UI／解析／診断ロジック。 | ディレクトリ: `lib/src/features/data_integration/`, `lib/src/features/ingest/`, `lib/src/features/import_diagnose/` / 主要資料: `docs/reports/COMPLETE_FILE_MANAGEMENT_GUIDE.md`, `docs/planning/Starlist まとめ.md` |
| ビジネス・運用 | 事業計画、タスク管理、運用ガイドライン。 | ディレクトリ: `docs/business/`, `docs/planning/`, `docs/ops/`, `docs/tasks.md` |
| ドキュメント群 | 設計／運用／ビジネス資料。 | ディレクトリ: `docs/`（本ファイルを含む） |
| 旧資料 | 旧版ドキュメント／過去の成果物アーカイブ。 | ディレクトリ: `repository/` |

### 1.1 フロントエンド詳細
- **モジュール構成**: `lib/src/` に `features/`, `services/`, `providers/`, `core/` を配置。Riverpod ベースの状態管理と、`lib/widgets/` の UI コンポーネント群で構成。
- **ターゲット**: モバイル・デスクトップ・Web に対応。Web 開発は `scripts/c.sh` で Chrome をキャッシュクリア後に起動。
- **補足資料**: デザイン仕様は `docs/design/site_specification/`、ロゴ／アイコン管理は `docs/development/ICON_MANAGEMENT.md`。

### 1.2 バックエンド（NestJS）詳細
- **役割**: データ収集 (`server/src/ingest/`)、メディア処理 (`server/src/media/`)、ヘルスチェック (`server/src/health/`)、メトリクス提供 (`server/src/metrics/`) を担う。
- **構成**: エントリポイントは `server/src/main.ts`、モジュール定義は `server/src/app.module.ts`。`shared/` に共通ユーティリティ。
- **運用**: Stripe や Supabase の環境変数が前提。Docker 化は未整備だが、`docs/development/DEPLOYMENT_CHECKLIST.md` に手順。

### 1.3 Supabase 詳細
- **マイグレーション**: `supabase/migrations/` に時系列で SQL が配置（例: `20250101000000_create_base_tables.sql`, `20250716000002_user_security_2fa.sql`）。
- **エッジ関数**: `supabase/functions/sign-url/` が署名付き URL 発行、`supabase/functions/exchange/` がポイント交換などの処理を担当。
- **補足**: `supabase_setup.sql` で初期セットアップ、`docs/api/SUPABASE_RLS_REVIEW.md` に RLS 設計レビュー。

### 1.4 データ連携／インポート詳細
- **Flutter 側 UI**: `lib/src/features/data_integration/screens/` に各サービス用画面、`support_matrix.dart` で対応状況を管理。
- **データ処理**: `lib/src/features/ingest/` でアップロード／解析、`lib/src/features/import_diagnose/` で診断フロー。
- **補足資料**: `docs/reports/COMPLETE_FILE_MANAGEMENT_GUIDE.md` にファイル連携の全体像、旧資料 `docs/planning/Starlist まとめ.md` に要件記録。

### 1.5 ビジネス／運用ドキュメント詳細
- **計画／タスク**: `docs/planning/Task.md`, `docs/planning/starlist_planning.md`, `docs/tasks.md`。
- **ビジネス戦略**: `docs/business/` にポジショニング、マネタイズ、リスク分析など。
- **運用レポート**: `docs/reports/`（例: `STARLIST_DEVELOPMENT_SUMMARY.md`, `MIGRATION_REPORT.md`）や `docs/ops/` の運用手順。
- **ドキュメント共有運用**: Supabase Storage `doc-share` の手順は `docs/ops/supabase_byo_auth.md` の最後を参照。
- **相関フロー（Mermaid）**: `docs/Mermaid.md` に主要ドキュメントの関係図（Mermaid）がある。

---

## 2. チーム共通で押さえるべきドキュメント

- `../README.md` … リポジトリ全体の概要とセットアップ要約。
- `docs/README.md` … ドキュメント全体のフォルダ構成と利用ルール。
- `docs/STARLIST_OVERVIEW.md` … プロジェクト全体像のサマリー。
- `docs/COMPANY_SETUP_GUIDE.md` … アカウント発行・開発環境セットアップ手順。
- `docs/development/DEVELOPMENT_GUIDE.md` … 開発環境構築と作業手順。
- `docs/planning/Task.md` … 進行中のタスク一覧。
- `docs/architecture/starlist_architecture_documentation.md.docx` … システム構成図と技術スタック（バイナリだが主要情報を保持）。
- `docs/features/payment_current_state.md` … 現行の決済実装まとめ。
- `docs/api/PAYMENT_SYSTEM_INTEGRATION_STRATEGY.md` … 決済連携の設計方針・DB スキーマ案。
- `docs/design/site_specification/` … 画面仕様とコンポーネント指針。
- `docs/legal/` 配下 … 利用規約・プライバシーポリシーなど外部公開文書。

（必要に応じて新しい資料を追加し、このリストを更新してください。）

---

## 3. ChatGPT 等へ共有する際の手順

1. **必要最小限の資料を抜粋**  
   - 本ファイルと、関連セクションのサマリー（例：決済なら `docs/features/payment_current_state.md` と `docs/api/PAYMENT_SYSTEM_INTEGRATION_STRATEGY.md`）を提示。
2. **大容量対策**  
   - ファイルが多い場合は ZIP でまとめたうえでアップロード／共有し、参照してほしいパスを添える。
   - もしくは要約ノートを先に作成し、詳細が必要になったタイミングで個別ファイルを提供。
3. **コンテキストの順序整理**  
   - リクエスト前に「プロジェクト概要 → 目的 → 該当ドキュメント抜粋 → 質問」の順で情報を渡すと、モデルが迷わず理解しやすい。

---

## 4. ドキュメント運用ルール（共通）

1. **更新責任**  
   - 機能を追加／変更した際は、関連するドキュメントを必ず更新し、本インデックスにも追記する。
2. **バージョン管理**  
   - ドキュメントの変更はコードと同じブランチ／PR でレビューを受ける。
3. **履歴整理**  
   - 廃止した資料は `repository/` などアーカイブフォルダに移動し、現行版との混在を避ける。
4. **タグ・検索性**  
   - 冒頭に目的や最終更新日を入れ、目次やリンクで相互参照しやすくする。

---

## 5. 今後の追加候補

- プロジェクト別サマリー（モバイル/サーバー/データパイプラインなど）の 1 ページ化。
- API／データモデルの ER 図・シーケンス図を画像＋テキストで併記。
- 開発者オンボーディング用のチェックリスト更新。

必要な情報が不足している場合はこのファイルまたは `docs/README.md` を更新し、各チームに共有してください。
