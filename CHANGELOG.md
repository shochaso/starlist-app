---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- **Ad-based Gacha Ticket Restriction (Server-side)** - Implements Lv1 server-side control with daily limits
  - Database migration `20251121_add_ad_views_logging_and_gacha_rpc.sql`
  - New RPC: `complete_ad_view_and_grant_ticket()` - Records ad view and grants ticket (max 3/day, JST 3:00 reset)
  - New RPC: `consume_gacha_attempts()` - Atomically consumes attempts and records rewards with point grants
  - New function: `date_key_jst3()` - Calculates date key based on JST 3:00 AM boundary
  - Enhanced `ad_views` table with Lv2-Lite logging columns: device_id, user_agent, client_ip, status, date_key, reward_granted
  - Enhanced `gacha_attempts` table with date_key and source tracking
  - Enhanced `gacha_history` table with reward_points and reward_silver_ticket columns
  - New indexes for efficient daily limit checks and device-level analytics
  - Documentation: Comprehensive migration README with usage examples and analytics queries

### Changed
- **Gacha Probability Table** - Adjusted for expected value balance
  - New distribution: 50%→20pt, 30%→40pt, 15%→60pt, 4%→120pt, 1%→silver ticket
  - Expected value: ~35.8pt per draw + 0.01 silver tickets
  - Target: 135 draws (3/day × 45 days) ≈ 1 silver ticket equivalent
- **Flutter Client Architecture** - Migrated to server-side control
  - `ad_service.dart`: Added `completeAdViewAndGrantTicket()` method using new RPC
  - `gacha_attempts_manager.dart`: Removed local `setTodayBaseAttempts(10)`, now fetches from server
  - `gacha_view_model.dart`: Uses `consume_gacha_attempts` RPC for atomic gacha execution
  - `gacha_limits_repository.dart`: Added `consumeGachaAttemptsWithResult()` method

### Fixed
- Ad view limit bypass vulnerability - Daily limit now enforced server-side with JST 3:00 reset
- Point grant inconsistency - Gacha consumption and reward grants now atomic via RPC

### Deprecated
- `GachaAttemptsManager.addBonusAttempts()` - Use `AdService.completeAdViewAndGrantTicket()` instead
- Local ad view recording without server validation

### Technical
- All ad completion events now log device_id, user_agent, client_ip for Lv2-Lite analytics
- RPC functions use PostgreSQL transactions for data consistency
- Row Level Security (RLS) enabled on all modified tables
- Backward compatible: Old code paths continue to work but are deprecated

### Notes
- **Security**: This PR implements Lv1 (grant limits) server-side control and Lv2-Lite observation infrastructure
- **Future Work**: Automated ban detection and rate limiting (Lv2) will be implemented separately
- **Testing**: Integration tests for 4th ad rejection and atomic gacha consumption recommended

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

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
