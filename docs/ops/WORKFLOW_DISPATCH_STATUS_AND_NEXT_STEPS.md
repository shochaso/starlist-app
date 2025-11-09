# workflow_dispatch ステータスと次のステップ

**作成日時**: 2025-11-09  
**目的**: `workflow_dispatch` の有効化状況を確認し、次のステップを明確化

---

## 📋 現在の状況

### ローカルファイルの状態

**✅ ローカルファイル**: `workflow_dispatch` が先頭に配置済み
- `.github/workflows/weekly-routine.yml`: ✅ `workflow_dispatch:` が先頭
- `.github/workflows/allowlist-sweep.yml`: ✅ `workflow_dispatch:` が先頭

### mainブランチの状態

**確認が必要**: mainブランチに `workflow_dispatch` が反映されているか

---

## 🔍 確認手順

### 1. mainブランチのワークフローファイル確認

**方法A: GitHub UI**
1. GitHub → Code → `.github/workflows/weekly-routine.yml`
2. **Branch: main** を選択
3. `on:` セクションを確認
4. `workflow_dispatch:` が先頭にあるか確認

**方法B: GitHub API**
```bash
gh api repos/shochaso/starlist-app/contents/.github/workflows/weekly-routine.yml?ref=main | \
  jq -r '.content' | base64 -d | head -10
```

---

### 2. workflow_dispatch の動作確認

**方法A: GitHub UI（推奨）**
1. **Actions** タブを開く
2. **weekly-routine** を選択
3. **「Run workflow」** ボタンが表示されるか確認
4. 表示されれば ✅ 有効化済み

**方法B: CLI**
```bash
# 422エラーが出る場合 = 未有効化
gh workflow run weekly-routine.yml --ref main

# 成功する場合 = 有効化済み
```

---

## 📋 次のステップ

### ケースA: mainブランチに既に反映されている場合

**手順**:
1. **GitHub UIで確認**: Actions → weekly-routine → 「Run workflow」ボタンが表示されるか確認
2. **手動実行**: 「Run workflow」→ Branch: `main` → **Run workflow**
3. **RUN_ID 取得**: URLから取得（`.../actions/runs/<RUN_ID>`）
4. **記録**: `out/security/...` に記録、DoD更新

---

### ケースB: mainブランチに未反映の場合

**手順**:

#### ステップ1: PRを作成（既存PRがない場合）

```bash
# temp/workflow-dispatch ブランチからPRを作成
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

#### ステップ2: PRのマージ

1. **PRを開く**: GitHub UIでPR番号を確認
2. **Checks確認**: `security-scan` が ✅ SUCCESS か確認
3. **承認・マージ**: Review changes → Approve → Squash and merge

#### ステップ3: workflow_dispatch の認識待ち

**注意**: GitHub APIの認識遅延があるため、マージ後数分待つ必要があります。

**確認方法**:
```bash
# GitHub UIで確認（推奨）
# Actions → weekly-routine → 「Run workflow」ボタンが表示されるか確認

# CLIで確認（422エラーが消えるまで待つ）
gh workflow run weekly-routine.yml --ref main
# 成功するまで数分待って再試行
```

#### ステップ4: ワークフローを手動実行

**GitHub UI（推奨）**:
1. **Actions** タブを開く
2. **weekly-routine** を選択
3. **「Run workflow」** ボタンをクリック
4. Branch: `main` → **Run workflow**
5. **RUN_ID** をメモ（URLから取得: `.../actions/runs/<RUN_ID>`）

**同様に allowlist-sweep も実行**

#### ステップ5: RUN_ID 取得と記録

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

- [ ] mainブランチのワークフローファイル確認（`workflow_dispatch` が先頭か）
- [ ] GitHub UIで「Run workflow」ボタンが表示されるか確認
- [ ] PRが存在するか確認（存在しない場合は作成）
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
**ステータス**: ✅ **workflow_dispatch ステータスと次のステップ作成完了**

