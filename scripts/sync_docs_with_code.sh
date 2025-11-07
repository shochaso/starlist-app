#!/bin/bash

# ドキュメントとコードの同期スクリプト
# 実装されている機能を分析し、ドキュメントを自動更新

echo "🔍 Dartコードを分析してドキュメントを更新します..."

# 機能一覧を取得
FEATURES=$(find lib/features -type d -maxdepth 1 -not -path "lib/features" | sed 's|lib/features/||' | sort)

# 画面一覧を取得
SCREENS=$(find lib -name "*_screen.dart" -o -name "*_page.dart" | wc -l)

# プロバイダー一覧を取得  
PROVIDERS=$(find lib -name "*_provider.dart" | wc -l)

# サービス一覧を取得
SERVICES=$(find lib -name "*_service.dart" | wc -l)

echo "✅ 分析完了"
echo "  - 実装機能数: $(echo "$FEATURES" | wc -l)"
echo "  - 画面数: $SCREENS"
echo "  - プロバイダー数: $PROVIDERS"
echo "  - サービス数: $SERVICES"
echo ""
echo "📝 ドキュメント更新対象:"
echo "$FEATURES"




