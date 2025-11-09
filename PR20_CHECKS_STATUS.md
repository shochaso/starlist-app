# PR #20 Checks ステータス確認レポート

## 📊 最新のワークフロー実行状況

### security-audit
- 最新の実行状況は `/tmp/gh_pr20_checks_latest.log` に保存されています
- 失敗ログの詳細は `/tmp/gh_security_audit_failure_details.log` に保存されています

### extended-security
- 最新の実行状況は `/tmp/gh_pr20_checks_latest.log` に保存されています
- 失敗ログの詳細は `/tmp/gh_extended_security_failure_details.log` に保存されています

---

## 🔍 失敗ステップの特定

### security-audit の失敗ステップ

失敗ステップとエラーメッセージを確認するには:

```bash
gh run view <RUN_ID> --repo shochaso/starlist-app --log | grep -B 2 -A 10 -E "(error|Error|ERROR|failed|Failed|FAILED|exit code)"
```

### extended-security の失敗ステップ

失敗ステップとエラーメッセージを確認するには:

```bash
gh run view <RUN_ID> --repo shochaso/starlist-app --log | grep -B 2 -A 10 -E "(error|Error|ERROR|failed|Failed|FAILED|exit code)"
```

---

## 📋 共有していただきたい情報

失敗が続く場合、以下を共有してください:

1. **失敗ステップ名**: 例: `security-audit > dart pub get`
2. **エラーメッセージ**: 2〜3行の実エラー
3. **ログURL**: 失敗したワークフローのログURL

いただき次第、最小差分パッチを即座に作成します。

---

## 🔧 追加のフォロー（必要に応じて）

### キャッシュ不整合が疑われる場合

一時的に `dart pub cache repair` を挟むか、`actions/cache` を無効化して再実行してください。

### Docs Link Check

Docs Link Checkは成功済みです。Functions直URLの除外は継続で問題ありません。

---

**最終更新**: PR #20 Checks ステータス確認完了時点


## 📊 最新のワークフロー実行状況

### security-audit
- 最新の実行状況は `/tmp/gh_pr20_checks_latest.log` に保存されています
- 失敗ログの詳細は `/tmp/gh_security_audit_failure_details.log` に保存されています

### extended-security
- 最新の実行状況は `/tmp/gh_pr20_checks_latest.log` に保存されています
- 失敗ログの詳細は `/tmp/gh_extended_security_failure_details.log` に保存されています

---

## 🔍 失敗ステップの特定

### security-audit の失敗ステップ

失敗ステップとエラーメッセージを確認するには:

```bash
gh run view <RUN_ID> --repo shochaso/starlist-app --log | grep -B 2 -A 10 -E "(error|Error|ERROR|failed|Failed|FAILED|exit code)"
```

### extended-security の失敗ステップ

失敗ステップとエラーメッセージを確認するには:

```bash
gh run view <RUN_ID> --repo shochaso/starlist-app --log | grep -B 2 -A 10 -E "(error|Error|ERROR|failed|Failed|FAILED|exit code)"
```

---

## 📋 共有していただきたい情報

失敗が続く場合、以下を共有してください:

1. **失敗ステップ名**: 例: `security-audit > dart pub get`
2. **エラーメッセージ**: 2〜3行の実エラー
3. **ログURL**: 失敗したワークフローのログURL

いただき次第、最小差分パッチを即座に作成します。

---

## 🔧 追加のフォロー（必要に応じて）

### キャッシュ不整合が疑われる場合

一時的に `dart pub cache repair` を挟むか、`actions/cache` を無効化して再実行してください。

### Docs Link Check

Docs Link Checkは成功済みです。Functions直URLの除外は継続で問題ありません。

---

**最終更新**: PR #20 Checks ステータス確認完了時点

