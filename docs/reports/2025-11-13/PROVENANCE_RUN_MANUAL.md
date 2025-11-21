---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# Provenance Run Manual Execution Guide

**Purpose**: Step-by-step guide for manual execution of provenance workflows via UI and CLI.

**Last Updated**: 2025-11-13 (UTC)

---

## Prerequisites

- GitHub repository access
- GitHub CLI (`gh`) installed and authenticated
- Workflow files present in `.github/workflows/`

---

## Method 1: GitHub UI Execution

### Step-by-Step Instructions

1. **Navigate to Actions**
   - Go to: https://github.com/shochaso/starlist-app/actions/workflows/slsa-provenance.yml

2. **Click "Run workflow"**
   - Located in the top right corner
   - Dropdown will appear

3. **Select Branch**
   - Choose: `feature/slsa-phase2.1-hardened` (or `main` after merge)
   - Default: `main`

4. **Enter Tag**
   - Input field: `tag`
   - Example: `v2025.11.13-success-test`
   - Required: No (optional)

5. **Click "Run workflow"**
   - Workflow will start immediately
   - Run ID will be displayed

6. **Monitor Execution**
   - Click on the run to view logs
   - Wait for completion (typically 2-3 minutes)

7. **Collect Results**
   - Copy Run URL
   - Download artifacts if available
   - Record Run ID and conclusion

---

## Method 2: CLI Execution

### Basic Command

```bash
gh workflow run slsa-provenance.yml \
  --ref feature/slsa-phase2.1-hardened \
  -f tag=v2025.11.13-success-test
```

### With Specific Branch

```bash
gh workflow run .github/workflows/slsa-provenance.yml \
  --ref feature/slsa-phase2.1-hardened \
  -f tag=v2025.11.13-success-test
```

### Check Run Status

```bash
# List recent runs
gh run list --workflow=slsa-provenance.yml --limit 5

# View specific run
gh run view [RUN_ID] --json conclusion,status,displayTitle,url

# Download artifacts
gh run download [RUN_ID] --name provenance-[TAG] --dir /tmp/artifacts
```

---

## Execution Scenarios

### Success Case

```bash
# Tag for success case
TAG="v2025.11.13-success-test"

# Execute
gh workflow run slsa-provenance.yml \
  --ref feature/slsa-phase2.1-hardened \
  -f tag="${TAG}"

# Wait and check
sleep 30
RUN_ID=$(gh run list --workflow=slsa-provenance.yml --limit 1 --json databaseId -q '.[0].databaseId')
gh run watch "${RUN_ID}"
```

### Failure Case

```bash
# Tag for failure case
TAG="v2025.11.13-fail-test"

# Execute
gh workflow run slsa-provenance.yml \
  --ref feature/slsa-phase2.1-hardened \
  -f tag="${TAG}"

# Monitor for failure
RUN_ID=$(gh run list --workflow=slsa-provenance.yml --limit 1 --json databaseId -q '.[0].databaseId')
gh run view "${RUN_ID}" --log-failed
```

### Concurrency Case

```bash
# Execute 3 runs simultaneously
for i in 1 2 3; do
  gh workflow run slsa-provenance.yml \
    --ref feature/slsa-phase2.1-hardened \
    -f tag="v2025.11.13-concurrent-${i}" &
done
wait

# Check concurrency behavior
gh run list --workflow=slsa-provenance.yml --limit 10
```

---

## Troubleshooting

### Issue: HTTP 422 - Workflow does not have 'workflow_dispatch' trigger

**Cause**: Workflow file not recognized on branch or default branch doesn't have workflow_dispatch.

**Solutions**:
1. Merge PR to `main` branch
2. Wait 5-10 minutes for GitHub to recognize workflow
3. Use GitHub UI instead of CLI
4. Verify workflow file syntax is correct

### Issue: Run starts but fails immediately

**Cause**: Missing required inputs or invalid tag.

**Solutions**:
1. Verify tag exists: `git tag | grep [TAG]`
2. Check workflow inputs are correct
3. Review workflow logs for specific error

### Issue: Artifacts not found

**Cause**: Run failed or artifacts expired.

**Solutions**:
1. Check run conclusion: `gh run view [RUN_ID] --json conclusion`
2. Verify run completed successfully
3. Check artifact retention period (default: 90 days)

---

## Evidence Collection

After execution, collect:

1. **Run URL**: `https://github.com/shochaso/starlist-app/actions/runs/[RUN_ID]`
2. **Run ID**: Numeric ID from run URL
3. **Artifacts**: List of artifact names
4. **Conclusion**: success/failure/skipped
5. **Execution Time**: Start and end timestamps
6. **Logs**: Relevant log excerpts

---

## Rollback Procedure

If execution causes issues:

1. **Cancel Running Workflow**
   ```bash
   gh run cancel [RUN_ID]
   ```

2. **Revert Workflow File**
   ```bash
   git checkout HEAD~1 .github/workflows/slsa-provenance.yml
   git commit -m "revert: workflow changes"
   ```

3. **Disable Workflow** (temporary)
   - Go to Actions → Workflows → slsa-provenance
   - Click "..." → Disable workflow

---

**Note**: This manual is for reference. Actual execution results should be recorded in `PHASE2_2_VALIDATION_REPORT.md`.

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
