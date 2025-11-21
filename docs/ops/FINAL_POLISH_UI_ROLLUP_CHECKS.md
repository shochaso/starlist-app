---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# 最終仕上げ Rollup Checks（UIオンリー）

目的：本日内の「通電→可視化→証跡→復帰」までを 1 ページで俯瞰し、未完を0にする。

**作成日**: 2025-11-09

---

## A. Workflows（2/2必須）

- [ ] weekly-routine: success（Run URL: … / Run ID: …）
- [ ] allowlist-sweep: success（Run URL: … / Run ID: …）
- [ ] Artifacts: 1件DL（保存: /ops/audit/YYYYMMDD/）

---

## B. Overview（健康度）

- [ ] `CI=OK / Reports=<n> / Gitleaks=0 / LinkErr=0`
- [ ] Before→After差分（1行で）： …

---

## C. Docs Link Check（SOT整合）

- [ ] success（SOT追記済み）
- [ ] 追記行：`merged: <PR URL> (YYYY-MM-DD HH:mm JST)`

---

## D. Security戻し運用（今日の成果）

- [ ] Semgrep 昇格 +2 ルール（PR # …）
- [ ] Trivy（Config）strict ON +1 サービス（Run URL: …）

---

## E. Branch Protection

- [ ] 必須 Checks: extended-security / Docs Link Check
- [ ] Linear history=ON / Squash only=ON
- [ ] 未合格時マージ不可（ダミーPRで確認）

---

## F. 監査証跡

- [ ] Securityタブ(SARIF)スクショ保管
- [ ] Artifacts保管（ファイル名: …）
- [ ] `FINAL_COMPLETION_REPORT.md` へ集約

---

**作成日**: 2025-11-09  
**ステータス**: ✅ **最終仕上げ Rollup Checks完成**

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
