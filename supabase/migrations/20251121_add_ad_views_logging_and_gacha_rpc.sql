-- Ad Views Logging and Gacha RPC with Daily Ticket Grant Limits
-- 2025-11-21
-- Purpose: Implement server-side control for ad-based gacha tickets (max 3/day, JST 3:00 reset)
-- and add Lv2-Lite device logging/metrics for analysis

-- ============================================================================
-- 1. Date Key Function (JST 3:00 baseline)
-- ============================================================================
-- Returns the date key based on JST (UTC+9) with 3:00 AM as the day boundary
-- Example: 2025-11-21 02:59:59 JST -> 2025-11-20
--          2025-11-21 03:00:00 JST -> 2025-11-21
CREATE OR REPLACE FUNCTION public.date_key_jst3(ts timestamptz)
RETURNS date
LANGUAGE sql IMMUTABLE
AS $$
  SELECT (ts AT TIME ZONE 'Asia/Tokyo' - interval '3 hours')::date
$$;

-- ============================================================================
-- 2. Create/Alter Tables
-- ============================================================================

-- Create ad_views table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.ad_views (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  ad_type TEXT,
  ad_provider TEXT,
  ad_id TEXT,
  view_duration INTEGER DEFAULT 0,
  completed BOOLEAN DEFAULT FALSE,
  reward_attempts INTEGER DEFAULT 0,
  viewed_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add new columns to ad_views for Lv2-Lite logging
DO $$ 
BEGIN
  -- device_id
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'ad_views' AND column_name = 'device_id'
  ) THEN
    ALTER TABLE public.ad_views ADD COLUMN device_id TEXT;
  END IF;

  -- user_agent
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'ad_views' AND column_name = 'user_agent'
  ) THEN
    ALTER TABLE public.ad_views ADD COLUMN user_agent TEXT;
  END IF;

  -- client_ip
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'ad_views' AND column_name = 'client_ip'
  ) THEN
    ALTER TABLE public.ad_views ADD COLUMN client_ip TEXT;
  END IF;

  -- status
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'ad_views' AND column_name = 'status'
  ) THEN
    ALTER TABLE public.ad_views ADD COLUMN status TEXT DEFAULT 'pending' 
      CHECK (status IN ('pending', 'success', 'failed', 'revoked'));
  END IF;

  -- error_reason
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'ad_views' AND column_name = 'error_reason'
  ) THEN
    ALTER TABLE public.ad_views ADD COLUMN error_reason TEXT;
  END IF;

  -- date_key
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'ad_views' AND column_name = 'date_key'
  ) THEN
    ALTER TABLE public.ad_views ADD COLUMN date_key DATE;
  END IF;

  -- reward_granted
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'ad_views' AND column_name = 'reward_granted'
  ) THEN
    ALTER TABLE public.ad_views ADD COLUMN reward_granted BOOLEAN DEFAULT FALSE;
  END IF;

  -- updated_at
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'ad_views' AND column_name = 'updated_at'
  ) THEN
    ALTER TABLE public.ad_views ADD COLUMN updated_at TIMESTAMPTZ DEFAULT NOW();
  END IF;
END $$;

-- Create gacha_attempts table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.gacha_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  base_attempts INTEGER NOT NULL DEFAULT 10,
  bonus_attempts INTEGER NOT NULL DEFAULT 0,
  used_attempts INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, date)
);

-- Add new columns to gacha_attempts
DO $$ 
BEGIN
  -- date_key
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'gacha_attempts' AND column_name = 'date_key'
  ) THEN
    ALTER TABLE public.gacha_attempts ADD COLUMN date_key DATE;
  END IF;

  -- source
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'gacha_attempts' AND column_name = 'source'
  ) THEN
    ALTER TABLE public.gacha_attempts ADD COLUMN source TEXT DEFAULT 'daily';
  END IF;
END $$;

-- Create gacha_history table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.gacha_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  gacha_result JSONB NOT NULL,
  attempts_used INTEGER NOT NULL DEFAULT 1,
  source TEXT NOT NULL DEFAULT 'normal',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add new columns to gacha_history
DO $$ 
BEGIN
  -- reward_points
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'gacha_history' AND column_name = 'reward_points'
  ) THEN
    ALTER TABLE public.gacha_history ADD COLUMN reward_points INTEGER DEFAULT 0;
  END IF;

  -- reward_silver_ticket
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' AND table_name = 'gacha_history' AND column_name = 'reward_silver_ticket'
  ) THEN
    ALTER TABLE public.gacha_history ADD COLUMN reward_silver_ticket BOOLEAN DEFAULT FALSE;
  END IF;
END $$;

