---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# GitHub Actions Run 再実行コマンド一覧

## 📊 直近の失敗Run一覧

最新10件のワークフロー実行状況は `/tmp/gh_run_list_latest_10.log` に保存されています。

---

## 🔄 再実行コマンド

### 失敗Runの再実行

失敗したRunを再実行するには、以下のコマンドを使用してください:

```bash
gh run rerun <RUN_ID> --repo shochaso/starlist-app
```

### 最新の失敗Runを確認

```bash
gh run list --repo shochaso/starlist-app --branch fix/security-hardening-web-csp-lock --limit 10
```

### 特定のワークフローの失敗Runを再実行

```bash
# security-auditの最新の失敗Runを取得して再実行
LATEST_FAILED=$(gh run list --repo shochaso/starlist-app --branch fix/security-hardening-web-csp-lock --limit 10 --json status,conclusion,workflowName,databaseId --jq '.[] | select(.workflowName == "security-audit" and .conclusion == "failure") | .databaseId' | head -1)
gh run rerun "$LATEST_FAILED" --repo shochaso/starlist-app
```

---

## 📋 よく使うコマンド

### 1. 直近の失敗Run一覧
```bash
gh run list --repo shochaso/starlist-app --branch fix/security-hardening-web-csp-lock --limit 10
```

### 2. 特定のワークフローの失敗Runを再実行
```bash
# security-audit
gh run list --repo shochaso/starlist-app --branch fix/security-hardening-web-csp-lock --limit 10 --json status,conclusion,workflowName,databaseId --jq '.[] | select(.workflowName == "security-audit" and .conclusion == "failure") | .databaseId' | head -1 | xargs -I {} gh run rerun {} --repo shochaso/starlist-app

# extended-security
gh run list --repo shochaso/starlist-app --branch fix/security-hardening-web-csp-lock --limit 10 --json status,conclusion,workflowName,databaseId --jq '.[] | select(.workflowName == "extended-security" and .conclusion == "failure") | .databaseId' | head -1 | xargs -I {} gh run rerun {} --repo shochaso/starlist-app
```

### 3. 実行中のRunの確認
```bash
gh run list --repo shochaso/starlist-app --branch fix/security-hardening-web-csp-lock --limit 10 --json status,conclusion,workflowName,databaseId --jq '.[] | select(.status == "in_progress" or .status == "queued")'
```

---

**最終更新**: GitHub Actions Run 再実行コマンド一覧作成時点


## 📊 直近の失敗Run一覧

最新10件のワークフロー実行状況は `/tmp/gh_run_list_latest_10.log` に保存されています。

---

## 🔄 再実行コマンド

### 失敗Runの再実行

失敗したRunを再実行するには、以下のコマンドを使用してください:

```bash
gh run rerun <RUN_ID> --repo shochaso/starlist-app
```

### 最新の失敗Runを確認

```bash
gh run list --repo shochaso/starlist-app --branch fix/security-hardening-web-csp-lock --limit 10
```

### 特定のワークフローの失敗Runを再実行

```bash
# security-auditの最新の失敗Runを取得して再実行
LATEST_FAILED=$(gh run list --repo shochaso/starlist-app --branch fix/security-hardening-web-csp-lock --limit 10 --json status,conclusion,workflowName,databaseId --jq '.[] | select(.workflowName == "security-audit" and .conclusion == "failure") | .databaseId' | head -1)
gh run rerun "$LATEST_FAILED" --repo shochaso/starlist-app
```

---

## 📋 よく使うコマンド

### 1. 直近の失敗Run一覧
```bash
gh run list --repo shochaso/starlist-app --branch fix/security-hardening-web-csp-lock --limit 10
```

### 2. 特定のワークフローの失敗Runを再実行
```bash
# security-audit
gh run list --repo shochaso/starlist-app --branch fix/security-hardening-web-csp-lock --limit 10 --json status,conclusion,workflowName,databaseId --jq '.[] | select(.workflowName == "security-audit" and .conclusion == "failure") | .databaseId' | head -1 | xargs -I {} gh run rerun {} --repo shochaso/starlist-app

# extended-security
gh run list --repo shochaso/starlist-app --branch fix/security-hardening-web-csp-lock --limit 10 --json status,conclusion,workflowName,databaseId --jq '.[] | select(.workflowName == "extended-security" and .conclusion == "failure") | .databaseId' | head -1 | xargs -I {} gh run rerun {} --repo shochaso/starlist-app
```

### 3. 実行中のRunの確認
```bash
gh run list --repo shochaso/starlist-app --branch fix/security-hardening-web-csp-lock --limit 10 --json status,conclusion,workflowName,databaseId --jq '.[] | select(.status == "in_progress" or .status == "queued")'
```

---

**最終更新**: GitHub Actions Run 再実行コマンド一覧作成時点

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
