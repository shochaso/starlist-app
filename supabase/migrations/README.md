# Database Migrations

This directory contains SQL migrations for the Starlist application database.

## Migration: 20251121_add_ad_views_logging_and_gacha_rpc.sql

### Overview
Implements server-side control for ad-based gacha ticket grants with a daily limit of 3 times per user (JST 3:00 reset) and adds Lv2-Lite device logging/metrics for analysis.

### Key Changes

#### 1. New Function: `date_key_jst3()`
- Returns date key based on JST (UTC+9) with 3:00 AM as day boundary
- Example: `2025-11-21 02:59:59 JST` → `2025-11-20`
- Example: `2025-11-21 03:00:00 JST` → `2025-11-21`

#### 2. Table Modifications

**ad_views** - Enhanced for Lv2-Lite logging:
- `device_id` (TEXT): Device identifier for analytics
- `user_agent` (TEXT): User agent string
- `client_ip` (TEXT): Client IP address
- `status` (TEXT): 'pending', 'success', 'failed', 'revoked'
- `error_reason` (TEXT): Error description if applicable
- `date_key` (DATE): JST 3:00-based daily partitioning key
- `reward_granted` (BOOLEAN): Whether ticket was actually granted
- `updated_at` (TIMESTAMPTZ): Last update timestamp

**gacha_attempts** - Enhanced for daily balance management:
- `date_key` (DATE): JST 3:00-based daily partitioning key
- `source` (TEXT): Source of attempts ('daily', 'ad', etc.)

**gacha_history** - Enhanced for reward tracking:
- `reward_points` (INTEGER): Points awarded from this gacha
- `reward_silver_ticket` (BOOLEAN): Whether silver ticket was directly awarded
- (existing `source` column now used to track 'normal', 'bonus', etc.)

#### 3. New RPC Functions

**`complete_ad_view_and_grant_ticket()`**
```sql
complete_ad_view_and_grant_ticket(
  p_user_id UUID,
  p_device_id TEXT,
  p_ad_view_id UUID DEFAULT NULL,
  p_user_agent TEXT DEFAULT NULL,
  p_client_ip TEXT DEFAULT NULL,
  p_ad_type TEXT DEFAULT 'video',
  p_ad_provider TEXT DEFAULT 'mock_provider'
)
```

**Purpose:** Record ad view completion and grant gacha ticket if daily limit not exceeded

**Behavior:**
1. Verifies user authentication
2. Calculates date key using JST 3:00 baseline
3. Counts today's granted rewards (max 3)
4. If limit exceeded: records ad_view as 'revoked' and returns error
5. If under limit: records ad_view as 'success', grants 1 bonus attempt
6. Returns: `{granted, remaining_today, total_balance, ad_view_id, error?}`

**Daily Limit:** 3 gacha tickets per user per day (JST 3:00 reset)

**`consume_gacha_attempts()`**
```sql
consume_gacha_attempts(
  p_user_id UUID,
  p_consume_count INTEGER DEFAULT 1,
  p_source TEXT DEFAULT 'normal',
  p_reward_points INTEGER DEFAULT 0,
  p_reward_silver_ticket BOOLEAN DEFAULT FALSE,
  p_gacha_result JSONB DEFAULT '{}'::jsonb
)
```

**Purpose:** Consume gacha attempts and record result with rewards in a single transaction

**Behavior:**
1. Verifies user authentication
2. Checks available balance
3. Consumes specified attempts
4. Records result in gacha_history
5. If reward_points > 0: updates s_points and creates transaction record
6. Returns: `{new_balance, history_id, points_awarded, silver_ticket_awarded}`

#### 4. Indexes Added
- `idx_ad_views_user_id_date_key`: For user daily limit checks
- `idx_ad_views_device_id_date_key`: For device-level analytics
- `idx_ad_views_status`: For status-based queries
- `idx_ad_views_reward_granted`: For granted reward counts
- `idx_gacha_attempts_date_key`: For date key lookups
- `idx_gacha_history_source`: For source-based analytics

#### 5. RLS Policies
All tables have Row Level Security enabled with appropriate policies:
- Users can view/insert/update their own records
- SELECT policies allow authenticated users to view their data
- INSERT/UPDATE policies restrict to own user_id

### Migration Steps

1. **Backup Database** (recommended before any migration)
   ```bash
   supabase db dump > backup_$(date +%Y%m%d_%H%M%S).sql
   ```

2. **Apply Migration**
   ```bash
   supabase db push
   ```
   
   Or manually:
   ```bash
   psql $DATABASE_URL < supabase/migrations/20251121_add_ad_views_logging_and_gacha_rpc.sql
   ```

3. **Verify Migration**
   ```sql
   -- Check function exists
   SELECT routine_name FROM information_schema.routines 
   WHERE routine_schema = 'public' AND routine_name = 'date_key_jst3';
   
   -- Check columns added
   SELECT column_name FROM information_schema.columns 
   WHERE table_name = 'ad_views' AND column_name IN ('device_id', 'date_key', 'reward_granted');
   
   -- Test date_key function
   SELECT date_key_jst3('2025-11-21 02:59:59+09'::timestamptz); -- Should return 2025-11-20
   SELECT date_key_jst3('2025-11-21 03:00:00+09'::timestamptz); -- Should return 2025-11-21
   ```

4. **Backfill Existing Data** (if needed)
   The migration automatically backfills `date_key` for existing records, but verify:
   ```sql
   -- Check backfill completion
   SELECT COUNT(*) FROM ad_views WHERE date_key IS NULL AND viewed_at IS NOT NULL;
   SELECT COUNT(*) FROM gacha_attempts WHERE date_key IS NULL;
   ```

