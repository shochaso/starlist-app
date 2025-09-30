# Starlist Development Scripts

## 開発用スクリプト

### 🚀 `dev.sh` - tmux開発環境 (推奨)
tmuxセッションでFlutterを常駐させ、ホットリロードを高速化

```bash
./scripts/dev.sh
```

**初回実行時:**
- tmuxセッション `flutter_dev` を起動
- Flutter web on Chrome (port 8080) を開始
- Chromeブラウザを自動起動

**2回目以降:**
- Flutterホットリロード (`r`) を自動実行
- ChromeタブをAppleScriptで自動リロード
- ⚡️ 爆速でコード変更を反映

**tmuxセッション管理:**
```bash
# セッション確認
tmux ls

# アタッチ（ログを見る）
tmux attach -t flutter_dev

# デタッチ（Ctrl+b → d）

# セッション終了
tmux kill-session -t flutter_dev
```

---

### 🔄 `c.sh` - Chrome実行スクリプト
プロンプトをログに保存してChrome起動

```bash
./scripts/c.sh
# または環境変数で
PROMPT_MSG="実装完了" ./scripts/c.sh
```

**機能:**
1. プロンプトを `logs/prompt_history.json` に保存
2. 既存のFlutter webプロセスを終了
3. Chrome (port 8080) で起動
4. `[Run OK]` マーカーを出力

---

### 📝 `prompt_logger.dart` - プロンプト履歴ロガー
入力されたプロンプトをJSON形式で保存

```bash
dart scripts/prompt_logger.dart "実装完了"
```

**出力例:**
```json
{"timestamp":"2025-10-01T06:26:05.271677","summary":"実装完了"}
```

---

### 📦 その他のスクリプト

- **`setup.sh`** - 初期セットアップ
- **`deploy.sh`** - デプロイスクリプト
- **`update_task_status.sh`** - タスク状態更新
- **`task_completion_check.sh`** - タスク完了チェック

---

## 推奨ワークフロー

### 1. 初回起動
```bash
./scripts/dev.sh
```

### 2. コード編集
エディタでコードを変更

### 3. リロード
```bash
./scripts/dev.sh  # ホットリロード + Chrome更新
```

### 4. デバッグ
```bash
tmux attach -t flutter_dev  # ログ確認
```

### 5. 終了
```bash
tmux kill-session -t flutter_dev
```

---

## Tips

### エラー発生時
```bash
# tmuxセッションを強制終了
tmux kill-session -t flutter_dev

# 再起動
./scripts/dev.sh
```

### ポート変更
`dev.sh` 内の `--web-port 8080` を変更

### 複数ブラウザ対応
Chrome以外 (Safari/Firefox) を使う場合は `dev.sh` の `osascript` 部分を調整