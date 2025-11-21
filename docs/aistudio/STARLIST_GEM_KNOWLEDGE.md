# STARLIST Project Knowledge Base for Gemini Gems
Generated on: 2025-11-21 16:00:13

> This document is a consolidated knowledge base for the Starlist project. Use this as the primary source of truth for the Starlist Custom Gem.

## 1. Project Overview
**Source:** `docs/overview/STARLIST_OVERVIEW.md`
**Description:** Vision, Mission, and Core Features

```markdown
---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



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

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。

```

---

## 2. Development Rules & Guidelines
**Source:** `docs/development/starlist-rules.md`
**Description:** Coding standards, commit rules, and best practices

```markdown
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


\# Starlist 開発ルール

あなたはFlutter、Dart、Supabase、クリーンアーキテクチャに精通した開発エキスパートです。Starlistアプリの開発において以下のルールとガイドラインに従ってください。

\## コードスタイルと構造

\- シンプルで読みやすい Flutter/Dart コードを書くこと

\- 関数型プログラミングとイミュータブルなデータ構造を優先する

\- コードの重複を避け、モジュール化と再利用を促進する

\- 説明的な変数名を使用し、補助動詞を含める（例：isLoading, hasError）

\- ファイル構成:
エクスポートされたコンポーネント、サブコンポーネント、ヘルパー、静的コンテンツ、型定義の順

\## 命名規則

\- ディレクトリ: 小文字とハイフンを使用（例：components/auth-wizard）

\- コンポーネント: 名前付きエクスポートを優先

\## Dartの使用法

\- すべてのコードにDartを使用; インターフェースを型定義に優先

\- enumの代わりにmapを使用

\- 型付きの関数コンポーネントを使用

\## 構文とフォーマット

\- 純粋な関数には \"function\" キーワードを使用

\- 条件文では不要な波括弧を避ける;
シンプルなステートメントには簡潔な構文を使用

\- 宣言的なDartコードを書く

\## UIとスタイリング

\- Flutter の Material/Cupertino ウィジェットをベースにしたデザイン

\- レスポンシブデザインのためのFlexible/Expandedウィジェット活用;
モバイルファーストアプローチ

\- ThemeData を用いた一貫したスタイリング

\## パフォーマンス最適化

\- \'use client\' ディレクティブとステート操作を最小化; Riverpodを活用

\- StatefulWidget はできるだけ小さく保ち、StatelessWidget を優先

\- 非重要コンポーネントには遅延ロードを使用

\- 画像最適化: キャッシュの活用、サイズデータの指定、遅延ロード実装

\## 主要規約

\- Flutter Riverpod を状態管理に使用

\- Web Vitalsの最適化（LCP, CLS, FID）

\- StatefulWidget の使用を制限:

\- サーバーコンポーネントとSupabaseの機能を優先

\- Widgetのライフサイクルが必要な場合のみ使用

\- データ取得や状態管理にはRiverpodを活用

\## データ参照・操作規則

\- Planningファイルを参照して、プロジェクトの全体計画と方針を把握

\-
Taskファイルを参照して、現在のプロジェクト状況と優先すべきタスクを理解

\- スター/ファンデータの更新は、対応するRepositoryクラス経由で行う

\- ユーザーデータの更新時は、状態を適切に反映させる

\## タスク管理と自動更新

\- Taskファイルのタスク状態を更新する場合は、以下の規則を遵守:

\- タスク完了時: 「\[ \]」を「\[x\]」に変更し、状態を「✅ 完了」に更新

\- タスク開始時: 状態を「🔄 進行中」に更新

\- タスク延期時: 状態を「⏸️ 保留中」に更新

\- 次のスプリントに移動: 状態を「🔜 次のスプリント」に更新

\## 設計パターン

\- リポジトリパターン: データアクセスの抽象化

\- サービスパターン: ビジネスロジックのカプセル化

\- プロバイダーパターン: 依存性の注入と状態管理

\- アダプターパターン: 外部APIとの互換性確保

\## Supabase連携ガイドライン

\- 直接SQLクエリよりもSupabaseクライアントAPIを優先

\- RLSポリシーを活用したデータセキュリティの実装

\- バッチ処理にはトランザクションを使用

\- 可能な限りサーバー側の関数で処理を行う

\## テスト戦略

\- ユニットテスト: 個々の関数とサービス

\- ウィジェットテスト: UIコンポーネント

\- 統合テスト: 複数コンポーネント間の相互作用

\- モックとスタブを活用してテストの分離性を確保

\## ドキュメント

\- 複雑なロジックには簡潔なコメントを追加

\- APIインターフェイスには適切なドキュメントを提供

\- README.mdを最新に保ち、セットアップ手順を明確に記述

\## 実装・検証ワークフロー

\- 新しいコード実装後、以下のステップを必ず実行:

1\. コードレビュー:
自身でコードを再確認し、上記ルールに準拠しているか確認

2\. 静的解析: \`flutter analyze\` を実行してコード品質をチェック

3\. 実行テスト: 実装した機能を実機またはエミュレーターで実行して動作確認

4\. ホットリロードの活用: 可能な場合は \`flutter run\`
中にホットリロードで迅速に変更を反映

5\. ユニットテスト: 関連するテストを実行し、機能の正確性を確認

\- どのような小さな変更でも、必ず実行テストを行う

\- UIの変更は異なる画面サイズで検証する

\-
パフォーマンス影響のある変更は、デバッグモードとリリースモードの両方で検証

\## 進捗報告

\- 実装完了後、Task.mdのステータスを更新

\- スクリプトを使用してタスク状態を更新:
\`./scripts/update_task_status.sh \"\<タスク名\>\" complete\`

\- 次に取り組むタスクをTask.mdの優先順位に基づいて選択

\## 実装完了時の自動実行

\- 重要: 全ての実装作業完了後、必ず以下のステップを実行すること:

1\. 実装が完了したら、コードの変更を要約

2\. run_terminal_cmdツールを使用してFlutterアプリを実行: \`cd
/Users/shochaso/starlist/starlist && flutter run\`

3\. 実行結果を共有

4\. 問題がなければタスクを完了としてマーク

\-
特に新しいUI要素やウィジェットを追加した場合は、必ず実行して視覚的に確認

\- エラーが発生した場合は修正してから再度実行

\- このステップは省略せず、全ての実装完了後に必ず実行すること

Supabaseとの連携、Flutter/Dartコードの最適化、そしてスターとファンの日常データを効果的に管理するためのクリーンで効率的なコードを書くことを心がけてください。

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。

```

---

## 3. Current Tasks & Status
**Source:** `docs/planning/Task.md`
**Description:** Active tasks and roadmap

