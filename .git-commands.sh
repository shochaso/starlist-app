#!/bin/bash
# Phase 4 Auto-Audit Implementation - Git Commands
# Execute these commands to create commits and PR

set -e

BRANCH="feat/phase4-auto-audit-20251114"

# Create branch if not exists
git checkout -b "$BRANCH" 2>/dev/null || git checkout "$BRANCH"

# WS01: Observer 2.0
git add scripts/phase4/observer/index.ts tests/phase4/observer.spec.ts
git commit -m "feat(phase4): WS01 Observer 2.0 implementation

- GitHub API integration for run discovery
- Artifact download with dry-run support
- SHA256 comparison and validation
- Manifest atomic append integration
- Telemetry upsert integration
- Masked Slack excerpt on failure
- Structured JSON logging
- Unit tests"

# WS02: Retry Engine
git add lib/phase4/retry.ts tests/phase4/retry.spec.ts
git commit -m "feat(phase4): WS02 Retry Engine implementation

- Error classification (422/403 non-retryable, 5xx retryable)
- Exponential backoff (5s, 10s, 20s)
- Max 3 attempts enforcement
- Unit tests with Vitest"

# WS03: CI Guard
git add .github/workflows/phase4-retry-guard.yml .github/workflows/phase4-auto-audit.yml
git commit -m "feat(phase4): WS03 CI Guard implementation

- Secrets presence checks (SUPABASE_SERVICE_KEY, SLACK_WEBHOOK_URL)
- No secret values logged
- Exit messages: ci-guard-required format
- Guard output integration
- Conditional job execution"

# WS04: Evidence Collector
git add scripts/phase4/collector/collect.ts scripts/phase4/sha-compare.ts
git commit -m "feat(phase4): WS04 Evidence Collector implementation

- Run log collection
- Artifact listing collection
- SHA comparison collection
- Slack excerpt extraction (masked)
- Evidence index generation
- Dry-run support"

# WS05: KPI Aggregator & Supporting Modules
git add scripts/phase4/kpi/aggregate.ts scripts/phase4/manifest/append.ts scripts/phase4/notify/slack.ts scripts/phase4/telemetry/telemetry.ts scripts/phase4/sweep/scan.ts scripts/phase4/recovery/align.ts lib/phase4/time.ts tests/phase4/*.spec.ts tests/fixtures/phase4/
git commit -m "feat(phase4): WS05 KPI Aggregator & supporting modules

- KPI aggregation from RUNS_SUMMARY.json
- Manifest atomic append (tmp→mv pattern)
- Masked Slack excerpt writer
- Telemetry upsert (Supabase stub)
- Security sweep for token detection
- Recovery handler for alignment
- Timezone helpers (JST folder, UTC timestamps)
- Unit tests for all modules"

# Configuration & Documentation
git add package.json tsconfig.json vitest.config.ts docs/ops/PHASE4_*.md
git commit -m "docs(phase4): Configuration and documentation

- Update package.json with phase4 scripts
- Add TypeScript configuration
- Add Vitest configuration
- Add implementation summary
- Add micro-tasks documentation"

# Push branch
echo "Ready to push. Run: git push -u origin $BRANCH"

