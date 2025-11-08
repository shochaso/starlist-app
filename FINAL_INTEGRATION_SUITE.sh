#!/usr/bin/env bash
# ====================================================================
# STARLIST Final Integration Suite (Day11統合 + 監査票自動生成・強化版)
# - 実行順: Preflight → DAY11_GO_LIVE.sh → 監査票作成 → 監査用フォルダ整備
# - 依存: jq, git, date, awk, bash>=5 / Asia/Tokyo 固定
# - 機微情報は出力しません
# ====================================================================

set -Eeuo pipefail

# --- 基本設定 ---
: "${TZ:=Asia/Tokyo}"
export TZ
NOW_JST="$(date +"%Y-%m-%d %H:%M:%S %Z")"
RUN_DATE="$(date +%Y-%m-%d)"
RUN_WEEK="$(date +%G-W%V)"   # ISO週

# --- 前提チェック（Fail-fast） ---
require_env() { 
  for k in "$@"; do 
    [[ -n "${!k-}" ]] || { echo "ERROR: env $k is missing"; exit 11; }
  done
}

require_bin() { 
  for b in "$@"; do 
    command -v "$b" >/dev/null || { echo "ERROR: $b not found"; exit 12; }
  done
}

require_env SUPABASE_URL SUPABASE_ANON_KEY
require_bin jq sed awk grep date

# Supabase / Stripe は任意機能で使うため存在すれば使う
if command -v supabase >/dev/null; then USE_SUPABASE=1; else USE_SUPABASE=0; fi
if command -v stripe   >/dev/null; then USE_STRIPE=1;   else USE_STRIPE=0;   fi

