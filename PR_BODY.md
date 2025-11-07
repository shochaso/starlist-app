feat(ops): Day5 Telemetry/OPS 基盤 実装完了 + Dashboard 初版

## 概要

Day5の実装スコープを完了。Telemetry収集〜Opsアラート〜ダッシュボード可視化までを、DB/Edge/Flutter/CI/Docsで一貫整備。`STARLIST_FF_PROD_TELEMETRY=true` で本番相当のサンプリング収集を有効化。

## 変更点（ハイライト）

* **DB**
  * `supabase/migrations/20251107_ops_metrics.sql`
  * `ops_metrics` + `v_ops_5min`、RLSポリシー適用

* **Edge Functions**
  * `supabase/functions/telemetry/index.ts`（POST→DB挿入）
  * `supabase/functions/ops-alert/index.ts`（失敗率/遅延 閾値チェック・dryRun）

* **Flutter**
  * `lib/src/features/ops/ops_telemetry.dart`（送信クライアント）
  * `lib/core/telemetry/prod_search_telemetry.dart`（SearchTelemetry）
  * `lib/src/features/ops/models/ops_metrics_model.dart`
  * `lib/src/features/ops/providers/ops_metrics_provider.dart`
  * `lib/src/features/ops/screens/ops_dashboard_page.dart`（Auth/RLS/Subscription/Performanceの指標可視化）

* **CI**
  * `.github/workflows/qa-e2e.yml`（テレメトリPOST/ops-alert dryRunの自動検証）

* **Feature Flag**
  * `STARLIST_FF_PROD_TELEMETRY=true` でProdSearchTelemetryを有効化（`searchTelemetryProvider`で自動切替）

* **Docs**
  * `docs/ops/OPS-TELEMETRY-SYNC-001.md`（Status: aligned-with-Flutter）
  * `docs/reports/DAY5_SOT_DIFFS.md`（実装履歴・CodeRefs追記）

## 影響範囲 / 移行手順

* **DBマイグレーション（ローカル）**
  ```bash
  supabase db push   # or supabase migration up
  ```

* **Edge Functions デプロイ（ローカル）**
  ```bash
  supabase functions deploy telemetry
  supabase functions deploy ops-alert
  ```

* **Feature Flag**
  * 本番・ステージングで `STARLIST_FF_PROD_TELEMETRY=true` を設定（env）

## 動作確認（手順）

1. マイグ適用・Functionsデプロイ後、ローカルでアプリを起動
2. 画面遷移/検索等でTelemetryを発火させる
3. OPSダッシュボードで5分バケット表示・フィルタ（env/app/event）を確認
4. `ops-alert` dryRunの結果が一覧に反映されることを確認

## セキュリティ/RLS

* `ops_metrics` はRLS有効。適切なロールのみ参照可能。
* Flutterクライアントは既存トークンを利用、追加権限は不要。

## CI ステータス

* Docs Status Audit：🟢
* Docs Link Check：🟢
* QA E2E：🟢
* Lint：🟢（変更 81 files / エラーなし）

## スクリーンショット

* （ダッシュボードKPIカード、5分時系列、フィルタUIのキャプチャを貼付）

## リスク&ロールバック

* **リスク**：収集量の増加によるDB負荷
* **緩和**：サンプリング制御＋`v_ops_5min`で集計参照、Feature Flagで即OFF可能
* **ロールバック**：Functionsの前バージョンへ復帰／Flag OFF／前マイグにリストア（スナップショット運用）

## リリースノート（ドラフト）

* Telemetry/OPS基盤を導入。失敗率・p95応答・5分時系列の可視化、dryRunアラート検知を追加。Feature Flagで段階的に有効化可能。

## レビュワー / メタ

* Reviewer: @pm-tim
* Labels: `area:ops`, `type:feature`, `day5`
* Breakings: なし

