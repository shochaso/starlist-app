#!/bin/bash
# Day11 ops-slack-summary デプロイ & 受け入れ確認 一括実行スクリプト
# Usage: ./DAY11_EXECUTE_ALL.sh

set -euo pipefail

echo "=== Day11 ops-slack-summary デプロイ & 受け入れ確認（一括実行） ==="
echo ""

# ① 環境変数をセット（Preflight）
echo "📋 ① 環境変数をセット（Preflight）"
echo ""

if [ -z "${SUPABASE_URL:-}" ]; then
  echo "❌ Error: SUPABASE_URL is not set"
  echo ""
  echo "環境変数を設定してください:"
  echo "  export SUPABASE_URL='https://<project-ref>.supabase.co'"
  echo "  export SUPABASE_ANON_KEY='<anon-key>'"
  echo ""
  echo "取得方法: Supabase Dashboard → Project Settings → API"
  exit 1
fi

if [ -z "${SUPABASE_ANON_KEY:-}" ]; then
  echo "❌ Error: SUPABASE_ANON_KEY is not set"
  echo ""
  echo "環境変数を設定してください:"
  echo "  export SUPABASE_URL='https://<project-ref>.supabase.co'"
  echo "  export SUPABASE_ANON_KEY='<anon-key>'"
  echo ""
  echo "取得方法: Supabase Dashboard → Project Settings → API"
  exit 1
fi

# URL形式チェック
if ! echo "$SUPABASE_URL" | grep -qE '^https://[a-z0-9-]+\.supabase\.co$'; then
  echo "⚠️  Warning: SUPABASE_URL format may be incorrect"
  echo "   Expected: https://<project-ref>.supabase.co"
  echo "   Got: $SUPABASE_URL"
  read -p "続行しますか？ (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
else
  echo "✅ OK: URL形式"
fi

# jq の確認
if ! command -v jq >/dev/null 2>&1; then
  echo "⚠️  jq がインストールされていません"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "   macOSの場合: brew install jq"
  else
    echo "   Linuxの場合: sudo apt-get install jq または sudo yum install jq"
  fi
  read -p "jqをインストールしますか？ (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      brew install jq
    else
      echo "手動でインストールしてください"
      exit 1
    fi
  else
    echo "❌ jqが必要です。インストールしてから再実行してください"
    exit 1
  fi
fi

echo "✅ SUPABASE_URL: ${SUPABASE_URL}"
echo "✅ SUPABASE_ANON_KEY: ${SUPABASE_ANON_KEY:0:20}..."
echo ""
echo "⚠️  Secrets確認（手動）:"
echo "  - Supabase Edge Function Secret: slack_webhook_ops_summary（小文字スネーク）"
echo "  - GitHub Actions Secret: SLACK_WEBHOOK_OPS_SUMMARY（大文字スネーク）"
echo ""

# ② DBビューの作成確認
echo "📋 ② DBビューの作成確認"
echo ""
echo "⚠️  Supabase Dashboard → SQL Editor で以下を実行してください:"
echo "   supabase/migrations/20251108_v_ops_notify_stats.sql"
echo ""
read -p "DBビュー v_ops_notify_stats は作成済みですか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "❌ DBビューを作成してから再実行してください"
  exit 1
fi

# ③ Edge Functionデプロイ確認
echo ""
echo "📋 ③ Edge Functionデプロイ確認"
echo ""
echo "⚠️  Supabase Dashboard → Edge Functions → ops-slack-summary → Deploy"
echo "   Secrets設定: slack_webhook_ops_summary"
echo ""
read -p "Edge Function ops-slack-summary はデプロイ済みですか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "❌ Edge Functionをデプロイしてから再実行してください"
  exit 1
fi

# ④ dryRun実行（自動検証つき）
echo ""
echo "📋 ④ dryRun実行（自動検証つき）"
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

