#!/bin/bash
# Stripe Webhook 実地検証スクリプト
# Usage: ./PRICING_WEBHOOK_VALIDATION.sh

set -euo pipefail

echo "=== Stripe Webhook 実地検証 ==="
echo ""

# 1) Secrets 最終確認
echo "📋 1) Secrets 最終確認（Supabase Functions）"
echo ""
echo "以下のSecretsが設定されていることを確認してください:"
echo "  - STRIPE_API_KEY"
echo "  - STRIPE_WEBHOOK_SECRET"
echo "  - SUPABASE_URL"
echo "  - SUPABASE_SERVICE_ROLE_KEY"
echo ""
read -p "Secretsが設定済みですか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo ""
  echo "Secrets設定コマンド（参考）:"
  echo "  supabase functions secrets set \\"
  echo "    STRIPE_API_KEY=\"<sk_live_or_test_...>\" \\"
  echo "    STRIPE_WEBHOOK_SECRET=\"<whsec_...>\" \\"
  echo "    SUPABASE_URL=\"https://<project-ref>.supabase.co\" \\"
  echo "    SUPABASE_SERVICE_ROLE_KEY=\"<supabase_service_role_key>\""
  exit 1
fi
echo ""

# 2) デプロイ確認
echo "📋 2) Edge Function デプロイ確認"
echo ""
read -p "stripe-webhook Edge Functionをデプロイしましたか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo ""
  echo "デプロイコマンド:"
  echo "  supabase functions deploy stripe-webhook"
  echo ""
  read -p "今すぐデプロイしますか？ (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    supabase functions deploy stripe-webhook
  else
    echo "⚠️  デプロイをスキップしました。後で実行してください。"
    exit 1
  fi
fi
echo ""

# 3) Stripe CLI テスト（オプション）
echo "📋 3) Stripe CLI テスト（オプション）"
echo ""
if command -v stripe >/dev/null 2>&1; then
  echo "✅ Stripe CLI がインストールされています"
  echo ""
  read -p "Stripe CLIでテストイベントを発火しますか？ (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Stripe CLI フォワードを開始します..."
    echo "別ターミナルで以下を実行してください:"
    echo ""
    echo "  stripe listen --forward-to \"https://<project-ref>.supabase.co/functions/v1/stripe-webhook\""
    echo ""
    read -p "フォワードが開始されましたか？ (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo ""
      echo "代表イベントを順に発火します..."
      echo ""
      echo "1. checkout.session.completed"
      stripe trigger checkout.session.completed
      sleep 2
      
      echo ""
      echo "2. customer.subscription.created"
      stripe trigger customer.subscription.created
      sleep 2
      
      echo ""
      echo "3. customer.subscription.updated"
      stripe trigger customer.subscription.updated
      sleep 2
      
      echo ""
      echo "4. invoice.payment_succeeded"
      stripe trigger invoice.payment_succeeded
      sleep 2
      
      echo ""
      echo "5. charge.refunded"
      stripe trigger charge.refunded
      
      echo ""
      echo "✅ Stripe CLI テスト完了"
    fi
  fi
else
  echo "⚠️  Stripe CLI がインストールされていません"
  echo ""
  echo "インストール方法:"
  echo "  brew install stripe/stripe-cli/stripe"
  echo ""
  echo "または、Stripe Dashboard → Webhooks から手動でテストイベントを送信してください"
fi
echo ""

# 4) DB 反映の確認
echo "📋 4) DB 反映の確認（plan_price / currency）"
echo ""
echo "Supabase Dashboard → SQL Editor で以下を実行してください:"
echo ""
cat <<'SQL'
-- 直近で更新されたサブスク（例）
select subscription_id, plan_price, currency, updated_at
from public.subscriptions
order by updated_at desc
limit 5;
SQL
echo ""
read -p "DB反映を確認しましたか？ plan_priceが整数の円として保存されていますか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "⚠️  DB反映を確認してください。金額単位のズレが疑われる場合は、"
  echo "   Stripeダッシュボードで amount_total / unit_amount の基数を照合してください。"
fi
echo ""

echo "=== Stripe Webhook 実地検証完了 ==="
echo ""
echo "✅ 確認ポイント:"
echo "  [ ] Secrets設定完了"
echo "  [ ] Edge Functionデプロイ完了"
echo "  [ ] Stripe CLIテスト（または手動テスト）完了"
echo "  [ ] DB反映確認（plan_priceが整数の円）"
echo ""


