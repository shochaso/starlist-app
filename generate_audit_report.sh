#!/usr/bin/env bash
# 監査票自動生成スクリプト（permalink・Edgeログ・Stripeイベントを集約・強化版）
# Usage: ./generate_audit_report.sh [--date YYYYMMDD] [--lookback HOURS]

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

require_cmd jq
require_cmd date
require_env SUPABASE_URL

# ===== Setup =====
: "${AUDIT_LOOKBACK_HOURS:=36}"         # 必要に応じて延長
: "${TZ:=Asia/Tokyo}"                   # 監査票はJSTで固める
export TZ

AUDIT_SINCE_ISO="$(date -u -d "-${AUDIT_LOOKBACK_HOURS} hours" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -v-${AUDIT_LOOKBACK_HOURS}H +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "")"
RUN_DATE_JST="$(TZ="$TZ" date +"%Y-%m-%d %H:%M:%S %Z")"

DATE_DIR="${1:-$(date +'%Y%m%d')}"
if [[ "$DATE_DIR" == "--date" ]]; then
  DATE_DIR="${2:-$(date +'%Y%m%d')}"
fi
if [[ "$DATE_DIR" == "--lookback" ]]; then
  AUDIT_LOOKBACK_HOURS="${2:-36}"
  DATE_DIR="$(date +'%Y%m%d')"
fi

TS="$(date +'%Y-%m-%dT%H:%M:%S%z')"
REPORTS_DIR="docs/reports/${DATE_DIR}"
TMP_DIR="tmp/audit_day11"
STRIPE_TMP_DIR="tmp/audit_stripe"
EDGE_TMP_DIR="tmp/audit_edge"
mkdir -p "$REPORTS_DIR" "$TMP_DIR" "$STRIPE_TMP_DIR" "$EDGE_TMP_DIR"

AUDIT_REPORT="${REPORTS_DIR}/AUDIT_REPORT_${TS}.md"

# ===== Helper Functions =====
checksum() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" 2>/dev/null | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" 2>/dev/null | awk '{print $1}'
  else
    echo "n/a"
  fi
}

get_permalink() {
  for f in ".day11_cache/permalink.txt" "docs/reports/${DATE_DIR}/DAY11_PERMALINK.txt" "logs/day11/permalink.txt"; do
    [[ -s "$f" ]] && { cat "$f"; return 0; }
  done
  # JSONログからURLっぽいものを抽出（保険）
  grep -rhoE "https://.*slack.com/archives/[A-Z0-9]+/p[0-9]+" logs/day11 2>/dev/null | head -n1 || true
}

collect_edge_logs() {
  local project_ref="${SUPABASE_PROJECT_REF:-$(basename "$SUPABASE_URL" .supabase.co)}"
  local edge_funcs=("ops-slack-summary" "ops-summary-email")
  
  if ! command -v supabase >/dev/null 2>&1; then
    warn "Supabase CLI not found, skipping Edge logs"
    return 0
  fi
  
  for fn in "${edge_funcs[@]}"; do
    log "Collecting Edge logs for $fn..."
    supabase functions logs --project-ref "$project_ref" --function-name "$fn" --since "$AUDIT_LOOKBACK_HOURS hours" \
      > "${EDGE_TMP_DIR}/${fn}.log" 2>&1 || warn "Failed to collect logs for $fn"
  done
}

