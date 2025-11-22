# DEPRECATED: Legacy Gacha Implementation

**This directory contains the old client-side gacha system and is deprecated.**

## Migration Information

**New Implementation Location:** `lib/src/features/gacha/`

**Migration Date:** 2025-11-21

**Migration File:** `supabase/migrations/20251121_add_ad_views_logging_and_gacha_rpc.sql`

## What Changed

### Old System (Deprecated)
- Client-side gacha ticket management using `LocalStore`
- AB testing variants (`ABConfig`)
- Web-based ad bridge (`AdBridge`)
- Local daily reset at JST 00:00
- Daily cap of 3 rewarded ads (client-side enforcement)
- Hourly cap of 2 rewarded ads (client-side enforcement)

### New System (Current)
- **Server-side** gacha ticket management via Supabase RPC
- Daily limit of 3 ad-granted tickets enforced server-side
- JST timezone with **03:00 boundary** for daily resets
- Device tracking for fraud detection (device_id, user_agent, client_ip)
- Comprehensive logging in `ad_views` table
- Race-condition safe with PostgreSQL locks
- No more AB testing - single consistent behavior

## Key Components Replaced

| Old File | New File | Purpose |
|----------|----------|---------|
| `gacha_controller.dart` | `lib/src/features/gacha/providers/gacha_attempts_manager.dart` | Ticket balance management |
| N/A (client-side) | `lib/src/features/gacha/services/ad_service.dart` | Ad viewing and server integration |
| N/A (client-side) | `supabase/migrations/20251121_*.sql` | Server RPC functions |

## Server RPC Functions

1. **`complete_ad_view_and_grant_ticket(user_id, device_id, ad_view_id)`**
   - Records ad view with status tracking
   - Enforces daily limit (3 tickets per JST day)
   - Grants ticket if under limit
   - Returns: granted boolean, remaining_today, total_balance, ad_view_id

2. **`consume_gacha_attempts(user_id, consume_count, source, reward_points, reward_silver_ticket, reward_gold_ticket)`**
   - Validates and decrements balance
   - Records gacha draw in history
   - Returns: new_balance, history_id

3. **`get_user_gacha_state(user_id)`**
   - Returns: current balance, today_granted count

## Breaking Changes

### ⚠️ No More Auto-Grant of 10 Base Tickets

The old system automatically granted 10 free gacha tickets per day. **This has been removed.**

- **Old behavior:** Users start with 10 free tickets daily (reset at JST 00:00)
- **New behavior:** Users start with 0 tickets and must watch ads to earn them

This is a significant UX change that affects user progression.

### Daily Boundary Changed

- **Old:** JST 00:00 (midnight)
- **New:** JST 03:00 (3 AM)

Times between 00:00-02:59 JST now count as the previous day.

## Migration Guide for Developers

If you need to update code that references this directory:

1. **Remove imports** from `lib/features/gacha/`
2. **Add imports** from `lib/src/features/gacha/`
3. **Update gacha draw logic:**
   ```dart
   // OLD (deprecated)
   final controller = GachaController();
   await controller.init();
   final success = await controller.spin();
   
   // NEW
   final manager = ref.read(gachaAttemptsManagerProvider(userId).notifier);
   final state = ref.watch(gachaAttemptsManagerProvider(userId));
   await manager.consumeAttempt();
   ```

4. **Update ad viewing logic:**
   ```dart
   // OLD (deprecated)
   final success = await AdBridge.showRewarded();
   
   // NEW
   final adService = ref.read(adServiceProvider);
   final result = await adService.showAd(AdType.video);
   if (result.success) {
     // Server automatically grants ticket
     await manager.refreshAttempts();
   }
   ```

## When Will This Be Removed?

These files are marked as `@Deprecated` but will remain in the codebase for backwards compatibility during the migration period. They may be removed in a future release after confirming no dependencies remain.

## Questions?

See the main documentation:
- `supabase/migrations/README.md` - Migration and RPC documentation
- `CHANGELOG.md` - Behavior changes and deprecation notices
