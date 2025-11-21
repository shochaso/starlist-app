---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# Execution Guide - One-Pass Evidence Collection

**Date**: 2025-11-13 (UTC)
**Purpose**: Step-by-step guide for executing WS02-WS14 evidence collection

---

## ⚠️ Important Notes

1. **workflow_dispatch Recognition**: GitHub Actions may not recognize workflow_dispatch on feature branch immediately. Use GitHub UI or merge PR first.

2. **Secrets Configuration**: 
   - SUPABASE_URL: ✅ Found
   - SUPABASE_SERVICE_KEY: ⚠️ Check in workflow context
   - SLACK_WEBHOOK_URL: ❌ Not found (optional)

3. **Execution Order**: Execute commands in order. Wait for each workflow to complete before proceeding.

---

## Quick Start

### Option 1: GitHub UI Execution (Recommended)

1. **Success Case**
   - Go to: https://github.com/shochaso/starlist-app/actions/workflows/slsa-provenance.yml
   - Click "Run workflow"
   - Branch: `feature/slsa-phase2.1-hardened` (or `main` after merge)
   - Tag: `vtest-success-$(date +%Y%m%d%H%M%S)`
   - Click "Run workflow"
   - Wait for completion (2-3 minutes)
   - Record Run ID and URL

2. **Failure Case**
   - Same as above, but Tag: `vtest-fail-$(date +%Y%m%d%H%M%S)`
   - Or inject intentional failure step temporarily

3. **Concurrency Case**
   - Run 3 workflows simultaneously with different tags
   - Monitor concurrency behavior

### Option 2: CLI Execution (After PR Merge)

Use commands from `EXECUTION_COMMANDS.md` in order.

---

## Evidence Collection Checklist

After each execution:

- [ ] Run ID recorded
- [ ] Run URL saved
- [ ] Artifacts downloaded
- [ ] Logs saved
- [ ] SHA256 validated
- [ ] Manifest updated
- [ ] Report updated

---

## File Locations

All evidence files are saved to: `docs/reports/2025-11-12/`

- Execution logs: `run_<RUN_ID>.log`
- Artifacts: `artifacts/<RUN_ID>/`
- Slack excerpts: `slack_excerpts/<RUN_ID>.log`
- Supabase responses: `SUPABASE_RESPONSE.json`
- Observer reports: `observer/`

---

## Execution Commands Reference

See `EXECUTION_COMMANDS.md` for copy-paste ready commands.

---

**Status**: ⏳ Ready for execution (awaiting workflow_dispatch recognition or PR merge)

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
