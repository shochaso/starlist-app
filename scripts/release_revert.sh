#!/usr/bin/env bash
# scripts/release_revert.sh
# リリースロールバックスクリプト
# Usage: ./scripts/release_revert.sh <TAG_TO_REVERT>

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <TAG_TO_REVERT>"
  echo ""
  echo "例: $0 v2025.11.12.1407"
  exit 1
fi

TAG_TO_REVERT="$1"
REPO="${GITHUB_REPOSITORY:-shochaso/starlist-app}"

echo "🔄 リリースロールバック開始: $TAG_TO_REVERT"
echo ""

# 1. タグが存在するか確認
if ! git rev-parse "$TAG_TO_REVERT" >/dev/null 2>&1; then
  echo "❌ エラー: タグ $TAG_TO_REVERT が見つかりません"
  exit 1
fi

# 2. タグを削除
echo "📋 Step 1: タグを削除..."
git tag -d "$TAG_TO_REVERT" || true
git push origin ":refs/tags/$TAG_TO_REVERT" || true

# 3. 前のコミットに戻す
echo "📋 Step 2: 前のコミットに戻す..."
PREV_COMMIT=$(git rev-parse "$TAG_TO_REVERT^")
git reset --hard "$PREV_COMMIT"

# 4. mainブランチにpush（force-pushが必要な場合は警告）
echo "📋 Step 3: mainブランチを更新..."
echo "⚠️  Warning: Force-pushが必要な場合があります"
echo "   実行するには: git push origin main --force"
echo ""

# 5. 新しいタグを作成（ロールバック済みを示す）
NEW_TAG="${TAG_TO_REVERT}-reverted-$(date +%Y%m%d%H%M)"
echo "📋 Step 4: ロールバックタグを作成: $NEW_TAG"
git tag "$NEW_TAG"
git push origin "$NEW_TAG"

# 6. GitHub Releaseを削除（手動）
echo ""
echo "📋 Step 5: GitHub Releaseの削除（手動）"
echo "   URL: https://github.com/$REPO/releases/tag/$TAG_TO_REVERT"
echo "   手動で削除してください"
echo ""

echo "✅ ロールバック完了"
echo "   削除したタグ: $TAG_TO_REVERT"
echo "   作成したタグ: $NEW_TAG"

