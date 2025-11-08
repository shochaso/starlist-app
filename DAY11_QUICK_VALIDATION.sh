#!/bin/bash
# Day11 追加のワンショット確認（任意）
# Usage: ./DAY11_QUICK_VALIDATION.sh

set -euo pipefail

DRYRUN_JSON="/tmp/day11_dryrun.json"

if [ ! -f "$DRYRUN_JSON" ]; then
  echo "❌ dryRun JSONが見つかりません: $DRYRUN_JSON"
  echo ""
  echo "DAY11_FINAL_RUN.sh または DAY11_EXECUTE_ALL.sh を先に実行してください"
  exit 1
fi

echo "=== Day11 追加のワンショット確認 ==="
echo ""

# dryRun 抜粋の目視
echo "📊 dryRun 抜粋:"
echo ""
jq '.stats, .weekly_summary, .message' "$DRYRUN_JSON" 2>/dev/null || {
  echo "⚠️  JSON解析に失敗しました"
  exit 1
}
echo ""

# 次回実行日時の抽出（JST）
echo "📅 次回実行日時（JST）:"
NEXT_RUN_JST="$(
  jq -r '.message
    | (capture("(?<date>20[0-9]{2}-[01][0-9]-[0-3][0-9]).*?(?<time>[0-2][0-9]:[0-5][0-9])")? // empty)
    | if .=="" then "N/A" else (.date+"T"+.time+":00+09:00") end' "$DRYRUN_JSON" 2>/dev/null || echo "N/A"
)"
echo "$NEXT_RUN_JST"
echo ""

# 統計値の詳細確認
echo "📈 統計値の詳細:"
echo ""
jq '.stats | {
  mean_notifications: .mean_notifications,
  std_dev: .std_dev,
  new_threshold: .new_threshold,
  critical_threshold: .critical_threshold
}' "$DRYRUN_JSON" 2>/dev/null || echo "⚠️  統計値の抽出に失敗しました"
echo ""

# 週次サマリの詳細確認
echo "📊 週次サマリの詳細:"
echo ""
jq '.weekly_summary | {
  normal: .normal,
  warning: .warning,
  critical: .critical,
  normal_change: .normal_change,
  warning_change: .warning_change,
  critical_change: .critical_change
}' "$DRYRUN_JSON" 2>/dev/null || echo "⚠️  週次サマリの抽出に失敗しました"
echo ""

echo "=== ワンショット確認完了 ==="
echo ""

