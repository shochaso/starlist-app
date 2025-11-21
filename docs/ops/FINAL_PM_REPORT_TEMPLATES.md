---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# PM報告テンプレート集

**作成日**: 2025-11-09

---

## 1) PRコメント（最終着地）

```
=== UI-only Final Landing — Completion Report ===

Workflows: weekly-routine ✅ / allowlist-sweep ✅

Ops Health: CI=OK / Reports=<n> / Gitleaks=0 / LinkErr=0（Overview更新済）

SOT Ledger: OK（PR URL + JST時刻追記／Docs Link Check成功）

Security戻し運用: Semgrep 2ルール昇格PR起票 / Trivy Strict 一部ON

Branch Protection: main に必須Checks設定（lin. history / squashのみ）



Next:

- 週次WFの定例運用（Artifacts/SARIFで可視化）

- Semgrep昇格を週2–3本、Trivy Strictは行列で順次ON

- allowlist 自動PRの棚卸し（期限ラベル）
```

---

## 2) 監査JSON（保存用）

```json
{
  "date_jst": "YYYY-MM-DD",
  "workflows": {
    "weekly_routine": {"run_id": "<RID>", "conclusion": "success"},
    "allowlist_sweep": {"run_id": "<RID>", "conclusion": "success"},
    "docs_link_check": {"run_id": "<RID>", "conclusion": "success"}
  },
  "ops_health": {"CI": "OK", "Reports": "<n>", "Gitleaks": 0, "LinkErr": 0},
  "sot_ledger": {"status": "OK", "note": "PR URL + JST時刻追記済み"},
  "security_rehardening": {
    "semgrep_rules_promoted": 2,
    "trivy_config_strict_services_on": 1
  },
  "branch_protection": {
    "required_checks": ["extended-security", "Docs Link Check"],
    "linear_history": true,
    "squash_only": true
  },
  "artifacts_proof": {
    "security_sarif": "captured",
    "weekly_artifact": "downloaded"
  }
}
```

---

## 3) Slack通知（簡潔版）

```
【週次オートメーション結果】

- Workflows: weekly-routine ✅ / allowlist-sweep ✅

- Ops Health: CI=OK / Reports=<n> / Gitleaks=0 / LinkErr=0（Overview更新済）

- SOT Ledger: OK（PR URL + JST時刻追記済）

- Security復帰: Semgrep(2ルール) PR起票 / Trivy strict 一部復帰

次アクション:
- Semgrep昇格を週2–3本ペースで継続
- Trivy strictをサービス行列で順次ON
- allowlist自動PRの棚卸し（期限ラベル運用）
```

---

## 4) 仕上げのPMワンライナー（PR/Slack用）

```
週次WF通電（2/2 success）、Overviewを `CI=OK / Reports=<n> / Gitleaks=0 / LinkErr=0` に更新、SOT整合OK。
Semgrep 2ルール昇格PR／Trivy strict 1サービス通電、ブランチ保護は未合格時マージ不可を確認。
監査一式（SARIF/Artifacts/JSON/差分）を `FINAL_COMPLETION_REPORT.md` に集約済み。以上で"UIオンリー最終着地"完了です。
```

---

**作成日**: 2025-11-09  
**ステータス**: ✅ **PM報告テンプレート集完成**

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
