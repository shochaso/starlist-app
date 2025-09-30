#!/bin/zsh
set -euo pipefail

cd "$(dirname "$0")/.."

# Log the prompt if provided via PROMPT_MSG env or arg
PROMPT_MSG_INPUT="${1:-${PROMPT_MSG:-}}"
if [[ -n "$PROMPT_MSG_INPUT" ]]; then
  dart scripts/prompt_logger.dart "$PROMPT_MSG_INPUT" | tail -n +1
fi

# Kill any previous flutter web runs on 8080
pkill -f "flutter_tools\.snapshot run -d chrome" || true

# Run Flutter web on Chrome at port 8080 with auto-reload
flutter run -d chrome --web-port 8080 &
RUN_PID=$!

# Wait for server
until curl -sS -I http://127.0.0.1:8080 >/dev/null 2>&1; do
  sleep 1
done

echo "[Run OK]"

wait $RUN_PID || true


