# Phase 2.2 Validation Report

**Collection Date**: 2025-11-13  
**Branch**: feature/slsa-phase2.1-hardened  
**PR**: #61

---

## 1. Playbook Execution Attempts

The sequential playbook runs for the Success, Failure, and Concurrency cases all fail before the workflow starts because GitHub rejects the dispatch request with an HTTP 422. Below are the raw command invocations and the responses:

### 🔷 Success Case (`v2025.11.13-phase2.2-success`)

```bash
gh workflow run slsa-provenance.yml -f tag=v2025.11.13-phase2.2-success
```

```
could not create workflow dispatch event: HTTP 422: Workflow does not have 'workflow_dispatch' trigger
```

### 🔶 Failure Case (`v2025.11.13-phase2.2-fail`)

```bash
gh workflow run slsa-provenance.yml -f tag=v2025.11.13-phase2.2-fail
```

```
could not create workflow dispatch event: HTTP 422: Workflow does not have 'workflow_dispatch' trigger
```

### 🔷 Concurrency Case (`v2025.11.13-phase2.2-concurrent-1`)

```bash
gh workflow run slsa-provenance.yml -f tag=v2025.11.13-phase2.2-concurrent-1
```

```
could not create workflow dispatch event: HTTP 422: Workflow does not have 'workflow_dispatch' trigger
```

Because each dispatch is blocked, no artifacts have been generated yet (Success run), no failure notifications could fire, and no concurrency group actually executed.

## 2. Workflow & Artifact State

The most recent `slsa-provenance` runs are all from push events and concluded with `failure` because they skip without a release context. The list below is the current state pulled from GitHub:

```json
[{"conclusion":"failure","createdAt":"2025-11-12T15:40:39Z","databaseId":19303053744,"event":"push","headBranch":"feature/slsa-phase2.1-hardened","status":"completed","workflowName":".github/workflows/slsa-provenance.yml"},{"conclusion":"failure","createdAt":"2025-11-12T15:28:54Z","databaseId":19302690592,"event":"push","headBranch":"feature/slsa-phase2.1-hardened","status":"completed","workflowName":".github/workflows/slsa-provenance.yml"},{"conclusion":"failure","createdAt":"2025-11-12T15:28:52Z","databaseId":19302689701,"event":"push","headBranch":"feature/slsa-phase2.1-hardened","status":"completed","workflowName":".github/workflows/slsa-provenance.yml"},{"conclusion":"failure","createdAt":"2025-11-12T15:26:55Z","databaseId":19302628134,"event":"push","headBranch":"feature/slsa-phase2.1-hardened","status":"completed","workflowName":".github/workflows/slsa-provenance.yml"},{"conclusion":"failure","createdAt":"2025-11-12T15:24:10Z","databaseId":19302542584,"event":"push","headBranch":"feature/slsa-phase2.1-hardened","status":"completed","workflowName":".github/workflows/slsa-provenance.yml"}]
```

Because the manual dispatch never triggered, there are no provenance artifacts to download, no SHA256 to compare, and the `provenance-validate` job never ran.

## 3. Manifest Status

The manifest managed under `docs/reports/_manifest.json` still contains zero entries, so there is no per-day JSON to inspect yet.

```bash
cat docs/reports/_manifest.json | jq '.'
```

```
[]
```

Without a successful run there was also no manifest append commit or SHA256 proof to validate.

## 4. Supabase & Notifications

- No Supabase credentials are available in this environment (`SUPABASE_URL`, `SUPABASE_SERVICE_KEY`, and `SUPABASE_ANON_KEY` were unset), so no ingestion query or telemetry post could be performed (`env | rg -i supabase` returned nothing).
- Slack + issue notifications could not be observed because the failure path never executed—the `notify-on-failure` job is gated on the provenance job completing (which never happened).

## 5. Branch Protection

Branch protection on `main` currently enforces a single approving-review requirement but does not require any status checks, so there is no `provenance-validate` context to block the merge:

```json
{
  "required_pull_request_reviews": { "required_approving_review_count": 1, "require_code_owner_reviews": false },
  "required_signatures": { "enabled": false },
  "enforce_admins": { "enabled": false },
  "required_linear_history": { "enabled": false },
  "allow_force_pushes": { "enabled": false },
  "allow_deletions": { "enabled": false }
}
```

Because GitHub reports zero required status-check contexts for `main`, the mandate "Branch protection includes `provenance-validate`" has not been met in this workspace.

## 6. Blockers & Next Steps

1. **Enable manual dispatch** – GitHub refuses to run `slsa-provenance.yml` via `workflow_dispatch` even though the feature branch defines it. Confirm the `workflow_dispatch` trigger is active on the workflow that `gh` sees (typically the default branch version) or rely on a release event to fire the job.
2. **Re-run the Success, Failure, and Concurrency cases once dispatch works**:
   - Collect provenance artifacts (`artifacts/slsa/<tag>/provenance-<tag>.json`), compute SHA256, validate `predicateType` / `content_sha256`, and capture the artifact log.
   - Inspect `docs/reports/_manifest.json` and the per-day `manifest.json` entry for unique `run_id` and `sha` values and a commit hash.
   - Run `scripts/verify_slsa_provenance.sh <RUN_ID> <TAG>` to print predicate metadata and ensure `provenance-validate` completes.
3. **Query Supabase** once `SUPABASE_URL` & service-key secrets are present: `curl ... /rest/v1/slsa_runs?select=...` to prove RLS works and ingestion succeeded.
4. **Watch for Slack/Issue notifications** from the failure run, or manually trigger the `notify-on-failure` job once the provenance job has a non-`success` result.
5. **Update branch protection** to include `provenance-validate` (and any other required contexts) so that the gating requirement is enforceable.

Once all three playbook cases complete end-to-end, this report should be updated with:
- The `manifest.json` diff and commit hash for each run;
- SHA256 checks and predicate verification logs;
- Supabase ingestion rows + telemetry log entries;
- Evidence that Slack and the fallback issue were delivered; and
- Confirmation that `provenance-validate` succeeded and appears in the required-status-check list.

