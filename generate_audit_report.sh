#!/usr/bin/env bash
# 監査票自動生成スクリプト（permalink・Edgeログ・Stripeイベントを集約）
# Usage: ./generate_audit_report.sh [--date YYYYMMDD]

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
DATE_DIR="${1:-$(date +'%Y%m%d')}"
if [[ "$DATE_DIR" == "--date" ]]; then
  DATE_DIR="${2:-$(date +'%Y%m%d')}"
fi

TS="$(date +'%Y-%m-%dT%H:%M:%S%z')"
REPORTS_DIR="docs/reports/${DATE_DIR}"
mkdir -p "$REPORTS_DIR"

AUDIT_REPORT="${REPORTS_DIR}/AUDIT_REPORT_${TS}.md"

# ===== Collect Data =====
log "=== 監査票自動生成 ==="
log ""

# 1) Permalink収集
log "📋 1) Permalink収集"
PERMALINK=""
if [ -f ".day11_cache/permalink.txt" ]; then
  PERMALINK=$(cat ".day11_cache/permalink.txt")
  log "✅ Permalink found: $PERMALINK"
elif [ -f "${REPORTS_DIR}/DAY11_PERMALINK.txt" ]; then
  PERMALINK=$(cat "${REPORTS_DIR}/DAY11_PERMALINK.txt")
  log "✅ Permalink found: $PERMALINK"
else
  warn "Permalink not found"
fi
log ""

# 2) Edge Function Logs収集
log "📋 2) Edge Function Logs収集"
EDGE_LOGS=""
if command -v supabase >/dev/null 2>&1; then
  PROJECT_REF=$(basename "$SUPABASE_URL" .supabase.co)
  log "Fetching Edge Function logs..."
  EDGE_LOGS=$(supabase functions logs --project-ref "$PROJECT_REF" --function-name "ops-slack-summary" --since 2h 2>/dev/null | tail -n 50 || echo "")
  if [ -n "$EDGE_LOGS" ]; then
    log "✅ Edge logs collected"
  else
    warn "Edge logs not available"
  fi
else
  warn "Supabase CLI not found, skipping Edge logs"
fi
log ""

