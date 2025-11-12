# Phase 2.1 Validation Suite Report

**Date**: 2025-11-13
**Branch**: feature/slsa-phase2.1-hardened
**PR**: #61

---

## ⚠️ Current Status

**Issue**: `workflow_dispatch` trigger is not recognized on feature branch immediately after push.

**Workaround Required**: 
- Execute via GitHub UI (recommended)
- Or merge PR and execute on main branch
- Or trigger via release event

---

## 🧩 Success Case

- Run ID: (Pending - requires manual execution via GitHub UI)
- Tag: v2025.11.13-success
- SHA256: (Pending)
- Manifest Entry: (Pending)
- Supabase Row: (Pending)
- Validation: (Pending)

**Status**: ⏳ Waiting for manual execution

**Execution Method**: 
1. Go to Actions → slsa-provenance → Run workflow
2. Select branch: `feature/slsa-phase2.1-hardened`
3. Enter tag: `v2025.11.13-success`
4. Click "Run workflow"

---

## ⚠ Failure Case

- Run ID: (Pending)
- Tag: v2025.11.13-fail
- Issue: (Pending)
- Slack: (Pending)
- Manifest: (Pending)

**Status**: ⏳ Waiting for Success Case completion

---

## 🚧 Concurrency Case

- Run IDs: (Pending)
- Tag: v2025.11.13-concurrent-*
- Artifact Duplication: (Pending)
- Manifest Entries: (Pending)
- Supabase Rows: (Pending)

**Status**: ⏳ Waiting for Success/Failure Case completion

---

# Phase 2.1 Verification Evidence

## 1. Run IDs and Artifacts

### Latest Runs (from push events - skipped)
- Run ID: 19302628134 (push event - skipped)
- Run ID: 19302542584 (push event - skipped)
- Run ID: 19302476936 (push event - skipped)

**Note**: These runs were triggered by push events and skipped provenance generation (expected behavior).

### Artifact Paths
- No artifacts generated (runs were skipped due to push event)

## 2. SHA256 Consistency Check

- No artifacts available for verification

## 3. Manifest.json Diff (Last 10 lines)

```json
(No manifest entries created yet - waiting for workflow_dispatch execution)
```

## 4. Supabase slsa_runs Table (Last 5 entries)

```json
(Requires SUPABASE_URL and SUPABASE_SERVICE_KEY environment variables)
```

**Query**: 
```sql
SELECT * FROM slsa_runs ORDER BY created_at DESC LIMIT 5;
```

## 5. Branch Protection Settings

**Current Required Checks**:
```json
(To be retrieved via: gh api repos/shochaso/starlist-app/branches/main/protection)
```

**Expected**: `provenance-validate` should be added as required check

---

## 📋 Next Steps

1. **Execute Success Case** via GitHub UI
2. **Wait for completion** and collect Run ID
3. **Verify artifacts** and SHA256
4. **Check manifest entry** creation
5. **Execute Failure Case** via GitHub UI
6. **Execute Concurrency Case** via GitHub UI
7. **Collect all evidence** using `scripts/collect_phase2_1_evidence.sh`

---

**Note**: This report will be updated as test execution progresses.
