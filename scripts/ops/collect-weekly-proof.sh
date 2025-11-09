#!/usr/bin/env bash
# scripts/ops/collect-weekly-proof.sh
# 週次検証ログを自動収集して1枚サマリを作成

set -euo pipefail

PROOF_DIR="out/proof"
PROOF_FILE="${PROOF_DIR}/weekly-proof-$(date +%Y%m%d-%H%M%S).md"
mkdir -p "$PROOF_DIR"

{
  echo "# Weekly Routine Proof Report"
  echo ""
  echo "**Generated**: $(date '+%Y-%m-%d %H:%M:%S JST')"
  echo ""
  echo "---"
  echo ""
  
  echo "## 1. Weekly Routine Workflow Status"
  echo ""
  LATEST_RUN=$(gh run list --workflow weekly-routine.yml --limit 1 --json databaseId,status,conclusion,createdAt,url --jq '.[0]' 2>/dev/null || echo '{}')
  if [ "$LATEST_RUN" != "{}" ]; then
    RUN_ID=$(echo "$LATEST_RUN" | jq -r '.databaseId // "unknown"')
    RUN_STATUS=$(echo "$LATEST_RUN" | jq -r '.status // "unknown"')
    RUN_CONCLUSION=$(echo "$LATEST_RUN" | jq -r '.conclusion // "unknown"')
    RUN_URL=$(echo "$LATEST_RUN" | jq -r '.url // "unknown"')
    echo "- **Run ID**: $RUN_ID"
    echo "- **Status**: $RUN_STATUS"
    echo "- **Conclusion**: $RUN_CONCLUSION"
    echo "- **URL**: $RUN_URL"
  else
    echo "- ⚠️  Could not fetch workflow status"
  fi
  echo ""
  
  echo "## 2. Extended Security Workflow Status"
  echo ""
  EXT_SEC_RUN=$(gh run list --workflow extended-security.yml --limit 1 --json databaseId,status,conclusion,createdAt --jq '.[0]' 2>/dev/null || echo '{}')
  if [ "$EXT_SEC_RUN" != "{}" ]; then
    EXT_STATUS=$(echo "$EXT_SEC_RUN" | jq -r '.status // "unknown"')
    EXT_CONCLUSION=$(echo "$EXT_SEC_RUN" | jq -r '.conclusion // "unknown"')
    echo "- **Status**: $EXT_STATUS"
    echo "- **Conclusion**: $EXT_CONCLUSION"
  else
    echo "- ⚠️  Could not fetch Extended Security status"
  fi
  echo ""
  
  echo "## 3. SOT Ledger Verification"
  echo ""
  if scripts/ops/verify-sot-ledger.sh 2>&1; then
    echo "- ✅ SOT ledger verification passed"
  else
    echo "- ❌ SOT ledger verification failed"
  fi
  echo ""
  
  echo "## 4. Ops Health Status"
  echo ""
  if [ -f "docs/overview/STARLIST_OVERVIEW.md" ]; then
    OPS_HEALTH=$(grep -A1 "Ops Health" docs/overview/STARLIST_OVERVIEW.md | tail -n1 || echo "Not found")
    echo "- **Current Status**: $OPS_HEALTH"
  else
    echo "- ⚠️  STARLIST_OVERVIEW.md not found"
  fi
  echo ""
  
  echo "## 5. Weekly Reports"
  echo ""
  if [ -d "out/reports" ]; then
    REPORT_COUNT=$(ls -1 out/reports/weekly-*.* 2>/dev/null | wc -l | tr -d ' ' || echo "0")
    echo "- **Report Count**: $REPORT_COUNT"
    if [ "$REPORT_COUNT" -gt 0 ]; then
      echo "- **Latest Reports**:"
      ls -1t out/reports/weekly-*.* 2>/dev/null | head -n 3 | sed 's/^/  - /' || true
    fi
  else
    echo "- ⚠️  out/reports directory not found"
  fi
  echo ""
  
  echo "## 6. Log Files"
  echo ""
  if [ -d "out/logs" ]; then
    LOG_COUNT=$(ls -1 out/logs/*.txt out/logs/*.log 2>/dev/null | wc -l || echo "0")
    echo "- **Log File Count**: $LOG_COUNT"
    if [ "$LOG_COUNT" -gt 0 ]; then
      echo "- **Log Files**:"
      ls -1t out/logs/*.txt out/logs/*.log 2>/dev/null | head -n 5 | sed 's/^/  - /' || true
    fi
  else
    echo "- ⚠️  out/logs directory not found"
  fi
  echo ""
  
  echo "## 7. Security Hardening Progress"
  echo ""
  echo "### Issues"
  gh issue list --label security --limit 5 --json number,title,state --jq '.[] | "- #\(.number): \(.title) (\(.state))"' 2>/dev/null || echo "- ⚠️  Could not fetch issues"
  echo ""
  
  echo "### Dockerfile Non-root Status"
  if [ -f "cloudrun/ocr-proxy/Dockerfile" ]; then
    if grep -q "^USER app" cloudrun/ocr-proxy/Dockerfile; then
      echo "- ✅ cloudrun/ocr-proxy: USER app configured"
    else
      echo "- ⚠️  cloudrun/ocr-proxy: USER not configured"
    fi
  fi
  echo ""
  
  echo "---"
  echo ""
  echo "**Proof Report Generated**: $(date '+%Y-%m-%d %H:%M:%S JST')"
  
} > "$PROOF_FILE"

echo "✅ Proof report generated: $PROOF_FILE"
cat "$PROOF_FILE"

