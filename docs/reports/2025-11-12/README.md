---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# Evidence Collection Execution Guide

**Date**: 2025-11-13 (UTC)
**Purpose**: One-pass execution guide for WS02-WS14 evidence collection

---

## ⚠️ Important Notes

1. **workflow_dispatch Recognition**: GitHub Actions may not recognize workflow_dispatch on feature branch immediately. Use GitHub UI or merge PR first.

2. **Execution Method**: Execute workflows via GitHub UI, then run collection commands.

---

## Quick Start

### Step 1: Execute Workflows via GitHub UI

1. **Success Case**
   - Go to: https://github.com/shochaso/starlist-app/actions/workflows/slsa-provenance.yml
   - Click "Run workflow"
   - Branch: `feature/slsa-phase2.1-hardened` (or `main` after merge)
   - Tag: `vtest-success-$(date +%Y%m%d%H%M%S)`
   - Click "Run workflow"
   - Wait for completion (2-3 minutes)

2. **Failure Case**
   - Same as above, but Tag: `vtest-fail-$(date +%Y%m%d%H%M%S)`
   - Or inject intentional failure step temporarily

3. **Concurrency Case**
   - Run 3 workflows simultaneously with different tags

### Step 2: Run Auto-Execution Script

```bash
cd /Users/shochaso/Downloads/starlist-appのコピー
./docs/reports/2025-11-12/AUTO_EXECUTE.sh
```

Or execute commands manually from `EXECUTION_COMMANDS.md`.

---

## File Structure

```
docs/reports/2025-11-12/
├── EXECUTION_COMMANDS.md      # Copy-paste ready commands
├── PREFLIGHT_CHECK.md          # Preflight check results
├── EXECUTION_GUIDE.md          # Step-by-step guide
├── EXECUTION_STATUS.md         # Execution status tracking
├── AUTO_EXECUTE.sh             # Auto-execution script
├── PHASE2_2_VALIDATION_REPORT.md  # Validation results
├── WS06_SHA256_VALIDATION.md   # SHA256 validation table
├── _manifest.json              # Run manifest
├── artifacts/                  # Downloaded artifacts
│   └── <RUN_ID>/
├── slack_excerpts/             # Slack log excerpts
│   └── <RUN_ID>.log
└── observer/                   # Observer reports
```

---

## Evidence Collection Checklist

After workflows complete:

- [ ] Run auto-execution script or manual commands
- [ ] Verify artifacts downloaded
- [ ] Check SHA256 validation table
- [ ] Review validation report
- [ ] Update evidence index

---

**Status**: ⏳ Ready for execution (awaiting workflow completion)

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
