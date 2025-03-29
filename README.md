# Starlist

Starlistは、YouTube動画やウェブコンテンツを共有・発見するためのソーシャル・キュレーションアプリです。お気に入りのコンテンツを保存し、共有できます。

## 機能

- **お気に入り管理**: コンテンツをお気に入りに追加して整理
- **ソーシャル機能**: スターやファンをフォロー、コンテンツの共有
- **YouTube連携**: YouTube動画の検索と保存
- **プロフィール管理**: カスタマイズ可能なプロフィール

## セットアップ

### 前提条件

- Flutter (最新版)
- Supabase アカウント
- YouTube Data API キー

### 環境変数

プロジェクトのルートに `.env` ファイルを作成し、以下の環境変数を設定してください：

```
SUPABASE_URL=あなたのSupabaseプロジェクトURL
SUPABASE_ANON_KEY=あなたのSupabase匿名キー
YOUTUBE_API_KEY=あなたのYouTube Data APIキー
```

### データベースのセットアップ

1. Supabaseダッシュボードにログイン
2. SQLエディタを開く
3. このリポジトリの `supabase_setup.sql` ファイルの内容を実行

### アプリケーションのインストール

```bash
# 依存関係のインストール
flutter pub get

# アプリケーションの実行
flutter run
```

## 使用方法

### ログイン/登録

- アプリを初めて起動する際は、画面下部の「プロフィール」タブからログイン画面へ移動
- メールアドレスとパスワードで登録またはログイン

### コンテンツの探索

- 「ホーム」タブでおすすめのコンテンツを閲覧
- 「検索」タブでYouTube動画を検索

### お気に入りの追加

1. コンテンツを閲覧中に「お気に入り」ボタンをタップ
2. 必要に応じてメモやタグを追加
3. お気に入り一覧はプロフィールで確認可能

## 貢献方法

バグ報告や機能リクエストは、Issueを作成してください。

プルリクエストは以下の手順で行ってください：

1. リポジトリをフォーク
2. 機能ブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add some amazing feature'`)
4. ブランチをプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。詳細は[LICENSE](LICENSE)ファイルを参照してください。

## 作者
- Your Name - [@yourusername](https://github.com/yourusername)

## 謝辞
- Flutter Team
- Firebase Team
- YouTube Data API Team
- Stripe Team
- Supabase Team
