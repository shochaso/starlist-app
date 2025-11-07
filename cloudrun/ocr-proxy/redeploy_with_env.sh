# Cloud Shellで実行: 環境変数を設定して再デプロイ

# 1. 環境変数を直接設定（.env.docaiがない場合）
export DOCUMENT_AI_PROJECT_ID=calm-library-460413-k1
export DOCUMENT_AI_LOCATION=us-central1
export DOCUMENT_AI_PROCESSOR_ID=a3a48b7099e2e989

# 2. 環境変数の確認
echo "環境変数の確認:"
echo "DOCUMENT_AI_PROJECT_ID: $DOCUMENT_AI_PROJECT_ID"
echo "DOCUMENT_AI_LOCATION: $DOCUMENT_AI_LOCATION"
echo "DOCUMENT_AI_PROCESSOR_ID: $DOCUMENT_AI_PROCESSOR_ID"

# 3. 環境変数ファイルを作成
cat > /tmp/docai.env <<EOF
DOCUMENT_AI_PROJECT_ID=$DOCUMENT_AI_PROJECT_ID
DOCUMENT_AI_LOCATION=$DOCUMENT_AI_LOCATION
DOCUMENT_AI_PROCESSOR_ID=$DOCUMENT_AI_PROCESSOR_ID
CORS_ALLOW_ORIGIN=http://localhost:8080,https://app.starlist.jp
EOF

echo ""
echo "📝 環境変数ファイルを作成しました: /tmp/docai.env"
cat /tmp/docai.env

# 4. デプロイが完了したら、環境変数を設定して再デプロイ
echo ""
echo "🚀 Cloud Runにデプロイ中..."
gcloud run deploy ocr-proxy \
  --source=. \
  --region=us-central1 \
  --allow-unauthenticated \
  --env-vars-file=/tmp/docai.env

# 5. デプロイ後の確認
echo ""
echo "✅ デプロイ完了"
echo ""
echo "⏳ 30秒待機してからログを確認します..."
sleep 30

echo ""
echo "📝 最新のログを確認:"
gcloud run services logs read ocr-proxy --region=us-central1 --limit=20 --format="table(timestamp,severity,textPayload)"

