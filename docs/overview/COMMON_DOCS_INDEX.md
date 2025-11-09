# Starlist 共通ドキュメント索引

Starlist 関連リポジトリ／プロジェクトに共通して参照したい資料を集約したインデックス。ChatGPT など外部ツールに概要を渡す際は、本ファイルとリンク先の要約を共有すると効率的です。

**Status**: beta  
**Last-Updated**: 2025-11-08

---

## 1. プロジェクト構成の俯瞰

| 区分 | 主な内容 | 代表ディレクトリ／参照ドキュメント |
| --- | --- | --- |
| フロントエンド | Flutter 製クライアントアプリ全般。画面・ウィジェット・状態管理・テーマ・マルチプラットフォームビルド。 | ディレクトリ: `lib/`, `android/`, `ios/`, `macos/`, `linux/`, `windows/`, `web/` / 主要資料: `docs/development/DEVELOPMENT_GUIDE.md`, `docs/features/design/` |
| Web 実行補助 | Chrome 実行スクリプト、BrowserSync 設定、Codex 用ユーティリティなどローカル開発支援。 | ディレクトリ: `scripts/`, `run_chrome.sh`, `bs-config.js` / 補足: `scripts/README.md` |
| バックエンド | NestJS ベースの API／ジョブ処理・メディア変換・メトリクス収集。 | ディレクトリ: `server/src/`（`app.module.ts`, `ingest/`, `media/`, `metrics/` 等） / 主要資料: `docs/architecture/`, `docs/development/DEPLOYMENT_CHECKLIST.md` |
| Supabase | DB スキーマ、RLS ポリシー、エッジ関数。 | ディレクトリ: `supabase/migrations/`, `supabase/functions/` / 主要資料: `docs/api/PAYMENT_SYSTEM_INTEGRATION_STRATEGY.md`, `supabase_setup.sql` |
| データ連携・インポート | 外部サービスからの取り込み UI／解析／診断ロジック。 | ディレクトリ: `lib/src/features/data_integration/`, `lib/src/features/ingest/`, `lib/src/features/import_diagnose/` / 主要資料: `docs/reports/COMPLETE_FILE_MANAGEMENT_GUIDE.md`, `docs/planning/Starlist まとめ.md` |
| ビジネス・運用 | 事業計画、タスク管理、運用ガイドライン。 | ディレクトリ: `guides/business/`, `docs/planning/`, `docs/ops/`, `docs/journal/tasks.md` |
| ドキュメント群 | 設計／運用／ビジネス資料。 | ディレクトリ: `docs/overview/`, `docs/features/`, `docs/architecture/`, `docs/development/`, `docs/ops/`, `docs/planning/`, `docs/reports/`, `guides/` |
| 旧資料 | 旧版ドキュメント／過去の成果物アーカイブ。 | ディレクトリ: `repository/` |

### 1.1 フロントエンド詳細
- **モジュール構成**: `lib/src/` に `features/`, `services/`, `providers/`, `core/` を配置。Riverpod ベースの状態管理と、`lib/widgets/` の UI コンポーネント群で構成。
- **ターゲット**: モバイル・デスクトップ・Web に対応。Web 開発は `scripts/c.sh` で Chrome をキャッシュクリア後に起動。
- **補足資料**: デザイン仕様は `docs/features/design/`、ロゴ／アイコン管理は `docs/development/ICON_MANAGEMENT.md`。

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
- **計画／タスク**: `docs/planning/Task.md`, `docs/planning/starlist_planning.md`, `docs/journal/tasks.md`。
- **ビジネス戦略**: `guides/business/` にポジショニング、マネタイズ、リスク分析など。
- **運用レポート**: `docs/reports/`（例: `STARLIST_DEVELOPMENT_SUMMARY.md`, `MIGRATION_REPORT.md`）や `docs/ops/` の運用手順。
- **ドキュメント共有運用**: Supabase Storage `doc-share` の手順は `docs/ops/supabase_byo_auth.md` の最後を参照。
- **相関フロー（Mermaid）**: `docs/Mermaid.md` に主要ドキュメントの関係図（Mermaid）がある。
- **監査イベント命名**: `auth.login.success/failure`, `auth.link.success`, `auth.reauth.triggered`, `auth.sync.dryrun`, `rls.access.denied`, `ops.subscription.price_selected/price_confirmed` の6系統で統一。

