# Release Policy

## タグ命名ポリシー

### 日次形式（デフォルト）
- 形式: `vYYYY.MM.DD.HHMM`
- 例: `v2025.11.12.1407`
- 使用: 通常のmainブランチへのpush時

### 週次形式（手動）
- 形式: `vYYYY.W##`
- 例: `v2025.W46`
- 使用: `workflow_dispatch`で`tag_format: weekly`を指定

## リリースプロセス

1. **自動リリース**: mainブランチへのpushで自動実行
2. **署名者**: `STARLIST CI <ops@starlist.jp>`
3. **Release Notes**: GitHubの自動生成を使用

## ロールバック手順

```bash
# 1. タグを削除
git tag -d <TAG>
git push origin :refs/tags/<TAG>

# 2. 前のコミットに戻す
git reset --hard <PREV_COMMIT>

# 3. mainブランチを更新（force-pushが必要な場合）
git push origin main --force

# 4. スクリプトを使用（推奨）
./scripts/release_revert.sh <TAG>
```

## Draft Release運用

- main push時は通常リリース（draft: false）
- 将来的にDraft Release運用を導入する場合は、`release.yml`の`draft: true`を設定

## 例外時の扱い

- **緊急時**: 管理者バイパスでマージ可能（監査ログに記録）
- **ロールバック**: `scripts/release_revert.sh`を使用
- **タグ命名変更**: `workflow_dispatch`で手動実行

