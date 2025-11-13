#!/bin/bash
# Phase 3 Audit Observer Script
# Observes and validates SLSA Provenance workflow runs

set -euo pipefail

# Configuration
REPO="${GITHUB_REPOSITORY:-shochaso/starlist-app}"
PR_NUMBER="${PR_NUMBER:-61}"
SUPABASE_URL="${SUPABASE_URL:-}"
SUPABASE_SERVICE_KEY="${SUPABASE_SERVICE_KEY:-}"
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 Phase 3 Audit Observer"
echo "========================="
echo "Repository: $REPO"
echo "PR Number: $PR_NUMBER"
echo ""

# Function to check if command exists
check_command() {
  if ! command -v "$1" &> /dev/null; then
    echo -e "${RED}❌ Error: $1 is not installed${NC}"
    exit 1
  fi
}

# Check dependencies
echo "📋 Checking dependencies..."
check_command "gh"
check_command "jq"
check_command "curl"
check_command "sha256sum"
echo -e "${GREEN}✅ All dependencies available${NC}"
echo ""

# Function to get latest provenance run
get_latest_provenance_run() {
  echo "🔍 Finding latest provenance run..."
  gh run list --workflow=slsa-provenance.yml --limit 1 --json databaseId,conclusion,status,displayTitle,url,createdAt \
    --jq '.[0]' || echo "{}"
}

# Function to get latest validation run
get_latest_validation_run() {
  echo "🔍 Finding latest validation run..."
  gh run list --workflow=provenance-validate.yml --limit 1 --json databaseId,conclusion,status,displayTitle,url,createdAt \
    --jq '.[0]' || echo "{}"
}

# Function to audit provenance run
audit_provenance_run() {
  local RUN_ID="$1"
  local RUN_JSON="$2"
  
  echo ""
  echo "📊 Auditing Provenance Run: $RUN_ID"
  echo "-----------------------------------"
  
  CONCLUSION=$(echo "$RUN_JSON" | jq -r '.conclusion // "unknown"')
  STATUS=$(echo "$RUN_JSON" | jq -r '.status // "unknown"')
  DISPLAY_TITLE=$(echo "$RUN_JSON" | jq -r '.displayTitle // ""')
  RUN_URL=$(echo "$RUN_JSON" | jq -r '.url // ""')
  
  echo "Conclusion: $CONCLUSION"
  echo "Status: $STATUS"
  echo "Title: $DISPLAY_TITLE"
  echo "URL: $RUN_URL"
  
  # Extract tag
  TAG=$(echo "$DISPLAY_TITLE" | grep -oP 'v[\d.]+' | head -1 || echo "")
  echo "Tag: $TAG"
  
  # Download artifacts if successful
  ARTIFACT_COUNT=0
  SHA256=""
  PREDICATE_TYPE=""
  BUILDER_ID=""
  CONTENT_SHA256=""
  
  if [ "$CONCLUSION" = "success" ]; then
    echo ""
    echo "📦 Downloading artifacts..."
    gh run download "$RUN_ID" --dir /tmp/provenance_artifacts_${RUN_ID} 2>&1 || true
    
    ARTIFACT_FILE=$(find /tmp/provenance_artifacts_${RUN_ID} -name "provenance-*.json" -type f | head -1 || echo "")
    
    if [ -n "$ARTIFACT_FILE" ]; then
      ARTIFACT_COUNT=1
      echo "Found artifact: $ARTIFACT_FILE"
      
      # SHA256 check
      SHA256=$(sha256sum "$ARTIFACT_FILE" | cut -d' ' -f1)
      echo "SHA256: $SHA256"
      
      # PredicateType check
      PREDICATE_TYPE=$(jq -r '.predicateType // empty' "$ARTIFACT_FILE")
      if [ "$PREDICATE_TYPE" = "https://slsa.dev/provenance/v0.2" ]; then
        echo -e "${GREEN}✅ PredicateType: Valid${NC}"
      else
        echo -e "${RED}❌ PredicateType: Invalid ($PREDICATE_TYPE)${NC}"
      fi
      
      # Builder ID check
      BUILDER_ID=$(jq -r '.builder.id // empty' "$ARTIFACT_FILE")
      echo "Builder ID: $BUILDER_ID"
      
      # Content SHA256 check
      CONTENT_SHA256=$(jq -r '.metadata.content_sha256 // empty' "$ARTIFACT_FILE")
      echo "Content SHA256: $CONTENT_SHA256"
      
      # Verify tag matches invocation.release
      INV_RELEASE=$(jq -r '.invocation.release // empty' "$ARTIFACT_FILE")
      if [ "$INV_RELEASE" = "$TAG" ]; then
        echo -e "${GREEN}✅ Invocation release matches tag${NC}"
      else
        echo -e "${YELLOW}⚠️ Invocation release mismatch: $INV_RELEASE != $TAG${NC}"
      fi
    else
      echo -e "${YELLOW}⚠️ No artifact found${NC}"
    fi
  else
    echo -e "${RED}❌ Run did not succeed, skipping artifact verification${NC}"
  fi
  
  # Return results as JSON
  cat <<EOF
{
  "run_id": $RUN_ID,
  "conclusion": "$CONCLUSION",
  "status": "$STATUS",
  "tag": "$TAG",
  "artifact_count": $ARTIFACT_COUNT,
  "sha256": "$SHA256",
  "predicate_type": "$PREDICATE_TYPE",
  "builder_id": "$BUILDER_ID",
  "content_sha256": "$CONTENT_SHA256",
  "run_url": "$RUN_URL"
}
EOF
}

