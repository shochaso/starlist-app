# Day 11 State of Truth - Rollback Procedures

**Date**: 2025-11-13 (UTC)
**Purpose**: Centralized rollback procedures for all changes made during Phase 2/3 implementation.

---

## Rollback Procedures

### 1. Secrets Invalidation

**Purpose**: Disable secrets if they are compromised or need to be rotated.

**Steps**:

```bash
# List current secrets
gh secret list

# Delete specific secret
gh secret delete SUPABASE_URL
gh secret delete SUPABASE_SERVICE_KEY
gh secret delete SLACK_WEBHOOK_URL

# Verify deletion
gh secret list
```

**Impact**: Workflows requiring secrets will fail. Update workflows to handle missing secrets gracefully.

**Recovery**: Re-add secrets with new values via GitHub UI or CLI.

---

### 2. Workflow Temporary Disable

**Purpose**: Temporarily disable workflows without deleting files.

**Steps**:

#### Via GitHub UI

1. Go to Actions → Workflows
2. Select workflow (e.g., `slsa-provenance.yml`)
3. Click "..." → Disable workflow

#### Via API

```bash
# Disable workflow (requires workflow file rename or deletion)
# Note: GitHub doesn't have direct disable API, so rename file instead

git mv .github/workflows/slsa-provenance.yml .github/workflows/slsa-provenance.yml.disabled
git commit -m "chore: temporarily disable slsa-provenance workflow"
git push
```

**Impact**: Workflow will not trigger. Existing runs will continue.

**Recovery**: Rename file back or re-enable via UI.

---

### 3. PR Revert

**Purpose**: Revert changes from a merged PR.

**Steps**:

```bash
# Find merge commit
git log --oneline --grep="Phase 2" | head -5

# Revert merge commit
git revert -m 1 [MERGE_COMMIT_SHA]

# Push revert
git push origin main
```

**Impact**: All changes from PR are reverted. May require manual conflict resolution.

**Recovery**: Re-apply changes manually or create new PR.

---

### 4. Branch Protection Rollback

**Purpose**: Remove provenance-validate from required checks.

**Steps**:

```bash
# Remove provenance-validate from required checks
gh api repos/shochaso/starlist-app/branches/main/protection \
  -X PATCH \
  -f required_status_checks[contexts][]=build \
  -f required_status_checks[contexts][]=check
# Note: Omit provenance-validate

# Or disable branch protection entirely
gh api repos/shochaso/starlist-app/branches/main/protection \
  -X DELETE
```

**Impact**: PRs can merge without provenance-validate passing.

**Recovery**: Re-add provenance-validate via GUI or API.

---

### 5. Supabase Table Rollback

**Purpose**: Remove audit metrics table if issues occur.

**Steps**:

```sql
-- Connect to Supabase SQL Editor
-- Drop views first
DROP VIEW IF EXISTS public.v_ops_slsa_audit_kpi;
DROP VIEW IF EXISTS public.v_ops_slsa_audit_failures;

-- Drop table
DROP TABLE IF EXISTS public.slsa_audit_metrics;

-- Verify
SELECT * FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name = 'slsa_audit_metrics';
```

**Impact**: Audit metrics will not be stored. Existing data is lost.

**Recovery**: Re-run migration: `supabase/ops/slsa_audit_metrics_table.sql`

---

### 6. Workflow File Rollback

**Purpose**: Revert workflow file changes.

**Steps**:

```bash
# View file history
git log --oneline -- .github/workflows/slsa-provenance.yml

# Revert to specific commit
git checkout [COMMIT_SHA] -- .github/workflows/slsa-provenance.yml

# Commit revert
git commit -m "revert: slsa-provenance.yml to [COMMIT_SHA]"
git push
```

**Impact**: Workflow behavior reverts to previous version.

**Recovery**: Re-apply changes or cherry-pick commits.

---

## Emergency Contacts

- **GitHub Admin**: [記録]
- **Supabase Admin**: [記録]
- **Slack Channel**: [記録]

---

## Rollback Decision Tree

```
Issue Detected
    │
    ├─ Secrets Compromised?
    │   └─→ Use Procedure #1 (Secrets Invalidation)
    │
    ├─ Workflow Failing Continuously?
    │   └─→ Use Procedure #2 (Workflow Disable)
    │
    ├─ PR Caused Issues?
    │   └─→ Use Procedure #3 (PR Revert)
    │
    ├─ Branch Protection Too Restrictive?
    │   └─→ Use Procedure #4 (Branch Protection Rollback)
    │
    ├─ Database Issues?
    │   └─→ Use Procedure #5 (Supabase Table Rollback)
    │
    └─ Workflow File Issues?
        └─→ Use Procedure #6 (Workflow File Rollback)
```

---

**Last Updated**: 2025-11-13
**Maintainer**: STARLIST Ops Team
