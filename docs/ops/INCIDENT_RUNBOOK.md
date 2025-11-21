---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# Minimal incident runbook (summary)

1) Detection:

   - Alerts from Actions, external monitoring

2) Triage:

   - Assign on-call, create issue with label incident/severity

3) KillSwitch:

   - Set repo variable KILL_SWITCH=true or call admin to enable protection

4) Mitigation:

   - Revert last merge: git revert -m 1 <merge_sha>

5) Postmortem:

   - Fill docs/reports/YYYY-MM-DD/INCIDENT.md and schedule RCA

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
