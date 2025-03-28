# Starlist

## 概要
Starlistは、ユーザーがお気に入りのコンテンツを管理し、共有できるアプリケーションです。

## 機能
- ユーザー認証
- サブスクリプション管理
- 支払い処理
- プライバシー設定
- ランキングシステム
- YouTube統合

## 技術スタック
- Flutter
- Firebase
- YouTube Data API
- Stripe
- Supabase (新規追加)
- Hive (ローカルキャッシュ)

## 開発環境のセットアップ

### 必要条件
- Flutter SDK (3.x)
- Firebase CLI
- Android Studio / Xcode
- Git
- Supabase CLI

### インストール手順
1. リポジトリのクローン
```bash
git clone https://github.com/yourusername/starlist.git
cd starlist
```

2. 依存関係のインストール
```bash
flutter pub get
```

3. 環境変数の設定
```bash
cp .env.example .env
# .envファイルを編集して必要な環境変数を設定
```

4. Firebaseの設定
```bash
firebase login
firebase init
```

5. Supabaseの設定
```bash
# Supabase CLIがインストールされていることを確認
supabase init
supabase start

# マイグレーションの実行
supabase db reset
```

6. アプリの実行
```bash
flutter run
```

## 環境変数
アプリの実行には以下の環境変数が必要です：

```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
YOUTUBE_API_KEY=your_youtube_api_key
```

開発時には以下のようにして環境変数を渡すことができます：

```bash
flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key --dart-define=YOUTUBE_API_KEY=your_key
```

## ランキング機能

Starlistのランキング機能は、ユーザーの活動スコアに基づいてリアルタイムでランキングを表示します。

### 特徴

- 日次、週次、月次、年次、全期間のランキング表示
- ユーザーのランキング位置の表示
- 周辺ユーザーの表示（自分の前後のランキング）
- キャッシュによるオフライン表示と高速読み込み

### 技術的実装

- Supabaseを使用したバックエンド処理
- カスタムRPC関数による効率的なランキング計算
- Hiveを使用したローカルキャッシュ
- Riverpodによる状態管理

## テスト
```bash
# ユニットテストの実行
flutter test

# 統合テストの実行
flutter drive --target=test_driver/app.dart
```

## デプロイメント
```bash
# 開発環境へのデプロイ
./scripts/deploy.sh development

# ステージング環境へのデプロイ
./scripts/deploy.sh staging

# 本番環境へのデプロイ
./scripts/deploy.sh production
```

## リリース計画
2023年4月30日の初回リリースを予定しています。詳細なリリース計画は[RELEASE_TODO.md](RELEASE_TODO.md)を参照してください。

## プロジェクト構造
```
lib/
  ├── src/
  │   ├── core/
  │   │   ├── api/
  │   │   ├── cache/
  │   │   ├── config/
  │   │   ├── error/
  │   │   ├── performance/
  │   │   └── security/
  │   ├── features/
  │   │   ├── auth/
  │   │   ├── payment/
  │   │   ├── privacy/
  │   │   ├── ranking/
  │   │   ├── subscription/
  │   │   └── youtube/
  │   └── shared/
  └── main.dart
test/
  ├── core/
  ├── features/
  └── helpers/
supabase/
  └── migrations/
      └── 20230420000000_create_rankings.sql
```

## コントリビューション
1. このリポジトリをフォーク
2. 新しいブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m "Add some amazing feature"`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
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
