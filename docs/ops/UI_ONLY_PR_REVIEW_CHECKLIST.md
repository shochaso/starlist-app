---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# UI-Only PR Review Checklist（Security/Docs/CI 観点）

**作成日**: 2025-11-09

---

## Security

- [ ] rg-guard禁止語をコード/コメントに含まない（回避語彙へ置換）
- [ ] Gitleaks擬陽性は期限付きallowlist（自動棚卸し対象）

---

## Docs/SOT

- [ ] SOTフォーマット厳守：`merged: <PR URL> (YYYY-MM-DD HH:mm JST)`
- [ ] Link Checkのanchor名はユニーク

---

## CI/週次WF

- [ ] workflow_dispatch を含む
- [ ] "最小修正で緑にする"方針（テンプレ修正を優先）

---

**作成日**: 2025-11-09  
**ステータス**: ✅ **UI-Only PR Review Checklist完成**

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
