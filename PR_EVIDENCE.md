Evidence for Extended-Security (observation / 2025-11-09)

- run-id: 19207760988
- artifacts: docs/ops/audit/artifacts/extended-security-19207760988/
- logs: docs/ops/audit/logs/extended-security-19207760988.log
- branch-protection proof: docs/ops/audit/branch_protection_ok.png
- sha256(screenshot): N/A
- contexts(applied): [".github/dependabot.yml","Dependabot","Telemetry E2E Tests","audit","deploy-prod","deploy-stg","report","rg-guard","rls-audit","security-audit","security-scan","validate"]

Notes:
- Applied stage: SOFT (strict=false, enforce_admins=false)
- Revert plan: curl DELETE /branches/main/protection
