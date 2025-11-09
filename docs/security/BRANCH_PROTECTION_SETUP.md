# ブランチ保護設定ガイド（WS-D）

**Status**: Active  
**Last Updated**: 2025-11-09  
**Owner**: DevOps + PM

---

## 設定手順（GitHub UI操作）

### 1. ブランチ保護ルールの追加

1. GitHubリポジトリにアクセス
2. **Settings** → **Branches** → **Branch protection rules**
3. **Add rule** をクリック

---

## 設定項目

### 対象ブランチ

- **Branch name pattern**: `main`（完全一致）

---

### Require a pull request before merging

- ✅ **Require a pull request before merging**: ON
- **Required approvals**: **1**
- **推奨レビュアー**: PMまたはSecOps

---

### Require status checks to pass before merging

- ✅ **Require status checks to pass before merging**: ON

**必須チェック（全てON）**:
- `extended-security`
- `docs:preflight`
- （存在すれば）`build`
- （存在すれば）`test`

- ✅ **Require branches to be up to date before merging**: ON（推奨）

---

### その他の設定

- ✅ **Dismiss stale pull request approvals when new commits are pushed**: ON
- ✅ **Require linear history**: ON（Squash運用と整合）
- **Restrict who can push to matching branches**: 必要に応じてチームに限定

---

## 受入基準（DoD）

### 確認項目

1. ✅ 新規PRで「**Checks required**」が表示される
2. ✅ 必須チェック通過までマージ不可であること
3. ✅ Squashのみ許可（Merge commit / Rebase は不可）

---

## 検証方法

### 1. テストPR作成

```bash
git checkout -b test/branch-protection
git commit --allow-empty -m "test: branch protection"
git push -u origin test/branch-protection
gh pr create --title "test: branch protection" --body "Testing branch protection rules"
```

### 2. PR画面で確認

- [ ] 「Checks required」が表示される
- [ ] 必須チェック（`extended-security`, `docs:preflight`）が実行される
- [ ] チェック未通過時はマージボタンが無効化される

### 3. マージ方式確認

- [ ] Squash and merge のみ選択可能
- [ ] Create a merge commit は選択不可
- [ ] Rebase and merge は選択不可

---

## トラブルシューティング

### 必須チェックが表示されない場合

1. **ワークフロー名の確認**
   - `.github/workflows/extended-security.yml`の`name:`を確認
   - ブランチ保護設定のチェック名と一致させる

2. **ワークフローの実行確認**
   - 少なくとも1回は該当ブランチでワークフローが実行されている必要がある
   - `gh workflow run extended-security.yml`で手動実行

### レビュアーが設定できない場合

- GitHubリポジトリの**Settings** → **Code review**でレビュアーを設定
- または、ブランチ保護ルールで「Restrict who can dismiss reviews」を設定

---

## 関連ドキュメント

- GitHub公式ドキュメント: [Branch protection rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- セキュリティ厳格化ロードマップ: `docs/security/SEC_HARDENING_ROADMAP.md`

---

**作成日**: 2025-11-09  
**次回レビュー**: 設定完了後

