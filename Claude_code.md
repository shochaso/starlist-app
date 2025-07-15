# Claude Code 設定・使用ガイド

## 概要
Claude Codeは、ターミナルから直接Claudeと対話できるコマンドラインツールです。コード生成、デバッグ、質問応答などを効率的に行えます。

## インストール状況
- **パッケージ**: `@anthropic-ai/claude-code@1.0.41`
- **インストール場所**: `/Users/shochaso/.nvm/versions/node/v18.18.0/lib/node_modules/@anthropic-ai/claude-code/`
- **実行ファイル**: `cli.js`

## 修正した問題
### 問題: "claude not found"エラー
**原因**: npmインストール時にシンボリックリンクが正しく作成されていない

**解決方法**:
```bash
# シンボリックリンクを手動で作成
ln -sf /Users/shochaso/.nvm/versions/node/v18.18.0/lib/node_modules/@anthropic-ai/claude-code/cli.js /Users/shochaso/.nvm/versions/node/v18.18.0/bin/claude
```

## 基本的な使用方法

### 1. インタラクティブモード（デフォルト）
```bash
# 基本的な対話セッション
claude

# 危険なパーミッションチェックをスキップ（サンドボックス環境推奨）
claude --dangerously-skip-permissions

# 最新の会話を継続
claude --continue
claude -c

# 特定のセッションを再開
claude --resume [sessionId]
claude -r [sessionId]
```

### 2. 非インタラクティブモード
```bash
# 一回限りの質問（パイプ処理に便利）
claude --print "Flutterアプリの最適化方法を教えて"
claude -p "このエラーの解決方法は？"

# JSON形式で出力
claude --print --output-format json "コード例を提供して"

# ストリーミングJSON出力
claude --print --output-format stream-json "長い説明をお願いします"
```

### 3. モデル指定
```bash
# 特定のモデルを使用
claude --model sonnet "コードレビューをお願いします"
claude --model opus "複雑な問題を解決して"

# フォールバックモデル指定（--printモードのみ）
claude --print --fallback-model sonnet "質問内容"
```

### 4. ツール制御
```bash
# 許可するツールを指定
claude --allowedTools "Bash(git:*) Edit" "Git操作とファイル編集のみ許可"

# 禁止するツールを指定
claude --disallowedTools "Bash(rm:*)" "削除コマンドを禁止"

# 追加ディレクトリへのアクセス許可
claude --add-dir /path/to/project /another/path "プロジェクトフォルダにアクセス"
```

### 5. IDE連携
```bash
# IDEに自動接続
claude --ide
```

## 設定管理

### 設定の確認・変更
```bash
# 設定管理コマンド
claude config

# グローバル設定でテーマを変更
claude config set -g theme dark

# 設定の確認
claude config list
```

### MCP（Model Context Protocol）サーバー管理
```bash
# MCPサーバーの設定
claude mcp

# 設定ファイルからMCPサーバーを読み込み
claude --mcp-config /path/to/mcp-config.json

# MCP設定を文字列で指定
claude --mcp-config '{"servers": {...}}'
```

## トラブルシューティング

### 1. ヘルスチェック
```bash
# Claude Codeの状態確認
claude doctor
```

### 2. アップデート
```bash
# アップデートの確認とインストール
claude update

# 特定バージョンのインストール
claude install stable
claude install latest
claude install 1.0.41
```

### 3. 移行
```bash
# グローバルインストールからローカルインストールへ移行
claude migrate-installer
```

### 4. デバッグモード
```bash
# デバッグ情報を表示
claude --debug --verbose "問題のある操作"

# MCPデバッグ（非推奨、--debugを使用）
claude --mcp-debug "MCP関連の問題"
```

## 実用的な使用例

### 1. Starlistプロジェクトでの活用
```bash
# プロジェクトディレクトリでの開発支援
cd /Users/shochaso/starlist
claude --dangerously-skip-permissions --continue

# Flutterコードのレビュー
claude --print "このFlutterコードの問題点を指摘して" < lib/main.dart

# エラーの解決
claude --allowedTools "Edit Bash(flutter:*)" "Flutter build エラーを修正して"
```

### 2. パイプ処理での活用
```bash
# ログファイルの分析
tail -f logs/app.log | claude --print --input-format stream-json

# Gitコミットメッセージの生成
git diff --cached | claude --print "このdiffに適したコミットメッセージを生成して"
```

### 3. 継続的な開発支援
```bash
# 長期的な開発セッション
claude --continue --add-dir /Users/shochaso/starlist --ide

# 特定のファイルタイプのみ許可
claude --allowedTools "Edit(*.dart,*.yaml,*.md)" --disallowedTools "Bash(rm:*,sudo:*)"
```

## 注意事項

1. **パーミッション**: `--dangerously-skip-permissions`は安全な環境でのみ使用
2. **リソース**: 長時間のセッションはAPIクォータに注意
3. **セキュリティ**: 機密情報を含むファイルへのアクセス制御を適切に設定
4. **バックアップ**: 重要なファイルの編集前はバックアップを取得

## バージョン情報
- **現在のバージョン**: 1.0.41
- **Node.js要件**: >=18.0.0
- **最終更新**: 2025年7月14日 