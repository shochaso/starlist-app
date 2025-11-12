# Phase 2.1 Execution Status

**Date**: 2025-11-13
**Branch**: feature/slsa-phase2.1-hardened

---

## ⚠️ Current Issue

`workflow_dispatch` trigger is not immediately recognized on feature branch after push.

**Error**: `HTTP 422: Workflow does not have 'workflow_dispatch' trigger`

**Root Cause**: GitHub Actions may take time to recognize workflow files on new branches.

---

## ✅ Solution: Manual Execution via GitHub UI

### Step-by-Step Instructions

1. **Navigate to Actions**
   - Go to: https://github.com/shochaso/starlist-app/actions/workflows/slsa-provenance.yml

2. **Run Workflow**
   - Click "Run workflow" button (top right)
   - Select branch: `feature/slsa-phase2.1-hardened`
   - Enter tag: `v2025.11.13-success`
   - Click "Run workflow"

3. **Wait for Completion**
   - Monitor run status
   - Expected duration: 2-3 minutes

4. **Collect Run ID**
   - Copy Run ID from run page
   - Use for evidence collection

---

## 📋 Test Execution Order

1. **Success Case**: `v2025.11.13-success`
2. **Failure Case**: `v2025.11.13-fail`
3. **Concurrency Case**: `v2025.11.13-concurrent-1/2/3`

---

## 🔍 After Execution: Evidence Collection

```bash
# Set environment variables (if available)
export SUPABASE_URL="your-url"
export SUPABASE_SERVICE_KEY="your-key"

# Run evidence collection script
./scripts/collect_phase2_1_evidence.sh

# Or manually collect:
# 1. Get Run ID
RUN_ID=$(gh run list --workflow=slsa-provenance.yml --limit 1 --json databaseId -q '.[0].databaseId')

# 2. Download artifacts
gh run download $RUN_ID --dir /tmp/provenance-test

# 3. Verify SHA256
find /tmp/provenance-test -name "provenance-*.json" -exec sha256sum {} \;

# 4. Check manifest
cat docs/reports/$(date +%Y-%m-%d)/manifest.json | jq '.[] | select(.tag == "v2025.11.13-success")'
```

---

## 📊 Report Template

After execution, report results in this format:

```markdown
### 🧩 Success Case
- Run ID: 123456789
- Tag: v2025.11.13-success
- SHA256: aabbccddeeff...
- Manifest Entry: present ✅
- Supabase Row: inserted ✅
- Validation: passed ✅
```

---

**Status**: ⏳ Waiting for manual execution via GitHub UI
