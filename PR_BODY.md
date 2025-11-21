---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# feat(phase4): Auto-Audit & Self-Healing — Foundation (2025-11-14)

## Summary

Implements Phase 4 Auto-Audit & Self-Healing foundation with automated auditing, evidence collection, and self-healing capabilities for SLSA Provenance workflows.

## Changes

### Core Implementation (WS01-WS05)

- **WS01: Observer 2.0** - GitHub API integration, artifact download, SHA validation, manifest append, telemetry upsert
- **WS02: Retry Engine** - Error classification, exponential backoff (5s/10s/20s), max 3 attempts
- **WS03: CI Guard** - Secrets presence checks, no values logged, guard output integration
- **WS04: Evidence Collector** - Run logs, artifacts, SHA comparison, masked Slack excerpts
- **WS05: KPI Aggregator** - Metrics calculation, audit summary generation

### Supporting Modules

- Manifest atomic append (tmp→mv pattern)
- Timezone helpers (JST folder, UTC timestamps)
- Masked Slack excerpt writer
- Telemetry upsert (Supabase stub)
- Security sweep for token detection
- Recovery handler for alignment

### Testing

- Unit tests for retry, time, manifest, sha-compare, telemetry, observer
- Test fixtures for provenance and artifacts
- Vitest configuration

## Acceptance Checklist

### Pre-Merge

- [x] All workflows lint successfully
- [x] TypeScript compiles without errors
- [x] Unit tests pass (`npm test`)
- [x] No secret values in code or logs
- [x] Dry-run mode works for all scripts
- [x] Manifest updates are atomic
- [x] Retry policy correctly classifies errors
- [x] CI Guard fails cleanly on missing secrets
- [x] Evidence stored under `docs/reports/<JST-date>/`
- [x] Timestamps in UTC ISO8601 format

### Post-Merge (Same Day)

- [ ] Workflow dispatch succeeds
- [ ] Guard job passes with secrets present
- [ ] Observer discovers runs correctly
- [ ] Collector downloads artifacts
- [ ] KPI aggregator generates summary
- [ ] Security sweep finds no tokens
- [ ] Manifest entries are unique
- [ ] Supabase upsert returns ci-guard-required when key missing

## Testing

### Local Development

```bash
# Install dependencies (Node 18+)
npm install

# Run unit tests
npm test

# Dry-run observer
npm run phase4:observer -- --dry-run

# Dry-run collector
npm run phase4:collect -- --dry-run

# KPI aggregation
npm run phase4:kpi

# Security sweep
npm run phase4:sweep
```

### CI Verification

1. Run `phase4-retry-guard.yml` workflow_dispatch
2. Verify guard fails without secrets
3. Set secrets and verify guard passes
4. Run `phase4-auto-audit.yml` workflow_dispatch
5. Verify all jobs execute successfully

## Rollback

If issues occur:

1. Disable workflows: Rename `.github/workflows/phase4-*.yml` files
2. Revert commits: `git revert <commit-sha>`
3. Remove secrets: `gh secret delete SUPABASE_SERVICE_KEY --repo <repo>`

## Related

- Design: `docs/ops/PHASE4_AUTO_AUDIT_SELF_HEALING_DESIGN.md`
- Summary: `docs/ops/PHASE4_IMPLEMENTATION_SUMMARY.md`
- Micro-tasks: `docs/ops/PHASE4_MICROTASKS.md`

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
