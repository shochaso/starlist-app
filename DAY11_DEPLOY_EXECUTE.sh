#!/bin/bash
# Day11 ops-slack-summary デプロイ & 受け入れ確認実行スクリプト
# Usage: ./DAY11_DEPLOY_EXECUTE.sh

set -euo pipefail

echo "=== Day11 ops-slack-summary デプロイ & 受け入れ確認 ==="
echo ""

# 1) Preflight（環境変数 & Secret最終確認）
echo "📋 1) Preflight（環境変数 & Secret最終確認）"
echo ""

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

echo "✅ SUPABASE_URL: ${SUPABASE_URL}"
echo "✅ SUPABASE_ANON_KEY: ${SUPABASE_ANON_KEY:0:20}..."
echo ""
echo "⚠️  Secrets確認（手動）:"
echo "  - GitHub Actions Secret: SLACK_WEBHOOK_OPS_SUMMARY"
echo "  - Supabase Edge Secret: slack_webhook_ops_summary"
echo ""
read -p "Secrets設定は完了していますか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "❌ Secrets設定を完了してから再実行してください"
  exit 1
fi

# 2) DBビュー存在確認（v_ops_notify_stats）
echo ""
echo "📋 2) DBビュー存在確認（v_ops_notify_stats）"
echo ""

# psqlが利用可能か確認
if ! command -v psql &> /dev/null; then
  echo "⚠️  psql が利用できません。Supabase Dashboard → SQL Editor で手動確認してください"
  echo "   実行SQL:"
  echo "   SELECT 1 FROM pg_views WHERE viewname = 'v_ops_notify_stats';"
  echo ""
else
  echo "✅ psql が利用可能です"
  echo "   DBビューの存在確認は Supabase Dashboard → SQL Editor で実行してください"
  echo "   または、psql で直接実行:"
  echo "   psql \"\$SUPABASE_URL\" -c \"SELECT 1 FROM pg_views WHERE viewname = 'v_ops_notify_stats';\""
  echo ""
fi

read -p "DBビュー v_ops_notify_stats は作成済みですか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "❌ DBビューを作成してから再実行してください"
  echo "   SQL: supabase/migrations/20251108_v_ops_notify_stats.sql"
  exit 1
fi

# 3) Edge Functionデプロイ（ops-slack-summary）
echo ""
echo "📋 3) Edge Functionデプロイ（ops-slack-summary）"
echo ""

if command -v supabase &> /dev/null; then
  echo "✅ Supabase CLI が利用可能です"
  echo "   デプロイコマンド: supabase functions deploy ops-slack-summary"
  echo ""
  read -p "Edge Functionをデプロイしますか？ (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    supabase functions deploy ops-slack-summary
    echo "✅ Edge Functionデプロイ完了"
  else
    echo "⚠️  デプロイをスキップしました。Supabase Dashboard から手動デプロイしてください"
  fi
else
  echo "⚠️  Supabase CLI が利用できません。Supabase Dashboard から手動デプロイしてください"
  echo "   Functions > ops-slack-summary > Deploy"
fi

echo ""
read -p "Edge Function ops-slack-summary はデプロイ済みですか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "❌ Edge Functionをデプロイしてから再実行してください"
  exit 1
fi

# 4) dryRun（JSON検証つき）
echo ""
echo "📋 4) dryRun（JSON検証つき）"
echo ""

EDGE_URL="${SUPABASE_URL%/}/functions/v1/ops-slack-summary"
DRYRUN_URL="${EDGE_URL}?dryRun=true&period=14d"

echo "🚀 dryRun実行中..."
RESPONSE=$(curl -sS --fail --show-error --retry 3 --retry-all-errors --max-time 30 \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -X POST \
  "${DRYRUN_URL}" \
  -d '{}')

echo "${RESPONSE}" | tee /tmp/day11_dryrun.json | jq .

echo ""
echo "🔍 自動検証中..."

# 検証1: 必須フィールドの存在
if echo "${RESPONSE}" | jq -e 'has("ok") and has("period") and has("stats") and has("weekly_summary") and has("message")' > /dev/null 2>&1; then
  echo "✅ 必須フィールドが存在します"
else
  echo "❌ 必須フィールドが不足しています"
  exit 1
fi

# 検証2: ok == true かつ stats の構造
if echo "${RESPONSE}" | jq -e '.ok == true and (.stats | has("mean_notifications", "std_dev", "new_threshold", "critical_threshold"))' > /dev/null 2>&1; then
  echo "✅ ok=true かつ stats構造が正しいです"