collect_stripe_events() {
  if ! command -v stripe >/dev/null 2>&1; then
    warn "Stripe CLI not found, skipping Stripe events"
    return 0
  fi
  
  : "${STRIPE_EVENT_TYPES:=checkout.session.completed payment_intent.succeeded customer.subscription.updated}"
  : "${STRIPE_LOOKBACK_SEC:=$((AUDIT_LOOKBACK_HOURS*3600))}"
  
  local created_since=$(date -u +%s --date="-${AUDIT_LOOKBACK_HOURS} hours" 2>/dev/null || date -u -v-${AUDIT_LOOKBACK_HOURS}H +%s 2>/dev/null || echo "")
  
  log "Collecting Stripe events..."
  stripe events list \
    --limit 100 \
    ${created_since:+--created "gte=$created_since"} \
    -j > "${STRIPE_TMP_DIR}/events.json" 2>&1 || warn "Failed to collect Stripe events"
  
  # Starlist対象のみ抽出（メタデータ/価格ID/通貨など任意条件）
  if [ -f "${STRIPE_TMP_DIR}/events.json" ]; then
    jq '
      .data
      | map(select(
          ( .data.object.metadata.app // "" ) == "starlist"
          or ( .data.object.currency // "" ) == "jpy"
          or ( .type | contains("checkout.session") )
        ))
    ' "${STRIPE_TMP_DIR}/events.json" > "${STRIPE_TMP_DIR}/events_starlist.json" 2>/dev/null || echo "[]" > "${STRIPE_TMP_DIR}/events_starlist.json"
  fi
}

merge_day11_logs() {
  log "Merging Day11 JSON logs..."
  jq -s 'flatten' logs/day11/*_dryrun.json 2>/dev/null > "${TMP_DIR}/dryrun_merged.json" || echo "[]" > "${TMP_DIR}/dryrun_merged.json"
  jq -s 'flatten' logs/day11/*_send.json   2>/dev/null > "${TMP_DIR}/send_merged.json"   || echo "[]" > "${TMP_DIR}/send_merged.json"
}

# ===== Collect Data =====
log "=== 監査票自動生成（強化版） ==="
log "監査範囲: 過去 ${AUDIT_LOOKBACK_HOURS}h（since: ${AUDIT_SINCE_ISO:-N/A}, UTC）"
log ""

# 1) Permalink収集
log "📋 1) Permalink収集"
PERMALINK="$(get_permalink)"
if [ -n "$PERMALINK" ]; then
  log "✅ Permalink found: $PERMALINK"
else
  warn "Permalink not found"
fi
log ""

# 2) Day11 JSON Logs収集・マージ
log "📋 2) Day11 JSON Logs収集・マージ"
merge_day11_logs
DRYRUN_SUM="$(checksum "${TMP_DIR}/dryrun_merged.json")"
SEND_SUM="$(checksum "${TMP_DIR}/send_merged.json")"
log "✅ Day11 logs merged"
log ""

# 3) Edge Function Logs収集
log "📋 3) Edge Function Logs収集"
collect_edge_logs
EDGE_LIST="$(ls -1 ${EDGE_TMP_DIR}/*.log 2>/dev/null | xargs -I{} basename {} | paste -sd ',' || echo "")"
log ""

# 4) Stripe Events収集
log "📋 4) Stripe Events収集"
collect_stripe_events
STRIPE_SUM="$(checksum "${STRIPE_TMP_DIR}/events_starlist.json")"
log ""

# ===== Generate Audit Report =====
log "📋 5) 監査票生成"

# Front-Matter生成
REPORT_ID="audit_${RUN_DATE}_${RUN_WEEK}_$(date +%s)"
GIT_SHA="$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")"
EDGE_LOG_LIST="$(ls -1 ${EDGE_TMP_DIR}/*.log 2>/dev/null | xargs -I{} basename {} | paste -sd ',' || echo "")"

# 異常検知（p95 latency）
METRICS_JSON="${TMP_DIR}/metrics.json"
if [ -f "${TMP_DIR}/send.json" ] && [ "$(jq 'length' "${TMP_DIR}/send.json" 2>/dev/null || echo 0)" -gt 0 ]; then
  jq '
    def p(v; n): (v|sort)[(length*n|floor)];
    . as $raw
    | { 
        count: ($raw|length),
        statuses: ($raw | group_by(.status//200) | map({k:(.[0].status//200), n:length})),
        p95_latency_ms: ( ($raw | map(.latency_ms//null) | del(.[]|select(.==null))) as $L | if ($L|length > 0) then p($L;0.95) else null end )
      }
  ' "${TMP_DIR}/send.json" > "$METRICS_JSON" 2>/dev/null || echo '{"count":0,"statuses":[],"p95_latency_ms":null}' > "$METRICS_JSON"
  
  P95_LATENCY_BUDGET_MS="${P95_LATENCY_BUDGET_MS:-2000}"
  ANOMALY_P95="$(jq -r --arg budget "$P95_LATENCY_BUDGET_MS" '.p95_latency_ms as $p95 | if ($p95 != null and $p95 > ($budget|tonumber)) then "NG" else "OK" end' "$METRICS_JSON" 2>/dev/null || echo "OK")"
else
  echo '{"count":0,"statuses":[],"p95_latency_ms":null}' > "$METRICS_JSON"
  ANOMALY_P95="OK"
fi

cat > "$AUDIT_REPORT" <<EOF
---
report_id: "$REPORT_ID"
generated_at: "$RUN_DATE_JST"
tz: "$TZ"
scope_hours: ${AUDIT_LOOKBACK_HOURS}
supabase_ref: "$PROJECT_REF"
slack_permalink: "${PERMALINK:-""}"
git_sha: "$GIT_SHA"
artifacts:
  dryrun_json: "${TMP_DIR}/dryrun_merged.json"
  send_json: "${TMP_DIR}/send_merged.json"
  stripe_json: "${STRIPE_TMP_DIR}/events_starlist.json"
  edge_logs: "$EDGE_LOG_LIST"
checks:
  - name: slack_permalink_exists
  - name: edge_logs_collected
  - name: stripe_events_nonzero
  - name: day11_send_not_empty
  - name: p95_latency_within_budget
---

# Day11 & Pricing 統合監査票（自動生成）

- 生成日時（JST）: **${RUN_DATE_JST}**
- 監査範囲: 過去 **${AUDIT_LOOKBACK_HOURS}h**（since: ${AUDIT_SINCE_ISO:-N/A}, UTC）
- Git: \`${GIT_SHA}\`
- Slack Permalink: ${PERMALINK:-"(未取得)"}

---

## 1. Day11 実行ログ（サマリ）

- dryRun ログ: \`${TMP_DIR}/dryrun_merged.json\`（sha256=${DRYRUN_SUM:-n/a}）
- send ログ: \`${TMP_DIR}/send_merged.json\`（sha256=${SEND_SUM:-n/a}）

### 1.1 送信件数（自動計上）

\`\`\`json
$(jq -n --slurpfile d "${TMP_DIR}/dryrun_merged.json" --slurpfile s "${TMP_DIR}/send_merged.json" \
  '{dryRun: ($d[0]|length), send: ($s[0]|length)}' 2>/dev/null || echo '{"dryRun": 0, "send": 0}')
\`\`\`

### 1.2 最新dryRun結果

$(if [ -f "${TMP_DIR}/dryrun_merged.json" ] && [ "$(jq 'length' "${TMP_DIR}/dryrun_merged.json" 2>/dev/null || echo 0)" -gt 0 ]; then
  echo '```json'
  jq '.[-1] | {ok, stats: .stats, weekly_summary: .weekly_summary, message: .message}' "${TMP_DIR}/dryrun_merged.json" 2>/dev/null || echo "{}"
  echo '```'
else
  echo "dryRun JSON not found"
fi)

### 1.3 最新send結果

$(if [ -f "${TMP_DIR}/send_merged.json" ] && [ "$(jq 'length' "${TMP_DIR}/send_merged.json" 2>/dev/null || echo 0)" -gt 0 ]; then
  echo '```json'
  jq '.[-1] | {ok, permalink: (.permalink? // .slack?.permalink? // .message_url? // "N/A")}' "${TMP_DIR}/send_merged.json" 2>/dev/null || echo "{}"
  echo '```'
else
  echo "send JSON not found"
fi)

---

## 2. Supabase Edge Logs

- 収集対象: ${EDGE_LIST:-"(なし)"}

\`\`\`text
$(for f in ${EDGE_TMP_DIR}/*.log; do
  [[ -s "$f" ]] || continue
  echo "===== $(basename "$f") ====="
  tail -n 80 "$f" | scripts/utils/redact.sh 2>/dev/null || tail -n 80 "$f"
  echo
done || echo "Edge logs not available")
\`\`\`

---

## 3. Stripe Pricing イベント

- 抽出ファイル: \`${STRIPE_TMP_DIR}/events_starlist.json\`（sha256=${STRIPE_SUM:-n/a}）
- 代表イベント（最大10件）

\`\`\`json
$(jq '.[0:10] | map({id, type, created, amount_total: (.data.object.amount_total // .data.object.amount // null)})' "${STRIPE_TMP_DIR}/events_starlist.json" 2>/dev/null | scripts/utils/redact.sh 2>/dev/null || jq '.[0:10] | map({id, type, created, amount_total: (.data.object.amount_total // .data.object.amount // null)})' "${STRIPE_TMP_DIR}/events_starlist.json" 2>/dev/null || echo "[]")
\`\`\`

---

## 4. Pricing E2E Test

### 検証項目
- [ ] 学生プラン：推奨価格表示・バリデーション・Checkout→DB保存
- [ ] 成人プラン：推奨価格表示・バリデーション・Checkout→DB保存
- [ ] plan_price整数検証完了

### DB検証結果
\`\`\`sql
-- 直近のplan_price保存確認
select subscription_id, plan_price, currency, updated_at
from public.subscriptions
where plan_price is not null
order by updated_at desc
limit 10;
\`\`\`

**結果**: 手動で確認してください（plan_priceが整数の円で保存されていること）

---

## 5. 整合性チェック（自動判定）

- Slack投稿: $( [[ -n "$PERMALINK" ]] && echo "**OK**" || echo "**NG**: Permalink未取得")
- Edgeログ:  $( [[ -n "$EDGE_LIST" ]]    && echo "**OK**" || echo "**NG**: 収集なし")
- Stripe:     $( [[ -s "${STRIPE_TMP_DIR}/events_starlist.json" ]] && jq 'length > 0' "${STRIPE_TMP_DIR}/events_starlist.json" 2>/dev/null && echo "**OK**" || echo "**NG**: 抽出0件")
- P95 Latency: $(echo "$ANOMALY_P95" | grep -q "NG" && echo "**NG**: P95超過（予算: ${P95_LATENCY_BUDGET_MS:-2000}ms）" || echo "**OK**")

### 5.1 異常検知メトリクス

\`\`\`json
$(cat "$METRICS_JSON" 2>/dev/null || echo "{}")
\`\`\`

---

## 6. 合格ライン確認

### Day11（3点）
- [ ] dryRun：\`ok=true\` かつ \`stats/weekly_summary/message\` 妥当、\`std_dev>=0\`・\`thresholds>=0\`
- [ ] 本送信：JSON妥当、Slack \`#ops-monitor\` に**1件のみ**到達（permalink取得）
- [ ] ログ：HTTP 2xx、429/5xxは最大2回再試行内で回復、指数バックオフ再送**痕跡なし**

### Pricing（3+1）
- [ ] UI：推奨バッジ表示・刻み/上下限バリデーションOK
- [ ] Checkout→DB：plan_price が整数円で保存
- [ ] Webhook：checkout.* / subscription.* / invoice.* で価格更新反映
- [ ] Logs：Supabase Functions 200、例外なし／再送痕跡なし

---

## 7. インシデント対処・ロールバック（要約）

- 二重投稿 → 関数/トリガー一時停止、キャッシュ確認、再送要因を除去後に再実行（dryRun→send）
- 429/5xx → 最大2回の指数バックオフで回復しない場合は停止、Edgeログ確認とSecrets再注入
- JSON不整合 → ビュー再集計・型崩れ修正後にdryRun再検証
- plan_priceがNULL → 金額単位変換を確認（amount_total/unit_amountの基数）

---

## 8. 付記

- 生成コマンド: \`./FINAL_INTEGRATION_SUITE.sh\` → \`generate_audit_report.sh\`
- タイムゾーン: ${TZ}
- 注意: 本監査票は**自動生成**。疑義がある場合は各原本（ログ/イベントJSON）を参照のこと。

---

**監査完了日時**: ${RUN_DATE_JST}  
**監査者**: $(whoami)  
**承認**: <approver>
EOF

log "✅ 監査票生成完了: $AUDIT_REPORT"

# 失敗モード別フォールバック（明確なExit Code）
EXIT=0
[[ -n "$PERMALINK" ]] || EXIT=21      # Slackリンク未取得
if [[ ! -s "${STRIPE_TMP_DIR}/events_starlist.json" ]] || [[ "$(jq 'length' "${STRIPE_TMP_DIR}/events_starlist.json" 2>/dev/null || echo 0)" -eq 0 ]]; then 
  EXIT=22  # Stripe抽出0件
fi
if [[ "$(jq '.|length' "${TMP_DIR}/send.json" 2>/dev/null || echo 0)" -eq 0 ]]; then 
  EXIT=23  # Day11 send 空
fi

if [[ $EXIT -ne 0 ]]; then
  warn "Exit code: $EXIT"
  case $EXIT in
    21) warn "Slack Permalink未取得（Webhook/権限/429）" ;;
    22) warn "Stripe抽出0件（型/Lookback/API Key）" ;;
    23) warn "Day11 send空（実行失敗/権限）" ;;
  esac
fi

log ""
log "📝 次のステップ:"
log "  1. 監査票を確認: $AUDIT_REPORT"
log "  2. 構造検証: make verify"
log "  3. 不足情報を手動で追記"
log "  4. PRテンプレートを使用してPR作成"
log ""

exit $EXIT
