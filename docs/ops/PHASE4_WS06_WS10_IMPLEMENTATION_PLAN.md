---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# Phase 4 WS06-WS10 Implementation Plan (20× Microtasks)

## Overview

This document outlines 20 microtasks for implementing Phase4 Workstreams 06-10:
- **WS06**: Collector enhancements (CLI, artifact download, SHA verification)
- **WS07**: KPI aggregator (success rate, latency percentiles, audit summary)
- **WS08**: Sweep enhancements (exclusions config, token pattern detection)
- **WS09**: Manifest commit-hint persistence (git integration)
- **WS10**: Telemetry real implementation (Supabase client with env guard)

## 20 Microtasks

### WS06: Collector Enhancements (Tasks 1-5)

#### Task 1: Collector CLI Argument Parsing
**File**: `scripts/phase4/collector/cli.ts`
- Parse `--run-ids` (comma-separated), `--dry-run`, `--report-dir`
- Validate run IDs format (numeric or GitHub run ID format)
- Return structured config object

**Test**: `tests/phase4/collector/cli.spec.ts`
- Test argument parsing, validation, default values

**Acceptance**: `node scripts/phase4/collector/cli.ts --run-ids 123,456 --dry-run` outputs JSON config

---

#### Task 2: Artifact Download with Fixture Fallback
**File**: `scripts/phase4/collector/download.ts`
- Download artifacts via `gh run download <run_id>`
- In dry-run mode, use fixtures from `tests/fixtures/phase4/`
- Return artifact paths array

**Test**: `tests/phase4/collector/download.spec.ts`
- Mock `gh run download`, test fixture fallback in dry-run

**Acceptance**: Dry-run returns fixture paths, normal mode downloads artifacts

---

#### Task 3: SHA Verification Integration
**File**: `scripts/phase4/collector/verify.ts`
- Use `sha-compare.ts` to verify artifact SHA256
- Compare with provenance metadata if available
- Log `shaVerify` events with match status

**Test**: `tests/phase4/collector/verify.spec.ts`
- Test SHA comparison, provenance metadata extraction

**Acceptance**: Logs include `{"event":"shaVerify","match":true}` for valid artifacts

---

#### Task 4: RUNS_SUMMARY.json Idempotent Append
**File**: `scripts/phase4/collector/summary.ts`
- Read existing `RUNS_SUMMARY.json` or create new
- Append run entries idempotently (check `run_id` uniqueness)
- Use atomic write pattern (tmp→fsync→rename)

**Test**: `tests/phase4/collector/summary.spec.ts`
- Test idempotency, atomic writes, duplicate handling

**Acceptance**: Multiple runs with same run_id only append once

---

#### Task 5: Artifact Organization
**File**: `scripts/phase4/collector/organize.ts`
- Organize artifacts under `docs/reports/<date>/artifacts/<run_id>/`
- Preserve artifact names and structure
- Create index file `artifacts/<run_id>/_index.json`

**Test**: `tests/phase4/collector/organize.spec.ts`
- Test directory structure, file preservation, index generation

**Acceptance**: Artifacts organized correctly, index file created

---

### WS07: KPI Aggregator (Tasks 6-9)

#### Task 6: RUNS_SUMMARY.json Reader
**File**: `scripts/phase4/kpi/reader.ts`
- Read and parse `RUNS_SUMMARY.json`
- Handle missing file gracefully (return empty summary)
- Validate JSON structure

**Test**: `tests/phase4/kpi/reader.spec.ts`
- Test file reading, missing file handling, invalid JSON

**Acceptance**: Returns empty summary if file missing, parses valid JSON

---

#### Task 7: Success Rate Calculation
**File**: `scripts/phase4/kpi/metrics.ts`
- Calculate success rate: `success_count / total_runs * 100`
- Calculate validator pass rate: `validator_pass / validator_total * 100`
- Handle edge cases (zero runs, missing verdicts)

**Test**: `tests/phase4/kpi/metrics.spec.ts`
- Test success rate calculation, edge cases, percentage formatting

**Acceptance**: Returns correct percentages, handles zero division

---

#### Task 8: Latency Percentile Calculation
**File**: `scripts/phase4/kpi/latency.ts`
- Extract timing data from run metadata
- Calculate p50, p90, p95 percentiles
- Handle missing timing data gracefully

**Test**: `tests/phase4/kpi/latency.spec.ts`
- Test percentile calculation, missing data handling

**Acceptance**: Returns correct percentiles, handles missing data

---

#### Task 9: Audit Summary Markdown Generation
**File**: `scripts/phase4/kpi/summary.ts`
- Generate `PHASE3_AUDIT_SUMMARY.md` with metrics
- Include run details table, success rate, latency stats
- Append mode (preserve existing content)

**Test**: `tests/phase4/kpi/summary.spec.ts`
- Test markdown generation, append mode, formatting

**Acceptance**: Generates valid markdown, includes all metrics

---

### WS08: Sweep Enhancements (Tasks 10-12)

#### Task 10: Exclusions Configuration
**File**: `scripts/phase4/sweep/config.ts`
- Read `.gitleaks.toml` or `sweep-exclusions.json`
- Support file path patterns, regex exclusions
- Default exclusions for common false positives

**Test**: `tests/phase4/sweep/config.spec.ts`
- Test exclusion loading, pattern matching, defaults

