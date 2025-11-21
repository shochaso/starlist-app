---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# Phase 4 Micro-Tasks (20× per Workstream)

## WS01: Observer 2.0 (20 tasks)

1. ✅ Implement `runObserver()` function with options
2. ✅ Add GitHub API integration for run discovery
3. ✅ Add artifact download with dry-run support
4. ✅ Implement SHA256 comparison
5. ✅ Add manifest atomic append integration
6. ✅ Add telemetry upsert integration
7. ✅ Add masked Slack excerpt on failure
8. ✅ Add dry-run mode support
9. ✅ Add structured JSON logging
10. ✅ Add error handling and recovery
11. ✅ Add unit tests for observer
12. ✅ Add integration test fixtures
13. ✅ Add JST folder name support
14. ✅ Add UTC timestamp formatting
15. ✅ Add validator verdict checking
16. ✅ Add run summary generation
17. ✅ Add audit summary generation
18. ✅ Add observer log file generation
19. ✅ Add error event logging
20. ✅ Add documentation

## WS02: Retry Engine (20 tasks)

1. ✅ Implement `classifyError()` function
2. ✅ Add 422/403 non-retryable classification
3. ✅ Add 5xx retryable classification
4. ✅ Add timeout classification
5. ✅ Add rate limit classification
6. ✅ Implement exponential backoff calculation
7. ✅ Implement `retry()` function with config
8. ✅ Add max attempts enforcement
9. ✅ Add delay between retries
10. ✅ Add retry result interface
11. ✅ Add unit tests for error classification
12. ✅ Add unit tests for retry logic
13. ✅ Add test for 422 non-retry
14. ✅ Add test for 403 non-retry
15. ✅ Add test for 500 retry with backoff
16. ✅ Add test for max retries exceeded
17. ✅ Add test for successful retry
18. ✅ Add test for timeout handling
19. ✅ Add test for rate limit handling
20. ✅ Add documentation

## WS03: CI Guard (20 tasks)

1. ✅ Create workflow file
2. ✅ Add workflow_dispatch trigger
3. ✅ Add workflow_call trigger
4. ✅ Add SUPABASE_SERVICE_KEY check
5. ✅ Add SLACK_WEBHOOK_URL check
6. ✅ Add presence-only checks (no values)
7. ✅ Add exit message formatting
8. ✅ Add guard-passed output
9. ✅ Add error messages
10. ✅ Add success messages
11. ✅ Integrate with auto-audit workflow
12. ✅ Add job outputs
13. ✅ Add conditional job execution
14. ✅ Add documentation
15. ✅ Add test workflow run
16. ✅ Verify guard failure on missing secrets
17. ✅ Verify guard success on present secrets
18. ✅ Verify no secret values in logs
19. ✅ Add CI integration tests
20. ✅ Add rollback documentation

## WS04: Evidence Collector (20 tasks)

1. ✅ Implement `collect()` function
2. ✅ Add run log collection
3. ✅ Add artifact listing collection
4. ✅ Add SHA comparison collection
5. ✅ Add Slack excerpt extraction
6. ✅ Add evidence index generation
7. ✅ Add dry-run support
8. ✅ Add JST folder name support
9. ✅ Add error handling
10. ✅ Add structured logging
11. ✅ Add unit tests
12. ✅ Add integration test fixtures
13. ✅ Add artifact path generation
14. ✅ Add log path generation
15. ✅ Add excerpt path generation
16. ✅ Add index markdown generation
17. ✅ Add file existence checks
18. ✅ Add directory creation
19. ✅ Add documentation
20. ✅ Add error recovery

## WS05: KPI Aggregator (20 tasks)

1. ✅ Implement `aggregateKpis()` function
2. ✅ Add RUNS_SUMMARY.json reading
3. ✅ Add total runs calculation
4. ✅ Add success count calculation
5. ✅ Add success rate calculation
6. ✅ Add validator pass count calculation
7. ✅ Add validator pass rate calculation
8. ✅ Add P50 latency calculation
9. ✅ Add P90 latency calculation
10. ✅ Add PHASE3_AUDIT_SUMMARY.md generation
11. ✅ Add markdown formatting
12. ✅ Add UTC timestamp formatting
13. ✅ Add operator tracking
14. ✅ Add run details listing
15. ✅ Add file append support
16. ✅ Add error handling
17. ✅ Add unit tests
18. ✅ Add test fixtures
19. ✅ Add documentation
20. ✅ Add edge case handling

## WS06-WS20: TODO

See individual workstream documentation for detailed micro-tasks.

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
