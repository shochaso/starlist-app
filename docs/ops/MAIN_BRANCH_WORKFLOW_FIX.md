# Main Branch Workflow Fix — workflow_dispatch 追加

**作成日時**: 2025-11-09  
**目的**: main ブランチのワークフローファイルに `workflow_dispatch` を追加

---

## 🔍 問題の原因

ローカルのワークフローファイルには `workflow_dispatch` が定義されていますが、main ブランチにマージされていない可能性があります。

**確認結果**:
- ✅ ローカルファイル: `workflow_dispatch` 定義済み
- ⏳ main ブランチ: 確認が必要

---

## 🔧 解決方法

### 方法1: PR #48 をマージ（推奨）

PR #48 にはワークフローファイルが含まれているため、マージすれば main ブランチに反映されます。

### 方法2: main ブランチに直接修正を適用

main ブランチのワークフローファイルを確認し、`workflow_dispatch` が無い場合は追加します。

---

## 📋 修正手順（GitHub UI）

### 1. main ブランチのワークフローファイルを確認

1. GitHub → Code → `.github/workflows/weekly-routine.yml` を開く
2. **Branch: main** を選択
3. `on:` セクションを確認

### 2. workflow_dispatch を追加（無い場合）

1. **Edit**（鉛筆アイコン）をクリック
2. `on:` セクションに以下を追加:

```yaml
on:
  schedule:
    - cron: "0 0 * * 1"  # 毎週月曜 00:00 UTC (09:00 JST)
  workflow_dispatch:
```

3. **Commit changes** → **Create a new branch for this commit and start a pull request**
4. PR を作成してマージ

---

## 📋 修正手順（CLI）

### main ブランチに直接適用

```bash
# main ブランチに切り替え
git checkout main
git pull origin main

# ワークフローファイルを編集
# .github/workflows/weekly-routine.yml の on: セクションに workflow_dispatch: を追加

# コミット・プッシュ
git add .github/workflows/weekly-routine.yml
git commit -m "ci: add workflow_dispatch to weekly-routine.yml"
git push origin main
```

---

## ✅ 確認方法

修正後、以下で確認:

```bash
# GitHub UI で確認
# Actions → weekly-routine → 「Run workflow」ボタンが表示される

# CLI で確認
gh workflow run weekly-routine.yml --ref main
```

---

**作成完了時刻**: 2025-11-09  
**ステータス**: ⏳ **main ブランチのワークフローファイル確認が必要**

