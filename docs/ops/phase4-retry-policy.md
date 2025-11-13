# Phase 4 Retry Policy

## このドキュメントの使い方 / How to Use During 2025-11-14 Event
- 自動観測や Supabase upsert、GitHub API 呼び出し時に適用する公式リトライルールです。
- スクリプト・ワークフローでの実装時はこの表に従い、`phase4-retry-guard.yml` のチェックをパスするよう構成してください。

## HTTP ステータス分類
| Status Class | Retry? | Max Attempts | Backoff | Notes |
| --- | --- | --- | --- | --- |
| 200-299 | ❌ | 1 | N/A | 正常応答。追加処理なし。 |
| 409 | ❌ | 1 | N/A | 既存 Run ID と重複。成功扱いで通知のみ。 |
| 422 | ❌ | 1 | N/A | 入力不備。手動調査を Slack に通知。 |
| 403 | ❌ | 1 | N/A | 権限不足。Secrets 不備を疑い `phase4-secrets-check.md` を参照。 |
| 429 | ✅ | 3 | 指数 (1s, 4s, 9s) | GitHub/Supabase レート制限。 |
| 500-504 | ✅ | 3 | 指数 (5s, 15s, 45s) | サーバ側障害。 |
| その他 5xx | ✅ | 3 | 指数 (5s, 15s, 45s) | 同上。 |

## 実装ガイド
- リトライは純粋関数的に実装し、失敗ログには実際のレスポンス本文を含めない。
- 3 回失敗した場合は `AUTO_OBSERVER_SUMMARY.md` に「retry_exhausted=true」を追記。
- CLI スクリプトでは `set -o pipefail` を必須化し、失敗時に非ゼロ終了する。