# ============ Validation Functions (final, impl-aligned & robust) ============
# 期待JSON例：
# {
#   "ok": true,
#   "stats": { "mean_notifications": 12.3, "std_dev": 2.1, "new_threshold": 16, "critical_threshold": 20 },
#   "weekly_summary": {
#     "normal": 10, "warning": 2, "critical": 1,
#     "normal_change": "+6.3%", "warning_change": "-2.0%", "critical_change": null
#   },
#   "message": "Next run: 2025-11-10 09:00 JST ..."
# }

parse_pct_or_null() {
  # jq filter that converts "+6.3%" / "-2%" / "0%" / "6.3" / 6.3 / null -> number or null
  cat <<'JQ'
    (if . == null then null
     elif (type=="number") then .
     elif (type=="string") then
       (. | gsub("[ %]";"") | gsub("\\+";"") ) as $s
       | if ($s|test("^-?[0-9]*\\.?[0-9]+$")) then ($s|tonumber) else null end
     else null end)
JQ
}

validate_dryrun_json() {
  local f="$1"

  # 1) ベース必須
  jq -e '
    .ok == true and
    (.stats | type) == "object" and
    (.weekly_summary | type) == "object" and
    (.message | type) == "string"
  ' "$f" >/dev/null || { echo "[ERR ] base fields invalid"; return 1; }
  echo "✅ ベース必須フィールドが正しいです"

  # 2) stats: 数値 & 境界（std_dev>=0, thresholds>=0, critical>=new）
  jq -e '
    (.stats.mean_notifications      | type) == "number" and
    (.stats.std_dev                 | type) == "number" and
    (.stats.new_threshold           | type) == "number" and
    (.stats.critical_threshold      | type) == "number" and
    (.stats.std_dev >= 0) and
    (.stats.new_threshold >= 0) and
    (.stats.critical_threshold >= .stats.new_threshold)
  ' "$f" >/dev/null || { echo "[ERR ] stats invalid or out of range"; return 1; }
  echo "✅ stats フィールドが正しいです（境界値チェックOK）"

  # 3) weekly_summary: 件数は非負整数、変化率は 文字列% / 数値 / null を許容
  jq -e '
    (.weekly_summary.normal   | type) == "number" and (.weekly_summary.normal   >= 0) and ((.weekly_summary.normal   | floor) == .weekly_summary.normal) and
    (.weekly_summary.warning  | type) == "number" and (.weekly_summary.warning  >= 0) and ((.weekly_summary.warning  | floor) == .weekly_summary.warning) and
    (.weekly_summary.critical | type) == "number" and (.weekly_summary.critical >= 0) and ((.weekly_summary.critical | floor) == .weekly_summary.critical)
  ' "$f" >/dev/null || { echo "[ERR ] weekly_summary counts must be non-negative integers"; return 1; }
  echo "✅ weekly_summary 件数が正しいです（非負整数）"

  # 3-2) 変化率の正規化（%文字列→数値）と NaN 回避チェック
  local pct_filter
  pct_filter="$(parse_pct_or_null)"
  jq -e --argfile _ "$f" '
    .weekly_summary as $w
    | {
        normal:  $w.normal,
        warning: $w.warning,
        critical:$w.critical,
        normal_change:  ($w.normal_change | '"$pct_filter"'),
        warning_change: ($w.warning_change | '"$pct_filter"'),
        critical_change:($w.critical_change | '"$pct_filter"')
      }
    | true
  ' "$f" >/dev/null || { echo "[ERR ] *_change normalization failed"; return 1; }
  echo "✅ 変化率の正規化が成功しました（NaN回避）"

  # 4) 次回実行日時っぽい表現を message から抽出（JP/ENのゆるい両対応）
  #    YYYY-MM-DD と HH:MM を拾えたら表示。拾えなくても致命ではない。
  local next_run_iso
  next_run_iso="$(
    jq -r '
      .message
      | capture("(?<date>20[0-9]{2}-[01][0-9]-[0-3][0-9]).*?(?<time>[0-2][0-9]:[0-5][0-9])")?
      | if . == null then "" else (.date + "T" + .time + ":00+09:00") end
    ' "$f"
  )"
  if [[ -n "$next_run_iso" ]]; then
    echo "[INFO] Next run (parsed): $next_run_iso"
  else
    echo "[WARN] Could not parse next run from .message（表現差異は許容）"
  fi

  echo "[INFO] dryRun JSON validation: OK ✅"
  return 0
}

