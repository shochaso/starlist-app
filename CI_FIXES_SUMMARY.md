# CIワークフロー修正サマリ

## 🔧 修正した問題

### 1. security-audit.yml

**問題**: `dart pub get`が失敗（Flutter SDKが利用できない）

**エラー**:
```
Because starlist_app depends on flutter_test from sdk which doesn't exist (the Flutter SDK is not available), version solving failed.
Flutter users should use `flutter pub` instead of `dart pub`.
```

**修正**:
- `dart-lang/setup-dart@v1` → `subosito/flutter-action@v2` に変更
- `dart pub get` → `flutter pub get` に変更

---

### 2. extended-security.yml

**問題1**: pnpmが見つからない

**エラー**:
```
Unable to locate executable file: pnpm. Please verify either the file path exists or the file can be found within the PATH environment variable.
```

**修正**:
- `corepack enable` → `pnpm/action-setup@v4` に変更

**問題2**: trivy-results.sarifが存在しない

**エラー**:
```
Path does not exist: trivy-results.sarif
```

**修正**:
- `if: always()` → `if: always() && hashFiles('trivy-results.sarif') != ''` に変更

---

## 📋 修正後のワークフロー

### security-audit.yml

```yaml
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.24.0'
    channel: 'stable'

- name: flutter pub get
  run: flutter pub get
```

### extended-security.yml

```yaml
- name: Setup pnpm
  uses: pnpm/action-setup@v4
  with:
    version: 9

- name: Upload Trivy results
  uses: github/codeql-action/upload-sarif@v3
  if: always() && hashFiles('trivy-results.sarif') != ''
  with:
    sarif_file: 'trivy-results.sarif'
  continue-on-error: true
```

---

## 🔍 次の確認

1. **PRページでワークフローが再実行されるのを確認**
   - 修正がプッシュされたので、自動的に再実行されるはずです

2. **修正後のログを確認**
   ```bash
   gh run list --repo shochaso/starlist-app --branch fix/security-hardening-web-csp-lock --limit 5
   ```

3. **成功を確認**
   - `security-audit` が成功することを確認
   - `extended-security` が成功することを確認

---

**最終更新**: CIワークフロー修正完了時点

