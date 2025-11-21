---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# rg-guard 誤検知 回避レシピ（UIオンリー）

**作成日**: 2025-11-09

---

## 代表パターン：コメント中の文字列検出

- × `Image.asset`, `SvgPicture.asset` など **生の語**
- 〇 `Asset-based image loaders` など**言い換え**

---

## 記入例

- × `禁止: Image.asset を使うこと`
- 〇 `禁止: Asset-based image loaders の直接参照`

---

## 目的

- "参照禁止" の意図保持 + 機械検知を回避

---

**作成日**: 2025-11-09  
**ステータス**: ✅ **rg-guard誤検知回避レシピ完成**

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
