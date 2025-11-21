---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# Phase 2.1 Validation Suite

## 🎯 Test Objectives

1. **Success Case**: Verify hardened workflow with per-job permissions, atomic manifest, run_id in artifact
2. **Failure Case**: Verify dual alert (Issue + Slack) with enhanced error messages
3. **Concurrency Case**: Verify atomic manifest write prevents race conditions

## 📋 Test Commands

### 1. Success Case Test

```bash
# Trigger workflow with valid tag
gh workflow run slsa-provenance.yml -f tag=v2025.11.13-hardened-success

# Wait for completion and get run ID
RUN_ID=$(gh run list --workflow=slsa-provenance.yml --limit 1 --json databaseId -q '.[0].databaseId')

# Verify provenance artifact includes run_id in path
gh run download $RUN_ID --dir /tmp/provenance-test
ls -la /tmp/provenance-test/artifacts/slsa/v2025.11.13-hardened-success/$RUN_ID/

# Verify manifest entry
cat docs/reports/$(date +%Y-%m-%d)/manifest.json | jq '.[] | select(.tag == "v2025.11.13-hardened-success")'

# Verify per-job permissions (check logs)
gh run view $RUN_ID --log | grep -i "permission"

# Verify validation workflow runs
gh run list --workflow=provenance-validate.yml --limit 1
```

**Expected Results:**
- ✅ Provenance artifact at `artifacts/slsa/<tag>/<run_id>/provenance-<tag>-<run_id>.json`
- ✅ Manifest entry created atomically
- ✅ Per-job permissions applied correctly
- ✅ Validation workflow runs automatically
- ✅ Supabase row inserted

### 2. Failure Case Test

```bash
# Trigger workflow with invalid tag (will fail)
gh workflow run slsa-provenance.yml -f tag=v2025.11.13-hardened-fail

# Wait for failure and get run ID
RUN_ID=$(gh run list --workflow=slsa-provenance.yml --limit 1 --json databaseId -q '.[0].databaseId')

# Check for Issue creation with enhanced message
gh issue list --label "provenance-failure" --limit 1 --json number,title,body

# Verify Issue contains actionable next steps
ISSUE_NUM=$(gh issue list --label "provenance-failure" --limit 1 --json number -q '.[0].number')
gh issue view $ISSUE_NUM

# Check Slack notification (if configured)
# Verify dual alert: Issue + Slack both triggered
```

**Expected Results:**
- ✅ Workflow fails gracefully
- ✅ Issue created with enhanced error message and next steps
- ✅ Slack notification sent with Issue number and URL
- ✅ Dual alert confirmed (Issue + Slack)

### 3. Concurrency Case Test

```bash
# Trigger multiple workflows simultaneously
gh workflow run slsa-provenance.yml -f tag=v2025.11.13-hardened-concurrent-1 &
gh workflow run slsa-provenance.yml -f tag=v2025.11.13-hardened-concurrent-2 &
gh workflow run slsa-provenance.yml -f tag=v2025.11.13-hardened-concurrent-3 &
wait

# Check manifest for atomic writes (no duplicates, no corruption)
cat docs/reports/$(date +%Y-%m-%d)/manifest.json | jq '[.[] | select(.tag | startswith("v2025.11.13-hardened-concurrent"))] | length'

# Verify all runs completed successfully
gh run list --workflow=slsa-provenance.yml --limit 10 --json databaseId,conclusion,displayTitle

# Verify manifest integrity (valid JSON, no duplicates)
cat docs/reports/$(date +%Y-%m-%d)/manifest.json | jq '. | length'
cat docs/reports/$(date +%Y-%m-%d)/manifest.json | jq '[.[] | .run_id] | unique | length'
```

**Expected Results:**
- ✅ All workflows complete successfully
- ✅ No duplicate manifest entries
- ✅ Manifest JSON is valid and consistent
- ✅ Atomic writes prevent race conditions
- ✅ Concurrency groups prevent conflicts

## 🔍 Validation Checklist

### Per-Job Permissions
- [ ] Workflow-level permissions minimized
- [ ] Job-level permissions applied correctly
- [ ] commit-manifest job has separate write permissions
- [ ] No excessive permissions in any job

### Artifact Path with run_id
- [ ] Artifact path includes run_id: `artifacts/slsa/<tag>/<run_id>/provenance-<tag>-<run_id>.json`
- [ ] Artifact name includes run_id: `provenance-<tag>-<run_id>`
- [ ] Retention set to 365 days

### Atomic Manifest Write
- [ ] Manifest write uses temp file + atomic move
- [ ] No race conditions in concurrent runs
- [ ] Manifest schema validated against provenance-manifest-schema.json
- [ ] No duplicate entries for same run_id

### Notify-on-Failure (Dual Alert)
- [ ] Issue created with enhanced error message
- [ ] Issue includes actionable next steps
- [ ] Slack notification sent with Issue number and URL
- [ ] Both alerts triggered (Issue + Slack)

### Supabase Integration
- [ ] Supabase row inserted correctly
- [ ] Narrow-scope service key used
- [ ] RLS policies working correctly

### Branch Protection
- [ ] provenance-validate.yml registered as required check (manual step)
- [ ] Validation workflow runs automatically after provenance generation

## 📊 Test Results Template

### Success Case
- **Run ID**: `1234567890`
- **Tag**: `v2025.11.13-hardened-success`
- **Artifact Path**: `artifacts/slsa/v2025.11.13-hardened-success/1234567890/provenance-v2025.11.13-hardened-success-1234567890.json`
- **Manifest Entry**: ✅ Created atomically
- **Per-Job Permissions**: ✅ Applied correctly
- **Validation**: ✅ Passed
- **Supabase Row**: ✅ Inserted

### Failure Case
- **Run ID**: `1234567891`
- **Tag**: `v2025.11.13-hardened-fail`
- **Issue Created**: ✅ #XXX with enhanced message
- **Slack Notification**: ✅ Sent with Issue number
- **Dual Alert**: ✅ Confirmed

### Concurrency Case
- **Run IDs**: `1234567892`, `1234567893`, `1234567894`
- **Tags**: `v2025.11.13-hardened-concurrent-1/2/3`
- **All Completed**: ✅
- **No Duplicates**: ✅
- **Manifest Integrity**: ✅ Valid JSON, no corruption
- **Atomic Writes**: ✅ Confirmed

## 🚀 Execution Plan

1. **Pre-test**: Verify branch protection registration (manual)
2. **Success Test**: Run with valid tag, verify all hardened features
3. **Failure Test**: Run with invalid tag, verify dual alert
4. **Concurrency Test**: Run multiple workflows simultaneously
5. **Post-test**: Document results with run IDs and artifacts

## 📝 Notes

- Branch protection registration must be done manually via GitHub UI
- Slack notifications require SUPABASE_URL and SUPABASE_ANON_KEY secrets
- Supabase sync requires SUPABASE_SERVICE_ROLE_KEY secret
- All tests should be run on feature branch before merging to main

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
