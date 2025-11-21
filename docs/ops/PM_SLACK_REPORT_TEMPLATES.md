---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# PM向け Slack 報告テンプレ

**作成日**: 2025-11-09

---

## Ultra-Short（60字）

週次WF(2/2)成功、Overview更新、SOT整合OK。Semgrep+2/Trivy+1、保護設定確認済。

---

## Short

週次WF通電（2/2 success）。Overviewを `CI=OK / Reports=<n> / Gitleaks=0 / LinkErr=0` に更新、SOT整合OK。Semgrep 2ルール昇格、Trivy strict 1サービスON。ブランチ保護（未合格時ブロック）確認、監査証跡はFINAL_COMPLETION_REPORTに集約。

---

## Long

- Workflows: weekly-routine ✅ / allowlist-sweep ✅（Run URL付き）
- Ops Health: `CI=OK / Reports=<n> / Gitleaks=0 / LinkErr=0`（差分1行）
- SOT Ledger: OK（PR URL + JST追記、Docs Link Check success）
- Security戻し運用: Semgrep+2（PR #…）/ Trivy strict +1（Run URL）
- Branch Protection: 必須Checks設定＆未合格時ブロック確認
- 監査: SARIF/Artifacts/JSONを FINAL_COMPLETION_REPORT.md に集約

---

**作成日**: 2025-11-09  
**ステータス**: ✅ **PM向けSlack報告テンプレ完成**

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
