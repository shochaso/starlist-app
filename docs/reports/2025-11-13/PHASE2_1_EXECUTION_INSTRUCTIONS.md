# Phase 2.1 Execution Instructions

**Important**: Due to `workflow_dispatch` not being recognized on feature branch, manual execution via GitHub UI is required.

---

## 🎯 Quick Start

1. **Open**: https://github.com/shochaso/starlist-app/actions/workflows/slsa-provenance.yml
2. **Click**: "Run workflow" (top right)
3. **Select**: Branch `feature/slsa-phase2.1-hardened`
4. **Enter**: Tag `v2025.11.13-success`
5. **Click**: "Run workflow"
6. **Wait**: 2-3 minutes for completion
7. **Report**: Run URL and Run ID back here

---

## 📋 Test Cases

### 1. Success Case
- **Tag**: `v2025.11.13-success`
- **Expected**: Artifact generation, manifest entry, Supabase sync, validation

### 2. Failure Case
- **Tag**: `v2025.11.13-fail`
- **Expected**: Issue creation, Slack notification, manifest skip

### 3. Concurrency Case
- **Tags**: `v2025.11.13-concurrent-1`, `v2025.11.13-concurrent-2`, `v2025.11.13-concurrent-3`
- **Execute**: All 3 simultaneously via GitHub UI
- **Expected**: No duplicates, atomic manifest writes

---

## 📊 Report Template

After execution, report in this format:

```markdown
### ✅ Success Run
- Run URL: https://github.com/.../actions/runs/123456789
- Run ID: 123456789
- Artifacts: (ls -la / wc -c output)
- JSON (head -n 40): (provenance JSON content)
- SHA256 file: (sha256sum output)
- provenance-validate run result: (validation run URL/ID)

### ⚠️ Failure Run
- Run URL: https://github.com/.../actions/runs/987654321
- Run ID: 987654321
- Issue URL: https://github.com/.../issues/62
- Slack message ID / Screenshot: (if available)
- notify-on-failure job excerpt: (job log excerpt)

### 🧩 Concurrency Runs
- Run URL (1): https://github.com/.../actions/runs/111111111
- Run URL (2): https://github.com/.../actions/runs/222222222
- Run URL (3): https://github.com/.../actions/runs/333333333
- Manifest entries: (docs/reports/<date>/manifest.json excerpt)

### 🗄️ Supabase / Branch Protection
- Supabase slsa_runs (last 5): (SQL query results)
- Branch protection (required checks): (gh api output)
```

---

**Note**: All test execution must be done via GitHub UI until workflow_dispatch is recognized on the branch.
