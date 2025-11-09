#!/bin/bash
# Day11 ops-slack-summary dryRun実行コマンド
# Usage: ./DAY11_DRYRUN_COMMANDS.sh

set -euo pipefail

# 環境変数の確認
if [ -z "${SUPABASE_URL:-}" ]; then
  echo "❌ Error: SUPABASE_URL is not set"
  echo "   Set it with: export SUPABASE_URL='https://<project-ref>.supabase.co'"
  exit 1
fi

if [ -z "${SUPABASE_ANON_KEY:-}" ]; then
  echo "❌ Error: SUPABASE_ANON_KEY is not set"
  echo "   Set it with: export SUPABASE_ANON_KEY='<anon-key>'"
  exit 1
fi

# URL正規化
BASE_URL="${SUPABASE_URL%/}"
EDGE_URL="${BASE_URL}/functions/v1/ops-slack-summary"

echo "=== Day11 ops-slack-summary dryRun実行 ==="
echo ""
echo "📋 設定確認:"
echo "  SUPABASE_URL: ${BASE_URL}"
echo "  EDGE_URL: ${EDGE_URL}"
echo ""

# dryRun実行
echo "🚀 dryRun実行中..."
RESPONSE=$(curl -sS --fail --show-error --retry 3 --retry-all-errors --max-time 30 \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -X POST \
  "${EDGE_URL}?dryRun=true&period=14d" \
  -d '{}')

echo ""
echo "✅ レスポンス:"
echo "${RESPONSE}" | jq .

# 検証
echo ""
echo "🔍 検証中..."
if echo "${RESPONSE}" | jq -e '.ok == true and .dryRun == true' > /dev/null; then
  echo "✅ dryRun成功: ok=true, dryRun=true"
else
  echo "❌ dryRun失敗: 期待されるレスポンス形式と異なります"
  exit 1
fi

if echo "${RESPONSE}" | jq -e '.stats.mean_notifications != null' > /dev/null; then
  echo "✅ 統計情報が含まれています"
else
  echo "❌ 統計情報が含まれていません"
  exit 1
fi

if echo "${RESPONSE}" | jq -e '.weekly_summary != null' > /dev/null; then
  echo "✅ 週次サマリが含まれています"
else
  echo "❌ 週次サマリが含まれていません"
  exit 1
fi

if echo "${RESPONSE}" | jq -e '.message != null' > /dev/null; then
  echo "✅ メッセージが含まれています"
  echo ""
  echo "📝 メッセージプレビュー:"
  echo "${RESPONSE}" | jq -r '.message' | head -10
else
  echo "❌ メッセージが含まれていません"
  exit 1
fi

echo ""
echo "✅ すべての検証が成功しました！"
echo ""
echo "📋 次のステップ:"
echo "  1. 本送信テスト: GitHub Actions から dryRun=false で実行"
echo "  2. または、Supabase Dashboard → Edge Functions → ops-slack-summary → Invoke"
echo "  3. Slack #ops-monitor チャンネルで週次サマリを確認"


# Day11 ops-slack-summary dryRun実行コマンド
# Usage: ./DAY11_DRYRUN_COMMANDS.sh

set -euo pipefail

# 環境変数の確認
if [ -z "${SUPABASE_URL:-}" ]; then
  echo "❌ Error: SUPABASE_URL is not set"
  echo "   Set it with: export SUPABASE_URL='https://<project-ref>.supabase.co'"
  exit 1
fi

if [ -z "${SUPABASE_ANON_KEY:-}" ]; then
  echo "❌ Error: SUPABASE_ANON_KEY is not set"
  echo "   Set it with: export SUPABASE_ANON_KEY='<anon-key>'"
  exit 1
fi

# URL正規化
BASE_URL="${SUPABASE_URL%/}"
EDGE_URL="${BASE_URL}/functions/v1/ops-slack-summary"

echo "=== Day11 ops-slack-summary dryRun実行 ==="
echo ""
echo "📋 設定確認:"
echo "  SUPABASE_URL: ${BASE_URL}"
echo "  EDGE_URL: ${EDGE_URL}"
echo ""

# dryRun実行
echo "🚀 dryRun実行中..."
RESPONSE=$(curl -sS --fail --show-error --retry 3 --retry-all-errors --max-time 30 \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -X POST \
  "${EDGE_URL}?dryRun=true&period=14d" \
  -d '{}')

echo ""
echo "✅ レスポンス:"
echo "${RESPONSE}" | jq .

# 検証
echo ""
echo "🔍 検証中..."
if echo "${RESPONSE}" | jq -e '.ok == true and .dryRun == true' > /dev/null; then
  echo "✅ dryRun成功: ok=true, dryRun=true"
else
  echo "❌ dryRun失敗: 期待されるレスポンス形式と異なります"
  exit 1
fi

if echo "${RESPONSE}" | jq -e '.stats.mean_notifications != null' > /dev/null; then
  echo "✅ 統計情報が含まれています"
else
  echo "❌ 統計情報が含まれていません"
  exit 1
fi

if echo "${RESPONSE}" | jq -e '.weekly_summary != null' > /dev/null; then
  echo "✅ 週次サマリが含まれています"
else
  echo "❌ 週次サマリが含まれていません"
  exit 1
fi

if echo "${RESPONSE}" | jq -e '.message != null' > /dev/null; then
  echo "✅ メッセージが含まれています"
  echo ""
  echo "📝 メッセージプレビュー:"
  echo "${RESPONSE}" | jq -r '.message' | head -10
else
  echo "❌ メッセージが含まれていません"
  exit 1
fi

echo ""
echo "✅ すべての検証が成功しました！"
echo ""
echo "📋 次のステップ:"
echo "  1. 本送信テスト: GitHub Actions から dryRun=false で実行"
echo "  2. または、Supabase Dashboard → Edge Functions → ops-slack-summary → Invoke"
echo "  3. Slack #ops-monitor チャンネルで週次サマリを確認"


