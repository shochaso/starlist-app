#!/usr/bin/env bash
# Factory CLI連携スクリプト
# 使用例: ./bin/factory-run.sh STA-11 "Integrate Factory CLI automation"

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <ISSUE_KEY> \"<TITLE>\""
  echo ""
  echo "例: $0 STA-11 \"Integrate Factory CLI automation\""
  exit 1
fi

ISSUE_KEY="$1"
TITLE="$2"

echo "[Factory] health-check start"
gh workflow run "Lint & Build Check" || true
gh run list --limit 5 | head -n 5
echo "[Factory] done"

echo ""
echo "🔧 Factory CLI連携: ${ISSUE_KEY} - ${TITLE}"
echo ""
echo "このスクリプトはFactory環境での実行を想定しています。"
echo "以下のコマンドをFactory環境で実行してください:"
echo ""
echo "1. ブランチ作成とPR作成:"
echo "   bin/new.sh ${ISSUE_KEY} \"${TITLE}\""
echo ""
echo "2. Factory環境での作業:"
echo "   - Remote Workspaceで実装"
echo "   - 重い依存（Flutter/LLM/DB）の実行"
echo "   - GPU/マルチサービスの統合実行"
echo ""
echo "3. PR操作（管理者権限が必要な場合）:"
echo "   gh pr edit <PR_NUMBER> --add-reviewer @reviewer"
echo "   gh pr merge <PR_NUMBER> --squash --delete-branch --admin"
echo ""
echo "4. Linear自動遷移確認:"
echo "   - PR作成 → In Progress"
echo "   - レビュー依頼 → In Review"
echo "   - マージ → Done"
echo ""
echo "📝 詳細: docs/ops/WORKFLOW_MODEL.md"
