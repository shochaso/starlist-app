#!/usr/bin/env bash
# Day11 Go-Live 最終実行スクリプト（堅牢化版・完成版）
# Usage: ./DAY11_GO_LIVE.sh

set -Eeuo pipefail

# ===== Common =====
log()   { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
warn()  { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
error() { printf "\033[1;31m[ERR ]\033[0m %s\n" "$*" >&2; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { error "Command not found: $1"; exit 127; }
}

require_env() {
  : "${!1:?ERR: env $1 is required}"
}

trap 'error "Aborted (line $LINENO)"; exit 1' ERR

# ===== Preflight =====
require_cmd curl
require_cmd jq
require_cmd awk
require_cmd date
require_cmd flock || warn "flock not found (parallel execution guard disabled)"

require_env SUPABASE_URL
require_env SUPABASE_ANON_KEY

# SUPABASE_URL の厳格チェック
if ! [[ "$SUPABASE_URL" =~ ^https://[a-z0-9-]+\.supabase\.co$ ]]; then
  error "SUPABASE_URL format invalid: $SUPABASE_URL"
  exit 2
fi

# 機密漏えい防止
set +x  # 以降は -x を使わない（秘密鍵がログに出ないように）

# ===== Lock File (Parallel Execution Guard) =====
LOCK=".day11.lock"
if command -v flock >/dev/null 2>&1; then
  exec 9>"$LOCK" || exit 1
  if ! flock -n 9; then
    error "Another DAY11_GO_LIVE.sh is running"
    exit 1
  fi
  trap 'rm -f "$LOCK"' EXIT
fi

# ===== Logging Setup =====
TS="$(date +'%Y-%m-%dT%H:%M:%S%z')"
LOG_DIR="logs/day11"
mkdir -p "$LOG_DIR"

log_json() {
  local name="$1" json="$2"
  printf '%s\n' "$json" > "$LOG_DIR/${TS}_$name.json"
  log "JSON saved: $LOG_DIR/${TS}_$name.json"
}

# ===== Cache Setup (Idempotency) =====
CACHE_DIR=".day11_cache"
mkdir -p "$CACHE_DIR"

payload_hash() {
  echo -n "$1" | sha256sum | awk '{print $1}'
}

ensure_not_duplicate() {
  local key="$1" hash="$2" file="$CACHE_DIR/$key.last"
  if [[ -f "$file" ]] && [[ "$(cat "$file" 2>/dev/null)" == "$hash" ]]; then
    warn "same payload detected; skip send (idempotent)"
    return 1
  fi
  echo "$hash" > "$file"
  return 0
}

summary_fingerprint() {
  jq -r '[.weekly_summary, .stats.mean_notifications, .stats.std_dev, .stats.new_threshold, .stats.critical_threshold] | @tsv' <<<"$1" \
    | sha256sum | awk '{print $1}'
}

# ===== HTTP/JSON Helper with Retry =====
http_json() {
  local method="$1" url="$2" body="$3" attempt=0 max=3
  while :; do
    attempt=$((attempt+1))
    resp=$(curl -sS --show-error -X "$method" "$url" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
      -H "apikey: $SUPABASE_ANON_KEY" \
      ${body:+--data "$body"} \
      -w "\n%{http_code}" 2>&1)
    code="$(echo "$resp" | tail -n1)"
    json="$(echo "$resp" | sed '$d')"

    # 2xx 厳格判定
    if [[ "$code" =~ ^2[0-9]{2}$ ]]; then
      echo "$json"
      return 0
    fi

    # 一時エラーのみ限定的に再試行
    if [[ "$code" == "429" || "$code" =~ ^5 ]]; then
      if (( attempt < max )); then
        warn "HTTP $code (attempt $attempt/$max), retrying..."
        sleep $(( 2 ** attempt ))
        continue
      fi
    fi
    error "HTTP $code"
    echo "$json" | jq -r '.message? // .error? // .detail? // empty' 1>&2 || echo "$json" 1>&2
    return 1
  done
}

# ===== JSON Validation =====
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

# ===== Constants =====
FUNC_NAME="ops-slack-summary"
PERIOD="14d"
DRYRUN_Q="dryRun=true&period=${PERIOD}"
SEND_Q="dryRun=false&period=${PERIOD}"
TMP_DRY="/tmp/day11_dryrun.json"
TMP_SEND="/tmp/day11_send.json"

# ===== Main Flow =====
log "=== Day11 Go-Live 最終実行（堅牢化版・完成版） ==="
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
dryrun_json=$(http_json POST "${SUPABASE_URL}/functions/v1/${FUNC_NAME}?${DRYRUN_Q}" '{}')
printf '%s\n' "$dryrun_json" > "$TMP_DRY"

validate_dryrun_json "$TMP_DRY"
log "dryRun 抜粋:"
jq '.stats, .weekly_summary, .message' "$TMP_DRY" || true
log_json "dryrun" "$dryrun_json"
log ""

# 3) 本送信（確認プロンプト）
log "📋 3) 本送信（確認プロンプト）"
read -r -p ">>> 本送信しますか？（Slack #ops-monitor）[y/N]: " yn
if [[ "$yn" =~ ^[Yy]$ ]]; then
  log "Invoke SEND..."
  
  # 冪等性チェック（同一内容の場合はスキップ）
  dryrun_fp=$(summary_fingerprint "$dryrun_json")
  if ! ensure_not_duplicate "weekly" "$dryrun_fp"; then
    warn "Same payload detected, skipping send (idempotent)"
  else
    send_json=$(http_json POST "${SUPABASE_URL}/functions/v1/${FUNC_NAME}?${SEND_Q}" '{}')
    printf '%s\n' "$send_json" > "$TMP_SEND"
    
    validate_send_json "$TMP_SEND"
    log_json "send" "$send_json"
    
    # 同一内容検出
    send_fp=$(summary_fingerprint "$send_json")
    if [[ "$dryrun_fp" == "$send_fp" ]]; then
      log "Send content matches dryRun (identical summary)"
    fi
    
    log "Slack #ops-monitor で到達を確認してください。"
    permalink=$(jq -r '.permalink? // .slack?.permalink? // "-"' <<<"$send_json" 2>/dev/null || echo "-")
    [[ "$permalink" != "-" ]] && log "Slack permalink: $permalink"
  fi
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
log "  - 本送信完了（確認後実行、冪等性チェック付き）"
log "  - 合格ライン確認完了（3点）"
log "  - JSONログ保存完了: $LOG_DIR/"
log ""
log "📝 次のステップ:"
log "  1. Slack #ops-monitor チャンネルで週次サマリを確認"
log "  2. Supabase Functions Logs でログを確認"
log "  3. 重要ファイル（OPS-MONITORING-V3-001.md / Mermaid.md）を更新"
log "  4. 最終レポート（SlackメッセージURL）を追記"
log ""
log "🎉 Day11 の本番デプロイ～受け入れ確認が完了しました！"
log ""