-- ============================================================================
-- 3. Indexes
-- ============================================================================

-- Indexes for ad_views
CREATE INDEX IF NOT EXISTS idx_ad_views_user_id_date_key ON public.ad_views(user_id, date_key);
CREATE INDEX IF NOT EXISTS idx_ad_views_device_id_date_key ON public.ad_views(device_id, date_key);
CREATE INDEX IF NOT EXISTS idx_ad_views_status ON public.ad_views(status);
CREATE INDEX IF NOT EXISTS idx_ad_views_reward_granted ON public.ad_views(reward_granted);
CREATE INDEX IF NOT EXISTS idx_ad_views_created_at ON public.ad_views(created_at);

-- Indexes for gacha_attempts
CREATE INDEX IF NOT EXISTS idx_gacha_attempts_user_id ON public.gacha_attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_gacha_attempts_user_date ON public.gacha_attempts(user_id, date);
CREATE INDEX IF NOT EXISTS idx_gacha_attempts_date_key ON public.gacha_attempts(date_key);

-- Indexes for gacha_history
CREATE INDEX IF NOT EXISTS idx_gacha_history_user_id ON public.gacha_history(user_id);
CREATE INDEX IF NOT EXISTS idx_gacha_history_created_at ON public.gacha_history(created_at);
CREATE INDEX IF NOT EXISTS idx_gacha_history_source ON public.gacha_history(source);

-- ============================================================================
-- 4. RLS Policies
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE public.ad_views ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gacha_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gacha_history ENABLE ROW LEVEL SECURITY;

-- ad_views policies
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'ad_views' AND policyname = 'Users can view their own ad views'
  ) THEN
    CREATE POLICY "Users can view their own ad views" ON public.ad_views
      FOR SELECT USING (auth.uid() = user_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'ad_views' AND policyname = 'Users can insert their own ad views'
  ) THEN
    CREATE POLICY "Users can insert their own ad views" ON public.ad_views
      FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

-- gacha_attempts policies (should already exist, but ensure they're there)
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'gacha_attempts' AND policyname = 'Users can view their own gacha attempts'
  ) THEN
    CREATE POLICY "Users can view their own gacha attempts" ON public.gacha_attempts
      FOR SELECT USING (auth.uid() = user_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'gacha_attempts' AND policyname = 'Users can insert their own gacha attempts'
  ) THEN
    CREATE POLICY "Users can insert their own gacha attempts" ON public.gacha_attempts
      FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'gacha_attempts' AND policyname = 'Users can update their own gacha attempts'
  ) THEN
    CREATE POLICY "Users can update their own gacha attempts" ON public.gacha_attempts
      FOR UPDATE USING (auth.uid() = user_id);
  END IF;
END $$;

-- gacha_history policies
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'gacha_history' AND policyname = 'Users can view their own gacha history'
  ) THEN
    CREATE POLICY "Users can view their own gacha history" ON public.gacha_history
      FOR SELECT USING (auth.uid() = user_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'gacha_history' AND policyname = 'Users can insert their own gacha history'
  ) THEN
    CREATE POLICY "Users can insert their own gacha history" ON public.gacha_history
      FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

-- ============================================================================
-- 5. RPC Functions
-- ============================================================================

-- Function: complete_ad_view_and_grant_ticket
-- Purpose: Record ad view completion and grant gacha ticket if daily limit not exceeded
-- Returns: {granted: boolean, remaining_today: int, total_balance: int, ad_view_id: uuid}
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
DECLARE
  v_date_key DATE;
  v_granted_count INTEGER;
  v_ad_view_id UUID;
  v_gacha_attempts_id UUID;
  v_new_bonus_attempts INTEGER;
  v_total_balance INTEGER;
  v_remaining INTEGER;
  v_daily_limit INTEGER := 3;
