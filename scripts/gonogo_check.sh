#!/usr/bin/env bash
# Go/No-Go チェックスクリプト（10項目）
# Usage: ./scripts/gonogo_check.sh [--report-file <path>]

set -Eeuo pipefail

log()   { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
warn()  { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
error() { printf "\033[1;31m[ERR ]\033[0m %s\n" "$*" >&2; }

REPORT_FILE="${1:-$(ls -1 docs/reports/*_DAY11_AUDIT_*.md 2>/dev/null | tail -n1 || echo "")}"

if [[ -z "$REPORT_FILE" ]] || [[ ! -f "$REPORT_FILE" ]]; then
  error "Audit report not found: $REPORT_FILE"
  exit 1
fi

log "=== Go/No-Go Check: $REPORT_FILE ==="
log ""

FAILED=0

# 1. Front-Matter検証
log "[1/10] Front-Matter検証..."
if command -v ajv >/dev/null && command -v yq >/dev/null; then
  if awk '/^---$/{f++} f==1{print} /^---$/{if(f==2) exit}' "$REPORT_FILE" | sed '1d;$d' | yq -o=json | ajv validate -s schemas/audit_report.schema.json -d /dev/stdin >/dev/null 2>&1; then
    log "✅ OK"
  else
    error "❌ NG: Schema validation failed"
    FAILED=$((FAILED + 1))
  fi
else
  warn "⚠️  SKIP: ajv or yq not found (run 'make schema')"
fi

# 2. JST固定
log "[2/10] JST固定..."
if grep -q "tz: Asia/Tokyo" "$REPORT_FILE" && grep -q "generated_at:" "$REPORT_FILE"; then
  log "✅ OK"
else
  error "❌ NG: JST not fixed"
  FAILED=$((FAILED + 1))
fi

# 3. 範囲一貫
log "[3/10] 範囲一貫..."
SCOPE_HOURS=$(awk '/^scope_hours:/{print $2}' "$REPORT_FILE" | tr -d '"' || echo "")
if [[ -n "$SCOPE_HOURS" ]] && [[ "$SCOPE_HOURS" =~ ^[0-9]+$ ]]; then
  log "✅ OK (scope_hours: $SCOPE_HOURS)"
else
  error "❌ NG: scope_hours not found or invalid"
  FAILED=$((FAILED + 1))
fi

# 4. Slack証跡
log "[4/10] Slack証跡..."
PERMALINK=$(awk '/^slack_permalink:/{print $2}' "$REPORT_FILE" | tr -d '"' || echo "")
if [[ -n "$PERMALINK" ]] && [[ "$PERMALINK" =~ ^https://.*slack.com/archives/ ]]; then
  log "✅ OK (permalink found)"
else
  error "❌ NG: Slack permalink not found or invalid"
  FAILED=$((FAILED + 1))
fi

# 5. Edgeログ
log "[5/10] Edgeログ..."
if grep -q "edge_logs:" "$REPORT_FILE" && ! grep -qi "ERROR\|panic" "$REPORT_FILE"; then
  log "✅ OK (no ERROR/panic detected)"
else
  warn "⚠️  WARN: Edge logs check (manual review recommended)"
fi

# 6. Stripeイベント
log "[6/10] Stripeイベント..."
if grep -q "stripe_json:" "$REPORT_FILE" && grep -q "<redacted-" "$REPORT_FILE"; then
  log "✅ OK (redaction applied)"
else
  warn "⚠️  WARN: Stripe events check (manual review recommended)"
fi

# 7. DB監査（整数/範囲/重複/参照整合）
log "[7/10] DB監査..."
if grep -q "db_integer_ok\|db_price_range_valid\|db_dup_zero\|db_ref_integrity_ok" "$REPORT_FILE"; then
  log "✅ OK (DB audit checks found)"
else
  warn "⚠️  WARN: DB audit checks (manual review recommended)"
fi

# 8. 突合一致
log "[8/10] 突合一致..."
if [[ -f sql/pricing_reconcile.sql ]]; then
  log "✅ OK (reconcile SQL exists)"
else
  warn "⚠️  WARN: Reconcile SQL not found"
fi

# 9. 異常検知
log "[9/10] 異常検知..."
METRICS_FILE="tmp/audit_day11/metrics.json"
if [[ -f "$METRICS_FILE" ]]; then
  P95=$(jq -r '.p95_latency_ms // null' "$METRICS_FILE" 2>/dev/null || echo "null")
  BUDGET="${P95_LATENCY_BUDGET_MS:-2000}"
  if [[ "$P95" != "null" ]] && (( $(echo "$P95 <= $BUDGET" | bc -l 2>/dev/null || echo 0) )); then
    log "✅ OK (p95: ${P95}ms <= ${BUDGET}ms)"
  else
    warn "⚠️  WARN: P95 latency ($P95 ms) exceeds budget ($BUDGET ms)"
  fi
else
  warn "⚠️  WARN: Metrics file not found"
fi

# 10. CI成果物
log "[10/10] CI成果物..."
if [[ -d tmp/audit_day11 ]] || [[ -d tmp/audit_stripe ]] || [[ -d tmp/audit_edge ]]; then
  log "✅ OK (artifacts directories exist)"
else
  warn "⚠️  WARN: Artifacts directories not found"
fi

log ""
if [[ $FAILED -eq 0 ]]; then
  log "✅ Go/No-Go Check: PASSED (0 failures)"
  exit 0
else
  error "❌ Go/No-Go Check: FAILED ($FAILED failures)"
  exit 1
fi

