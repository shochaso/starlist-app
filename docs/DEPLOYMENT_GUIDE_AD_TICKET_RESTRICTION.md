# Deployment and Testing Guide: Ad-based Gacha Ticket Restriction (Lv1 + Lv2-Lite)

## Overview

This guide provides step-by-step instructions for deploying and testing the server-side ad-based gacha ticket restriction system with daily limits (3 tickets/day, JST 3:00 reset) and Lv2-Lite logging infrastructure.

## Pre-Deployment Checklist

- [ ] Review all code changes in the PR
- [ ] Backup production database
- [ ] Verify Supabase project access
- [ ] Test migration on development environment first
- [ ] Communicate deployment window to team

## Deployment Steps

### 1. Database Migration

```bash
# Navigate to project directory
cd /path/to/starlist-app

# Apply the migration to Supabase
supabase db push

# Verify migration applied successfully
supabase db pull
```

Expected output:
- `date_key_jst3` function created
- New columns added to `ad_views`, `gacha_attempts`, `gacha_history`
- New RPC functions created
- Indexes and RLS policies applied

### 2. Backfill Existing Data

```bash
# Make script executable (if not already)
chmod +x ./supabase/migrations/backfill_date_key.sh

# Run backfill script
# Option 1: Using SUPABASE_DB_URL environment variable
export SUPABASE_DB_URL="postgresql://..."
./supabase/migrations/backfill_date_key.sh

# Option 2: Pass database URL as argument
./supabase/migrations/backfill_date_key.sh "postgresql://..."
```

Expected output:
- All existing `ad_views` records have `date_key` populated
- All existing `gacha_attempts` records have `date_key` populated
- Test cases pass for JST 3:00 boundary

### 3. Verify Database Functions

```sql
-- Test date_key_jst3 function
SELECT date_key_jst3('2025-11-21 02:59:59+09'::timestamptz); -- Expected: 2025-11-20
SELECT date_key_jst3('2025-11-21 03:00:00+09'::timestamptz); -- Expected: 2025-11-21

-- Test complete_ad_view_and_grant_ticket RPC
SELECT complete_ad_view_and_grant_ticket(
  auth.uid(),
  'test-device-123',
  NULL,
  'Test User Agent',
  '192.168.1.1'
);
-- Expected: {"granted": true, "remaining_today": 2, "total_balance": ..., "ad_view_id": "..."}

-- Test consume_gacha_attempts RPC
SELECT consume_gacha_attempts(
  auth.uid(),
  1,
  'test',
  20,
  false,
  '{"type":"point","amount":20}'::jsonb
);
-- Expected: {"new_balance": ..., "history_id": "...", "points_awarded": 20, "silver_ticket_awarded": false}
```

### 4. Deploy Flutter App

```bash
# Run Flutter analyzer
flutter analyze

# Run tests (if applicable)
flutter test

# Build and deploy
# For Android
flutter build apk --release

# For iOS
flutter build ios --release

# For Web
flutter build web --release
```

## Post-Deployment Testing

### Test 1: Daily Limit Enforcement

**Scenario:** Verify that users can watch exactly 3 ads per day and the 4th is rejected.

**Steps:**
1. Log in with a test user
2. Navigate to gacha screen
3. Watch ad #1 → Should succeed, show "2 remaining today"
4. Watch ad #2 → Should succeed, show "1 remaining today"
5. Watch ad #3 → Should succeed, show "0 remaining today"
6. Watch ad #4 → Should fail with error "Daily limit exceeded (max 3 rewards per day)"

**Verification:**
```sql
SELECT 
  user_id,
  date_key,
  COUNT(*) as total_views,
  COUNT(*) FILTER (WHERE reward_granted = true) as granted,
  COUNT(*) FILTER (WHERE status = 'revoked') as rejected
FROM ad_views
WHERE user_id = 'YOUR-TEST-USER-ID'
  AND date_key = date_key_jst3(now())
GROUP BY user_id, date_key;
```

Expected result: `total_views=4, granted=3, rejected=1`

### Test 2: JST 3:00 Reset

**Scenario:** Verify that quota resets at 3:00 AM JST, not midnight.

