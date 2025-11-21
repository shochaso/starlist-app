---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# Audit JSON Schema（UIオンリー）

**作成日**: 2025-11-09

---

```json
{
  "date_jst": "2025-11-09",
  "pr": {
    "url": "https://github.com/<owner>/<repo>/pull/<#>",
    "merge_commit": "<sha>"
  },
  "workflows": [
    {"name":"weekly-routine","run_id":"...","url":"...","conclusion":"success"},
    {"name":"allowlist-sweep","run_id":"...","url":"...","conclusion":"success"}
  ],
  "artifacts": [{"name":"...","url":"...","saved_to":"/ops/audit/20251109/..."}],
  "overview": {"before":"CI=OK / Reports=0 / Gitleaks=0 / LinkErr=0","after":"CI=OK / Reports=2 / Gitleaks=0 / LinkErr=0"},
  "sot": {"status":"ok","appended":"merged: <PR URL> (YYYY-MM-DD HH:mm JST)"},
  "security_rehardening": {"semgrep_promoted":2,"trivy_strict_on":1,"links":["..."]},
  "branch_protection": {"required_checks":["extended-security","Docs Link Check"],"block_unmet":true},
  "notes": "1行で要旨"
}
```

---

**作成日**: 2025-11-09  
**ステータス**: ✅ **Audit JSON Schema完成**

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
