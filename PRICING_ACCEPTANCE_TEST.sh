#!/bin/bash
# 推奨価格機能 受け入れテスト（最小セット）
# Usage: ./PRICING_ACCEPTANCE_TEST.sh

set -euo pipefail

echo "=== 推奨価格機能 受け入れテスト ==="
echo ""

# 1) ユニットテスト（バリデーション）
echo "📋 1) ユニットテスト（バリデーション）"
echo ""
if command -v flutter >/dev/null 2>&1; then
  echo "🚀 Flutterテストを実行します..."
  flutter test test/src/features/pricing/ || {
    echo "❌ ユニットテストが失敗しました"
    exit 1
  }
  echo "✅ ユニットテスト完了"
else
  echo "⚠️  Flutter がインストールされていません"
  echo "   手動で以下を実行してください:"
  echo "   flutter test test/src/features/pricing/"
fi
echo ""

# 2) E2Eテスト（手動チェックリスト）
echo "📋 2) E2Eテスト（手動チェックリスト）"
echo ""
echo "以下の項目を手動で確認してください:"
echo ""
echo "  [ ] 画面に推奨額（学生/成人）が表示される"
echo "  [ ] 刻み/上下限の即時ガードが効く"
echo "  [ ] Checkout成功 → DB subscriptions.plan_price が整数の円で保存"
echo "  [ ] 推奨設定を更新（Seed再適用）しても、既存購読の plan_price は不変"
echo ""
read -p "E2Eテストを完了しましたか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "⚠️  E2Eテストを完了してください"
fi
echo ""

# 3) ログ/監査確認
echo "📋 3) ログ/監査確認"
echo ""
echo "以下の項目を確認してください:"
echo ""
echo "  [ ] Supabase Functions Logs：Stripeイベント 200、例外なし"
echo "  [ ] （任意）監査テーブルを運用する場合：event_id UNIQUE で冪等担保"
echo ""
read -p "ログ/監査確認を完了しましたか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "⚠️  ログ/監査確認を完了してください"
fi
echo ""

# 4) Go/No-Go判定
echo "📋 4) Go/No-Go判定（最終4条件）"
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
else
  echo ""
  echo "❌ No-Go判定：上記の条件を満たすまで実装を継続してください"
fi
echo ""

echo "=== 受け入れテスト完了 ==="
echo ""
echo "📝 次のステップ:"
echo "  1. Stripeイベントのログ（type と保存後の subscriptions レコード）を確認"
echo "  2. 画面スクショを取得"
echo "  3. 最終レポート（PRICING_FINAL_CHECKLIST.md 反映版）を整形"
echo ""


# 推奨価格機能 受け入れテスト（最小セット）
# Usage: ./PRICING_ACCEPTANCE_TEST.sh

set -euo pipefail

echo "=== 推奨価格機能 受け入れテスト ==="
echo ""

# 1) ユニットテスト（バリデーション）
echo "📋 1) ユニットテスト（バリデーション）"
echo ""
if command -v flutter >/dev/null 2>&1; then
  echo "🚀 Flutterテストを実行します..."
  flutter test test/src/features/pricing/ || {
    echo "❌ ユニットテストが失敗しました"
    exit 1
  }
  echo "✅ ユニットテスト完了"
else
  echo "⚠️  Flutter がインストールされていません"
  echo "   手動で以下を実行してください:"
  echo "   flutter test test/src/features/pricing/"
fi
echo ""

# 2) E2Eテスト（手動チェックリスト）
echo "📋 2) E2Eテスト（手動チェックリスト）"
echo ""
echo "以下の項目を手動で確認してください:"
echo ""
echo "  [ ] 画面に推奨額（学生/成人）が表示される"
echo "  [ ] 刻み/上下限の即時ガードが効く"
echo "  [ ] Checkout成功 → DB subscriptions.plan_price が整数の円で保存"
echo "  [ ] 推奨設定を更新（Seed再適用）しても、既存購読の plan_price は不変"
echo ""
read -p "E2Eテストを完了しましたか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "⚠️  E2Eテストを完了してください"
fi
echo ""

# 3) ログ/監査確認
echo "📋 3) ログ/監査確認"
echo ""
echo "以下の項目を確認してください:"
echo ""
echo "  [ ] Supabase Functions Logs：Stripeイベント 200、例外なし"
echo "  [ ] （任意）監査テーブルを運用する場合：event_id UNIQUE で冪等担保"
echo ""
read -p "ログ/監査確認を完了しましたか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "⚠️  ログ/監査確認を完了してください"
fi
echo ""

# 4) Go/No-Go判定
echo "📋 4) Go/No-Go判定（最終4条件）"
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
else
  echo ""
  echo "❌ No-Go判定：上記の条件を満たすまで実装を継続してください"
fi
echo ""

echo "=== 受け入れテスト完了 ==="
echo ""
echo "📝 次のステップ:"
echo "  1. Stripeイベントのログ（type と保存後の subscriptions レコード）を確認"
echo "  2. 画面スクショを取得"
echo "  3. 最終レポート（PRICING_FINAL_CHECKLIST.md 反映版）を整形"
echo ""


