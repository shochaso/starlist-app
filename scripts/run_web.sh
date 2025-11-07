#!/usr/bin/env bash
set -euo pipefail

: "${DOC_AI_ENV_FILE:=.env.docai}"

if [[ -f "$DOC_AI_ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  set -a
  source "$DOC_AI_ENV_FILE"
  set +a
fi

: "${DOCUMENT_AI_PROJECT_ID:?DOCUMENT_AI_PROJECT_ID is required}"
: "${DOCUMENT_AI_LOCATION:?DOCUMENT_AI_LOCATION is required}"
: "${DOCUMENT_AI_PROCESSOR_ID:?DOCUMENT_AI_PROCESSOR_ID is required}"
: "${API_BASE:?API_BASE is required (Cloud Run URL)}"

FLUTTER_BIN="${FLUTTER_BIN:-flutter}"

if ! command -v "$FLUTTER_BIN" >/dev/null 2>&1; then
  if [[ -x "./apps/flutter/bin/flutter" ]]; then
    FLUTTER_BIN="./apps/flutter/bin/flutter"
  else
    echo "flutter executable not found. Set FLUTTER_BIN to the flutter command." >&2
    exit 1
  fi
fi

WEB_PORT=${WEB_PORT:-8080}

exec "$FLUTTER_BIN" run -d chrome \
  --web-port "$WEB_PORT" \
  --web-hostname localhost \
  --dart-define=FLUTTER_WEB_AUTO_DETECT=false \
  --dart-define=DOCUMENT_AI_PROJECT_ID="$DOCUMENT_AI_PROJECT_ID" \
  --dart-define=DOCUMENT_AI_LOCATION="$DOCUMENT_AI_LOCATION" \
  --dart-define=DOCUMENT_AI_PROCESSOR_ID="$DOCUMENT_AI_PROCESSOR_ID" \
  --dart-define=API_BASE="$API_BASE"
