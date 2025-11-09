#!/bin/bash
# 推奨価格機能 スポット確認（現場で役立つ一行集）
# Usage: ./PRICING_SPOT_COMMANDS.sh [command]

set -euo pipefail

COMMAND="${1:-all}"

case "$COMMAND" in
  stripe-cli|stripe)
    echo "=== Stripe CLI（本番エンドポイントにフォワードして擬似イベント送出） ==="
    echo ""
    if [ -z "${SUPABASE_URL:-}" ]; then
      echo "❌ SUPABASE_URL が設定されていません"
      exit 1
    fi
    echo "1. Stripe CLI フォワードを開始:"
    echo "   stripe listen --forward-to \"${SUPABASE_URL}/functions/v1/stripe-webhook\""
    echo ""
    echo "2. 代表イベントを順に発火:"
    echo "   stripe trigger checkout.session.completed"
    echo "   stripe trigger customer.subscription.updated"
    echo "   stripe trigger invoice.payment_succeeded"
    echo ""
    ;;
  db-check|db)
    echo "=== DB 反映（直近の金額が入っているか） ==="
    echo ""
    echo "Supabase Dashboard → SQL Editor で以下を実行:"
    echo ""
    cat <<'SQL'
select subscription_id, plan_price, currency, updated_at
from public.subscriptions
order by updated_at desc
limit 5;
SQL
    echo ""
    ;;
  flutter-test|test)
    echo "=== Flutter ユニット（バリデーション） ==="
    echo ""
    if command -v flutter >/dev/null 2>&1; then
      echo "🚀 Flutterテストを実行します..."
      flutter test test/src/features/pricing/ || {
        echo "❌ テストが失敗しました"
        exit 1
      }
      echo "✅ テスト完了"
    else
      echo "⚠️  Flutter がインストールされていません"
      echo "   手動で以下を実行してください:"
      echo "   flutter test test/src/features/pricing/"
    fi
    echo ""
    ;;
  all|*)
    echo "=== 推奨価格機能 スポット確認コマンド集 ==="
    echo ""
    echo "使用方法: ./PRICING_SPOT_COMMANDS.sh [command]"
    echo ""
    echo "利用可能なコマンド:"
    echo "  stripe-cli, stripe  - Stripe CLI テストコマンド表示"
    echo "  db-check, db        - DB反映確認SQL表示"
    echo "  flutter-test, test  - Flutterユニットテスト実行"
    echo "  all                 - すべてのコマンドを表示（デフォルト）"
    echo ""
    echo "---"
    echo ""
    echo "1. Stripe CLI（本番エンドポイントにフォワードして擬似イベント送出）"
    echo ""
    if [ -z "${SUPABASE_URL:-}" ]; then
      echo "⚠️  SUPABASE_URL が設定されていません"
    else
      echo "   stripe listen --forward-to \"${SUPABASE_URL}/functions/v1/stripe-webhook\""
      echo "   stripe trigger checkout.session.completed"
      echo "   stripe trigger customer.subscription.updated"
      echo "   stripe trigger invoice.payment_succeeded"
    fi
    echo ""
    echo "---"
    echo ""
    echo "2. DB 反映（直近の金額が入っているか）"
    echo ""
    echo "Supabase Dashboard → SQL Editor で以下を実行:"
    echo ""
    cat <<'SQL'
select subscription_id, plan_price, currency, updated_at
from public.subscriptions
order by updated_at desc
limit 5;
SQL
    echo ""
    echo "---"
    echo ""
    echo "3. Flutter ユニット（バリデーション）"
    echo ""
    echo "   flutter test test/src/features/pricing/"
    echo ""
    ;;
esac


# 推奨価格機能 スポット確認（現場で役立つ一行集）
# Usage: ./PRICING_SPOT_COMMANDS.sh [command]

set -euo pipefail

COMMAND="${1:-all}"

case "$COMMAND" in
  stripe-cli|stripe)
    echo "=== Stripe CLI（本番エンドポイントにフォワードして擬似イベント送出） ==="
    echo ""
    if [ -z "${SUPABASE_URL:-}" ]; then
      echo "❌ SUPABASE_URL が設定されていません"
      exit 1
    fi
    echo "1. Stripe CLI フォワードを開始:"
    echo "   stripe listen --forward-to \"${SUPABASE_URL}/functions/v1/stripe-webhook\""
    echo ""
    echo "2. 代表イベントを順に発火:"
    echo "   stripe trigger checkout.session.completed"
    echo "   stripe trigger customer.subscription.updated"
    echo "   stripe trigger invoice.payment_succeeded"
    echo ""
    ;;
  db-check|db)
    echo "=== DB 反映（直近の金額が入っているか） ==="
    echo ""
    echo "Supabase Dashboard → SQL Editor で以下を実行:"
    echo ""
    cat <<'SQL'
select subscription_id, plan_price, currency, updated_at
from public.subscriptions
order by updated_at desc
limit 5;
SQL
    echo ""
    ;;
  flutter-test|test)
    echo "=== Flutter ユニット（バリデーション） ==="
    echo ""
    if command -v flutter >/dev/null 2>&1; then
      echo "🚀 Flutterテストを実行します..."
      flutter test test/src/features/pricing/ || {
        echo "❌ テストが失敗しました"
        exit 1
      }
      echo "✅ テスト完了"
    else
      echo "⚠️  Flutter がインストールされていません"
      echo "   手動で以下を実行してください:"
      echo "   flutter test test/src/features/pricing/"
    fi
    echo ""
    ;;
  all|*)
    echo "=== 推奨価格機能 スポット確認コマンド集 ==="
    echo ""
    echo "使用方法: ./PRICING_SPOT_COMMANDS.sh [command]"
    echo ""
    echo "利用可能なコマンド:"
    echo "  stripe-cli, stripe  - Stripe CLI テストコマンド表示"
    echo "  db-check, db        - DB反映確認SQL表示"
    echo "  flutter-test, test  - Flutterユニットテスト実行"
    echo "  all                 - すべてのコマンドを表示（デフォルト）"
    echo ""
    echo "---"
    echo ""
    echo "1. Stripe CLI（本番エンドポイントにフォワードして擬似イベント送出）"
    echo ""
    if [ -z "${SUPABASE_URL:-}" ]; then
      echo "⚠️  SUPABASE_URL が設定されていません"
    else
      echo "   stripe listen --forward-to \"${SUPABASE_URL}/functions/v1/stripe-webhook\""
      echo "   stripe trigger checkout.session.completed"
      echo "   stripe trigger customer.subscription.updated"
      echo "   stripe trigger invoice.payment_succeeded"
    fi
    echo ""
    echo "---"
    echo ""
    echo "2. DB 反映（直近の金額が入っているか）"
    echo ""
    echo "Supabase Dashboard → SQL Editor で以下を実行:"
    echo ""
    cat <<'SQL'
select subscription_id, plan_price, currency, updated_at
from public.subscriptions
order by updated_at desc
limit 5;
SQL
    echo ""
    echo "---"
    echo ""
    echo "3. Flutter ユニット（バリデーション）"
    echo ""
    echo "   flutter test test/src/features/pricing/"
    echo ""
    ;;
esac


