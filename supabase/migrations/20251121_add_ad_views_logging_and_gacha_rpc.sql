-- Ad-view logging and gacha ticket system with JST 03:00 boundary
-- 2025-11-21

-- ====================================================================
-- 1. JST date_key calculation function (JST = UTC+9, boundary at 03:00)
-- ====================================================================

CREATE OR REPLACE FUNCTION public.date_key_jst3(ts TIMESTAMPTZ)
RETURNS DATE
LANGUAGE SQL
IMMUTABLE
AS $$
  -- Convert UTC timestamp to JST (UTC+9)
  -- Then subtract 3 hours to shift the day boundary from 00:00 to 03:00
  -- Example: 2025-11-21 02:59:59 JST -> 2025-11-20 (previous day)
  --          2025-11-21 03:00:00 JST -> 2025-11-21 (current day)
  SELECT DATE((ts AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Tokyo') - INTERVAL '3 hours');
$$;

COMMENT ON FUNCTION public.date_key_jst3(TIMESTAMPTZ) IS 
  'Calculate JST date with 03:00 boundary for daily limits. Times before 03:00 JST count as previous day.';

-- ====================================================================
-- 2. Create ad_views table for ad viewing logs
-- ====================================================================

CREATE TABLE IF NOT EXISTS public.ad_views (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  device_id TEXT,
  user_agent TEXT,
  client_ip INET,
  ad_type TEXT,
  ad_provider TEXT,
  ad_id TEXT,
  view_duration INTEGER,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'success', 'failed', 'revoked')),
  error_reason TEXT,
  date_key DATE,
  reward_granted BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ad_views_user_date ON public.ad_views(user_id, date_key);
CREATE INDEX IF NOT EXISTS idx_ad_views_device_date ON public.ad_views(device_id, date_key);
CREATE INDEX IF NOT EXISTS idx_ad_views_created_at ON public.ad_views(created_at);

COMMENT ON TABLE public.ad_views IS 'Logs all ad view attempts with device info and fraud detection fields';
COMMENT ON COLUMN public.ad_views.device_id IS 'Device identifier for fraud detection';
COMMENT ON COLUMN public.ad_views.status IS 'pending: started, success: completed and rewarded, failed: error, revoked: daily limit exceeded';
COMMENT ON COLUMN public.ad_views.date_key IS 'JST date with 03:00 boundary for daily limit calculation';
COMMENT ON COLUMN public.ad_views.reward_granted IS 'TRUE if gacha ticket was granted for this ad view';

-- Enable RLS
ALTER TABLE public.ad_views ENABLE ROW LEVEL SECURITY;

-- Users can view their own ad view logs
CREATE POLICY "Users can view their own ad views" ON public.ad_views
  FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own ad view logs
CREATE POLICY "Users can insert their own ad views" ON public.ad_views
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ====================================================================
-- 3. Create gacha_attempts table for tracking user gacha balance
-- ====================================================================

CREATE TABLE IF NOT EXISTS public.gacha_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  balance INTEGER NOT NULL DEFAULT 0 CHECK (balance >= 0),
  date_key DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id)
);

CREATE INDEX IF NOT EXISTS idx_gacha_attempts_user_id ON public.gacha_attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_gacha_attempts_date_key ON public.gacha_attempts(date_key);

COMMENT ON TABLE public.gacha_attempts IS 'User gacha ticket balance';
COMMENT ON COLUMN public.gacha_attempts.balance IS 'Current number of available gacha tickets';
COMMENT ON COLUMN public.gacha_attempts.date_key IS 'Last updated date key for tracking';

-- Enable RLS
ALTER TABLE public.gacha_attempts ENABLE ROW LEVEL SECURITY;

-- Users can view their own balance
CREATE POLICY "Users can view their own gacha balance" ON public.gacha_attempts
  FOR SELECT USING (auth.uid() = user_id);

-- Users can update their own balance via RPC only
CREATE POLICY "Users can update their own gacha balance" ON public.gacha_attempts
  FOR UPDATE USING (auth.uid() = user_id);

-- Users can insert their own balance
CREATE POLICY "Users can insert their own gacha balance" ON public.gacha_attempts
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Update trigger
CREATE OR REPLACE FUNCTION public.update_gacha_attempts_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_gacha_attempts_updated_at
  BEFORE UPDATE ON public.gacha_attempts
  FOR EACH ROW EXECUTE FUNCTION public.update_gacha_attempts_updated_at();

-- ====================================================================
-- 4. Create gacha_history table for tracking gacha draws
-- ====================================================================

CREATE TABLE IF NOT EXISTS public.gacha_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  reward_points INTEGER DEFAULT 0,
  reward_silver_ticket BOOLEAN DEFAULT FALSE,
  reward_gold_ticket BOOLEAN DEFAULT FALSE,
  source TEXT,
  date_key DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_gacha_history_user_id ON public.gacha_history(user_id);
