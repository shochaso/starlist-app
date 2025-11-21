---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# 🌐 GitHub UI確認ガイド（PR #20）

## PR #20 画面での確認ポイント

### 1. "Checks" タブの確認

**URL**: https://github.com/shochaso/starlist-app/pull/20/checks

#### security-audit ワークフロー
- ✅ pnpm audit - 成功か確認（moderate以下の警告は許容）
- ✅ dart pub outdated - 成功か確認
- ✅ semgrep - 成功か確認（critical/high がないこと）

**警告がある場合**:
```bash
# ログの"High/Critical"を確認
gh run view <RUN_ID> --repo shochaso/starlist-app --log | grep -i "high\|critical"
```

必要ならコメントで共有してください。

---

### 2. "Reviewers" セクション

1. レビューアーを追加（必要なら）
2. "Request review" をクリックして依頼

---

### 3. Auto-merge（任意）

レビュー済み・CI green 後に：
1. "Enable auto-merge" を有効化
2. マージ方法：**Squash** 推奨（コミット履歴を整理）

---

## マージ後の作業

### CSP観測（48–72時間）

#### 1. 本番/ステージングのConsoleで確認

```bash
# Chrome DevToolsで実行
flutter run -d chrome
```

**確認項目**:
- DevTools → Console → CSP Report-Only違反を確認
- 違反が許容範囲内であることを確認

#### 2. CSPレポート受信の確認

```bash
# /_/csp-report または Functions直URLでログ確認
gh run list --repo shochaso/starlist-app --workflow extended-security.yml --limit 5
```

#### 3. 頻出ドメインの調整

CSP違反で頻出するドメインがある場合：
- `connect-src`、`img-src`、`font-src` に最小限のドメインを追加
- 問題なければ Enforce 化PR（`feat/sec-csp-enforce`）へ

---

## 失敗時の即応（超短）

### ❌ pnpm audit がHigh以上

**対処**:
```bash
# 該当パッケージのminor/patch pinを検討
pnpm update <package-name> --latest

# または audit-level=moderate で運用し、依存経路をPR本文にメモ
pnpm audit --audit-level=moderate
```

---

### ❌ semgrepが危険API/秘密検知

**対処**:
```bash
# 該当行を修正（ログ出力抑制やAPI置換）
# 誤検知なら .semgrepignore に最小範囲で除外を追記

echo "path/to/file.dart" >> .semgrepignore
```

---

### ❌ gitleaksがシークレット検出

**緊急対処**:
1. すぐに無効化／ローテーション
2. 履歴からの削除（必要なら `git filter-repo`）
3. CI再実行

```bash
# 履歴からシークレットを削除
git filter-repo --invert-paths --path path/to/file-with-secret

# または BFG Repo-Cleanerを使用
bfg --delete-files file-with-secret
```

---

## 次に欲しいもの（ログ共有）

以下の情報を共有していただければ、最小差分パッチを即時ご用意します：

### 1. security-audit の実行ログURLとステータス

```bash
gh run list --repo shochaso/starlist-app --branch fix/security-hardening-web-csp-lock --workflow security-audit.yml --limit 1
```

**共有していただきたい情報**:
- 実行ログURL: `https://github.com/shochaso/starlist-app/actions/runs/<RUN_ID>`
- ステータス: success / failure / cancelled

---

### 2. 重大な指摘（High/Critical）の抜粋

```bash
# High/Criticalな指摘を抽出
gh run view <RUN_ID> --repo shochaso/starlist-app --log | grep -i "high\|critical"
```

**semgrep/gitleaks の重大な指摘がある場合**:
- 該当行番号
- 検出内容の抜粋
- ファイルパス

---

### 3. flutter run -d chrome でのConsoleのCSP違反サンプル

```bash
flutter run -d chrome
```

**DevTools → Consoleで確認**:
- CSP違反メッセージ
- 違反しているドメイン一覧（頻出順）

**例**:
```
[Report Only] Refused to connect to 'https://example.com/api' because it violates the following Content Security Policy directive: "connect-src 'self' https://*.supabase.co".
```

---

## ワークフロー確認コマンド集

### PR #20のワークフロー実行履歴

```bash
gh run list --repo shochaso/starlist-app --branch fix/security-hardening-web-csp-lock --limit 5
```

### 最新の実行ログを確認

```bash
RUN_ID=$(gh run list --repo shochaso/starlist-app --branch fix/security-hardening-web-csp-lock --workflow security-audit.yml --limit 1 --json databaseId --jq '.[0].databaseId')
gh run view $RUN_ID --repo shochaso/starlist-app --log
```

### 失敗したジョブのログのみ確認

```bash
gh run view $RUN_ID --repo shochaso/starlist-app --log-failed
```

### PR #20のステータス確認

```bash
gh pr view 20 --repo shochaso/starlist-app
```

---

## まとめ

1. **PR #20の"Checks"タブでCI結果を確認**
2. **警告がある場合は内容を確認し、必要に応じて共有**
3. **レビュー依頼を送信**
4. **マージ後、48-72時間のCSP観測**
5. **問題があれば上記の即応対処を実施**

ログやエラーを共有いただければ、最小差分パッチを即座に作成します！

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
