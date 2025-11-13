# Phase 4 Verification Steps

## Pre-Merge Verification

### 1. Install Dependencies
```bash
npm ci
```
**Expected**: All dependencies installed successfully

### 2. Run Unit Tests
```bash
npm test
```
**Expected**: All tests pass (28/28)

### 3. Dry-Run Observer
```bash
npm run phase4:observer -- --dry-run
```
**Expected Output**:
- JSON logs with `event: "shaCompare"`
- `match: true` for fixture-run-1
- No files written to `docs/reports/*`

### 4. Security Sweep
```bash
npm run phase4:sweep -- docs/reports/2025-11-14
```
**Expected**: `{"event":"sweepClean"}` and exit code 0

### 5. TypeScript Compilation
```bash
npx tsc --noEmit
```
**Expected**: No compilation errors

## Post-Merge Verification (CI)

### 1. Guard Workflow
```bash
gh workflow run phase4-retry-guard.yml
```
**Expected**: 
- Fails with "ci-guard-required: SUPABASE_SERVICE_KEY missing" when secrets absent
- Passes when secrets present
- No secret values in logs

### 2. Auto-Audit Workflow
```bash
gh workflow run phase4-auto-audit.yml --field window_days=7 --field run_mode=full
```
**Expected**:
- Guard job passes
- Observer job runs and logs shaCompare events
- Collector job runs
- KPI job runs

### 3. Verify Artifacts
```bash
gh run download <RUN_ID>
ls -la docs/reports/*/
```
**Expected**:
- `_manifest.json` exists
- `RUNS_SUMMARY.json` exists
- `PHASE3_AUDIT_SUMMARY.md` exists
- No secret values in any files

## Test Results Summary

- ✅ Retry Engine: Error classification and exponential backoff
- ✅ Manifest Atomicity: tmp→mv pattern with fsync
- ✅ Telemetry: Supabase client integration with env guard
- ✅ Observer: Dry-run mode and provenance handling
- ✅ Security Sweep: Token detection
- ✅ Time Helpers: JST folder, UTC timestamps
