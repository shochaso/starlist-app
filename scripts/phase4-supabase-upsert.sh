#!/usr/bin/env bash
# Phase 4 Supabase metrics upsert helper
# Accepts canonical audit metrics fields and performs a single upsert keyed by run_id.

set -euo pipefail

TABLE_NAME="phase4_audit_metrics"
RUN_ID=""
STATUS=""
RETRIES="0"
DURATION="0"
VALIDATOR_VERDICT=""
PROV_SHA=""
COMPUTED_SHA=""
CREATED_AT=""
OBSERVED_AT=""
RETRIES_EXHAUSTED="false"
WINDOW_DAYS="7"
DRY_RUN="false"

usage() {
  cat <<'USAGE'
Usage: scripts/phase4-supabase-upsert.sh --run-id <id> --status <status> --duration <seconds> --validator-verdict <verdict> --prov-sha <sha> --computed-sha <sha> --created-at <UTC> --observed-at <UTC> [options]

Options:
  --retries <number>            Number of retries attempted (default: 0)
  --retries-exhausted <bool>    true/false (default: false)
  --window-days <number>        Observation window (default: 7)
  --table <name>                Supabase table name (default: phase4_audit_metrics)
  --dry-run                     Print payload without sending request
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --run-id) RUN_ID="$2"; shift 2 ;;
    --status) STATUS="$2"; shift 2 ;;
    --retries) RETRIES="$2"; shift 2 ;;
    --duration) DURATION="$2"; shift 2 ;;
    --validator-verdict) VALIDATOR_VERDICT="$2"; shift 2 ;;
    --prov-sha) PROV_SHA="$2"; shift 2 ;;
    --computed-sha) COMPUTED_SHA="$2"; shift 2 ;;
    --created-at) CREATED_AT="$2"; shift 2 ;;
    --observed-at) OBSERVED_AT="$2"; shift 2 ;;
    --retries-exhausted) RETRIES_EXHAUSTED="$2"; shift 2 ;;
    --window-days) WINDOW_DAYS="$2"; shift 2 ;;
    --table) TABLE_NAME="$2"; shift 2 ;;
    --dry-run) DRY_RUN="true"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 1 ;;
  esac
done

if [ -z "$RUN_ID" ] || [ -z "$STATUS" ] || [ -z "$VALIDATOR_VERDICT" ] || [ -z "$PROV_SHA" ] || [ -z "$COMPUTED_SHA" ] || [ -z "$CREATED_AT" ] || [ -z "$OBSERVED_AT" ]; then
  usage >&2
  exit 1
fi

SUPABASE_URL="${SUPABASE_URL:-}"
SUPABASE_SERVICE_KEY="${SUPABASE_SERVICE_KEY:-}"

if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_SERVICE_KEY" ]; then
  echo "Supabase URL または SERVICE_KEY が未設定です。環境変数 SUPABASE_URL / SUPABASE_SERVICE_KEY を確認してください。" >&2
  exit 1
fi

ENDPOINT="${SUPABASE_URL%/}/rest/v1/${TABLE_NAME}"

PAYLOAD=$(
RUN_ID="$RUN_ID" \
STATUS="$STATUS" \
RETRIES="$RETRIES" \
DURATION="$DURATION" \
VALIDATOR_VERDICT="$VALIDATOR_VERDICT" \
PROV_SHA="$PROV_SHA" \
COMPUTED_SHA="$COMPUTED_SHA" \
CREATED_AT="$CREATED_AT" \
OBSERVED_AT="$OBSERVED_AT" \
RETRIES_EXHAUSTED="$RETRIES_EXHAUSTED" \
WINDOW_DAYS="$WINDOW_DAYS" \
python3 - <<'PY'
import json, os, sys

payload = {
    "run_id": os.environ["RUN_ID"],
    "status": os.environ["STATUS"],
    "retries": int(os.environ.get("RETRIES", "0") or 0),
    "duration_sec": float(os.environ.get("DURATION", "0") or 0),
    "validator_verdict": os.environ["VALIDATOR_VERDICT"],
    "prov_sha": os.environ["PROV_SHA"],
    "computed_sha": os.environ["COMPUTED_SHA"],
    "created_at": os.environ["CREATED_AT"],
    "observed_at": os.environ["OBSERVED_AT"],
    "retries_exhausted": os.environ.get("RETRIES_EXHAUSTED", "false").lower() == "true",
    "window_days": int(os.environ.get("WINDOW_DAYS", "7") or 7),
}

print(json.dumps(payload))
PY
)

if [ "$DRY_RUN" = "true" ]; then
  echo "[Dry Run] POST $ENDPOINT"
  echo "$PAYLOAD"
  exit 0
fi

HTTP_RESPONSE=$(mktemp)
HTTP_CODE=$(curl -sS -X POST "$ENDPOINT" \
  -H "apikey: $SUPABASE_SERVICE_KEY" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_KEY" \
  -H "Content-Type: application/json" \
  -H "Prefer: resolution=merge-duplicates" \
  --data "$PAYLOAD" \
  -D - \
  -o "$HTTP_RESPONSE" \
  -w "%{http_code}")

case "$HTTP_CODE" in
  200|201|202|204)
    echo "Supabase upsert success (status=$HTTP_CODE, run_id=$RUN_ID)"
    rm -f "$HTTP_RESPONSE"
    exit 0
    ;;
  409)
    echo "Supabase upsert duplicate (run_id=$RUN_ID) — treating as success"
    rm -f "$HTTP_RESPONSE"
    exit 0
    ;;
  500|501|502|503|504)
    echo "Retryable server error from Supabase (status=$HTTP_CODE)."
    cat "$HTTP_RESPONSE"
    rm -f "$HTTP_RESPONSE"
    exit 75
    ;;
  422|403)
    echo "Non-retryable client error from Supabase (status=$HTTP_CODE)." >&2
    cat "$HTTP_RESPONSE" >&2
    rm -f "$HTTP_RESPONSE"
    exit 78
    ;;
  *)
    echo "Unexpected Supabase response (status=$HTTP_CODE)." >&2
    cat "$HTTP_RESPONSE" >&2
    rm -f "$HTTP_RESPONSE"
    exit 1
    ;;
esac
