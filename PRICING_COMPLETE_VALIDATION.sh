#!/bin/bash
# 推奨価格機能 完全検証スクリプト（一発実行）
# Usage: ./PRICING_COMPLETE_VALIDATION.sh

set -euo pipefail

echo "=== 推奨価格機能 完全検証 ==="
echo ""

# 1) Webhook実地検証
echo "📋 1) Webhook実地検証"
if [ -f ./PRICING_WEBHOOK_VALIDATION.sh ]; then
  chmod +x ./PRICING_WEBHOOK_VALIDATION.sh
  ./PRICING_WEBHOOK_VALIDATION.sh
else
  echo "⚠️  PRICING_WEBHOOK_VALIDATION.sh が見つかりません"
  echo "   手動でWebhook検証を実行してください"
fi
echo ""

# 2) Flutter統合確認
echo "📋 2) Flutter統合確認"
echo ""
echo "PRICING_FLUTTER_INTEGRATION.md を参照して、以下を確認してください:"
echo ""
echo "  [ ] Provider取得 → 画面結線"
echo "  [ ] 送出前バリデーション（刻み/上下限）"
echo "  [ ] 推奨バッジ表示"
echo "  [ ] リアルタイム検証"
echo "  [ ] 不正値はCTA無効"
echo ""
read -p "Flutter統合確認を完了しましたか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "⚠️  Flutter統合確認を完了してください"
fi
echo ""

# 3) 受け入れテスト
echo "📋 3) 受け入れテスト"
if [ -f ./PRICING_ACCEPTANCE_TEST.sh ]; then
  chmod +x ./PRICING_ACCEPTANCE_TEST.sh
  ./PRICING_ACCEPTANCE_TEST.sh
else
  echo "⚠️  PRICING_ACCEPTANCE_TEST.sh が見つかりません"
  echo "   手動で受け入れテストを実行してください"
fi
echo ""

# 4) Go/No-Go最終判定
echo "📋 4) Go/No-Go最終判定"
echo ""
echo "以下の4条件をすべて満たしていることを確認してください:"
echo ""
echo "  1. UI：推奨表示・刻み/上下限ガードが正常"
echo "  2. Checkout：成功後 plan_price が整数円で保持"
echo "  3. Webhook：checkout.* / subscription.* / invoice.* での価格更新が反映"
echo "  4. ログ：Functions 200／例外・再送痕跡なし"
echo ""
read -p "すべての条件を満たしていますか？ (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo ""
  echo "✅ Go判定：推奨価格機能は実装～検証～運用まで完了です"
  echo ""
  echo "📝 次のステップ:"
  echo "  1. Stripeイベントのログ（type と保存後の subscriptions レコード）を確認"
  echo "  2. 画面スクショを取得"
  echo "  3. 最終レポート（PRICING_FINAL_CHECKLIST.md 反映版）を整形"
else
  echo ""
  echo "❌ No-Go判定：上記の条件を満たすまで実装を継続してください"
  echo ""
  echo "📖 トラブルシューティング:"
  echo "   PRICING_TROUBLESHOOTING.md を参照してください"
fi
echo ""

echo "=== 完全検証完了 ==="
echo ""


# 推奨価格機能 完全検証スクリプト（一発実行）
# Usage: ./PRICING_COMPLETE_VALIDATION.sh

set -euo pipefail

echo "=== 推奨価格機能 完全検証 ==="
echo ""

# 1) Webhook実地検証
echo "📋 1) Webhook実地検証"
if [ -f ./PRICING_WEBHOOK_VALIDATION.sh ]; then
  chmod +x ./PRICING_WEBHOOK_VALIDATION.sh
  ./PRICING_WEBHOOK_VALIDATION.sh
else
  echo "⚠️  PRICING_WEBHOOK_VALIDATION.sh が見つかりません"
  echo "   手動でWebhook検証を実行してください"
fi
echo ""

# 2) Flutter統合確認
echo "📋 2) Flutter統合確認"
echo ""
echo "PRICING_FLUTTER_INTEGRATION.md を参照して、以下を確認してください:"
echo ""
echo "  [ ] Provider取得 → 画面結線"
echo "  [ ] 送出前バリデーション（刻み/上下限）"
echo "  [ ] 推奨バッジ表示"
echo "  [ ] リアルタイム検証"
echo "  [ ] 不正値はCTA無効"
echo ""
read -p "Flutter統合確認を完了しましたか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "⚠️  Flutter統合確認を完了してください"
fi
echo ""

# 3) 受け入れテスト
echo "📋 3) 受け入れテスト"
if [ -f ./PRICING_ACCEPTANCE_TEST.sh ]; then
  chmod +x ./PRICING_ACCEPTANCE_TEST.sh
  ./PRICING_ACCEPTANCE_TEST.sh
else
  echo "⚠️  PRICING_ACCEPTANCE_TEST.sh が見つかりません"
  echo "   手動で受け入れテストを実行してください"
fi
echo ""

# 4) Go/No-Go最終判定
echo "📋 4) Go/No-Go最終判定"
echo ""
echo "以下の4条件をすべて満たしていることを確認してください:"
echo ""
echo "  1. UI：推奨表示・刻み/上下限ガードが正常"
echo "  2. Checkout：成功後 plan_price が整数円で保持"
echo "  3. Webhook：checkout.* / subscription.* / invoice.* での価格更新が反映"
echo "  4. ログ：Functions 200／例外・再送痕跡なし"
echo ""
read -p "すべての条件を満たしていますか？ (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo ""
  echo "✅ Go判定：推奨価格機能は実装～検証～運用まで完了です"
  echo ""
  echo "📝 次のステップ:"
  echo "  1. Stripeイベントのログ（type と保存後の subscriptions レコード）を確認"
  echo "  2. 画面スクショを取得"
  echo "  3. 最終レポート（PRICING_FINAL_CHECKLIST.md 反映版）を整形"
else
  echo ""
  echo "❌ No-Go判定：上記の条件を満たすまで実装を継続してください"
  echo ""
  echo "📖 トラブルシューティング:"
  echo "   PRICING_TROUBLESHOOTING.md を参照してください"
fi
echo ""

echo "=== 完全検証完了 ==="
echo ""


