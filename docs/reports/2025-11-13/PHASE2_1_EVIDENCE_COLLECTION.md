---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# Phase 2.1 Verification Evidence Collection

**Collection Date**: 2025-11-13
**Branch**: feature/slsa-phase2.1-hardened
**PR**: #61

---

## 1. Run IDs and Artifacts

### Current Status
- **Latest Run ID**: 19302628134 (push event - skipped)
- **Workflow**: slsa-provenance.yml
- **Status**: completed (failure - expected, as push events are skipped)
- **Artifacts**: None (run was skipped)

### Execution Method
Due to `workflow_dispatch` not being recognized on feature branch immediately after push, manual execution via GitHub UI is required:

1. Navigate to: https://github.com/shochaso/starlist-app/actions/workflows/slsa-provenance.yml
2. Click "Run workflow"
3. Select branch: `feature/slsa-phase2.1-hardened`
4. Enter tag: `v2025.11.13-success`
5. Click "Run workflow"

---

## 2. SHA256 Consistency Check

**Status**: Pending - No artifacts available yet

**Expected Check**:
```bash
# After artifact download
sha256sum artifacts/slsa/<tag>/<run_id>/provenance-<tag>-<run_id>.json
```

---

## 3. Manifest.json Diff (Last 10 lines)

**Status**: No manifest entries created yet

**Expected Location**: `docs/reports/2025-11-13/manifest.json`

**Expected Format**:
```json
[
  {
    "run_id": 123456789,
    "tag": "v2025.11.13-success",
    "sha": "aabbccddeeff...",
    "artifact_url": "https://github.com/.../actions/runs/123456789",
    "actor": "github-actions[bot]",
    "timestamp": "2025-11-13T00:00:00Z",
    "status": "success",
    "governance_flag": "provenance-ready",
    "release_url": "https://github.com/.../releases/tag/v2025.11.13-success"
  }
]
```

---

## 4. Supabase slsa_runs Table (Last 5 entries)

**Status**: Requires environment variables

**Required**: 
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`

**Query**:
```sql
SELECT * FROM slsa_runs ORDER BY created_at DESC LIMIT 5;
```

**Expected Columns**:
- run_id
- tag
- sha256
- status
- governance_flag
- validated_status
- created_at

---

## 5. Branch Protection Settings

**Current Required Checks**:
```bash
gh api repos/shochaso/starlist-app/branches/main/protection --jq '.required_status_checks.contexts'
```

**Expected**: 
- `build`
- `check`
- `provenance-validate` (to be added)

**Manual Registration**:
1. Go to Repository Settings → Branches → Branch protection rules
2. Edit protection rule for `main` branch
3. Under "Require status checks to pass before merging":
   - Add `provenance-validate` as a required check

---

## 📋 Collection Script

Use `scripts/collect_phase2_1_evidence.sh` to collect evidence:

```bash
export SUPABASE_URL="your-supabase-url"
export SUPABASE_SERVICE_KEY="your-service-key"
./scripts/collect_phase2_1_evidence.sh
```

---

**Note**: Evidence collection will be updated after test execution via GitHub UI.

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
