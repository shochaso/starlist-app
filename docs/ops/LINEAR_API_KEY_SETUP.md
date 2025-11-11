# Linear API Key 保存手順

## 📋 ステップ1: direnvのインストール（未インストールの場合）

```bash
# macOSの場合
brew install direnv

# シェル設定に追加（zshの場合）
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
source ~/.zshrc
```

## 📋 ステップ2: .envrcにAPIキーを追加

1. `.envrc`ファイルを開く
2. `export LINEAR_API_KEY=''` の空文字列を実際のAPIキーに置き換える

```bash
# エディタで編集
# export LINEAR_API_KEY='lin_api_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
```

## 📋 ステップ3: direnvを有効化

```bash
# プロジェクトディレクトリで実行
direnv allow
```

これで、このディレクトリに入ると自動的に環境変数が読み込まれます。

## 📋 ステップ4: STA-8を作成

```bash
# 環境変数が自動的に読み込まれているので、そのまま実行可能
./scripts/create-linear-issue.sh STA-8 "Production flow smoke test"
```

---

## 🔒 セキュリティ注意事項

- ✅ `.envrc`は`.gitignore`に含まれているため、Gitにコミットされません
- ✅ APIキーはローカルのみに保存されます
- ⚠️ `.envrc`ファイルを他の人と共有しないでください
- ⚠️ スクリーンショットやログにAPIキーを含めないでください

---

## 🆘 トラブルシューティング

### direnvが動作しない場合

```bash
# direnvがインストールされているか確認
which direnv

# シェル設定を確認
cat ~/.zshrc | grep direnv

# 手動で環境変数を設定（一時的）
export LINEAR_API_KEY='your-api-key'
```

### .envrcが読み込まれない場合

```bash
# direnv allowを再実行
direnv allow

# または、手動で読み込み
source .envrc
```
