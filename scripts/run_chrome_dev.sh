#!/bin/bash
# Flutter Web を Chrome で実行（明示的な設定付き）
# Usage: ./scripts/run_chrome_dev.sh

set -euo pipefail

cd "$(dirname "$0")/.."

# Chrome 実行ファイルのパスを設定
export CHROME_EXECUTABLE="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# Chrome が存在するか確認
if [ ! -f "$CHROME_EXECUTABLE" ]; then
  echo "❌ Chrome executable not found at: $CHROME_EXECUTABLE"
  echo "Please install Google Chrome or set CHROME_EXECUTABLE environment variable"
  exit 1
fi

echo "✅ Chrome executable: $CHROME_EXECUTABLE"

# 開発用Chromeプロファイルディレクトリを作成
mkdir -p .chrome-dev-profile
echo "✅ Using Chrome dev profile: $(pwd)/.chrome-dev-profile"

# Flutter clean & pub get（必要に応じて）
if [ "${FLUTTER_CLEAN:-false}" = "true" ]; then
  echo "🧹 Running flutter clean..."
  flutter clean
fi

if [ "${FLUTTER_PUB_GET:-true}" = "true" ]; then
  echo "📦 Running flutter pub get..."
  flutter pub get
fi

# Flutter run with explicit Chrome settings
echo ""
echo "🚀 Starting Flutter Web on Chrome..."
echo "   Port: 8080"
echo "   Hostname: localhost"
echo "   Renderer: html"
echo "   User Data Dir: $(pwd)/.chrome-dev-profile"
echo ""
echo "📝 Manual steps if auto-connect fails:"
echo "   1. Open Chrome manually: http://localhost:8080"
echo "   2. Open DevTools (F12 or Cmd+Option+I)"
echo "   3. Check Flutter DevTools connection"
echo ""

flutter run -d chrome \
  --web-port 8080 \
  --web-hostname localhost


# Usage: ./scripts/run_chrome_dev.sh

set -euo pipefail

cd "$(dirname "$0")/.."

# Chrome 実行ファイルのパスを設定
export CHROME_EXECUTABLE="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# Chrome が存在するか確認
if [ ! -f "$CHROME_EXECUTABLE" ]; then
  echo "❌ Chrome executable not found at: $CHROME_EXECUTABLE"
  echo "Please install Google Chrome or set CHROME_EXECUTABLE environment variable"
  exit 1
fi

echo "✅ Chrome executable: $CHROME_EXECUTABLE"

# 開発用Chromeプロファイルディレクトリを作成
mkdir -p .chrome-dev-profile
echo "✅ Using Chrome dev profile: $(pwd)/.chrome-dev-profile"

# Flutter clean & pub get（必要に応じて）
if [ "${FLUTTER_CLEAN:-false}" = "true" ]; then
  echo "🧹 Running flutter clean..."
  flutter clean
fi

if [ "${FLUTTER_PUB_GET:-true}" = "true" ]; then
  echo "📦 Running flutter pub get..."
  flutter pub get
fi

# Flutter run with explicit Chrome settings
echo ""
echo "🚀 Starting Flutter Web on Chrome..."
echo "   Port: 8080"
echo "   Hostname: localhost"
echo "   Renderer: html"
echo "   User Data Dir: $(pwd)/.chrome-dev-profile"
echo ""
echo "📝 Manual steps if auto-connect fails:"
echo "   1. Open Chrome manually: http://localhost:8080"
echo "   2. Open DevTools (F12 or Cmd+Option+I)"
echo "   3. Check Flutter DevTools connection"
echo ""

flutter run -d chrome \
  --web-port 8080 \
  --web-hostname localhost

