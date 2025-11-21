---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# Phase 3 Environment Variables & Secrets Setup

## Required Secrets

Set the following secrets in GitHub repository settings (`Settings` → `Secrets and variables` → `Actions`):

### 1. Supabase Configuration

```bash
# Supabase Project URL
SUPABASE_URL=https://your-project.supabase.co

# Supabase Service Role Key (for write access)
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**How to get**:
1. Go to Supabase Dashboard → Project Settings → API
2. Copy `Project URL` → Set as `SUPABASE_URL`
3. Copy `service_role` key → Set as `SUPABASE_SERVICE_KEY`

**⚠️ Security Note**: Service role key has full access. Use narrow-scope service key if available.

### 2. Slack Notification (Optional)

```bash
# Slack Webhook URL
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
```

**How to get**:
1. Go to Slack → Apps → Incoming Webhooks
2. Create new webhook for your channel
3. Copy webhook URL → Set as `SLACK_WEBHOOK_URL`

**Note**: If not set, Slack notifications will be skipped (non-blocking).

### 3. GitHub Token (Automatic)

`GITHUB_TOKEN` is automatically provided by GitHub Actions. No manual setup required.

---

## Environment Variables for Local Testing

For local script execution (`scripts/observe_phase3.sh`):

```bash
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_SERVICE_KEY="your-service-role-key"
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"  # Optional
export PR_NUMBER=61  # Optional, default: 61
export GITHUB_REPOSITORY="owner/repo"  # Optional, default: shochaso/starlist-app
```

---

## Verification

### Test Supabase Connection

```bash
curl -X GET \
  "${SUPABASE_URL}/rest/v1/slsa_runs?select=run_id&limit=1" \
  -H "Authorization: Bearer ${SUPABASE_SERVICE_KEY}" \
  -H "apikey: ${SUPABASE_SERVICE_KEY}"
```

Expected: JSON array (may be empty if no runs exist)

### Test Slack Webhook

```bash
curl -X POST \
  "${SLACK_WEBHOOK_URL}" \
  -H "Content-Type: application/json" \
  -d '{"text":"Test message from Phase 3 Audit Observer"}'
```

Expected: `ok` response

### Test GitHub CLI

```bash
gh auth status
gh run list --workflow=phase3-audit-observer.yml --limit 1
```

Expected: Authentication status and workflow run list

---

## Secrets Setup Checklist

- [ ] `SUPABASE_URL` set in repository secrets
- [ ] `SUPABASE_SERVICE_KEY` set in repository secrets
- [ ] `SLACK_WEBHOOK_URL` set in repository secrets (optional)
- [ ] Supabase connection verified
- [ ] Slack webhook verified (if configured)
- [ ] GitHub CLI authenticated (for local testing)

---

## Troubleshooting

### Issue: Supabase connection fails

**Symptoms**: `verify_supabase` step fails with 401/403 errors

**Solutions**:
1. Verify `SUPABASE_URL` is correct (no trailing slash)
2. Verify `SUPABASE_SERVICE_KEY` is the service role key (not anon key)
3. Check Supabase RLS policies allow service role access
4. Verify network connectivity from GitHub Actions runners

### Issue: Slack notification fails

**Symptoms**: Slack notification step fails but workflow continues

**Solutions**:
1. Verify `SLACK_WEBHOOK_URL` is correct
2. Check webhook is still active in Slack
3. Verify webhook has permission to post to channel
4. Check Slack API rate limits

### Issue: GitHub API rate limits

**Symptoms**: `gh` CLI commands fail with rate limit errors

**Solutions**:
1. Use `GITHUB_TOKEN` environment variable
2. Reduce frequency of API calls
3. Use workflow concurrency groups to prevent parallel runs

---

**Last Updated**: 2025-11-13

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
