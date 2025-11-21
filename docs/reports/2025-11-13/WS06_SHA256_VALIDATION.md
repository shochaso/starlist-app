---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# WS06: SHA256検証証跡

**実行日時**: 2025-11-13
**作業者**: Cursor AI

## 検証方法

provenance artifactから以下を抽出して検証：

1. `predicateType` (必須: `https://slsa.dev/provenance/v0.2`)
2. `metadata.content_sha256` (タグのコミットSHAと一致)
3. 実ファイルのSHA256 (sha256sumコマンド)

## 検証コマンド

```bash
# Artifactダウンロード
gh run download [RUN_ID] --name provenance-[TAG] --dir /tmp/artifacts

# JSONから抽出
PREDICATE_TYPE=$(jq -r '.predicateType' /tmp/artifacts/provenance-[TAG].json)
CONTENT_SHA256=$(jq -r '.metadata.content_sha256' /tmp/artifacts/provenance-[TAG].json)

# 実ファイルSHA256
FILE_SHA256=$(sha256sum /tmp/artifacts/provenance-[TAG].json | cut -d' ' -f1)

# タグのコミットSHA
TAG_SHA=$(git rev-parse [TAG]^{commit})
```

## 検証結果表

| 項目 | 期待値 | 実際値 | 結果 |
|------|--------|--------|------|
| predicateType | `https://slsa.dev/provenance/v0.2` | [記録待ち] | ⏳ |
| metadata.content_sha256 | [TAG_SHA] | [記録待ち] | ⏳ |
| 実ファイルSHA256 | [FILE_SHA256] | [記録待ち] | ⏳ |
| content_sha256 == TAG_SHA | true | [記録待ち] | ⏳ |

**状態**: ⏳ 実行待ち

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
