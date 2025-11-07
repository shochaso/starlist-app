#!/bin/bash
set -e

echo "🚀 OCRプロキシの再デプロイを開始します..."

# 1. リポジトリを最新の状態に更新
cd ~/starlist-app
echo "📥 リポジトリを更新中..."
git pull origin fix/icon-debug-proxy

# 2. OCRプロキシディレクトリに移動
cd cloudrun/ocr-proxy

# 3. package.jsonを確認
echo ""
echo "📦 package.jsonの内容:"
cat package.json

# 4. 環境変数を設定（.env.docaiから読み込む）
if [ -f ../../.env.docai ]; then
  source ../../.env.docai
  echo ""
  echo "✅ 環境変数を読み込みました"
else
  echo ""
  echo "⚠️ .env.docaiが見つかりません。環境変数を手動で設定してください"
  exit 1
fi

# 環境変数の確認
echo ""
echo "環境変数の確認:"
echo "DOCUMENT_AI_PROJECT_ID: $DOCUMENT_AI_PROJECT_ID"
echo "DOCUMENT_AI_LOCATION: $DOCUMENT_AI_LOCATION"
echo "DOCUMENT_AI_PROCESSOR_ID: $DOCUMENT_AI_PROCESSOR_ID"

# 5. 環境変数ファイルを作成
cat > /tmp/docai.env <<EOF
DOCUMENT_AI_PROJECT_ID=$DOCUMENT_AI_PROJECT_ID
DOCUMENT_AI_LOCATION=$DOCUMENT_AI_LOCATION
DOCUMENT_AI_PROCESSOR_ID=$DOCUMENT_AI_PROCESSOR_ID
CORS_ALLOW_ORIGIN=http://localhost:8080,https://app.starlist.jp
EOF

echo ""
echo "📝 環境変数ファイルを作成しました: /tmp/docai.env"

# 6. Cloud Runにデプロイ
echo ""
echo "🚀 Cloud Runにデプロイ中..."
gcloud run deploy ocr-proxy \
  --source=. \
  --region=us-central1 \
  --allow-unauthenticated \
  --env-vars-file=/tmp/docai.env

# 7. デプロイ後の確認
echo ""
echo "✅ デプロイ完了"
echo ""
echo "⏳ 30秒待機してからログを確認します..."
sleep 30

echo ""
echo "📝 最新のログを確認:"
gcloud run services logs read ocr-proxy --region=us-central1 --limit=30 --format="table(timestamp,textPayload)"

echo ""
echo "📝 エラーログを確認:"
gcloud logging read \
  'resource.type="cloud_run_revision"
   resource.labels.service_name="ocr-proxy"
   resource.labels.location="us-central1"
   severity>=ERROR' \
  --freshness=5m --limit=10 --order=desc \
  --format="value(timestamp,textPayload,jsonPayload)"
