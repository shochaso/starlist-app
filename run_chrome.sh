#!/bin/bash

# Starlist - Chrome起動スクリプト
# "c"または"C"コマンド用

echo "🧹 Flutterキャッシュをクリア中..."
flutter clean

echo ""
echo "🚀 ChromeでFlutterアプリを起動中..."
flutter run -d chrome

