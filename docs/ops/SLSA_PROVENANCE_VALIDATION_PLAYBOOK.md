---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# SLSA Provenance Validation Playbook

## Objective recap
1. Hard-minimize job-level permissions for the release-provenance flow and make the provenance dispatch tokened and auditable.
2. Provide a deterministic notify-on-failure flow that opens an issue as a fallback and ties back to the provenance run + release tag.
3. Capture every provenance artifact in a daily `docs/reports/<YYYY-MM-DD>/manifest.json` and keep that manifest in sync via automation.
4. Introduce a dedicated `provenance-validate` job in Security CI that asserts SLSA L3 guarantees before any cut of `main`/`release/**`.
5. Extend Supabase with a KPI view + audit table so ops dashboards and incident response can query release-provenance telemetry.
6. Document all workflows end-to-end with Mermaid diagrams and concise tables so the SPOF and approval path is explicit.

## Baseline inventory
- `.github/workflows/release.yml`: generates tag/release and dispatches `slsa-provenance.yml` via `github-script` using the job-level `GITHUB_TOKEN` (`contents: write`) and logs the tag.
- `.github/workflows/slsa-provenance.yml`: `release` + `workflow_dispatch` triggered, `checkout` depth 2, `upload-artifact` retention 90 days, `if: github.event_name != 'push'`.
- Docs folder already stores run artifacts under `docs/reports/2025-11-12`.
- Supabase migrations already exist for ops metrics and notifications (`supabase/migrations/20251107_ops_metrics.sql`, etc.).
- Ops Slack workflows (`ops-slack-notify.yml`, `ops-summary-email.yml`) already call Supabase functions.

## Patch proposals

### 1. Job-level permissions + secure dispatch token
- Restrict `release` job to `permissions: contents: write` only on the step that pushes the tag and create release; shrink to `contents: read` elsewhere using `permissions` matrix overrides.
- Replace the inline `actions/github-script` call with a dedicated `slsa-provenance-dispatch` step that:
  * Runs with `permissions: actions: write` + `contents: read` only (no `id-token` or `attestations`).
  * Reads a `PROVENANCE_DISPATCH_TOKEN` stored in `secrets` (a PAT limited to `repo` scope + `workflows` write) instead of `GITHUB_TOKEN`.
  * Logs `dispatch_tag` + `release_url` and persists them in `${{ steps.context.outputs }}` for downstream verification.
- Guard the dispatch token with `permissions` boundary so the release step cannot escalate; store the run id in `docs/reports/<date>/manifest` for later audit.

### 2. Notify-on-failure job with issue fallback
- Add a `notify-on-failure` job under `slsa-provenance.yml` that runs `if: failure()` and depends on the `provenance` job.
- This job should:
  * Read `steps.resolve_tag.outputs.tag`, `github.run_id`, `github.repository`, `github.workflow`, and `downloads` for artifact existence.
  * Post to `ops-slack-notify` (reuse existing Supabase function) via `curl` with `range=latest&source=slsa-provenance`.
  * If Slack post fails or returns `.delivered != true`, call `gh issue create` (via `actions/github-script` or `gh` CLI) with label `ops-alert`.
  * Write a summary JSON `artifacts/slsa/<tag>/failure.json` for the manifest and supabase loader.
- Keep `permissions` minimal (only `contents: read`, `issues: write`, `actions: read` as needed).

### 3. Manifest automation
- New manifest format `docs/reports/<YYYY-MM-DD>/manifest.json`:
  ```json
  {
    "run": "<run_id>",
    "tag": "<tag>",
    "status": "success|failure",
    "artifact": "artifacts/slsa/<tag>/provenance-<tag>.json",
    "release_url": "<release_url>",
    "validated_at": "<UTC timestamp>"
  }
  ```
- `slsa-provenance` job appends/updates the manifest at completion inside `docs/reports/$(date +%F)/manifest.json` using `release_tag`, `github.run_id`, and the artifact path; commit via a transient `gh` CLI step or `git commit` + `git push`.
- A nightly workflow (`ci-weekly-report.yml` extension) can validate the manifest vs. Supabase table and raise alerts when entries are missing.

