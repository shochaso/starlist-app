-- Status:: in-progress
-- Source-of-Truth:: supabase/migrations/20251117_update_pricing_ranges.sql
-- Spec-State:: 確定済み（価格仕様 v1 MVP 反映）
-- Last-Updated:: 2025-11-17

-- 1. 推奨価格設定 JSON を最新版へ更新
UPDATE public.app_settings
SET value = jsonb_build_object(
  'version', '2025-11-17',
  'tiers', jsonb_build_object(
    'light', jsonb_build_object('student', 100, 'adult', 980),
    'standard', jsonb_build_object('student', 200, 'adult', 1980),
    'premium', jsonb_build_object('student', 500, 'adult', 2980)
  ),
  'limits', jsonb_build_object(
    'student', jsonb_build_object('min', 100, 'max', 1000),
    'adult', jsonb_build_object('min', 980, 'max', 100000),
    'step', 10,
    'currency', 'JPY',
    'tax_inclusive', true
  )
)
WHERE key = 'pricing.recommendations';

-- 2. subscription_plans にプラン別価格レンジ制約を追加

ALTER TABLE public.subscription_plans
  ADD CONSTRAINT subscription_plans_price_range_check CHECK (
    CASE lower(name)
      WHEN 'light' THEN price BETWEEN 980 AND 30000
      WHEN 'standard' THEN price BETWEEN 1980 AND 50000
      WHEN 'premium' THEN price BETWEEN 2980 AND 100000
      ELSE TRUE
    END
  );

-- 3. Super Chat 系の上限拡張

-- 3-1. 既存データを MVP レンジ内に丸める（min は 100 円以上、max は 10 万円以下）
UPDATE public.super_chat_pricing
SET min_amount = GREATEST(min_amount, 100);
UPDATE public.super_chat_pricing
SET max_amount = LEAST(GREATEST(max_amount, min_amount), 100000);

-- 3-2. デフォルト / 制約を見直し
ALTER TABLE public.super_chat_pricing
  ALTER COLUMN max_amount SET DEFAULT 100000;

ALTER TABLE public.super_chat_pricing
  ADD CONSTRAINT super_chat_pricing_amount_limit CHECK (
    min_amount >= 100 AND
    max_amount <= 100000 AND
    max_amount >= min_amount
  );

-- 3-3. Super Chat 記録メッセージにもハードレンジを追加（既存データを丸める）
UPDATE public.super_chat_messages
SET amount = 100 WHERE amount < 100;
UPDATE public.super_chat_messages
SET amount = 100000 WHERE amount > 100000;

ALTER TABLE public.super_chat_messages
  ADD CONSTRAINT super_chat_messages_amount_range_check CHECK (
    amount BETWEEN 100 AND 100000
  );

-- 4. 既存 rows への注記
COMMENT ON TABLE public.super_chat_pricing IS
  'MVP 価格仕様 v1 により min_amount >= 100, max_amount <= 100000, tier thresholds はアプリ側で定義';

COMMENT ON TABLE public.subscription_plans IS
  '価格チェックは plan 名に応じた MVP レンジ（Light/Standard/Premium） をカバー';






