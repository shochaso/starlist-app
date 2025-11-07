# Cloud Shellで実行: デプロイ後のエラーログ確認

# 1. 最新のリビジョン情報を確認
echo "📋 最新のリビジョン情報:"
gcloud run services describe ocr-proxy --region=us-central1 --format="value(status.latestReadyRevisionName)"

# 2. 最新のリビジョンが起動してからのログを確認
echo ""
echo "📝 最新のリビジョンのログ（エラーを含む）:"
gcloud run services logs read ocr-proxy --region=us-central1 --limit=20 --format="table(timestamp,severity,textPayload)"

# 3. エラーログの詳細を確認（JSON形式）
echo ""
echo "📝 エラーログの詳細（JSON形式）:"
gcloud logging read \
  'resource.type="cloud_run_revision"
   resource.labels.service_name="ocr-proxy"
   resource.labels.location="us-central1"
   severity>=ERROR' \
  --freshness=10m --limit=5 --order=desc \
  --format=json | jq '.[] | {timestamp, severity, textPayload, jsonPayload}'

# 4. OCR Errorが含まれるログを確認
echo ""
echo "📝 OCR Errorが含まれるログ:"
gcloud logging read \
  'resource.type="cloud_run_revision"
   resource.labels.service_name="ocr-proxy"
   textPayload=~"OCR Error"' \
  --freshness=10m --limit=5 --order=desc \
  --format=json | jq -r '.[] | "\(.timestamp) \(.textPayload)"'

# 5. 全てのログを確認（エラーに関連するもの）
echo ""
echo "📝 全てのログ（エラー関連）:"
gcloud logging read \
  'resource.type="cloud_run_revision"
   resource.labels.service_name="ocr-proxy"
   (textPayload=~"Error" OR textPayload=~"error" OR severity>=ERROR)' \
  --freshness=10m --limit=10 --order=desc \
  --format=json | jq -r '.[] | "\(.timestamp) [\(.severity)] \(.textPayload // .jsonPayload.message // .jsonPayload.error // "")"'

