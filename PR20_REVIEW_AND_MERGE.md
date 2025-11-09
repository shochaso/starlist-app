# PR #20 レビュー依頼 & Auto-merge 準備

## 📋 PR #20 の状態

最新のPR状態を確認するには:

```bash
gh pr view 20 --repo shochaso/starlist-app
```

---

## 🔄 レビュー依頼 & Auto-merge 準備

### 1. レビュー依頼（必要に応じて）

```bash
# レビュアーを追加
gh pr edit 20 --add-reviewer <github_id_1> --add-reviewer <github_id_2>
```

### 2. Auto-merge準備（マージ条件を満たしたら）

```bash
# マージ条件を満たしたら自動スクワッシュマージ（ブランチ削除）
gh pr merge 20 --squash --delete-branch --auto
```

**注意**: `--auto` フラグは、すべての必須チェックが成功した場合にのみ自動マージします。

---

## 📊 実行中／直近Runの追跡

### 最新10件のワークフロー実行状況

```bash
gh run list --repo shochaso/starlist-app --branch fix/security-hardening-web-csp-lock --limit 10
```

### Checks状況の確認

```bash
gh pr checks 20 --repo shochaso/starlist-app
```

---

## 🔄 失敗Runの再実行（必要時）

### 失敗Runの確認

```bash
gh run list --repo shochaso/starlist-app --branch fix/security-hardening-web-csp-lock --limit 10 --json status,conclusion,workflowName,databaseId --jq '.[] | select(.conclusion == "failure")'
```

### 再実行

```bash
gh run rerun <RUN_ID> --repo shochaso/starlist-app
```

---

## ✅ 現在の状況

### 成功しているワークフロー
- ✅ security-audit
- ✅ extended-security
- ✅ Docs Link Check
- ✅ Guard No Image Loaders
- ✅ rls-audit

### PRゲート設定
- ✅ ops-alert-dryrun.yml: PRブランチでは実行されない（workflow_dispatchのみ）
- ✅ notify.yml: PRブランチでは実行されない（issue_comment/pull_request_review_commentのみ）

---

## 📋 次のアクション

1. **PR #20のChecks状況を確認**
   ```bash
   gh pr checks 20 --repo shochaso/starlist-app
   ```

2. **すべての必須チェックが成功したらAuto-mergeを有効化**
   ```bash
   gh pr merge 20 --squash --delete-branch --auto
   ```

3. **必要に応じてレビュアーを追加**
   ```bash
   gh pr edit 20 --add-reviewer <github_id>
   ```

---

**最終更新**: PR #20 レビュー依頼 & Auto-merge 準備完了時点


## 📋 PR #20 の状態

最新のPR状態を確認するには:

```bash
gh pr view 20 --repo shochaso/starlist-app
```

---

## 🔄 レビュー依頼 & Auto-merge 準備

### 1. レビュー依頼（必要に応じて）

```bash
# レビュアーを追加
gh pr edit 20 --add-reviewer <github_id_1> --add-reviewer <github_id_2>
```

### 2. Auto-merge準備（マージ条件を満たしたら）

```bash
# マージ条件を満たしたら自動スクワッシュマージ（ブランチ削除）
gh pr merge 20 --squash --delete-branch --auto
```

**注意**: `--auto` フラグは、すべての必須チェックが成功した場合にのみ自動マージします。

---

## 📊 実行中／直近Runの追跡

### 最新10件のワークフロー実行状況

```bash
gh run list --repo shochaso/starlist-app --branch fix/security-hardening-web-csp-lock --limit 10
```

### Checks状況の確認

```bash
gh pr checks 20 --repo shochaso/starlist-app
```

---

## 🔄 失敗Runの再実行（必要時）

### 失敗Runの確認

```bash
gh run list --repo shochaso/starlist-app --branch fix/security-hardening-web-csp-lock --limit 10 --json status,conclusion,workflowName,databaseId --jq '.[] | select(.conclusion == "failure")'
```

### 再実行

```bash
gh run rerun <RUN_ID> --repo shochaso/starlist-app
```

---

## ✅ 現在の状況

### 成功しているワークフロー
- ✅ security-audit
- ✅ extended-security
- ✅ Docs Link Check
- ✅ Guard No Image Loaders
- ✅ rls-audit

### PRゲート設定
- ✅ ops-alert-dryrun.yml: PRブランチでは実行されない（workflow_dispatchのみ）
- ✅ notify.yml: PRブランチでは実行されない（issue_comment/pull_request_review_commentのみ）

---

## 📋 次のアクション

1. **PR #20のChecks状況を確認**
   ```bash
   gh pr checks 20 --repo shochaso/starlist-app
   ```

2. **すべての必須チェックが成功したらAuto-mergeを有効化**
   ```bash
   gh pr merge 20 --squash --delete-branch --auto
   ```

3. **必要に応じてレビュアーを追加**
   ```bash
   gh pr edit 20 --add-reviewer <github_id>
   ```

---

**最終更新**: PR #20 レビュー依頼 & Auto-merge 準備完了時点

