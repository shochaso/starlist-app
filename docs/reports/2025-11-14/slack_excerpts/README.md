# Slack Excerpts Handling (Phase 4 – 2025-11-14 JST)

## このドキュメントの使い方 / How to Use During 2025-11-14 Event
- Phase 4 の自動通知を Slack で共有する際に遵守すべきマスキングポリシーです。
- 抜粋ファイルは `RUN_ID-summary.md` など一意なファイル名で保存し、`AUTO_OBSERVER_SUMMARY.md` から参照します。

## Allowed Fields
- **status:** success / failure / retry / alert
- **timestamp_utc:** `YYYY-MM-DDTHH:MM:SSZ`
- **summary:** 200 文字以内の要約 (Secret, URL, 個人情報なし)
- **retry_context (optional):** "retry_attempt=2 (5xx detected)" のような短い説明

## File Template
```
status: retry
timestamp_utc: 2025-11-14T05:45:10Z
summary: Observer detected 503 from Supabase. Retry attempt scheduled.
retry_context: retry_attempt=1 backoff=5s
```

## Masking Policy
- Slack Message Link、Thread URL は記載禁止。Manifest のエントリ ID を引用すること。
- 個別 Run ID は記載可だが、ハッシュやトークンはマスク (例: `run_id=123456***` )。
- Supabase エンドポイントは `SUPABASE_URL` と環境変数名で置換。
