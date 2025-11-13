# Phase 4 KPI Metrics Definition

## このドキュメントの使い方 / How to Use During 2025-11-14 Event
- KPI を算出する際の定義集です。`phase4-observer-report.sh` や Supabase upsert のフィールド命名で参照してください。
- すべての値は UTC を基準とし、JST 表記が必要な場合は補助列として追加します。

## Core Metrics
| KPI | Definition | Source | Notes |
| --- | --- | --- | --- |
| total_runs | window_days 内の監査対象ラン数 | RUNS_SUMMARY.json | 包括的な成功/失敗含む |
| success_count | status == "success" の件数 | RUNS_SUMMARY.json | Phase3 手動成功を含む |
| failure_count | status == "failure" の件数 | RUNS_SUMMARY.json | 自動リトライ失敗も計上 |
| success_rate | success_count / total_runs | 派生 | 小数第 3 位まで |
| retry_invocations | retries > 0 の合計 | RUNS_SUMMARY.json | Phase4 リトライで増加 |
| retry_success_rate | リトライ後に success へ転じた割合 | RUNS_SUMMARY.json | `sha_parity=true` のみカウント |
| p50_latency_sec | 実行時間中央値 | RUNS_SUMMARY.json | `run_completed - run_started` |
| p90_latency_sec | 実行時間 90 パーセンタイル | RUNS_SUMMARY.json | 同上 |

## Derived Signals
- **sha_parity_pass_rate** = `count(sha_parity=true) / total_runs`
- **observer_lag_sec** = Phase4 実行時刻 - 最新ランの `run_completed_at_utc`
- **supabase_ingest_success_rate** = Supabase upsert 2xx / 呼び出し数

## Reporting Conventions
- JSON 出力は `metrics.phase4` ネームスペースを使用。
- Slack 報告では成功/失敗数のみを記載し、個別 run_id は `_manifest.json` を参照するよう誘導。
- Supabase 側カラム: `total_runs`, `success_rate`, `retry_count`, `sha_parity_pass_rate`, `p50_latency_sec`, `p90_latency_sec`.
