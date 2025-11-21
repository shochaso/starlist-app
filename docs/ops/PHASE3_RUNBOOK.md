---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# Phase 3 Audit Observer Runbook

## Overview

Phase 3 Audit Observer monitors and validates SLSA Provenance workflow runs, ensuring:
- SHA256 integrity verification
- PredicateType validation
- Supabase integration verification
- Automatic PR comments on successful validation

---

## Prerequisites

### Required Secrets

Set the following secrets in GitHub repository settings:

```bash
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_KEY=your-service-role-key

# Slack Notification (Optional)
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL

# GitHub Token (automatically provided as GITHUB_TOKEN)
```

### Required Permissions

The workflow requires:
- `contents: read` - Checkout repository
- `actions: read` - Query workflow runs
- `pull-requests: write` - Comment on PRs
- `issues: write` - Create issues on failure
- `id-token: write` - OIDC authentication

---

## Execution Methods

### 1. Automatic Execution (Recommended)

The workflow runs automatically:
- **On workflow_run**: When `slsa-provenance` or `provenance-validate` completes
- **On schedule**: Daily at 00:00 UTC

### 2. Manual Execution via GitHub UI

1. Navigate to: https://github.com/[OWNER]/[REPO]/actions/workflows/phase3-audit-observer.yml
2. Click "Run workflow"
3. Select branch (default: `main`)
4. Optionally provide:
   - `provenance_run_id`: Specific provenance run to audit
   - `validation_run_id`: Specific validation run to audit
   - `pr_number`: PR number to comment on (default: 61)
5. Click "Run workflow"

### 3. Manual Execution via CLI

```bash
# Audit latest runs
gh workflow run phase3-audit-observer.yml

# Audit specific runs
gh workflow run phase3-audit-observer.yml \
  -f provenance_run_id=123456789 \
  -f validation_run_id=987654321 \
  -f pr_number=61

# Run script locally
export SUPABASE_URL="your-url"
export SUPABASE_SERVICE_KEY="your-key"
export PR_NUMBER=61
./scripts/observe_phase3.sh
```

---

## Validation Checklist

### Provenance Run Validation

- [ ] Run exists and is accessible
- [ ] Run conclusion is `success`
- [ ] Artifact downloaded successfully
- [ ] SHA256 calculated and verified
- [ ] PredicateType is `https://slsa.dev/provenance/v0.2`
- [ ] Builder ID is present
- [ ] Content SHA256 matches tag commit
- [ ] Invocation release matches tag
- [ ] Supabase entry exists

### Validation Run Validation

- [ ] Run exists and is accessible
- [ ] Run conclusion is `success`
- [ ] Supabase validation status is set

### Overall Assessment

- [ ] All provenance checks pass
- [ ] All validation checks pass
- [ ] Supabase integration verified
- [ ] PR comment posted (if all checks pass)

---

## Troubleshooting

### Issue: Workflow not triggering

**Symptoms**: Workflow doesn't run after provenance/validation completion

**Solutions**:
1. Check workflow file is in `.github/workflows/` directory
2. Verify workflow syntax is valid
3. Check GitHub Actions is enabled for repository
4. Verify `workflow_run` trigger syntax

### Issue: Supabase verification fails

**Symptoms**: `verify_supabase` step fails or reports entries not found

**Solutions**:
1. Verify `SUPABASE_URL` and `SUPABASE_SERVICE_KEY` secrets are set
2. Check Supabase RLS policies allow service role access
3. Verify `slsa_runs` table exists and has correct schema
4. Check network connectivity from GitHub Actions runners

### Issue: PR comment not posted

**Symptoms**: All validations pass but PR comment is not posted

**Solutions**:
1. Verify `pull-requests: write` permission is granted
2. Check PR number is correct (default: 61)
3. Verify PR exists and is accessible
4. Check workflow logs for error messages

### Issue: Artifact download fails

**Symptoms**: `gh run download` fails or returns no artifacts

**Solutions**:
1. Verify provenance run completed successfully
2. Check artifact retention period hasn't expired
3. Verify `actions: read` permission is granted
4. Check artifact name matches expected pattern

---

## Expected Outputs

### Success Case

```
✅ All validations passed
✅ Phase 3 Audit Operationalization Verified — Proceed to Phase 4 (Telemetry & KPI Dashboard)
```

### Failure Case

- GitHub Issue created with failure details
- Slack notification sent (if webhook configured)
- Audit summary artifact uploaded

---

## Monitoring

### View Audit Metrics

Query Supabase for audit metrics:

```sql
-- Recent audits
SELECT * FROM slsa_audit_metrics
ORDER BY audit_timestamp DESC
LIMIT 10;

-- Success rate
SELECT * FROM v_ops_slsa_audit_kpi
ORDER BY date DESC
LIMIT 30;

-- Recent failures
SELECT * FROM v_ops_slsa_audit_failures
LIMIT 10;
```

### View Audit Artifacts

Download audit summary artifacts:

```bash
# List artifacts
gh run list --workflow=phase3-audit-observer.yml --limit 10

# Download artifact
gh run download [RUN_ID] --name phase3-audit-summary-[RUN_ID]
```

---

## Integration with Phase 4

Upon successful Phase 3 validation, proceed to:

1. **Telemetry Dashboard**: Set up Supabase KPI views
2. **Automated Reporting**: Configure weekly audit reports
3. **Alerting**: Set up Slack/Email notifications for failures
4. **Metrics Collection**: Implement DORA metrics integration

---

**Last Updated**: 2025-11-13
**Maintainer**: STARLIST Ops Team

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
