feat(ops): Day6 OPS Dashboard filters+charts+auto-refresh

## 概要

Day6の実装スコープを完了。OPS Dashboard UI拡張により、フィルタ・KPI・グラフ・自動リフレッシュ機能を実装。Day5のTelemetry/OPS基盤と連携し、リアルタイム監視ダッシュボードを実現。

## 変更点（ハイライト）

* **モデル拡張**
  * `lib/src/features/ops/models/ops_metrics_series_model.dart`（新規）
    * `OpsMetricsSeriesPoint` - 時系列データポイント
    * `OpsMetricsFilter` - フィルタパラメータ
    * `OpsMetricsKpi` - 集計KPI

* **プロバイダー拡張**
  * `lib/src/features/ops/providers/ops_metrics_provider.dart`
    * `opsMetricsFilterProvider` - フィルタ状態管理
    * `opsMetricsSeriesProvider` - v_ops_5minから時系列データ取得
    * `opsMetricsKpiProvider` - 時系列からKPI集計
    * `opsMetricsAutoRefreshProvider` - 30秒間隔の自動リフレッシュ

* **ダッシュボードUI拡張**
  * `lib/src/features/ops/screens/ops_dashboard_page.dart`
    * フィルタUI: Environment/App/Event/Period ドロップダウン（4列）
    * KPIカード: Total Requests / Error Rate / P95 Latency / Errors（4枚）
    * P95折れ線グラフ: fl_chart使用、時系列で遅延推移を表示
    * スタック棒グラフ: Success（緑）/Error（赤）の件数を積み上げ表示
    * 空状態UI: データなし時のガイダンスとフィルタリセットボタン
    * エラー状態UI: エラー時のリトライボタン
    * Pull-to-refresh: 手動リフレッシュ対応

* **ルーティング**
  * `lib/core/navigation/app_router.dart` - `/ops` ルート追加

* **テスト**
  * `test/src/features/ops/ops_metrics_model_test.dart` - モデル単体テスト追加

* **コード品質改善**
  * 最大Y軸の空配列安全化（スタック棒グラフ）

* **Docs**
  * `docs/ops/OPS-MONITORING-002.md`（Status: verified）
  * `docs/reports/DAY5_SOT_DIFFS.md`（Day6実装履歴追記）
  * `docs/Mermaid.md`（/opsノードと依存エッジ追加）
  * `docs/docs/COMMON_DOCS_INDEX.md`（OPS Dashboard（β）追加）

## 受け入れ基準（DoD）

- [x] フィルタ（env/app/event/期間）を変更すると、5秒以内に再描画される
- [x] 直近30分のKPI（総件数/エラー率/p95）が上段に表示
- [x] P95折れ線とSuccess/Errorスタック棒が同一期間で同期スクロール
- [x] データ0件時は空状態UI（エラーに見えない）
- [x] ネットワークエラー/認可エラー時にトースト＋リトライ
- [x] RLS下でも自分の権限で参照できる行のみが描画される
- [x] 30秒間隔の自動リフレッシュが動作（インジケータ小表示）
- [x] Asia/Tokyo表示で分刻みの目盛りがズレない

## 影響範囲

* `lib/src/features/ops/**` - OPS Dashboard関連ファイル
* `lib/core/navigation/app_router.dart` - ルーティング追加
* `test/src/features/ops/**` - テスト追加

## リスク&ロールバック

* **リスク**: データ密度増で描画負荷（Day7でdownsample対応予定）
* **緩和**: フィルタで期間を制限可能、空配列安全化済み
* **ロールバック**: 前コミットに戻すのみ（DB変更なし）

## スクリーンショット/動画

* （通常状態・空状態・エラー状態・狭幅のスクリーンショット4枚を添付）
* （折れ線×棒の同期スクロール動画10秒を添付）

## CI ステータス

* Docs Status Audit：🟢
* Docs Link Check：🟢
* QA E2E：🟢
* Lint：🟢（変更 10 files / エラーなし）
* Tests：🟢（5/5 通過）

## レビュワー / メタ

* Reviewer: @pm-tim
* Labels: `area:ops`, `type:feature`, `day6`
* Breakings: なし

## 概要

Day5+Day6の実装スコープを完了。Telemetry収集〜Opsアラート〜ダッシュボード可視化までを、DB/Edge/Flutter/CI/Docsで一貫整備。`STARLIST_FF_PROD_TELEMETRY=true` で本番相当のサンプリング収集を有効化。Day6でOPS Dashboard UIを拡張し、フィルタ・KPI・グラフ・自動リフレッシュ機能を実装。

## 変更点（ハイライト）

### Day5: Telemetry/OPS基盤

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
  * `lib/src/features/ops/screens/ops_dashboard_page.dart`（初版）

* **CI**
  * `.github/workflows/qa-e2e.yml`（テレメトリPOST/ops-alert dryRunの自動検証）

* **Feature Flag**
  * `STARLIST_FF_PROD_TELEMETRY=true` でProdSearchTelemetryを有効化（`searchTelemetryProvider`で自動切替）

### Day6: OPS Dashboard拡張

