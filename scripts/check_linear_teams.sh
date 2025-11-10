#!/usr/bin/env bash
set -euo pipefail

# Linearのすべてのチーム一覧からKeyとIDを取得（表示用）
# 使用例: LINEAR_API_KEY=lin_xxxxxxxxxxxxx ./scripts/check_linear_teams.sh

LINEAR_API_KEY="${LINEAR_API_KEY:-}"
API=https://api.linear.app/graphql

if [[ -z "$LINEAR_API_KEY" ]]; then
  echo "⚠️  LINEAR_API_KEY が設定されていません"
  echo "使用例: LINEAR_API_KEY=lin_xxxxxxxxxxxxx ./scripts/check_linear_teams.sh"
  exit 1
fi

echo "→ Linear チーム一覧取得"
curl -sS "$API" \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{"query":"{ teams(first:50){ nodes { id name key } } }"}' | \
  jq -r '.data.teams.nodes[] | "\(.key) | \(.name) | \(.id)"' | \
  column -t -s '|' || echo "エラー: APIキーまたは権限を確認してください"

