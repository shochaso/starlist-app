#!/bin/bash
# 推奨価格機能 最終実務ショートカット（一気通貫実行）
# Usage: ./PRICING_FINAL_SHORTCUT.sh

set -euo pipefail

echo "=== 推奨価格機能 最終実務ショートカット ==="
echo ""

# 0) 前提（環境変数確認）
echo "📋 0) 前提（環境変数確認）"
if [ -z "${SUPABASE_URL:-}" ]; then
  echo "❌ SUPABASE_URL が設定されていません"
  echo ""
  echo "設定してください:"
  echo "  export SUPABASE_URL='https://<project-ref>.supabase.co'"
  exit 1
fi

if [ -z "${SUPABASE_ANON_KEY:-}" ]; then
  echo "❌ SUPABASE_ANON_KEY が設定されていません"
  echo ""
  echo "設定してください:"
  echo "  export SUPABASE_ANON_KEY='<anon-key>'"
  exit 1
fi

echo "✅ SUPABASE_URL: ${SUPABASE_URL}"
echo "✅ SUPABASE_ANON_KEY: ${SUPABASE_ANON_KEY:0:20}..."
echo ""

# 1) Webhook 実地検証
echo "📋 1) Webhook 実地検証（Secrets/Deploy/DB反映）"
if [ -f ./PRICING_WEBHOOK_VALIDATION.sh ]; then
  chmod +x ./PRICING_WEBHOOK_VALIDATION.sh
  ./PRICING_WEBHOOK_VALIDATION.sh || {
    echo "❌ Webhook実地検証が失敗しました"
    exit 1
  }
else
  echo "⚠️  PRICING_WEBHOOK_VALIDATION.sh が見つかりません"
  echo "   手動でWebhook検証を実行してください"
fi
echo ""

# 2) Flutter 統合確認
echo "📋 2) Flutter 統合確認（ドキュメント手順に沿って画面を確認）"
echo ""
echo "PRICING_FLUTTER_INTEGRATION.md を参照して、以下を確認してください:"
echo ""
echo "  [ ] Provider取得 → 画面結線"
echo "  [ ] 推奨バッジ表示"
echo "  [ ] 刻み・上下限バリデーションが即時に効く"
echo "  [ ] 不正値はCTA無効"
echo ""
read -p "Flutter統合確認を完了しましたか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "⚠️  Flutter統合確認を完了してください"
  echo "   PRICING_FLUTTER_INTEGRATION.md を参照してください"
fi
echo ""

# 3) 受け入れテスト
echo "📋 3) 受け入れテスト（ユニット + E2E チェックリスト）"
if [ -f ./PRICING_ACCEPTANCE_TEST.sh ]; then
  chmod +x ./PRICING_ACCEPTANCE_TEST.sh
  ./PRICING_ACCEPTANCE_TEST.sh || {
    echo "❌ 受け入れテストが失敗しました"
    exit 1
  }
else
  echo "⚠️  PRICING_ACCEPTANCE_TEST.sh が見つかりません"
  echo "   手動で受け入れテストを実行してください"
fi
echo ""

# 4) 成功トレイル確認（必ず満たす3+1）
echo "📋 4) 成功トレイル確認（必ず満たす3+1）"
echo ""
echo "以下の4点をすべて満たしていることを確認してください:"
echo ""
echo "  1. UI：推奨バッジ表示／刻み・上下限バリデーションが即時に効く（不正値はCTA無効）"
echo "  2. Checkout→DB：成功後 subscriptions.plan_price が整数の円で保存"
echo "  3. Webhook：checkout.* / subscription.* / invoice.* がトリガーされ、plan_price更新が反映"
echo "  4. ログ：Supabase Functions 200、例外なし／再送痕跡なし（必要に応じ監査記録もOK）"
echo ""
read -p "すべての条件を満たしていますか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo ""
  echo "❌ 成功トレイルを満たすまで実装を継続してください"
  echo ""
  echo "📖 トラブルシューティング:"
  echo "   PRICING_TROUBLESHOOTING.md を参照してください"
  exit 1
fi
echo ""

# 5) Go/No-Go判定
echo "📋 5) Go/No-Go判定"
echo ""
echo "以下の4条件をすべて満たしていることを確認してください:"
echo ""
echo "  ✅ UI：推奨表示・刻み/上下限ガードOK"
echo "  ✅ DB：plan_price 保存（整数円）OK"
echo "  ✅ Webhook：対象イベントすべて反映OK"
echo "  ✅ Logs：Functions 200、例外・再送なし（必要に応じ監査テーブルに記録）"
echo ""
read -p "Go判定で進めますか？ (y/n) " -n 1 -r
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
  exit 1
fi
echo ""

echo "=== 最終実務ショートカット完了 ==="
echo ""
echo "🎉 推奨価格機能の実地検証～Flutter結線確認～受け入れ判定が完了しました！"
echo ""

