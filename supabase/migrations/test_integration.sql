-- Integration Test SQL for Ad-based Gacha Ticket Restriction
-- Run this manually in psql or Supabase SQL Editor to verify functionality
-- Make sure to replace 'YOUR-USER-UUID' with an actual test user UUID

-- ============================================================================
-- Setup: Create test user (if needed)
-- ============================================================================
-- Note: In production, users are created via Auth. This is for testing only.
-- You should use an existing authenticated user UUID

-- ============================================================================
-- Test 1: Date Key Function (JST 3:00 boundary)
-- ============================================================================
SELECT '=== Test 1: Date Key Function ===' as test;

-- Test before 3:00 JST (should return previous day)
SELECT 
  '2025-11-21 02:59:59+09'::timestamptz as input_time,
  date_key_jst3('2025-11-21 02:59:59+09'::timestamptz) as date_key,
  '2025-11-20'::date as expected,
  date_key_jst3('2025-11-21 02:59:59+09'::timestamptz) = '2025-11-20'::date as test_passed;

-- Test at 3:00 JST (should return current day)
SELECT 
  '2025-11-21 03:00:00+09'::timestamptz as input_time,
  date_key_jst3('2025-11-21 03:00:00+09'::timestamptz) as date_key,
  '2025-11-21'::date as expected,
  date_key_jst3('2025-11-21 03:00:00+09'::timestamptz) = '2025-11-21'::date as test_passed;

-- Test midnight (should still be previous day)
SELECT 
  '2025-11-22 00:00:00+09'::timestamptz as input_time,
  date_key_jst3('2025-11-22 00:00:00+09'::timestamptz) as date_key,
  '2025-11-21'::date as expected,
  date_key_jst3('2025-11-22 00:00:00+09'::timestamptz) = '2025-11-21'::date as test_passed;

-- ============================================================================
-- Test 2: Complete Ad View and Grant Ticket (Success Cases)
-- ============================================================================
SELECT '=== Test 2a: First Ad View (Should Succeed) ===' as test;

-- Replace with your test user UUID
DO $$
DECLARE
  test_user_id UUID := 'YOUR-USER-UUID'; -- REPLACE THIS
  result JSONB;
BEGIN
  -- Grant first ticket
  result := complete_ad_view_and_grant_ticket(
    test_user_id,
    'test-device-001',
    NULL,
    'Test User Agent',
    '192.168.1.1'
  );
  
  RAISE NOTICE 'Result: %', result;
  
  IF (result->>'granted')::boolean = true THEN
    RAISE NOTICE 'Test PASSED: First ticket granted';
  ELSE
    RAISE EXCEPTION 'Test FAILED: First ticket should be granted';
  END IF;
END $$;

-- Check database state
SELECT 
  COUNT(*) as total_ad_views,
  COUNT(*) FILTER (WHERE reward_granted = true) as granted_count,
  COUNT(*) FILTER (WHERE status = 'success') as success_count
FROM ad_views
WHERE user_id = 'YOUR-USER-UUID' -- REPLACE THIS
  AND date_key = date_key_jst3(now());

SELECT '=== Test 2b: Second Ad View (Should Succeed) ===' as test;

DO $$
DECLARE
  test_user_id UUID := 'YOUR-USER-UUID'; -- REPLACE THIS
  result JSONB;
BEGIN
  result := complete_ad_view_and_grant_ticket(
    test_user_id,
    'test-device-001',
    NULL,
    'Test User Agent',
    '192.168.1.1'
  );
  
  IF (result->>'granted')::boolean = true AND (result->>'remaining_today')::int = 1 THEN
    RAISE NOTICE 'Test PASSED: Second ticket granted, 1 remaining';
  ELSE
    RAISE EXCEPTION 'Test FAILED: Expected granted=true, remaining_today=1, got: %', result;
  END IF;
END $$;

SELECT '=== Test 2c: Third Ad View (Should Succeed) ===' as test;

DO $$
DECLARE
  test_user_id UUID := 'YOUR-USER-UUID'; -- REPLACE THIS
  result JSONB;
BEGIN
  result := complete_ad_view_and_grant_ticket(
    test_user_id,
    'test-device-001',
    NULL,
    'Test User Agent',
    '192.168.1.1'
  );
  
  IF (result->>'granted')::boolean = true AND (result->>'remaining_today')::int = 0 THEN
    RAISE NOTICE 'Test PASSED: Third ticket granted, 0 remaining';
  ELSE
    RAISE EXCEPTION 'Test FAILED: Expected granted=true, remaining_today=0, got: %', result;
  END IF;
