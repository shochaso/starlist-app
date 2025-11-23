-- Gacha/Ads JST3 daily key and hard cap (Lv1 + Lv2-lite)
-- - Introduces date_key (JST 3:00 reset) to ad_views / gacha_attempts / gacha_history
-- - Adds device_id/user_agent/client_ip/status/error_reason/reward_granted to ad_views
-- - Adds reward_points/reward_silver_ticket to gacha_history
-- - Adds helper function get_jst3_date_key()
-- - Adds RPCs: complete_ad_view_and_grant_ticket, consume_gacha_attempt_atomic

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- JST 3:00 reset date key helper
CREATE OR REPLACE FUNCTION public.get_jst3_date_key(ts timestamptz DEFAULT now())
RETURNS date AS $$
  SELECT (timezone('Asia/Tokyo', ts) - interval '3 hour')::date;
$$ LANGUAGE sql STABLE;

-- ad_views extensions
ALTER TABLE IF EXISTS public.ad_views
  ADD COLUMN IF NOT EXISTS device_id text,
  ADD COLUMN IF NOT EXISTS user_agent text,
  ADD COLUMN IF NOT EXISTS client_ip inet,
  ADD COLUMN IF NOT EXISTS status text DEFAULT 'initiated' CHECK (status IN ('initiated','completed','failed','skipped')),
  ADD COLUMN IF NOT EXISTS error_reason text,
  ADD COLUMN IF NOT EXISTS reward_granted boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS date_key date;

-- Backfill date_key for existing rows
UPDATE public.ad_views SET date_key = public.get_jst3_date_key(viewed_at) WHERE date_key IS NULL;

-- gacha_attempts add date_key (for consistency & indexing)
ALTER TABLE IF EXISTS public.gacha_attempts
  ADD COLUMN IF NOT EXISTS date_key date;
UPDATE public.gacha_attempts SET date_key = public.get_jst3_date_key(created_at) WHERE date_key IS NULL;

-- gacha_history enrichments
ALTER TABLE IF EXISTS public.gacha_history
  ADD COLUMN IF NOT EXISTS reward_points integer,
  ADD COLUMN IF NOT EXISTS reward_silver_ticket boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS date_key date;
UPDATE public.gacha_history SET date_key = public.get_jst3_date_key(created_at) WHERE date_key IS NULL;

-- Indexes for daily caps
CREATE INDEX IF NOT EXISTS idx_ad_views_user_date ON public.ad_views(user_id, date_key);
CREATE INDEX IF NOT EXISTS idx_ad_views_device_date ON public.ad_views(device_id, date_key);
CREATE INDEX IF NOT EXISTS idx_gacha_attempts_user_date ON public.gacha_attempts(user_id, date_key);
CREATE INDEX IF NOT EXISTS idx_gacha_history_user_date ON public.gacha_history(user_id, date_key);

-- Initialize or upsert daily gacha attempts (base=0 by default)
CREATE OR REPLACE FUNCTION public.initialize_daily_gacha_attempts_jst3(user_id_param uuid)
RETURNS void AS $$
DECLARE
  today_key date := public.get_jst3_date_key();
BEGIN
  INSERT INTO public.gacha_attempts (user_id, date, date_key, base_attempts)
  VALUES (user_id_param, today_key, today_key, 0)
  ON CONFLICT (user_id, date) DO NOTHING;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Override: get_available_gacha_attempts to use JST3
CREATE OR REPLACE FUNCTION public.get_available_gacha_attempts(user_id_param uuid)
RETURNS jsonb AS $$
DECLARE
  today_key date := public.get_jst3_date_key();
  rec record;
