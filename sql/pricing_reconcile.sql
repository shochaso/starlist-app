-- Stripe金額（最新イベント）と subscriptions.plan_price の不一致検出
-- Usage: supabase db query < sql/pricing_reconcile.sql

-- 注: 実際のテーブル構造に合わせて調整が必要
-- ここでは subscriptions テーブルを想定

WITH latest_stripe_events AS (
  SELECT
    customer_id,
    subscription_id,
    MAX(created_at) AS last_event_at
  FROM public.stripe_events
  WHERE event_type IN ('checkout.session.completed', 'payment_intent.succeeded')
    AND customer_id IS NOT NULL
  GROUP BY customer_id, subscription_id
),
joined AS (
  SELECT 
    s.subscription_id,
    s.user_id,
    s.plan_price::int AS db_price,
    se.amount_total / 100 AS stripe_price_jpy,
    se.currency,
    se.created_at AS stripe_event_at
  FROM public.subscriptions s
  JOIN latest_stripe_events lse ON s.subscription_id = lse.subscription_id
  JOIN public.stripe_events se ON se.subscription_id = s.subscription_id 
    AND se.created_at = lse.last_event_at
  WHERE s.plan_price IS NOT NULL
)
SELECT 
  subscription_id,
  user_id,
  db_price,
  stripe_price_jpy,
  currency,
  stripe_event_at,
  CASE 
    WHEN currency <> 'jpy' THEN 'currency_mismatch'
    WHEN db_price <> stripe_price_jpy THEN 'amount_mismatch'
    ELSE 'ok'
  END AS reconciliation_status
FROM joined
WHERE currency <> 'jpy' OR db_price <> stripe_price_jpy;


-- Usage: supabase db query < sql/pricing_reconcile.sql

-- 注: 実際のテーブル構造に合わせて調整が必要
-- ここでは subscriptions テーブルを想定

WITH latest_stripe_events AS (
  SELECT
    customer_id,
    subscription_id,
    MAX(created_at) AS last_event_at
  FROM public.stripe_events
  WHERE event_type IN ('checkout.session.completed', 'payment_intent.succeeded')
    AND customer_id IS NOT NULL
  GROUP BY customer_id, subscription_id
),
joined AS (
  SELECT 
    s.subscription_id,
    s.user_id,
    s.plan_price::int AS db_price,
    se.amount_total / 100 AS stripe_price_jpy,
    se.currency,
    se.created_at AS stripe_event_at
  FROM public.subscriptions s
  JOIN latest_stripe_events lse ON s.subscription_id = lse.subscription_id
  JOIN public.stripe_events se ON se.subscription_id = s.subscription_id 
    AND se.created_at = lse.last_event_at
  WHERE s.plan_price IS NOT NULL
)
SELECT 
  subscription_id,
  user_id,
  db_price,
  stripe_price_jpy,
  currency,
  stripe_event_at,
  CASE 
    WHEN currency <> 'jpy' THEN 'currency_mismatch'
    WHEN db_price <> stripe_price_jpy THEN 'amount_mismatch'
    ELSE 'ok'
  END AS reconciliation_status
FROM joined
WHERE currency <> 'jpy' OR db_price <> stripe_price_jpy;


