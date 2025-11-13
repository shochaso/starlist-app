#!/bin/bash
# Auto-execution script for WS02-WS14 evidence collection
# Execute after workflows complete via GitHub UI

set -euo pipefail

REPORT_DIR="docs/reports/$(date -u +%F)"
mkdir -p "$REPORT_DIR/slack_excerpts" "$REPORT_DIR/artifacts" "$REPORT_DIR/observer"

echo "🔧 Auto-execution script started"
echo "REPORT_DIR=$REPORT_DIR"

# Get latest run IDs
RUN_ID_SUCCESS=$(gh run list --workflow slsa-provenance.yml --limit 1 --json databaseId -q '.[0].databaseId' 2>/dev/null || echo "")
RUN_ID_FAIL=$(gh run list --workflow slsa-provenance.yml --limit 2 --json databaseId -q '.[1].databaseId' 2>/dev/null || echo "")

echo "Success Run ID: ${RUN_ID_SUCCESS:-[not found]}"
echo "Failure Run ID: ${RUN_ID_FAIL:-[not found]}"

# Download logs and artifacts for success case
if [ -n "$RUN_ID_SUCCESS" ] && [ "$RUN_ID_SUCCESS" != "null" ]; then
  echo "📥 Downloading success case artifacts..."
  gh run view "$RUN_ID_SUCCESS" --log > "$REPORT_DIR/run_${RUN_ID_SUCCESS}.log" 2>&1 || true
  gh run download "$RUN_ID_SUCCESS" --dir "$REPORT_DIR/artifacts/${RUN_ID_SUCCESS}" 2>&1 || true
  
  # SHA256 validation
  PROV=$(find "$REPORT_DIR/artifacts/${RUN_ID_SUCCESS}" -name "provenance-*.json" 2>/dev/null | head -n1)
  if [ -n "$PROV" ] && [ -f "$PROV" ]; then
    METASHA=$(jq -r '.metadata.content_sha256 // empty' "$PROV" 2>/dev/null || echo "")
    CALCSHA=$(shasum -a 256 "$PROV" 2>/dev/null | awk '{print $1}' || echo "")
    PREDICATE=$(jq -r '.predicateType // empty' "$PROV" 2>/dev/null || echo "")
    TAG_SUCCESS=$(gh run view "$RUN_ID_SUCCESS" --json displayTitle -q '.displayTitle' 2>/dev/null | grep -o 'vtest-[^ ]*' | head -1 || echo "vtest-success-unknown")
    
    printf "| run_id | tag | predicateType | meta_sha | calc_sha | equal |\n|---|---|---|---|---|---|\n| %s | %s | %s | %s | %s | %s |\n" \
      "$RUN_ID_SUCCESS" "$TAG_SUCCESS" "$PREDICATE" "${METASHA:0:16}..." "${CALCSHA:0:16}..." \
      "$([ "$METASHA" = "$CALCSHA" ] && echo OK || echo MISMATCH)" \
      > "$REPORT_DIR/WS06_SHA256_VALIDATION.md"
    echo "✅ SHA256 validation table created"
  fi
fi

# Download logs for failure case
if [ -n "$RUN_ID_FAIL" ] && [ "$RUN_ID_FAIL" != "null" ]; then
  echo "📥 Downloading failure case logs..."
  gh run view "$RUN_ID_FAIL" --log > "$REPORT_DIR/run_${RUN_ID_FAIL}.log" 2>&1 || true
  gh run download "$RUN_ID_FAIL" --dir "$REPORT_DIR/artifacts/${RUN_ID_FAIL}" 2>&1 || true
  
  # Extract Slack excerpts
  grep -nEi "slack|webhook|POST|200|4..|5.." "$REPORT_DIR/run_${RUN_ID_FAIL}.log" 2>/dev/null | head -n 15 > "$REPORT_DIR/slack_excerpts/${RUN_ID_FAIL}.log" || true
  echo "✅ Slack excerpts extracted"
fi

echo "✅ Auto-execution script completed"