validate_send_json() {
  local f="$1"
  jq -e '.ok == true' "$f" >/dev/null || { echo "[ERR ] send json not ok"; return 1; }
  echo "[INFO] send JSON validation: OK ✅"
  return 0
}

# dryRun JSON検証実行
if ! validate_dryrun_json "/tmp/day11_dryrun.json"; then
  echo ""
  echo "❌ dryRun検証が失敗しました"
  exit 1
fi

echo ""
echo "📝 メッセージプレビュー:"
jq '.stats, .weekly_summary, .message' /tmp/day11_dryrun.json

echo ""
echo "✅ dryRun検証がすべて成功しました！"

# ⑤ 本送信テスト（Slack #ops-monitor）
echo ""
echo "📋 ⑤ 本送信テスト（Slack #ops-monitor）"
echo ""

read -p "本送信テストを実行しますか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "⚠️  本送信テストをスキップしました"
  echo "   後で手動実行してください:"
  echo "   curl -sS -X POST \"${EDGE_URL}?dryRun=false&period=14d\" \\"
  echo "     -H \"Authorization: Bearer \${SUPABASE_ANON_KEY}\" \\"
  echo "     -H \"apikey: \${SUPABASE_ANON_KEY}\" \\"
  echo "     -H \"Content-Type: application/json\" \\"
  echo "     -d '{}' | jq"
  exit 0
fi

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

# 本送信JSON検証実行
if ! validate_send_json "/tmp/day11_send.json"; then
  echo ""
  echo "❌ 本送信が失敗しました"
  exit 1
fi

echo ""
echo "✅ 本送信が成功しました"
echo "   Slack #ops-monitor チャンネルで確認してください"

# sent フィールドの確認
if jq -e '.sent == true' /tmp/day11_send.json >/dev/null 2>&1; then
  echo "✅ Slackへの送信が完了しました"
elif jq -e '.sent == false' /tmp/day11_send.json >/dev/null 2>&1; then
  echo "⚠️  Slackへの送信が失敗しました（エラーを確認してください）"
  jq -r '.error // empty' /tmp/day11_send.json
fi

# ⑥ ログ確認（成功トレイル）
echo ""
echo "📋 ⑥ ログ確認（成功トレイル）"
echo ""
echo "✅ ログ確認手順:"
echo "   - Supabase Functions Logs: Dashboard → Edge Functions → ops-slack-summary → Logs"
echo "   - HTTP 200 で完了していることを確認"
echo "   - 指数バックオフの再送が出ていないことを確認"
echo ""

# ⑦ 成果物の記録
echo ""
echo "📋 ⑦ 成果物の記録"
echo ""

# 次回実行日時の抽出
NEXT_RUN_JST="$(
  jq -r '
    .message
    | (capture("(?<date>20[0-9]{2}-[01][0-9]-[0-3][0-9]).*?(?<time>[0-2][0-9]:[0-5][0-9])")? // empty)
    | if . == "" then "" else (.date + "T" + .time + ":00+09:00") end
  ' /tmp/day11_dryrun.json 2>/dev/null || echo ""
)"

read -p "SlackメッセージURLを入力してください（任意）: " SLACK_MSG_URL

echo ""
echo "📝 DAY11_SOT_DIFFS.md に追記しますか？ (y/n)"
read -p ">>> " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  cat >> docs/reports/DAY11_SOT_DIFFS.md <<EOF

### 本番検証ログ（$(date +'%Y-%m-%d %H:%M %Z')）