```markdown
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


\# Starlist タスク管理

このファイルはStarlistプロジェクトの開発タスクを管理・追跡するために使用します。タスクは優先度と開発フェーズに基づいて整理されています。

\## 優先度レベル

\- \*\*P0\*\*: 緊急（即時対応が必要）

\- \*\*P1\*\*: 高（次回リリースに含める必要あり）

\- \*\*P2\*\*: 中（できれば次回リリースに含めたい）

\- \*\*P3\*\*: 低（将来のリリースで対応）

\## 状態

\- 🔄 進行中

\- ✅ 完了

\- 🔜 次のスプリント

\- 📅 スケジュール済み

\- ⏸️ 保留中

\## フェーズ1タスク（MVP）

\### 認証システム

\- \[x\] P1 🔄 ✅ 完了 ユーザー登録機能

\- \[x\] P1 🔄 ✅ 完了 ログイン機能

\- \[x\] P2 🔜 ✅ 完了 ソーシャルログイン連携

\- \[ \] P2 📅 アカウント管理画面の実装

\- \[ \] P2 📅 パスワードリセット機能

\### プロフィール管理

\- \[x\] P1 ✅ 基本プロフィール情報の設定 ✅ 完了

\- \[x\] P1 ✅ スター/ファン区分の実装 ✅ 完了

\- \[ \] P2 🔜 プロフィール画像アップロード

\- \[ \] P2 📅 プロフィール閲覧権限設定

\- \[ \] P3 📅 プロフィール編集履歴

\### データ連携

\- \[x\] P1 ✅ 完了 YouTube視聴履歴

\- \[x\] P1 ✅ 完了 Spotify再生履歴

\- \[x\] P2 ✅ 完了 Amazon購入履歴取込

\- \[x\] P2 ✅ 完了 Netflix視聴履歴連携

\- \[x\] P1 ✅ 完了 データインポート診断機能

\- \[ \] P1 📅 データ取り込みの精度UP

\- \[ \] P3 📅 スクリーンタイムデータ連携

\### UI/UX基本実装

\- \[x\] P1 🔄 ✅ 完了 アプリのテーマ設定

\- \[x\] P1 ✅ ナビゲーション構造の実装 ✅ 完了

\- \[x\] P1 🔜 ✅ 完了 基本リストビューの実装

\- \[ \] P2 📅 タイムライン表示の実装

\- \[ \] P2 📅 ダークモード対応

### 課金システム

- [x] P1 ✅ 完了 決済システム基盤
- [x] P1 ✅ 完了 サブスクリプション機能
- [x] P1 ✅ 完了 プレミアム機能実装
- [x] P2 ✅ 完了 ポイント購入機能
- [x] P2 ✅ 完了 収益分析ダッシュボード
- [ ] P2 📅 決済方法の追加（PayPal等）

### ガチャ機能

- [x] P2 ✅ 完了 ガチャシステム実装
- [x] P2 ✅ 完了 スターカードガチャ
- [x] P2 ✅ 完了 レアリティ管理
- [ ] P3 📅 ガチャバランス調整

### 検索・マイリスト機能

- [x] P1 ✅ 完了 スター検索機能
- [x] P1 ✅ 完了 コンテンツ検索機能
- [x] P1 ✅ 完了 フィルター機能
- [x] P2 ✅ 完了 マイリスト機能
- [ ] P2 📅 検索精度の向上

### 分析・管理機能

- [x] P1 ✅ 完了 分析ダッシュボード
- [x] P1 ✅ 完了 管理者機能（スター認証管理）
- [x] P2 ✅ 完了 ソーシャルリンク機能
- [x] P2 ✅ 完了 メンバーシップ管理
- [ ] P2 📅 高度な分析機能の追加

### 機能開発

- [ ] **新規スター登録・認証フローの実装**
  - [ ] **DBスキーマ設計**:
    - [ ] `users`テーブルに`verification_status`カラムを追加/更新 (`awaiting_terms_agreement`, `awaiting_ekyc`, `awaiting_parental_consent`, `awaiting_sns_verification`, `pending_review`, `approved`, `rejected`)
    - [ ] `parental_consents`テーブルを新規作成
    - [ ] Supabaseマイグレーションスクリプトの作成
  - [ ] **ステップA: 事務所利用規約への同意画面 (`TermsAgreementScreen`)**
    - [ ] UI/UX実装
    - [ ] 同意状態の永続化とステータス更新 (`awaiting_ekyc`)
    - [ ] Widgetテスト作成
  - [ ] **ステップB: eKYCによる本人・年齢確認 (`eKYCStartScreen`)**
    - [ ] サードパーティeKYCサービスのSDK連携
    - [ ] コールバックを受け取るAPIエンドポイント実装 (Supabase Edge Functions)
    - [ ] 年齢判定ロジック（18歳未満/以上）を実装
    - [ ] ステータス更新ロジック (`awaiting_sns_verification` or `awaiting_parental_consent`)
    - [ ] ユニットテスト/統合テスト作成
  - [ ] **ステップC: 親権者同意フロー (`ParentalConsentScreen`)**
    - [ ] UI/UX実装（情報入力、同意書DL、画像アップロード）
    - [ ] 同意書アップロード処理 (Supabase Storage)
    - [ ] 親権者情報をDBに保存するAPI実装
    - [ ] ステータス更新ロジック (`awaiting_sns_verification`)
    - [ ] Widgetテスト作成
  - [ ] **ステップD: SNSアカウント所有権確認**
    - [ ] 既存のSNS連携機能を認証フローに統合
    - [ ] 所有権確認ロジック（ユニークコード埋め込み等）を実装
    - [ ] ステータス更新ロジック (`pending_review`)
    - [ ] 統合テスト作成
  - [ ] **運営向け承認管理画面の強化**
    - [ ] 申請者情報（eKYC結果、年齢、親権者同意書など）の一元表示
    - [ ] 承認(`approved`) / 拒否(`rejected`)の実行機能
    - [ ] 変更後のステータスをDBに反映
  - [ ] **認証フロー全体の制御**
    - [ ] `verification_status`が`approved`になるまで機能制限をかけるロジックを実装

- [ ] **UI/UX改善**

\## フェーズ2タスク

\### OCR機能

\- \[ \] P1 📅 レシート読み取り機能

\- \[ \] P1 📅 商品情報の抽出ロジック

\- \[ \] P2 📅 重複検出アルゴリズム

\- \[ \] P2 📅 OCR精度改善

\- \[ \] P3 📅 プライバシー考慮機能

\### プライバシー設定

\- \[ \] P1 📅 項目別公開設定

\- \[ \] P1 📅 閲覧権限の細分化

\- \[ \] P2 📅 ブロック機能

\- \[ \] P2 📅 コンテンツフィルタリング

\- \[ \] P3 📅 自動プライバシー推奨設定

\## フェーズ3タスク

\### AI分析機能

\- \[ \] P1 🔄 進行中 AI秘書機能の実装（設計完了）
  - \[ \] Supabaseテーブル設計・マイグレーション
  - \[ \] Dartモデルクラス作成
  - \[ \] AIリポジトリ実装
  - \[ \] スター向けダッシュボードUI
  - \[ \] ファン向け推薦機能

\- \[ \] P1 📅 AIスケジューラーモデル（設計完了）
  - \[ \] 最適な投稿タイミング算出
  - \[ \] Google Calendar連携
  - \[ \] 自動リマインダー

\- \[ \] P1 📅 AIコンテンツアドバイザー（設計完了）
  - \[ \] トレンド検出機能
  - \[ \] コンテンツアイデア生成
  - \[ \] エンゲージメント予測

\- \[ \] P2 📅 AIデータブリッジ（設計完了）
  - \[ \] MCP連携
  - \[ \] 複数データソース統合

\- \[ \] P2 📅 感情分析機能

\- \[ \] P2 📅 コンテンツカテゴライズ自動化

\- \[ \] P3 📅 予測モデルの実装

\### インタラクション拡張

\- \[ \] P1 📅 コメント機能の高度化

\- \[ \] P1 📅 リアクションシステムの拡張

\- \[ \] P2 📅 有料提案システム

\- \[ \] P2 📅 イベント通知機能

\- \[ \] P3 📅 インタラクション分析ダッシュボード

\## 進捗追跡

\### 実装完了（2025年10月15日時点）

✅ **フェーズ1（MVP）完了**
\- 認証システム（ログイン、登録、SNS連携）
\- プロフィール管理（スター/ファン区分）
\- データ連携（YouTube, Spotify, Amazon, Netflix）
\- 基本UI/UX（テーマ、ナビゲーション、リストビュー）
\- 課金システム（決済、サブスクリプション、プレミアム）
\- ガチャ機能（スターカード、レアリティ管理）
\- 検索・マイリスト機能
\- 分析・管理機能

📊 **実装統計**
\- 実装機能: 23機能
\- 画面数: 114画面
\- プロバイダー数: 39
\- サービス数: 64

\### 現在のスプリント（2025/10/15-10/31）

🔄 **進行中**
\- AI秘書機能の実装開始
  - データベース設計
  - モデルクラス作成
  - リポジトリ実装

📅 **計画中**
\- AIスケジューラーモデルの実装
\- AIコンテンツアドバイザーの実装
\- データ取り込み精度の向上

\### 次回スプリント（2025/11/1-11/15）

\- AI機能のPoC完成
\- パフォーマンス最適化
\- ユーザーテスト実施
\- フィードバック収集と改善

\## 技術的負債＆リファクタリング予定

\- \[ \] P2 📅 状態管理ライブラリの統一

\- \[ \] P2 📅 エラーハンドリングの統一化

\- \[ \] P3 📅 非同期処理パターンの標準化

\- \[ \] P3 📅 UI層のコンポーネント分割

\- \[ \] P3 📅 テストカバレッジの向上

\## 参照

\- \[Planning.txr\](Planning.txr) - プロジェクトの全体計画

\- \[README.txr\](README.txr) - プロジェクト概要と要件定義

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。

```