END $$;

-- ============================================================================
-- Test 3: Complete Ad View and Grant Ticket (Rejection Case)
-- ============================================================================
SELECT '=== Test 3: Fourth Ad View (Should Be Rejected) ===' as test;

DO $$
DECLARE
  test_user_id UUID := 'YOUR-USER-UUID'; -- REPLACE THIS
  result JSONB;
BEGIN
  result := complete_ad_view_and_grant_ticket(
    test_user_id,
    'test-device-001',
    NULL,
    'Test User Agent',
    '192.168.1.1'
  );
  
  IF (result->>'granted')::boolean = false AND result->>'error' IS NOT NULL THEN
    RAISE NOTICE 'Test PASSED: Fourth ticket rejected with error: %', result->>'error';
  ELSE
    RAISE EXCEPTION 'Test FAILED: Expected granted=false with error, got: %', result;
  END IF;
END $$;

-- Verify rejection was recorded
SELECT 
  COUNT(*) as total_ad_views,
  COUNT(*) FILTER (WHERE reward_granted = true) as granted_count,
  COUNT(*) FILTER (WHERE status = 'revoked') as revoked_count,
  COUNT(*) FILTER (WHERE status = 'success') as success_count
FROM ad_views
WHERE user_id = 'YOUR-USER-UUID' -- REPLACE THIS
  AND date_key = date_key_jst3(now());

-- Expected: total=4, granted=3, revoked=1, success=3

-- ============================================================================
-- Test 4: Gacha Attempts State
-- ============================================================================
SELECT '=== Test 4: Verify Gacha Attempts State ===' as test;

SELECT 
  base_attempts,
  bonus_attempts,
  used_attempts,
  base_attempts + bonus_attempts - used_attempts as available
FROM gacha_attempts
WHERE user_id = 'YOUR-USER-UUID' -- REPLACE THIS
  AND date = CURRENT_DATE;

-- Expected: base_attempts=10, bonus_attempts=3, used_attempts depends on usage

-- ============================================================================
-- Test 5: Consume Gacha Attempts with Point Reward
-- ============================================================================
SELECT '=== Test 5: Consume Gacha with Point Reward ===' as test;

-- Check balance before
SELECT balance as balance_before 
FROM s_points 
WHERE user_id = 'YOUR-USER-UUID' -- REPLACE THIS
LIMIT 1;

DO $$
DECLARE
  test_user_id UUID := 'YOUR-USER-UUID'; -- REPLACE THIS
  result JSONB;
  initial_balance INT;
  new_balance INT;
BEGIN
  -- Get initial balance
  SELECT balance INTO initial_balance FROM s_points WHERE user_id = test_user_id;
  
  -- Consume gacha with 20 point reward
  result := consume_gacha_attempts(
    test_user_id,
    1,
    'test',
    20,
    false,
    '{"type":"point","amount":20}'::jsonb
  );
  
  new_balance := (result->>'new_balance')::int;
  
  -- Get updated balance
  SELECT balance INTO new_balance FROM s_points WHERE user_id = test_user_id;
  
  IF new_balance = initial_balance + 20 THEN
    RAISE NOTICE 'Test PASSED: Points awarded correctly (% -> %)', initial_balance, new_balance;
  ELSE
    RAISE EXCEPTION 'Test FAILED: Expected balance %, got %', initial_balance + 20, new_balance;
  END IF;
  
  RAISE NOTICE 'Result: %', result;
END $$;

-- Check balance after
SELECT balance as balance_after 
FROM s_points 
WHERE user_id = 'YOUR-USER-UUID' -- REPLACE THIS
LIMIT 1;

-- Verify transaction record
SELECT * 
FROM s_point_transactions 
WHERE user_id = 'YOUR-USER-UUID' -- REPLACE THIS
ORDER BY created_at DESC 
LIMIT 1;

-- ============================================================================
-- Test 6: Consume Gacha with Silver Ticket
-- ============================================================================
SELECT '=== Test 6: Consume Gacha with Silver Ticket ===' as test;

