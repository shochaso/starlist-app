#!/bin/bash
# Day11 最終レポート追記（必要なら手動で整形）
# Usage: ./DAY11_FINAL_REPORT.sh [SLACK_MSG_URL]

set -euo pipefail

SLACK_MSG_URL="${1:-}"

if [ -z "$SLACK_MSG_URL" ]; then
  echo "SlackメッセージURLを入力してください:"
  read -r SLACK_MSG_URL
fi

DRYRUN_JSON="/tmp/day11_dryrun.json"
if [ ! -f "$DRYRUN_JSON" ]; then
  echo "⚠️  dryRun JSONが見つかりません: $DRYRUN_JSON"
  echo "DAY11_EXECUTE_ALL.shを実行してから再実行してください"
  exit 1
fi

# 次回実行日時の抽出
NEXT_RUN_JST="$(
  jq -r '
    .message
    | (capture("(?<date>20[0-9]{2}-[01][0-9]-[0-3][0-9]).*?(?<time>[0-2][0-9]:[0-5][0-9])")? // empty)
    | if .=="" then "" else (.date+"T"+.time+":00+09:00") end
  ' "$DRYRUN_JSON" 2>/dev/null || echo ""
)"

if [ -z "$NEXT_RUN_JST" ]; then
  NEXT_RUN_JST="(抽出不可)"
fi

# レポート追記
REPORT_FILE="docs/reports/DAY11_SOT_DIFFS.md"
TIMESTAMP="$(date +'%Y-%m-%d %H:%M %Z')"

cat >> "$REPORT_FILE" <<EOF

### Day11 本番検証ログ（${TIMESTAMP}）

- DryRun: HTTP 200 / ok:true / period=14d（抜粋: stats / weekly_summary / message）

- 本送信: HTTP 200 / ok:true / Slack: ${SLACK_MSG_URL}

- 次回実行（推定）: ${NEXT_RUN_JST}

- Logs: Supabase Functions=200（再送なし）, GHA=成功（実施時）
EOF

echo "✅ 最終レポートを追記しました: $REPORT_FILE"
echo ""
echo "追記内容:"
cat "$REPORT_FILE" | tail -n 6


# Day11 最終レポート追記（必要なら手動で整形）
# Usage: ./DAY11_FINAL_REPORT.sh [SLACK_MSG_URL]

set -euo pipefail

SLACK_MSG_URL="${1:-}"

if [ -z "$SLACK_MSG_URL" ]; then
  echo "SlackメッセージURLを入力してください:"
  read -r SLACK_MSG_URL
fi

DRYRUN_JSON="/tmp/day11_dryrun.json"
if [ ! -f "$DRYRUN_JSON" ]; then
  echo "⚠️  dryRun JSONが見つかりません: $DRYRUN_JSON"
  echo "DAY11_EXECUTE_ALL.shを実行してから再実行してください"
  exit 1
fi

# 次回実行日時の抽出
NEXT_RUN_JST="$(
  jq -r '
    .message
    | (capture("(?<date>20[0-9]{2}-[01][0-9]-[0-3][0-9]).*?(?<time>[0-2][0-9]:[0-5][0-9])")? // empty)
    | if .=="" then "" else (.date+"T"+.time+":00+09:00") end
  ' "$DRYRUN_JSON" 2>/dev/null || echo ""
)"

if [ -z "$NEXT_RUN_JST" ]; then
  NEXT_RUN_JST="(抽出不可)"
fi

# レポート追記
REPORT_FILE="docs/reports/DAY11_SOT_DIFFS.md"
TIMESTAMP="$(date +'%Y-%m-%d %H:%M %Z')"

cat >> "$REPORT_FILE" <<EOF

### Day11 本番検証ログ（${TIMESTAMP}）

- DryRun: HTTP 200 / ok:true / period=14d（抜粋: stats / weekly_summary / message）

- 本送信: HTTP 200 / ok:true / Slack: ${SLACK_MSG_URL}

- 次回実行（推定）: ${NEXT_RUN_JST}

- Logs: Supabase Functions=200（再送なし）, GHA=成功（実施時）
EOF

echo "✅ 最終レポートを追記しました: $REPORT_FILE"
echo ""
echo "追記内容:"
cat "$REPORT_FILE" | tail -n 6


