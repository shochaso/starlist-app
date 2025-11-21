---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# 🧠 Cursor向けCLIコマンド集

## CIの状況確認・ログ取得

### PRブランチの直近ワークフロー一覧
```bash
gh run list --repo shochaso/starlist-app --branch fix/security-hardening-web-csp-lock
```

### 任意の実行(run-id)の詳細とログ
```bash
gh run view <RUN_ID> --repo shochaso/starlist-app --log
```

### ワークフロー実行状況サマリ
```bash
gh run list --repo shochaso/starlist-app --branch fix/security-hardening-web-csp-lock --limit 5 --json status,conclusion,workflowName,createdAt,databaseId --jq '.[] | "\(.workflowName) | \(.status) | \(.conclusion // "running") | ID: \(.databaseId)"'
```

---

## レビュー依頼・PR本文更新・コメント

### レビューアー追加（必要時）
```bash
gh pr edit 20 --add-reviewer <github_id_1> --add-reviewer <github_id_2>
```

### 本文を手元ファイルで更新（追記したい場合）
```bash
gh pr edit 20 -F /tmp/pr_body_final.txt
```

### コメント投稿（テスト結果やCSP観測計画を共有）
```bash
gh pr comment 20 -b "CI green を確認。CSPはReport-Onlyで48–72時間観測します。"
```

---

## 再実行・失敗時の切り分け

### 失敗したワークフロー全体を再実行
```bash
gh run rerun <RUN_ID> --repo shochaso/starlist-app
```

### セマフォ的に一部だけ再実行したい場合（失敗ジョブのrun-idで）
```bash
gh run rerun <FAILED_RUN_ID> --repo shochaso/starlist-app
```

---

## マージ戦略（準備OK後）

### スクワッシュマージ（推奨）
```bash
gh pr merge 20 --squash --delete-branch --auto
```

### 通常マージ
```bash
gh pr merge 20 --merge --delete-branch --auto
```

---

## CSP受け口の疎通（Functions直URLに向けたPOST）

### Supabase Functions URLの確認
1. Supabase Dashboard → Project Settings → API → Project URL
2. または環境変数から取得: `SUPABASE_URL`

### CSPレポートの送信テスト
```bash
curl -i -X POST \
  -H "Content-Type: application/csp-report" \
  --data '{"csp-report":{"effective-directive":"connect-src","blocked-uri":"https://example.com"}}' \
  "https://<PROJECT-REF>.functions.supabase.co/csp-report"
```

**期待**: HTTP/1.1 204 No Content

### 実際の使用例
```bash
# PROJECT-REFを実際の値に置き換える
PROJECT_REF="your-project-ref"
curl -i -X POST \
  -H "Content-Type: application/csp-report" \
  --data '{"csp-report":{"effective-directive":"connect-src","blocked-uri":"https://example.com","document-uri":"https://starlist.app","violated-directive":"connect-src"}}' \
  "https://${PROJECT_REF}.functions.supabase.co/csp-report"
```

---

## 便利なエイリアス（任意）

`.zshrc` または `.bashrc` に追加:

```bash
# PR関連
alias pr-list='gh pr list --repo shochaso/starlist-app'
alias pr-view='gh pr view 20 --repo shochaso/starlist-app'
alias pr-runs='gh run list --repo shochaso/starlist-app --branch fix/security-hardening-web-csp-lock'

# CI関連
alias ci-logs='gh run view'
alias ci-rerun='gh run rerun --repo shochaso/starlist-app'
```

---

**最終更新**: CLIコマンド集作成時点

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
