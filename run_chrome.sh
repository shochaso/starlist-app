#!/bin/bash

# Starlist - Chrome起動スクリプト
# "c"または"C"コマンド用
# Chrome自動検出問題対応: 明示的な設定付き

set -euo pipefail

cd "$(dirname "$0")"

# Chrome 実行ファイルのパスを設定
export CHROME_EXECUTABLE="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# Chrome が存在するか確認
if [ ! -f "$CHROME_EXECUTABLE" ]; then
  echo "❌ Chrome executable not found at: $CHROME_EXECUTABLE"
  echo "Please install Google Chrome or set CHROME_EXECUTABLE environment variable"
  exit 1
fi

echo "✅ Chrome executable: $CHROME_EXECUTABLE"

# 開発用Chromeプロファイルディレクトリを作成（既存プロファイルとの競合回避）
mkdir -p .chrome-dev-profile
echo "✅ Using Chrome dev profile: $(pwd)/.chrome-dev-profile"

echo ""
echo "🧹 Flutterキャッシュをクリア中..."
flutter clean

echo ""
echo "📦 依存関係を取得中..."
flutter pub get

echo ""
echo "🚀 ChromeでFlutterアプリを起動中..."
echo "   Port: 8080"
echo "   Hostname: localhost"
echo "   Renderer: html"
echo "   User Data Dir: $(pwd)/.chrome-dev-profile"
echo ""
echo "📝 自動接続に失敗した場合の手動手順:"
echo "   1. Chromeを手動で開く: http://localhost:8080"
echo "   2. DevToolsを開く (F12 または Cmd+Option+I)"
echo "   3. Flutter DevTools接続を確認"
echo ""

flutter run -d chrome \
  --web-port 8080 \
  --web-hostname localhost