# Function to audit validation run
audit_validation_run() {
  local RUN_ID="$1"
  local RUN_JSON="$2"
  
  echo ""
  echo "📊 Auditing Validation Run: $RUN_ID"
  echo "-----------------------------------"
  
  CONCLUSION=$(echo "$RUN_JSON" | jq -r '.conclusion // "unknown"')
  STATUS=$(echo "$RUN_JSON" | jq -r '.status // "unknown"')
  DISPLAY_TITLE=$(echo "$RUN_JSON" | jq -r '.displayTitle // ""')
  RUN_URL=$(echo "$RUN_JSON" | jq -r '.url // ""')
  
  echo "Conclusion: $CONCLUSION"
  echo "Status: $STATUS"
  echo "Title: $DISPLAY_TITLE"
  echo "URL: $RUN_URL"
  
  # Return results as JSON
  cat <<EOF
{
  "run_id": $RUN_ID,
  "conclusion": "$CONCLUSION",
  "status": "$STATUS",
  "run_url": "$RUN_URL"
}
EOF
}

# Function to verify Supabase integration
verify_supabase() {
  local PROVENANCE_RUN_ID="$1"
  local VALIDATION_RUN_ID="$2"
  
  if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_SERVICE_KEY" ]; then
    echo ""
    echo -e "${YELLOW}⚠️ Supabase credentials not available, skipping verification${NC}"
    return 0
  fi
  
  echo ""
  echo "🔍 Verifying Supabase Integration"
  echo "-----------------------------------"
  
  SUPABASE_BASE="${SUPABASE_URL%/}"
  
  # Query for provenance run entry
  if [ -n "$PROVENANCE_RUN_ID" ]; then
    echo "Querying Supabase for provenance run $PROVENANCE_RUN_ID..."
    PROVENANCE_ENTRY=$(curl -sS --fail --show-error --max-time 30 \
      -H "Authorization: Bearer ${SUPABASE_SERVICE_KEY}" \
      -H "apikey: ${SUPABASE_SERVICE_KEY}" \
      -H "Content-Type: application/json" \
      -X GET \
      "${SUPABASE_BASE}/rest/v1/slsa_runs?run_id=eq.${PROVENANCE_RUN_ID}&select=*" \
      | jq '.[0]' || echo "{}")
    
    if [ "$PROVENANCE_ENTRY" != "{}" ] && [ "$PROVENANCE_ENTRY" != "null" ]; then
      PROVENANCE_STATUS=$(echo "$PROVENANCE_ENTRY" | jq -r '.status // "unknown"')
      echo -e "${GREEN}✅ Provenance entry found in Supabase (status: $PROVENANCE_STATUS)${NC}"
    else
      echo -e "${RED}❌ Provenance entry not found in Supabase${NC}"
    fi
  fi
  
  # Query for validation status
  if [ -n "$PROVENANCE_RUN_ID" ]; then
    echo "Querying Supabase for validation status..."
    VALIDATION_ENTRY=$(curl -sS --fail --show-error --max-time 30 \
      -H "Authorization: Bearer ${SUPABASE_SERVICE_KEY}" \
      -H "apikey: ${SUPABASE_SERVICE_KEY}" \
      -H "Content-Type: application/json" \
      -X GET \
      "${SUPABASE_BASE}/rest/v1/slsa_runs?run_id=eq.${PROVENANCE_RUN_ID}&select=validated_status,validated_at" \
      | jq '.[0]' || echo "{}")
    
    if [ "$VALIDATION_ENTRY" != "{}" ] && [ "$VALIDATION_ENTRY" != "null" ]; then
      VALIDATED_STATUS=$(echo "$VALIDATION_ENTRY" | jq -r '.validated_status // "null"')
      if [ "$VALIDATED_STATUS" != "null" ]; then
        echo -e "${GREEN}✅ Validation status found in Supabase (status: $VALIDATED_STATUS)${NC}"
      else
        echo -e "${YELLOW}⚠️ Validation status not set in Supabase${NC}"
      fi
    else
      echo -e "${YELLOW}⚠️ Validation entry not found in Supabase${NC}"
    fi
  fi
}

