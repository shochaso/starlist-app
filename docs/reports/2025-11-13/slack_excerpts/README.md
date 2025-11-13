# Slack Excerpts Handling (Phase 3 – 2025-11-13 JST)

## このドキュメントの使い方 / How to Use During 2025-11-13 Event
- Slack から抜粋を作成する際は、本文を直接貼り付けず、以下 3 要素のみに限定します。
  - **status:** success / failure / warning などの短い指標
  - **timestamp_utc:** `YYYY-MM-DDTHH:MM:SSZ`
  - **summary:** 200 文字以内の要約 (個人情報・シークレット禁止)
- 取得した抜粋は `_evidence_index.md` に位置情報を記載し、このフォルダには下記サンプルフォーマットで保存します。

## File Template
```
status: success
timestamp_utc: 2025-11-13T04:05:33Z
summary: Manual dispatch #123456 completed. Artifacts uploaded and checksum verified.
```

## Masking Policy
- 個人名は GitHub Handle など既定の識別子に置換。
- 内部プロジェクト名・秘密 URL・トークンは一切記載しない。
- Supabase テーブル名や実行環境情報が必要な場合は環境変数名のみ言及 (例: `SUPABASE_SERVICE_KEY` 未設定)。