CREATE INDEX IF NOT EXISTS idx_gacha_history_created_at ON public.gacha_history(created_at);
CREATE INDEX IF NOT EXISTS idx_gacha_history_date_key ON public.gacha_history(date_key);

COMMENT ON TABLE public.gacha_history IS 'History of all gacha draws and their rewards';
COMMENT ON COLUMN public.gacha_history.reward_points IS 'Star points awarded from this draw (0 if ticket)';
COMMENT ON COLUMN public.gacha_history.reward_silver_ticket IS 'TRUE if silver ticket was awarded';
COMMENT ON COLUMN public.gacha_history.source IS 'How tickets were obtained: ad_view, purchase, admin, etc.';

-- Enable RLS
ALTER TABLE public.gacha_history ENABLE ROW LEVEL SECURITY;

-- Users can view their own history
CREATE POLICY "Users can view their own gacha history" ON public.gacha_history
  FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own history
CREATE POLICY "Users can insert their own gacha history" ON public.gacha_history
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ====================================================================
-- 5. Backfill existing data with date_key
-- ====================================================================

-- Backfill ad_views table if it has existing data without date_key
UPDATE public.ad_views
SET date_key = public.date_key_jst3(created_at)
WHERE date_key IS NULL AND created_at IS NOT NULL;

-- Backfill gacha_history table if it exists with data
UPDATE public.gacha_history
SET date_key = public.date_key_jst3(created_at)
WHERE date_key IS NULL AND created_at IS NOT NULL;

-- ====================================================================
-- 6. RPC: complete_ad_view_and_grant_ticket
-- ====================================================================

