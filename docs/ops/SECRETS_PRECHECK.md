---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# Secrets Pre-check Procedure

**Purpose**: Verify required secrets are configured before workflow execution.

---

## Required Secrets Checklist

### Phase 2 Secrets

- [ ] `SUPABASE_URL` - Supabase project URL
- [ ] `SUPABASE_SERVICE_KEY` - Supabase service role key (for writes)
- [ ] `SUPABASE_ANON_KEY` - Supabase anonymous key (for reads, optional)

### Phase 3 Secrets

- [ ] `SUPABASE_URL` - Supabase project URL
- [ ] `SUPABASE_SERVICE_KEY` - Supabase service role key (for writes)
- [ ] `SLACK_WEBHOOK_URL` - Slack webhook URL (optional, for notifications)

---

## Pre-check Commands

### 1. Check Secrets in GitHub

```bash
# List repository secrets (requires admin access)
gh secret list

# Check specific secret exists (will show masked value)
gh secret get SUPABASE_URL
```

### 2. Verify Supabase Connection

```bash
# Test connection with SERVICE KEY
curl -X GET \
  "${SUPABASE_URL}/rest/v1/slsa_runs?select=run_id&limit=1" \
  -H "Authorization: Bearer ${SUPABASE_SERVICE_KEY}" \
  -H "apikey: ${SUPABASE_SERVICE_KEY}"

# Expected: 200 OK with JSON array (may be empty)
```

### 3. Verify Slack Webhook (Optional)

```bash
# Test webhook
curl -X POST \
  "${SLACK_WEBHOOK_URL}" \
  -H "Content-Type: application/json" \
  -d '{"text":"Test message"}'

# Expected: {"ok":true,"ts":"1234567890.123456"}
```

---

## Pre-check Workflow Integration

### GitHub Actions Workflow Step

```yaml
- name: Pre-check secrets
  run: |
    set -euo pipefail
    
    echo "🔍 Checking required secrets..."
    
    # Check Supabase URL
    if [ -z "${SUPABASE_URL:-}" ]; then
      echo "❌ SUPABASE_URL is not set"
      exit 1
    fi
    
    # Check Supabase Service Key
    if [ -z "${SUPABASE_SERVICE_KEY:-}" ]; then
      echo "❌ SUPABASE_SERVICE_KEY is not set"
      exit 1
    fi
    
    # Test Supabase connection
    echo "Testing Supabase connection..."
    curl -sS --fail --max-time 10 \
      -H "Authorization: Bearer ${SUPABASE_SERVICE_KEY}" \
      -H "apikey: ${SUPABASE_SERVICE_KEY}" \
      "${SUPABASE_URL}/rest/v1/slsa_runs?select=run_id&limit=1" \
      > /dev/null || {
        echo "❌ Supabase connection failed"
        exit 1
      }
    
    echo "✅ All required secrets are configured and accessible"
  env:
    SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
    SUPABASE_SERVICE_KEY: ${{ secrets.SUPABASE_SERVICE_KEY }}
```

---

## Troubleshooting

### Issue: Secret not found

**Symptoms**: `Secret not found` error

**Solutions**:
1. Verify secret name matches exactly (case-sensitive)
2. Check secret is set in repository settings
3. Verify workflow has access to secrets (not in fork)

### Issue: Supabase connection fails

**Symptoms**: 401/403 errors

**Solutions**:
1. Verify `SUPABASE_URL` is correct (no trailing slash)
2. Verify `SUPABASE_SERVICE_KEY` is service role key (not anon key)
3. Check Supabase RLS policies allow service role access

### Issue: Slack webhook fails

**Symptoms**: Webhook returns error

**Solutions**:
1. Verify webhook URL is correct
2. Check webhook is still active in Slack
3. Verify webhook has permission to post to channel

---

## Pre-check Report Template

```markdown
# Secrets Pre-check Report

**Date**: [DATE]
**Repository**: [REPO]

## Required Secrets Status

| Secret | Status | Verified |
|--------|--------|----------|
| SUPABASE_URL | ✅ Set | [YES/NO] |
| SUPABASE_SERVICE_KEY | ✅ Set | [YES/NO] |
| SLACK_WEBHOOK_URL | ⚠️ Optional | [YES/NO] |

## Connection Tests

- Supabase Connection: [SUCCESS/FAILURE]
- Slack Webhook: [SUCCESS/FAILURE/SKIPPED]

## Next Steps

[ACTION_ITEMS]
```

---

**Last Updated**: 2025-11-13

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
