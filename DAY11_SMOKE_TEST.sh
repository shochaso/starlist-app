#!/bin/bash
# Day11 最小スモークテスト（任意・数十秒）
# Usage: ./DAY11_SMOKE_TEST.sh

set -euo pipefail

echo "=== Day11 最小スモークテスト ==="
echo ""

if [ ! -f /tmp/day11_dryrun.json ]; then
  echo "❌ /tmp/day11_dryrun.json が見つかりません"
  echo "   まず ./DAY11_EXECUTE_ALL.sh を実行してください"
  exit 1
fi

echo "📋 dryRun JSONの要点抜粋"
echo ""
jq '.stats, .weekly_summary, .message' /tmp/day11_dryrun.json

echo ""
echo "📋 次回実行日時（抽出できた場合）"
echo ""
NEXT_RUN_JST="$(
  jq -r '.message
    | (capture("(?<date>20[0-9]{2}-[01][0-9]-[0-3][0-9]).*?(?<time>[0-2][0-9]:[0-5][0-9])")? // empty)
    | if . == "" then "N/A" else (.date + "T" + .time + ":00+09:00") end' /tmp/day11_dryrun.json 2>/dev/null || echo "N/A"
)"
echo "次回実行日時: ${NEXT_RUN_JST}"

echo ""
echo "✅ スモークテスト完了"


# Day11 最小スモークテスト（任意・数十秒）
# Usage: ./DAY11_SMOKE_TEST.sh

set -euo pipefail

echo "=== Day11 最小スモークテスト ==="
echo ""

if [ ! -f /tmp/day11_dryrun.json ]; then
  echo "❌ /tmp/day11_dryrun.json が見つかりません"
  echo "   まず ./DAY11_EXECUTE_ALL.sh を実行してください"
  exit 1
fi

echo "📋 dryRun JSONの要点抜粋"
echo ""
jq '.stats, .weekly_summary, .message' /tmp/day11_dryrun.json

echo ""
echo "📋 次回実行日時（抽出できた場合）"
echo ""
NEXT_RUN_JST="$(
  jq -r '.message
    | (capture("(?<date>20[0-9]{2}-[01][0-9]-[0-3][0-9]).*?(?<time>[0-2][0-9]:[0-5][0-9])")? // empty)
    | if . == "" then "N/A" else (.date + "T" + .time + ":00+09:00") end' /tmp/day11_dryrun.json 2>/dev/null || echo "N/A"
)"
echo "次回実行日時: ${NEXT_RUN_JST}"

echo ""
echo "✅ スモークテスト完了"


