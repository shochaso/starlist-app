-- Test script for ad-view gacha ticket system
-- This script tests the daily limit enforcement (3 tickets per JST day)
--
-- Prerequisites:
-- 1. Run the migration: 20251121_add_ad_views_logging_and_gacha_rpc.sql
-- 2. Have a test user in the users table
--
-- Usage:
-- Replace 'YOUR_TEST_USER_ID' with an actual UUID from your users table
-- Run this script in a SQL client connected to your Supabase database

-- Setup: Clean test data for user
DO $$
DECLARE
  test_user_id UUID := 'YOUR_TEST_USER_ID'; -- Replace with actual user ID
BEGIN
  -- Clean existing test data
  DELETE FROM public.ad_views WHERE user_id = test_user_id;
  DELETE FROM public.gacha_history WHERE user_id = test_user_id;
  DELETE FROM public.gacha_attempts WHERE user_id = test_user_id;
  
  RAISE NOTICE 'Test data cleaned for user %', test_user_id;
END $$;

-- Test 1: Initial state - should have 0 balance and 0 granted today
SELECT 
  'Test 1: Initial state' AS test_name,
  *
FROM public.get_user_gacha_state('YOUR_TEST_USER_ID');

-- Test 2: First ad view - should grant ticket (granted=true, remaining_today=2)
SELECT 
  'Test 2: First ad view' AS test_name,
  *
FROM public.complete_ad_view_and_grant_ticket(
  'YOUR_TEST_USER_ID'::UUID,
  'test_device_001',
  NULL -- Let server generate UUID
);

-- Verify balance after first grant
SELECT 
  'After Test 2: Verify balance' AS test_name,
  *
FROM public.get_user_gacha_state('YOUR_TEST_USER_ID');

-- Test 3: Second ad view - should grant ticket (granted=true, remaining_today=1)
SELECT 
  'Test 3: Second ad view' AS test_name,
  *
FROM public.complete_ad_view_and_grant_ticket(
  'YOUR_TEST_USER_ID'::UUID,
  'test_device_001',
  NULL
);

-- Test 4: Third ad view - should grant ticket (granted=true, remaining_today=0)
SELECT 
  'Test 4: Third ad view' AS test_name,
  *
FROM public.complete_ad_view_and_grant_ticket(
  'YOUR_TEST_USER_ID'::UUID,
  'test_device_001',
  NULL
);

-- Verify balance after third grant (should be 3)
SELECT 
  'After Test 4: Verify balance=3' AS test_name,
  *
FROM public.get_user_gacha_state('YOUR_TEST_USER_ID');

-- Test 5: Fourth ad view - should be REJECTED (granted=false, remaining_today=0, status=revoked)
SELECT 
  'Test 5: Fourth ad view (SHOULD FAIL)' AS test_name,
  *
FROM public.complete_ad_view_and_grant_ticket(
  'YOUR_TEST_USER_ID'::UUID,
  'test_device_001',
  NULL
);

-- Verify balance unchanged (still 3)
SELECT 
  'After Test 5: Verify balance still=3' AS test_name,
  *
FROM public.get_user_gacha_state('YOUR_TEST_USER_ID');

-- Check ad_views table - should show 4 records, last one with status='revoked'
SELECT 
  'Verify ad_views records' AS test_name,
  id,
  status,
  reward_granted,
  date_key,
  created_at
FROM public.ad_views
WHERE user_id = 'YOUR_TEST_USER_ID'
ORDER BY created_at;

-- Test 6: Consume 1 gacha attempt
SELECT 
  'Test 6: Consume 1 ticket' AS test_name,
  *
FROM public.consume_gacha_attempts(
  'YOUR_TEST_USER_ID'::UUID,
  1,
  'test_gacha',
  50, -- reward_points
  false, -- reward_silver_ticket
  false  -- reward_gold_ticket
);

-- Verify balance decreased to 2
SELECT 
  'After Test 6: Verify balance=2' AS test_name,
  *
FROM public.get_user_gacha_state('YOUR_TEST_USER_ID');

-- Check gacha_history - should have 1 record with 50 points
SELECT 
  'Verify gacha_history' AS test_name,
  id,
  reward_points,
  reward_silver_ticket,
  source,
  date_key,
  created_at
FROM public.gacha_history
WHERE user_id = 'YOUR_TEST_USER_ID'
ORDER BY created_at;

-- Test 7: Try to consume more tickets than available (should fail)
DO $$
DECLARE
  test_user_id UUID := 'YOUR_TEST_USER_ID';
BEGIN
  PERFORM public.consume_gacha_attempts(
    test_user_id,
    10, -- Try to consume 10 tickets
    'test_gacha',
    100,
    false,
    false
  );
  RAISE EXCEPTION 'Test 7 FAILED: Should have raised insufficient balance error';
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Test 7 PASSED: Correctly rejected with error: %', SQLERRM;
END $$;

-- Test 8: Test date_key_jst3 function with various times
SELECT 
  'Test 8: JST boundary' AS test_name,
  ts,
  public.date_key_jst3(ts) AS date_key,
  CASE 
    WHEN EXTRACT(HOUR FROM (ts AT TIME ZONE 'Asia/Tokyo')) < 3 THEN 'Before 03:00 JST'
    ELSE 'After 03:00 JST'
  END AS boundary_status
FROM (
  VALUES 
    ('2025-11-21 17:59:00+00'::TIMESTAMPTZ), -- 02:59 JST (should be 2025-11-20)
    ('2025-11-21 18:00:00+00'::TIMESTAMPTZ), -- 03:00 JST (should be 2025-11-21)
    ('2025-11-21 18:01:00+00'::TIMESTAMPTZ), -- 03:01 JST (should be 2025-11-21)
    ('2025-11-21 14:59:00+00'::TIMESTAMPTZ)  -- 23:59 JST (should be 2025-11-21)
) AS t(ts);

-- Summary
SELECT 
  'TEST SUMMARY' AS summary,
  'All tests completed. Check results above.' AS message,
  'Expected: Tests 1-6 pass, Test 7 raises error correctly, Test 8 shows boundary logic' AS expected_results;

-- Cleanup (optional - uncomment to clean up test data)
-- DO $$
-- DECLARE
--   test_user_id UUID := 'YOUR_TEST_USER_ID';
-- BEGIN
--   DELETE FROM public.ad_views WHERE user_id = test_user_id;
--   DELETE FROM public.gacha_history WHERE user_id = test_user_id;
--   DELETE FROM public.gacha_attempts WHERE user_id = test_user_id;
--   RAISE NOTICE 'Test data cleaned up';
-- END $$;
