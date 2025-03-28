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

## 開発環境のセットアップ

### 必要条件
- Flutter SDK (3.x)
- Firebase CLI
- Android Studio / Xcode
- Git

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

5. アプリの実行
```bash
flutter run
```

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
