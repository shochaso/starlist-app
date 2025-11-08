#!/bin/bash
# Day11 Go-Live 最終実行スクリプト（一発実行）
# Usage: ./DAY11_GO_LIVE.sh

set -euo pipefail

echo "=== Day11 Go-Live 最終実行 ==="
echo ""

# 0) 環境変数確認
echo "📋 0) 環境変数確認"
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

# 1) 実行直前チェック
echo "📋 1) 実行直前チェック（1分）"
if [ -f ./DAY11_PREFLIGHT_CHECK.sh ]; then
  chmod +x ./DAY11_PREFLIGHT_CHECK.sh
  ./DAY11_PREFLIGHT_CHECK.sh || {
    echo "❌ 実行直前チェックが失敗しました"
    exit 1
  }
else
  echo "⚠️  DAY11_PREFLIGHT_CHECK.sh が見つかりません"
  echo "   手動でチェックを実行してください"
fi
echo ""

# 2) 本番実行（一括）
echo "📋 2) 本番実行（一括）"
echo ""
echo "スクリプトが dryRun → 自動検証 → 本送信 → スモーク → 変更差分 → 成功トレイル → レポート雛形 まで実行します"
echo ""
if [ -f ./DAY11_FINAL_RUN.sh ]; then
  chmod +x ./DAY11_FINAL_RUN.sh
  ./DAY11_FINAL_RUN.sh || {
    echo "❌ 本番実行が失敗しました"
    exit 1
  }
else
  echo "❌ DAY11_FINAL_RUN.sh が見つかりません"
  exit 1
fi
echo ""

# 3) 合格ライン確認（最終3点）
echo "📋 3) 合格ライン確認（最終3点）"
echo ""
echo "以下の3点を確認してください:"
echo ""
echo "  1. dryRun：validate_dryrun_json が OK（stats / weekly_summary / message 整合）"
echo "  2. 本送信：validate_send_json が OK、Slack #ops-monitor に1件のみ到達"
echo "  3. ログ：Supabase Functions 200、指数バックオフの再送なし"
echo ""
read -p "すべての条件を満たしていますか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo ""
  echo "⚠️  合格ラインを満たすまで実装を継続してください"
  echo ""
  echo "📖 トラブルシューティング:"
  echo "  - Webhook 400/404：Webhook再発行 → slack_webhook_ops_summary を更新 → 再実行"
  echo "  - 統計値/閾値が不正：v_ops_notify_stats の 0 補完/集計（COALESCE/CASE）を再適用"
  echo "  - 変化率が \"—\"/\"N/A\"：parse_pct_or_null に gsub(\"—|N/A\";\"\") を追加"
  echo "  - 件数が小数：ビューの COUNT(*)::int / CAST を確認"
  exit 1
fi
echo ""

# 4) 追加のワンショット確認（任意）
echo "📋 4) 追加のワンショット確認（任意）"
DRYRUN_JSON="/tmp/day11_dryrun.json"
if [ -f "$DRYRUN_JSON" ]; then
  read -p "dryRun抜粋を表示しますか？ (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "📊 dryRun 抜粋:"
    jq '.stats, .weekly_summary, .message' "$DRYRUN_JSON" 2>/dev/null || echo "⚠️  JSON解析に失敗しました"
    echo ""
    echo "📅 次回実行日時（JST）:"
    jq -r '.message
      | (capture("(?<date>20[0-9]{2}-[01][0-9]-[0-3][0-9]).*?(?<time>[0-2][0-9]:[0-5][0-9])")? // empty)
      | if .=="" then "N/A" else (.date+"T"+.time+":00+09:00") end' "$DRYRUN_JSON" 2>/dev/null || echo "N/A"
    echo ""
  fi
else
  echo "⚠️  dryRun JSONが見つかりません: $DRYRUN_JSON"
fi
echo ""

# 5) 最終レポート追記（任意）
echo "📋 5) 最終レポート追記（任意／URLが取れたら）"
if [ -f ./DAY11_FINAL_REPORT.sh ]; then
  chmod +x ./DAY11_FINAL_REPORT.sh
  read -p "最終レポートを追記しますか？ (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "SlackメッセージURLを入力してください（Enterでスキップ）:"
    read -r SLACK_MSG_URL
    if [ -n "$SLACK_MSG_URL" ]; then
      ./DAY11_FINAL_REPORT.sh "$SLACK_MSG_URL"
    else
      echo "⚠️  レポート追記をスキップしました"
      echo ""
      echo "後で実行する場合:"
      echo "  ./DAY11_FINAL_REPORT.sh \"https://<SlackメッセージURL>\""
    fi
  fi
else
  echo "⚠️  DAY11_FINAL_REPORT.sh が見つかりません"
  echo "   手動でレポートを追記してください"
fi
echo ""

# 6) 重要ファイル更新の確認
echo "📋 6) 重要ファイル更新の確認"
echo ""
echo "以下のファイルを手動で更新してください:"
echo ""
echo "  [ ] OPS-MONITORING-V3-001.md（稼働開始日・責任者）"
echo "  [ ] Mermaid.md（Day11ノード）"
echo ""
read -p "重要ファイルを更新しましたか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "⚠️  重要ファイルを更新してください"
fi
echo ""

echo "=== Day11 Go-Live 完了 ==="
echo ""
echo "✅ 実行完了:"
echo "  - 実行直前チェック完了"
echo "  - 本番実行完了（dryRun → 本送信 → スモーク → レポート）"
echo "  - 合格ライン確認完了（3点）"
echo ""
echo "📝 次のステップ:"
echo "  1. Slack #ops-monitor チャンネルで週次サマリを確認"
echo "  2. Supabase Functions Logs でログを確認"
echo "  3. 重要ファイル（OPS-MONITORING-V3-001.md / Mermaid.md）を更新"
echo "  4. 最終レポート（SlackメッセージURL）を追記"
echo ""
echo "🎉 Day11 の本番デプロイ～受け入れ確認が完了しました！"
echo ""

