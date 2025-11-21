---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# CI実行状況レポート

## 📊 ワークフロー実行状況

### ✅ 成功
- **rls-audit** (ID: 19193825313) - 完了
- **Guard No Image Loaders** (ID: 19193825286) - 完了

### ⚠️ 失敗
- **extended-security** (ID: 19193825282) - 失敗
- **security-audit** (ID: 19193825284) - 失敗
- **Docs Link Check** (ID: 19193825289) - 失敗

### 🔄 実行中
- **Flutter Startup Performance Check** (ID: 19193825287) - 実行中

---

## 🔍 失敗ワークフローの詳細確認

### extended-security (ID: 19193825282)

**ログ確認コマンド**:
```bash
gh run view 19193825282 --repo shochaso/starlist-app --log
```

**ブラウザで確認**:
```bash
gh run view 19193825282 --repo shochaso/starlist-app --web
```

---

### security-audit (ID: 19193825284)

**ログ確認コマンド**:
```bash
gh run view 19193825284 --repo shochaso/starlist-app --log
```

**ブラウザで確認**:
```bash
gh run view 19193825284 --repo shochaso/starlist-app --web
```

---

### Docs Link Check (ID: 19193825289)

**ログ確認コマンド**:
```bash
gh run view 19193825289 --repo shochaso/starlist-app --log
```

**ブラウザで確認**:
```bash
gh run view 19193825289 --repo shochaso/starlist-app --web
```

---

## 📝 ログファイル

- `/tmp/gh_run_extended_security_errors.log` - extended-security エラーログ
- `/tmp/gh_run_security_audit_errors.log` - security-audit エラーログ
- `/tmp/gh_run_docs_link_errors.log` - Docs Link Check エラーログ
- `/tmp/gh_run_extended_security_tail.log` - extended-security 詳細ログ（末尾）
- `/tmp/gh_run_security_audit_tail.log` - security-audit 詳細ログ（末尾）

---

## 🔧 次のアクション

1. **失敗ワークフローのログを確認**
   - 上記のコマンドでログを取得
   - エラーの原因を特定

2. **修正パッチの作成**
   - エラーの原因に応じて修正パッチを作成
   - 必要に応じてワークフロー設定を調整

3. **再実行**
   - 修正後、ワークフローを再実行
   - 成功を確認

---

**最終更新**: CI実行状況確認時点

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
