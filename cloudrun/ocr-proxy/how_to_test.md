---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# OCR Proxy 修正のテスト手順

## 1. 事前準備

1. Google Cloud プロジェクトに対して Document AI Processor が有効化されていることを確認します。
2. 次の環境変数を控えておきます。
   - `PROJECT` (または `GCP_PROJECT` / `GOOGLE_CLOUD_PROJECT`)
   - `LOCATION` (または `DOCAI_LOCATION`)
   - `PROCESSOR` (または `PROCESSOR_ID`)
   - `OCR_GCS_BUCKET` : 2MB 超の入力をアップロードするための GCS バケット
3. サービスアカウントキー(JSON)を取得し、Cloud Shell などでファイルとして保存します。
4. テスト用の小さな画像ファイル (2MB 未満) を用意します。例: `samples/sample.png`

## 2. ローカル (Cloud Shell) での API テスト

```bash
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/path/to/key.json"
export PROJECT="your-project-id"
export LOCATION="us"
export PROCESSOR="xxxxxxxxxxxxxxxx"
export OCR_GCS_BUCKET="your-ocr-bucket"
export FILE="samples/sample.png"

cd cloudrun/ocr-proxy
npm ci
node test-process.js
```

- 正常終了すると、ドキュメントテキストが標準出力の最後に 2,000 文字まで表示されます。
- 2MB 超のファイルでテストする場合は、`FILE` を大きなファイルに差し替えて同じコマンドを実行します。

## 3. Cloud Run ローカル実行

```bash
npm ci
npm start
```

別端末 (または同一シェルの別ウィンドウ) から次のようにリクエストします。

```bash
curl -s -X POST http://localhost:8080/ocr/process \
  -H "Content-Type: application/json" \
  -d "$(node -e 'const fs=require("fs"); const data=fs.readFileSync(process.env.FILE); const base64=data.toString("base64"); console.log(JSON.stringify({ mimeType: "image/png", contentBase64: base64 }));')"
```

- レスポンスに `text` フィールドが含まれることを確認します。
- サーバーログには `[OCR] incoming` や `[OCR] result` が JSON 形式で出力されます。

## 4. Docker ビルド & ローカル起動

```bash
# プロジェクトルートで
cd cloudrun/ocr-proxy
npm ci
npm test:process   # 念のため再度確認

docker build -t ocr-proxy:local .
docker run --rm -it \
  -e GOOGLE_APPLICATION_CREDENTIALS=/secrets/key.json \
  -v $GOOGLE_APPLICATION_CREDENTIALS:/secrets/key.json:ro \
  -e PROJECT \
  -e LOCATION \
  -e PROCESSOR \
  -e OCR_GCS_BUCKET \
  -p 8080:8080 \
  ocr-proxy:local
```

別ターミナルから手順 3 と同じ curl を実行して応答を確認します。

## 5. Cloud Run へのデプロイ (例)

```bash
cd cloudrun/ocr-proxy
npm ci
npm run build  # build ステップが必要な場合のみ

gcloud builds submit --tag gcr.io/$PROJECT/ocr-proxy

gcloud run deploy ocr-proxy \
  --image gcr.io/$PROJECT/ocr-proxy \
  --region $LOCATION \
  --set-env-vars PROJECT=$PROJECT,LOCATION=$LOCATION,PROCESSOR=$PROCESSOR,OCR_GCS_BUCKET=$OCR_GCS_BUCKET \
  --allow-unauthenticated
```

デプロイ後は、Cloud Run のサービス URL に対して curl を実行し、ログに `[OCR] incoming` / `[OCR] result` が出力されることを確認してください。

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