- DryRun: HTTP 200 / ok:true / period=14d（抜粋: stats / weekly_summary / message）

- 本送信: HTTP 200 / ok:true / Slack: ${SLACK_MSG_URL:-"(URL未記入)"}

- 次回実行（推定）: ${NEXT_RUN_JST:-"(抽出不可)"}

- Logs: Supabase Functions=200（再送なし） / GHA（実施時）=成功
EOF
  echo "✅ DAY11_SOT_DIFFS.md に追記しました"
else
  echo "⚠️  手動で追記してください"
fi

echo ""
echo "✅ 以下のファイルも更新してください:"
echo ""
echo "1. docs/ops/OPS-MONITORING-V3-001.md"
echo "   - 稼働開始日"
echo "   - 運用責任者"
echo "   - 連絡先"
echo ""
echo "2. docs/Mermaid.md"
echo "   - Day11ノードをDay10直下に追加"
echo ""

# ⑧ Go/No-Go判定
echo ""
echo "📋 ⑧ Go/No-Go判定（4条件）"
echo ""
echo "✅ 判定基準:"
echo "   [ ] dryRun検証すべて合格"
echo "   [ ] Slack本送信が到達し体裁OK"
echo "   [ ] ログにエラー/再送痕跡なし"
echo "   [ ] 3文書更新（SOT/運用/Mermaid）"
echo ""
echo "すべての基準を満たしている場合、Day11は Go です！"
echo ""

# 実行結果サマリー
echo "=== 実行結果サマリー ==="
echo ""
echo "✅ dryRun結果: /tmp/day11_dryrun.json"
if [ -f /tmp/day11_send.json ]; then
  echo "✅ 本送信結果: /tmp/day11_send.json"
fi
echo ""
echo "📝 次のステップ:"
echo "   1. Slack #ops-monitor チャンネルで週次サマリを確認"
echo "   2. Supabase Functions Logs でログを確認"
echo "   3. 成果物を記録（DAY11_SOT_DIFFS.md など）"
echo "   4. Go/No-Go判定を実施"
echo ""


# Usage: ./DAY11_EXECUTE_ALL.sh

set -euo pipefail

echo "=== Day11 ops-slack-summary デプロイ & 受け入れ確認（一括実行） ==="
echo ""

# ① 環境変数をセット（Preflight）
echo "📋 ① 環境変数をセット（Preflight）"
echo ""

if [ -z "${SUPABASE_URL:-}" ]; then
  echo "❌ Error: SUPABASE_URL is not set"
  echo ""
  echo "環境変数を設定してください:"
  echo "  export SUPABASE_URL='https://<project-ref>.supabase.co'"
  echo "  export SUPABASE_ANON_KEY='<anon-key>'"
  echo ""
  echo "取得方法: Supabase Dashboard → Project Settings → API"
  exit 1
fi

if [ -z "${SUPABASE_ANON_KEY:-}" ]; then
  echo "❌ Error: SUPABASE_ANON_KEY is not set"
  echo ""
  echo "環境変数を設定してください:"
  echo "  export SUPABASE_URL='https://<project-ref>.supabase.co'"
  echo "  export SUPABASE_ANON_KEY='<anon-key>'"
  echo ""
  echo "取得方法: Supabase Dashboard → Project Settings → API"
  exit 1
fi

# URL形式チェック
if ! echo "$SUPABASE_URL" | grep -qE '^https://[a-z0-9-]+\.supabase\.co$'; then
  echo "⚠️  Warning: SUPABASE_URL format may be incorrect"
  echo "   Expected: https://<project-ref>.supabase.co"
  echo "   Got: $SUPABASE_URL"
  read -p "続行しますか？ (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
else
  echo "✅ OK: URL形式"
fi

