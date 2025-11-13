# Phase 4 Observer Specification

## このドキュメントの使い方 / How to Use During 2025-11-14 Event
- オブザーバージョブと `phase4-observer-report.sh` の要件定義です。実行前に必ず読み合わせ、パラメータの誤設定を防ぎます。
- 入出力を満たしたうえで `AUTO_OBSERVER_SUMMARY.md` に結果を記録してください。

## Inputs
| Parameter | Source | Description | Required | Notes |
| --- | --- | --- | --- | --- |
| window_days | workflow_dispatch input | 直近 N 日を観測 (デフォルト 7) | ✅ | Phase 3 handoff 後は最低 2 日推奨 |
| run_id | CLI arg / dispatch input | オブザーバー自体の GitHub Actions run | ✅ | Manifest 更新時の主キー |
| metrics_path | env | `docs/reports/2025-11-14/RUNS_SUMMARY.json` | ✅ | 読み取り専用で開始し、検証後に更新 |
| supabase_url | secret env | Supabase REST Endpoint | ✅ | `phase4-secrets-check.md` 参照 |
| supabase_service_key | secret env | サービスキー | ✅ | 出力ログに露出禁止 |

## Processing Flow
1. `RUNS_SUMMARY.json` から対象期間のレコードをロード。
2. SHA パリティが false の場合は `phase4-auto-collect.sh` 再実行をトリガーし、再度検証。
3. HTTP 5xx エラーが発生した場合のみ `phase4-retry-policy.md` の回数とバックオフで再試行。
4. メトリクス集計後、`scripts/phase4-supabase-upsert.sh` (Step6 で追加) を呼び出し、Supabase へ upsert。
5. 最終結果および異常値は `AUTO_OBSERVER_SUMMARY.md` に追記。

## Outputs
- `AUTO_OBSERVER_SUMMARY.md` : まとめ行を追加 (UTC timestamps)。
- `PHASE3_AUDIT_SUMMARY.md` : KPI を同期し、Go/No-Go 判定を補完。
- Supabase upsert ステータス: CLI 出力のみ。ログには HTTP ステータスコードと retry 判定 (true/false) を残す。

## Idempotency
- オブザーバースクリプトは同一 run_id で複数回実行されても最終結果が変わらないよう、以下を遵守:
  - Manifest 更新は `scripts/phase4-manifest-atomic.sh` を介して merge。
  - Supabase upsert は `run_id` をユニークキーとし、HTTP 409 を成功扱いにする。
  - KPI 再計算時は既存ファイルを上書きせず、テンプレートをコピーして更新。
