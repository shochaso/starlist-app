# workflow_dispatch 実行サマリ

**作成日時**: 2025-11-09  
**目的**: `temp/workflow-dispatch` ブランチのPRをマージし、RUN_ID を取得

---

## 📋 現在の状況

### ✅ 確認済み

- **ローカルファイル**: `workflow_dispatch` が先頭に配置済み
  - `.github/workflows/weekly-routine.yml`: ✅ `workflow_dispatch:` が先頭
  - `.github/workflows/allowlist-sweep.yml`: ✅ `workflow_dispatch:` が先頭

- **ブランチ**: `temp/workflow-dispatch` が存在（`git fetch origin temp/workflow-dispatch` で確認済み）

### ⏳ 確認が必要

- **PR番号**: `temp/workflow-dispatch` ブランチのPRが見つからない
- **mainブランチ**: `workflow_dispatch` が反映されているか確認が必要

---

## 📋 次のステップ（優先順位順）

### ステップ1: PR番号を特定

**方法A: GitHub UIで確認**
1. GitHub → **Pull requests** タブ
2. 検索: `temp/workflow-dispatch` または `workflow-dispatch`
3. PR番号をメモ

**方法B: ブランチから直接PRを作成（PRが見つからない場合）**

```bash
gh pr create --head temp/workflow-dispatch --base main \
  --title "ci: move workflow_dispatch to top of on: section" \
  --body "weekly-routine.yml と allowlist-sweep.yml の workflow_dispatch を on: の先頭に移動

## 変更内容
- \`.github/workflows/weekly-routine.yml\`: \`workflow_dispatch:\` を \`on:\` の先頭に移動
- \`.github/workflows/allowlist-sweep.yml\`: \`workflow_dispatch:\` を \`on:\` の先頭に移動

## 目的
mainブランチで手動 dispatch を有効化し、RUN_ID を取得可能にする。

## 関連
- SOT/DoD: providers-only CI の RUN_ID 取得待ち
- Issue: #38"
```

---

### ステップ2: PRのマージ（保護ブランチ対応）

**現在のBranch Protection設定**:
- **strict**: `false`
- **enforce_admins**: `false`
- **contexts**: `["security-scan"]` のみ

**手順**:
1. **PRを開く**: GitHub UIでPR番号を確認
2. **Checks確認**: `security-scan` が ✅ SUCCESS か確認
3. **承認・マージ**: 
   - **Files changed** タブ → **Review changes** → **Approve**
   - **Merge pull request** → **Squash and merge**

---

### ステップ3: workflow_dispatch の認識待ち

**注意**: GitHub APIの認識遅延があるため、マージ後数分待つ必要があります。

**確認方法**:
1. **GitHub UIで確認（推奨）**:
   - **Actions** タブ → **weekly-routine** を選択
   - **「Run workflow」** ボタンが表示されるか確認
   - 表示されれば ✅ 有効化済み

2. **CLIで確認**（422エラーが消えるまで待つ）:
   ```bash
   gh workflow run weekly-routine.yml --ref main
   # 成功するまで数分待って再試行
   ```

---

### ステップ4: ワークフローを手動実行

**GitHub UI（推奨）**:

1. **weekly-routine**:
   - **Actions** タブ → **weekly-routine** を選択
   - **「Run workflow」** ボタンをクリック
   - Branch: `main` → **Run workflow**
   - **RUN_ID** をメモ（URLから取得: `.../actions/runs/<RUN_ID>`）

2. **allowlist-sweep**:
   - **Actions** タブ → **allowlist-sweep** を選択
   - **「Run workflow」** ボタンをクリック
   - Branch: `main` → **Run workflow**
   - **RUN_ID** をメモ（URLから取得: `.../actions/runs/<RUN_ID>`）

---

### ステップ5: RUN_ID 取得と記録

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
2. ブランチから直接PRを作成（上記のコマンドを実行）

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

- [ ] PR番号を特定（GitHub UIで確認 or 新規作成）
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
**ステータス**: ✅ **workflow_dispatch 実行サマリ作成完了**