---

## 4. Technical Architecture & Context
**Source:** `docs/aistudio/starlist_context.md`
**Description:** Technical details, models, and API signatures

```markdown
---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



## 1. ディレクトリ構成（概要）

```
lib/
└─ src/
   ├─ config/          # 環境変数ラッパー・プロバイダー定義
   ├─ core/            # 共通コンポーネント・テーマ・ルーティング
   ├─ data/            # 汎用モデルとリポジトリ
   ├─ features/        # 機能別モジュール（auth, ops, star, analytics 等）
   ├─ services/        # 共有サービス（telemetry, icon registry, parsers）
   ├─ providers/       # アプリ全体で共有する Riverpod プロバイダー
   └─ widgets/         # 汎用 UI

lib/features/          # 旧ディレクトリ（新旧 UI が混在）

assets/
├─ config/             # JSON 設定・サービスアイコンマップ
├─ icons/              # 共通アイコン（services/ サブディレクトリ含む）
├─ mockups/            # UI モック画像
└─ service_icons/      # 透過 PNG / SVG 群

supabase/
├─ functions/
│  ├─ exchange/        # Auth0 id_token → Supabase JWT 交換
│  ├─ ops-alert/       # 監視アラート集計/dryRun
│  ├─ ops-health/      # v_ops_5min + alert history の集約 API
│  ├─ ops-summary-email/ # 週次 OPS レポート生成
│  ├─ sign-url/        # Supabase Storage 署名 URL 発行
│  └─ telemetry/       # Flutter からの OPS メトリクス受付
└─ migrations/         # Postgres/RLS 定義

scripts/               # `run_chrome.sh`, seed スクリプト、CI 補助
server/src/            # NestJS (ingest, media, metrics, health)
docs/                  # プロジェクト仕様・運用・レポート
test/                  # Flutter/Dart テスト一式
```

---

## 2. モデル定義

### Star (lib/models/star.dart)
```dart
class Star {
  final String id;
  final String name;
  final List<String> platforms;
  final List<String> genres;
  final String rank;
  final int followers;
  final String imageUrl;
  final Map<String, GenreRating> genreRatings;
  final bool isVerified;
  final List<SocialAccount> socialAccounts;
  final String? description;
}

class GenreRating {
  final int level;
  final int points;
  final DateTime lastUpdated;
}

class SocialAccount {
  final String platform;
  final String username;
  final String url;
  final bool isVerified;
  final DateTime verifiedAt;
}
```

### User (lib/models/user.dart)
```dart
class User {
  final String id;
  final String name;
  final String email;
  final UserType type;        // star | fan
  final FanPlanType? fanPlanType; // free/light/standard/premium
  final String? profileImageUrl;
  final List<String>? platforms;
  final List<String>? genres;
  final DateTime createdAt;
}
```

### StarData ドメイン (lib/features/star_data/domain/star_data.dart)
```dart
class StarData {
  final String id;
  final StarDataCategory category;
  final String title;
  final String? description;
  final String serviceIcon;
  final Uri? url;
  final String? imageUrl;
  final DateTime createdAt;
  final StarDataVisibility visibility;
  final String? starComment;
  final Map<String, dynamic>? enrichedMetadata;
}

class StarProfile {
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final int? totalFollowers;
  final StarSnsLinks snsLinks;
}