DO $$
DECLARE
  test_user_id UUID := 'YOUR-USER-UUID'; -- REPLACE THIS
  result JSONB;
BEGIN
  result := consume_gacha_attempts(
    test_user_id,
    1,
    'test',
    0,
    true,  -- Silver ticket awarded
    '{"type":"ticket","ticketType":"silver"}'::jsonb
  );
  
  IF (result->>'silver_ticket_awarded')::boolean = true THEN
    RAISE NOTICE 'Test PASSED: Silver ticket recorded';
  ELSE
    RAISE EXCEPTION 'Test FAILED: Silver ticket should be recorded';
  END IF;
  
  RAISE NOTICE 'Result: %', result;
END $$;

-- Verify history record
SELECT 
  reward_points,
  reward_silver_ticket,
  gacha_result
FROM gacha_history
WHERE user_id = 'YOUR-USER-UUID' -- REPLACE THIS
ORDER BY created_at DESC 
LIMIT 1;

-- Expected: reward_points=0, reward_silver_ticket=true

-- ============================================================================
-- Test 7: Insufficient Balance
-- ============================================================================
SELECT '=== Test 7: Insufficient Balance (Should Fail) ===' as test;

-- First, use all remaining attempts
DO $$
DECLARE
  test_user_id UUID := 'YOUR-USER-UUID'; -- REPLACE THIS
  available INT;
BEGIN
  -- Get available attempts
  SELECT base_attempts + bonus_attempts - used_attempts INTO available
  FROM gacha_attempts
  WHERE user_id = test_user_id AND date = CURRENT_DATE;
  
  -- Try to consume more than available
  BEGIN
    PERFORM consume_gacha_attempts(
      test_user_id,
      available + 1,  -- More than available
      'test',
      0,
      false,
      '{}'::jsonb
    );
    RAISE EXCEPTION 'Test FAILED: Should have raised insufficient balance error';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLERRM LIKE '%Insufficient gacha attempts%' THEN
        RAISE NOTICE 'Test PASSED: Correctly rejected insufficient balance';
      ELSE
        RAISE EXCEPTION 'Test FAILED: Unexpected error: %', SQLERRM;
      END IF;
  END;
END $$;

-- ============================================================================
-- Test 8: Device-Level Analytics
-- ============================================================================
SELECT '=== Test 8: Device-Level Analytics ===' as test;

SELECT 
  device_id,
  COUNT(DISTINCT user_id) as unique_users,
  COUNT(*) as total_views,
  COUNT(*) FILTER (WHERE reward_granted) as granted_tickets,
  COUNT(*) FILTER (WHERE status = 'revoked') as rejected_views
FROM ad_views
WHERE date_key >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY device_id
ORDER BY unique_users DESC, total_views DESC;

-- ============================================================================
-- Cleanup (Optional)
-- ============================================================================
SELECT '=== Cleanup (Uncomment to run) ===' as test;

-- Uncomment the following lines to clean up test data:

-- DELETE FROM ad_views WHERE user_id = 'YOUR-USER-UUID';
-- DELETE FROM gacha_history WHERE user_id = 'YOUR-USER-UUID';
-- DELETE FROM gacha_attempts WHERE user_id = 'YOUR-USER-UUID';

-- ============================================================================
-- Summary Report
-- ============================================================================
SELECT '=== Test Summary ===' as test;

SELECT 
  'Ad Views' as table_name,
  COUNT(*) as total_records,
  COUNT(*) FILTER (WHERE reward_granted = true) as granted,
  COUNT(*) FILTER (WHERE status = 'revoked') as revoked
FROM ad_views
WHERE user_id = 'YOUR-USER-UUID' -- REPLACE THIS

UNION ALL

SELECT 
  'Gacha History' as table_name,
  COUNT(*) as total_records,
  SUM(reward_points) as total_points,
  COUNT(*) FILTER (WHERE reward_silver_ticket = true) as silver_tickets
FROM gacha_history
WHERE user_id = 'YOUR-USER-UUID' -- REPLACE THIS

UNION ALL

SELECT 
  'Gacha Attempts' as table_name,
  SUM(base_attempts) as base,
  SUM(bonus_attempts) as bonus,
  SUM(used_attempts) as used
FROM gacha_attempts
WHERE user_id = 'YOUR-USER-UUID'; -- REPLACE THIS

SELECT 'All tests completed!' as message;
