# Cloud Shellで実行: 詳細なエラーログ確認

# JSON形式でエラーログを確認
gcloud logging read \
  'resource.type="cloud_run_revision"
   resource.labels.service_name="ocr-proxy"
   resource.labels.location="us-central1"
   severity>=ERROR' \
  --freshness=1h --limit=5 --order=desc \
  --format=json | jq '.[] | {timestamp, severity, textPayload, jsonPayload}'

# 特に500エラーが発生したリクエストの詳細
gcloud logging read \
  'resource.type="cloud_run_revision"
   resource.labels.service_name="ocr-proxy"
   httpRequest.status=500' \
  --freshness=1h --limit=3 --order=desc \
  --format=json | jq '.[] | {timestamp, httpRequest, textPayload, jsonPayload}'

# 全てのログをJSON形式で確認（エラーに関連するもの）
gcloud logging read \
  'resource.type="cloud_run_revision"
   resource.labels.service_name="ocr-proxy"
   (textPayload=~"OCR Error" OR textPayload=~"Error" OR severity>=ERROR)' \
  --freshness=1h --limit=10 --order=desc \
  --format=json | jq -r '.[] | "\(.timestamp) [\(.severity)] \(.textPayload // .jsonPayload.message // .jsonPayload.error // "")"'