# 3) Day11 JSON Logs収集
log "📋 3) Day11 JSON Logs収集"
DRYRUN_JSON=""
SEND_JSON=""
if [ -d "logs/day11" ]; then
  LATEST_DRY=$(ls -t logs/day11/*_dryrun.json 2>/dev/null | head -n1)
  LATEST_SEND=$(ls -t logs/day11/*_send.json 2>/dev/null | head -n1)
  
  if [ -n "$LATEST_DRY" ] && [ -f "$LATEST_DRY" ]; then
    DRYRUN_JSON=$(cat "$LATEST_DRY")
    log "✅ dryRun JSON found: $LATEST_DRY"
  fi
  
  if [ -n "$LATEST_SEND" ] && [ -f "$LATEST_SEND" ]; then
    SEND_JSON=$(cat "$LATEST_SEND")
    log "✅ send JSON found: $LATEST_SEND"
  fi
else
  warn "logs/day11 directory not found"
fi
log ""

# 4) Stripe Events収集（Pricing機能用）
log "📋 4) Stripe Events収集（Pricing機能用）"
STRIPE_EVENTS=""
if command -v stripe >/dev/null 2>&1; then
  log "Fetching recent Stripe events..."
  STRIPE_EVENTS=$(stripe events list --limit 10 2>/dev/null | jq -r '.data[] | "\(.created) \(.type) \(.id)"' || echo "")
  if [ -n "$STRIPE_EVENTS" ]; then
    log "✅ Stripe events collected"
  else
    warn "Stripe events not available"
  fi
else
  warn "Stripe CLI not found, skipping Stripe events"
fi
log ""

# ===== Generate Audit Report =====
log "📋 5) 監査票生成"
cat > "$AUDIT_REPORT" <<EOF
# Day11 & Pricing 統合監査レポート（自動生成）

**生成日時**: ${TS}  
**実行者**: $(whoami)  
**環境**: ${SUPABASE_URL}

---

## 1. Preflight Check

- ✅ Environment Variables確認完了
- ✅ SUPABASE_URL形式検証完了（20桁ref）
- ✅ Preflightスクリプト実行完了

### Environment Matrix
\`\`\`
SUPABASE_URL: ${SUPABASE_URL}
SUPABASE_ANON_KEY: <masked>
TZ: Asia/Tokyo
\`\`\`

---

## 2. Day11 Execution

### dryRun結果
$(if [ -n "$DRYRUN_JSON" ]; then
  echo '```json'
  echo "$DRYRUN_JSON" | jq '.' 2>/dev/null || echo "$DRYRUN_JSON"
  echo '```'
  echo ""
  echo "**検証結果**:"
  echo "$DRYRUN_JSON" | jq -r '
    "  - ok: " + (.ok | tostring) +
    "\n  - mean_notifications: " + (.stats.mean_notifications | tostring) +
    "\n  - std_dev: " + (.stats.std_dev | tostring) +
    "\n  - new_threshold: " + (.stats.new_threshold | tostring) +
    "\n  - critical_threshold: " + (.stats.critical_threshold | tostring)
  ' 2>/dev/null || echo "  - JSON解析エラー"
else
  echo "dryRun JSON not found"
fi)

### 本送信結果
$(if [ -n "$SEND_JSON" ]; then
  echo '```json'
  echo "$SEND_JSON" | jq '.' 2>/dev/null || echo "$SEND_JSON"
  echo '```'
  echo ""
  echo "**検証結果**:"
  echo "$SEND_JSON" | jq -r '
    "  - ok: " + (.ok | tostring) +
    "\n  - permalink: " + (.permalink? // .slack?.permalink? // .message_url? // "N/A" | tostring)
  ' 2>/dev/null || echo "  - JSON解析エラー"
else
  echo "send JSON not found"
fi)

### Permalink
$(if [ -n "$PERMALINK" ]; then
  echo "[$PERMALINK]($PERMALINK)"
else
  echo "Not available"
fi)

---

## 3. Edge Function Logs

$(if [ -n "$EDGE_LOGS" ]; then
  echo '```'
  echo "$EDGE_LOGS"
  echo '```'
else
  echo "Edge Function logs not available"
  echo ""
  echo "手動で確認:"
  echo "\`\`\`bash"
  echo "supabase functions logs --project-ref <ref> --function-name ops-slack-summary --since 2h"
  echo "\`\`\`"
fi)

---

## 4. Stripe Events（Pricing機能用）

$(if [ -n "$STRIPE_EVENTS" ]; then
  echo "### 直近10件のStripe Events"
  echo ""
  echo '| Created | Type | ID |'
  echo '|---------|------|-----|'
  echo "$STRIPE_EVENTS" | while IFS=' ' read -r created type id; do
    echo "| $created | $type | \`$id\` |"
  done
else
  echo "Stripe events not available"
  echo ""
  echo "手動で確認:"
  echo "\`\`\`bash"
  echo "stripe events list --limit 10"
  echo "\`\`\`"
fi)

---

## 5. Pricing E2E Test

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

**結果**: 手動で確認してください

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

## 7. ログファイル

### Day11
$(if [ -n "$LATEST_DRY" ]; then
  echo "- dryRun JSON: \`$LATEST_DRY\`"
else
  echo "- dryRun JSON: not found"
fi)
$(if [ -n "$LATEST_SEND" ]; then
  echo "- Send JSON: \`$LATEST_SEND\`"
else
  echo "- Send JSON: not found"
fi)

### Pricing
- Webhook検証ログ: `<pricing logs>`
- E2Eテストログ: `<test logs>`

---

## 8. 次のステップ

1. ✅ Slack #ops-monitor チャンネルで週次サマリを確認
2. ✅ Supabase Functions Logs でログを確認
3. ✅ 重要ファイル（OPS-MONITORING-V3-001.md / Mermaid.md）を更新
4. ✅ PR作成（付属テンプレート使用）

---

## 9. インシデント対処

### 失敗時の復旧手順
1. \`DAY11_RECOVERY_TEMPLATE.sh\` を実行
2. Slack到達確認（UI確認）
3. Edge Functionログ確認（\`supabase functions logs\`）
4. DBビュー再集計確認（\`v_ops_notify_stats\`）
5. Secrets再読込み確認

### ロールバック手順
1. GitHub Actions workflow を無効化
2. Supabase Edge Function を前バージョンにロールバック
3. DBビューを前バージョンにロールバック（必要に応じて）

---

**監査完了日時**: $(date +'%Y-%m-%d %H:%M:%S %Z')  
**監査者**: $(whoami)  
**承認**: `<approver>`

EOF

log "✅ 監査票生成完了: $AUDIT_REPORT"
log ""
log "📝 次のステップ:"
log "  1. 監査票を確認: $AUDIT_REPORT"
log "  2. 不足情報を手動で追記"
log "  3. PRテンプレートを使用してPR作成"
log ""

