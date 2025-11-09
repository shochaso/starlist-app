# Branch保護の実効性担保（検証PRテンプレ）

**Status**: Active  
**Last Updated**: 2025-11-09  
**Owner**: DevOps + PM

---

## 検証PR本文テンプレ

### 検証目的

- Branch保護の必須チェック/直線履歴/Squash制限が有効に働くか確認する

### 期待値（DoD）

- 必須Checks通過前はMerge不可
- 古いApprovalがCommit追加で無効化される
- Merge方式はSquashのみ許可

---

## 検証手順

### 1. テストPR作成

```bash
git checkout -b test/branch-protection-verification
git commit --allow-empty -m "test: branch protection verification"
git push -u origin test/branch-protection-verification
gh pr create --title "test: branch protection verification" --body "$(cat docs/security/BRANCH_PROTECTION_VERIFICATION.md | sed -n '/^### 検証目的/,/^---/p')"
```

### 2. 確認項目

- [ ] PR画面に「**Checks required**」が表示される
- [ ] `extended-security`チェックが実行される
- [ ] `docs:preflight`チェックが実行される
- [ ] チェック未通過時はマージボタンが無効化される
- [ ] レビュー承認後に新しいコミットを追加すると、承認が無効化される
- [ ] Merge方式は「Squash and merge」のみ選択可能

---

## UI設定確認項目

### GitHub Settings → Branches → Branch protection rules

- [ ] 対象ブランチ: `main`（完全一致）
- [ ] Require a pull request before merging: ON
- [ ] Required approvals: 1
- [ ] Require status checks to pass before merging: ON
- [ ] 必須チェック: `extended-security`, `docs:preflight`
- [ ] Require branches to be up to date before merging: ON
- [ ] Dismiss stale pull request approvals when new commits are pushed: ON
- [ ] Require linear history: ON
- [ ] Allow squash merging: ON
- [ ] Allow merge commits: OFF
- [ ] Allow rebase merging: OFF

---

**作成日**: 2025-11-09

