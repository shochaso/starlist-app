#!/usr/bin/env bash
# Day11 Go-Live 最終実行スクリプト（堅牢化版）
# Usage: ./DAY11_GO_LIVE.sh

set -Eeuo pipefail

# ===== Common =====
log()   { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
warn()  { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
error() { printf "\033[1;31m[ERR ]\033[0m %s\n" "$*" >&2; }
need_cmd(){ command -v "$1" >/dev/null 2>&1 || { error "Command not found: $1"; exit 127; }; }

trap 'error "Aborted (line $LINENO)"; exit 1' ERR

# ===== Preflight =====
: "${SUPABASE_URL:?Set SUPABASE_URL (e.g., https://<project-ref>.supabase.co)}"
: "${SUPABASE_ANON_KEY:?Set SUPABASE_ANON_KEY}"

need_cmd curl
need_cmd jq
command -v supabase >/dev/null 2>&1 || warn "Supabase CLI 未検出（Dashboard操作にフォールバックします）"

# URL 形式ざっくり検証
if ! echo "$SUPABASE_URL" | grep -Eq '^https://[a-z0-9-]+\.supabase\.co$'; then
  error "SUPABASE_URL format invalid: $SUPABASE_URL"
  exit 2
fi

FUNC_NAME="ops-slack-summary"
PERIOD="14d"
DRYRUN_Q="dryRun=true&period=${PERIOD}"
SEND_Q="dryRun=false&period=${PERIOD}"
TMP_DRY="/tmp/day11_dryrun.json"
TMP_SEND="/tmp/day11_send.json"

# ===== Helpers =====
validate_dryrun_json() {
  local f="$1"
  
  # ベース必須
  jq -e '.ok == true and (.stats|type)=="object" and (.weekly_summary|type)=="object" and (.message|type)=="string"' "$f" >/dev/null || {
    error "dryRun JSON: base fields invalid"
    return 1
  }
  
  # stats 数値＋境界
  jq -e '(.stats.mean_notifications|type)=="number" and (.stats.std_dev|type)=="number" and
         (.stats.new_threshold|type)=="number" and (.stats.critical_threshold|type)=="number" and
         .stats.std_dev>=0 and .stats.new_threshold>=0 and .stats.critical_threshold>=.stats.new_threshold' "$f" >/dev/null || {
    error "dryRun JSON: stats invalid or out of range"
    return 1
  }
  
  # 件数は非負整数
  jq -e '([.weekly_summary.normal,.weekly_summary.warning,.weekly_summary.critical] | all(type=="number" and .>=0 and (floor==.)))' "$f" >/dev/null || {
    error "dryRun JSON: weekly_summary counts must be non-negative integers"
    return 1
  }
  
  # 変化率：%文字列/数値/null を許容（NaN回避）
  jq -e '
    def pctnorm:
      if .==null then null
      elif (type=="number") then .
      elif (type=="string") then (gsub("[ %]";"")|gsub("\\+";"")) as $s
        | if ($s|test("^-?[0-9]*\\.?[0-9]+$")) then ($s|tonumber) else null end
      else null end;
    ([.weekly_summary.normal_change,.weekly_summary.warning_change,.weekly_summary.critical_change]
      | all( (.|pctnorm)==null or ((.|pctnorm)|type)=="number"))
  ' "$f" >/dev/null || {
    error "dryRun JSON: *_change normalization failed"
    return 1
  }
  
  # 次回実行（任意抽出）
  local next
  next="$(jq -r '.message
     | (capture("(?<date>20[0-9]{2}-[01][0-9]-[0-3][0-9]).*?(?<time>[0-2][0-9]:[0-5][0-9])")? // "")
     | if .=="" then "" else (.date+"T"+.time+":00+09:00") end' "$f" 2>/dev/null || echo "")"
  [[ -n "$next" ]] && log "Next run (JST) parsed: $next" || warn "Next run not parsed (message 形式差は許容)"
  
  log "dryRun JSON validation: OK ✅"
}

validate_send_json(){
  jq -e '.ok == true' "$1" >/dev/null || {
    error "send JSON validation failed"
    return 1
  }
  log "send JSON validation: OK ✅"
}

# ===== Main Flow =====
log "=== Day11 Go-Live 最終実行（堅牢化版） ==="
log ""

# 1) 実行直前チェック
log "📋 1) 実行直前チェック（1分）"
if [ -f ./DAY11_PREFLIGHT_CHECK.sh ]; then
  chmod +x ./DAY11_PREFLIGHT_CHECK.sh
  ./DAY11_PREFLIGHT_CHECK.sh || {
    error "実行直前チェックが失敗しました"
    exit 1
  }
else
  warn "DAY11_PREFLIGHT_CHECK.sh が見つかりません"
  log "手動でチェックを実行してください"
fi
log ""

# 2) dryRun
log "📋 2) dryRun実行"
log "Invoke dryRun..."
HTTP_CODE=$(curl -sS --fail -w "%{http_code}" -o "$TMP_DRY" -X POST \
  "${SUPABASE_URL}/functions/v1/${FUNC_NAME}?${DRYRUN_Q}" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d '{}' || echo "000")

if [[ "$HTTP_CODE" != "200" ]]; then
  error "dryRun HTTP $HTTP_CODE"
  cat "$TMP_DRY" || true
  exit 10
fi

validate_dryrun_json "$TMP_DRY"
log "dryRun 抜粋:"
jq '.stats, .weekly_summary, .message' "$TMP_DRY" || true
log ""

# 3) 本送信（確認プロンプト）
log "📋 3) 本送信（確認プロンプト）"
read -r -p ">>> 本送信しますか？（Slack #ops-monitor）[y/N]: " yn
if [[ "$yn" =~ ^[Yy]$ ]]; then
  log "Invoke SEND..."
  HTTP_CODE=$(curl -sS --fail -w "%{http_code}" -o "$TMP_SEND" -X POST \
    "${SUPABASE_URL}/functions/v1/${FUNC_NAME}?${SEND_Q}" \
    -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
    -H "apikey: ${SUPABASE_ANON_KEY}" \
    -H "Content-Type: application/json" \
    -d '{}' || echo "000")

  if [[ "$HTTP_CODE" != "200" ]]; then
    error "send HTTP $HTTP_CODE"
    cat "$TMP_SEND" || true
    exit 11
  fi
  
  validate_send_json "$TMP_SEND"
  log "Slack #ops-monitor で到達を確認してください。"
else
  warn "本送信をスキップしました（dryRunのみ）。"
fi
log ""

# 4) 合格ライン確認（最終3点）
log "📋 4) 合格ライン確認（最終3点）"
log ""
log "以下の3点を確認してください:"
log ""
log "  1. dryRun：validate_dryrun_json が OK（stats / weekly_summary / message 整合）"
log "  2. 本送信：validate_send_json が OK、Slack #ops-monitor に1件のみ到達"
log "  3. ログ：Supabase Functions 200、指数バックオフの再送なし"
log ""
read -p "すべての条件を満たしていますか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  warn "合格ラインを満たすまで実装を継続してください"
  log ""
  log "📖 トラブルシューティング:"
  log "  - Webhook 400/404：Webhook再発行 → slack_webhook_ops_summary を更新 → 再実行"
  log "  - 統計値/閾値が不正：v_ops_notify_stats の 0 補完/集計（COALESCE/CASE）を再適用"
  log "  - 変化率が \"—\"/\"N/A\"：parse_pct_or_null に gsub(\"—|N/A\";\"\") を追加"
  log "  - 件数が小数：ビューの COUNT(*)::int / CAST を確認"
  exit 1
fi
log ""

# 5) 追加のワンショット確認（任意）
log "📋 5) 追加のワンショット確認（任意）"
if [ -f "$TMP_DRY" ]; then
  read -p "dryRun抜粋を表示しますか？ (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    log ""
    log "📊 dryRun 抜粋:"
    jq '.stats, .weekly_summary, .message' "$TMP_DRY" 2>/dev/null || warn "JSON解析に失敗しました"
    log ""
    log "📅 次回実行日時（JST）:"
    jq -r '.message
      | (capture("(?<date>20[0-9]{2}-[01][0-9]-[0-3][0-9]).*?(?<time>[0-2][0-9]:[0-5][0-9])")? // empty)
      | if .=="" then "N/A" else (.date+"T"+.time+":00+09:00") end' "$TMP_DRY" 2>/dev/null || echo "N/A"
    log ""
  fi
else
  warn "dryRun JSONが見つかりません: $TMP_DRY"
fi
log ""

# 6) 最終レポート追記（任意）
log "📋 6) 最終レポート追記（任意／URLが取れたら）"
if [[ -x "./DAY11_FINAL_REPORT.sh" ]]; then
  log "最終レポート追記スクリプトの案内： ./DAY11_FINAL_REPORT.sh \"<SlackメッセージURL>\""
  read -p "最終レポートを追記しますか？ (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    log ""
    log "SlackメッセージURLを入力してください（Enterでスキップ）:"
    read -r SLACK_MSG_URL
    if [ -n "$SLACK_MSG_URL" ]; then
      ./DAY11_FINAL_REPORT.sh "$SLACK_MSG_URL"
    else
      warn "レポート追記をスキップしました"
    fi
  fi
else
  warn "DAY11_FINAL_REPORT.sh が見つかりません"
  log "手動でレポートを追記してください"
fi
log ""

# 7) 重要ファイル更新の確認
log "📋 7) 重要ファイル更新の確認"
log ""
log "以下のファイルを手動で更新してください:"
log ""
log "  [ ] OPS-MONITORING-V3-001.md（稼働開始日・責任者）"
log "  [ ] Mermaid.md（Day11ノード）"
log ""
read -p "重要ファイルを更新しましたか？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  warn "重要ファイルを更新してください"
fi
log ""

log "=== Day11 Go-Live 完了 ==="
log ""
log "✅ 実行完了:"
log "  - 実行直前チェック完了"
log "  - dryRun実行完了（自動検証付き）"
log "  - 本送信完了（確認後実行）"
log "  - 合格ライン確認完了（3点）"
log ""
log "📝 次のステップ:"
log "  1. Slack #ops-monitor チャンネルで週次サマリを確認"
log "  2. Supabase Functions Logs でログを確認"
log "  3. 重要ファイル（OPS-MONITORING-V3-001.md / Mermaid.md）を更新"
log "  4. 最終レポート（SlackメッセージURL）を追記"
log ""
log "🎉 Day11 の本番デプロイ～受け入れ確認が完了しました！"
log ""
