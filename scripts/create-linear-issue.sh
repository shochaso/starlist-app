#!/usr/bin/env bash
# Linear APIを使用してIssueを作成するスクリプト
# 使用例: ./scripts/create-linear-issue.sh STA-8 "Production flow smoke test"

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <ISSUE_KEY> \"<TITLE>\" [API_KEY]"
  echo ""
  echo "例: $0 STA-8 \"Production flow smoke test\""
  echo ""
  echo "API_KEYが指定されない場合、LINEAR_API_KEY環境変数を使用します。"
  exit 1
fi

ISSUE_KEY="$1"
TITLE="$2"
API_KEY="${3:-${LINEAR_API_KEY:-}}"

if [[ -z "$API_KEY" ]]; then
  echo "❌ Error: Linear APIキーが必要です。"
  echo ""
  echo "以下のいずれかの方法でAPIキーを設定してください："
  echo "1. 環境変数: export LINEAR_API_KEY='your-api-key'"
  echo "2. 引数として渡す: $0 $ISSUE_KEY \"$TITLE\" 'your-api-key'"
  echo ""
  echo "Linear APIキーの取得方法:"
  echo "1. Linearにログイン"
  echo "2. Settings > API > Personal API keys"
  echo "3. 新しいキーを生成"
  exit 1
fi

echo "🔍 チーム情報を取得中..."
TEAMS_RESPONSE=$(curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: ${API_KEY}" \
  -d '{
    "query": "query { teams { nodes { id name key } } }"
  }')

echo "$TEAMS_RESPONSE" | jq -r '.data.teams.nodes[] | "\(.key): \(.name) (ID: \(.id))"' || {
  echo "❌ Error: チーム情報の取得に失敗しました。"
  echo "Response: $TEAMS_RESPONSE"
  exit 1
}

# STA-* の形式からチームキーを抽出（例: STA-8 → STA）
TEAM_KEY=$(echo "$ISSUE_KEY" | cut -d'-' -f1)

echo ""
echo "📝 Issue作成中: ${ISSUE_KEY} - ${TITLE}"

# チームIDを取得
TEAM_ID=$(echo "$TEAMS_RESPONSE" | jq -r ".data.teams.nodes[] | select(.key == \"${TEAM_KEY}\") | .id")

if [[ -z "$TEAM_ID" ]]; then
  echo "❌ Error: チーム '${TEAM_KEY}' が見つかりません。"
  exit 1
fi

echo "✅ チームID: ${TEAM_ID}"

# Issue作成
CREATE_RESPONSE=$(curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: ${API_KEY}" \
  -d "{
    \"query\": \"mutation { issueCreate(input: { teamId: \\\"${TEAM_ID}\\\", title: \\\"${TITLE}\\\", description: \\\"Created via API for GitHub PR #54 integration test\\\" }) { success issue { id identifier title url } } }\"
  }")

SUCCESS=$(echo "$CREATE_RESPONSE" | jq -r '.data.issueCreate.success // false')
ISSUE_ID=$(echo "$CREATE_RESPONSE" | jq -r '.data.issueCreate.issue.identifier // empty')
ISSUE_URL=$(echo "$CREATE_RESPONSE" | jq -r '.data.issueCreate.issue.url // empty')

if [[ "$SUCCESS" == "true" && -n "$ISSUE_ID" ]]; then
  echo "✅ Issue作成成功: ${ISSUE_ID}"
  echo "🔗 URL: ${ISSUE_URL}"
  echo ""
  echo "次のステップ:"
  echo "1. Linearで ${ISSUE_ID} が作成されたことを確認"
  echo "2. PR #54のタイトルに [${ISSUE_ID}] が含まれているため、自動リンクされる可能性があります"
else
  echo "❌ Error: Issue作成に失敗しました。"
  echo "Response: $CREATE_RESPONSE"
  exit 1
fi

