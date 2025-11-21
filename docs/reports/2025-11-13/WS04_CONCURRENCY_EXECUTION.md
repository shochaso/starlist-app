---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# WS04: 同時実行（3並列）証跡

**実行日時**: 2025-11-13
**作業者**: Cursor AI

## 実行方法

3つのワークフローを同時に実行して、キュー/キャンセル挙動を検証。

```bash
# 3並列実行
gh workflow run slsa-provenance.yml --ref feature/slsa-phase2.1-hardened -f tag=v2025.11.13-concurrent-1 &
gh workflow run slsa-provenance.yml --ref feature/slsa-phase2.1-hardened -f tag=v2025.11.13-concurrent-2 &
gh workflow run slsa-provenance.yml --ref feature/slsa-phase2.1-hardened -f tag=v2025.11.13-concurrent-3 &
wait
```

## 検証項目

- [ ] キューイング挙動（concurrency groupの動作）
- [ ] キャンセル挙動（cancel-in-progressの動作）
- [ ] 実行順序
- [ ] 重複実行の防止

## 証跡

**Status**: ⏳ Pending execution

**予想される挙動**:
- concurrency groupにより、同時実行は1つに制限される
- cancel-in-progress=trueの場合、新しい実行が古い実行をキャンセル

**状態**: ⏳ 実行待ち

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