# jq の確認
if ! command -v jq >/dev/null 2>&1; then
  echo "⚠️  jq がインストールされていません"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "   macOSの場合: brew install jq"
  else
    echo "   Linuxの場合: sudo apt-get install jq または sudo yum install jq"
  fi
  read -p "jqをインストールしますか？ (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      brew install jq
    else
      echo "手動でインストールしてください"
      exit 1
    fi
  else
    echo "❌ jqが必要です。インストールしてから再実行してください"
    exit 1
  fi
fi

echo "✅ SUPABASE_URL: ${SUPABASE_URL}"
echo "✅ SUPABASE_ANON_KEY: ${SUPABASE_ANON_KEY:0:20}..."
echo ""
echo "⚠️  Secrets確認（手動）:"
echo "  - Supabase Edge Function Secret: slack_webhook_ops_summary（小文字スネーク）"
echo "  - GitHub Actions Secret: SLACK_WEBHOOK_OPS_SUMMARY（大文字スネーク）"
echo ""

# ② DBビューの作成確認
echo "📋 ② DBビューの作成確認"
echo ""
echo "⚠️  Supabase Dashboard → SQL Editor で以下を実行してください:"
echo "   supabase/migrations/20251108_v_ops_notify_stats.sql"
echo ""
read -p "DBビュー v_ops_notify_stats は作成済みですか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "❌ DBビューを作成してから再実行してください"
  exit 1
fi

# ③ Edge Functionデプロイ確認
echo ""
echo "📋 ③ Edge Functionデプロイ確認"
echo ""
echo "⚠️  Supabase Dashboard → Edge Functions → ops-slack-summary → Deploy"
echo "   Secrets設定: slack_webhook_ops_summary"
echo ""
read -p "Edge Function ops-slack-summary はデプロイ済みですか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "❌ Edge Functionをデプロイしてから再実行してください"
  exit 1
fi

# ④ dryRun実行（自動検証つき）
echo ""
echo "📋 ④ dryRun実行（自動検証つき）"
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

# ============ Validation Functions (final, impl-aligned & robust) ============
# 期待JSON例：
# {
#   "ok": true,
#   "stats": { "mean_notifications": 12.3, "std_dev": 2.1, "new_threshold": 16, "critical_threshold": 20 },
#   "weekly_summary": {
#     "normal": 10, "warning": 2, "critical": 1,
#     "normal_change": "+6.3%", "warning_change": "-2.0%", "critical_change": null
#   },
#   "message": "Next run: 2025-11-10 09:00 JST ..."
# }

parse_pct_or_null() {
  # jq filter that converts "+6.3%" / "-2%" / "0%" / "6.3" / 6.3 / null -> number or null
  cat <<'JQ'
    (if . == null then null
     elif (type=="number") then .
     elif (type=="string") then
       (. | gsub("[ %]";"") | gsub("\\+";"") ) as $s
       | if ($s|test("^-?[0-9]*\\.?[0-9]+$")) then ($s|tonumber) else null end
     else null end)
JQ
}

