---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# WS08: Supabase REST API Verification Results

**Date**: 2025-11-13 (UTC)
**Collector**: Cursor AI

---

## Verification Status

**Current Status**: ⏸️ Pending (Secrets not configured)

**Reason**: `SUPABASE_URL` and `SUPABASE_SERVICE_KEY` secrets are not set in repository.

**Action Required**: Configure secrets before verification can proceed.

---

## Verification Procedure

### Step 1: Check Secrets Availability

```bash
# Check if secrets are set (in workflow context)
if [ -z "${SUPABASE_URL:-}" ] || [ -z "${SUPABASE_SERVICE_KEY:-}" ]; then
  echo "⚠️ Supabase credentials not set - skipping"
  echo "SKIP=true" >> $GITHUB_OUTPUT
else
  echo "✅ Supabase credentials available"
fi
```

### Step 2: Query slsa_runs Table

```bash
# GET request to query recent runs
curl -X GET \
  "${SUPABASE_URL}/rest/v1/slsa_runs?select=*&order=created_at.desc&limit=5" \
  -H "Authorization: Bearer ${SUPABASE_SERVICE_KEY}" \
  -H "apikey: ${SUPABASE_SERVICE_KEY}" \
  -H "Content-Type: application/json" \
  | jq '.' > /tmp/supabase_response.json
```

### Step 3: Verify Response

**Expected Responses**:
- `200 OK`: Success, data returned
- `401 Unauthorized`: Authentication failed
- `404 Not Found`: Table doesn't exist
- `500 Internal Server Error`: Server error

---

## Verification Results

### SERVICE KEY Verification

**Status**: ⏸️ Pending (Secrets not configured)

**HTTP Status**: [記録待ち]
**Response JSON**: [記録待ち]
**Error Message**: [記録待ち]

**Expected Response** (when configured):
```json
[
  {
    "run_id": 123456789,
    "tag": "v2025.11.13-success-test",
    "sha256": "a1b2c3d4...",
    "status": "success",
    "created_at": "2025-11-13T00:00:00Z"
  }
]
```

### ANON KEY Verification

**Status**: ⏸️ Pending (Secrets not configured)

**HTTP Status**: [記録待ち]
**Response JSON**: [記録待ち]

**Expected Behavior**: 
- Should return data if RLS policies allow
- May return empty array if no matching rows
- Should not allow writes (POST/PUT/DELETE)

---

## Configuration Steps

1. **Set Secrets in GitHub**
   - Go to Settings → Secrets and variables → Actions
   - Add `SUPABASE_URL`
   - Add `SUPABASE_SERVICE_KEY`

2. **Verify Connection**
   ```bash
   curl -X GET \
     "${SUPABASE_URL}/rest/v1/slsa_runs?select=run_id&limit=1" \
     -H "Authorization: Bearer ${SUPABASE_SERVICE_KEY}" \
     -H "apikey: ${SUPABASE_SERVICE_KEY}"
   ```

3. **Run Verification**
   - Execute workflow with secrets configured
   - Check response status and JSON
   - Record results in this file

---

## Rollback Procedure

If Supabase verification causes issues:

1. **Remove Secrets** (temporary)
   ```bash
   gh secret delete SUPABASE_URL
   gh secret delete SUPABASE_SERVICE_KEY
   ```

2. **Disable Supabase Steps** (in workflow)
   - Add `if: env.SUPABASE_URL != ''` condition
   - Or comment out Supabase steps temporarily

3. **Rollback Database Changes**
   - See `DAY11_SOT_DIFFS.md` for SQL rollback procedures

---

**Status**: ⏸️ Pending (Secrets configuration required)
**Next Action**: Configure secrets and re-run verification

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
