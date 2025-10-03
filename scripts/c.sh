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
sleep 1

# Run Flutter web on Chrome at port 8080 with hot reload
echo "🚀 Starting Flutter Web on Chrome (port 8080)..."
flutter run -d chrome --web-port 8080


