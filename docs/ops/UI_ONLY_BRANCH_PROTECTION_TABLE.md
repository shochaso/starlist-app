# Branch Protection 設定表（UIオンリー）

**作成日**: 2025-11-09

---

| 項目 | 推奨値 | 備考 |
|---|---|---|
| Required checks | extended-security / Docs Link Check | 週次WFは任意で追加 |
| Merge strategy | Squash only | 履歴の明瞭化 |
| Linear history | ON | 再現性担保 |
| Include admins | ON | 例外無し運用 |

---

## 検証手順（UIのみ）

1. 軽微Docs変更でダミーPR作成
2. Checks未合格時：Mergeボタンがブロックされる
3. 合格後：Mergeボタンが有効化される（スクショ保存）

---

**作成日**: 2025-11-09  
**ステータス**: ✅ **Branch Protection設定表完成**

