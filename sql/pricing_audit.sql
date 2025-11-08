-- Pricing監査SQL（整数/範囲/重複/参照整合チェック）
-- Usage: supabase db query < sql/pricing_audit.sql

-- 整数性チェック
SELECT COUNT(*) AS non_integer_prices
FROM public.subscriptions
WHERE plan_price IS NOT NULL
  AND (plan_price::text !~ '^[0-9]+$' OR plan_price < 0);

-- 範囲チェック（例：学生100–9999円、成人300–29999円 を想定ルール）
-- 注: 実際のルールは app_settings.pricing.recommendations から取得すべきだが、
--     ここでは簡易的に固定値でチェック
SELECT 
  CASE 
    WHEN plan_price < 100 THEN 'below_min'
    WHEN plan_price > 29999 THEN 'above_max'
    ELSE 'in_range'
  END AS range_status,
  COUNT(*) AS count
FROM public.subscriptions
WHERE plan_price IS NOT NULL
GROUP BY range_status;

-- 重複チェック（同ユーザー×プランの二重購読）
SELECT 
  user_id, 
  plan_id, 
  COUNT(*) AS dup_count
FROM public.subscriptions
WHERE user_id IS NOT NULL AND plan_id IS NOT NULL
GROUP BY user_id, plan_id
HAVING COUNT(*) > 1;

-- Stripe参照整合チェック（subscription_id が存在するのに plan_price が欠落）
SELECT 
  COUNT(*) AS inconsistent_rows
FROM public.subscriptions
WHERE subscription_id IS NOT NULL 
  AND plan_price IS NULL;

-- 通貨チェック（JPY以外の通貨が混在していないか）
SELECT 
  currency,
  COUNT(*) AS count
FROM public.subscriptions
WHERE currency IS NOT NULL
GROUP BY currency;

-- 直近のplan_price保存確認（監査用）
SELECT 
  subscription_id, 
  plan_price, 
  currency, 
  updated_at
FROM public.subscriptions
WHERE plan_price IS NOT NULL
ORDER BY updated_at DESC
LIMIT 10;