**Steps:**
1. Watch 3 ads before 3:00 AM JST (exhaust quota)
2. Wait until 2:59 AM JST → Should still show 0 remaining
3. Wait until 3:00 AM JST → Should reset to 3 remaining
4. Watch ad → Should succeed

**Verification:**
```sql
-- Check date_key for records around 3:00 AM boundary
SELECT 
  created_at AT TIME ZONE 'Asia/Tokyo' as jst_time,
  date_key,
  reward_granted
FROM ad_views
WHERE user_id = 'YOUR-TEST-USER-ID'
  AND created_at > NOW() - INTERVAL '2 hours'
ORDER BY created_at;
```

### Test 3: Lv2-Lite Logging

**Scenario:** Verify that device information is logged for analytics.

**Steps:**
1. Watch an ad on device A
2. Watch an ad on device B with same account
3. Query analytics

**Verification:**
```sql
SELECT 
  device_id,
  user_agent,
  client_ip,
  status,
  date_key,
  reward_granted,
  created_at
FROM ad_views
WHERE user_id = 'YOUR-TEST-USER-ID'
ORDER BY created_at DESC
LIMIT 10;
```

Expected: All fields populated with non-null values

### Test 4: Atomic Gacha Operations

**Scenario:** Verify that gacha consumption and reward grants happen atomically.

**Steps:**
1. Note current point balance
2. Perform gacha draw that awards 20 points
3. Verify all changes happened together

**Verification:**
```sql
-- Get latest gacha result
SELECT 
  gh.id,
  gh.reward_points,
  gh.reward_silver_ticket,
  gh.created_at,
  ga.used_attempts,
  sp.balance,
  spt.amount as transaction_amount
FROM gacha_history gh
JOIN gacha_attempts ga ON ga.user_id = gh.user_id AND ga.date = CURRENT_DATE
JOIN s_points sp ON sp.user_id = gh.user_id
LEFT JOIN s_point_transactions spt ON spt.metadata->>'history_id' = gh.id::text
WHERE gh.user_id = 'YOUR-TEST-USER-ID'
ORDER BY gh.created_at DESC
LIMIT 1;
```

Expected: 
- `used_attempts` incremented by 1
- `reward_points` matches transaction amount
- `balance` updated correctly

### Test 5: Error Handling

**Scenario:** Verify proper error handling for edge cases.

**Test 5a: Insufficient Balance**
```sql
-- Try to consume more attempts than available
SELECT consume_gacha_attempts(
  auth.uid(),
  999,  -- Unrealistic number
  'test',
  0,
  false,
  '{}'::jsonb
);
```
Expected: Error message "Insufficient gacha attempts"

**Test 5b: Unauthenticated Access**
```sql
-- Try to call RPC without authentication
-- (Run this outside of authenticated session)
SELECT complete_ad_view_and_grant_ticket(
  'random-uuid'::uuid,
  'device-id',
  NULL,
  NULL,
  NULL
);
```
Expected: Error message "Unauthorized: User must be authenticated"

## Monitoring and Analytics

### Daily Metrics Dashboard Queries

```sql
-- Daily ad views and grants
SELECT 
  date_key,
  COUNT(DISTINCT user_id) as unique_users,
  COUNT(*) as total_views,
  COUNT(*) FILTER (WHERE reward_granted = true) as granted_tickets,
  COUNT(*) FILTER (WHERE status = 'revoked') as rejected_over_limit,
  ROUND(100.0 * COUNT(*) FILTER (WHERE reward_granted = true) / COUNT(*), 2) as grant_rate_pct
FROM ad_views
WHERE date_key >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY date_key
ORDER BY date_key DESC;

-- Device-level analytics (multi-account detection)
SELECT 
  device_id,
  COUNT(DISTINCT user_id) as user_count,
  COUNT(*) as view_count,
  COUNT(*) FILTER (WHERE reward_granted = true) as granted_count,
  ARRAY_AGG(DISTINCT user_id) as user_ids
FROM ad_views
WHERE date_key >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY device_id
HAVING COUNT(DISTINCT user_id) > 1
ORDER BY user_count DESC, view_count DESC
LIMIT 20;

-- Gacha reward distribution
SELECT 
  source,
  COUNT(*) as total_draws,
  SUM(reward_points) as total_points,
  COUNT(*) FILTER (WHERE reward_silver_ticket = true) as silver_tickets,
  ROUND(AVG(reward_points), 2) as avg_points_per_draw
FROM gacha_history
WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY source;

-- Expected value verification
WITH recent_draws AS (
  SELECT reward_points
  FROM gacha_history
  WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
    AND reward_silver_ticket = false
)
SELECT 
  AVG(reward_points) as actual_avg,
  35.8 as expected_avg,  -- From probability table
  ABS(AVG(reward_points) - 35.8) as deviation
FROM recent_draws;
```

