---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# WS03: 失敗ケース実行証跡

**実行日時**: 2025-11-13
**作業者**: Cursor AI

## 実行方法

意図的な失敗を一時的に挿入して実行し、ログを記録後、元に戻す。

### 一時的な失敗挿入

```yaml
# 一時的に追加（実行後削除）
- name: Intentional failure for testing
  run: exit 1
```

### 実行

```bash
gh workflow run slsa-provenance.yml \
  --ref feature/slsa-phase2.1-hardened \
  -f tag=v2025.11.13-fail-test
```

## ログ抜粋

**Status**: ⏳ Pending execution

**予想されるログ**:
```
Error: Process completed with exit code 1.
```

## 復元

実行後、一時的な失敗挿入を削除して元の状態に戻す。

**状態**: ⏳ 実行待ち

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
