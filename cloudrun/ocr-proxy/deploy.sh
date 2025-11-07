#!/bin/bash
set -e

cd "$(dirname "$0")"

# 環境変数を読み込み
if [ -f ../../.env.docai ]; then
  source ../../.env.docai
fi

# 環境変数の確認
if [ -z "$DOCUMENT_AI_PROJECT_ID" ] || [ -z "$DOCUMENT_AI_LOCATION" ] || [ -z "$DOCUMENT_AI_PROCESSOR_ID" ]; then
  echo "❌ 環境変数が設定されていません"
  echo "DOCUMENT_AI_PROJECT_ID: $DOCUMENT_AI_PROJECT_ID"
  echo "DOCUMENT_AI_LOCATION: $DOCUMENT_AI_LOCATION"
  echo "DOCUMENT_AI_PROCESSOR_ID: $DOCUMENT_AI_PROCESSOR_ID"
  exit 1
fi

# 環境変数ファイルを作成
cat > /tmp/docai.env <<EOF
DOCUMENT_AI_PROJECT_ID=$DOCUMENT_AI_PROJECT_ID
DOCUMENT_AI_LOCATION=$DOCUMENT_AI_LOCATION
DOCUMENT_AI_PROCESSOR_ID=$DOCUMENT_AI_PROCESSOR_ID
CORS_ALLOW_ORIGIN=http://localhost:8080,https://app.starlist.jp
EOF

echo "🚀 Cloud Runにデプロイ中..."
gcloud run deploy ocr-proxy \
  --source=. \
  --region=us-central1 \
  --allow-unauthenticated \
  --env-vars-file=/tmp/docai.env

echo "✅ デプロイ完了"
echo ""
echo "📝 デプロイ後の確認:"
echo "gcloud run services logs read ocr-proxy --region=us-central1 --limit=20"

