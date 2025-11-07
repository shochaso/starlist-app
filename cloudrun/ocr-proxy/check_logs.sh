# Cloud Shellで実行: 詳細ログ確認コマンド

# 1. 最新のリビジョン情報を確認
echo "📋 最新のリビジョン情報:"
gcloud run services describe ocr-proxy --region=us-central1 --format="value(status.latestReadyRevisionName)"

# 2. 最新のログを確認（severityを含む）
echo ""
echo "📝 最新のログ（severityを含む）:"
gcloud run services logs read ocr-proxy --region=us-central1 --limit=30 --format="table(timestamp,severity,textPayload)"

# 3. エラーログを詳細に確認（JSON形式）
echo ""
echo "📝 エラーログ（詳細JSON）:"
gcloud logging read \
  'resource.type="cloud_run_revision"
   resource.labels.service_name="ocr-proxy"
   resource.labels.location="us-central1"
   severity>=ERROR' \
  --freshness=1h --limit=10 --order=desc \
  --format=json | jq -r '.[] | "\(.timestamp) [\(.severity)] \(.textPayload // .jsonPayload.message // .jsonPayload.error // "")"'

# 4. 500エラーが発生したリクエストの詳細を確認
echo ""
echo "📝 500エラーの詳細:"
gcloud logging read \
  'resource.type="cloud_run_revision"
   resource.labels.service_name="ocr-proxy"
   httpRequest.status=500' \
  --freshness=1h --limit=10 --order=desc \
  --format=json | jq -r '.[] | "\(.timestamp) Status: \(.httpRequest.status) - \(.textPayload // .jsonPayload.message // .jsonPayload.error // "")"'

# 5. 全てのログを時系列で確認
echo ""
echo "📝 全てのログ（時系列）:"
gcloud run services logs read ocr-proxy --region=us-central1 --limit=50 --format="table(timestamp,severity,textPayload)" | grep -E "ERROR|WARNING|OCR Error|listening"
