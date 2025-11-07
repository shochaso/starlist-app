Status:: in-progress  
Source-of-Truth:: docs/reports/DAY5_SOT_DIFFS.md  
Spec-State:: 確定済み（実装履歴・CodeRefs）  
Last-Updated:: 2025-11-07  

# DAY5_SOT_DIFFS — Telemetry & Monitoring Sync Reality vs Spec

Status: in-progress  
Last-Updated: 2025-11-07  
Source-of-Truth: Flutter code (`lib/core/telemetry/**`, `lib/features/**`) + Edge Functions + DB migrations

| ID | 領域 | コードで確認できる挙動 | 仕様との差分 / 修正方針 | 参照ファイル |
| -- | --- | --- | --- | --- |
| T1 | Telemetry実装 | `searchTelemetryProvider`は`NoopSearchTelemetry`のみ。OPSイベント送信機能なし。 | OPS-TELEMETRY-SYNC-001で`ProdSearchTelemetry`と`OpsTelemetry`を実装し、Edge Function経由で`ops_metrics`に保存する計画を定義。 | `lib/core/telemetry/search_telemetry.dart`, `lib/features/search/providers/search_providers.dart` |
| T2 | Edge Function | `supabase/functions/telemetry/`は存在しない。 | Edge Function `telemetry`を新規作成し、Flutterからのイベントを受信→`ops_metrics`テーブルに挿入する実装を定義。 | `supabase/functions/telemetry/index.ts`（新規） |
| T3 | DBスキーマ | `ops_metrics`テーブルは未作成。 | `ops_metrics`テーブルを作成し、RLSポリシーを設定するマイグレーションを定義。 | `supabase/migrations/YYYYMMDDHHMMSS_create_ops_metrics.sql`（新規） |
| Q1 | E2E自動化 | E2Eテストは手動実行のみ。CI/CDにE2Eテストジョブなし。 | QA-E2E-AUTO-001でGitHub Actionsワークフロー（`.github/workflows/qa-e2e.yml`）を新規作成し、headless Chromeで自動実行する計画を定義。 | `.github/workflows/qa-e2e.yml`（新規） |
| M1 | OPSダッシュボード | OPSダッシュボード画面は未実装。リアルタイム監視機能なし。 | OPS-MONITORING-002でOPSダッシュボード画面（`lib/src/features/ops/dashboard_page.dart`）を実装し、主要KPIを可視化する計画を定義。 | `lib/src/features/ops/dashboard_page.dart`（新規） |
| M2 | アラート通知 | アラート通知機能なし。Slack/PagerDuty連携なし。 | OPS-MONITORING-002でアラートEdge Function（`supabase/functions/ops-alert/index.ts`）を実装し、Slack通知とPagerDuty連携を定義。 | `supabase/functions/ops-alert/index.ts`（新規） |

### OPS-TELEMETRY-SYNC-001
- Before: `searchTelemetryProvider`は`NoopSearchTelemetry`のみ。OPSイベント送信機能なし。Edge Function未実装。
- After : `ProdSearchTelemetry`と`OpsTelemetry`を実装し、Edge Function経由で`ops_metrics`に保存。サンプリング率制御とDry-runモードを実装。
- Reason: SoT = Flutter実装。現在はテレメトリ送信機能が未実装のため、実シンク化が必要。
- CodeRefs: `lib/core/telemetry/search_telemetry.dart`, `lib/features/search/providers/search_providers.dart`, `supabase/functions/telemetry/index.ts`（新規）
- Impact: 監査イベント命名統一（`auth.*`, `rls.*`, `ops.subscription.*`）に準拠した送信機能を追加し、OPS-MONITORING-002のダッシュボードと連携。

### QA-E2E-AUTO-001
- Before: E2Eテストは手動実行のみ。CI/CDにE2Eテストジョブなし。テレメトリイベント検証なし。
- After : GitHub ActionsでE2Eテストを自動実行。headless Chromeで主要フローを検証。テレメトリイベントを`ops_metrics`から検証。
- Reason: SoT = Flutter実装。現在は手動テストのみのため、CI/CD統合が必要。
- CodeRefs: `.github/workflows/qa-e2e.yml`（新規）, `integration_test/e2e_test.dart`（新規）, `scripts/verify-telemetry-events.js`（新規）
- Impact: E2Eテストの自動化により、PR作成時とmainブランチマージ時に自動検証が可能。失敗時のログとスクリーンショット自動保存。

