# スターリスト 開発スクリプト

このディレクトリには、Starlistプロジェクトの開発を効率化するためのスクリプトが含まれています。

## タスク状態管理スクリプト

### update_task_status.sh

`Task.md`内のタスク状態を更新するためのスクリプトです。

#### 使用方法
```bash
./scripts/update_task_status.sh <タスク識別キーワード> <状態>
```

#### 引数
- `<タスク識別キーワード>`: 更新するタスクを特定するためのキーワード
- `<状態>`: タスクの新しい状態。以下の値を使用できます:
  - `complete`: 完了済み
  - `progress`: 進行中
  - `next`: 次のスプリント
  - `pending`: 保留中

#### 例
```bash
# 「ログイン機能」タスクを進行中としてマーク
./scripts/update_task_status.sh "ログイン機能" progress

# 「YouTube視聴履歴」タスクを完了としてマーク
./scripts/update_task_status.sh "YouTube視聴履歴" complete
```

### task_completion_check.sh

コードベースの状態を分析して、タスクの完了状態を自動的に判断するスクリプトです。このスクリプトはGitHub Actionsによって自動的に実行されますが、手動でも実行できます。

#### 使用方法
```bash
./scripts/task_completion_check.sh
```

## Git Hooks

### pre-commit

コミット前に`Task.md`のタスク状態を自動的に更新します。このフックは`.git/hooks/pre-commit`に自動インストールされています。

## GitHub Actions

### deploy.yml

Mainブランチへのプッシュ時に以下の処理を自動的に実行します:

1. データベースマイグレーションの適用
2. タスク完了状態の自動チェック
3. ウェブバージョンのデプロイ（設定時）

## セットアップ方法

初めて使用する場合、以下のコマンドを実行してスクリプトを初期化します:

```bash
# スクリプトに実行権限を付与
chmod +x scripts/*.sh

# pre-commitフックをインストール
cp .git/hooks/pre-commit .git/hooks/pre-commit.backup 2>/dev/null || true
cp -f scripts/pre-commit .git/hooks/
chmod +x .git/hooks/pre-commit

# 最初のタスク状態チェックを実行
./scripts/task_completion_check.sh
``` 