---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# Security Runbook

## Purpose
STARLIST's ops stack (Supabase Edge Functions, telemetry tables, and scheduled emails) now enforces zero-trust at every boundary. This runbook collects the run-time knobs, rotation steps, and audit procedures for those controls.

## Secrets
### `OPS_SERVICE_SECRET`
- Every Edge Function now calls `shared.enforceOpsSecret(req)`. Keep this value in GitHub as `OPS_SERVICE_SECRET` (also set it in Supabase function envs and any self-hosted jobs that call the functions).
- Rotation steps:
  1. Generate a new secret (at least 32 random characters).
  2. Push the new value to Supabase `fn` environment variables and to GitHub secrets simultaneously.
  3. Restart any self-hosted runners or services that call these functions with `x-ops-secret`.
  4. Run the `security-audit` workflow to validate the new header can still reach the endpoints.

### `OPS_ALLOWED_ORIGINS`
- Defaults to `https://app.starlist.jp`, `https://ops.starlist.jp`, and localhost. Override this env when staging or preview apps need access so CORS responses always match the caller.

### `OPS_ADMIN_METADATA_KEY`
- Used by the `public.has_ops_admin_claim()` function to gate row-level security. The default claim key is `ops_admin` (true/"true").
- To grant a user ops access, run:
  ```sql
  update auth.users
  set app_metadata = jsonb_set(coalesce(app_metadata, '{}'::jsonb), '{ops_admin}', 'true', true)
  where id = 'service-account-user-id';
  ```
- After updating metadata, re-issue the service user's JWT or log out/in to refresh claims.

## Data Access & RLS
- The migration `supabase/migrations/20260101_ops_security_rls.sql` now disables broad authenticated selects on `ops_metrics`, `ops_alerts_history`, and `ops_summary_email_logs`.
- Verification checklist:
  1. Run `supabase db query "select * from pg_policies where tablename like 'ops_%';"` and ensure each policy references `public.has_ops_admin_claim()` or `auth.role() = 'service_role'`.
  2. Attempt to query the tables with a normal user JWT—queries should return an empty result.
  3. Service role queries (from Edge Functions or migrations) should continue working because they bypass RLS.

## Deployment & Validation
- Every deploy that touches `supabase/functions` or RLS migrations must trigger the new `security-audit.yml` workflow. This job runs:
  - `npm audit --production`
  - `dart pub outdated --mode=null-safety`
  - `semgrep --config=auto`
  - `deno test supabase/functions/shared_test.ts`
- Ensure GitHub Actions is configured to fail fast on these checks before merging.

## Logging & Monitoring
- `shared.safeLog()` masks emails and Bearer tokens before writing to `console.error`. When investigating failures, prefer the structured error returned by functions (no PII) and only look at sanitized logs.
- If an integration needs more context, log via `safeLog` and parse the masked payload rather than logging unfiltered user data.

## Incident Steps
1. If telemetry/alerts stop ingesting, verify:
   - `x-ops-secret` header is present and matches the secret in the environment.
   - The calling token carries `ops_admin` metadata if the function requires it.
2. Rotate `OPS_SERVICE_SECRET` immediately if it leaks; follow the secret rotation steps above and re-run the `security-audit` workflow.
3. Document every rotation in `SECURITY_AUDIT_REPORT.md` and in this runbook's changelog section.

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
