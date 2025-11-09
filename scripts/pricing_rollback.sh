#!/bin/bash
# Pricing 失敗時ロールバック手順（1コマンド）
# Usage: ./scripts/pricing_rollback.sh [price_id]

set -euo pipefail

PRICE_ID="${1:-}"

if [ -z "$PRICE_ID" ]; then
  echo "❌ Usage: ./scripts/pricing_rollback.sh <stripe_price_id>"
  echo ""
  echo "例: ./scripts/pricing_rollback.sh price_1234567890"
  exit 1
fi

echo "=== Pricing ロールバック ==="
echo ""

# Stripe CLIで最新のPriceを非有効化
if command -v stripe >/dev/null 2>&1; then
  echo "📋 1) Stripe Priceを非有効化"
  stripe prices update "$PRICE_ID" --active=false || {
    echo "❌ Stripe Price無効化に失敗しました"
    exit 1
  }
  echo "✅ Stripe Price無効化完了: $PRICE_ID"
  echo ""
  
  # 直前バージョンに戻す（履歴から取得）
  echo "📋 2) 直前バージョンに戻す"
  echo "⚠️  手動でStripe Dashboardから直前バージョンを有効化してください"
  echo "  または、以下のコマンドで履歴を確認:"
  echo "  stripe prices list --limit 10"
else
  echo "⚠️  Stripe CLI not found. Manual rollback required:"
  echo "  1. Stripe Dashboard → Products → Prices"
  echo "  2. Find price ID: $PRICE_ID"
  echo "  3. Deactivate current price"
  echo "  4. Activate previous version"
fi

echo ""
echo "✅ ロールバック完了（所要時間: 約3分）"
echo "📝 ログ: docs/reports/ROLLBACK_LOG_TEMPLATE.md に記録してください"

# Pricing 失敗時ロールバック手順（1コマンド）
# Usage: ./scripts/pricing_rollback.sh [price_id]

set -euo pipefail

PRICE_ID="${1:-}"

if [ -z "$PRICE_ID" ]; then
  echo "❌ Usage: ./scripts/pricing_rollback.sh <stripe_price_id>"
  echo ""
  echo "例: ./scripts/pricing_rollback.sh price_1234567890"
  exit 1
fi

echo "=== Pricing ロールバック ==="
echo ""

# Stripe CLIで最新のPriceを非有効化
if command -v stripe >/dev/null 2>&1; then
  echo "📋 1) Stripe Priceを非有効化"
  stripe prices update "$PRICE_ID" --active=false || {
    echo "❌ Stripe Price無効化に失敗しました"
    exit 1
  }
  echo "✅ Stripe Price無効化完了: $PRICE_ID"
  echo ""
  
  # 直前バージョンに戻す（履歴から取得）
  echo "📋 2) 直前バージョンに戻す"
  echo "⚠️  手動でStripe Dashboardから直前バージョンを有効化してください"
  echo "  または、以下のコマンドで履歴を確認:"
  echo "  stripe prices list --limit 10"
else
  echo "⚠️  Stripe CLI not found. Manual rollback required:"
  echo "  1. Stripe Dashboard → Products → Prices"
  echo "  2. Find price ID: $PRICE_ID"
  echo "  3. Deactivate current price"
  echo "  4. Activate previous version"
fi

echo ""
echo "✅ ロールバック完了（所要時間: 約3分）"
echo "📝 ログ: docs/reports/ROLLBACK_LOG_TEMPLATE.md に記録してください"