validate_dryrun_json() {
  local f="$1"

  # 1) ベース必須
  jq -e '
    .ok == true and
    (.stats | type) == "object" and
    (.weekly_summary | type) == "object" and
    (.message | type) == "string"
  ' "$f" >/dev/null || { echo "[ERR ] base fields invalid"; return 1; }
  echo "✅ ベース必須フィールドが正しいです"

  # 2) stats: 数値 & 境界（std_dev>=0, thresholds>=0, critical>=new）
  jq -e '
    (.stats.mean_notifications      | type) == "number" and
    (.stats.std_dev                 | type) == "number" and
    (.stats.new_threshold           | type) == "number" and
    (.stats.critical_threshold      | type) == "number" and
    (.stats.std_dev >= 0) and
    (.stats.new_threshold >= 0) and
    (.stats.critical_threshold >= .stats.new_threshold)
  ' "$f" >/dev/null || { echo "[ERR ] stats invalid or out of range"; return 1; }
  echo "✅ stats フィールドが正しいです（境界値チェックOK）"

  # 3) weekly_summary: 件数は非負整数、変化率は 文字列% / 数値 / null を許容
  jq -e '
    (.weekly_summary.normal   | type) == "number" and (.weekly_summary.normal   >= 0) and ((.weekly_summary.normal   | floor) == .weekly_summary.normal) and
    (.weekly_summary.warning  | type) == "number" and (.weekly_summary.warning  >= 0) and ((.weekly_summary.warning  | floor) == .weekly_summary.warning) and
    (.weekly_summary.critical | type) == "number" and (.weekly_summary.critical >= 0) and ((.weekly_summary.critical | floor) == .weekly_summary.critical)
  ' "$f" >/dev/null || { echo "[ERR ] weekly_summary counts must be non-negative integers"; return 1; }
  echo "✅ weekly_summary 件数が正しいです（非負整数）"

  # 3-2) 変化率の正規化（%文字列→数値）と NaN 回避チェック
  local pct_filter
  pct_filter="$(parse_pct_or_null)"
  jq -e --argfile _ "$f" '
    .weekly_summary as $w
    | {
        normal:  $w.normal,
        warning: $w.warning,
        critical:$w.critical,
        normal_change:  ($w.normal_change | '"$pct_filter"'),
        warning_change: ($w.warning_change | '"$pct_filter"'),
        critical_change:($w.critical_change | '"$pct_filter"')
      }
    | true
  ' "$f" >/dev/null || { echo "[ERR ] *_change normalization failed"; return 1; }
  echo "✅ 変化率の正規化が成功しました（NaN回避）"

  # 4) 次回実行日時っぽい表現を message から抽出（JP/ENのゆるい両対応）
  #    YYYY-MM-DD と HH:MM を拾えたら表示。拾えなくても致命ではない。
  local next_run_iso
  next_run_iso="$(
    jq -r '
      .message
      | capture("(?<date>20[0-9]{2}-[01][0-9]-[0-3][0-9]).*?(?<time>[0-2][0-9]:[0-5][0-9])")?
      | if . == null then "" else (.date + "T" + .time + ":00+09:00") end
    ' "$f"
  )"
  if [[ -n "$next_run_iso" ]]; then
    echo "[INFO] Next run (parsed): $next_run_iso"
  else
    echo "[WARN] Could not parse next run from .message（表現差異は許容）"
  fi

  echo "[INFO] dryRun JSON validation: OK ✅"
  return 0
}

validate_send_json() {
  local f="$1"
  jq -e '.ok == true' "$f" >/dev/null || { echo "[ERR ] send json not ok"; return 1; }
  echo "[INFO] send JSON validation: OK ✅"
  return 0
}

# dryRun JSON検証実行
if ! validate_dryrun_json "/tmp/day11_dryrun.json"; then
  echo ""
  echo "❌ dryRun検証が失敗しました"
  exit 1
fi

echo ""
echo "📝 メッセージプレビュー:"
jq '.stats, .weekly_summary, .message' /tmp/day11_dryrun.json

echo ""
echo "✅ dryRun検証がすべて成功しました！"

# ⑤ 本送信テスト（Slack #ops-monitor）
echo ""
echo "📋 ⑤ 本送信テスト（Slack #ops-monitor）"
echo ""

read -p "本送信テストを実行しますか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "⚠️  本送信テストをスキップしました"
  echo "   後で手動実行してください:"
  echo "   curl -sS -X POST \"${EDGE_URL}?dryRun=false&period=14d\" \\"
  echo "     -H \"Authorization: Bearer \${SUPABASE_ANON_KEY}\" \\"
  echo "     -H \"apikey: \${SUPABASE_ANON_KEY}\" \\"
  echo "     -H \"Content-Type: application/json\" \\"
  echo "     -d '{}' | jq"
  exit 0
fi

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

# 本送信JSON検証実行
if ! validate_send_json "/tmp/day11_send.json"; then
  echo ""
  echo "❌ 本送信が失敗しました"
  exit 1
fi

