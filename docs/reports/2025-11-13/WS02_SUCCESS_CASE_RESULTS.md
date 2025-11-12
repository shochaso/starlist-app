# WS02: Success Case Execution Results

**Date**: 2025-11-13 (UTC)
**Collector**: Cursor AI

---

## Execution Status

**Current Status**: ⏳ Awaiting workflow_dispatch recognition

**Issue**: GitHub Actions does not recognize workflow_dispatch on feature branch immediately after push.

**Workaround**: 
- Merge PR to `main` branch (recommended)
- Use GitHub UI for manual execution
- Wait 5-10 minutes for GitHub to recognize workflow

---

## Execution Attempts

### Attempt 1: CLI Execution

```bash
gh workflow run slsa-provenance.yml \
  --ref feature/slsa-phase2.1-hardened \
  -f tag=v2025.11.13-success-test
```

**Result**: HTTP 422 - Workflow does not have 'workflow_dispatch' trigger

**Reason**: GitHub resolves dispatch events against default branch metadata, not the branch specified with `--ref`.

### Attempt 2: GitHub UI Execution

**Status**: ⏳ Pending

**Instructions**:
1. Navigate to: https://github.com/shochaso/starlist-app/actions/workflows/slsa-provenance.yml
2. Click "Run workflow"
3. Select branch: `feature/slsa-phase2.1-hardened` (or `main` after merge)
4. Enter tag: `v2025.11.13-success-test`
5. Click "Run workflow"

---

## Expected Results (After Execution)

Once workflow executes successfully:

- **Run URL**: [記録待ち]
- **Run ID**: [記録待ち]
- **Tag**: v2025.11.13-success-test
- **Artifacts**: 
  - `provenance-v2025.11.13-success-test`
  - `slsa-manifest-v2025.11.13-success-test`
- **SHA256**: [記録待ち]
- **PredicateType**: `https://slsa.dev/provenance/v0.2` (expected)
- **Conclusion**: success (expected)
- **Execution Time**: [記録待ち]

---

## Validation Checklist

After execution, verify:

- [ ] Run completed successfully
- [ ] Artifact downloaded
- [ ] SHA256 calculated
- [ ] PredicateType validated
- [ ] Manifest entry created
- [ ] Supabase entry created (if secrets configured)
- [ ] Validation workflow triggered

---

## Rollback Procedure

If execution causes issues:

1. **Cancel Run**
   ```bash
   gh run cancel [RUN_ID]
   ```

2. **Remove Artifacts** (if needed)
   - Go to Actions → Run → Artifacts
   - Delete artifacts manually

3. **Revert Manifest** (if needed)
   ```bash
   git checkout HEAD~1 docs/reports/_manifest.json
   git commit -m "revert: manifest entry"
   ```

---

**Status**: ⏳ Execution pending (workflow_dispatch recognition required)
