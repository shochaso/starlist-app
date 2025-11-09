#!/usr/bin/env bash
# scripts/ops/post-merge-routine.sh
# PRマージ後のルーチン処理を実行するスクリプト（ログ出力付き）
set -euo pipefail

# ログディレクトリの準備
mkdir -p out/logs
LOG_DIR="out/logs"
JST_NOW=$(TZ='Asia/Tokyo' date '+%Y-%m-%d %H:%M:%S %Z')

note() {
  echo "[$(date +%H:%M:%S)] $*" | tee -a "$LOG_DIR/routine.log"
}

note "🔍 Post-merge routine started"

# 1. Extended Securityワークフローの最新実行状態を確認
note "📊 Checking Extended Security workflow status..."
{
  echo "[run] extended-security recent"
  gh run list --workflow=extended-security.yml --limit 5 2>&1 || echo "gh command failed"
} | tee "$LOG_DIR/extsec.txt" | head -n 6

LATEST_RUN=$(gh run list --workflow=extended-security.yml --limit 1 --json databaseId,status,conclusion,createdAt --jq '.[0]' 2>/dev/null || echo '{}')

if [ "$LATEST_RUN" != "{}" ]; then
  RUN_STATUS=$(echo "$LATEST_RUN" | jq -r '.status // "unknown"')
  RUN_CONCLUSION=$(echo "$LATEST_RUN" | jq -r '.conclusion // "unknown"')
  RUN_ID=$(echo "$LATEST_RUN" | jq -r '.databaseId // "unknown"')
  
  note "Latest Extended Security run: ID=$RUN_ID, Status=$RUN_STATUS, Conclusion=$RUN_CONCLUSION"
  
  if [ "$RUN_STATUS" = "completed" ] && [ "$RUN_CONCLUSION" = "success" ]; then
    echo "✅ Extended Security workflow is GREEN" | tee -a "$LOG_DIR/routine.log"
  else
    echo "⚠️  Extended Security workflow is not successful (Status: $RUN_STATUS, Conclusion: $RUN_CONCLUSION)" | tee -a "$LOG_DIR/routine.log"
  fi
else
  echo "⚠️  Could not fetch Extended Security workflow status" | tee -a "$LOG_DIR/routine.log"
fi

# 2. PR #30-33のマージ状態を確認
note "🔍 Verifying PR #30-33 merge status..."
MERGED_COUNT=0
for PR_NUM in 30 31 32 33; do
  PR_STATE=$(gh pr view "$PR_NUM" --json state --jq '.state' 2>/dev/null || echo "unknown")
  if [ "$PR_STATE" = "MERGED" ]; then
    MERGED_COUNT=$((MERGED_COUNT + 1))
    note "✅ PR #$PR_NUM is merged"
  else
    note "⚠️  PR #$PR_NUM state: $PR_STATE"
  fi
done

if [ "$MERGED_COUNT" -eq 4 ]; then
  echo "✅ All PRs (#30-33) are merged"
else
  echo "⚠️  Only $MERGED_COUNT/4 PRs are merged"
fi

# 3. DAY12_SOT_DIFFS.mdの存在確認
note "📄 Checking DAY12_SOT_DIFFS.md..."
if [ -f "docs/reports/DAY12_SOT_DIFFS.md" ]; then
  echo "✅ DAY12_SOT_DIFFS.md exists"
  # ファイルに4行（PR情報）が含まれているか確認
  PR_LINES=$(grep -c "^### PR #" "docs/reports/DAY12_SOT_DIFFS.md" || echo "0")
  if [ "$PR_LINES" -ge 4 ]; then
    echo "✅ DAY12_SOT_DIFFS.md contains $PR_LINES PR entries"
  else
    echo "⚠️  DAY12_SOT_DIFFS.md contains only $PR_LINES PR entries (expected 4+)"
  fi
else
  echo "⚠️  DAY12_SOT_DIFFS.md not found"
fi

# 4. 監査レポートの生成確認（オプション・ソフトフェイル）
note "📊 Checking audit report generation..."
mkdir -p out/reports
if command -v pnpm >/dev/null 2>&1; then
  if pnpm export:audit-report >"$LOG_DIR/audit-report.log" 2>&1 || bash scripts/generate_audit_report.sh >"$LOG_DIR/audit-report.log" 2>&1; then
    echo "✅ Audit report generation completed" | tee -a "$LOG_DIR/routine.log"
    ls -1 out/reports/weekly-*.* 2>/dev/null | head -n 3 | tee "$LOG_DIR/reports.txt" || echo "No weekly reports found" | tee "$LOG_DIR/reports.txt"
  else
    echo "⚠️  Audit report generation failed (non-fatal)" | tee -a "$LOG_DIR/routine.log"
    echo "mlc local failed (non-fatal)" | tee "$LOG_DIR/audit-report.log"
  fi
else
  echo "⚠️  pnpm not found, trying bash script..." | tee -a "$LOG_DIR/routine.log"
  if bash scripts/generate_audit_report.sh >"$LOG_DIR/audit-report.log" 2>&1; then
    ls -1 out/reports/weekly-*.* 2>/dev/null | head -n 3 | tee "$LOG_DIR/reports.txt" || echo "No weekly reports found" | tee "$LOG_DIR/reports.txt"
  else
    echo "⚠️  Audit report generation failed (non-fatal)" | tee -a "$LOG_DIR/routine.log"
  fi
fi

# 5. Markdown lint確認（ソフトフェイル）
note "🔍 Checking markdown lint..."
if command -v npm >/dev/null 2>&1; then
  if npm run lint:md:local >"$LOG_DIR/mlc.txt" 2>&1; then
    echo "✅ Markdown lint passed" | tee -a "$LOG_DIR/routine.log"
  else
    echo "⚠️  Markdown lint may have issues (non-fatal)" | tee -a "$LOG_DIR/routine.log"
    echo "mlc local failed (non-fatal)" | tee -a "$LOG_DIR/mlc.txt"
  fi
else
  echo "⚠️  npm not found, skipping markdown lint check" | tee -a "$LOG_DIR/routine.log"
fi

# 完了ログ
note "✅ Post-merge routine completed at $JST_NOW"
echo "DONE" | tee -a "$LOG_DIR/routine.log"
date | tee -a "$LOG_DIR/routine.log"

# ログファイルのサマリー
echo ""
echo "📋 Log files generated:"
ls -lh "$LOG_DIR"/*.txt "$LOG_DIR"/*.log 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}' || echo "  (no log files)"

