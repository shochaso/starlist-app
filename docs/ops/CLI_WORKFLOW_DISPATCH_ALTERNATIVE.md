# CLI Workflow Dispatch Alternative — API直接実行

**作成日時**: 2025-11-09  
**目的**: `gh workflow run` が使えない場合の代替実行方法

---

## 🔍 問題

`gh workflow run` コマンドでエラーが出る場合でも、GitHub API を直接使用してワークフローを実行できます。

---

## 🔧 解決方法

### 方法1: ワークフローIDを直接指定（推奨）

```bash
# ワークフローIDを取得
WF_ID=$(gh api repos/shochaso/starlist-app/actions/workflows/weekly-routine.yml --jq '.id')

# ワークフローを実行
gh api -X POST repos/shochaso/starlist-app/actions/workflows/${WF_ID}/dispatches \
  -f ref=main
```

### 方法2: ワークフローファイル名で実行

```bash
# ワークフローファイル名を直接指定
gh api -X POST repos/shochaso/starlist-app/actions/workflows/weekly-routine.yml/dispatches \
  -f ref=main
```

### 方法3: curl + PAT で実行

```bash
# GITHUB_TOKEN を環境変数に設定
export GITHUB_TOKEN=gho_...

# curl で実行
curl -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  https://api.github.com/repos/shochaso/starlist-app/actions/workflows/weekly-routine.yml/dispatches \
  -d '{"ref":"main"}'
```

---

## 📋 実行例

### weekly-routine を実行

```bash
gh api -X POST repos/shochaso/starlist-app/actions/workflows/weekly-routine.yml/dispatches \
  -f ref=main
```

### allowlist-sweep を実行

```bash
gh api -X POST repos/shochaso/starlist-app/actions/workflows/allowlist-sweep.yml/dispatches \
  -f ref=main
```

---

## ✅ 実行確認

```bash
# 実行直後の Run を確認
gh run list --workflow weekly-routine.yml --limit 1
```

---

**作成完了時刻**: 2025-11-09  
**ステータス**: ✅ **CLI Workflow Dispatch Alternative 作成完了**

