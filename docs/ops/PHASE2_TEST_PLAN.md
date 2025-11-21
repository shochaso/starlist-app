---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# Phase 2 Test Plan

## 🎯 Test Objectives

1. **Success Case**: Verify provenance generation, manifest update, Supabase sync, and validation
2. **Failure Case**: Verify failure notifications (Issue + Slack)
3. **Concurrency Case**: Verify manifest atomic append and no duplicates

## 📋 Test Commands

### 1. Success Case Test

```bash
# Trigger workflow with valid tag
gh workflow run slsa-provenance.yml -f tag=v2025.11.13-success

# Wait for completion and get run ID
RUN_ID=$(gh run list --workflow=slsa-provenance.yml --limit 1 --json databaseId -q '.[0].databaseId')

# Verify provenance
./scripts/verify_slsa_provenance.sh $RUN_ID v2025.11.13-success

# Check manifest entry
cat docs/reports/$(date +%Y-%m-%d)/manifest.json | jq '.[] | select(.tag == "v2025.11.13-success")'

# Check Supabase (via SQL or dashboard)
# SELECT * FROM slsa_runs WHERE tag = 'v2025.11.13-success';
```

**Expected Results:**
- ✅ Provenance artifact generated
- ✅ SHA256 calculated correctly
- ✅ Manifest entry created
- ✅ Supabase row inserted
- ✅ Validation workflow runs successfully
- ✅ Slack notification sent (if configured)

### 2. Failure Case Test

```bash
# Trigger workflow with invalid tag (will fail)
gh workflow run slsa-provenance.yml -f tag=v2025.11.13-fail

# Wait for failure and get run ID
RUN_ID=$(gh run list --workflow=slsa-provenance.yml --limit 1 --json databaseId -q '.[0].databaseId')

# Check for Issue creation
gh issue list --label "provenance-failure" --limit 1

# Check Slack notification (if configured)
# Check Supabase for failure entry
# SELECT * FROM slsa_runs WHERE tag = 'v2025.11.13-fail' AND status = 'failure';
```

**Expected Results:**
- ✅ Workflow fails gracefully
- ✅ Issue created with label `provenance-failure`
- ✅ Slack notification sent (if configured)
- ✅ Manifest entry has `status=failure`
- ✅ Supabase row inserted with failure status

### 3. Concurrency Case Test

```bash
# Trigger multiple workflows simultaneously
gh workflow run slsa-provenance.yml -f tag=v2025.11.13-concurrent-1 &
gh workflow run slsa-provenance.yml -f tag=v2025.11.13-concurrent-2 &
gh workflow run slsa-provenance.yml -f tag=v2025.11.13-concurrent-3 &
wait

# Check manifest for duplicates
cat docs/reports/$(date +%Y-%m-%d)/manifest.json | jq '[.[] | select(.tag | startswith("v2025.11.13-concurrent"))] | length'

# Verify all runs completed
gh run list --workflow=slsa-provenance.yml --limit 10
```

**Expected Results:**
- ✅ All workflows complete successfully
- ✅ No duplicate manifest entries
- ✅ Concurrency groups prevent conflicts
- ✅ All Supabase rows inserted correctly

## 🔍 Validation Checklist

### Provenance Artifact
- [ ] `predicateType` = `https://slsa.dev/provenance/v0.2`
- [ ] `builder.id` = `github-actions/slsa-provenance`
- [ ] `invocation.release` matches tag
- [ ] SHA256 calculated correctly

### Manifest Entry
- [ ] Entry created in `docs/reports/<date>/manifest.json`
- [ ] `run_id`, `tag`, `sha`, `status` present
- [ ] `governance_flag` = `provenance-ready`
- [ ] Git commit succeeds (or fails gracefully)

### Supabase Integration
- [ ] Row inserted in `slsa_runs` table
- [ ] `run_id`, `tag`, `sha256`, `status` correct
- [ ] `v_ops_slsa_status` view updated
- [ ] RLS policies working correctly

### Validation Workflow
- [ ] `provenance-validate.yml` runs after `slsa-provenance.yml`
- [ ] All validations pass
- [ ] Supabase report sent

### Notifications
- [ ] Success: Slack notification sent (if configured)
- [ ] Failure: Issue created with correct labels
- [ ] Failure: Slack notification sent (if configured)

## 📊 Test Results Template

### Success Case
- **Run ID**: `1234567890`
- **Tag**: `v2025.11.13-success`
- **SHA256**: `abc123...`
- **Manifest Entry**: ✅ Created
- **Supabase Row**: ✅ Inserted
- **Validation**: ✅ Passed
- **Slack Notification**: ✅ Sent

### Failure Case
- **Run ID**: `1234567891`
- **Tag**: `v2025.11.13-fail`
- **Issue Created**: ✅ #XXX
- **Slack Notification**: ✅ Sent
- **Manifest Entry**: ✅ `status=failure`

### Concurrency Case
- **Run IDs**: `1234567892`, `1234567893`, `1234567894`
- **Tags**: `v2025.11.13-concurrent-1/2/3`
- **All Completed**: ✅
- **No Duplicates**: ✅
- **Manifest Entries**: ✅ 3 entries

## 🚀 Next Steps After Testing

1. Document test results with run IDs
2. Verify artifacts and SHA256 values
3. Confirm Supabase KPI view accuracy
4. Proceed to Phase 3 (Dashboard/Visualization)

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
