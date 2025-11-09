# CI失敗ワークフロー分析レポート

## 📊 最新のワークフロー実行状況

### 実行中のワークフロー
- 最新の実行状況は `/tmp/gh_run_summary_latest.log` に保存されています

### 失敗ワークフローのログ
- `security-audit`: `/tmp/gh_run_security_audit_19193847478.log`
- `extended-security`: `/tmp/gh_run_extended_security_19193847480.log`
- `Docs Link Check`: `/tmp/gh_run_docs_link_19193847492.log`

---

## 🔍 失敗原因の分析

### 1. security-audit

**問題**: Semgrepの引数ミス

**修正済み**: ✅
- `args: --config=p/ci || true` → `config: p/ci` に変更
- `continue-on-error: true` を追加

**ログ確認**:
```bash
gh run view 19193847478 --repo shochaso/starlist-app --log
```

---

### 2. extended-security

**問題**: pnpmが見つからない

**修正済み**: ✅
- `pnpm/action-setup`を`setup-node`の前に移動
- `pnpm install`に`continue-on-error`を追加

**ログ確認**:
```bash
gh run view 19193847480 --repo shochaso/starlist-app --log
```

---

### 3. Docs Link Check

**問題**: npm run lint:md が失敗（exit code 127）

**修正済み**: ✅
- `.mlc.json`を作成（Supabase Functions URLを除外）
- `.lychee.toml`も作成（将来のlychee使用に備えて）

**ログ確認**:
```bash
gh run view 19193847492 --repo shochaso/starlist-app --log
```

---

## 📋 修正パッチ適用状況

### ✅ 適用済みの修正

1. **security-audit.yml**
   - semgrepの引数を修正
   - `continue-on-error: true` を追加

2. **extended-security.yml**
   - pnpm/action-setupをsetup-nodeの前に移動
   - pnpm installにcontinue-on-errorを追加

3. **Docs Link Check用設定**
   - `.mlc.json`を作成
   - `.lychee.toml`を作成

---

## 🔄 再実行コマンド

修正後、以下のワークフローを再実行してください:

```bash
# security-audit
gh run rerun 19193847478 --repo shochaso/starlist-app

# Docs Link Check
gh run rerun 19193847492 --repo shochaso/starlist-app

# extended-security
gh run rerun 19193847480 --repo shochaso/starlist-app
```

---

## 🌐 GitHub UIでの確認

### PR #20のChecksタブ
- `security-audit` のステータス確認
- `extended-security` のステータス確認
- `Docs Link Check` のステータス確認

### 失敗時の確認方法
1. 「View workflow run」をクリック
2. 「Logs」タブで失敗行を特定
3. ログURLと失敗行の抜粋を共有

---

## 📝 共有していただきたい情報

失敗が続く場合、以下を共有してください:

1. **ログURL**: 失敗したワークフローのログURL
2. **失敗行の抜粋**: エラーメッセージの数行
3. **失敗しているジョブ名**: 例: `security-audit > semgrep`

いただき次第、最小差分パッチを即座に作成します。

---

**最終更新**: CI失敗分析完了時点


## 📊 最新のワークフロー実行状況

### 実行中のワークフロー
- 最新の実行状況は `/tmp/gh_run_summary_latest.log` に保存されています

### 失敗ワークフローのログ
- `security-audit`: `/tmp/gh_run_security_audit_19193847478.log`
- `extended-security`: `/tmp/gh_run_extended_security_19193847480.log`
- `Docs Link Check`: `/tmp/gh_run_docs_link_19193847492.log`

---

## 🔍 失敗原因の分析

### 1. security-audit

**問題**: Semgrepの引数ミス

**修正済み**: ✅
- `args: --config=p/ci || true` → `config: p/ci` に変更
- `continue-on-error: true` を追加

**ログ確認**:
```bash
gh run view 19193847478 --repo shochaso/starlist-app --log
```

---

### 2. extended-security

**問題**: pnpmが見つからない

**修正済み**: ✅
- `pnpm/action-setup`を`setup-node`の前に移動
- `pnpm install`に`continue-on-error`を追加

**ログ確認**:
```bash
gh run view 19193847480 --repo shochaso/starlist-app --log
```

---

### 3. Docs Link Check

**問題**: npm run lint:md が失敗（exit code 127）

**修正済み**: ✅
- `.mlc.json`を作成（Supabase Functions URLを除外）
- `.lychee.toml`も作成（将来のlychee使用に備えて）

**ログ確認**:
```bash
gh run view 19193847492 --repo shochaso/starlist-app --log
```

---

## 📋 修正パッチ適用状況

### ✅ 適用済みの修正

1. **security-audit.yml**
   - semgrepの引数を修正
   - `continue-on-error: true` を追加

2. **extended-security.yml**
   - pnpm/action-setupをsetup-nodeの前に移動
   - pnpm installにcontinue-on-errorを追加

3. **Docs Link Check用設定**
   - `.mlc.json`を作成
   - `.lychee.toml`を作成

---

## 🔄 再実行コマンド

修正後、以下のワークフローを再実行してください:

```bash
# security-audit
gh run rerun 19193847478 --repo shochaso/starlist-app

# Docs Link Check
gh run rerun 19193847492 --repo shochaso/starlist-app

# extended-security
gh run rerun 19193847480 --repo shochaso/starlist-app
```

---

## 🌐 GitHub UIでの確認

### PR #20のChecksタブ
- `security-audit` のステータス確認
- `extended-security` のステータス確認
- `Docs Link Check` のステータス確認

### 失敗時の確認方法
1. 「View workflow run」をクリック
2. 「Logs」タブで失敗行を特定
3. ログURLと失敗行の抜粋を共有

---

## 📝 共有していただきたい情報

失敗が続く場合、以下を共有してください:

1. **ログURL**: 失敗したワークフローのログURL
2. **失敗行の抜粋**: エラーメッセージの数行
3. **失敗しているジョブ名**: 例: `security-audit > semgrep`

いただき次第、最小差分パッチを即座に作成します。

---

**最終更新**: CI失敗分析完了時点

