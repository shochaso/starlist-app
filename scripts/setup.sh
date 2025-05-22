#!/bin/bash
# セットアップスクリプト

# スクリプトディレクトリへ移動
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR/.." || exit 1

echo "==== Starlist 開発環境セットアップ ===="

# スクリプトに実行権限を付与
echo "スクリプトに実行権限を付与中..."
chmod +x scripts/*.sh

# .githooksディレクトリがなければ作成
if [ ! -d ".githooks" ]; then
  mkdir -p .githooks
fi

# pre-commitフックをコピー
echo "pre-commitフックをインストール中..."
cp -f scripts/pre-commit .githooks/
chmod +x .githooks/pre-commit

# Gitの設定を更新してhooksディレクトリを指定
git config core.hooksPath .githooks

# タスク完了状態の初期チェック
echo "タスク状態をチェック中..."
./scripts/task_completion_check.sh

# ディレクトリ構造を確認
echo "必要なディレクトリ構造を確認中..."
mkdir -p lib/src/features/auth/screens
mkdir -p lib/src/features/auth/models
mkdir -p lib/src/features/auth/providers
mkdir -p lib/src/features/youtube/providers
mkdir -p lib/src/features/spotify/providers
mkdir -p lib/src/features/data_integration/repositories
mkdir -p lib/src/features/data_integration/services
mkdir -p lib/src/theme

echo "==== セットアップ完了 ===="
echo "Starlistプロジェクトの開発を開始できます！"
echo "タスクの更新は ./scripts/update_task_status.sh を使用してください。" 