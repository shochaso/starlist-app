# SLSA Security CI Scenario — Branches, Rollbacks, and Governance (20×)

## Overview
このドキュメントは `security-ci` での `provenance-validate` job から始まる統合シナリオを 20倍密度で記述し、Predicate 検証、通知、再実行、Supabase KPI 連携、並列制御、Failure Recovery Runbook まで包含します。

## 1. Job: provenance-validate
- **目的 / Objective**: Ensure each release tag has an SLSA predicate whose `predicateType` and SHA256-encoded materials match the release artifact; fail the job if any invariants breach, preventing merges.
- **構成**:
  1. Input manifest entry (from docs manifest) provides `tag`, `run_id`, `artifact_url`.
  2. Download artifact via `gh run download` and verify:
     - `predicateType` is `https://slsa.dev/provenance/v1` (or `v0.2` + governance override) and `invocation.release == tag`.
     - Materials SHA256 matches release commit `sha`.
     - Builder ID equals expected `github-actions/slsa-provenance`.
  3. Run `slsa-verifier verify` using OIDC `id-token` to fetch provenance as attestation; fallback to `cosign verify-attestation`.
  4. `Slack` and `Issue` notifications call `ops-slack-notify` and/or `gh issue create` if verification fails.
  5. On success, call Supabase API (`/functions/v1/provenance-validate`) with payload `{ tag, run_id, status: success, verified_at }`; failure submissions include `failure_reason`.

- **リスク / Risks**:
  - OIDC failure: `id-token` permission not granted; job gracefully degrades to cosign but logs missing attestation.
  - Artifact retention: if 90-day retention expired, verification cannot run; metric `artifact_retention_missing` triggers manual reacquire.
  - Slack/Issue tokens leak; use workspace-scoped `OPS_NOTIFY_TOKEN` for Slack and `GITHUB_TOKEN` with only `issues: write`.

- **想定異常系 / Failure cases**:
  1. `slsa-verifier` rejects predicate → job fails, sends Slack alert, and `notify-on-failure` job opens Issue with label `ops-alert`.
  2. Artifact download from run id fails (403/404) → job retries 3× then fails; Slack and Issue mention `artifact_missing`.
  3. PredicateType is unexpected (legacy `https://slsa.dev/provenance/v0.2` vs new `v1`); job records `predicate_mismatch` and tags Issue for `security-backcompat`.

- **監査メトリクス / Audit metrics**:
  - `security_ci.predicate_validation_pass_rate`.
  - `security_ci.slack_issue_followups`.
  - `security_ci.re_run_count` (times job reran after failure).
  - `security_ci.kpi_ingest_success`.

## 2. Notify and Issue escalations
- **目的 / Objective**: Guarantee visibility when `provenance-validate` or `slsa-provenance` fails by posting to Slack and creating a failover GitHub Issue.
- **構成**:
  1. `Notify-on-failure` job runs `if: failure()` and depends on both `provenance` and `provenance-validate`.
  2. Post to Supabase Slack function via `ops-slack-notify` endpoint with `range=latest&source=provenance-validate`.
  3. If Slack post fails (network, status not delivered), use `actions/github-script` to open Issue in `.github/ISSUE_TEMPLATE/provenance-fixture`.
  4. Issue body includes `run_id`, `tag`, `artifact_url`, `failure_reason`, `links` to `gh actions run`.
  5. Update manifest entry `status=failure` with `failure_reason`, `notify_slack=true`, `issue_number`.

- **リスク / Risks**:
  - Slack outage prevents notification; fallback ensures Issue still created.
  - `GITHUB_TOKEN` may run out due to rate limits; consider `FAILURE_ISSUE_TOKEN` with `issues: write`.
  - Double notifications on reruns; guard by checking if `issue_number` already recorded in manifest.

- **想定異常系 / Failure cases**:
  - Slack call returns `{ delivered: false }`: mark `slack_retry=1` and escalate to Issue creation.
  - Issue creation fails due to missing permission: escalate to `ops-slack-summary` with manual `ops-team` tag; manifest note mentioned.
  - Race condition when two failures handle same run: concurrency group `group: provenance-notify-${{ github.run_id }}` ensures single notifier.

- **監査メトリクス / Audit metrics**:
  - `notify.failures` (issues opened vs runs).
  - `notify.slack_success_rate`.
  - `notify.issue_latency` (time between failure detection and issue creation).