# Function to generate audit summary
generate_summary() {
  local PROVENANCE_AUDIT="$1"
  local VALIDATION_AUDIT="$2"
  
  echo ""
  echo "📊 Generating Audit Summary"
  echo "============================"
  
  PROVENANCE_CONCLUSION=$(echo "$PROVENANCE_AUDIT" | jq -r '.conclusion // "unknown"')
  VALIDATION_CONCLUSION=$(echo "$VALIDATION_AUDIT" | jq -r '.conclusion // "unknown"')
  PREDICATE_TYPE=$(echo "$PROVENANCE_AUDIT" | jq -r '.predicate_type // ""')
  SHA256=$(echo "$PROVENANCE_AUDIT" | jq -r '.sha256 // ""')
  
  echo ""
  echo "Overall Assessment:"
  echo "-------------------"
  
  if [ "$PROVENANCE_CONCLUSION" = "success" ] && \
     [ "$VALIDATION_CONCLUSION" = "success" ] && \
     [ "$PREDICATE_TYPE" = "https://slsa.dev/provenance/v0.2" ] && \
     [ -n "$SHA256" ]; then
    echo -e "${GREEN}✅ All validations passed${NC}"
    echo ""
    echo "✅ Phase 3 Audit Operationalization Verified — Proceed to Phase 4 (Telemetry & KPI Dashboard)"
    return 0
  else
    echo -e "${RED}❌ Some validations failed${NC}"
    echo ""
    echo "Failed checks:"
    [ "$PROVENANCE_CONCLUSION" != "success" ] && echo "  ❌ Provenance run failed"
    [ "$VALIDATION_CONCLUSION" != "success" ] && echo "  ❌ Validation run failed"
    [ "$PREDICATE_TYPE" != "https://slsa.dev/provenance/v0.2" ] && echo "  ❌ PredicateType invalid"
    [ -z "$SHA256" ] && echo "  ❌ SHA256 not calculated"
    return 1
  fi
}

# Main execution
main() {
  # Get latest runs
  PROVENANCE_RUN_JSON=$(get_latest_provenance_run)
  VALIDATION_RUN_JSON=$(get_latest_validation_run)
  
  if [ "$PROVENANCE_RUN_JSON" = "{}" ] && [ "$VALIDATION_RUN_JSON" = "{}" ]; then
    echo -e "${YELLOW}⚠️ No runs found to audit${NC}"
    exit 0
  fi
  
  # Extract run IDs
  PROVENANCE_RUN_ID=$(echo "$PROVENANCE_RUN_JSON" | jq -r '.databaseId // empty')
  VALIDATION_RUN_ID=$(echo "$VALIDATION_RUN_JSON" | jq -r '.databaseId // empty')
  
  # Audit runs
  PROVENANCE_AUDIT="{}"
  VALIDATION_AUDIT="{}"
  
  if [ -n "$PROVENANCE_RUN_ID" ]; then
    PROVENANCE_AUDIT=$(audit_provenance_run "$PROVENANCE_RUN_ID" "$PROVENANCE_RUN_JSON")
  fi
  
  if [ -n "$VALIDATION_RUN_ID" ]; then
    VALIDATION_AUDIT=$(audit_validation_run "$VALIDATION_RUN_ID" "$VALIDATION_RUN_JSON")
  fi
  
  # Verify Supabase
  verify_supabase "$PROVENANCE_RUN_ID" "$VALIDATION_RUN_ID"
  
  # Generate summary
  if generate_summary "$PROVENANCE_AUDIT" "$VALIDATION_AUDIT"; then
    echo ""
    echo "✅ Audit complete - All validations passed"
    exit 0
  else
    echo ""
    echo "❌ Audit complete - Some validations failed"
    exit 1
  fi
}

# Run main function
main "$@"