---

## 2. チーム共通で押さえるべきドキュメント

### 基本ドキュメント

- `../README.md` … リポジトリ全体の概要とセットアップ要約。
- `docs/README.md` … ドキュメント全体のフォルダ構成と利用ルール。
- `docs/overview/STARLIST_OVERVIEW.md` … プロジェクト全体像のサマリー（β版、KPI表・ロードマップ表含む）。
- `docs/COMPANY_SETUP_GUIDE.md` … アカウント発行・開発環境セットアップ手順（β版、Secrets運用SOP含む）。
- `docs/development/DEVELOPMENT_GUIDE.md` … 開発環境構築と作業手順。
- `docs/planning/Task.md` … 進行中のタスク一覧。

### 運用・監視（docs/ops/）

- `docs/ops/OPS-MONITORING-001.md` … 監視・テレメトリ正準。
- `docs/ops/OPS-MONITORING-002.md` … OPS Dashboard拡張（β）。
- `docs/ops/OPS-SUMMARY-EMAIL-001.md` … 週次メール要約。
- `docs/ops/LAUNCH_CHECKLIST.md` … 本番入りチェックリスト。
- `docs/ops/AUDIT_SYSTEM_ENTERPRISE.md` … 監査システム全体像。
- `docs/ops/DASHBOARD_IMPLEMENTATION.md` … KPIダッシュボード実装。

### レポート（docs/reports/）

- `docs/reports/STARLIST_DAY5_SUMMARY.md` … Day5 実装進行サマリー。
- `docs/reports/DAY10_SOT_DIFFS.md` … OPS Slack Notify（Day10）。
- `docs/reports/DAY11_INTEGRATION_LOG.md` … Day11統合ログ。
- `docs/reports/DAY12_SOT_DIFFS.md` … Day12ドキュメント統合差分。

### QA・テスト（docs/qa/）

- `docs/qa/AT_AUDIT_SUITE.md` … 受け入れテスト監査スイート。

### 機能・設計

- `docs/architecture/starlist_architecture_documentation.md.docx` … システム構成図と技術スタック（バイナリだが主要情報を保持）。
- `docs/features/payment_current_state.md` … 現行の決済実装まとめ。
- `docs/api/PAYMENT_SYSTEM_INTEGRATION_STRATEGY.md` … 決済連携の設計方針・DB スキーマ案。
- `docs/features/design/` … 画面仕様とコンポーネント指針。

### 法的文書

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
5. **情報設計の原則**  
   - 仕様は `docs/features/`、運用は `docs/ops/`、図は `docs/architecture/`、対外/読み物は `guides/` に配置する。その他のファイルはこの原則に従って整理する。

---

## 5. ER図・シーケンス図

### 5.1 保管場所と命名規則

**保管場所**: `docs/architecture/diagrams/`  
**命名規則**: `[type]_[name]_[version].{mermaid|png}`

- **ER図**: `er_starlist_v1.mermaid` / `er_starlist_v1.png`
- **シーケンス図**: `seq_auth_flow_v1.mermaid` / `seq_auth_flow_v1.png`
- **アーキテクチャ図**: `arch_system_overview_v1.mermaid` / `arch_system_overview_v1.png`

**形式**: Mermaid（推奨）またはPNG（静的画像）

### 5.2 図ファイル一覧