class StarDataViewerAccess {
  final bool isLoggedIn;
  final bool canViewFollowersOnlyContent;
  final bool isOwner;
  final bool canToggleActions;
  final Map<StarDataCategory, int> categoryDigest;
}
```

### Ops Telemetry & Metrics (lib/src/features/ops/)
```dart
class OpsTelemetry {
  final String baseUrl;
  final String app;
  final String env;
  Future<bool> send({required String event, required bool ok, int? latencyMs, String? errCode, Map<String, dynamic>? extra});
}

class OpsMetric {
  final DateTime bucketStart;
  final String env;
  final String app;
  final String eventType;
  final int successCount;
  final int errorCount;
  final int? p95Ms;
}

class OpsKpiSummary {
  final int total;
  final int successCount;
  final int errorCount;
  final double errorRate;
  final int? latestP95Ms;
}

class OpsAlert {
  final String id;
  final String title;
  final String severity; // info | warning | critical
  final DateTime createdAt;
  final String description;
  final bool acknowledged;
}
```

### YouTube/Parsed Video Models
```dart
class YouTubeVideo {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final DateTime publishedAt;
  final String channelId;
  final String channelTitle;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final Duration duration;
}

/// OCR から抽出した動画（ParsedVideo相当）
class VideoData {
  final String title;
  final String channel;
  final String? duration;
  final String? viewedAt;
  final String? viewCount;
  final double confidence;
}
```

### ServiceIconRegistry (lib/services/service_icon_registry.dart)
```dart
class ServiceIconRegistry {
  static Future<void> init();
  static Map<String, String> get icons;
  static Widget iconFor(String key, {double size = 24, IconData? fallback});
  static Widget? iconForOrNull(String? key, {double size = 24});
  static String? pathFor(String key);
  static void clearCache();
  static Map<String, String> debugAutoMap();
}
```

---

## 3. Provider設計

### ops_metrics_provider (lib/src/features/ops/providers/ops_metrics_provider.dart)
- `OpsMetricsFilter` (`env`, `app`, `eventType`, `sinceMinutes`) を `StateNotifier` で管理。
- `opsMetricsSeriesProvider` = `AutoDisposeAsyncNotifier<List<OpsMetric>>`
  - 30秒ごとの `Timer` で `_scheduleRefresh()`
  - 重複フェッチ防止 (フィルタと最終ハッシュを比較、5秒ウィンドウ内はスキップ)
  - `manualRefresh()` で強制リフレッシュ
  - `OPS_MOCK` フラグでダミー系列を生成
- `opsRecentAlertsProvider` は Edge `ops-alert` を置き換えるまではモックリストを返却
- `opsMetricsAuthErrorProvider` (StateProvider<bool>) で 401/403 UI の赤枠制御

### current_user_provider (lib/providers/user_provider.dart)
- `UserInfoNotifier extends StateNotifier<UserInfo>`
  - `loadFromSupabase()` で `profiles` テーブルを fetch
  - `Supabase.instance.client.auth.onAuthStateChange` を監視し、ログアウト時は `state = UserInfo(...)` でクリア
  - 共有メソッド: `_initializeUserState()`, `_setLoggedOut()`

### supabaseClientProvider (lib/src/config/providers.dart)
```dart
final supabaseClientProvider = riverpod.Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);
```

### YouTubeHistoryNotifier (lib/providers/youtube_history_provider.dart)
- `StateNotifier<List<YouTubeHistoryItem>>`
- `addHistory(List<YouTubeHistoryItem>)` でセッションIDの自動付与・Supabase挿入
- `clearHistory`, `removeHistoryItem`, `removeHistoryGroup`, `getLatestHistory()`, `getGroupedHistory()`
- `YouTubeHistoryGroup` モデルで UI 集計

### Link Enricher Provider (planned / server counterpart)
- スマートレシート・OCR結果を `enrichItemsBasic()` で JAN/thumbnail を補完（NestJS `enrich.processor.ts`）
- Flutter では `link_enricher_provider` 調達予定：BullMQ キューへ投入し、結果を `media_items` からポーリングする設計（ドキュメント参照）

### Auth / External Providers
- `external_auth_provider.dart` wraps LINE/Auth0 flows before hitting `supabase/functions/exchange`.
- `theme_provider_enhanced.dart` (under `lib/src/providers/`) toggles light/dark and persists to `SharedPreferences`.

---

## 4. Edge Functions / API 契約

### telemetry (`POST /functions/v1/telemetry`)
```json
// Request
{
  "app": "starlist",
  "env": "prod",
  "event": "search.sla_missed",
  "ok": false,
  "latency_ms": 1200,
  "err_code": "timeout",
  "extra": { "query": "YOASOBI" }
}
// Response (201)
{ "ok": true }
```

### ops-alert (`GET|POST /functions/v1/ops-alert`)
```json
// Query: /ops-alert?dry_run=true&minutes=30
{
  "ok": true,
  "dryRun": true,
  "period_minutes": 30,
  "metrics": {
    "total": 420,
    "failures": 21,
    "failure_rate": "5.00",
    "p95_latency_ms": 780
  },
  "alerts": [
    {
      "type": "p95_latency",
      "message": "High p95 latency: 780ms",
      "value": 780,
      "threshold": 500
    }
  ]
}
```

### ops-health (`GET /functions/v1/ops-health?period=6h&app=flutter_web`)
```json
{
  "ok": true,
  "period": "6h",
  "aggregations": [
    {
      "app": "flutter_web",
      "env": "prod",
      "event": "search",
      "uptime_percent": 99.2,
      "mean_p95_ms": 640,
      "alert_count": 2,
      "alert_trend": "stable"
    }
  ]
}
```

### ops-summary-email (`POST /functions/v1/ops-summary-email`)
```json
// Request
{ "dryRun": true, "period": "7d" }
// Response
{
  "ok": true,
  "dryRun": true,
  "report_week": "2025-W45",
  "preview": "<!DOCTYPE html>...STARLIST OPS Weekly Summary...",
  "metrics": {
    "uptime_percent": 99.85,
    "mean_p95_ms": 420,
    "alert_count": 3,
    "alert_trend": "↑",
    "alert_change": 1
  }
}
```

### sign-url (`POST /functions/v1/sign-url`)
```json
// Request
{ "mode": "path", "path": "uploads/private/abc123.png", "expiresIn": 900 }
// Response
{ "url": "https://...signed", "ttl": 900 }
```

### exchange (`POST /functions/v1/exchange`)
```json
// Request
{ "id_token": "eyJhbGciOi..." }
// Response
{ "supabase_jwt": "eyJhbGciOiJIUzI1NiIs...", "expires_in": 600 }
```

---

## 5. 共通定数・環境変数

| Key | 用途 |
| --- | --- |
| `SUPABASE_URL` (.env / dart-define) | Supabase プロジェクト URL。Edge Functions でも使用。 |
| `SUPABASE_ANON_KEY` | Flutter クライアントの匿名キー。 |
| `SUPABASE_SECRET_KEY` | サーバー処理用。 |
| `YOUTUBE_API_KEY` | YouTube Data API 連携。 |
| `APP_ENV` | `development / staging / production` スイッチ。 |
| `ASSETS_CDN_ORIGIN` | 画像/CDN のベース URL。 |
| `BUCKET_PUBLIC_ICONS`, `BUCKET_PRIVATE_ORIGINALS` | Storage バケット識別。 |
| `SIGNED_URL_TTL_SECONDS` | 署名 URL の TTL。 |
| `APP_BUILD_VERSION` | ビルド番号表示に利用。 |
| `API_BASE` (`docAiApiBase`) | Document AI プロキシ。 |
| `FAILURE_RATE_THRESHOLD`, `P95_LATENCY_THRESHOLD` | Edge `ops-alert` の閾値。 |
| `CORS_ALLOW_*` | `exchange` 関数の CORS ポリシー。 |
| `AUTH0_DOMAIN`, `SUPABASE_JWT_SECRET` | Token 交換用。 |

---

## 6. UI階層構造

### StarlistMainScreen (lib/screens/starlist_main_screen.dart)
```
Scaffold
├─ Custom AppBar (gradient title, actions: gacha, notifications)
├─ Drawer (AnimatedSwitcher)
│   ├─ User banner (role badge)
│   ├─ Primary nav items (Home/Search/DataImport/Mylist/Profile)
│   ├─ Conditional Star block (Data Import, Dashboard, OPS Dashboard)
│   ├─ Conditional Fan block (Subscription, Star Points)
│   └─ Quick actions (Theme toggle, Login status)
└─ Body (tabbed)
    ├─ Tab 0: Home feed (YouTube history, posts, trending, ads)
    ├─ Tab 1: SearchScreen
    ├─ Tab 2: DataImportScreen
    ├─ Tab 3: MylistScreen
    └─ Tab 4: ProfileScreen
