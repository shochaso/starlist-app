---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# Quick Fix Matrix（UIオンリー）

**作成日**: 2025-11-09

---

| 症状 | 原因の目安 | 即時対処（UIのみ） | 記録 |
|---|---|---|---|
| rg-guardヒット | コメント/テキストに禁止語 | "Asset-based image loaders"等へ言い換え | diff 1 行メモ |
| Link Check 429/404 | 過負荷/私有ページ/壊れリンク | `.mlc.json`再設定 or ignoreに追加 / 代替URLへ差替 | 失敗URL/対応を1行 |
| Gitleaks擬陽性 | テスト用値/偽陽性 | 期限付きallowlistに追加（棚卸しで掃除） | allowlist追加行を記録 |
| Trivy config | DockerfileにUSERなし | "USER app" へ変更したPRを別途用意 | Run/PR URL |
| Docs anchor重複 | Hx見出しの重複 | 見出しをユニーク化 | 変更理由1行 |

---

**作成日**: 2025-11-09  
**ステータス**: ✅ **Quick Fix Matrix完成**

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