### 4. Security CI `provenance-validate` job
- Add to `.github/workflows/security-audit.yml` (or a dedicated `security-provenance.yml`):
  * Trigger on `push` to `main`/`release/**` and depends on `slsa-provenance`.
  * Steps:
    1. Checkout `main` with `fetch-depth: 0` and `tags`.
    2. Install [`slsa-verifier`](https://github.com/slsa-framework/slsa-verifier) and `sqlite3` (or `python`).
    3. Download artifact via `gh run download <run_id>` using the manifest (passed via workflow input or `artifacts_manifest` file).
    4. Run `slsa-verifier verify` + `cosign verify-attestation` to ensure builder identity, materials, and invocation match the release tag.
    5. Emit metrics to Supabase via `curl` hitting `/functions/v1/provenance-validate` (new function).
  * Permissions: `contents: read`, `actions: read`, `id-token: write` (for `slsa-verifier` OIDC), `attestations: read`.
- The job fails if the attestation is missing or the verification command returns non-zero.

### 5. Supabase KPI view + audit table schema
- Introduce migration `supabase/migrations/20260201_provenance_audit.sql` with:
  * `create table provenance_audit_log (id uuid primary key default gen_random_uuid(), run_id bigint, tag text, release_url text, artifact_path text, status text, failure_reason text, created_at timestamptz default now());`
  * `create view provenance_kpi as select tag, run_id, status, created_at, release_url from provenance_audit_log where status = 'success';`
  * `create view provenance_incidents as select tag, run_id, failure_reason, created_at from provenance_audit_log where status <> 'success';`
- Supabase view `supabase/views/provenance_kpi.sql` should be added for the KPI dashboard.
- Update `supabase/functions/telemetry/index.ts` (or a new function) to ingest the manifest file via HTTP from the docs bucket and insert into `provenance_audit_log`.
- KPI dashboard uses `provenance_kpi` view to show `tag`, `run_id`, `status`, `validated_at`.

### 6. Mermaid + tabular workflow documentation
- Create `docs/ops/workflows.mmd` that expresses:
  * `release` job triggers `slsa-provenance`.
  * `slsa-provenance` branches into `provenance`, `notify-on-failure`, and `manifest-sync`.
  * `security-provenance` job depends on manifest entry.
  * Supabase ingestion occurs once `manifest.json` lands.
- Generate a `docs/ops/workflow-summary.md` table summarizing each workflow with these columns: `Name`, `Trigger`, `Purpose`, `Key permissions`, `Critical outputs`, `Related doc/diagram`.
- Reference the Mermaid diagram by linking the `.mmd` file and mention that `npx @mermaid-js/mermaid-cli` can render PNG.

## Validation recipe
1. **Dispatch hygiene**: Run `gh workflow run release.yml --field dry_run=false` (or simulate release) and confirm:
   * `slsa-provenance` run output includes `event_name=release`, `tag=…`, `status=success`.
   * `gh run download <run_id>` contains `artifacts/slsa/<tag>/provenance-<tag>.json`.
   * `docs/reports/<date>/manifest.json` contains an entry for the run.
2. **Failure notification**: Intentionally break the release tag (e.g., missing artifact) and verify `notify-on-failure` job:
   * Slack call fails → issue `ops-alert` created with run link.
   * Manifest entry has `status: failure`, `failure_reason`.
3. **Security CI**: Feed the manifest into `provenance-validate` job:
   * Run `slsa-verifier verify` or `cosign` (use `gh` CLI to download artifact).
   * Expect zero exit on valid signature; any mismatch fails the job.
4. **Supabase sync**: Use `supabase db query -f` to `select * from provenance_kpi limit 5` after manifest ingestion.
5. **Doc completeness**: Render Mermaid (`npx @mermaid-js/mermaid-cli -i docs/ops/workflows.mmd -o docs/ops/workflows.png`) and ensure `workflow-summary.md` table matches diagram.

## Definition of Done
- `release.yml` and `slsa-provenance.yml` jobs only request the permissions required for their steps and log their outputs (tag, run_id, release_url).
- Dispatch token is stored in secrets, never leaked to steps that are not dispatching workflows, and rotates with an audit comment.
- `notify-on-failure` job runs whenever `provenance` fails and either posts to Slack or opens an issue with the failure payload.
- `docs/reports/<YYYY-MM-DD>/manifest.json` updated by every run (success or failure) and preserved under version control.
- `provenance-validate` job passes SLSA L3 checks and refuses to merge if verification fails.
- Supabase `provenance_kpi` view is populated via the manifest ingestion path and surfaces in the ops dashboard.
- Mermaid diagram + summary table cover every relevant workflow and are referenced from a single ops doc index.

## Dependencies
| Item | Type | Notes |
| --- | --- | --- |
| `.github/workflows/release.yml` | Workflow | Must be updated with per-step permissions and dispatch token usage. |
| `.github/workflows/slsa-provenance.yml` | Workflow | Hosts `notify-on-failure`, manifest sync steps, artifact path updates. |
| `.github/workflows/security-audit.yml` | Workflow | Expanded with `provenance-validate` job referencing manifests. |
| `supabase/migrations/20260201_provenance_audit.sql` | Migration | Creates audit table, KPIs used by Supabase functions. |
| `supabase/functions/telemetry/index.ts` | Function | Ingests manifest entries and writes to Supabase. |
| `docs/ops/workflows.mmd` | Diagram | Mermaid definition for the workflow graph. |
| `docs/ops/workflow-summary.md` | Reference | Table cross-references diagram and key permissions. |
| `docs/reports/<YYYY-MM-DD>/manifest.json` | Artifact | Target for manifest automation. |

## Next steps
- Identify the minimum `PROVENANCE_DISPATCH_TOKEN` scopes and create an Ops secret entry.
- Draft the `notify-on-failure` job with the Slack/issue logic (place under `.github/workflows/slsa-provenance.yml`).
- Build the Supabase migration + ingestion function; add SQL + TypeScript doc snippets.
- Add the Mermaid & table docs; render the diagram and wire it into the main `docs/ops/INCIDENT_RUNBOOK.md` or similar overview.

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
