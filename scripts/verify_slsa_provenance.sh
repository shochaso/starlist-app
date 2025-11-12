#!/bin/bash
# SLSA Provenance 成功run検証スクリプト
# Usage: ./scripts/verify_slsa_provenance.sh <RUN_ID> [TAG]

set -euo pipefail

RUN_ID="${1:-}"
TAG="${2:-}"

if [ -z "$RUN_ID" ]; then
  echo "Usage: $0 <RUN_ID> [TAG]"
  exit 1
fi

echo "🔍 SLSA Provenance Run検証: $RUN_ID"
echo "=================================="

# GitHub APIでrun情報を取得
RUN_INFO=$(gh run view "$RUN_ID" --json conclusion,status,event,headBranch,headSha,workflowName,displayTitle --repo "$(gh repo view --json nameWithOwner -q .nameWithOwner)")

CONCLUSION=$(echo "$RUN_INFO" | jq -r '.conclusion')
STATUS=$(echo "$RUN_INFO" | jq -r '.status')
EVENT=$(echo "$RUN_INFO" | jq -r '.event')
WORKFLOW=$(echo "$RUN_INFO" | jq -r '.workflowName')

echo "📊 Run情報:"
echo "  - Workflow: $WORKFLOW"
echo "  - Event: $EVENT"
echo "  - Status: $STATUS"
echo "  - Conclusion: $CONCLUSION"
echo ""

if [ "$CONCLUSION" != "success" ]; then
  echo "❌ Runは成功していません (Conclusion: $CONCLUSION)"
  exit 1
fi

# Artifactをダウンロード
echo "📦 Artifactダウンロード中..."
ARTIFACT_DIR="/tmp/slsa_verify_${RUN_ID}"
mkdir -p "$ARTIFACT_DIR"
gh run download "$RUN_ID" --dir "$ARTIFACT_DIR" --repo "$(gh repo view --json nameWithOwner -q .nameWithOwner)" || {
  echo "⚠️ Artifactダウンロード失敗（artifactが存在しない可能性）"
  exit 1
}

# Provenanceファイルを検索
PROVENANCE_FILE=$(find "$ARTIFACT_DIR" -name "provenance-*.json" | head -1)

if [ -z "$PROVENANCE_FILE" ]; then
  echo "❌ Provenanceファイルが見つかりません"
  exit 1
fi

echo "✅ Provenanceファイル: $PROVENANCE_FILE"
echo ""

# predicateType確認
PREDICATE_TYPE=$(jq -r '.predicateType // empty' "$PROVENANCE_FILE")
if [ -z "$PREDICATE_TYPE" ]; then
  echo "❌ predicateTypeが見つかりません"
  exit 1
fi

echo "✅ predicateType: $PREDICATE_TYPE"

# SHA256計算
SHA256=$(sha256sum "$PROVENANCE_FILE" | cut -d' ' -f1)
echo "✅ SHA256: $SHA256"
echo ""

# 内容確認
echo "📄 Provenance内容:"
jq '.' "$PROVENANCE_FILE"
echo ""

# タグ確認
PROVENANCE_TAG=$(jq -r '.invocation.release // empty' "$PROVENANCE_FILE")
if [ -n "$PROVENANCE_TAG" ]; then
  echo "✅ Release Tag: $PROVENANCE_TAG"
  if [ -n "$TAG" ] && [ "$PROVENANCE_TAG" != "$TAG" ]; then
    echo "⚠️ タグ不一致: 期待値=$TAG, 実際=$PROVENANCE_TAG"
  fi
fi

echo ""
echo "✅ 検証完了"
echo "  - predicateType: $PREDICATE_TYPE"
echo "  - SHA256: $SHA256"
echo "  - Release Tag: ${PROVENANCE_TAG:-N/A}"
