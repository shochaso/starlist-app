#!/usr/bin/env bash
# Phase 4 automated artifact collector
# Responsibilities:
#   - Download GitHub Actions artifacts for the given run_id
#   - Compute SHA parity using scripts/phase4-sha-compare.sh
#   - Update docs/reports/2025-11-14/RUNS_SUMMARY.json
#   - Append/merge manifest entries via scripts/phase4-manifest-atomic.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_ROOT="$ROOT/docs/reports/2025-11-14"
ARTIFACT_BASE="$REPORT_ROOT/artifacts"
RUNS_SUMMARY_PATH="$REPORT_ROOT/RUNS_SUMMARY.json"
MANIFEST_PATH="$REPORT_ROOT/_manifest.json"

usage() {
  cat <<'USAGE'
Usage: scripts/phase4-auto-collect.sh <run_id> [options]

Options:
  --tag <TAG>                 Optional release tag reference for logging
  --artifact-pattern <glob>   File glob to locate primary artifact within downloaded payload
  --metadata-pattern <glob>   File glob to locate provenance metadata (default: provenance-*.json)
  --observer-run-id <id>      Observer workflow run_id to capture in summary
  --retries <number>          Retry count recorded for the run (default: 0)
  --retry-origin <string>     Retry origin descriptor (default: null)
  --observer-notes <text>     Short note stored with RUNS_SUMMARY entry
  --run-mode <mode>           Execution mode hint (default: normal)
  --dry-run                   Perform download + SHA compare only (no file mutations)

Environment requirements:
  - GitHub CLI (gh) authenticated
  - jq, python3 available
USAGE
}

if [ "$#" -lt 1 ]; then
  usage >&2
  exit 1
fi

RUN_ID="$1"
shift

TAG=""
ARTIFACT_PATTERN=""
METADATA_PATTERN="provenance-*.json"
OBSERVER_RUN_ID=""
RETRIES="0"
RETRY_ORIGIN=""
OBSERVER_NOTES=""
RUN_MODE="normal"
DRY_RUN="false"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --tag)
      TAG="$2"
      shift 2
      ;;
    --artifact-pattern)
      ARTIFACT_PATTERN="$2"
      shift 2
      ;;
    --metadata-pattern)
      METADATA_PATTERN="$2"
      shift 2
      ;;
    --observer-run-id)
      OBSERVER_RUN_ID="$2"
      shift 2
      ;;
    --retries)
      RETRIES="$2"
      shift 2
      ;;
    --retry-origin)
      RETRY_ORIGIN="$2"
      shift 2
      ;;
    --observer-notes)
      OBSERVER_NOTES="$2"
      shift 2
      ;;
    --run-mode)
      RUN_MODE="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

timestamp_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

log() {
  printf '[%s] %s\n' "$(timestamp_utc)" "$*"
}

log "Starting Phase 4 auto collect for run_id=${RUN_ID} (mode=${RUN_MODE})"
if [ -n "$TAG" ]; then
  log "Reference tag: $TAG"
fi

ARTIFACT_DIR="$ARTIFACT_BASE/$RUN_ID"
RAW_DIR="$ARTIFACT_DIR/raw"
mkdir -p "$RAW_DIR"

REPO_NAME="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
log "Downloading artifacts for run ${RUN_ID} from ${REPO_NAME}"
gh run download "$RUN_ID" --dir "$RAW_DIR" --repo "$REPO_NAME"

if command -v tree >/dev/null 2>&1; then
  log "Downloaded artifact layout:"
  if ! (cd "$ARTIFACT_DIR" && tree -a .); then
    echo "tree command failed to render artifact layout (non-fatal)."
  fi
else
  log "Downloaded files:"
  find "$ARTIFACT_DIR" -maxdepth 3 -type f -printf '%P\n'
fi

detect_file() {
  local base_dir="$1"
  local pattern="$2"
  local fallback_non_json="$3"
  local result=""

  if [ -n "$pattern" ]; then
    result=$(find "$base_dir" -maxdepth 5 -type f -name "$pattern" | head -n1 || true)
  fi

  if [ -z "$result" ] && [ "$fallback_non_json" = "true" ]; then
    result=$(find "$base_dir" -maxdepth 5 -type f ! -name '*.json' ! -name '*.txt' | head -n1 || true)
  fi

  echo "$result"
}

