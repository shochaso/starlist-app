#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $(basename "$0") \"request summary\"" >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
HISTORY_FILE="$REPO_ROOT/codex_request_history.md"

if [[ ! -f "$HISTORY_FILE" ]]; then
  echo '# Codex Request History' > "$HISTORY_FILE"
  echo >> "$HISTORY_FILE"
fi

timestamp=$(date '+%Y-%m-%d %H:%M:%S')
entry="$timestamp — $1"

echo "- $entry" >> "$HISTORY_FILE"

echo "Appended entry to $(realpath "$HISTORY_FILE")"