# Stripe Webhook 実地検証スクリプト
# Usage: ./PRICING_WEBHOOK_VALIDATION.sh

set -euo pipefail

echo "=== Stripe Webhook 実地検証 ==="
echo ""

# 1) Secrets 最終確認
echo "📋 1) Secrets 最終確認（Supabase Functions）"
echo ""
echo "以下のSecretsが設定されていることを確認してください:"
echo "  - STRIPE_API_KEY"
echo "  - STRIPE_WEBHOOK_SECRET"
echo "  - SUPABASE_URL"
echo "  - SUPABASE_SERVICE_ROLE_KEY"
echo ""
read -p "Secretsが設定済みですか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo ""
  echo "Secrets設定コマンド（参考）:"
  echo "  supabase functions secrets set \\"
  echo "    STRIPE_API_KEY=\"<sk_live_or_test_...>\" \\"
  echo "    STRIPE_WEBHOOK_SECRET=\"<whsec_...>\" \\"
  echo "    SUPABASE_URL=\"https://<project-ref>.supabase.co\" \\"
  echo "    SUPABASE_SERVICE_ROLE_KEY=\"<supabase_service_role_key>\""
  exit 1
fi
echo ""

# 2) デプロイ確認
echo "📋 2) Edge Function デプロイ確認"
echo ""
read -p "stripe-webhook Edge Functionをデプロイしましたか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo ""
  echo "デプロイコマンド:"
  echo "  supabase functions deploy stripe-webhook"
  echo ""
  read -p "今すぐデプロイしますか？ (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    supabase functions deploy stripe-webhook
  else
    echo "⚠️  デプロイをスキップしました。後で実行してください。"
    exit 1
  fi
fi
echo ""

# 3) Stripe CLI テスト（オプション）
echo "📋 3) Stripe CLI テスト（オプション）"
echo ""
if command -v stripe >/dev/null 2>&1; then
  echo "✅ Stripe CLI がインストールされています"
  echo ""
  read -p "Stripe CLIでテストイベントを発火しますか？ (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Stripe CLI フォワードを開始します..."
    echo "別ターミナルで以下を実行してください:"
    echo ""
    echo "  stripe listen --forward-to \"https://<project-ref>.supabase.co/functions/v1/stripe-webhook\""
    echo ""
    read -p "フォワードが開始されましたか？ (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo ""
      echo "代表イベントを順に発火します..."
      echo ""
      echo "1. checkout.session.completed"
      stripe trigger checkout.session.completed
      sleep 2
      
      echo ""
      echo "2. customer.subscription.created"
      stripe trigger customer.subscription.created
      sleep 2
      
      echo ""
      echo "3. customer.subscription.updated"
      stripe trigger customer.subscription.updated
      sleep 2
      
      echo ""
      echo "4. invoice.payment_succeeded"
      stripe trigger invoice.payment_succeeded
      sleep 2
      
      echo ""
      echo "5. charge.refunded"
      stripe trigger charge.refunded
      
      echo ""
      echo "✅ Stripe CLI テスト完了"
    fi
  fi
else
  echo "⚠️  Stripe CLI がインストールされていません"
  echo ""
  echo "インストール方法:"
  echo "  brew install stripe/stripe-cli/stripe"
  echo ""
  echo "または、Stripe Dashboard → Webhooks から手動でテストイベントを送信してください"
fi
echo ""

# 4) DB 反映の確認
echo "📋 4) DB 反映の確認（plan_price / currency）"
echo ""
echo "Supabase Dashboard → SQL Editor で以下を実行してください:"
echo ""
cat <<'SQL'
-- 直近で更新されたサブスク（例）
select subscription_id, plan_price, currency, updated_at
from public.subscriptions
order by updated_at desc
limit 5;
SQL
echo ""
read -p "DB反映を確認しましたか？ plan_priceが整数の円として保存されていますか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "⚠️  DB反映を確認してください。金額単位のズレが疑われる場合は、"
  echo "   Stripeダッシュボードで amount_total / unit_amount の基数を照合してください。"
fi
echo ""

echo "=== Stripe Webhook 実地検証完了 ==="
echo ""
echo "✅ 確認ポイント:"
echo "  [ ] Secrets設定完了"
echo "  [ ] Edge Functionデプロイ完了"
echo "  [ ] Stripe CLIテスト（または手動テスト）完了"
echo "  [ ] DB反映確認（plan_priceが整数の円）"
echo ""


