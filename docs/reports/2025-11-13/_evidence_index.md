# Phase 3 Evidence Index (2025-11-13 JST)

## このドキュメントの使い方 / How to Use During 2025-11-13 Event
- 各証跡取得後、5 分以内に行を追加し、UTC Timestamp を `YYYY-MM-DDTHH:MM:SSZ` 形式で記録します。
- `Location` は GitHub Run, Artifact 名、もしくは Supabase バケットキーなどの識別子のみを記載し、秘密 URL は書かないでください。
- `Retrieved By` には GitHub Handle や PagerDuty ID など個人特定が可能な識別子を記入します。

| Type | Location | Retrieved At (UTC) | Retrieved By | Notes |
| --- | --- | --- | --- | --- |
| log |  |  |  | Phase 3 成功ランの GitHub Actions ログ (マスク済み) |
| artifact |  |  |  | `phase4-sha-compare.sh` 実行用に取得したアーティファクト |
| screenshot |  |  |  | Slack スレッドの要約サマリ (本文なし) |

> 追記時の注意: 同一 Type で複数証跡がある場合も行を重複して追加し、`Notes` で差異を説明してください。
