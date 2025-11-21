---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# WS02: 成功ケース手動実行証跡

**実行日時**: 2025-11-13
**作業者**: Cursor AI

## 実行方法

### GitHub UI手順

1. Navigate to: https://github.com/shochaso/starlist-app/actions/workflows/slsa-provenance.yml
2. Click "Run workflow"
3. Select branch: `feature/slsa-phase2.1-hardened`
4. Enter tag: `v2025.11.13-success-test`
5. Click "Run workflow"

### CLI手順

```bash
gh workflow run slsa-provenance.yml \
  --ref feature/slsa-phase2.1-hardened \
  -f tag=v2025.11.13-success-test
```

## 実行結果

**Status**: ⏳ Pending execution (workflow_dispatch認識待ち)

**Note**: workflow_dispatchがブランチで認識されるまで時間が必要な可能性があります。

## 記録項目

- Run URL: (実行後記録)
- Run ID: (実行後記録)
- Artifacts名: (実行後記録)
- 実行時刻: (実行後記録)

**状態**: ⏳ 実行待ち

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
