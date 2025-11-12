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