BEGIN
  -- Verify user is authenticated
  IF auth.uid() IS NULL OR auth.uid() != p_user_id THEN
    RAISE EXCEPTION 'Unauthorized: User must be authenticated';
  END IF;

  -- Calculate date key (JST 3:00 baseline)
  v_date_key := public.date_key_jst3(NOW());

  -- Count today's granted rewards
  SELECT COUNT(*) INTO v_granted_count
  FROM public.ad_views
  WHERE user_id = p_user_id
    AND date_key = v_date_key
    AND reward_granted = TRUE
    AND status = 'success';

  -- Check if daily limit exceeded
  IF v_granted_count >= v_daily_limit THEN
    -- Record ad view as revoked (over limit)
    IF p_ad_view_id IS NOT NULL THEN
      UPDATE public.ad_views
      SET status = 'revoked',
          error_reason = 'Daily limit exceeded (max 3 rewards per day)',
          date_key = v_date_key,
          device_id = p_device_id,
          user_agent = p_user_agent,
          client_ip = p_client_ip,
          updated_at = NOW()
      WHERE id = p_ad_view_id;
    ELSE
      INSERT INTO public.ad_views (
        user_id, device_id, user_agent, client_ip, ad_type, ad_provider,
        status, error_reason, date_key, reward_granted, viewed_at
      ) VALUES (
        p_user_id, p_device_id, p_user_agent, p_client_ip, p_ad_type, p_ad_provider,
        'revoked', 'Daily limit exceeded (max 3 rewards per day)', v_date_key, FALSE, NOW()
      )
      RETURNING id INTO v_ad_view_id;
    END IF;

    -- Get current balance
    SELECT COALESCE(base_attempts + bonus_attempts - used_attempts, 0) INTO v_total_balance
    FROM public.gacha_attempts
    WHERE user_id = p_user_id AND date = CURRENT_DATE;

    RETURN jsonb_build_object(
      'granted', FALSE,
      'remaining_today', 0,
      'total_balance', COALESCE(v_total_balance, 0),
      'ad_view_id', COALESCE(v_ad_view_id, p_ad_view_id),
      'error', 'Daily limit exceeded (max 3 rewards per day)'
    );
  END IF;

  -- Record successful ad view
  IF p_ad_view_id IS NOT NULL THEN
    UPDATE public.ad_views
    SET status = 'success',
        reward_granted = TRUE,
        date_key = v_date_key,
        device_id = p_device_id,
        user_agent = p_user_agent,
        client_ip = p_client_ip,
        completed = TRUE,
        reward_attempts = 1,
        updated_at = NOW()
    WHERE id = p_ad_view_id
    RETURNING id INTO v_ad_view_id;
  ELSE
    INSERT INTO public.ad_views (
      user_id, device_id, user_agent, client_ip, ad_type, ad_provider,
      status, date_key, reward_granted, completed, reward_attempts, viewed_at
    ) VALUES (
      p_user_id, p_device_id, p_user_agent, p_client_ip, p_ad_type, p_ad_provider,
      'success', v_date_key, TRUE, TRUE, 1, NOW()
    )
    RETURNING id INTO v_ad_view_id;
  END IF;

  -- Ensure gacha_attempts record exists for today
  INSERT INTO public.gacha_attempts (user_id, date, base_attempts, bonus_attempts, used_attempts, date_key)
  VALUES (p_user_id, CURRENT_DATE, 10, 0, 0, v_date_key)
  ON CONFLICT (user_id, date) DO NOTHING;

  -- Grant 1 bonus attempt (atomically)
  UPDATE public.gacha_attempts
  SET bonus_attempts = LEAST(bonus_attempts + 1, v_daily_limit),
      updated_at = NOW()
  WHERE user_id = p_user_id AND date = CURRENT_DATE
  RETURNING id, bonus_attempts, base_attempts + bonus_attempts - used_attempts 
  INTO v_gacha_attempts_id, v_new_bonus_attempts, v_total_balance;

  -- Calculate remaining ad rewards for today
  v_remaining := v_daily_limit - (v_granted_count + 1);

  RETURN jsonb_build_object(
    'granted', TRUE,
    'remaining_today', v_remaining,
    'total_balance', v_total_balance,
    'ad_view_id', v_ad_view_id,
    'bonus_attempts', v_new_bonus_attempts
  );
END;
$$;