## 3. Rerun / Recovery logic
- **目的 / Objective**: Enable deterministic replays of failed provenance runs, tied to `re-run-from-failure` paths, with governance oversight.
- **Flow**:
  1. When `provenance-validate` fails, manifest entry includes `requeue=true` + reason.
  2. Secondary workflow `slsa-provenance-recover` triggers via `workflow_dispatch` with inputs `run_id`, `tag`, `reason`.
  3. Job merges concurrency group `group: provenance-recover-${{ inputs.run_id }}` to prevent duplicate reruns.
  4. Steps:
     - Clone `main`, check `release tag`.
     - `gh run rerun <run_id>` if permissible; otherwise fallback to manual `release` job rerun referencing same tag.
     - After rerun, update manifest (new run_id, status) and update Supabase KPI via helper script.
     - If rerun fails again, escalate and mark manifest `status=blocked`.

- **想定異常系**:
  - GitHub rerun API denies (run older than 30 days); fallback to manual release flow or create new tag with `-retry`.
  - Automations inadvertently requeue an already-successful run; guard using manifest flag `rerun_in_progress`.

- **監査メトリクス**:
  - `rerun.success_rate`.
  - `rerun.time_to_resolution`.
  - `rerun.automated_vs_manual`.

## 4. Failure Recovery Runbook
- **目的**: Codify the path from `GitHub Actions failure → Issue → Slack → rollback decision`.

- **Steps**:
  1. Detection: `notify-on-failure` job logs `failure_reason`.
  2. Issue created with labels `ops-alert`, `provenance-failure`.
  3. Slack `ops-alert` channel receives message with run link + manifest snippet.
  4. On-call reviews issue, confirms build; if rollback needed, open `release` revert PR and update `manifest` entry referencing rollback run.
  5. After rollback, manifest entry for rollback run recorded with `status=rollback` and `governance_flag=rollback`.
- **リスク**:
  - Issue may be missed; ensure `ops-slack-summary` includes failure digest.
  - Manual rollback may skip re-validation; require rerunning `provenance-validate` on rollback branch before merging.
- **Metrics**:
  - `recovery.issue_to_fix`.
  - `recovery.rollback_lead_time`.
  - `recovery.slack_ack_time`.

## 5. Security CI dependency and concurrency design
- **Dependencies**:
  - `provenance-validate` depends on manifest artifact, so gating on `docs/reports/<date>/manifest.json`.
  - `notify-on-failure` depends on both `provenance` and `provenance-validate`.
- **Concurrency**:
  - `group: provenance-validate-${{ github.ref }}-result` ensures only one validation per ref at a time.
  - `manifest` updates protected by `group: provenance-manifest-${{ github.ref }}`.
  - `notify` uses `group: provenance-notify-${{ github.run_id }}` to avoid duplicated notifications across reruns.
  - Reruns gated by `group: provenance-recover-${{ inputs.run_id }}`.

- **想定異常系**:
  - `provenance-validate` re-queued while manifest update still running → concurrency guard delays rerun in queue.
  - Concurrency lock times out (default 5 mins); instrument `metrics.lock_wait_seconds`.

## 6. Governance integration Appendix
- **Roles**:
  - `Governance Reviewer`: signs off on reruns and manifest commits; uses `ops-gov` team.
  - `Release Steward`: rotates tokens, updates manifest schema, cross-checks Supabase KPI.
  - `Security CI Admin`: ensures `slsa-verifier` versions up to date, monitors `predicateType`.

- **Secrets**:
  - `PROVENANCE_DISPATCH_TOKEN`: PAT limited to `workflow_dispatch` + `contents: read`.
  - `OPS_NOTIFY_TOKEN`: limited to `functions` Slack endpoint.

- **审査手順**:
  1. On each manifest change, `ci.yml` runs `npm run lint-manifest` to check JSON diff.
  2. `SLSA Security CI` verifies `predicateType` and `sha`, emits metrics to Supabase for audit.
  3. `docs/ops/INCIDENT_RUNBOOK.md` references this scenario with Mermaid summary.

- **Metrics**:
  - `governance.manifest_diff_count`.
  - `governance.token_rotation_age`.
  - `governance.review_lead_time`.