BEGIN
  PERFORM public.initialize_daily_gacha_attempts_jst3(user_id_param);
  SELECT * INTO rec FROM public.gacha_attempts WHERE user_id = user_id_param AND date = today_key;
  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'base_attempts', 0,
      'bonus_attempts', 0,
      'used_attempts', 0,
      'available_attempts', 0,
      'date', today_key
    );
  END IF;

  RETURN jsonb_build_object(
    'base_attempts', rec.base_attempts,
    'bonus_attempts', rec.bonus_attempts,
    'used_attempts', rec.used_attempts,
    'available_attempts', rec.base_attempts + rec.bonus_attempts - rec.used_attempts,
    'date', rec.date
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Compatibility wrapper: consume_gacha_attempt delegates to atomic version without history payload
CREATE OR REPLACE FUNCTION public.consume_gacha_attempt(user_id_param uuid)
RETURNS jsonb AS $$
BEGIN
  RETURN public.consume_gacha_attempt_atomic(user_id_param, NULL, NULL, false, 'normal');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Complete ad view and (if under cap) grant +1 gacha attempt
CREATE OR REPLACE FUNCTION public.complete_ad_view_and_grant_ticket(
  user_id_param uuid,
  ad_view_id_param uuid,
  device_id_param text DEFAULT NULL,
  user_agent_param text DEFAULT NULL
)
RETURNS jsonb AS $$
DECLARE
  today_key date := public.get_jst3_date_key();
  max_daily integer := 3;
  current_count integer;
  ad_record record;
BEGIN
  -- lock ad view row
  SELECT * INTO ad_record FROM public.ad_views WHERE id = ad_view_id_param FOR UPDATE;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'ad_view_not_found');
  END IF;

  -- idempotent: already completed & granted
  IF ad_record.status = 'completed' AND ad_record.reward_granted THEN
    RETURN jsonb_build_object('success', true, 'granted', false, 'message', 'already_granted');
  END IF;

  -- ensure date_key
  UPDATE public.ad_views
    SET date_key = COALESCE(ad_record.date_key, today_key),
        device_id = COALESCE(ad_record.device_id, device_id_param),
        user_agent = COALESCE(ad_record.user_agent, user_agent_param),
        client_ip = COALESCE(ad_record.client_ip, inet_client_addr())
    WHERE id = ad_view_id_param;

  -- daily count (user based)
  SELECT count(*) INTO current_count
    FROM public.ad_views
    WHERE user_id = user_id_param AND date_key = today_key AND reward_granted = true;

  IF current_count >= max_daily THEN
    UPDATE public.ad_views
      SET status = 'completed', reward_granted = false, error_reason = 'daily_cap_reached', date_key = today_key
      WHERE id = ad_view_id_param;
    RETURN jsonb_build_object('success', false, 'error', 'daily_cap_reached');
  END IF;

  -- increment bonus attempts
  PERFORM public.initialize_daily_gacha_attempts_jst3(user_id_param);

  UPDATE public.gacha_attempts
    SET bonus_attempts = bonus_attempts + 1,
        date = today_key,
        date_key = today_key,
        updated_at = now()
    WHERE user_id = user_id_param AND date = today_key;

  UPDATE public.ad_views
    SET status = 'completed', reward_granted = true, date_key = today_key
    WHERE id = ad_view_id_param;

  RETURN jsonb_build_object('success', true, 'granted', true, 'remaining_today', max_daily - current_count - 1);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Atomic consume gacha attempt and record history
CREATE OR REPLACE FUNCTION public.consume_gacha_attempt_atomic(
  user_id_param uuid,
  gacha_result jsonb DEFAULT NULL,
  reward_points integer DEFAULT NULL,
  reward_silver_ticket boolean DEFAULT false,
  source text DEFAULT 'normal'
)
RETURNS jsonb AS $$
DECLARE
  today_key date := public.get_jst3_date_key();
  attempts_record record;
  available integer;
BEGIN
  PERFORM public.initialize_daily_gacha_attempts_jst3(user_id_param);

  SELECT * INTO attempts_record
    FROM public.gacha_attempts
    WHERE user_id = user_id_param AND date = today_key
    FOR UPDATE;

  available := attempts_record.base_attempts + attempts_record.bonus_attempts - attempts_record.used_attempts;
  IF available <= 0 THEN
    RETURN jsonb_build_object('success', false, 'error', 'no_attempts');
  END IF;

  UPDATE public.gacha_attempts
    SET used_attempts = attempts_record.used_attempts + 1,
        updated_at = now(),
        date_key = today_key,
        date = today_key
    WHERE id = attempts_record.id;

  IF gacha_result IS NOT NULL THEN
    INSERT INTO public.gacha_history (user_id, gacha_result, attempts_used, source, reward_points, reward_silver_ticket, date_key, created_at)
    VALUES (user_id_param, gacha_result, 1, source, reward_points, reward_silver_ticket, today_key, now());
  END IF;

  RETURN jsonb_build_object('success', true, 'remaining', available - 1);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Helper view: count granted today per user/device
CREATE OR REPLACE VIEW public.ad_view_grants_today AS
SELECT user_id, device_id, date_key, count(*) AS grants
FROM public.ad_views
WHERE reward_granted = true AND date_key = public.get_jst3_date_key()
GROUP BY user_id, device_id, date_key;