| 図の種類 | ファイル名 | 説明 | リンク |
| --- | --- | --- | --- |
| ER図 | `er_starlist_v1.mermaid` | データベーススキーマ全体図 | [ER図](architecture/diagrams/er_starlist_v1.mermaid) |
| シーケンス図（認証） | `seq_auth_flow_v1.mermaid` | OAuth認証フロー | [認証フロー](architecture/diagrams/seq_auth_flow_v1.mermaid) |
| シーケンス図（決済） | `seq_payment_flow_v1.mermaid` | Stripe決済フロー | [決済フロー](architecture/diagrams/seq_payment_flow_v1.mermaid) |
| アーキテクチャ図 | `arch_system_overview_v1.mermaid` | システム全体構成図 | [システム構成](architecture/diagrams/arch_system_overview_v1.mermaid) |

> **注意**: 図ファイルは`docs/architecture/diagrams/`に配置し、Mermaid形式を推奨します。

### 5.3 図内凡例（色/矢印/注釈）

#### ER図の凡例

- **テーブル**: 四角形（`[table_name]`）
- **リレーション**: 矢印（`-->` 一対多、`<-->` 多対多）
- **主キー**: 下線付き（`id`）
- **外部キー**: 点線矢印（`-.->`）

#### シーケンス図の凡例

- **アクター**: 四角形（`[Actor]`）
- **メッセージ**: 矢印（`-->` 同期、`-->>` 非同期）
- **ループ**: 四角形（`loop [condition]`）
- **条件分岐**: ダイヤモンド（`alt [condition]`）

#### アーキテクチャ図の凡例

- **コンポーネント**: 四角形（`[Component]`）
- **データフロー**: 矢印（`-->`）
- **外部サービス**: 楕円形（`(External)`）
- **データストア**: 円筒形（`[(Database)]`）

### 5.4 更新手順テンプレ（誰が・どこを・どう直す）

**誰が**: テックリード / アーキテクト  
**どこを**: `docs/architecture/diagrams/`配下の図ファイル  
**どう直す**:

1. **Mermaidファイルを編集**（`docs/architecture/diagrams/[type]_[name]_[version].mermaid`）
2. **プレビューで確認**（VS CodeのMermaid拡張、または`mermaid-cli`でPNG生成）
3. **COMMON_DOCS_INDEX.mdの図ファイル一覧を更新**（必要に応じて）
4. **変更をコミット**（`git add docs/architecture/diagrams/`）
5. **PR作成**（変更内容を説明）

**更新頻度**: スキーマ変更時、フロー変更時、新機能追加時

### 5.5 双方向リンク

- **Index → 図**: `COMMON_DOCS_INDEX.md`の「図ファイル一覧」から各図へリンク
- **図 → Index**: 各図ファイルの冒頭に`[← 索引に戻る](../overview/COMMON_DOCS_INDEX.md)`を追加

---

## 6. 今後の追加候補

- プロジェクト別サマリー（モバイル/サーバー/データパイプラインなど）の 1 ページ化。
- 開発者オンボーディング用のチェックリスト更新。

---

## 6. 用語統一（最小語彙表）

| 用語 | 正規表記 | 備考 |
| --- | --- | --- |
| OPS | OPS（大文字） | Operationsの略 |
| KPI | KPI（大文字） | Key Performance Indicator |
| Edge Function | Edge Function | Supabase Edge Functions |
| dryRun | dryRun | テスト実行モード |
| Secrets | Secrets | 機密情報（大文字S） |
| doc-share | doc-share | Supabase Storageバケット名 |

必要な情報が不足している場合はこのファイルまたは `docs/README.md` を更新し、各チームに共有してください。

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
5. **情報設計の原則**  
   - 仕様は `docs/features/`、運用は `docs/ops/`、図は `docs/architecture/`、対外/読み物は `guides/` に配置する。その他のファイルはこの原則に従って整理する。

---

## 5. ER図・シーケンス図

### 5.1 保管場所と命名規則

**保管場所**: `docs/architecture/diagrams/`  
**命名規則**: `[type]_[name]_[version].{mermaid|png}`

