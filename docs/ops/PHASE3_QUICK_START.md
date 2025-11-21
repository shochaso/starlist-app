---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# Phase 3 Quick Start Guide

## 🚀 Quick Setup (5 minutes)

### 1. Set Required Secrets

Go to GitHub repository settings → Secrets and variables → Actions:

```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_KEY=your-service-role-key
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL  # Optional
```

### 2. Merge PR

Merge the Phase 3 implementation PR to `main` branch.

### 3. Verify Execution

The workflow will automatically run:
- When `slsa-provenance` completes
- When `provenance-validate` completes
- Daily at 00:00 UTC

### 4. Test Manual Execution

```bash
# Via GitHub UI
# Navigate to Actions → phase3-audit-observer → Run workflow

# Via CLI
gh workflow run phase3-audit-observer.yml
```

### 5. Check Results

```bash
# View latest audit run
gh run list --workflow=phase3-audit-observer.yml --limit 1

# Download audit summary
gh run download [RUN_ID] --name phase3-audit-summary-[RUN_ID]
```

---

## ✅ Success Criteria

When all validations pass, you'll see:

1. **PR Comment** on PR #61:
   ```
   ✅ Phase 3 Audit Operationalization Verified — Proceed to Phase 4 (Telemetry & KPI Dashboard)
   ```

2. **Audit Summary Artifact** uploaded

3. **Supabase Entry** in `slsa_audit_metrics` table

---

## 📊 Monitor Metrics

```sql
-- Success rate
SELECT * FROM v_ops_slsa_audit_kpi
ORDER BY date DESC
LIMIT 30;

-- Recent failures
SELECT * FROM v_ops_slsa_audit_failures
LIMIT 10;
```

---

## 🆘 Troubleshooting

### Workflow not triggering?

- Check workflow file is in `.github/workflows/`
- Verify workflow syntax is valid
- Check GitHub Actions is enabled

### Supabase verification fails?

- Verify `SUPABASE_URL` and `SUPABASE_SERVICE_KEY` are set
- Check Supabase RLS policies
- Verify network connectivity

### PR comment not posted?

- Verify `pull-requests: write` permission
- Check PR number is correct (default: 61)
- Review workflow logs

---

**For detailed documentation, see**:
- `docs/ops/PHASE3_RUNBOOK.md` - Full runbook
- `docs/ops/PHASE3_ENV_SETUP.md` - Environment setup
- `docs/ops/PHASE3_IMPLEMENTATION_SUMMARY.md` - Implementation details

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