-- Function: consume_gacha_attempts
-- Purpose: Consume gacha attempts and record the result in history
-- Returns: {new_balance: int, history_id: uuid}
CREATE OR REPLACE FUNCTION public.consume_gacha_attempts(
  p_user_id UUID,
  p_consume_count INTEGER DEFAULT 1,
  p_source TEXT DEFAULT 'normal',
  p_reward_points INTEGER DEFAULT 0,
  p_reward_silver_ticket BOOLEAN DEFAULT FALSE,
  p_gacha_result JSONB DEFAULT '{}'::jsonb
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_current_balance INTEGER;
  v_new_balance INTEGER;
  v_history_id UUID;
  v_date_key DATE;
BEGIN
  -- Verify user is authenticated
  IF auth.uid() IS NULL OR auth.uid() != p_user_id THEN
    RAISE EXCEPTION 'Unauthorized: User must be authenticated';
  END IF;

  -- Calculate date key
  v_date_key := public.date_key_jst3(NOW());

  -- Ensure gacha_attempts record exists
  INSERT INTO public.gacha_attempts (user_id, date, base_attempts, bonus_attempts, used_attempts, date_key)
  VALUES (p_user_id, CURRENT_DATE, 10, 0, 0, v_date_key)
  ON CONFLICT (user_id, date) DO NOTHING;

  -- Get current balance
  SELECT base_attempts + bonus_attempts - used_attempts INTO v_current_balance
  FROM public.gacha_attempts
  WHERE user_id = p_user_id AND date = CURRENT_DATE;

  -- Check if sufficient balance
  IF v_current_balance < p_consume_count THEN
    RAISE EXCEPTION 'Insufficient gacha attempts (available: %, requested: %)', v_current_balance, p_consume_count;
  END IF;

  -- Consume attempts
  UPDATE public.gacha_attempts
  SET used_attempts = used_attempts + p_consume_count,
      updated_at = NOW()
  WHERE user_id = p_user_id AND date = CURRENT_DATE
  RETURNING base_attempts + bonus_attempts - used_attempts INTO v_new_balance;

  -- Record in history
  INSERT INTO public.gacha_history (
    user_id, gacha_result, attempts_used, source, reward_points, reward_silver_ticket
  ) VALUES (
    p_user_id, p_gacha_result, p_consume_count, p_source, p_reward_points, p_reward_silver_ticket
  )
  RETURNING id INTO v_history_id;

  -- If points were rewarded, update s_points
  IF p_reward_points > 0 THEN
    -- Ensure s_points record exists
    INSERT INTO public.s_points (user_id, balance, total_earned)
    VALUES (p_user_id, 0, 0)
    ON CONFLICT (user_id) DO NOTHING;

    -- Add points
    UPDATE public.s_points
    SET balance = balance + p_reward_points,
        total_earned = total_earned + p_reward_points,
        updated_at = NOW()
    WHERE user_id = p_user_id;

    -- Record transaction
    INSERT INTO public.s_point_transactions (
      user_id, type, amount, source, source_type, description, metadata
    ) VALUES (
      p_user_id, 'earned', p_reward_points, 'gacha_reward', 'gacha', 
      'Points earned from gacha', 
      jsonb_build_object('history_id', v_history_id, 'source', p_source)
    );
  END IF;

  RETURN jsonb_build_object(
    'new_balance', v_new_balance,
    'history_id', v_history_id,
    'points_awarded', p_reward_points,
    'silver_ticket_awarded', p_reward_silver_ticket
  );
END;
$$;

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION public.complete_ad_view_and_grant_ticket TO authenticated;
GRANT EXECUTE ON FUNCTION public.consume_gacha_attempts TO authenticated;
GRANT EXECUTE ON FUNCTION public.date_key_jst3 TO authenticated;

-- ============================================================================
-- 6. Triggers for updated_at
-- ============================================================================

-- Trigger for ad_views
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger 
    WHERE tgname = 'update_ad_views_updated_at'
  ) THEN
    CREATE TRIGGER update_ad_views_updated_at
      BEFORE UPDATE ON public.ad_views
      FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
  END IF;
END $$;

-- Trigger for gacha_attempts
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger 
    WHERE tgname = 'update_gacha_attempts_updated_at'
  ) THEN
    CREATE TRIGGER update_gacha_attempts_updated_at
      BEFORE UPDATE ON public.gacha_attempts
      FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
  END IF;
END $$;

-- ============================================================================
-- 7. Backfill existing data
-- ============================================================================

-- Update existing ad_views with date_key if they have viewed_at
UPDATE public.ad_views 
SET date_key = public.date_key_jst3(viewed_at)
WHERE date_key IS NULL AND viewed_at IS NOT NULL;

-- Update existing gacha_attempts with date_key if they have date
UPDATE public.gacha_attempts
SET date_key = public.date_key_jst3(date::timestamptz)
WHERE date_key IS NULL;

-- ============================================================================
-- Comments for documentation
-- ============================================================================

COMMENT ON FUNCTION public.date_key_jst3 IS 
  'Returns date key based on JST (UTC+9) with 3:00 AM as day boundary';

COMMENT ON FUNCTION public.complete_ad_view_and_grant_ticket IS 
  'Complete ad view and grant gacha ticket if daily limit (3/day) not exceeded';

COMMENT ON FUNCTION public.consume_gacha_attempts IS 
  'Consume gacha attempts and record result in history with point rewards';

COMMENT ON COLUMN public.ad_views.date_key IS 
  'Date key for JST 3:00-based daily partitioning';

COMMENT ON COLUMN public.ad_views.device_id IS 
  'Device identifier for Lv2-Lite analytics';

COMMENT ON COLUMN public.ad_views.reward_granted IS 
  'Whether gacha ticket was actually granted (false if over daily limit)';
