---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# SOT 追記ルール（UIオンリー）

**作成日**: 2025-11-09

---

## 追記フォーマット

`merged: https://github.com/<owner>/<repo>/pull/<PR#> (YYYY-MM-DD HH:mm JST)`

---

## 追記対象

- 日次/週次で反映したPR、ロールバック、重大変更

---

## NG例→修正

- × `merge:` / `Merged:` / タイムゾーン未記載
- 〇 `merged: <PR URL> (YYYY-MM-DD HH:mm JST)`

---

## よくある失敗と修正

- Link Check で anchor 死亡 → 目次を再生成、または ignore へ
- 日付時刻の未入力 → 必ず JST 明記

---

**作成日**: 2025-11-09  
**ステータス**: ✅ **SOT追記ルール完成**

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