```

### StarDataViewPage (lib/features/star_data/presentation/star_data_view_page.dart)
```
Scaffold
└─ SafeArea
    └─ CustomScrollView
        ├─ Sliver: StarHeader (avatar, counts)
        ├─ Sliver: StarActionBar (Follow/Share/Report)
        ├─ Sliver: StarFilterBar (categories)
        ├─ Sliver: LinearProgressIndicator (when refreshing)
        ├─ StarDataGrid (cards: image, metadata, paywall guard)
        ├─ Sliver: CircularProgressIndicator (infinite scroll)
        └─ Sliver: Spacer
```

### OpsDashboardPage (lib/src/features/ops/pages/ops_dashboard_page.dart)
```
Scaffold
├─ AppBar ("OPS Dashboard", manual refresh icon)
└─ RefreshIndicator
    └─ ListView
        ├─ _FilterRow (env/app/event dropdowns + duration + refresh button)
        ├─ AutoRefreshIndicator (30s spinner)
        ├─ KPI Row (cards with Semantics + tooltips)
        ├─ MetricsCharts (LineChart for p95, stacked BarChart for success/error)
        ├─ AlertsCard (recent alerts list, fallback text)
        ├─ _EmptyState / _ErrorState (CTA buttons)
        └─ Loading skeleton cards
```

---

## 7. 主要関数シグネチャ

```dart
Future<bool> OpsTelemetry.send({
  required String event,
  required bool ok,
  int? latencyMs,
  String? errCode,
  Map<String, dynamic>? extra,
});

Future<void> OpsMetricsSeriesNotifier.manualRefresh();
Future<List<OpsMetric>> OpsMetricsSeriesNotifier._refreshWithFilter(
  OpsMetricsFilter filter, { bool force = false });

Future<StarDataPage> StarDataRepository.fetchStarData({
  required String username,
  StarDataCategory? category,
  String? cursor,
});

Future<void> YouTubeHistoryNotifier.addHistory(List<YouTubeHistoryItem> newItems);
void YouTubeHistoryNotifier.clearHistory();
List<YouTubeHistoryGroup> YouTubeHistoryNotifier.getGroupedHistory();

Future<void> UserInfoNotifier.loadFromSupabase();
void UserInfoNotifier.setUser(UserInfo user);
void UserInfoNotifier.clearUser();

Widget ServiceIconRegistry.iconFor(String key, {double size = 24, IconData? fallback});
Widget? ServiceIconRegistry.iconForOrNull(String? key, {double size = 24});

Future<Response> telemetry(req);          // Deno serve handler (Edge)
Future<Response> opsAlert(req);           // Aggregates metrics + thresholds
Future<Response> opsHealth(req);          // Authenticated uptime summary
Future<Response> opsSummaryEmail(req);    // Weekly HTML email generator
Future<Response> signUrl(req);            // Storage URL signer with ACL
Future<Response> exchange(req);           // Auth0 ⇨ Supabase JWT
```

---

## 8. ドメイン定義・文脈情報

- **Starlist とは**  
  README/STARLIST_OVERVIEW によると、スター（YouTuber/アーティスト/インフルエンサー）が日常の消費行動（視聴履歴、購買、音楽、SNS）を記録・共有し、ファンが閲覧・応援できる Web/Flutter プラットフォーム。  
  - 日常データ（コンテンツ/購入履歴）を軸に新しいマネタイズ手段を提供。  
  - ファンは階層型サブスクで限定コンテンツやコメント機能を利用。  
  - 監査イベント (`auth.*`, `rls.*`, `ops.subscription.*`) を Edge Telemetry に流し、ダッシュボード/レポートで可視化。

- **技術構成**  
  - **Frontend**: Flutter + Riverpod。Web/デスクトップ/モバイル共通。  
  - **Backend**: NestJS (`server/src`) で ingest/media/metrics jobs。  
  - **Supabase**: Postgres + RLS + Edge Functions (`exchange`, `sign-url`, `telemetry`, `ops-*`).  
  - **Cloud**: Cloud Run (DocAI proxy), Auth0/LINE (token exchange), Stripe (payments).  
  - **Monitoring**: OPS Dashboard (Day6) + Alert Automation (Day7) + Weekly Summary Email (Day9 roadmap).  

- **Docs 背景**  
  - `docs/docs/COMMON_DOCS_INDEX.md` … 全資料リンク。  
  - `docs/ops/OPS-TELEMETRY-SYNC-001.md` … Telemetry 仕様・監査イベント命名。  
  - `docs/reports/DAY6_SOT_DIFFS.md` / `DAY7_SOT_DIFFS.md` … OPS ダッシュボード/アラート実装記録。  
  - 将来: `OPS-SUMMARY-AUTOMATION-001.md` で週次レポート設計（Cron `ops-weekly-summary`, HTML email template, Flutter settings toggle）。

---

**Missing Sections**  
現時点で `link_enricher_provider` の Flutter 実装は未確認（NestJS enrich service のみ）。利用する場合は `server/src/ingest/services/enrich.service.ts` と BullMQ Processor を参照し、Flutter 側の Provider/API 契約を定義してください。

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。

```

