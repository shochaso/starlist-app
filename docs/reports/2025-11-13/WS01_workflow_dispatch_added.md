---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# WS01: workflow_dispatch追加証跡

**実行日時**: 2025-11-13
**作業者**: Cursor AI

## 変更内容

### slsa-provenance.yml
- ✅ 既存の`workflow_dispatch`に`inputs`セクションを追加
- ✅ `tag`入力パラメータを追加（required: false）

### provenance-validate.yml
- ✅ 既存の`workflow_dispatch`は変更なし（既に実装済み）

## 検証

```bash
# 確認コマンド
grep -A 5 "workflow_dispatch" .github/workflows/slsa-provenance.yml
grep -A 5 "workflow_dispatch" .github/workflows/provenance-validate.yml
```

## 証跡

- 変更前: `workflow_dispatch:`のみ（inputsなし）
- 変更後: `workflow_dispatch:` + `inputs:`セクション追加

**差分**: 最小限（既存onを温存、inputs追加のみ）

**状態**: ✅ 完了

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
