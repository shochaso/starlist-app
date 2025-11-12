# Phase 3 Audit Summary (2025-11-13)

**Observer Run ID**: Not dispatched (workflow_dispatch missing on default branch)  
**Scheduled Clock**: daily `0 0 * * *` UTC (`.github/workflows/phase3-audit-observer.yml`)  
**Trigger Attempt**: `phase3-audit-observer.yml` → failed before starting (see below)

---

## 1. Manual audit dispatch attempt

```bash
gh workflow run phase3-audit-observer.yml --ref feature/slsa-phase2.1-hardened \
  -f provenance_run_id=19302628134 \
  -f validation_run_id=19303053984
```

```
could not create workflow dispatch event: HTTP 422: Workflow does not have 'workflow_dispatch' trigger
```

Because the workflow routing layer checks the default branch metadata (Workflow ID 206345562) for the `workflow_dispatch` hook, the attempt fails before the job spins up even though the feature branch file declares the input parameters.

## 2. Existing audit runs

| Run ID | Event | Created (UTC) | Conclusion |
| --- | --- | --- | --- |
| 19303259295 | push | 2025-11-12T15:47:31Z | failure |
| 19303254816 | push | 2025-11-12T15:47:22Z | failure |

These push-triggered audits fail because there is no successful provenance/validation pair to review and because the observer never receives artifact data.

## 3. Supabase / Slack / Artifacts

- Supabase entries: **pending** (no successful audit run, no service keys in this environment)  
- Slack delivery: **n/a** (the notifier step is gated behind a completed audit run)  
- Artifacts: **n/a**

## 4. Next actions

1. Merge the workflow changes that add `workflow_dispatch` to `slsa-provenance.yml` and `phase3-audit-observer.yml` into `main` so `gh workflow run ...` no longer bumps into Workflow ID 206345562.  
2. Rerun the manual audit after the Phase 2.2 success/failure/concurrency cases complete to populate this report with concrete run metadata (artifact files, SHA256, predicate type, Supabase rows).  
3. Once the observer succeeds, copy the populated JSON snippet into `docs/reports/PHASE3_AUDIT_SUMMARY.md` (daily file) and post the Supabase response/Slack request IDs into `docs/reports/2025-11-13/_evidence_index.md`.
