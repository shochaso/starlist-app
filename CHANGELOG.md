# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- Ad-view gacha ticket system with server-side control
  - Server RPC `complete_ad_view_and_grant_ticket()` enforces daily limit of 3 ad-granted tickets per user
  - Server RPC `consume_gacha_attempts()` handles gacha ticket consumption and history tracking
  - Server RPC `get_user_gacha_state()` returns current balance and today's granted count
  - JST timezone support with 03:00 boundary for daily limits via `date_key_jst3()` function
  - `ad_views` table with device tracking (device_id, user_agent, client_ip) for fraud detection
  - `gacha_attempts` table for user ticket balance management
  - `gacha_history` table for comprehensive gacha draw tracking with reward details
  - All RPCs are race-condition safe with SELECT FOR UPDATE locking

### Changed
- **BREAKING**: Gacha attempts no longer auto-grant 10 base tickets
  - Removed automatic 10-ticket daily grant in `gacha_attempts_manager.dart`
  - Users start with 0 balance and must watch ads to earn tickets
  - `ad_service.dart` now calls `complete_ad_view_and_grant_ticket()` RPC instead of legacy methods
  - `gacha_view_model.dart` now calls `consume_gacha_attempts()` RPC to decrement balance and record history
- Flutter ad service now integrates with server-side ad view logging
- Gacha view model now records reward_points and reward_silver_ticket in server history

### Deprecated
- `gacha_attempts_manager.resetToTenAttempts()` - base attempts are no longer auto-granted
- Legacy ad view recording methods in `ad_service.dart`

## [0.9.0] - 2025-11-08

### Added
- OPS Summary Email（β）公開
  - Edge Function `ops-summary-email`（週次レポート生成）
  - GitHub Actions週次スケジュール（毎週月曜09:00 JST）
  - Resend/SendGridメール送信対応
  - 送信の冪等化（重複送信防止）
  - 配信品質改善（List-Unsubscribeヘッダー、Preheader）
  - 監査ログ（`ops_summary_email_logs`テーブル）
  - 宛先の安全策（@starlist.jpのみ許可）

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


- DropdownButtonFormFieldのnull値型エラーを修正
- ref.listen()のメモリリークを修正
- copyWith()でnullableフィールドをnullに設定可能に修正
- ops-alert関数でdryRunモード時に認証をスキップするように修正
- 正規表現パターンの修正（youtube_ocr_parser_v6.dart）

### Technical
- モデル: `OpsMetricsSeriesPoint`, `OpsMetricsFilter`, `OpsMetricsKpi`
- プロバイダー: `opsMetricsFilterProvider`, `opsMetricsSeriesProvider`, `opsMetricsKpiProvider`, `opsMetricsAutoRefreshProvider`
- テスト: モデル単体テスト追加

