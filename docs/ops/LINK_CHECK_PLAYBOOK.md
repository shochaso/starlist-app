---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# Markdown Link Check PLAYBOOK（UIオンリー）

**作成日**: 2025-11-09

---

## 失敗時の標準対応

1. 429/一時エラー → `.mlc.json` の retryOn429 / retryCount を確認（既にON）
2. 管理画面系URL（admin/設定）の外部不可 → ignorePatterns に追加
3. 同一ページ内 anchor → Hx 見出しをユニーク化（重複回避）

---

## 記録

- 変更理由を 1 行で：`docs: stabilize link for <title>`
- 再実行 → success を確認

---

**作成日**: 2025-11-09  
**ステータス**: ✅ **Link Check PLAYBOOK完成**

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
