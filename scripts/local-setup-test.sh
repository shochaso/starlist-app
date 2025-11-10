#!/usr/bin/env bash
set -euo pipefail

# Linearの自動遷移テスト用のサンプル差分を作成
# 使用例: ./scripts/local-setup-test.sh

BRANCH_NAME="LIN-001-my-page-wording"
BASE_BRANCH="${BASE_BRANCH:-main}"

echo "=== Linear自動遷移テスト用PR作成 ==="
echo ""

# 最新化
echo "1. リポジトリを最新化..."
git fetch --all --prune

# ブランチ作成
echo "2. ブランチ作成: ${BRANCH_NAME}"
git checkout -B "${BRANCH_NAME}" "origin/${BASE_BRANCH}" 2>/dev/null || \
git checkout -B "${BRANCH_NAME}" "${BASE_BRANCH}" || {
  echo "⚠️  ブランチ作成に失敗しました。現在のブランチを確認してください。"
  exit 1
}

# ちょい差分
echo "3. テストファイル作成..."
mkdir -p docs
echo "auto-link test $(date -u +"%Y-%m-%dT%H:%MZ")" >> docs/auto-link-test.md
git add docs/auto-link-test.md
git commit -m "chore(ui): LIN-001 wording tweak" || {
  echo "⚠️  コミットに失敗しました。変更がない可能性があります。"
  exit 1
}

# プッシュ
echo "4. ブランチをプッシュ..."
git push -u origin "${BRANCH_NAME}" || {
  echo "⚠️  プッシュに失敗しました。SSH接続または認証を確認してください。"
  exit 1
}

# PR作成
echo "5. PR作成..."
PR_URL=$(gh pr create \
  --title "chore(ui): LIN-001 wording tweak" \
  --body "Purpose: auto-link test to Linear

DoD: PR→In Progress, Review→In Review, Merge→Done" \
  --base "${BASE_BRANCH}" \
  --json url --jq .url 2>/dev/null) || {
  echo "⚠️  PR作成に失敗しました。GitHub CLIの認証を確認してください。"
  exit 1
}

echo "✅ PR作成完了: ${PR_URL}"

# 自分にレビュー依頼
echo "6. レビュー依頼..."
gh pr edit "${PR_URL}" --add-reviewer @me 2>/dev/null || {
  echo "⚠️  レビュー依頼に失敗しました（スキップ）。"
}

echo ""
echo "=== 完了 ==="
echo "PR URL: ${PR_URL}"
echo ""
echo "次のステップ:"
echo "1. Linearでチケット LIN-001 が In Progress になっているか確認"
echo "2. PRにレビューを追加すると In Review に遷移するか確認"
echo "3. PRをマージすると Done に遷移するか確認"
