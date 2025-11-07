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