**Acceptance**: Exclusions loaded correctly, patterns matched

---

#### Task 11: Token Pattern Detection Enhancement
**File**: `scripts/phase4/sweep/patterns.ts`
- Enhanced token patterns (GitHub tokens, AWS keys, etc.)
- Context-aware detection (avoid FPs in comments/docs)
- Return structured findings with line numbers

**Test**: `tests/phase4/sweep/patterns.spec.ts`
- Test pattern matching, FP reduction, context awareness

**Acceptance**: Detects real tokens, avoids FPs in comments

---

#### Task 12: Sweep Report Generation
**File**: `scripts/phase4/sweep/report.ts`
- Generate `SWEEP_REPORT.json` with findings
- Include file paths, line numbers, pattern matched
- Exit code 2 if findings, 0 if clean

**Test**: `tests/phase4/sweep/report.spec.ts`
- Test report generation, exit codes, JSON structure

**Acceptance**: Generates valid JSON report, correct exit codes

---

### WS09: Manifest Commit-Hint Persistence (Tasks 13-15)

#### Task 13: Git Integration Helper
**File**: `scripts/phase4/manifest/git.ts`
- Check if git repo, get current branch, commit hash
- Validate git state (no uncommitted changes if required)
- Return git metadata object

**Test**: `tests/phase4/manifest/git.spec.ts`
- Mock git commands, test metadata extraction

**Acceptance**: Returns git metadata, handles non-git directories

---

#### Task 14: Commit-Hint Generation
**File**: `scripts/phase4/manifest/hint.ts`
- Generate commit hint from manifest entry: `manifest-updated:<run_id>`
- Include git branch, commit hash in hint
- Support custom hint format

**Test**: `tests/phase4/manifest/hint.spec.ts`
- Test hint generation, format customization

**Acceptance**: Generates valid hints, includes git metadata

---

#### Task 15: Manifest Entry Git Metadata
**File**: `scripts/phase4/manifest/append.ts` (enhancement)
- Add `git_branch`, `git_commit` to ManifestEntry interface
- Populate git metadata in atomicAppendManifest
- Optional git metadata (skip if not in git repo)

**Test**: `tests/phase4/manifest/git-metadata.spec.ts`
- Test git metadata inclusion, optional behavior

**Acceptance**: Git metadata included when available, optional otherwise

---

### WS10: Telemetry Real Implementation (Tasks 16-20)

#### Task 16: Supabase Client Factory
**File**: `scripts/phase4/telemetry/client.ts`
- Create Supabase client with env guard
- Handle missing `@supabase/supabase-js` gracefully
- Return client or null based on env availability

**Test**: `tests/phase4/telemetry/client.spec.ts`
- Mock Supabase client, test env guard, missing library handling

**Acceptance**: Returns client when env set, null otherwise

---

#### Task 17: Telemetry Upsert Implementation
**File**: `scripts/phase4/telemetry/upsert.ts`
- Implement real Supabase upsert with `onConflict: 'run_id'`
- Handle errors (network, auth, validation)
- Return structured TelemetryResult

**Test**: `tests/phase4/telemetry/upsert.spec.ts`
- Mock Supabase responses, test error handling, idempotency

**Acceptance**: Upserts successfully, handles errors, idempotent

---

#### Task 18: Telemetry Batch Operations
**File**: `scripts/phase4/telemetry/batch.ts`
- Batch multiple telemetry entries in single request
- Handle partial failures (some succeed, some fail)
- Return batch result with success/failure counts

**Test**: `tests/phase4/telemetry/batch.spec.ts`
- Test batch operations, partial failures, retry logic

**Acceptance**: Batches entries, handles partial failures

---

#### Task 19: Telemetry Retry Integration
**File**: `scripts/phase4/telemetry/retry.ts`
- Integrate retry engine with telemetry upsert
- Retry on 5xx errors, fail fast on 4xx
- Log retry attempts with structured events

**Test**: `tests/phase4/telemetry/retry.spec.ts`
- Test retry behavior, error classification, logging

**Acceptance**: Retries on 5xx, fails fast on 4xx, logs attempts

---

#### Task 20: Telemetry Health Check
**File**: `scripts/phase4/telemetry/health.ts`
- Health check endpoint/function for telemetry system
- Verify Supabase connectivity, auth, table existence
- Return health status with diagnostics

**Test**: `tests/phase4/telemetry/health.spec.ts`
- Test health check, connectivity verification, diagnostics

**Acceptance**: Returns health status, verifies connectivity

---

## Implementation Order

1. **Foundation** (Tasks 1, 6, 10, 13, 16): CLI, readers, configs, git helpers, client factory
2. **Core Logic** (Tasks 2-5, 7-9, 11-12, 14-15, 17-18): Business logic implementation
3. **Integration** (Tasks 19-20): Retry, health checks, end-to-end integration

## Testing Strategy

- **Unit Tests**: Each module has dedicated test file
- **Integration Tests**: End-to-end workflow tests
- **Dry-Run Tests**: All scripts support `--dry-run` flag
- **Mock Tests**: External dependencies (Supabase, GitHub API) mocked

## Acceptance Criteria

- All 20 tasks implemented with tests
- All tests passing (target: 100% pass rate)
- Dry-run mode works for all scripts
- No secrets logged or committed
- Idempotency maintained throughout
- CI workflows updated to use new components

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
