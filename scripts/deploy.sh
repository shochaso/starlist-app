#!/bin/bash

# 環境変数の設定
ENV=$1

# 環境の検証
if [ -z "$ENV" ]; then
  echo "環境を指定してください (development, staging, production)"
  exit 1
fi

# 環境に応じた設定の適用
case $ENV in
  "development")
    echo "開発環境のビルドを開始します..."
    flutter build apk --debug
    flutter build ios --debug
    ;;
  "staging")
    echo "ステージング環境のビルドを開始します..."
    flutter build apk --release
    flutter build ios --release
    ;;
  "production")
    echo "本番環境のビルドを開始します..."
    flutter build apk --release
    flutter build ios --release
    ;;
  *)
    echo "無効な環境です: $ENV"
    exit 1
    ;;
esac

# ビルドの確認
if [ $? -eq 0 ]; then
  echo "ビルドが完了しました"
else
  echo "ビルドに失敗しました"
  exit 1
fi

# テストの実行
if [ "$ENV" != "development" ]; then
  echo "テストを実行します..."
  flutter test
  if [ $? -ne 0 ]; then
    echo "テストに失敗しました"
    exit 1
  fi
fi

# デプロイメントの実行
case $ENV in
  "development")
    echo "開発環境へのデプロイを開始します..."
    # 開発環境のデプロイメントコマンド
    ;;
  "staging")
    echo "ステージング環境へのデプロイを開始します..."
    # ステージング環境のデプロイメントコマンド
    ;;
  "production")
    echo "本番環境へのデプロイを開始します..."
    # 本番環境のデプロイメントコマンド
    ;;
esac

echo "デプロイメントが完了しました"