PROJECT_REF="$(echo "$SUPABASE_URL" | sed -n 's#https://\([a-z0-9]\{20\}\)\.supabase\.co#\1#p')"
[[ ${#PROJECT_REF} -eq 20 ]] || { echo "ERROR: Invalid SUPABASE_URL (project-ref 20 chars not found)"; exit 13; }

echo "[PRECHECK] $NOW_JST / ref=$PROJECT_REF / stripe=$USE_STRIPE / supabase=$USE_SUPABASE"

# 機密は出さない
set +x

# --- paths ---
ROOT="$(pwd)"
CACHE_DIR="${ROOT}/.day11_cache"
LOG_DIR="${ROOT}/logs/day11"
REPORT_DIR="${ROOT}/docs/reports"
mkdir -p "$CACHE_DIR" "$LOG_DIR" "$REPORT_DIR"

COMMIT="$(git rev-parse --short HEAD || echo 'unknown')"
RUN_AT="$(date +'%Y-%m-%dT%H:%M:%S%z')"

: "${AUDIT_LOOKBACK_HOURS:=48}"

# --- util ---
info(){ printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
warn(){ printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
err(){  printf "\033[1;31m[ERR ]\033[0m %s\n"  "$*" 1>&2; }

TS_ISO(){ date +'%Y-%m-%dT%H:%M:%S%z'; }
DAY(){ date +'%Y-%m-%d'; }
WEEK(){ date +'%G-W%V'; }

PROJECT_REF_FROM_URL(){
  basename "${SUPABASE_URL}" .supabase.co
}

get_permalink() {
  for f in ".day11_cache/permalink.txt" "docs/reports/${RUN_DATE}/DAY11_PERMALINK.txt" "logs/day11/permalink.txt"; do
    [[ -s "$f" ]] && { cat "$f"; return 0; }
  done
  grep -rhoE "https://.*slack.com/archives/[A-Z0-9]+/p[0-9]+" logs/day11 2>/dev/null | head -n1 || true
}

# --- 1) Go-Live 実行 ---
info "Run DAY11_GO_LIVE.sh …"
chmod +x ./DAY11_GO_LIVE.sh
./DAY11_GO_LIVE.sh

# --- 2) 監査素材の収集 ---
info "Collect artifacts for audit …"

# 最新ログファイル（dryrun/send）を検出
latest_json() { ls -1t "${LOG_DIR}"/"*_${1}.json" 2>/dev/null | head -n1 || true; }
DRY_JSON_FILE="$(latest_json dryrun)"
SEND_JSON_FILE="$(latest_json send)"

if [[ -z "$DRY_JSON_FILE" || -z "$SEND_JSON_FILE" ]]; then
  err "could not find latest dryrun/send json under ${LOG_DIR}"
  exit 1
fi

# Day11 JSONログの自動マージ
mkdir -p tmp/audit_day11
jq -s 'flatten' logs/day11/*_dryrun.json 2>/dev/null > tmp/audit_day11/dryrun.json || echo "[]" > tmp/audit_day11/dryrun.json
jq -s 'flatten' logs/day11/*_send.json   2>/dev/null > tmp/audit_day11/send.json   || echo "[]" > tmp/audit_day11/send.json

# Permalink（キャッシュ優先→ログから抽出）
PERMALINK_FILE="${CACHE_DIR}/permalink.txt"
if [[ -s "$PERMALINK_FILE" ]]; then
  PERMALINK="$(cat "$PERMALINK_FILE" || true)"
else
  PERMALINK="$(get_permalink)"
  [[ -n "$PERMALINK" ]] && printf '%s\n' "$PERMALINK" > "$PERMALINK_FILE" || true
fi
[[ -z "$PERMALINK" ]] && warn "permalink not found; please attach Slack screenshot to the report."

# 合格ラインの自動判定（簡易）
OK_DRY="$(jq -e '.ok==true and (.stats|type=="object") and (.weekly_summary|type=="object") and (.message|type=="string") and (.stats.std_dev|numbers and .>=0) and (.stats.new_threshold|numbers and .>=0) and (.stats.critical_threshold|numbers and .>=0)' "$DRY_JSON_FILE" >/dev/null && echo OK || echo NG)"
OK_SEND="$(jq -e '.ok==true and (.stats|type=="object") and (.weekly_summary|type=="object") and (.message|type=="string")' "$SEND_JSON_FILE" >/dev/null && echo OK || echo NG)"

# --- 3) Edge Logs収集 ---
mkdir -p tmp/audit_edge
if [[ "$USE_SUPABASE" -eq 1 ]]; then
  EDGE_FUNCS=("ops-slack-summary" "ops-summary-email")
  for fn in "${EDGE_FUNCS[@]}"; do
    info "Collecting Edge logs for $fn..."
    supabase functions logs --project-ref "$PROJECT_REF" --function-name "$fn" --since "${AUDIT_LOOKBACK_HOURS} hours" \
      > "tmp/audit_edge/${fn}.log" 2>&1 || warn "Failed to collect logs for $fn"
  done
fi

# --- 4) Stripe Events収集（Pricing監査用） ---
if [[ "$USE_STRIPE" -eq 1 ]]; then
  mkdir -p tmp/audit_stripe
  SINCE_UNIX="$(date -u +%s -d "-${AUDIT_LOOKBACK_HOURS} hours" 2>/dev/null || date -u -v-${AUDIT_LOOKBACK_HOURS}H +%s 2>/dev/null || echo "")"
  STRIPE_TYPES="checkout.session.completed payment_intent.succeeded customer.subscription.created customer.subscription.updated"
  
  info "Collecting Stripe events..."
  stripe events list --limit 100 ${SINCE_UNIX:+--created "gte=${SINCE_UNIX}"} \
    $(for t in $STRIPE_TYPES; do printf -- "--type %q " "$t"; done) -j \
    > tmp/audit_stripe/events_raw.json 2>&1 || echo '{"data":[]}' > tmp/audit_stripe/events_raw.json

  # Starlist対象抽出
  jq '
    .data
    | map(select(
      ( .data.object.metadata.app // "" ) == "starlist"
      or ( .data.object.currency // "" ) == "jpy"
      or ( .data.object.lines.data[0].price.id // "" | startswith("price_") )
      or ( .type | contains("checkout.session") )
    ))
  ' tmp/audit_stripe/events_raw.json > tmp/audit_stripe/events_starlist.json 2>/dev/null || echo "[]" > tmp/audit_stripe/events_starlist.json
fi

# --- 5) DB監査（Pricing用） ---
if [[ -f sql/pricing_audit.sql && "$USE_SUPABASE" -eq 1 ]]; then
  info "Running DB audit for Pricing..."
  supabase db query < sql/pricing_audit.sql > tmp/audit_stripe/db_pricing_audit.txt 2>&1 || warn "DB audit failed"
fi

# --- 6) Day11監査票生成 ---
DAY11_REPORT="docs/reports/${RUN_DATE}_DAY11_AUDIT_${RUN_WEEK}.md"
info "Generate Day11 audit report: ${DAY11_REPORT}"

cat > "$DAY11_REPORT" <<EOF
# Day11 監査票（自動生成）

- 生成: ${NOW_JST}
- 範囲: 過去 ${AUDIT_LOOKBACK_HOURS}h
- Supabase ref: ${PROJECT_REF}
- Slack: ${PERMALINK:-未取得}

## 1. 件数サマリ

\`\`\`json
$(jq -n --slurpfile d tmp/audit_day11/dryrun.json --slurpfile s tmp/audit_day11/send.json \
  '{dryRun: ($d[0]|length), send: ($s[0]|length)}' 2>/dev/null || echo '{"dryRun": 0, "send": 0}')
\`\`\`

## 2. エッジログ（末尾）

\`\`\`text
$(for f in tmp/audit_edge/*.log 2>/dev/null; do [[ -s "$f" ]] || continue; echo "== $(basename "$f") =="; tail -n 120 "$f"; echo; done || echo "Edge logs not available")
\`\`\`

## 3. 失敗/警告抽出（send.json）

\`\`\`json
$(jq '[.[] | select((.status//200) != 200 or (.ok//true) != true)] | .[0:20]' tmp/audit_day11/send.json 2>/dev/null || echo "[]")
\`\`\`

## 4. チェックリスト

- [ ] Slack Permalink 取得済み
- [ ] エッジログにERRORなし
- [ ] send/dryRun の件数に極端な乖離なし
- [ ] dryRun JSON 妥当性: ${OK_DRY}
- [ ] 本送信 JSON 妥当性: ${OK_SEND}

## 5. 証跡リンク/ファイル

- dryRun JSON: \`${DRY_JSON_FILE}\`
- send JSON: \`${SEND_JSON_FILE}\`
- Edge logs: \`tmp/audit_edge/\`
- 参考: \`.day11_cache/weekly.last\`（冪等性キー）

---

**監査完了日時**: ${NOW_JST}  
**監査者**: $(whoami)  
**承認**: <approver>
EOF

info "Day11 audit report created: $DAY11_REPORT"

# --- 7) Pricing監査票生成 ---
if [[ "$USE_STRIPE" -eq 1 ]]; then
  PRICING_REPORT="docs/reports/${RUN_DATE}_PRICING_AUDIT.md"
  STAR_EVENTS="tmp/audit_stripe/events_starlist.json"
  info "Generate Pricing audit report: ${PRICING_REPORT}"

  cat > "$PRICING_REPORT" <<EOF
# Pricing 監査票（自動生成）

- 生成: ${NOW_JST}
- 範囲: 過去 ${AUDIT_LOOKBACK_HOURS}h
- Supabase ref: ${PROJECT_REF}

## 1. Stripe 抽出（代表10件）

\`\`\`json
$(jq '.[0:10] | map({id, type, created, amount_total: (.data.object.amount_total // .data.object.amount // null), customer: (.data.object.customer // null)})' "$STAR_EVENTS" 2>/dev/null || echo "[]")
\`\`\`

## 2. DB 監査（整数/範囲/重複/参照整合）

\`\`\`text
$(sed -n '1,200p' tmp/audit_stripe/db_pricing_audit.txt 2>/dev/null || echo "No DB audit output")
\`\`\`

## 3. チェックリスト（基準）

- [ ] 整数性: 0件
- [ ] 範囲逸脱: 0件（学生100–9999 / 成人300–29999）
- [ ] 重複: 0件
- [ ] 参照不整合: 0件

## 4. 証跡リンク/ファイル

- Stripe Events: \`tmp/audit_stripe/events_starlist.json\`
- DB Audit: \`tmp/audit_stripe/db_pricing_audit.txt\`

---

**監査完了日時**: ${NOW_JST}  
**監査者**: $(whoami)  
**承認**: <approver>
EOF

  info "Pricing audit report created: $PRICING_REPORT"
fi

info "Final Integration Suite completed."