PROVENANCE_FILE=$(detect_file "$ARTIFACT_DIR" "$METADATA_PATTERN" "false")
ARTIFACT_FILE=$(detect_file "$ARTIFACT_DIR" "$ARTIFACT_PATTERN" "true")

if [ -z "$PROVENANCE_FILE" ]; then
  log "WARNING: provenance metadata file not found with pattern '${METADATA_PATTERN}'"
fi
if [ -z "$ARTIFACT_FILE" ]; then
  log "WARNING: artifact file not found (pattern '${ARTIFACT_PATTERN:-<auto>}')"
fi

METADATA_SHA=""
COMPUTED_SHA=""
SHA_PARITY="unknown"

if [ -n "$PROVENANCE_FILE" ] && [ -n "$ARTIFACT_FILE" ]; then
  COMPARE_OUTPUT="$(bash "$ROOT/scripts/phase4-sha-compare.sh" "$ARTIFACT_FILE" "$PROVENANCE_FILE" --run-id "$RUN_ID")"
  for kv in $COMPARE_OUTPUT; do
    key="${kv%%=*}"
    value="${kv#*=}"
    case "$key" in
      metadata_sha) METADATA_SHA="$value" ;;
      computed_sha) COMPUTED_SHA="$value" ;;
      sha_parity) SHA_PARITY="$value" ;;
    esac
  done
  log "SHA parity for run ${RUN_ID}: metadata_sha=${METADATA_SHA} computed_sha=${COMPUTED_SHA} parity=${SHA_PARITY}"
else
  log "SHA parity check skipped due to missing files."
fi

if [ "$DRY_RUN" = "true" ]; then
  log "Dry-run requested. Skipping manifest and RUNS_SUMMARY updates."
  exit 0
fi

if [ ! -f "$RUNS_SUMMARY_PATH" ]; then
  log "RUNS_SUMMARY.json not found. Creating new file."
  printf '[]\n' >"$RUNS_SUMMARY_PATH"
fi

RUN_INFO_JSON="$(gh run view "$RUN_ID" --json conclusion,event,runStartedAt,updatedAt,createdAt,headSha,headBranch,status,workflowName --repo "$REPO_NAME")"

CONCLUSION=$(echo "$RUN_INFO_JSON" | jq -r '.conclusion // .status // "unknown"')
EVENT=$(echo "$RUN_INFO_JSON" | jq -r '.event // "unknown"')
RUN_STARTED=$(echo "$RUN_INFO_JSON" | jq -r '.runStartedAt // .createdAt // empty')
RUN_COMPLETED=$(echo "$RUN_INFO_JSON" | jq -r '.updatedAt // empty')
HEAD_SHA=$(echo "$RUN_INFO_JSON" | jq -r '.headSha // empty')
WORKFLOW_NAME=$(echo "$RUN_INFO_JSON" | jq -r '.workflowName // empty')
BRANCH=$(echo "$RUN_INFO_JSON" | jq -r '.headBranch // empty')

if [ -z "$RUN_STARTED" ] || [ "$RUN_STARTED" = "null" ]; then
  RUN_STARTED=$(timestamp_utc)
fi

if [ -z "$RUN_COMPLETED" ] || [ "$RUN_COMPLETED" = "null" ]; then
  RUN_COMPLETED=$(timestamp_utc)
fi

TRIGGER_MODE="$EVENT"
case "$EVENT" in
  workflow_dispatch) TRIGGER_MODE="manual_dispatch" ;;
  schedule) TRIGGER_MODE="scheduled" ;;
  repository_dispatch) TRIGGER_MODE="repository_dispatch" ;;
esac

DURATION_SEC=$(python3 - <<'PY'
import sys
from datetime import datetime, timezone

start_raw, end_raw = sys.argv[1], sys.argv[2]
def parse(ts):
    try:
        return datetime.fromisoformat(ts.replace("Z", "+00:00"))
    except ValueError:
        return datetime.strptime(ts, "%Y-%m-%dT%H:%M:%S%z")

start = parse(start_raw)
end = parse(end_raw)
delta = (end - start).total_seconds()
if delta < 0:
    delta = 0.0
print(f"{delta:.3f}")
PY
"$RUN_STARTED" "$RUN_COMPLETED")

