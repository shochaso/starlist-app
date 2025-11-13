# Phase 4 Evidence Index (2025-11-14 JST)

## このドキュメントの使い方 / How to Use During 2025-11-14 Event
- 自動監査で生成された証跡をここにリスト化し、`_manifest.json` と整合させます。
- 各行追加の際は `phase4-auto-collect.sh` が出力するログのタイムスタンプ(UTC)を転記。
- `Notes` は 200 文字以内で簡潔に。Slack や Supabase URL は記載禁止。

| Type | Location | Retrieved At (UTC) | Retrieved By | Notes |
| --- | --- | --- | --- | --- |
| artifact |  |  |  | GitHub Actions artifact for auto audit |
| provenance |  |  |  | SLSA provenance JSON |
| log |  |  |  | Observer workflow log snippet (Masked) |
| supabase |  |  |  | Upsert response metadata (HTTP code only) |

> Manifest との重複を避けるため、追加後は `phase4-manifest-atomic.sh` の結果を確認し、記録済みの run_id を二重登録しないこと。
