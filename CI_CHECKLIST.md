---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# Phase 4 CI Verification Checklist

## Pre-Merge Checks

- [ ] Workflow files lint successfully (`yamllint` or GitHub Actions UI)
- [ ] TypeScript compiles (`npx tsc --noEmit`)
- [ ] Unit tests pass (`npm test`)
- [ ] No secret values in code (grep for patterns)
- [ ] Dry-run mode works (`npm run phase4:observer -- --dry-run`)

## Post-Merge Verification (Same Day)

### 1. Guard Workflow

```bash
# Trigger guard workflow
gh workflow run phase4-retry-guard.yml

# Expected: Failure without secrets
# Expected: Success with secrets
# Expected: No secret values in logs
```

### 2. Auto-Audit Workflow

```bash
# Trigger auto-audit workflow
gh workflow run phase4-auto-audit.yml \
  --field window_days=7 \
  --field run_mode=full

# Expected: Guard job passes
# Expected: Observer job runs
# Expected: Collector job runs
# Expected: KPI job runs
```

### 3. Artifact Verification

```bash
# Check artifacts generated
gh run list --workflow phase4-auto-audit.yml --limit 1
RUN_ID=$(gh run list --workflow phase4-auto-audit.yml --json databaseId -q '.[0].databaseId')
gh run download $RUN_ID

# Expected: Artifacts in docs/reports/<date>/
# Expected: _manifest.json exists
# Expected: RUNS_SUMMARY.json exists
# Expected: PHASE3_AUDIT_SUMMARY.md exists
```

### 4. Log Verification

```bash
# Check logs for secret values
gh run view $RUN_ID --log | grep -i "secret\|key\|token" | grep -v "MASKED\|ci-guard"

# Expected: No secret values found
```

## Rollback Procedure

If verification fails:

1. Disable workflows:
   ```bash
   git mv .github/workflows/phase4-retry-guard.yml .github/workflows/phase4-retry-guard.yml.disabled
   git mv .github/workflows/phase4-auto-audit.yml .github/workflows/phase4-auto-audit.yml.disabled
   git commit -m "chore: disable Phase 4 workflows"
   git push
   ```

2. Revert commits:
   ```bash
   git revert <commit-sha>
   git push
   ```

3. Remove secrets (if needed):
   ```bash
   gh secret delete SUPABASE_SERVICE_KEY --repo <repo>
   gh secret delete SLACK_WEBHOOK_URL --repo <repo>
   ```

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
