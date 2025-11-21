## YouTube Data API v3 のセットアップ手順

Starlist で YouTube 動画のメタ情報を取得するために、手元で YouTube Data API v3 の API キーを作成し `.env` に設定します。以下の手順に沿って準備してください。

### 1. Google Cloud Console にアクセス

1. <https://console.cloud.google.com/> にアクセスし、Google アカウントでログインします。
2. 右上のプロジェクトセレクターを開き、既存プロジェクトを選ぶか **「新しいプロジェクトを作成」** します。

### 2. YouTube Data API v3 を有効化

1. 左側メニューの **「API とサービス」→「ライブラリ」** を選択します。
2. 検索ボックスで *YouTube Data API v3* を探し、結果のカードを開きます。
3. **「有効にする」** ボタンを押して API をアクティブ化します。

### 3. API キーを発行

1. 「API とサービス」→**「認証情報」** に移動します。
2. 画面上部の **「＋認証情報を作成」→「API キー」** をクリックすると新しいキーが表示されます。
3. 表示されたキーを控えます（後のセクションで `.env` に設定します）。

### 4. API キーの制限（推奨）

セキュリティのため、作成した API キーは以下のように制限してください。

- **アプリケーション制限**: 「HTTP リファラー」または「IP アドレス」など、利用環境に応じた制限を設定します。
- **API 制限**: 「YouTube Data API v3」のみに限定します。

これにより、万一キーが漏えいした場合でも悪用リスクを最小限に抑えられます。

### 5. `.env` への設定

リポジトリ直下の `.env` に以下のエントリを追記/更新し、先ほど控えたキーを設定します。

```bash
# YouTube Data API v3 API key
YOUTUBE_API_KEY=YOUR_YOUTUBE_DATA_API_KEY_HERE
```

`.env` は `.gitignore` 済みのため、リポジトリへ push される心配はありません。チームメンバーに共有する場合は安全なチャネル（1Password, GCP Secret Manager など）を利用してください。

### 6. 動作確認

1. Next.js アプリを起動します。
   ```bash
   npm install
   npm run dev
   ```
2. 別ターミナルから以下のように API ルートを叩き、JSON が返ることを確認します。
   ```bash
   curl "http://localhost:3000/api/youtube/video?videoId=dQw4w9WgXcQ"
   ```
3. 動画情報（タイトル、チャンネル名など）が取得できればセットアップ完了です。

問題が発生した場合は、API キーが正しく `.env` に設定されているか／API 制限でブロックされていないかを確認してください。
