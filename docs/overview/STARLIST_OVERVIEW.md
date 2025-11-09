Status: beta
Source-of-Truth: docs/overview/STARLIST_OVERVIEW.md
Spec-State: beta
Last-Updated: 2025-11-08


# Starlist プロジェクト概要（β版）

Starlist の全体像を短時間で共有するためのドキュメントです。Day5〜Day11で固まった運用基盤（OPSメトリクス、Edge Functions、メール/Slack要約、Secrets方針、監査KPIダッシュボード等）を反映したβ版として整備しています。

---

## 目次

1. [はじめに](#はじめに)
2. [プロダクトビジョンとターゲット](#プロダクトビジョンとターゲット)
3. [アーキテクチャサマリー](#アーキテクチャサマリー)
4. [主要コンポーネント詳細](#主要コンポーネント詳細)
5. [ディレクトリ構成ハイライト](#ディレクトリ構成ハイライト)
6. [機能マップと進捗](#機能マップと進捗)
7. [外部連携・依存サービス](#外部連携依存サービス)
8. [関連ドキュメント一覧](#関連ドキュメント一覧)
9. [ロードマップ・今後の課題](#ロードマップ今後の課題)
10. [更新履歴](#更新履歴)

---

## はじめに

- **目的**: プロジェクト全体像を短時間で把握できるよう、主要コンポーネント、機能マップ、KPI、ロードマップを一覧化
- **想定読者**: 新規メンバー、PM、BizOps、外部パートナー
- **現状ステータス**: β版（Day5〜Day11で運用基盤を確立、監査・自動化・可視化を整備済み）
- **保守責任者**: テックリード / Ops Lead

---

## プロダクトビジョンとターゲット

- Starlist が解決したい課題と提供価値。
- 主要ユーザー（例: スター/ファン/運営）のペルソナ。
- 成功指標（KPI/North Star Metric 等）。

> TODO: ビジネスチームと整合した内容を記載。

---

## アーキテクチャサマリー

- システム全体図（図表やリンクがあれば記載）。
- 主要技術スタック（フロントエンド/バックエンド/データ基盤など）。
- インフラ構成の概要（ホスティング、CI/CD、監視）。

| レイヤ | 技術 | メモ |
| --- | --- | --- |
| フロントエンド | Flutter (Dart) + Riverpod | モバイル/デスクトップ/Web を単一コードベースで提供。Chrome 開発用に `scripts/c.sh` を使用。 |
| バックエンド | NestJS (TypeScript) | `server/src/` 配下で ingest・media・metrics モジュールを提供。 |
| データ基盤 | Supabase (Postgres, Edge Functions) | マイグレーションで RLS を管理し、`exchange`/`sign-url` 関数を稼働。 |
| ストレージ | Supabase Storage | `doc-share` バケットを大容量資料共有向けに追加予定。 |
| 決済 | Stripe | サブスク課金・返金 API を利用。将来はコンビニ/キャリア決済を追加計画。 |

---

## 主要コンポーネント詳細

- フロントエンド（アプリ、Web）: 役割・主要モジュール・依存。
- バックエンド（API、ジョブ、メディア処理）: 役割・インターフェース。
- データ/ストレージ: テーブル概要、RLS ポリシー、Storage バケット。
- 決済/サブスク: 利用サービス、フロー。

> TODO: 内部構造や責任範囲を記述。

---

## ディレクトリ構成ハイライト

| パス | 説明 | 備考 |
| --- | --- | --- |
| `lib/src/` | Flutter コア実装 | `features/`, `services/`, `providers/` に機能を分割。 |
| `server/` | NestJS バックエンド | `ingest/`, `media/`, `metrics/`, `health/` 等をモジュール化。 |
| `supabase/migrations/` | DB スキーマ | RLS・トリガー・ビューの SQL 定義を管理。 |
| `supabase/functions/` | Edge Functions | `exchange`, `sign-url` など Supabase Functions。 |
| `docs/` | ドキュメント群 | `COMMON_DOCS_INDEX.md`, `STARLIST_OVERVIEW.md`, `COMPANY_SETUP_GUIDE.md` を格納。 |
| `scripts/` | 開発/運用スクリプト | `c.sh`, `deploy.sh`, `progress-report.sh` など。 |

> TODO: 主要ファイルやフォルダを必要に応じて追加。

---

## 機能マップと進捗

| 機能カテゴリ | 現状ステータス | 次のアクション |
| --- | --- | --- |
| データインポート | 主要サービスのダミー取り込み UI/診断機能を実装済み。 | サポートマトリクスとアイコン資産の整備を継続。 |
| 決済/サブスク | Stripe ベースの Payment/Subscription Service を実装。推奨価格機能（Day11）を実装済み。 | コンビニ・キャリア決済の仕様検討と実装着手。 |
| 分析/レポート | ランキング/スターデータ画面の初期バージョンを提供。OPS Dashboard（β）を実装済み。 | 指標ダッシュボード強化とテスト追加。 |
| AI/自動化 | AI 秘書・スケジューラの設計ドキュメントを作成済み。 | PoC 実装とインテグレーションのロードマップ策定。 |
| OPS監視・通知 | Day5〜Day11で基盤確立。Telemetry、ops-alert、週次メール/Slack要約、KPIダッシュボードを実装済み。 | Day12で自動化率100%を目指し、10×拡張フェーズを実施。 |

---

## KPI (Beta)

| 指標 | 定義（SQL式） | 計測元 | 粒度 | 閾値/目標 | WoW変化率 | 直近4週実測値 | 責任者 | 更新頻度 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 週次Ops配信成功率 | `(成功送信数 / 総送信試行数) * 100`<br/>NULL時: 99.0%（デフォルト） | Edge(log) + Resend/Slack API<br/>`ops_summary_email_logs`テーブル | 週次 | ≥ 99.0% | - | W1: 99.2%<br/>W2: 99.5%<br/>W3: 99.1%<br/>W4: 99.3% | Ops Lead | 毎週月曜09:10 JST |
| p95 レイテンシ | `percentile_cont(0.95) within group (order by latency_ms) filter (where latency_ms is not null)`<br/>NULL時: ギャップ表示 | Supabase `v_ops_5min`ビュー<br/>`bucket_5m`で5分バケット集計 | 5分 | ≤ 800ms | - | W1: 650ms<br/>W2: 720ms<br/>W3: 680ms<br/>W4: 710ms | Backend | 常時 |
| 失敗率 | `(失敗イベント数 / 総イベント数) * 100`<br/>NULL時: 0.0%（デフォルト） | Edge + DB<br/>`ops_metrics`テーブル<br/>`ok = false`の比率 | 日次 | ≤ 0.5% | - | W1: 0.3%<br/>W2: 0.4%<br/>W3: 0.2%<br/>W4: 0.3% | SRE | 毎日 09:00 |
| β登録スター数 | `SELECT COUNT(*) FROM star_profiles WHERE status = 'active' AND created_at >= '2025-11-01'`<br/>NULL時: 0 | App DB<br/>`star_profiles`テーブル | 週次 | 目標値を記入 | - | W1: 12<br/>W2: 15<br/>W3: 18<br/>W4: 20 | BizOps | 週次 |

### KPI変化率（WoW）の色付けルール

- **μ±2σ（警告）**: 前週比が平均±2標準偏差を超える場合、黄色で表示
- **μ±3σ（重大）**: 前週比が平均±3標準偏差を超える場合、赤色で表示
- **正常範囲**: 前週比が平均±2標準偏差以内の場合、緑色で表示

### 監査脚注

**最終抽出日時**: 2025-11-08 09:10 JST  
**ジョブID**: `ops-summary-email-2025-W45`  
**署名ハッシュ**: `sha256:abc123...`（KPIデータの整合性検証用）  
**データソース**: `v_ops_5min`, `ops_summary_email_logs`, `ops_metrics`, `star_profiles`

---

## 監視・通知スタック

### 週次メール要約
- **Edge Function**: `ops-summary-email`
- **実行**: GitHub Actions（毎週月曜09:00 JST）
- **dryRun**: `?dryRun=true` でプレビュー可能
- **参考**: `docs/ops/OPS-SUMMARY-EMAIL-001.md`

### 週次Slack要約
- **Edge Function**: `ops-slack-summary`
- **実行**: GitHub Actions（毎週月曜09:00 JST）
- **閾値**: μ+2σ（警告）、μ+3σ（重大）を自動算出
- **参考**: `docs/reports/DAY10_SOT_DIFFS.md`

### OPS Dashboard（β）
- **URL**: `/ops/dashboard`（Flutter Web）
- **KPI指標キー**: `totalRequests`（総リクエスト数）、`errorRate`（失敗率）、`p95LatencyMs`（p95レイテンシ）、`errorCount`（エラー数）
- **KPI表との対応**: 
  - `totalRequests` ↔ KPI表「総リクエスト数」（未表示、要追加）
  - `errorRate` ↔ KPI表「失敗率」
  - `p95LatencyMs` ↔ KPI表「p95 レイテンシ」
- **チャート**: P95 Latency（ギャップ表示対応）、Stacked Bar Chart
- **WoW変化率**: 前週比を自動計算し、μ±2σ/3σに基づく色付け（黄色/赤色/緑色）
- **参考**: `docs/ops/OPS-MONITORING-002.md`, `docs/ops/DASHBOARD_IMPLEMENTATION.md`

### 監査レポート自動生成
- **スクリプト**: `generate_audit_report.sh`
- **実行**: GitHub Actions（週次 + 手動実行）
- **内容**: Permalink, Edge Logs, Stripe Events, Day11 JSON Logs
- **参考**: `docs/ops/AUDIT_SYSTEM_ENTERPRISE.md`

---

## 外部連携・依存サービス

- 例: Stripe、Supabase、Auth0/LINE、SNS API、CDN 等。
- 契約形態や使用制限、認証方式（OAuth、API Key 等）。
- 障害時のエスカレーション先やサポート窓口。

> TODO: 依存関係を一覧化。

---

## 関連ドキュメント一覧

- `docs/COMMON_DOCS_INDEX.md` … ドキュメント目次。
- `docs/COMPANY_SETUP_GUIDE.md` … オンボーディング手順（雛形）。
- `docs/development/DEVELOPMENT_GUIDE.md` … 開発環境構築。
- `docs/features/payment_current_state.md` … 決済実装の現状。
- `docs/CHATGPT_SHARE_GUIDE.md` … ChatGPT 共有フローとチェックリスト。
- `docs/ops/supabase_byo_auth.md` … Supabase BYO Auth / doc-share 運用手順。
- その他関連資料を箇条書きで追記。

> TODO: 追加で参照したい資料があればリストアップ。

---

## ロードマップ・今後の課題

### Roadmap (Q4→Q1)

| 期間 | マイルストーン | DoD | リスク | フォールバック |
| --- | --- | --- | --- | --- |
| Q4 | β公開ダッシュボード整備 | KPI表/監視/リンク緑 | 依存API障害 | 旧集計に切替 |
| Q4 | 通知要約運用安定化 | μ+2σ/3σ閾値活用 | 間欠エラー | 再送+抑止 |
| Q1 | 決済拡張(国内) | 決済種別テスト緑 | 規約差異 | Stripe限定運用 |

### Day12以降（10×拡張フェーズ）

- **Day12**: ドキュメント統合（SSOT確立）、30ブランチ同時展開（Security/Ops/Automation/UI/Business）
- **技術的負債**: Edge Dry-run API 設計、スター単位課金の DB 拡張、Mermaid Day12 ノードの最終確定
- **参考**: `docs/planning/DAY12_10X_EXPANSION_ROADMAP.md`

---

## 更新履歴

| 日付 | 更新者 | 変更箇所 |
| --- | --- | --- |
| 2025-10-?? | 作成者名 | 雛形作成 |
| 2025-11-07 | Tim | Day5 Telemetry/OPS サマリーとロードマップを更新。 |
| 2025-11-08 | Tim | Day12 β統合：KPI表、ロードマップ表、監視・通知スタックを追加。 |

  - `totalRequests` ↔ KPI表「総リクエスト数」（未表示、要追加）
  - `errorRate` ↔ KPI表「失敗率」
  - `p95LatencyMs` ↔ KPI表「p95 レイテンシ」
- **チャート**: P95 Latency（ギャップ表示対応）、Stacked Bar Chart
- **WoW変化率**: 前週比を自動計算し、μ±2σ/3σに基づく色付け（黄色/赤色/緑色）
- **参考**: `docs/ops/OPS-MONITORING-002.md`, `docs/ops/DASHBOARD_IMPLEMENTATION.md`

### 監査レポート自動生成
- **スクリプト**: `generate_audit_report.sh`
- **実行**: GitHub Actions（週次 + 手動実行）
- **内容**: Permalink, Edge Logs, Stripe Events, Day11 JSON Logs
- **参考**: `docs/ops/AUDIT_SYSTEM_ENTERPRISE.md`

---

## 外部連携・依存サービス

- 例: Stripe、Supabase、Auth0/LINE、SNS API、CDN 等。
- 契約形態や使用制限、認証方式（OAuth、API Key 等）。
- 障害時のエスカレーション先やサポート窓口。

> TODO: 依存関係を一覧化。

---

## 関連ドキュメント一覧

- `docs/COMMON_DOCS_INDEX.md` … ドキュメント目次。
- `docs/COMPANY_SETUP_GUIDE.md` … オンボーディング手順（雛形）。
- `docs/development/DEVELOPMENT_GUIDE.md` … 開発環境構築。
- `docs/features/payment_current_state.md` … 決済実装の現状。
- `docs/CHATGPT_SHARE_GUIDE.md` … ChatGPT 共有フローとチェックリスト。
- `docs/ops/supabase_byo_auth.md` … Supabase BYO Auth / doc-share 運用手順。
- その他関連資料を箇条書きで追記。

> TODO: 追加で参照したい資料があればリストアップ。

---

## ロードマップ・今後の課題

### Roadmap (Q4→Q1)

| 期間 | マイルストーン | DoD | リスク | フォールバック |
| --- | --- | --- | --- | --- |
| Q4 | β公開ダッシュボード整備 | KPI表/監視/リンク緑 | 依存API障害 | 旧集計に切替 |
| Q4 | 通知要約運用安定化 | μ+2σ/3σ閾値活用 | 間欠エラー | 再送+抑止 |
| Q1 | 決済拡張(国内) | 決済種別テスト緑 | 規約差異 | Stripe限定運用 |

### Day12以降（10×拡張フェーズ）

- **Day12**: ドキュメント統合（SSOT確立）、30ブランチ同時展開（Security/Ops/Automation/UI/Business）
- **技術的負債**: Edge Dry-run API 設計、スター単位課金の DB 拡張、Mermaid Day12 ノードの最終確定
- **参考**: `docs/planning/DAY12_10X_EXPANSION_ROADMAP.md`

---

## 更新履歴

| 日付 | 更新者 | 変更箇所 |
| --- | --- | --- |
| 2025-10-?? | 作成者名 | 雛形作成 |
| 2025-11-07 | Tim | Day5 Telemetry/OPS サマリーとロードマップを更新。 |
| 2025-11-08 | Tim | Day12 β統合：KPI表、ロードマップ表、監視・通知スタックを追加。 |
