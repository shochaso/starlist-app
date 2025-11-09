# Final UI-Only Solution — 完全解決策

**作成日時**: 2025-11-09  
**目的**: 「Run workflow」ボタンが表示されない問題の完全解決

---

## ✅ 確認結果

### ワークフローファイルの状態

**main ブランチ**: ✅ `workflow_dispatch` 定義済み
- `.github/workflows/weekly-routine.yml`: ✅ `workflow_dispatch:` あり
- `.github/workflows/allowlist-sweep.yml`: ✅ `workflow_dispatch:` あり
- `.github/workflows/extended-security.yml`: ✅ `workflow_dispatch:` あり

**権限**: ✅ `admin`（問題なし）

**結論**: ワークフローファイルは正しく設定されています。

---

## 🔍 問題の原因

`gh workflow run` コマンドでエラーが出る場合でも、以下の方法で実行可能です：

1. **GitHub UI**: 「Run workflow」ボタンが表示される（推奨）
2. **GitHub API 直接実行**: `gh api` コマンドで実行可能
3. **GitHub API 認識遅延**: 数分待ってから再試行

---

## 🚀 実行方法（3通り）

### 方法1: GitHub UI（最も確実・推奨）

1. GitHub → **Actions** タブ
2. 左サイドバーから **weekly-routine** を選択
3. **「Run workflow」** ボタンをクリック
4. Branch: `main` → **Run workflow**

**同様に allowlist-sweep も実行**

---

### 方法2: GitHub API 直接実行（CLI）

```bash
# weekly-routine を実行
gh api -X POST repos/shochaso/starlist-app/actions/workflows/weekly-routine.yml/dispatches \
  -f ref=main

# allowlist-sweep を実行
gh api -X POST repos/shochaso/starlist-app/actions/workflows/allowlist-sweep.yml/dispatches \
  -f ref=main
```

**実行確認**:
```bash
# 実行結果を確認
gh run list --workflow weekly-routine.yml --limit 1
gh run list --workflow allowlist-sweep.yml --limit 1
```

---

### 方法3: curl + PAT（gh が使えない場合）

```bash
# GITHUB_TOKEN を環境変数に設定
export GITHUB_TOKEN=gho_...

# weekly-routine を実行
curl -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  https://api.github.com/repos/shochaso/starlist-app/actions/workflows/weekly-routine.yml/dispatches \
  -d '{"ref":"main"}'
```

---

## 📋 実行結果の取得

### Run ID / Run URL を取得

```bash
# 最新の Run を取得
gh run list --workflow weekly-routine.yml --limit 1 --json databaseId,url | jq '.[0] | {run_id: .databaseId, url}'
```

### Artifacts をダウンロード

```bash
# Run ID を指定して Artifacts をダウンロード
RUN_ID=<RUN_ID>
gh run download ${RUN_ID} --dir artifacts/weekly-routine-${RUN_ID}
```

---

## ✅ 推奨実行フロー

### ステップ1: GitHub UI で確認

1. GitHub → Actions → weekly-routine
2. 「Run workflow」ボタンが表示されるか確認
3. 表示されれば、そのまま実行

### ステップ2: CLI で実行（UI が使えない場合）

```bash
# API で直接実行
gh api -X POST repos/shochaso/starlist-app/actions/workflows/weekly-routine.yml/dispatches -f ref=main
gh api -X POST repos/shochaso/starlist-app/actions/workflows/allowlist-sweep.yml/dispatches -f ref=main
```

### ステップ3: 実行結果を確認

```bash
# Run ID を取得
gh run list --workflow weekly-routine.yml --limit 1 --json databaseId,url
```

---

## 📋 トラブルシューティング

### 「Run workflow」ボタンが表示されない

**確認事項**:
1. ブランチが `main` であることを確認
2. ワークフローファイルが main ブランチに存在することを確認
3. 権限が WRITE 以上であることを確認

**対処**:
- GitHub UI で直接確認（最も確実）
- CLI で API 直接実行（代替方法）

---

## 🔗 参考リンク

- **詳細手順**: `docs/ops/UI_ONLY_EXECUTION_GUIDE.md`
- **トラブルシューティング**: `docs/ops/WORKFLOW_DISPATCH_TROUBLESHOOTING.md`
- **CLI代替方法**: `docs/ops/CLI_WORKFLOW_DISPATCH_ALTERNATIVE.md`

---

**作成完了時刻**: 2025-11-09  
**ステータス**: ✅ **Final UI-Only Solution 作成完了**

すべての実行方法を準備しました。GitHub UI または CLI で実行できます。

