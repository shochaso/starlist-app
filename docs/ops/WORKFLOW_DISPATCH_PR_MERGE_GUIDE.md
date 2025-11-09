# workflow_dispatch PR マージガイド

**作成日時**: 2025-11-09  
**目的**: `temp/workflow-dispatch` ブランチのPRをマージして、mainブランチで `workflow_dispatch` を有効化

---

## 📋 現在の状況

- **ブランチ**: `temp/workflow-dispatch`（PR済み未マージ）
- **変更内容**: `weekly-routine.yml` / `allowlist-sweep.yml` の `workflow_dispatch` を `on:` の先頭に移動
- **問題**: 保護ブランチのため直接 push できず、PR経由のマージ待ち
- **目標**: PRマージ後、main上で手動 dispatch が認識されるまで待つ → RUN_ID 取得

---

## 🔍 PR確認手順

### 1. PR番号を特定

```bash
# temp/workflow-dispatch ブランチのPRを検索
gh pr list --head temp/workflow-dispatch --json number,state,title,mergeable,mergeStateStatus,url

# または全PRから検索
gh pr list --limit 50 --json number,state,title,headRefName,baseRefName | \
  jq '.[] | select(.headRefName | contains("workflow") or contains("dispatch"))'
```

---

## 📋 マージ手順（保護ブランチ対応）

### ステップ1: PRの状態確認

1. **PRを開く**: GitHub UIでPR番号を確認
2. **Checks状態確認**: 
   - `security-scan` が ✅ SUCCESS か確認
   - 他のチェックは非ブロッキング（docs-onlyの場合は情報扱い）

### ステップ2: 必須チェックの確認

現在のBranch Protection設定:
- **strict**: `false`
- **enforce_admins**: `false`
- **contexts**: `["security-scan"]` のみ

**期待値**:
- `security-scan`: ✅ SUCCESS
- 他のチェック: Required表示が消える or 情報扱い

### ステップ3: 承認・マージ

1. **Files changed** タブを開く
2. **Review changes** → **Approve** をクリック
3. **Merge pull request** → **Squash and merge** を選択

---

## 📋 マージ後の手順

### ステップ1: workflow_dispatch の認識待ち

**注意**: GitHub APIの認識遅延があるため、マージ後数分待つ必要があります。

**確認方法**:
```bash
# GitHub UIで確認（推奨）
# Actions → weekly-routine → 「Run workflow」ボタンが表示されるか確認

# CLIで確認（422エラーが消えるまで待つ）
gh workflow run weekly-routine.yml --ref main
# 成功するまで数分待って再試行
```

### ステップ2: ワークフローを手動実行

**方法A: GitHub UI（推奨）**

1. **Actions** タブを開く
2. **weekly-routine** を選択
3. **「Run workflow」** ボタンをクリック
4. Branch: `main` → **Run workflow**
5. **RUN_ID** をメモ（URLから取得: `.../actions/runs/<RUN_ID>`）

**同様に allowlist-sweep も実行**

---

**方法B: GitHub API（CLI）**

```bash
# weekly-routine を実行
gh api -X POST repos/shochaso/starlist-app/actions/workflows/weekly-routine.yml/dispatches \
  -f ref=main

# allowlist-sweep を実行
gh api -X POST repos/shochaso/starlist-app/actions/workflows/allowlist-sweep.yml/dispatches \
  -f ref=main

# RUN_ID を取得
gh run list --workflow weekly-routine.yml --limit 1 --json databaseId,conclusion,url
gh run list --workflow allowlist-sweep.yml --limit 1 --json databaseId,conclusion,url
```

---

### ステップ3: RUN_ID 取得と記録

**取得する情報**:
```
- weekly-routine RUN_ID: <RUN_ID>
- weekly-routine conclusion: success
- weekly-routine URL: <RUN_URL>
- allowlist-sweep RUN_ID: <RUN_ID>
- allowlist-sweep conclusion: success
- allowlist-sweep URL: <RUN_URL>
```

**記録先**:
- `out/security/...` の記録
- DoD「providers-only CI」の「保留→OK」更新

---

## 🔧 トラブルシューティング

### ケースA: PRが見つからない

**対処**:
1. ブランチが存在するか確認: `git fetch origin temp/workflow-dispatch`
2. ブランチから直接PRを作成:
   ```bash
   gh pr create --head temp/workflow-dispatch --base main \
     --title "ci: move workflow_dispatch to top of on: section" \
     --body "weekly-routine.yml と allowlist-sweep.yml の workflow_dispatch を on: の先頭に移動"
   ```

---

### ケースB: マージ後も 422 エラーが続く

**対処**:
1. **数分待つ**（GitHub APIの認識遅延）
2. **GitHub UIで確認**: Actions → weekly-routine → 「Run workflow」ボタンが表示されるか確認
3. **GitHub API直接実行**: `gh api -X POST repos/.../actions/workflows/.../dispatches`

---

### ケースC: 必須チェックが失敗している

**対処**:
1. **Branch Protectionを一時緩和**（既に `security-scan` のみに設定済み）
2. **PRをRe-run**: Checksタブ → Re-run all jobs
3. **マージ後、HARDへ復帰**: `make -f Makefile.branch-protection protect-hard`

---

## 📋 チェックリスト

- [ ] PR番号を特定
- [ ] PRの状態確認（Checks / mergeable）
- [ ] 必須チェック確認（`security-scan` が ✅）
- [ ] 承認・マージ
- [ ] workflow_dispatch の認識待ち（数分）
- [ ] ワークフローを手動実行（GitHub UI推奨）
- [ ] RUN_ID 取得
- [ ] `out/security/...` に記録
- [ ] DoD「providers-only CI」を「保留→OK」に更新

---

**作成完了時刻**: 2025-11-09  
**ステータス**: ✅ **workflow_dispatch PR マージガイド作成完了**