- **ER図**: `er_starlist_v1.mermaid` / `er_starlist_v1.png`
- **シーケンス図**: `seq_auth_flow_v1.mermaid` / `seq_auth_flow_v1.png`
- **アーキテクチャ図**: `arch_system_overview_v1.mermaid` / `arch_system_overview_v1.png`

**形式**: Mermaid（推奨）またはPNG（静的画像）

### 5.2 図ファイル一覧

| 図の種類 | ファイル名 | 説明 | リンク |
| --- | --- | --- | --- |
| ER図 | `er_starlist_v1.mermaid` | データベーススキーマ全体図 | [ER図](architecture/diagrams/er_starlist_v1.mermaid) |
| シーケンス図（認証） | `seq_auth_flow_v1.mermaid` | OAuth認証フロー | [認証フロー](architecture/diagrams/seq_auth_flow_v1.mermaid) |
| シーケンス図（決済） | `seq_payment_flow_v1.mermaid` | Stripe決済フロー | [決済フロー](architecture/diagrams/seq_payment_flow_v1.mermaid) |
| アーキテクチャ図 | `arch_system_overview_v1.mermaid` | システム全体構成図 | [システム構成](architecture/diagrams/arch_system_overview_v1.mermaid) |

> **注意**: 図ファイルは`docs/architecture/diagrams/`に配置し、Mermaid形式を推奨します。

### 5.3 図内凡例（色/矢印/注釈）

#### ER図の凡例

- **テーブル**: 四角形（`[table_name]`）
- **リレーション**: 矢印（`-->` 一対多、`<-->` 多対多）
- **主キー**: 下線付き（`id`）
- **外部キー**: 点線矢印（`-.->`）

#### シーケンス図の凡例

- **アクター**: 四角形（`[Actor]`）
- **メッセージ**: 矢印（`-->` 同期、`-->>` 非同期）
- **ループ**: 四角形（`loop [condition]`）
- **条件分岐**: ダイヤモンド（`alt [condition]`）

#### アーキテクチャ図の凡例

- **コンポーネント**: 四角形（`[Component]`）
- **データフロー**: 矢印（`-->`）
- **外部サービス**: 楕円形（`(External)`）
- **データストア**: 円筒形（`[(Database)]`）

### 5.4 更新手順テンプレ（誰が・どこを・どう直す）

**誰が**: テックリード / アーキテクト  
**どこを**: `docs/architecture/diagrams/`配下の図ファイル  
**どう直す**:

1. **Mermaidファイルを編集**（`docs/architecture/diagrams/[type]_[name]_[version].mermaid`）
2. **プレビューで確認**（VS CodeのMermaid拡張、または`mermaid-cli`でPNG生成）
3. **COMMON_DOCS_INDEX.mdの図ファイル一覧を更新**（必要に応じて）
4. **変更をコミット**（`git add docs/architecture/diagrams/`）
5. **PR作成**（変更内容を説明）

**更新頻度**: スキーマ変更時、フロー変更時、新機能追加時

### 5.5 双方向リンク

- **Index → 図**: `COMMON_DOCS_INDEX.md`の「図ファイル一覧」から各図へリンク
- **図 → Index**: 各図ファイルの冒頭に`[← 索引に戻る](../overview/COMMON_DOCS_INDEX.md)`を追加

---

## 6. 今後の追加候補

- プロジェクト別サマリー（モバイル/サーバー/データパイプラインなど）の 1 ページ化。
- 開発者オンボーディング用のチェックリスト更新。

---

## 6. 用語統一（最小語彙表）

| 用語 | 正規表記 | 備考 |
| --- | --- | --- |
| OPS | OPS（大文字） | Operationsの略 |
| KPI | KPI（大文字） | Key Performance Indicator |
| Edge Function | Edge Function | Supabase Edge Functions |
| dryRun | dryRun | テスト実行モード |
| Secrets | Secrets | 機密情報（大文字S） |
| doc-share | doc-share | Supabase Storageバケット名 |

必要な情報が不足している場合はこのファイルまたは `docs/README.md` を更新し、各チームに共有してください。
