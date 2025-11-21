---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# Phase 2.1 Current Status Report

**Date**: 2025-11-13
**Branch**: feature/slsa-phase2.1-hardened
**PR**: #61

---

## ⚠️ Execution Status

### workflow_dispatch Recognition Issue

**Problem**: `workflow_dispatch` trigger is not recognized on feature branch
- **Error**: HTTP 422 - Workflow does not have 'workflow_dispatch' trigger
- **Attempts**: 20 retries over 10 minutes
- **Status**: Still not recognized

**Root Cause**: GitHub Actions may take time to recognize workflow files on new branches (typically 5-10 minutes, but can take longer)

**Solution**: Manual execution via GitHub UI is required

---

## 📊 Latest Runs (Push Events - Skipped)

### slsa-provenance.yml
- **Run ID**: 19302690592
- **Event**: push
- **Status**: completed
- **Conclusion**: failure (expected - push events are skipped)
- **URL**: https://github.com/shochaso/starlist-app/actions/runs/19302690592
- **Artifacts**: None (run was skipped)

### provenance-validate.yml
- **Run ID**: 19302692281
- **Event**: workflow_run (triggered by slsa-provenance)
- **Status**: completed
- **Conclusion**: failure (expected - no artifacts to validate)
- **URL**: https://github.com/shochaso/starlist-app/actions/runs/19302692281

**Note**: These runs are expected to fail/skip as they were triggered by push events, not workflow_dispatch.

---

## 🚀 Required Action: Manual Execution

### Step-by-Step Instructions

1. **Navigate to Actions**
   - URL: https://github.com/shochaso/starlist-app/actions/workflows/slsa-provenance.yml

2. **Run Success Case**
   - Click "Run workflow" button (top right)
   - Select branch: `feature/slsa-phase2.1-hardened`
   - Enter tag: `v2025.11.13-success`
   - Click "Run workflow"

3. **Wait for Completion**
   - Expected duration: 2-3 minutes
   - Monitor run status

4. **Collect Run ID**
   - Copy Run ID from run page
   - Report back with Run URL and ID

5. **Repeat for Failure and Concurrency Cases**

---

## 📋 Test Execution Checklist

- [ ] Success Case executed via GitHub UI
- [ ] Success Case Run ID collected
- [ ] Success Case artifacts verified
- [ ] Success Case manifest entry verified
- [ ] Failure Case executed via GitHub UI
- [ ] Failure Case Issue created verified
- [ ] Failure Case Slack notification verified
- [ ] Concurrency Case executed via GitHub UI
- [ ] Concurrency Case manifest integrity verified
- [ ] All evidence collected and reported

---

## 📊 Evidence Collection Script

After test execution, run:
```bash
./scripts/collect_phase2_1_evidence.sh
```

Or manually collect using the commands in `PHASE2_1_EVIDENCE_COLLECTION.md`.

---

**Status**: ⏳ Waiting for manual execution via GitHub UI

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
