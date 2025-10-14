#!/bin/zsh
set -euo pipefail

cd "$(dirname "$0")/.."

# ログディレクトリの作成
mkdir -p logs

# Log the prompt if provided via PROMPT_MSG env or arg
PROMPT_MSG_INPUT="${1:-${PROMPT_MSG:-}}"
if [[ -n "$PROMPT_MSG_INPUT" ]]; then
  dart scripts/prompt_logger.dart "$PROMPT_MSG_INPUT" | tail -n +1
fi

# Kill any previous flutter web runs on 8080 and browsersync
echo "🧹 Cleaning up previous processes..."
pkill -f "flutter_tools\.snapshot run -d chrome" || true
pkill -f "browser-sync" || true
sleep 2

# Run Flutter web on Chrome at port 8080 with hot reload (background)
echo "🚀 Starting Flutter Web on Chrome (port 8080)..."
echo "📝 Flutter log: logs/flutter.log"
flutter run -d chrome --web-port 8080 > logs/flutter.log 2>&1 &
FLUTTER_PID=$!

# Wait for Flutter to start (with timeout)
echo "⏳ Waiting for Flutter to start (max 120 seconds)..."
COUNTER=0
MAX_WAIT=60
until curl -sS http://localhost:8080 >/dev/null 2>&1; do
  sleep 2
  COUNTER=$((COUNTER + 1))
  
  # Check if Flutter process is still running
  if ! kill -0 $FLUTTER_PID 2>/dev/null; then
    echo ""
    echo "❌ Flutter process died! Check logs/flutter.log for errors:"
    tail -20 logs/flutter.log
    exit 1
  fi
  
  # Timeout check
  if [ $COUNTER -ge $MAX_WAIT ]; then
    echo ""
    echo "⏰ Timeout! Flutter did not start in 120 seconds."
    echo "📝 Last 20 lines of logs/flutter.log:"
    tail -20 logs/flutter.log
    exit 1
  fi
  
  # Progress indicator
  if [ $((COUNTER % 5)) -eq 0 ]; then
    echo "   ... still waiting ($((COUNTER * 2))s elapsed)"
  fi
done

echo "✅ Flutter started successfully on port 8080"

# Start BrowserSync proxy on port 3000
echo "🌐 Starting BrowserSync on http://localhost:3000"
echo "📝 BrowserSync log: logs/browsersync.log"
npx browser-sync start --config bs-config.js > logs/browsersync.log 2>&1 &
BS_PID=$!

# Wait for BrowserSync to start
sleep 3
COUNTER=0
MAX_WAIT=10
until curl -sS http://localhost:3000 >/dev/null 2>&1; do
  sleep 1
  COUNTER=$((COUNTER + 1))
  
  if ! kill -0 $BS_PID 2>/dev/null; then
    echo "❌ BrowserSync process died!"
    tail -10 logs/browsersync.log
    exit 1
  fi
  
  if [ $COUNTER -ge $MAX_WAIT ]; then
    echo "⏰ BrowserSync timeout!"
    exit 1
  fi
done

echo "✅ BrowserSync started successfully on port 3000"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ All services are running!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 Access: http://localhost:3000/#/home"
echo "📝 Flutter PID: $FLUTTER_PID"
echo "📝 BrowserSync PID: $BS_PID"
echo "📁 Logs:"
echo "   - logs/flutter.log"
echo "   - logs/browsersync.log"
echo ""
echo "🛑 To stop: pkill -f flutter && pkill -f browser-sync"
echo "📊 To check logs: tail -f logs/flutter.log"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"


