#!/bin/bash
# Phase 2.1 Verification Evidence Collection Script

set -euo pipefail

REPO="shochaso/starlist-app"
BRANCH="feature/slsa-phase2.1-hardened"
OUTPUT_DIR="/tmp/phase2_1_evidence"
mkdir -p "$OUTPUT_DIR"

echo "🔍 Phase 2.1 Verification Evidence Collection"
echo "=============================================="

# 1. Get latest run IDs
echo ""
echo "1. Run IDs Collection"
echo "-------------------"
gh run list --workflow=slsa-provenance.yml --limit 10 --json databaseId,conclusion,status,displayTitle,createdAt > "$OUTPUT_DIR/runs.json"
cat "$OUTPUT_DIR/runs.json" | jq -r '.[] | "\(.databaseId) | \(.status) | \(.conclusion) | \(.displayTitle)"'

# 2. Download artifacts for latest runs
echo ""
echo "2. Artifact Download"
echo "-------------------"
LATEST_RUNS=$(cat "$OUTPUT_DIR/runs.json" | jq -r '.[0:3] | .[].databaseId')
for RUN_ID in $LATEST_RUNS; do
  echo "Downloading artifacts for run $RUN_ID..."
  gh run download "$RUN_ID" --dir "$OUTPUT_DIR/artifacts_${RUN_ID}" 2>&1 | head -5 || echo "No artifacts for run $RUN_ID"
done

# 3. SHA256 consistency check
echo ""
echo "3. SHA256 Consistency Check"
echo "---------------------------"
find "$OUTPUT_DIR" -name "provenance-*.json" -type f | while read file; do
  SHA256=$(sha256sum "$file" | cut -d' ' -f1)
  echo "File: $file"
  echo "SHA256: $SHA256"
  echo "---"
done

# 4. Manifest.json diff (last 10 lines)
echo ""
echo "4. Manifest.json Diff (Last 10 lines)"
echo "-------------------------------------"
LATEST_MANIFEST=$(find docs/reports -name "manifest.json" -type f | sort | tail -1)
if [ -n "$LATEST_MANIFEST" ]; then
  echo "Latest manifest: $LATEST_MANIFEST"
  tail -10 "$LATEST_MANIFEST" | jq '.' || tail -10 "$LATEST_MANIFEST"
else
  echo "Manifest not found"
fi

# 5. Supabase query (if credentials available)
echo ""
echo "5. Supabase slsa_runs Table (Last 5 entries)"
echo "--------------------------------------------"
if [ -n "${SUPABASE_URL:-}" ] && [ -n "${SUPABASE_SERVICE_KEY:-}" ]; then
  curl -sS --fail --show-error --max-time 30 \
    -H "Authorization: Bearer ${SUPABASE_SERVICE_KEY}" \
    -H "apikey: ${SUPABASE_SERVICE_KEY}" \
    -H "Content-Type: application/json" \
    -X POST \
    "${SUPABASE_URL}/rest/v1/slsa_runs?select=*&order=created_at.desc&limit=5" \
    | jq '.' || echo "Supabase query failed"
else
  echo "Supabase credentials not available (set SUPABASE_URL and SUPABASE_SERVICE_KEY)"
fi

# 6. Branch protection settings
echo ""
echo "6. Branch Protection Settings"
echo "----------------------------"
gh api repos/${REPO}/branches/main/protection --jq '.required_status_checks.contexts' || echo "Branch protection API call failed"

echo ""
echo "✅ Evidence collection complete"
echo "Output directory: $OUTPUT_DIR"
