# Supabase Migrations

This directory contains SQL migration files for the Starlist app database schema.

## Migration Naming Convention

Migrations follow the pattern: `YYYYMMDD_description.sql`

Example: `20251121_add_ad_views_logging_and_gacha_rpc.sql`

## Running Migrations

### Apply migrations to remote database

```bash
supabase db push
```

### Pull current database state to local

```bash
supabase db pull
```

## Recent Migration: Ad-View Logging and Gacha Ticket System

**Migration file**: `20251121_add_ad_views_logging_and_gacha_rpc.sql`

### What's New

This migration implements server-side control for ad-view granted gacha tickets with JST timezone handling.

#### Tables Created/Modified

1. **ad_views** - Logs all ad view attempts with fraud detection fields
   - `device_id`, `user_agent`, `client_ip` for device tracking
   - `status` (pending/success/failed/revoked) for lifecycle tracking
   - `date_key` for JST 03:00 boundary daily limits
   - `reward_granted` flag for tracking which views earned tickets

2. **gacha_attempts** - User gacha ticket balance
   - `balance` - Current available tickets
   - `date_key` - Last update date for tracking

3. **gacha_history** - Record of all gacha draws
   - `reward_points` - Star points awarded
   - `reward_silver_ticket`, `reward_gold_ticket` - Ticket rewards
   - `source` - Origin of the ticket (ad_view, purchase, etc.)
   - `date_key` - Draw date for analytics

#### Functions Created

1. **date_key_jst3(ts)** - Calculate JST date with 03:00 boundary
   - Converts UTC to JST (UTC+9)
   - Shifts boundary from 00:00 to 03:00
   - Example: 02:59 JST = previous day, 03:00 JST = current day

2. **complete_ad_view_and_grant_ticket(user_id, device_id, ad_view_id)** 
   - Records ad view completion
   - Enforces daily limit of 3 tickets per user per JST day
   - Grants gacha ticket if under limit
   - Returns: granted status, remaining today, total balance, ad_view_id
   - Race-condition safe with SELECT FOR UPDATE

3. **consume_gacha_attempts(user_id, consume_count, source, reward_points, reward_silver_ticket, reward_gold_ticket)**
   - Validates and decrements gacha balance
   - Records gacha draw in history
   - Returns: new balance, history_id
   - Atomic transaction with balance checking

4. **get_user_gacha_state(user_id)**
   - Returns current gacha balance and today's granted count
   - Used by client to update UI state

### Backfill Instructions

If you have existing data in `ad_views` or `gacha_history` tables without `date_key` values, run:

```sql
-- Backfill ad_views
UPDATE public.ad_views
SET date_key = public.date_key_jst3(created_at)
WHERE date_key IS NULL AND created_at IS NOT NULL;

-- Backfill gacha_history
UPDATE public.gacha_history
SET date_key = public.date_key_jst3(created_at)
WHERE date_key IS NULL AND created_at IS NOT NULL;
```

These statements are already included in the migration file.

### Daily Limit Enforcement

- **Limit**: 3 ad-granted tickets per user per JST day
- **Boundary**: 03:00 JST (00:00 JST - 03:00 JST counts as previous day)
- **Tracking**: `date_key` column uses `date_key_jst3()` function
- **Enforcement**: `complete_ad_view_and_grant_ticket()` checks count before granting

### Security

- All tables have Row Level Security (RLS) enabled
- Users can only access their own data
- RPC functions validate `auth.uid()` matches `user_id` parameter
- Functions use `SECURITY DEFINER` to bypass RLS when needed
- `SELECT FOR UPDATE` prevents race conditions on balance updates

### Testing

Test the daily limit enforcement:

```sql
-- Get current state
SELECT * FROM get_user_gacha_state('YOUR_USER_ID');

-- Simulate 4 ad views (4th should be rejected)
SELECT * FROM complete_ad_view_and_grant_ticket('YOUR_USER_ID', 'device_123', gen_random_uuid());
SELECT * FROM complete_ad_view_and_grant_ticket('YOUR_USER_ID', 'device_123', gen_random_uuid());
SELECT * FROM complete_ad_view_and_grant_ticket('YOUR_USER_ID', 'device_123', gen_random_uuid());
SELECT * FROM complete_ad_view_and_grant_ticket('YOUR_USER_ID', 'device_123', gen_random_uuid());

-- Check ad_views table
SELECT id, status, reward_granted, date_key, created_at 
FROM ad_views 
WHERE user_id = 'YOUR_USER_ID' 
ORDER BY created_at DESC;

-- Verify balance
SELECT * FROM gacha_attempts WHERE user_id = 'YOUR_USER_ID';
```

Expected behavior:
- First 3 calls return `granted = TRUE` with decreasing `remaining_today`
- 4th call returns `granted = FALSE` with status='revoked'
- Balance increases by 3, not 4

## Rollback

If you need to rollback this migration, drop the objects in reverse order:

```sql
-- Drop RPC functions
DROP FUNCTION IF EXISTS public.get_user_gacha_state(UUID);
DROP FUNCTION IF EXISTS public.consume_gacha_attempts(UUID, INTEGER, TEXT, INTEGER, BOOLEAN, BOOLEAN);
DROP FUNCTION IF EXISTS public.complete_ad_view_and_grant_ticket(UUID, TEXT, UUID);
DROP FUNCTION IF EXISTS public.date_key_jst3(TIMESTAMPTZ);

-- Drop tables (be careful - this will delete data!)
DROP TABLE IF EXISTS public.gacha_history;
DROP TABLE IF EXISTS public.gacha_attempts;
DROP TABLE IF EXISTS public.ad_views;
```

**Warning**: Dropping tables will permanently delete all data. Always backup before rollback.
