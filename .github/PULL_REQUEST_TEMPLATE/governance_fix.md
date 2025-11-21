---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



## 概要

ガバナンス逸脱（{項目}）の是正。Release/監査/保護ルールの整合。

## 変更点

- {ファイル} の {設定} を {旧} → {新} に修正

- 監査YAMLを手動実行し、証跡を docs/reports/{date}/ に保存

## 合否基準

- Release/Tag 整合 OK

- Branch Protection Required=2本 OK

- 監査ワークフローが成功、逸脱0

## ロールバック

- `git revert -m 1 <commit>` で復元可能

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