---

## 5. Project Directory Structure
```

--- Directory: . ---
  artifacts/
  repository/
    starlist_updated_star_ranking.md
    starlist_market opportunities and growth strategies.md
    starlist customer journey map (Fan Registration).md
    starlist_positioning.md
    Starlist まとめ.md
    starlist_technical_requirements_plan.md
    starlist_risk_analysis.md
    starlist_target_analysis.md
    starlist_monetization_plan.md
    Starlist Customer Journey Map (Star Regisration).md
    Task.md
    starlist-rules.md
    starlist_planning.md
    starlist_architecture_documentation.md.docx
    starlist_README.md
  types/
    audit.ts
  macos/
    Podfile
    Podfile.lock
  app/
    layout.tsx
    page.tsx
    globals.css
  artifact_4544009766_dir/
    rls-audit-results.txt
  test/
    service_icon_registry_smoke_test.dart
    ranking_service_test.mocks.dart
    widget_test.dart
    ranking_service_test.dart
  bin/
    new.sh
    factory-run.sh
    finish.sh
  out/
    linear_error_20251112_004255.json
    linear_smoke_test3.log
    linear_smoke_test.log
    linear_smoke_test2.log
  dist/
    next-tsconfig.tsbuildinfo
  web/
    index.html
    favicon.png
    index.html.bak
    manifest.json
  tests/
    collector.download.spec.ts
    starlist_md_validator_test.py
    youtubeClient.spec.ts
    collector.spec.ts
    collector.normal.spec.ts
  server/
    package-lock.json
    package.json
    tsconfig.json
  release/
    freeze_window.json
  docs/
    environment_config.md
    COMPANY_SETUP_GUIDE.md
    README.md
    COPILOT_PROMPTS_DAY12.md
    starlist_guides_all.zip
    _cleanup_schedule.md
    star_subscription_requirements.md
    Mermaid.md
    auto-link-test.md
  ios/
    Podfile
    Podfile.lock
  schemas/
    audit_report.v2.schema.json
    audit_report.schema.json
  supabase/
  cloudrun/
  dashboard/
  logs/
    flutter.log
    browsersync.log
  guides/
    CHATGPT_SHARE_GUIDE.md
  linux/
    CMakeLists.txt
  examples/
  android/
    local.properties
    build.gradle.kts
    settings.gradle.kts
    gradle.properties
  scripts/
    setup.sh
    local-setup-test.sh
    c.sh
    starlist_md_validator.py
    task_completion_check.sh
    collect_phase2_1_evidence.sh
    watch_10min.sh
    verify_extended_security_checks.sh
    create-linear-issue.sh
    prompt_logger.dart
    run_web.sh
    gonogo_check.sh
    check_mail_dns.mjs
    generate_fake_audit_data.sh
    ensure-node20.js
    polyfill-file.js
    release_revert.sh
    generate_dora_metrics.sh
    dev.sh
    generate_gem_context.py
    extended_security_runner.sh
    verify_slsa_provenance.sh
    pricing_rollback.sh
    observe_phase3.sh
    extended_security_runner.sh.bak
    README.md
    lint-md-local.sh
    check_service_icon_manifest.dart
    smoke_test.sh
    run_chrome_dev.sh
    sync_docs_with_code.sh
    update_task_status.sh
    rls_audit.sql
    deploy.sh
    verify_supabase_env.sh
    log_codex_request.sh
    chaos_slack.sh
    pre-commit
    progress-report.sh
  lib/
    starlist_web_mockup.dart
    starlist_mockup.dart
    main.dart
  db/
  marketing/
    STAR_ACQUISITION_STRATEGY_1000.md
  build/
    5877c1ff9ba6867f813ab40cd2a0f8f0.cache.dill.track.dill
  windows/
    CMakeLists.txt
  assets/
  apps/
  src/
    openai-test.ts
  sql/
    pricing_reconcile.sql
    pricing_audit.sql

--- Directory: lib ---
lib/
  starlist_web_mockup.dart
  starlist_mockup.dart
  main.dart
  ui/
    app_text_field.dart
    app_card.dart
    app_button.dart
  core/
  config/
    environment_config.dart
    debug_flags.dart
    auth0_config.dart
    runtime_flags.dart
    ui_flags.dart
  phase4/
    retry.ts
    time.ts
  providers/
    posts_provider.dart
    current_user_provider.dart
    user_provider.dart
    music_history_provider.dart
    external_auth_provider.dart
    theme_provider.dart
    youtube_history_provider.dart
    supabase_client_provider.dart
  features/
  utils/
    key_normalizer.dart
    service_icon_debug.dart
    visibility_rules.dart
  models/
    star.dart
    activity.dart
    user.dart
    parental_consent.dart
    sns_verification.dart
  screens/
    test_account_switcher_screen.dart
    fan_mypage_screen.dart
    category_list_screen.dart
    login_status_screen.dart
    starlist_home_screen.dart
    starlist_main_screen.dart
    following_screen.dart
    style_guide_page.dart.bak
    fan_register_screen.dart
    register_screen.dart
    star_registration_screen.dart
    help_center_screen.dart
    star_data_view_page.dart
    login_screen.dart
    bootstrap_screen.dart
    star_data_page.dart
    category_screen.dart
    mypage_screen.dart
    star_teaser_screen.dart
    star_mypage_screen.dart
    dev_preview_page.dart
    star_home_screen.dart
    privacy_screen.dart
    search_screen.dart
    home_screen.dart
    landing_screen.dart
    star_detail_screen.dart
    test_account_switcher_screen.dart.backup
  theme/
    context_ext.dart
    tokens.dart
    app_theme.dart
    typography.dart
    app_theme_enhanced.dart
    color_schemes.dart
  data/
    mock_data.dart
    test_accounts_data.dart
  routes/
    app_routes.dart
  consts/
    debug_flags.dart
  services/
    sns_verification_service.dart.bak
    signed_url_client.dart
    access_control_service.dart
    youtube_ocr_parser.dart
    sns_verification_service.dart
    cdn_analytics.dart
    image_url_builder.dart
    ad_bridge.dart
    receipt_ocr_parser_web.dart
    receipt_ocr_parser.dart
    asset_image_index.dart
    service_icon_registry.dart
    parental_consent_service.dart
    receipt_ocr_parser_mobile.dart
    ekyc_service.dart.bak
  widgets/
    star_dashboard.dart
    star_content_management.dart
    signed_image.dart
    media_gate.dart
    horizontal_section.dart
    activity_card.dart
    icon_diag_hud.dart
    category_card.dart
    subscription_plan_card.dart
    star_card.dart
    star_fan_analytics.dart
    sample_image.dart
    service_icon.dart
    services_icon_gallery.dart
  src/
    app.dart

--- Directory: server ---
server/
  package-lock.json
  package.json
  tsconfig.json
  dist/
    main.js
    app.module.js
  src/
    main.ts
    app.module.ts

--- Directory: supabase ---
supabase/
  migrations/
    20250716000002_user_security_2fa.sql
    20251108_app_settings_pricing.sql
    20250716000000_add_profiles_rls_policy.sql
    20250715000001_create_reactions_system.sql
    DDL_slsa_runs.sql
    20251108_v_ops_notify_stats.sql
    20250101000000_create_base_tables.sql
    20251108_subscriptions_plan_price.sql
    20251107_ops_summary_email_logs.sql
    20250102000000_star_verification_system.sql
    20250622_premium_question_system.sql
    20250716000003_create_star_point_tables.sql
    20251108_ops_slack_notify_logs.sql
    20250104000000_add_tag_only_support.sql
    20260101_ops_security_rls.sql
    20251107_ops_alerts_history.sql
    20250622_voting_system.sql
    20230420000000_create_rankings.sql
    20250622_birthday_notification_system.sql
    20250622_super_chat_system.sql
    20250716000001_profiles_update_policy.sql
    20251107_ops_metrics.sql
    20250103000000_star_verification_final.sql
    20250402204743_starlist_schema.sql
    20251117_update_pricing_ranges.sql
    20251113_slsa_runs.sql
  functions/
    shared_test.ts
    shared_rate.ts
    shared.ts
  ops/
    slsa_runs_table.sql
    slsa_audit_metrics_table.sql

--- Directory: docs ---
docs/
  environment_config.md
  COMPANY_SETUP_GUIDE.md
  README.md
  COPILOT_PROMPTS_DAY12.md
  starlist_guides_all.zip
  _cleanup_schedule.md
  star_subscription_requirements.md
  Mermaid.md
  auto-link-test.md
  journal/
    daily_log.md
    ideas.md
    bugs.md
    tasks.md
  payments/
    STAR_VERIFICATION_PRICING_MATRIX.md
  security/
    SEC_HARDENING_ROADMAP.md
    RLS_AUDIT_REPORT.md
    oidc_rollout.md
    BRANCH_PROTECTION_VERIFICATION.md
    DOCKERFILE_NONROOT_GUIDE.md
    BRANCH_PROTECTION_SETUP.md
  auth/
    WEB_COOKIE_AUTH.md
    STAR_MANUAL_VERIFICATION.md
  development/
    DAY5_IMPLEMENTATION_GUIDE.md
    codex_request_history.md
    TROUBLESHOOTING.md
    Claude_code.md
    ICON_MANAGEMENT.md
    DOCS_STATUS_MANAGEMENT.md
    DOCS_STATUS_AUDIT_RULES.md
    GEMINI.md
    DEVELOPMENT_GUIDE.md
    starlist-rules.md
    HANAYAMA_MIZUKI_ACCOUNT.md
    CLAUDE.md
    DEPLOYMENT_CHECKLIST.md
  specs/
    STARLIST_FEATURE_MATRIX.md
  diagrams/
    seq-ops-flow.mmd
    er-overview.mmd
  features/
    payment_current_state.md
    search_repository_implementation.md
  planning/
    DAY12_CURSOR_PROMPTS.md
    STARLIST_未実装機能リスト.md
    Task.md
    DAY12_10X_EXPANSION_ROADMAP.md
    starlist_planning.md
  qa/
    AT_AUDIT_SUITE.md
  docs/
    COMMON_DOCS_INDEX.md
    COMPANY_SETUP_GUIDE.md
    CHATGPT_SHARE_GUIDE.md
    STARLIST_OVERVIEW.md
    Mermaid.md
  compliance/
    MAPPING.md
  architecture/
    IMPLEMENTED_FEATURES.md
    starlist_technical_requirements_plan.md
    starlist_architecture_documentation.md.docx
  ai/
  aistudio/
    starlist_context.md
  api/
    YOUTUBE_API_SETUP.md
  ops/
    TELEMETRY_HANDOFF.md
    PHASE3_IMPLEMENTATION_SUMMARY.md
    PHASE2_TEST_PLAN.md
    LINEAR_SMOKE_TROUBLESHOOTING.md
    PHASE1_IMPLEMENTATION_STATUS.md
    MD_CI_REPORT.md
    FINAL_POLISH_UI_CHECKLIST.md
    MARKDOWN_GOVERNANCE.md
    PLAYBOOK_MINI.md
    OPS-TELEMETRY-SYNC-001.md
    ROLLBACK_PROCEDURES.md
    FINAL_POLISH_UI_QA_CHECKSHEET.md
    LINEAR_TEMP_KEY_GUIDE.md
    FINAL_REPORT_TEMPLATE.md
    FINAL_COMPLETION_REPORT_TEMPLATE.md
    RUN_WORKFLOW_GUIDE.md
    PHASE3_QUICK_START.md
    PM_SLACK_REPORT_TEMPLATES.md
    MD_CHECKLIST.md
    UPDATE_LOG.md
    FUTURE_FEATURE_CANDIDATES.md
    SSOT_RULES.md
    STA9_COMPLETION_REPORT.md
    AUDIT_DOD.md
    SLSA_PROVENANCE_20X_IMPLEMENTATION_PLAN.md
    OPS-MONITORING-002.md
    DASHBOARD_AUDIT_KPI_TEMPLATE.md
    DASHBOARD_FINAL_CHECKLIST.md
    PHASE3_SETUP_COMMANDS.sh
    UI_ONLY_QUICK_FIX_MATRIX.md
    UI_ONLY_PM_ONEPAGER_V2_20251109.md
    OPS-MONITORING-V3-001.md
    RUN_WORKFLOW_GUIDE_EXTENDED_COMPLETE.md
    PHASE4_IMPLEMENTATION_SUMMARY.md
    AUDIT_SYSTEM_ENTERPRISE.md
    STA11_COMPLETION_CHECKLIST.md
    CI_RUNTIME_POLICY.md
    AUDIT_PROOF_SNAPSHOT_TEMPLATE.md
    RECOVERY_GUIDE.md
    DATA_RETENTION_POLICY.md
    GITLEAKS_EXCEPTIONS.md
    RG_GUARD_FALSE_POSITIVE_RECIPES.md
    GLOSSARY.md
    UI_ONLY_FAQ.md
    OPS_OVERVIEW_UPDATE_GUIDE.md
    LINEAR_API_KEY_SETUP.md
    FINAL_POLISH_UI_OPERATOR_GUIDE.md
    rotation.yaml
    CSP_TROUBLESHOOTING.md
    RISK_REGISTER.md
    PHASE3_RUNBOOK.md
    AUDIT_SYSTEM_SUMMARY.md
    POSTMORTEM_TEMPLATE.md
    supabase_byo_auth.md
    SECURITY_AUDIT_GUIDE.md
    UI_ONLY_CHECKLIST.md
    INCIDENT_RUNBOOK.md
    DATA_ABUSE_INCIDENT_RUNBOOK.md
    CI_REQUIRED_OPTIONAL_POLICY.md
    CSP_ENFORCE_OBSERVE.md
    NAMING_GUIDE.md
    PROJECT_SCHEDULE.md
    WORKFLOW_MODEL.md
    PHASE3_ENV_SETUP.md
    EXTERNAL_API_KEY_RUNBOOK.md
    UI_ONLY_FINAL_LANDING_ROUTE.md
    PROJECT_PROGRESS.md
    SLSA_PROVENANCE_VALIDATION_PLAYBOOK.md
    RELEASE_POLICY.md
    README.md
    UI_ONLY_PR_REVIEW_CHECKLIST.md
    CI_SEVERITY_RULES.md
    SOT_APPEND_RULES.md
    PHASE4_MICROTASKS.md
    DKIM_DMARC_RUNBOOK.md
    RACI_MATRIX.md
    PHASE4_KPI_README.md
    STA9_IMPLEMENTATION_REPORT.md
    LAUNCH_CHECKLIST.md
    OPS-SUMMARY-EMAIL-001.md
    DOCS_INDEX.md
    SLSA_SECURITY_CI_SCENARIO.md
    CSP_VERIFICATION_REPORT.md
    10X_FINAL_LANDING_MEGAPACK.md
    PHASE4_AUTO_AUDIT_SELF_HEALING_DESIGN.md
    IMPACT_ANALYSIS_REPORT.md
    UI_ONLY_QUICK_REFERENCE.md
    FINAL_SECURITY_REHARDENING_SOP.md
    OPS-ALERT-AUTOMATION-001.md
    LINK_CHECK_PLAYBOOK.md
    PRIORITY_MATRIX.md
    OPS-HEALTH-DASHBOARD-001.md
    UI_ONLY_EXECUTION_PLAYBOOK_V2.md
    FINAL_PM_REPORT_TEMPLATES.md
    PHASE2_1_TEST_EXECUTION_GUIDE.md
    FINAL_30X_COMPLETE.md
    PHASE4_WS06_WS10_IMPLEMENTATION_PLAN.md
    CSP_PRODUCTION_TROUBLESHOOTING.md
    QUICK_FIX_PRESETS.md
    OPS-MONITORING-001.md
    PHASE4_WS06_WS10_QUICK_START.md
    WEEKLY_ROUTINE_CHECKLIST.md
    PHASE2_1_VALIDATION_SUITE.md
    BRANCH_PROTECTION_VERIFICATION_CASES.md
    UI_ONLY_PM_ONEPAGER_TEMPLATE.md
    FINAL_POLISH_UI_ROLLUP_CHECKS.md
    SECURITY_DAILY_TICKETS.md
    SECURITY_RUNBOOK.md
    UI_ONLY_BRANCH_PROTECTION_TABLE.md
    NO_COMMAND_LANDING_GUIDE.md
    SECRETS_PRECHECK.md
    LOCAL_SETUP_GUIDE.md
    DISCUSSION_PENDING_LIST.md
    PHASE2_IMPLEMENTATION_SUMMARY.md
    SLSA_PROVENANCE_AUTOMATION_DESIGN.md
    UI_ONLY_AUDIT_JSON_SCHEMA.md
    UI_ONLY_SOT_EXAMPLES.md
    DASHBOARD_IMPLEMENTATION.md
    UI_ONLY_FINAL_LANDING_PACK.md
  legal/
    DATA_LICENSE_CHANGELOG.md
    Starlist プライバシーポリシー.md
    DATA_ANONYMIZATION_GUIDE.md
    DATA_LICENSE_AND_EXTERNAL_API_POLICY.md
    Starlist コミュニティガイドライン.md
    API_TERMS_OF_USE_DRAFT.md
    Starlist 利用規約.md
  overview/
    COMMON_DOCS_INDEX.md
    STARLIST_OVERVIEW.md
  pricing/
    RECOMMENDED_PRICING-001.md
    PRICING_FINAL_SHORTCUT_GUIDE.md
  future/
    STAR_AUTO_VERIFICATION_FUTURE.md
  reports/
    DAY9_SOT_DIFFS.md
    DAY5_FINAL_GATE_CHECK.md
    SECURITY-OBSERVATION.md
    DAY7_KICK_PREP.md
    DAY8_SOT_DIFFS.md
    DAY12_SOT_DIFFS.md
    ci-weekly.md
    AUDIT_REPORT_TEMPLATE.md
    DAY5_SOT_DIFFS.md
    DOCS_SYNC_WITH_CODE_COMPLETE.md
    STARLIST_DEVELOPMENT_SUMMARY.md
    OPS-SUMMARY-LOGS.md
    DAY11_BRANCHES_SUMMARY.md
    COMPLETE_FILE_MANAGEMENT_GUIDE.md
    DAY4_SOT_DIFFS.md
    STARLIST_DAY5_SUMMARY.md
    ROLLBACK_LOG_TEMPLATE.md
    _evidence_index.md
    PR_TEMPLATE_BASE.md
    WEEKLY_AUDIT_SUMMARY_TEMPLATE.md
    FLUTTER_COMPATIBILITY_CHECK.md
    DAY6_SOT_DIFFS.md
    DAY11_INTEGRATION_LOG.md
    DAY7_SOT_DIFFS.md
    AI_SECRETARY_POC_PLAN.md
    admin-bypass-audit.md
    PHASE3_AUDIT_SUMMARY.md
    provenance-manifest-schema.json
    _manifest.json
    REORGANIZATION_COMPLETE_REPORT.md
    DAY10_SOT_DIFFS.md
    FOLDER_STRUCTURE_EXPLANATION.md
    OBSIDIAN_SYNC_COMPLETE.md
    MIGRATION_REPORT.md
    IDEAL_PROJECT_STRUCTURE.md
    DAY11_SOT_DIFFS.md
  company/
    FOUNDING_MOTIVATION_STARLIST.md
    FOUNDING_MOTIVATION_JFC_SHORT.md
```