## Rollback Plan

If issues are detected after deployment:

### 1. Quick Rollback (Disable New Features)

```sql
-- Revert to old behavior by making RPC functions return success always
-- This is a temporary measure while investigating issues

CREATE OR REPLACE FUNCTION public.complete_ad_view_and_grant_ticket(
  p_user_id UUID,
  p_device_id TEXT,
  p_ad_view_id UUID DEFAULT NULL,
  p_user_agent TEXT DEFAULT NULL,
  p_client_ip TEXT DEFAULT NULL,
  p_ad_type TEXT DEFAULT 'video',
  p_ad_provider TEXT DEFAULT 'mock_provider'
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Emergency rollback: Always grant without limit checks
  RETURN jsonb_build_object(
    'granted', TRUE,
    'remaining_today', 3,
    'total_balance', 10,
    'ad_view_id', gen_random_uuid()
  );
END;
$$;
```

### 2. Full Rollback (Revert Migration)

```bash
# Restore from backup
psql $DATABASE_URL < backup_YYYYMMDD_HHMMSS.sql
```

Or manually:
```sql
-- Run the rollback commands from supabase/migrations/README.md
-- See "Rollback Instructions" section
```

### 3. Flutter App Rollback

Deploy previous version of the app that doesn't use the new RPCs.

## Common Issues and Solutions

### Issue 1: Migration fails with "function already exists"

**Solution:** The migration uses `CREATE OR REPLACE FUNCTION`, so this shouldn't happen. If it does, drop the function first:
```sql
DROP FUNCTION IF EXISTS public.date_key_jst3(timestamptz);
DROP FUNCTION IF EXISTS public.complete_ad_view_and_grant_ticket;
DROP FUNCTION IF EXISTS public.consume_gacha_attempts;
```
Then re-run the migration.

### Issue 2: Date key not backfilled

**Solution:** Run the backfill script again:
```bash
./supabase/migrations/backfill_date_key.sh
```

### Issue 3: Device ID always the same for all users

**Solution:** The current `device_identifier.dart` is a simple implementation. For production, install and use proper device ID:
```bash
flutter pub add device_info_plus
# Or
flutter pub add firebase_core
```

Then update the implementation in `device_identifier.dart` following the provided notes.

### Issue 4: Timezone issues (quota not resetting at 3:00 JST)

**Solution:** Verify PostgreSQL timezone configuration:
```sql
SHOW timezone;  -- Should be 'UTC' (we handle JST conversion in function)

-- Test date_key_jst3 function
SELECT 
  NOW() as utc_now,
  NOW() AT TIME ZONE 'Asia/Tokyo' as jst_now,
  date_key_jst3(NOW()) as current_date_key;
```

## Success Criteria

Deployment is considered successful when:

- ✅ All 4 test scenarios pass
- ✅ No errors in Supabase logs
- ✅ Daily limit enforced correctly (3 per user)
- ✅ JST 3:00 reset working as expected
- ✅ Device information logged correctly
- ✅ Gacha consumption atomic
- ✅ No impact on non-ad gacha functionality
- ✅ Analytics queries return meaningful data

## Support Contacts

- Database Issues: [DBA Team]
- Flutter Issues: [Mobile Team]
- Infrastructure: [DevOps Team]
- Product Questions: [Product Team]

## Additional Resources

- Migration SQL: `supabase/migrations/20251121_add_ad_views_logging_and_gacha_rpc.sql`
- Documentation: `supabase/migrations/README.md`
- Backfill Script: `supabase/migrations/backfill_date_key.sh`
- Integration Tests: `supabase/migrations/test_integration.sql`
- Changelog: `CHANGELOG.md`

---

**Last Updated:** 2025-11-21
**Version:** 1.0
**Reviewers:** [Add reviewers here]
