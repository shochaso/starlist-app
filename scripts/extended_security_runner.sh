#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/extended_security_runner.sh [options]

Options:
  --ref <branch>           Target branch ref to monitor (required unless --run-id is given)
  --run-id <id>            Existing workflow run ID to monitor instead of branch lookup
  --repo <owner/name>      Repository (default: current directory remote)
  --workflow <file>        Workflow file name (default: extended-security.yml)
  --out <dir>              Output directory for downloaded artifacts
  --timeout <seconds>      Maximum seconds to wait (default: 1800)
  --interval <seconds>     Polling interval in seconds (default: 15)
  -h, --help               Show this help message

Example:
  scripts/extended_security_runner.sh \
    --ref chore/extended-security-thresholds \
    --out artifacts/extended-security-$(date +%Y%m%d-%H%M%S)
USAGE
}

WORKFLOW="extended-security.yml"
TIMEOUT=1800
INTERVAL=15
OUT_DIR=""
REF=""
REPO=""
RUN_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --workflow)
      WORKFLOW="$2"
      shift 2
      ;;
    --timeout)
      TIMEOUT="$2"
      shift 2
      ;;
    --interval)
      INTERVAL="$2"
      shift 2
      ;;
    --out)
      OUT_DIR="$2"
      shift 2
      ;;
    --ref)
      REF="$2"
      shift 2
      ;;
    --repo)
      REPO="$2"
      shift 2
      ;;
    --run-id)
      RUN_ID="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$RUN_ID" && -z "$REF" ]]; then
  echo "Error: either --run-id or --ref must be provided" >&2
  usage
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "Error: gh CLI is required" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required" >&2
  exit 1
fi

if [[ -z "$REPO" ]]; then
  if REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null); then
    :
  else
    remote_url=$(git config --get remote.origin.url 2>/dev/null || true)
    if [[ -n "$remote_url" ]]; then
      remote_url="${remote_url%.git}"
      if [[ "$remote_url" == https://github.com/* ]]; then
        REPO=${remote_url#https://github.com/}
      elif [[ "$remote_url" == git@github.com:* ]]; then
        REPO=${remote_url#git@github.com:}
      else
        REPO=""
      fi
    fi
  fi
fi

if [[ -z "$REPO" ]]; then
  echo "Error: repository could not be determined; please provide --repo" >&2
  exit 1
fi

if [[ -z "$OUT_DIR" ]]; then
  OUT_DIR="artifacts/${WORKFLOW%.*}-$(date +%Y%m%d-%H%M%S)"
fi

mkdir -p "$OUT_DIR"

cleanup() {
  echo "Interrupted." >&2
  exit 130
}
trap cleanup INT

START_TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DEADLINE=$((SECONDS + TIMEOUT))

lookup_run_id() {
  gh run list --repo "$REPO" \
    --workflow "$WORKFLOW" --limit 20 \
    --json databaseId,headBranch,createdAt,status \
    | jq -r \
        --arg ref "$REF" \
        --arg started "$START_TS" \
        '[.[] | select(.headBranch == $ref) | select(.createdAt >= $started)] | first | .databaseId // empty'
}

if [[ -z "$RUN_ID" ]]; then
  echo "Waiting for workflow run of $WORKFLOW on branch $REF..."
  while [[ -z "$RUN_ID" && SECONDS -lt DEADLINE ]]; do
    RUN_ID=$(lookup_run_id || true)
    if [[ -z "$RUN_ID" ]]; then
      sleep "$INTERVAL"
    fi
  done
  if [[ -z "$RUN_ID" ]]; then
    echo "Timed out waiting for workflow run to appear." >&2
    exit 124
  fi
fi

echo "Monitoring run ID $RUN_ID on $REPO"

STATUS=""
CONCLUSION=""
RUN_URL=""
while [[ SECONDS -lt DEADLINE ]]; do
  run_json=$(gh run view "$RUN_ID" --repo "$REPO" --json status,conclusion,htmlUrl,headBranch 2>/dev/null || true)
  if [[ -z "$run_json" ]]; then
    echo "Unable to retrieve run details. Retrying..." >&2
    sleep "$INTERVAL"
    continue
  fi
  STATUS=$(jq -r '.status' <<<"$run_json")
  CONCLUSION=$(jq -r '.conclusion // ""' <<<"$run_json")
  RUN_URL=$(jq -r '.htmlUrl // ""' <<<"$run_json")
  printf 'Status: %s (%s)\n' "$STATUS" "${CONCLUSION:-pending}"
  if [[ "$STATUS" == "completed" ]]; then
    break
  fi
  sleep "$INTERVAL"
end

if [[ "$STATUS" != "completed" ]]; then
  echo "Timed out waiting for completion." >&2
  exit 124
fi

echo "Run completed with conclusion: ${CONCLUSION:-unknown}"
if [[ -n "$RUN_URL" ]]; then
  echo "Run URL: $RUN_URL"
fi

echo "Downloading artifacts to $OUT_DIR"
if ! gh run download "$RUN_ID" --repo "$REPO" --dir "$OUT_DIR"; then
  echo "Warning: artifact download failed." >&2
fi

if [[ -z $(find "$OUT_DIR" -mindepth 1 -print -quit 2>/dev/null) ]]; then
  echo "Warning: no artifacts found in $OUT_DIR" >&2
else
  echo "Artifacts saved under $OUT_DIR"
fi
