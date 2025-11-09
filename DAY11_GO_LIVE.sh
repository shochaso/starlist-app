#!/usr/bin/env bash
# ====================================================================
# STARLIST Day11 Go-Live Runner (final hardened)
# 目的: Slack週次サマリの dryRun→本送信→検証→監査保存 を一気通貫で実施
# 特徴: 失敗即停止 / 429・5xxのみ指数バックオフ再試行 / 冪等性 / 並列実行ガード
# タイムゾーン: Asia/Tokyo
# ====================================================================

set -Eeuo pipefail
export TZ="Asia/Tokyo"

# --- signal & error handling ---------------------------------------------------
on_err() {
  local exit_code=$?
  echo -e "\033[1;31m[ERR ]\033[0m line=${BASH_LINENO[0]} status=$exit_code"
  exit "$exit_code"
}
trap on_err ERR

# --- paths & dirs --------------------------------------------------------------
ROOT="$(pwd)"
CACHE_DIR="${ROOT}/.day11_cache"
LOG_DIR="${ROOT}/logs/day11"
LOCK_FILE="${ROOT}/.day11.lock"
mkdir -p "$CACHE_DIR" "$LOG_DIR"

# --- logging helpers -----------------------------------------------------------
TS() { date +'%Y-%m-%dT%H:%M:%S%z'; }
info(){ printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
warn(){ printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
err(){  printf "\033[1;31m[ERR ]\033[0m %s\n"  "$*" 1>&2; }

log_json() { # name, json
  local name="$1"; shift
  local json="$*"
  printf '%s\n' "$json" > "${LOG_DIR}/$(TS)_${name}.json"
}

# --- prerequisites -------------------------------------------------------------
require_cmd() { command -v "$1" >/dev/null 2>&1 || { err "$1 not found"; exit 127; }; }
require_env() { : "${!1:?ERR: env $1 is required}"; }

require_cmd curl; require_cmd jq; require_cmd awk; require_cmd date; require_cmd flock
require_env SUPABASE_URL
require_env SUPABASE_ANON_KEY

# URL厳格検証（<20桁ref>.supabase.co）
if ! [[ "$SUPABASE_URL" =~ ^https://[a-z0-9]{20}\.supabase\.co$ ]]; then
  err "SUPABASE_URL format invalid: $SUPABASE_URL"
  exit 2
fi

# 機密を出力しない
set +x

# --- parallel guard ------------------------------------------------------------
exec 9>"$LOCK_FILE" || { err "cannot open lock"; exit 1; }
if ! flock -n 9; then
  err "another DAY11_GO_LIVE.sh is running"
  exit 1
fi
cleanup(){ rm -f "$LOCK_FILE"; }
trap cleanup EXIT

# --- http helper with limited retries -----------------------------------------
http_json() {
  local method="$1" url="$2" body="${3:-}" attempt=0 max=3
  local resp code json
  while :; do
    attempt=$((attempt+1))
    resp="$(curl -sS --show-error -X "$method" "$url" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
      -H "apikey: $SUPABASE_ANON_KEY" \
      ${body:+ --data "$body"} \
      -w "\n%{http_code}")" || true

    code="$(echo "$resp" | tail -n1)"
    json="$(echo "$resp" | sed '$d')"

    # 2xx 成功
    if [[ "$code" =~ ^2[0-9]{2}$ ]]; then
      echo "$json"
      return 0
    fi

    # 一時障害のみ指数バックオフ再試行
    if [[ "$code" == "429" || "$code" =~ ^5 ]]; then
      if (( attempt < max )); then
        warn "HTTP $code (attempt $attempt/$max), retrying..."
        sleep $(( 2 ** attempt ))
        continue
      fi
    fi

    # 恒久エラーは即停止
    err "HTTP $code"
    jq -r '.message? // .error? // .detail? // empty' <<<"$json" || true
    return 1
  done
}

# --- validators ----------------------------------------------------------------
validate_stats_block() {
  jq -e '
    .ok == true
    and (.stats|type=="object")
    and (.weekly_summary|type=="object")
    and (.message|type=="string")
    and (.stats.mean_notifications | numbers)
    and (.stats.std_dev | numbers and . >= 0)
    and (.stats.new_threshold | numbers and . >= 0)
    and (.stats.critical_threshold | numbers and . >= 0)
    and (.stats.critical_threshold >= .stats.new_threshold)
  ' >/dev/null
}

summary_fingerprint() { # summarize dryRun/send content for equality check
  jq -r '[.weekly_summary, .stats.mean_notifications, .stats.std_dev, .stats.new_threshold, .stats.critical_threshold] | @tsv' | \
  sha256sum | awk '{print $1}'
}

payload_hash() { sha256sum | awk '{print $1}'; }

ensure_not_duplicate() {
  local key="$1" hash="$2" file="${CACHE_DIR}/${key}.last"
  if [[ -f "$file" && "$(cat "$file")" == "$hash" ]]; then
    warn "same payload detected; skip send (idempotent)"
    return 1
  fi
  echo "$hash" > "$file"
  return 0
}

# --- main ----------------------------------------------------------------------
API="${SUPABASE_URL}/functions/v1/ops-slack-summary"

info "Preflight OK. Starting Day11 Go-Live…"

# 1) dryRun
info "dryRun…"
DRY_JSON="$(http_json POST "${API}?dryRun=true&period=14d" '{}')"
validate_stats_block <<<"$DRY_JSON" || { err "dryRun JSON invalid"; exit 1; }
log_json "dryrun" "$DRY_JSON"
info "dryRun validated: $(jq -r '.weekly_summary | tostring' <<<"$DRY_JSON" | head -c 120)…"

# 2) 本送信の冪等検査（dryRun内容の指紋）
DRY_FP="$(summary_fingerprint <<<"$DRY_JSON")"
if ! ensure_not_duplicate "weekly" "$DRY_FP"; then
  info "idempotent guard: send skipped（same as previous）"
  exit 0
fi

# 3) 本送信
read -r -p ">>> 本送信しますか？（Slack #ops-monitor）[y/N]: " yn
if [[ ! "$yn" =~ ^[Yy]$ ]]; then
  warn "本送信をスキップしました（dryRunのみ）。"
  exit 0
fi

info "send…"
SEND_JSON="$(http_json POST "${API}?dryRun=false&period=14d" '{}')"
validate_stats_block <<<"$SEND_JSON" || { err "send JSON invalid"; exit 1; }
log_json "send" "$SEND_JSON"

# 4) dryRun と send の差分チェック（内容が同一なら注記）
SEND_FP="$(summary_fingerprint <<<"$SEND_JSON")"
if [[ "$DRY_FP" == "$SEND_FP" ]]; then
  warn "note: send content equals dryRun (no material change)"
fi

# 5) Slackへの到達確認（レスポンスの候補フィールド）
PERMALINK="$(jq -r '.permalink? // .slack?.permalink? // .message_url? // empty' <<<"$SEND_JSON")"
if [[ -z "$PERMALINK" ]]; then
  warn "permalink not present in response; attach UI screenshot manually to final report"
else
  info "Slack permalink: $PERMALINK"
  echo "$PERMALINK" > "${CACHE_DIR}/permalink.txt"
fi

# 6) 終了報告
info "Day11 Go-Live completed successfully."
exit 0

# STARLIST Day11 Go-Live Runner (final hardened)
# 目的: Slack週次サマリの dryRun→本送信→検証→監査保存 を一気通貫で実施
# 特徴: 失敗即停止 / 429・5xxのみ指数バックオフ再試行 / 冪等性 / 並列実行ガード
# タイムゾーン: Asia/Tokyo
# ====================================================================

set -Eeuo pipefail
export TZ="Asia/Tokyo"

# --- signal & error handling ---------------------------------------------------
on_err() {
  local exit_code=$?
  echo -e "\033[1;31m[ERR ]\033[0m line=${BASH_LINENO[0]} status=$exit_code"
  exit "$exit_code"
}
trap on_err ERR

# --- paths & dirs --------------------------------------------------------------
ROOT="$(pwd)"
CACHE_DIR="${ROOT}/.day11_cache"
LOG_DIR="${ROOT}/logs/day11"
LOCK_FILE="${ROOT}/.day11.lock"
mkdir -p "$CACHE_DIR" "$LOG_DIR"

# --- logging helpers -----------------------------------------------------------
TS() { date +'%Y-%m-%dT%H:%M:%S%z'; }
info(){ printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
warn(){ printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
err(){  printf "\033[1;31m[ERR ]\033[0m %s\n"  "$*" 1>&2; }

log_json() { # name, json
  local name="$1"; shift
  local json="$*"
  printf '%s\n' "$json" > "${LOG_DIR}/$(TS)_${name}.json"
}

# --- prerequisites -------------------------------------------------------------
require_cmd() { command -v "$1" >/dev/null 2>&1 || { err "$1 not found"; exit 127; }; }
require_env() { : "${!1:?ERR: env $1 is required}"; }

require_cmd curl; require_cmd jq; require_cmd awk; require_cmd date; require_cmd flock
require_env SUPABASE_URL
require_env SUPABASE_ANON_KEY

# URL厳格検証（<20桁ref>.supabase.co）
if ! [[ "$SUPABASE_URL" =~ ^https://[a-z0-9]{20}\.supabase\.co$ ]]; then
  err "SUPABASE_URL format invalid: $SUPABASE_URL"
  exit 2
fi

# 機密を出力しない
set +x

# --- parallel guard ------------------------------------------------------------
exec 9>"$LOCK_FILE" || { err "cannot open lock"; exit 1; }
if ! flock -n 9; then
  err "another DAY11_GO_LIVE.sh is running"
  exit 1
fi
cleanup(){ rm -f "$LOCK_FILE"; }
trap cleanup EXIT

# --- http helper with limited retries -----------------------------------------
http_json() {
  local method="$1" url="$2" body="${3:-}" attempt=0 max=3
  local resp code json
  while :; do
    attempt=$((attempt+1))
    resp="$(curl -sS --show-error -X "$method" "$url" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
      -H "apikey: $SUPABASE_ANON_KEY" \
      ${body:+ --data "$body"} \
      -w "\n%{http_code}")" || true

    code="$(echo "$resp" | tail -n1)"
    json="$(echo "$resp" | sed '$d')"

    # 2xx 成功
    if [[ "$code" =~ ^2[0-9]{2}$ ]]; then
      echo "$json"
      return 0
    fi

    # 一時障害のみ指数バックオフ再試行
    if [[ "$code" == "429" || "$code" =~ ^5 ]]; then
      if (( attempt < max )); then
        warn "HTTP $code (attempt $attempt/$max), retrying..."
        sleep $(( 2 ** attempt ))
        continue
      fi
    fi

    # 恒久エラーは即停止
    err "HTTP $code"
    jq -r '.message? // .error? // .detail? // empty' <<<"$json" || true
    return 1
  done
}

# --- validators ----------------------------------------------------------------
validate_stats_block() {
  jq -e '
    .ok == true
    and (.stats|type=="object")
    and (.weekly_summary|type=="object")
    and (.message|type=="string")
    and (.stats.mean_notifications | numbers)
    and (.stats.std_dev | numbers and . >= 0)
    and (.stats.new_threshold | numbers and . >= 0)
    and (.stats.critical_threshold | numbers and . >= 0)
    and (.stats.critical_threshold >= .stats.new_threshold)
  ' >/dev/null
}

summary_fingerprint() { # summarize dryRun/send content for equality check
  jq -r '[.weekly_summary, .stats.mean_notifications, .stats.std_dev, .stats.new_threshold, .stats.critical_threshold] | @tsv' | \
  sha256sum | awk '{print $1}'
}

payload_hash() { sha256sum | awk '{print $1}'; }

ensure_not_duplicate() {
  local key="$1" hash="$2" file="${CACHE_DIR}/${key}.last"
  if [[ -f "$file" && "$(cat "$file")" == "$hash" ]]; then
    warn "same payload detected; skip send (idempotent)"
    return 1
  fi
  echo "$hash" > "$file"
  return 0
}

# --- main ----------------------------------------------------------------------
API="${SUPABASE_URL}/functions/v1/ops-slack-summary"

info "Preflight OK. Starting Day11 Go-Live…"

# 1) dryRun
info "dryRun…"
DRY_JSON="$(http_json POST "${API}?dryRun=true&period=14d" '{}')"
validate_stats_block <<<"$DRY_JSON" || { err "dryRun JSON invalid"; exit 1; }
log_json "dryrun" "$DRY_JSON"
info "dryRun validated: $(jq -r '.weekly_summary | tostring' <<<"$DRY_JSON" | head -c 120)…"

# 2) 本送信の冪等検査（dryRun内容の指紋）
DRY_FP="$(summary_fingerprint <<<"$DRY_JSON")"
if ! ensure_not_duplicate "weekly" "$DRY_FP"; then
  info "idempotent guard: send skipped（same as previous）"
  exit 0
fi

# 3) 本送信
read -r -p ">>> 本送信しますか？（Slack #ops-monitor）[y/N]: " yn
if [[ ! "$yn" =~ ^[Yy]$ ]]; then
  warn "本送信をスキップしました（dryRunのみ）。"
  exit 0
fi

info "send…"
SEND_JSON="$(http_json POST "${API}?dryRun=false&period=14d" '{}')"
validate_stats_block <<<"$SEND_JSON" || { err "send JSON invalid"; exit 1; }
log_json "send" "$SEND_JSON"

# 4) dryRun と send の差分チェック（内容が同一なら注記）
SEND_FP="$(summary_fingerprint <<<"$SEND_JSON")"
if [[ "$DRY_FP" == "$SEND_FP" ]]; then
  warn "note: send content equals dryRun (no material change)"
fi

# 5) Slackへの到達確認（レスポンスの候補フィールド）
PERMALINK="$(jq -r '.permalink? // .slack?.permalink? // .message_url? // empty' <<<"$SEND_JSON")"
if [[ -z "$PERMALINK" ]]; then
  warn "permalink not present in response; attach UI screenshot manually to final report"
else
  info "Slack permalink: $PERMALINK"
  echo "$PERMALINK" > "${CACHE_DIR}/permalink.txt"
fi

# 6) 終了報告
info "Day11 Go-Live completed successfully."
exit 0
