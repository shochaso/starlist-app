---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# Phase 2.1 Test Execution Log

**Date**: 2025-11-13
**Branch**: feature/slsa-phase2.1-hardened

---

## Execution Attempts

### Attempt 1: CLI Execution
- **Time**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
- **Method**: `gh workflow run slsa-provenance.yml --ref feature/slsa-phase2.1-hardened -f tag=v2025.11.13-success`
- **Result**: ❌ HTTP 422 - Workflow does not have 'workflow_dispatch' trigger
- **Reason**: GitHub Actions may not recognize workflow files on feature branch immediately after push

### Attempt 2: Manual Execution via GitHub UI (Recommended)
- **Status**: ⏳ Pending
- **Instructions**: 
  1. Navigate to: https://github.com/shochaso/starlist-app/actions/workflows/slsa-provenance.yml
  2. Click "Run workflow"
  3. Select branch: `feature/slsa-phase2.1-hardened`
  4. Enter tag: `v2025.11.13-success`
  5. Click "Run workflow"

---

## Test Cases Status

### ✅ Success Case
- **Status**: ⏳ Waiting for manual execution
- **Tag**: v2025.11.13-success
- **Expected**: Artifact generation, manifest entry, Supabase sync, validation

### ⚠️ Failure Case
- **Status**: ⏳ Waiting for Success Case completion
- **Tag**: v2025.11.13-fail
- **Expected**: Issue creation, Slack notification, manifest skip

### 🧩 Concurrency Case
- **Status**: ⏳ Waiting for Success/Failure Case completion
- **Tags**: v2025.11.13-concurrent-1/2/3
- **Expected**: No duplicates, atomic manifest writes

---

## Evidence Collection

After test execution, run:
```bash
./scripts/collect_phase2_1_evidence.sh
```

Or manually collect:
1. Run IDs from GitHub Actions
2. Artifacts via `gh run download`
3. Manifest entries from `docs/reports/<date>/manifest.json`
4. Supabase rows (if credentials available)
5. Branch protection settings

---

**Note**: This log will be updated as tests are executed.

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