### OPS-MONITORING-002
- Before: OPSダッシュボード画面なし。リアルタイム監視機能なし。アラート通知機能なし。
- After : OPSダッシュボード画面を実装し、主要KPIを可視化。アラートルールを設定し、Slack通知とPagerDuty連携を実現。
- Reason: SoT = Flutter実装。現在は監視機能が未実装のため、可視化とアラートが必要。
- CodeRefs: `lib/src/features/ops/dashboard_page.dart`（新規）, `lib/src/features/ops/providers/ops_metrics_provider.dart`（新規）, `supabase/functions/ops-alert/index.ts`（新規）
- Impact: 運用KPIを一元管理できる設計に昇格し、リアルタイム監視とアラート通知により運用効率が向上。

> OPEN QUESTIONS  
> - Cloudflare Analytics統合の優先度（Supabase Logsのみで十分か）  
> - PagerDuty連携の閾値設定（Sign-in Success Rate < 95%で十分か）  
> - テレメトリサンプリング率の最適値（10%で十分か、5%に下げるべきか）

---

## 2025-11-07: Day5 実装完了（DB → Edge → Flutter → CI）

- Spec: `docs/ops/OPS-TELEMETRY-SYNC-001.md`, `docs/features/day4/QA-E2E-AUTO-001.md`, `docs/ops/OPS-MONITORING-002.md`
- Status: planned → in-progress → aligned-with-Flutter（実装完了）
- Reason: Day5実装フェーズ完了。DBマイグレーション、Edge Functions、Flutter実装、CI統合を完了。
- CodeRefs:
  - **DB**: `supabase/migrations/20251107_ops_metrics.sql:L1-L60` - ops_metricsテーブル + v_ops_5minビュー作成、RLSポリシー設定
  - **Edge Telemetry**: `supabase/functions/telemetry/index.ts:L1-L70` - POST受信→DB挿入実装
  - **Edge Alert**: `supabase/functions/ops-alert/index.ts:L1-L80` - 失敗率/遅延閾値チェック（dryRun実装）
  - **Flutter OpsTelemetry**: `lib/src/features/ops/ops_telemetry.dart:L1-L80` - テレメトリ送信クライアント実装
  - **Flutter ProdSearchTelemetry**: `lib/core/telemetry/prod_search_telemetry.dart:L1-L35` - SearchTelemetry実装、サンプリング制御
  - **CI**: `.github/workflows/qa-e2e.yml:L1-L50` - テレメトリPOST/ops-alert dryRun検証
- Impact: 
  - ✅ ops_metricsテーブルでテレメトリデータを永続化可能に
  - ✅ Edge Functions経由でFlutter→DBのデータフロー確立
  - ✅ ProdSearchTelemetryでSLA超過/重複検出イベントを送信可能に
  - ✅ CIで自動E2E検証が可能に
  - ⏸️ UI Dashboardは未実装（次フェーズ）

### 実装詳細

#### DBマイグレーション (`20251107_ops_metrics.sql`)
- `ops_metrics`テーブル作成（id, ts_ingested, app, env, event, ok, latency_ms, err_code, extra）
- インデックス3本（ts_ingested, event+ts_ingested, ok+ts_ingested）
- RLSポリシー：authenticatedロールからのINSERT/SELECT許可
- `v_ops_5min`ビュー：5分バケット集計（total, avg_latency_ms, p95_latency_ms, failure_rate）

#### Edge Functions
- **telemetry**: POST受信→バリデーション→ops_metrics挿入→201返却
- **ops-alert**: 直近N分のデータ取得→失敗率/p95遅延計算→閾値チェック→dryRunログ出力

#### Flutter実装
- **OpsTelemetry**: HTTP POSTでEdge Functionに送信、環境別ファクトリ（prod/staging/dev）
- **ProdSearchTelemetry**: SearchTelemetry実装、SLA超過時100%サンプリング、重複検出時10%サンプリング

#### CI統合
- qa-e2e.yml作成：テレメトリPOST送信→ops-alert dryRun検証

