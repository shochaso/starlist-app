#!/usr/bin/env bash
# scripts/ops/weekly-routine.sh
# 週次ルーチン（そのままコピペ運用）
# Usage: ./scripts/ops/weekly-routine.sh [PR_NUMBERS...]

set -euo pipefail

LOG_DIR="out/logs"
mkdir -p "$LOG_DIR"

note() {
  echo "[$(date +%H:%M:%S)] $*" | tee -a "$LOG_DIR/weekly-routine.log"
}

note "📋 Weekly routine started"

# ① セキュリティCI（手動キックと確認）
note "🔒 Step 1: Security CI"
gh workflow run extended-security.yml
sleep 8
note "📊 Checking Extended Security workflow status..."
gh run list --workflow extended-security.yml --limit 3 | tee -a "$LOG_DIR/weekly-routine.log"

# ② 週次レポ生成（WS-A）＋成果ログ（WS-F）
note "📄 Step 2: Audit report generation"
if command -v pnpm >/dev/null 2>&1; then
  pnpm export:audit-report 2>&1 | tee -a "$LOG_DIR/weekly-routine.log" || {
    note "⚠️  pnpm export:audit-report failed, trying bash script..."
    bash scripts/generate_audit_report.sh 2>&1 | tee -a "$LOG_DIR/weekly-routine.log" || true
  }
else
  note "⚠️  pnpm not found, using bash script..."
  bash scripts/generate_audit_report.sh 2>&1 | tee -a "$LOG_DIR/weekly-routine.log" || true
fi

note "📊 Step 3: Post-merge routine"
scripts/ops/post-merge-routine.sh

note "📋 Log files generated:"
ls -1 "$LOG_DIR"/*.txt "$LOG_DIR"/*.log 2>/dev/null | head -n 5 | tee -a "$LOG_DIR/weekly-routine.log" || echo "No log files found"

# ③ SOT台帳（WS-E）— マージ発生時のみ
if [ $# -gt 0 ]; then
  note "📝 Step 4: SOT append (PRs: $*)"
  scripts/ops/sot-append.sh "$@"
  note "📋 Latest SOT entries:"
  tail -n 3 docs/reports/DAY12_SOT_DIFFS.md | tee -a "$LOG_DIR/weekly-routine.log"
else
  note "⏭️  Step 4: SOT append skipped (no PR numbers provided)"
fi

note "✅ Weekly routine completed"
echo "📋 Summary:"
echo "  - Security CI: Check GitHub Actions"
echo "  - Audit reports: Check out/reports/weekly-*.*"
echo "  - Logs: Check out/logs/*"
if [ $# -gt 0 ]; then
  echo "  - SOT updated: docs/reports/DAY12_SOT_DIFFS.md"
fi

