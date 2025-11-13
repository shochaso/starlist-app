# Phase 4 Local Development Runbook

## Prerequisites

- Node.js 18+ (prefer Node 20)
- npm installed
- GitHub CLI (`gh`) installed (for artifact download tests)

## Setup

```bash
# Install dependencies
npm install

# Verify TypeScript compilation
npx tsc --noEmit

# Verify tests can run
npm test
```

## Development Commands

### Observer

```bash
# Dry-run (no file writes)
npm run phase4:observer -- --dry-run

# With environment variables
WINDOW_DAYS=7 REPORT_DIR=./test-reports npm run phase4:observer -- --dry-run

# Expected output: JSON logs with event types
# - observer_info: Discovery and processing logs
# - dry_run: Dry-run mode indicators
# - failure: Error events (if any)
```

### Collector

```bash
# Dry-run
npm run phase4:collect -- --dry-run

# With specific run IDs
RUN_IDS=123,456 REPORT_DIR=./test-reports npm run phase4:collect -- --dry-run

# Expected output: Collection logs for each run
```

### KPI Aggregator

```bash
# Generate summary from RUNS_SUMMARY.json
npm run phase4:kpi

# With custom report directory
REPORT_DIR=./test-reports npm run phase4:kpi

# Expected output: PHASE3_AUDIT_SUMMARY.md appended
```

### Security Sweep

```bash
# Scan evidence files
npm run phase4:sweep

# With custom report directory
REPORT_DIR=./test-reports npm run phase4:sweep

# Exit codes:
# - 0: Clean (no tokens found)
# - 2: Tokens found
# - 1: Error
```

### SHA Compare

```bash
# Compare artifact and provenance
npm run phase4:sha -- --artifact ./tests/fixtures/phase4/sample_artifact.bin --prov ./tests/fixtures/phase4/sample_provenance.json

# Expected output: JSON with computed_sha, metadata_sha, sha_parity
```

## Testing

### Unit Tests

```bash
# Run all tests
npm test

# Run specific test file
npx vitest run tests/phase4/retry.spec.ts

# Watch mode
npm run test:watch
```

### Expected Test Results

```
✓ tests/phase4/retry.spec.ts (15 tests)
  ✓ Retry Engine > classifyError (7 tests)
  ✓ Retry Engine > retry (8 tests)

✓ tests/phase4/time.spec.ts (4 tests)
  ✓ Time helpers (4 tests)

✓ tests/phase4/manifest.spec.ts (4 tests)
  ✓ Manifest Atomicity (4 tests)

✓ tests/phase4/sha-compare.spec.ts (4 tests)
  ✓ SHA Compare (4 tests)

✓ tests/phase4/telemetry.spec.ts (3 tests)
  ✓ Telemetry Upsert (3 tests)

✓ tests/phase4/observer.spec.ts (2 tests)
  ✓ Observer (2 tests)
```

## Troubleshooting

### Node Version Mismatch

If `npm install` fails with engine error:

```bash
# Check Node version
node --version

# Use nvm to switch to Node 20
nvm use 20

# Or update package.json engines to ">=18"
```

### TypeScript Errors

```bash
# Check TypeScript config
npx tsc --showConfig

# Verify file paths in tsconfig.json
```

### Test Failures

```bash
# Clear test cache
npx vitest --clearCache

# Run tests with verbose output
npx vitest run --reporter=verbose
```

## File Structure Verification

```bash
# Check all Phase 4 files exist
find scripts/phase4 lib/phase4 tests/phase4 .github/workflows/phase4* -type f | sort

# Expected files:
# - scripts/phase4/observer/index.ts
# - scripts/phase4/collector/collect.ts
# - scripts/phase4/kpi/aggregate.ts
# - scripts/phase4/manifest/append.ts
# - scripts/phase4/notify/slack.ts
# - scripts/phase4/telemetry/telemetry.ts
# - scripts/phase4/sweep/scan.ts
# - scripts/phase4/recovery/align.ts
# - scripts/phase4/sha-compare.ts
# - lib/phase4/retry.ts
# - lib/phase4/time.ts
# - tests/phase4/*.spec.ts
# - tests/fixtures/phase4/*
# - .github/workflows/phase4-retry-guard.yml
# - .github/workflows/phase4-auto-audit.yml
```