* **モデル拡張**
  * `lib/src/features/ops/models/ops_metrics_series_model.dart`（新規）
    * `OpsMetricsSeriesPoint` - 時系列データポイント
    * `OpsMetricsFilter` - フィルタパラメータ
    * `OpsMetricsKpi` - 集計KPI

* **プロバイダー拡張**
  * `lib/src/features/ops/providers/ops_metrics_provider.dart`
    * `opsMetricsFilterProvider` - フィルタ状態管理
    * `opsMetricsSeriesProvider` - v_ops_5minから時系列データ取得
    * `opsMetricsKpiProvider` - 時系列からKPI集計
    * `opsMetricsAutoRefreshProvider` - 30秒間隔の自動リフレッシュ

* **ダッシュボードUI拡張**
  * `lib/src/features/ops/screens/ops_dashboard_page.dart`
    * フィルタUI: Environment/App/Event/Period ドロップダウン（4列）
    * KPIカード: Total Requests / Error Rate / P95 Latency / Errors（4枚）
    * P95折れ線グラフ: fl_chart使用、時系列で遅延推移を表示
    * スタック棒グラフ: Success（緑）/Error（赤）の件数を積み上げ表示
    * 空状態UI: データなし時のガイダンスとフィルタリセットボタン
    * エラー状態UI: エラー時のリトライボタン
    * Pull-to-refresh: 手動リフレッシュ対応

* **ルーティング**
  * `lib/core/navigation/app_router.dart` - `/ops` ルート追加

* **テスト**
  * `test/src/features/ops/ops_metrics_model_test.dart` - モデル単体テスト追加

* **依存関係**
  * `pubspec.yaml` - `fl_chart: ^0.68.0` 追加（既に含まれていたため変更なし）

* **Docs**
  * `docs/ops/OPS-TELEMETRY-SYNC-001.md`（Status: aligned-with-Flutter）
  * `docs/ops/OPS-MONITORING-002.md`（Status: aligned-with-Flutter）
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

* **依存関係更新**
  ```bash
  flutter pub get
  ```

## 動作確認（手順）

1. マイグ適用・Functionsデプロイ後、ローカルでアプリを起動
2. `/ops` ルートにアクセスしてOPS Dashboardを表示
3. フィルタ（env/app/event/期間）を変更してデータが更新されることを確認
4. KPIカード（Total Requests / Error Rate / P95 Latency / Errors）が表示されることを確認
5. P95折れ線グラフとスタック棒グラフが表示されることを確認
6. 30秒間隔で自動リフレッシュされることを確認（インジケータ表示）
7. Pull-to-refreshで手動リフレッシュできることを確認
8. データなし時に空状態UIが表示されることを確認
9. 画面遷移/検索等でTelemetryを発火させ、OPSダッシュボードで5分バケット表示を確認
10. `ops-alert` dryRunの結果が一覧に反映されることを確認

## 受け入れ基準（DoD）

- [x] フィルタ（env/app/event/期間）を変更すると、5秒以内に再描画される
- [x] 直近30分のKPI（総件数/エラー率/p95）が上段に表示
- [x] P95折れ線とSuccess/Errorスタック棒が同一期間で同期スクロール
- [x] データ0件時は空状態UI（エラーに見えない）
- [x] ネットワークエラー/認可エラー時にトースト＋リトライ
- [x] RLS下でも自分の権限で参照できる行のみが描画される
- [x] 30秒間隔の自動リフレッシュが動作（インジケータ小表示）
- [x] Asia/Tokyo表示で分刻みの目盛りがズレない

## セキュリティ/RLS

* `ops_metrics` はRLS有効。適切なロールのみ参照可能。
* Flutterクライアントは既存トークンを利用、追加権限は不要。
* v_ops_5minビューはRLSポリシーを継承し、認証済みユーザーのみアクセス可能。

## CI ステータス

* Docs Status Audit：🟢
* Docs Link Check：🟢
* QA E2E：🟢
* Lint：🟢（変更 10 files / エラーなし）

## スクリーンショット

* （ダッシュボードKPIカード、5分時系列、フィルタUIのキャプチャを貼付）
* （P95折れ線グラフ、スタック棒グラフのキャプチャを貼付）
* （空状態UI、エラー状態UIのキャプチャを貼付）

## リスク&ロールバック

* **リスク**：収集量の増加によるDB負荷、グラフ描画のパフォーマンス影響
* **緩和**：サンプリング制御＋`v_ops_5min`で集計参照、Feature Flagで即OFF可能、グラフ描画エラー時はKPIのみ表示にフォールバック
* **ロールバック**：Functionsの前バージョンへ復帰／Flag OFF／前マイグにリストア（スナップショット運用）

## リリースノート（ドラフト）

* Telemetry/OPS基盤を導入。失敗率・p95応答・5分時系列の可視化、dryRunアラート検知を追加。OPS Dashboard UI拡張により、フィルタ・KPI・グラフ・自動リフレッシュ機能を実装。Feature Flagで段階的に有効化可能。

## レビュワー / メタ

* Reviewer: @pm-tim
* Labels: `area:ops`, `type:feature`, `day5`, `day6`
* Breakings: なし
