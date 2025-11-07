Status:: 
Source-of-Truth:: (TBD)
Spec-State:: 
Last-Updated:: 


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

## MP（問題解決プロンプト）

### 使用方法
```bash
# 問題解決プロンプトを使用してClaude Codeを起動
claude --print "MP: [解決したい問題を記述]"

# インタラクティブモードでMPを使用
claude
# 会話内で「MP: [問題]」と入力してプロンプトを呼び出し
```

### 問題解決プロンプトのフォーマット
```markdown
<complex_thinking_task>
<problem_statement>
<!-- 解決したい複雑な問題を明確に定義 -->
</problem_statement>

<thinking_framework>
この問題について、以下のステップで思考してください：

1. 問題の本質と構造を分析
   - 表面的な症状と根本原因の区別
   - 関係する要因の洗い出し

2. 多角的な視点から検討
   - ステークホルダーごとの立場
   - 短期・中期・長期の影響

3. 複数の解決策を発想
   - 従来的なアプローチ
   - 革新的なアプローチ
   - ハイブリッドなアプローチ

4. 各解決策の評価
   - 実現可能性
   - コストと効果
   - リスクと副作用

5. 最適解の選択と根拠
   - 総合的な判断理由
   - 実行時の注意点

必要に応じて外部情報も検索し、
最新で正確な情報に基づいて思考してください。
</thinking_framework>

<output_style>
思考プロセスを丁寧に示しながら、
最終的には実行可能な具体案を提示してください。
</output_style>
</complex_thinking_task>
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
claude --model opus "MP: 複雑な技術的問題を解決して"

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

## MP（問題解決プロンプト）実用例

### 1. Starlistプロジェクトでの技術的問題解決
```bash
# 技術的な問題解決
claude --dangerously-skip-permissions --continue
# 会話内で以下のように入力：
# MP: StarlistアプリのFlutter WebでSupabase認証が断続的に失敗する問題

# 機能設計の問題解決
claude --print "MP: ユーザーのスターポイント獲得モチベーションを向上させる新機能を設計したい"
```

### 2. ビジネス課題の解決
```bash
# マネタイゼーション問題
claude --model opus "MP: 課金ユーザーの継続率が月20%と低い問題を解決したい"

# ユーザー体験の改善
claude --print "MP: 新規ユーザーのアプリ離脱率が初日70%と高い問題"
```

### 3. コード品質・アーキテクチャ問題
```bash
# 技術的負債の解決
claude --allowedTools "Edit Bash(flutter:*)" "MP: Starlistアプリのコードベースで技術的負債が蓄積している問題"
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

# MP使用例：複雑な問題解決
claude --print "MP: Starlistアプリでユーザーデータの同期が不安定になる問題を根本的に解決したい"
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

# MPを活用した問題解決セッション
claude --dangerously-skip-permissions --model opus
# 会話内で「MP: [具体的な問題]」を使用して体系的に問題解決
```

## MP（問題解決プロンプト）のベストプラクティス

### 1. 問題の明確化
```bash
# 悪い例
claude --print "MP: アプリが遅い"

# 良い例  
claude --print "MP: StarlistアプリのiOS版で、OCR処理実行時にUI応答が3-5秒停止し、ユーザー体験が悪化している問題を解決したい"
```

### 2. コンテキストの提供
```bash
# プロジェクト情報を含めてMPを実行
claude --add-dir /Users/shochaso/starlist --print "MP: 現在のStarlistアプリで、スターポイント購入の転換率が業界平均の2%を下回る1.2%の問題"
```

### 3. 段階的な問題解決
```bash
# 複雑な問題は段階的に分割
claude --continue
# 1. MP: ユーザー離脱の根本原因分析
# 2. MP: 特定された課題に対する解決策設計  
# 3. MP: 解決策の実装優先順位付け
```

## 注意事項

1. **パーミッション**: `--dangerously-skip-permissions`は安全な環境でのみ使用
2. **リソース**: 長時間のセッションはAPIクォータに注意
3. **セキュリティ**: 機密情報を含むファイルへのアクセス制御を適切に設定
4. **バックアップ**: 重要なファイルの編集前はバックアップを取得
5. **MP使用時**: 問題を明確に定義し、具体的なコンテキストを提供することで最適な結果を得られます

## バージョン情報
- **現在のバージョン**: 1.0.41
- **Node.js要件**: >=18.0.0
- **最終更新**: 2025年7月14日
- **MP機能追加**: 2025年7月14日 