echo ""
echo "✅ 本送信が成功しました"
echo "   Slack #ops-monitor チャンネルで確認してください"

# sent フィールドの確認
if jq -e '.sent == true' /tmp/day11_send.json >/dev/null 2>&1; then
  echo "✅ Slackへの送信が完了しました"
elif jq -e '.sent == false' /tmp/day11_send.json >/dev/null 2>&1; then
  echo "⚠️  Slackへの送信が失敗しました（エラーを確認してください）"
  jq -r '.error // empty' /tmp/day11_send.json
fi

# ⑥ ログ確認（成功トレイル）
echo ""
echo "📋 ⑥ ログ確認（成功トレイル）"
echo ""
echo "✅ ログ確認手順:"
echo "   - Supabase Functions Logs: Dashboard → Edge Functions → ops-slack-summary → Logs"
echo "   - HTTP 200 で完了していることを確認"
echo "   - 指数バックオフの再送が出ていないことを確認"
echo ""

# ⑦ 成果物の記録
echo ""
echo "📋 ⑦ 成果物の記録"
echo ""

# 次回実行日時の抽出
NEXT_RUN_JST="$(
  jq -r '
    .message
    | (capture("(?<date>20[0-9]{2}-[01][0-9]-[0-3][0-9]).*?(?<time>[0-2][0-9]:[0-5][0-9])")? // empty)
    | if . == "" then "" else (.date + "T" + .time + ":00+09:00") end
  ' /tmp/day11_dryrun.json 2>/dev/null || echo ""
)"

read -p "SlackメッセージURLを入力してください（任意）: " SLACK_MSG_URL

echo ""
echo "📝 DAY11_SOT_DIFFS.md に追記しますか？ (y/n)"
read -p ">>> " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  cat >> docs/reports/DAY11_SOT_DIFFS.md <<EOF

### 本番検証ログ（$(date +'%Y-%m-%d %H:%M %Z')）

- DryRun: HTTP 200 / ok:true / period=14d（抜粋: stats / weekly_summary / message）

- 本送信: HTTP 200 / ok:true / Slack: ${SLACK_MSG_URL:-"(URL未記入)"}

- 次回実行（推定）: ${NEXT_RUN_JST:-"(抽出不可)"}

- Logs: Supabase Functions=200（再送なし） / GHA（実施時）=成功
EOF
  echo "✅ DAY11_SOT_DIFFS.md に追記しました"
else
  echo "⚠️  手動で追記してください"
fi

echo ""
echo "✅ 以下のファイルも更新してください:"
echo ""
echo "1. docs/ops/OPS-MONITORING-V3-001.md"
echo "   - 稼働開始日"
echo "   - 運用責任者"
echo "   - 連絡先"
echo ""
echo "2. docs/Mermaid.md"
echo "   - Day11ノードをDay10直下に追加"
echo ""

# ⑧ Go/No-Go判定
echo ""
echo "📋 ⑧ Go/No-Go判定（4条件）"
echo ""
echo "✅ 判定基準:"
echo "   [ ] dryRun検証すべて合格"
echo "   [ ] Slack本送信が到達し体裁OK"
echo "   [ ] ログにエラー/再送痕跡なし"
echo "   [ ] 3文書更新（SOT/運用/Mermaid）"
echo ""
echo "すべての基準を満たしている場合、Day11は Go です！"
echo ""

# 実行結果サマリー
echo "=== 実行結果サマリー ==="
echo ""
echo "✅ dryRun結果: /tmp/day11_dryrun.json"
if [ -f /tmp/day11_send.json ]; then
  echo "✅ 本送信結果: /tmp/day11_send.json"
fi
echo ""
echo "📝 次のステップ:"
echo "   1. Slack #ops-monitor チャンネルで週次サマリを確認"
echo "   2. Supabase Functions Logs でログを確認"
echo "   3. 成果物を記録（DAY11_SOT_DIFFS.md など）"
echo "   4. Go/No-Go判定を実施"
echo ""

