---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# Branch Protection 検証ケース

**作成日**: 2025-11-09

---

## 必須チェック

- extended-security
- Docs Link Check
- （推奨）weekly-routine, allowlist-sweep

---

## 検証手順（UIのみ）

1. ダミーPRを作成（軽微なDocs変更）
2. Checks未成功の状態で Merge ボタンがブロックされること
3. success 後にボタンが有効化されること

---

## 追加設定

- Linear history: ON
- Allow merge commits: OFF（Squash only）
- Include administrators: ON（推奨）

---

**作成日**: 2025-11-09  
**ステータス**: ✅ **Branch Protection検証ケース完成**

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
