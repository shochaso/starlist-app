# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.6.0] - 2025-11-07

### Added
- OPS Dashboard (β) - `/ops` ルートで監視ダッシュボードを公開
  - フィルタ機能: Environment/App/Event/Period ドロップダウン（4列）
  - KPIカード: Total Requests / Error Rate / P95 Latency / Errors（4枚）
  - P95折れ線グラフ: fl_chart使用、時系列で遅延推移を表示
  - スタック棒グラフ: Success（緑）/Error（赤）の件数を積み上げ表示
  - 30秒間隔の自動リフレッシュ機能
  - 空状態UI: データなし時のガイダンスとフィルタリセットボタン
  - エラー状態UI: エラー時のリトライボタン
  - Pull-to-refresh: 手動リフレッシュ対応

### Changed
- OPS Telemetry基盤の拡張
  - `ops_metrics`テーブルと`v_ops_5min`ビューの追加
  - Edge Functions: `telemetry`と`ops-alert`の実装
  - Flutter: `OpsTelemetry`クライアントとプロバイダーの実装

### Fixed
- DropdownButtonFormFieldのnull値型エラーを修正
- ref.listen()のメモリリークを修正
- copyWith()でnullableフィールドをnullに設定可能に修正
- ops-alert関数でdryRunモード時に認証をスキップするように修正
- 正規表現パターンの修正（youtube_ocr_parser_v6.dart）

### Technical
- モデル: `OpsMetricsSeriesPoint`, `OpsMetricsFilter`, `OpsMetricsKpi`
- プロバイダー: `opsMetricsFilterProvider`, `opsMetricsSeriesProvider`, `opsMetricsKpiProvider`, `opsMetricsAutoRefreshProvider`
- テスト: モデル単体テスト追加