CREATE OR REPLACE FUNCTION public.complete_ad_view_and_grant_ticket(
  p_user_id UUID,
  p_device_id TEXT,
  p_ad_view_id UUID DEFAULT NULL
)
RETURNS TABLE(
  granted BOOLEAN,
  remaining_today INTEGER,
  total_balance INTEGER,
  ad_view_id UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_ad_view_id UUID;
  v_date_key DATE;
  v_granted_count INTEGER;
  v_current_balance INTEGER;
  v_granted BOOLEAN := FALSE;
  v_remaining INTEGER := 0;
BEGIN
  -- Security: Ensure caller is the user
  IF auth.uid() != p_user_id THEN
    RAISE EXCEPTION 'Unauthorized: user_id mismatch';
  END IF;

  -- Calculate current date_key in JST with 03:00 boundary
  v_date_key := public.date_key_jst3(NOW());
  
  -- Use provided ad_view_id or generate new one
  v_ad_view_id := COALESCE(p_ad_view_id, gen_random_uuid());

  -- Insert or update ad_views record with success status
  INSERT INTO public.ad_views (
    id,
    user_id,
    device_id,
    status,
    date_key,
    created_at
  ) VALUES (
    v_ad_view_id,
    p_user_id,
    p_device_id,
    'success',
    v_date_key,
    NOW()
  )
  ON CONFLICT (id) DO UPDATE
  SET 
    status = 'success',
    date_key = v_date_key;

  -- Count how many rewards already granted today
  SELECT COUNT(*) INTO v_granted_count
  FROM public.ad_views
  WHERE user_id = p_user_id
    AND date_key = v_date_key
    AND reward_granted = TRUE;

  -- Check if under daily limit (3 tickets per day)
  IF v_granted_count < 3 THEN
    -- Lock user's gacha_attempts row for update
    SELECT balance INTO v_current_balance
    FROM public.gacha_attempts
    WHERE user_id = p_user_id
    FOR UPDATE;

    -- Insert if not exists
    IF v_current_balance IS NULL THEN
      INSERT INTO public.gacha_attempts (user_id, balance, date_key)
      VALUES (p_user_id, 1, v_date_key)
      RETURNING balance INTO v_current_balance;
    ELSE
      -- Increment balance
      UPDATE public.gacha_attempts
      SET balance = balance + 1,
          date_key = v_date_key
      WHERE user_id = p_user_id
      RETURNING balance INTO v_current_balance;
    END IF;

    -- Mark this ad_view as rewarded
    UPDATE public.ad_views
    SET reward_granted = TRUE
    WHERE id = v_ad_view_id;

    v_granted := TRUE;
    v_remaining := 2 - v_granted_count; -- Remaining slots today
  ELSE
    -- Daily limit reached - revoke this attempt
    UPDATE public.ad_views
    SET status = 'revoked',
        error_reason = 'Daily limit of 3 ad-granted tickets reached'
    WHERE id = v_ad_view_id;

    v_granted := FALSE;
    v_remaining := 0;
    
    -- Get current balance without updating
    SELECT balance INTO v_current_balance
    FROM public.gacha_attempts
    WHERE user_id = p_user_id;
    
    v_current_balance := COALESCE(v_current_balance, 0);
  END IF;

  -- Return results
  RETURN QUERY SELECT 
    v_granted,
    v_remaining,
    v_current_balance,
    v_ad_view_id;
END;
$$;

COMMENT ON FUNCTION public.complete_ad_view_and_grant_ticket IS 
  'Complete ad view and grant gacha ticket if under daily limit (3/day). Uses JST 03:00 boundary.';

-- ====================================================================
-- 7. RPC: consume_gacha_attempts
-- ====================================================================

CREATE OR REPLACE FUNCTION public.consume_gacha_attempts(
  p_user_id UUID,
  p_consume_count INTEGER,
  p_source TEXT,
  p_reward_points INTEGER DEFAULT 0,
  p_reward_silver_ticket BOOLEAN DEFAULT FALSE,
  p_reward_gold_ticket BOOLEAN DEFAULT FALSE
)
RETURNS TABLE(
  new_balance INTEGER,
  history_id UUID
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_current_balance INTEGER;
  v_new_balance INTEGER;
  v_history_id UUID;
  v_date_key DATE;
BEGIN
  -- Security: Ensure caller is the user
  IF auth.uid() != p_user_id THEN
    RAISE EXCEPTION 'Unauthorized: user_id mismatch';
  END IF;

  -- Validate consume_count
  IF p_consume_count <= 0 THEN
    RAISE EXCEPTION 'Invalid consume_count: must be positive';
  END IF;

  -- Calculate current date_key
  v_date_key := public.date_key_jst3(NOW());

  -- Lock and get current balance
  SELECT balance INTO v_current_balance
  FROM public.gacha_attempts
  WHERE user_id = p_user_id
  FOR UPDATE;

  -- Check if balance exists and is sufficient
  IF v_current_balance IS NULL THEN
    RAISE EXCEPTION 'No gacha balance found for user';
  END IF;

  IF v_current_balance < p_consume_count THEN
    RAISE EXCEPTION 'Insufficient balance: have %, need %', v_current_balance, p_consume_count;
  END IF;

  -- Decrement balance
  UPDATE public.gacha_attempts
  SET balance = balance - p_consume_count,
      date_key = v_date_key
  WHERE user_id = p_user_id
  RETURNING balance INTO v_new_balance;

  -- Insert gacha history record
  INSERT INTO public.gacha_history (
    user_id,
    reward_points,
    reward_silver_ticket,
    reward_gold_ticket,
    source,
    date_key,
    created_at
  ) VALUES (
    p_user_id,
    p_reward_points,
    p_reward_silver_ticket,
    p_reward_gold_ticket,
    p_source,
    v_date_key,
    NOW()
  )
  RETURNING id INTO v_history_id;

  -- Return results
  RETURN QUERY SELECT v_new_balance, v_history_id;
END;
$$;

COMMENT ON FUNCTION public.consume_gacha_attempts IS 
  'Consume gacha tickets and record result in history. Validates balance before decrementing.';

-- ====================================================================
-- 8. RPC: get_user_gacha_state
-- ====================================================================

CREATE OR REPLACE FUNCTION public.get_user_gacha_state(
  p_user_id UUID
)
RETURNS TABLE(
  balance INTEGER,
  today_granted INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_balance INTEGER;
  v_today_granted INTEGER;
  v_date_key DATE;
BEGIN
  -- Security: Ensure caller is the user
  IF auth.uid() != p_user_id THEN
    RAISE EXCEPTION 'Unauthorized: user_id mismatch';
  END IF;

  -- Calculate current date_key
  v_date_key := public.date_key_jst3(NOW());

  -- Get current balance
  SELECT gacha_attempts.balance INTO v_balance
  FROM public.gacha_attempts
  WHERE user_id = p_user_id;

  v_balance := COALESCE(v_balance, 0);

  -- Count today's granted tickets
  SELECT COUNT(*) INTO v_today_granted
  FROM public.ad_views
  WHERE user_id = p_user_id
    AND date_key = v_date_key
    AND reward_granted = TRUE;

  -- Return results
  RETURN QUERY SELECT v_balance, v_today_granted::INTEGER;
END;
$$;

COMMENT ON FUNCTION public.get_user_gacha_state IS 
  'Get user gacha state: current balance and tickets granted today. Uses JST 03:00 boundary.';

-- ====================================================================
-- 9. Grant execute permissions to authenticated users
-- ====================================================================

GRANT EXECUTE ON FUNCTION public.date_key_jst3(TIMESTAMPTZ) TO authenticated;
GRANT EXECUTE ON FUNCTION public.complete_ad_view_and_grant_ticket(UUID, TEXT, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.consume_gacha_attempts(UUID, INTEGER, TEXT, INTEGER, BOOLEAN, BOOLEAN) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_gacha_state(UUID) TO authenticated;