REL_ARTIFACT_PATH=""
if [ -n "$ARTIFACT_FILE" ]; then
  REL_ARTIFACT_PATH=$(python3 - "$ROOT" "$ARTIFACT_FILE" <<'PY'
import os, sys, pathlib
root = pathlib.Path(sys.argv[1])
target = pathlib.Path(sys.argv[2])
try:
    print(target.relative_to(root))
except ValueError:
    print(target)
PY
)
fi

RECORDED_AT="$(timestamp_utc)"

log "Updating RUNS_SUMMARY.json for run ${RUN_ID}"
RUN_ID_VAR="$RUN_ID" \
CONCLUSION_VAR="$CONCLUSION" \
TRIGGER_MODE_VAR="$TRIGGER_MODE" \
SHA_PARITY_VAR="$SHA_PARITY" \
RETRIES_VAR="$RETRIES" \
RETRY_ORIGIN_VAR="$RETRY_ORIGIN" \
RUN_STARTED_VAR="$RUN_STARTED" \
RUN_COMPLETED_VAR="$RUN_COMPLETED" \
DURATION_VAR="$DURATION_SEC" \
PROV_SHA_VAR="$METADATA_SHA" \
COMPUTED_SHA_VAR="$COMPUTED_SHA" \
OBSERVER_RUN_ID_VAR="$OBSERVER_RUN_ID" \
OBSERVER_NOTES_VAR="$OBSERVER_NOTES" \
WORKFLOW_NAME_VAR="$WORKFLOW_NAME" \
HEAD_SHA_VAR="$HEAD_SHA" \
BRANCH_VAR="$BRANCH" \
python3 - "$RUNS_SUMMARY_PATH" <<'PY'
import json, os, sys, pathlib

path = pathlib.Path(sys.argv[1])
if path.exists():
    data = json.loads(path.read_text())
else:
    data = []

entry = {
    "run_id": os.environ["RUN_ID_VAR"],
    "trigger_mode": os.environ["TRIGGER_MODE_VAR"],
    "status": os.environ["CONCLUSION_VAR"],
    "sha_parity": os.environ["SHA_PARITY_VAR"].lower() == "true",
    "retries": int(os.environ.get("RETRIES_VAR", "0") or 0),
    "retry_origin": os.environ.get("RETRY_ORIGIN_VAR") or None,
    "run_started_at_utc": os.environ["RUN_STARTED_VAR"],
    "run_completed_at_utc": os.environ["RUN_COMPLETED_VAR"],
    "duration_sec": float(os.environ["DURATION_VAR"] or 0),
    "prov_sha": os.environ.get("PROV_SHA_VAR") or "",
    "computed_sha": os.environ.get("COMPUTED_SHA_VAR") or "",
    "observer_run_id": os.environ.get("OBSERVER_RUN_ID_VAR") or None,
    "observer_notes": os.environ.get("OBSERVER_NOTES_VAR") or "",
    "head_sha": os.environ.get("HEAD_SHA_VAR") or "",
    "workflow_name": os.environ.get("WORKFLOW_NAME_VAR") or "",
    "branch": os.environ.get("BRANCH_VAR") or ""
}

data = [d for d in data if d.get("run_id") != entry["run_id"]]
data.append(entry)
data.sort(key=lambda item: item.get("run_started_at_utc", ""))

tmp_path = path.with_suffix(".tmp")
tmp_path.write_text(json.dumps(data, indent=2) + "\n")
tmp_path.replace(path)
PY

if [ -n "$REL_ARTIFACT_PATH" ]; then
  log "Updating manifest via scripts/phase4-manifest-atomic.sh"
  bash "$ROOT/scripts/phase4-manifest-atomic.sh" \
    --manifest "$MANIFEST_PATH" \
    --run-id "$RUN_ID" \
    --artifact-path "$REL_ARTIFACT_PATH" \
    --evidence-type "artifact" \
    --recorded-at "$RECORDED_AT" \
    --sha-parity "$SHA_PARITY" \
    --notes "workflow=${WORKFLOW_NAME}, mode=${RUN_MODE}"
fi

log "Phase 4 auto collect completed for run_id=${RUN_ID}"