### Rollback Instructions

If you need to rollback this migration:

```sql
-- Drop new functions
DROP FUNCTION IF EXISTS public.complete_ad_view_and_grant_ticket;
DROP FUNCTION IF EXISTS public.consume_gacha_attempts;
DROP FUNCTION IF EXISTS public.date_key_jst3;

-- Drop new columns (WARNING: data loss)
ALTER TABLE public.ad_views 
  DROP COLUMN IF EXISTS device_id,
  DROP COLUMN IF EXISTS user_agent,
  DROP COLUMN IF EXISTS client_ip,
  DROP COLUMN IF EXISTS status,
  DROP COLUMN IF EXISTS error_reason,
  DROP COLUMN IF EXISTS date_key,
  DROP COLUMN IF EXISTS reward_granted,
  DROP COLUMN IF EXISTS updated_at;

ALTER TABLE public.gacha_attempts
  DROP COLUMN IF EXISTS date_key,
  DROP COLUMN IF EXISTS source;

ALTER TABLE public.gacha_history
  DROP COLUMN IF EXISTS reward_points,
  DROP COLUMN IF EXISTS reward_silver_ticket;

-- Drop indexes
DROP INDEX IF EXISTS idx_ad_views_user_id_date_key;
DROP INDEX IF EXISTS idx_ad_views_device_id_date_key;
DROP INDEX IF EXISTS idx_ad_views_status;
DROP INDEX IF EXISTS idx_ad_views_reward_granted;
DROP INDEX IF EXISTS idx_gacha_attempts_date_key;
```

### Testing

Test the new functionality:

```sql
-- Test 1: Grant ticket (should succeed for first 3 times)
SELECT complete_ad_view_and_grant_ticket(
  auth.uid(),
  'test-device-123',
  null,
  'Test User Agent',
  '192.168.1.1'
);

-- Test 2: Check remaining today
SELECT 
  COUNT(*) FILTER (WHERE reward_granted AND date_key = date_key_jst3(now())) as granted_today,
  3 - COUNT(*) FILTER (WHERE reward_granted AND date_key = date_key_jst3(now())) as remaining
FROM ad_views
WHERE user_id = auth.uid();

-- Test 3: Consume gacha and grant points
SELECT consume_gacha_attempts(
  auth.uid(),
  1,
  'normal',
  20,
  false,
  '{"type":"point","amount":20}'::jsonb
);

-- Test 4: Verify point grant
SELECT balance FROM s_points WHERE user_id = auth.uid();
```

### Impact on Application

**Flutter Client Changes:**
- `ad_service.dart`: Now calls `complete_ad_view_and_grant_ticket` RPC
- `gacha_attempts_manager.dart`: Removed local `setTodayBaseAttempts(10)`
- `gacha_view_model.dart`: Uses `consume_gacha_attempts` RPC for atomic operations
- `gacha_repository.dart`: Updated probability table for expected value balance

**Expected Behavior:**
1. Users can watch ads up to 3 times per day (JST 3:00 reset)
2. 4th ad view in same day is rejected with error message
3. All ad views are logged with device_id for analytics
4. Gacha consumption and reward grants happen atomically
5. Points are automatically added to s_points when awarded

### Analytics Queries

Example queries for Lv2-Lite analytics:

```sql
-- Daily ad views and grants by user
SELECT 
  date_key,
  COUNT(DISTINCT user_id) as unique_users,
  COUNT(*) as total_views,
  COUNT(*) FILTER (WHERE reward_granted) as granted_tickets,
  COUNT(*) FILTER (WHERE status = 'revoked') as rejected_over_limit
FROM ad_views
WHERE date_key >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY date_key
ORDER BY date_key DESC;

-- Device-level analysis
SELECT 
  device_id,
  COUNT(DISTINCT user_id) as user_count,
  COUNT(*) as view_count,
  COUNT(*) FILTER (WHERE reward_granted) as granted_count
FROM ad_views
WHERE date_key = date_key_jst3(now())
GROUP BY device_id
HAVING COUNT(DISTINCT user_id) > 1  -- Potential multi-account devices
ORDER BY user_count DESC;

-- Gacha reward distribution
SELECT 
  source,
  COUNT(*) as total_draws,
  SUM(reward_points) as total_points,
  COUNT(*) FILTER (WHERE reward_silver_ticket) as silver_tickets,
  AVG(reward_points) as avg_points_per_draw
FROM gacha_history
WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY source;
```

### Notes

- **JST 3:00 Reset**: The daily limit resets at 3:00 AM JST, not midnight
- **Atomic Operations**: RPC functions use transactions to ensure data consistency
- **Security**: All RPCs verify user authentication before execution
- **Backward Compatibility**: Old code paths still work but are deprecated
- **Lv2-Lite**: This migration provides observation infrastructure; automated actions (bans, rate limits) are not yet implemented

### Related Files

- Migration: `/supabase/migrations/20251121_add_ad_views_logging_and_gacha_rpc.sql`
- Flutter Services: `/lib/src/features/gacha/services/ad_service.dart`
- Repository: `/lib/src/features/gacha/data/gacha_limits_repository.dart`
- View Model: `/lib/src/features/gacha/presentation/gacha_view_model.dart`
- Attempts Manager: `/lib/src/features/gacha/providers/gacha_attempts_manager.dart`