else
  echo "❌ ok=false または stats構造が不正です"
  exit 1
fi

# 検証3: std_dev が数値
if echo "${RESPONSE}" | jq -e '(.stats.std_dev | type) == "number"' > /dev/null 2>&1; then
  echo "✅ std_dev が数値です"
else
  echo "❌ std_dev が数値ではありません"
  exit 1
fi

# 検証4: weekly_summary の構造
if echo "${RESPONSE}" | jq -e '(.weekly_summary | type) == "object" and (.weekly_summary | has("normal", "warning", "critical", "normal_change", "warning_change", "critical_change"))' > /dev/null 2>&1; then
  echo "✅ weekly_summary 構造が正しいです"
else
  echo "❌ weekly_summary 構造が不正です"
  exit 1
fi

# 検証5: message が文字列
if echo "${RESPONSE}" | jq -e '(.message | type) == "string"' > /dev/null 2>&1; then
  echo "✅ message が文字列です"
  echo ""
  echo "📝 メッセージプレビュー:"
  echo "${RESPONSE}" | jq -r '.message' | head -10
else
  echo "❌ message が文字列ではありません"
  exit 1
fi

echo ""
echo "✅ dryRun検証がすべて成功しました！"

# 5) 本送信テスト（Slack #ops-monitor 到達確認）
echo ""
echo "📋 5) 本送信テスト（Slack #ops-monitor 到達確認）"
echo ""

read -p "本送信テストを実行しますか？ (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  SEND_URL="${EDGE_URL}?dryRun=false&period=14d"
  
  echo "🚀 本送信実行中..."
  SEND_RESPONSE=$(curl -sS --fail --show-error --retry 3 --retry-all-errors --max-time 30 \
    -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
    -H "apikey: ${SUPABASE_ANON_KEY}" \
    -H "Content-Type: application/json" \
    -X POST \
    "${SEND_URL}" \
    -d '{}')
  
  echo "${SEND_RESPONSE}" | tee /tmp/day11_send.json | jq .
  
  if echo "${SEND_RESPONSE}" | jq -e '.ok == true' > /dev/null 2>&1; then
    echo ""
    echo "✅ 本送信が成功しました"
    echo "   Slack #ops-monitor チャンネルで確認してください"
  else
    echo ""
    echo "❌ 本送信が失敗しました"
    echo "   レスポンス: ${SEND_RESPONSE}"
    exit 1
  fi
else
  echo "⚠️  本送信テストをスキップしました"
fi

# 6) ログ確認（成功トレイル）
echo ""
echo "📋 6) ログ確認（成功トレイル）"
echo ""
echo "✅ ログ確認手順:"
echo "   - Supabase Functions Logs: Dashboard → Edge Functions → ops-slack-summary → Logs"
echo "   - GitHub Actions: gh run list --workflow=ops-slack-summary.yml --limit 5"
echo ""
echo "   確認ポイント:"
echo "   - HTTP 200 で完了"
echo "   - 再送（指数バックオフ）が発火していない"
echo "   - エラーがない"
echo ""

# 7) 成果物の記録
echo ""
echo "📋 7) 成果物の記録"
echo ""
echo "✅ 以下のファイルを更新してください:"
echo ""
echo "   1. docs/reports/DAY11_SOT_DIFFS.md"
echo "      - dryRunレスポンス（/tmp/day11_dryrun.json）"
echo "      - 本送信レスポンス（/tmp/day11_send.json）"
echo "      - Slackスクショ（メッセージID/時刻）"
echo ""
echo "   2. docs/ops/OPS-MONITORING-V3-001.md"
echo "      - 稼働開始日"
echo "      - 運用責任者"
echo "      - 連絡先"
echo ""
echo "   3. docs/Mermaid.md"
echo "      - Day11ノードをDay10直下に追加"
echo ""

# 8) Go/No-Go 判定
echo ""
echo "📋 8) Go/No-Go 判定（最終4点）"
echo ""
echo "✅ 判定基準:"
echo "   [ ] dryRun検証すべて合格"
echo "   [ ] Slack本送信が到達し体裁OK"
echo "   [ ] ログにエラー/再送痕跡なし"
echo "   [ ] 3文書更新（SOT/運用/Mermaid）"
echo ""
echo "すべての基準を満たしている場合、Day11は Go です！"
echo ""

