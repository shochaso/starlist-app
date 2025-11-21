---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# UI-Only FAQ（よくある詰まり）

**作成日**: 2025-11-09

---

## Q. PRが"Not mergeable" / "Unknown"

**A.** 競合解消→再実行。Checks未達成ならQuick Fix Matrixを順に適用。  
   *SOT/rg-guard/Link Check/Gitleaks/Trivyの"最小修正"を優先。*

---

## Q. 週次WFが"Runできない"

**A.** ワークフローファイルが main に未反映。PRで反映させてから Actions→Run。

---

## Q. Link Checkが通らない

**A.** `.mlc.json`の retry/ignore と 見出しユニーク化で対応。どうしても無理なら代替URL。

---

## Q. rg-guardがコメントで誤検知

**A.** "Asset-based image loaders" 等の回避語彙へ**コメントを**置換（コード不変）。

---

**作成日**: 2025-11-09  
**ステータス**: ✅ **UI-Only FAQ完成**

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
