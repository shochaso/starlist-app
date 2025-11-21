---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# SLSA Provenance Automation Design (20× Continuous Governance)

## 1. 目的 / Objective
- Build an automated chain that binds every release tag to a reproducible provenance artifact, ensures the dispatch token is auditable, and writes a manifest entry that security, incidents, and audits can consume in near real time.
- Enable governance controls (roles, secrets, approval, manifest indexes) without writing any code in this doc; focus on structure, policy, and orchestrated flow.

## 2. Manifest Automation Flow

### 2.1 構成 / Composition
- **Trigger**: `slsa-provenance` completion (success/failure) or `release` dispatch ack.
- **Payload schema**:
  ```json
  {
    "run_id": 1234567890,
    "tag": "v2025.11.12.2350",
    "sha": "abcdef1234567890abcdef1234567890abcdef12",
    "artifact_url": "https://github.com/.../artifacts/123",
    "actor": "github-actions[bot]",
    "timestamp": "2025-11-12T23:50:00Z",
    "status": "success",
    "governance_flag": "provenance-ready",
    "release_url": "https://github.com/.../releases/tag/v2025..."
  }
  ```
- **Storage**: append/merge into `docs/reports/<YYYY-MM-DD>/manifest.json` (sorted by tag). The manifest file lives in Git and is updated by `slsa-provenance` job using a short-lived branch/PR or `git worktree` to avoid collisions.
- **Diff merge policy**: Compare `tag` + `run_id`. If entry exists, update `status`, `artifact_url`, and `timestamp`; otherwise append at end. Preserve `governance_flag` history.

### 2.2 目的 / Purpose
- Create a canonical audit trail for compliance and operations.
- Provide Security CI with deterministic inputs (tag/run/artifact) to verify L3 predicate + SHA.
- Enable Supabase ingestion and KPI dashboards without parsing logs.

### 2.3 リスク / Risks
- Manifest commits can conflict if two releases finish simultaneously; mitigate via concurrency group `group: provenance-manifest`.
- Secrets (dispatch token) reused incorrectly may lead to cross-workflow escalation; enforce least privilege (PAT scoped to `workflows:write` + `contents:read`).
- Manual edits may drift manifest content; guard with CI lint and `git diff` check.

### 2.4 想定異常系 / Failure cases
- Missing artifact (upload step skipped) leads to `status=failure`; manifest entry must still record `failure_reason`.
- Git push (manifest update) fails due to freeze window; fallback: queue entry in `out/provenance/queued-manifest.json` and notify `ops-slack-notify`.
- Dispatch token expired → manifest flagged `governance_flag=dispatch-token-expired`, triggers auto-issue creation in notify workflow.

### 2.5 監査メトリクス / Audit metrics
- `manifest.entries_per_day` (count).
- `manifest.missing_artifact_rate`.
- `manifest.dispatch_token_age` (timestamp vs last rotate).
- `manifest.md5` recorded via Git hash for tamper detection.
- Slack notification success ratio (per tag).

## 3. Governance Role Matrix (SLSA_PROVENANCE_GOVERNANCE_V2)

| Role | Permissions | Secrets | Approval |
| --- | --- | --- | --- |
| Release Operator | `contents: write`, `actions: read`, `pull-requests: write` on release job | `GITHUB_TOKEN` limited + `PROVENANCE_DISPATCH_TOKEN` (PAT) | Release summarizer (ops) sign-off via Jira tag |
| Provenance Validator | `contents: read`, `attestations: read`, `id-token: write`, `issues: write` in security CI | None (uses OIDC) | Gate on `manifest.status == success` |
| Governance Auditor | `contents: read` on docs repo, `checks: read` | None | Review manifest drift PRs once per sprint |

## 4. Apprenticed Governance Flow

### 4.1 Flow steps
1. Release job creates tag + release, exports `release_tag`.
2. Dedicated dispatch step (with PAT token) calls `slsa-provenance` via `workflow_dispatch`, logs `dispatch_tag`, `dispatch_run_id`.
3. `slsa-provenance` checkout, generates artifact, uploads, writes manifest entry, and triggers notifier/manifest validation.
4. Security CI `provenance-validate` job pulls manifest entry (via HTTP or artifact) and re-verifies predicate.
5. Supabase ingestion runs via scheduled job referencing manifest entries; merges into `provenance_audit_log`.

### 4.2 リスク / Risks
- Flow depends on PAT; PAT rotation must be audited (rotate quarterly, log last-used run).
- Documented concurrency: `group: manifest-lock` ensures only one manifest writer at a time.
- Doc updates must be signed (commit diff includes release-run id).

### 4.3 想定異常系 / Failure scenarios
- Release triggers but `slsa-provenance` fails before artifact upload: manifest entry records `status=failure`, `failure_reason=artifacts missing`.
- Manifest push fails: `docs/reports/<date>/manifest-queue.json` stores entry; `notify-on-failure` posts to Slack and raises Issue.
- Security CI can't download artifact (permissions/retention) → fail early, escalate to ops channel.

### 4.4 監査メトリクス / Audit metrics
- Concurrency wait time (manifest lock hold).
- Artifact upload latency (time from run start to upload step).
- Manifest-to-Supabase lag (minutes).
- Slack notification latency and success.

## 5. Supabase / KPI Integration (brief)
- Manifest ingestion function hits `supabase/functions/telemetry` (or new `provenance-manifest-sync`) with `manifest.json` entry:
  - Writes to `provenance_audit_log` (tag/run/status/actor/timestamp/metadata JSON blob).
  - Triggers `supabase/kpi` view calculation for dashboards.
- KPI view fields: `tag`, `status`, `validated_at`, `run_id`, `release_url`.
- `audit-table` schema stores `failure_reason`, `artifact_url`, `manifest_hash` for forensic queries.
 - Table definition now lives in `supabase/migrations/DDL_slsa_runs.sql` and captures run metadata, content SHA, validation_status, and manifest hash so ETL consumers can audit every entry.
 - ETL uses a narrow service key (`SLSA_MANIFEST_SERVICE_KEY`) that only grants insert/upsert on `slsa_runs` so automation cannot access broader Supabase APIs.

### 5.1 リスク
- Ingestion failure may skip KPI; detect via `manifest.ingest_failures` metric and `ops-slack-notify` alert.

### 5.2 監査メトリクス
- `supabase.provenance_kpi_counts`.
- `supabase.provenance_audit_failures`.

## 6. Documentation & Reference
- Document the flow in `docs/ops/workflows.mmd` (Mermaid) and reference `workflow-summary.md`.
- Maintain `failure-recovery.md` referencing manifest/issue/resolution steps (also cross-links with runbook).

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
