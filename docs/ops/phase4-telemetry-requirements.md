# Phase 4 Telemetry Requirements

## このドキュメントの使い方 / How to Use During 2025-11-14 Event
- Phase 5 で予定されている拡張監視に向けて、Phase 4 で収集するべきテレメトリ項目をリスト化しています。
- スクリプトやワークフローから Supabase へ送信するペイロードの必須フィールドとして適用してください。

## Required Fields
| Field | Description | Source | Example |
| --- | --- | --- | --- |
| run_id | GitHub Actions run ID | GH API | "1234567890" |
| status | final status ("success"/"failure"/"cancelled") | RUNS_SUMMARY.json | "success" |
| retries | 実施したリトライ回数 | RUNS_SUMMARY.json | 1 |
| duration_sec | `run_completed - run_started` | RUNS_SUMMARY.json | 245 |
| validator_verdict | SHA パリティおよび検証結果 | SHA compare | "parity_pass" |
| prov_sha | Provenance から取得した SHA256 | provenance artifact | "abc123..." |
| computed_sha | ダウンロードしたアーティファクトの SHA256 | SHA compare | "abc123..." |
| observer_run_id | オブザーバー実行 ID | workflow context | "987654321" |
| observed_at_utc | オブザーバーが記録した UTC 時刻 | observer script | "2025-11-14T05:05:00Z" |
| window_days | 参照期間 | dispatch input | 7 |
| retry_policy_version | 現行リトライポリシー | static | "phase4-v1" |

## Optional Fields
- `supabase_response_code` : Supabase REST の HTTP ステータス。
- `retry_exhausted` : 3 回リトライ後も失敗した場合 true。
- `slack_notification_id` : 通知トラッキング用 ID (URL は記載しない)。

## Storage / Transmission
- Supabase テーブル (例: `phase4_audit_metrics`) は Run ID ユニーク制約を設定。
- JSON ペイロードは以下テンプレートに準拠:
  ```
  {
    "run_id": "...",
    "status": "...",
    "retries": 0,
    "duration_sec": 245,
    "validator_verdict": "parity_pass",
    "prov_sha": "...",
    "computed_sha": "...",
    "observer_run_id": "...",
    "observed_at_utc": "...",
    "window_days": 7,
    "retry_policy_version": "phase4-v1"
  }
  ```
- Supabase 送信時は `Content-Type: application/json` を使用し、レスポンス本文はログへ出力しない。
