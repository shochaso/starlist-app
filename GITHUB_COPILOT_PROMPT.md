# GitHub Copilot用プロンプト（シェア可能版）

## セキュリティ修正PRのレビューと検証

以下のセキュリティ修正PRをレビューし、検証を実行してください。

### 背景

XSS攻撃による大量トークン窃取とサプライチェーン事故のリスク低減を目的に、以下のセキュリティ強化を実施しました。

### 変更内容

1. **Webでのトークン永続化を禁止**
   - `lib/core/prefs/secure_prefs.dart`（新規）: Webでは機密値の永続化を禁止、モバイルはSecureStorage
   - `lib/core/prefs/local_store.dart`: 機密キー保存を禁止

2. **CSP/セキュリティヘッダ追加**
   - `web/index.html`: Content-Security-Policy-Report-Only、X-Frame-Options、X-Content-Type-Options、Referrer-Policy

3. **セキュリティCI追加**
   - `.github/workflows/security-audit.yml`: pnpm audit、dart pub outdated、Semgrep

4. **依存関係追加**
   - `pubspec.yaml`: flutter_secure_storageを追加

### レビューポイント

1. **コードレビュー**
   - `lib/core/prefs/secure_prefs.dart`の実装が適切か（Webでの例外スロー、モバイルでのSecureStorage使用）
   - `lib/core/prefs/local_store.dart`の機密キーチェックが適切か
   - `web/index.html`のCSP設定が適切か（外部リソースの許可範囲）

2. **セキュリティレビュー**
   - Webでのトークン永続化が完全に禁止されているか
   - CSP設定がXSS/クリックジャッキング対策として適切か
   - 機密情報の漏洩リスクがないか

3. **テストレビュー**
   - Web/モバイルでの動作確認が必要
   - CIワークフローの動作確認が必要

### 検証タスク

以下の検証を実行してください：

- [ ] WebビルドでCSP違反が発生しないこと
- [ ] Webでトークンが永続化されていないこと（DevTools確認）
- [ ] モバイルでSecureStorageが正常に動作すること
- [ ] CIワークフロー（security-audit.yml）が正常に動作すること
- [ ] Dart分析でエラー・警告がないこと

### 関連ファイル

- `SECURITY_PR_BODY.md` - PR本文テンプレ
- `FINAL_GO_NO_GO_CHECKLIST.md` - 最終チェックリスト
- `QUICK_VERIFICATION_GUIDE.md` - クイック検証ガイド
- `SUPABASE_ENV_SETUP.md` - Supabase環境変数設定ガイド

---

## 検証実行コマンド

### Web検証

```bash
flutter run -d chrome
```

**確認項目**:
- DevTools → Application → Storage → Local Storageにトークン関連のキーが存在しない
- DevTools → Application → Storage → Session Storageにトークン関連のキーが存在しない
- DevTools → ConsoleでCSP違反ログが0件

### モバイル検証

```bash
flutter run -d ios    # または -d android
```

**確認項目**:
- ログイン → アプリ完全終了 → アプリ再起動 → セッション維持

### Supabase環境変数検証

```bash
export SUPABASE_URL="https://<project-ref>.supabase.co"
export OPS_SERVICE_SECRET="<your-secret>"
./scripts/verify_supabase_env.sh
```

**期待結果**:
- 正常ケース: HTTP 200/204
- 拒否ケース: HTTP 403

### CI検証

GitHub Actionsで以下を確認:
- `security-audit`ワークフローが実行される
- すべてのステップがgreen

---

## コードレビュー

以下のコードをレビューしてください。

### レビュー対象ファイル

1. `lib/core/prefs/secure_prefs.dart`
   - Webでの機密値永続化禁止の実装
   - モバイルでのSecureStorage使用
   - エラーメッセージの適切性

2. `lib/core/prefs/local_store.dart`
   - 機密キーチェックの実装
   - エラーメッセージの適切性

3. `web/index.html`
   - CSP設定の適切性
   - セキュリティヘッダの設定

4. `.github/workflows/security-audit.yml`
   - CIワークフローの設定
   - セキュリティチェックの網羅性

### チェックポイント

- [ ] セキュリティベストプラクティスに準拠しているか
- [ ] エラーハンドリングが適切か
- [ ] ドキュメントが十分か
- [ ] テストが適切か（可能であれば）

---

## トラブルシューティング

### よくある問題

1. **Webでトークンが永続化されている**
   - `SecurePrefs`が正しく使用されているか確認
   - `LocalStore`で機密キーを保存していないか確認
   - ブラウザのキャッシュをクリア

2. **CSP違反が発生している**
   - Consoleの違反ログを確認
   - `web/index.html`のCSP設定を調整
   - 外部リソースが必要な場合は`connect-src`や`img-src`に追加

3. **モバイルでセッションが維持されない**
   - `flutter_secure_storage`が正しくインストールされているか確認
   - iOS: Keychain、Android: EncryptedSharedPreferencesが使用可能か確認

4. **Supabase環境変数が反映されない**
   - Supabase Dashboardで設定を確認
   - Edge Functionを再デプロイ
   - 環境変数の名前が正確か確認

### デバッグコマンド

```bash
# Dart分析
dart analyze lib/core/prefs/secure_prefs.dart lib/core/prefs/local_store.dart

# Flutter依存関係確認
flutter pub get

# Supabase環境変数確認
./scripts/verify_supabase_env.sh
```


## セキュリティ修正PRのレビューと検証

以下のセキュリティ修正PRをレビューし、検証を実行してください。

### 背景

XSS攻撃による大量トークン窃取とサプライチェーン事故のリスク低減を目的に、以下のセキュリティ強化を実施しました。

### 変更内容

1. **Webでのトークン永続化を禁止**
   - `lib/core/prefs/secure_prefs.dart`（新規）: Webでは機密値の永続化を禁止、モバイルはSecureStorage
   - `lib/core/prefs/local_store.dart`: 機密キー保存を禁止

2. **CSP/セキュリティヘッダ追加**
   - `web/index.html`: Content-Security-Policy-Report-Only、X-Frame-Options、X-Content-Type-Options、Referrer-Policy

3. **セキュリティCI追加**
   - `.github/workflows/security-audit.yml`: pnpm audit、dart pub outdated、Semgrep

4. **依存関係追加**
   - `pubspec.yaml`: flutter_secure_storageを追加

### レビューポイント

1. **コードレビュー**
   - `lib/core/prefs/secure_prefs.dart`の実装が適切か（Webでの例外スロー、モバイルでのSecureStorage使用）
   - `lib/core/prefs/local_store.dart`の機密キーチェックが適切か
   - `web/index.html`のCSP設定が適切か（外部リソースの許可範囲）

2. **セキュリティレビュー**
   - Webでのトークン永続化が完全に禁止されているか
   - CSP設定がXSS/クリックジャッキング対策として適切か
   - 機密情報の漏洩リスクがないか

3. **テストレビュー**
   - Web/モバイルでの動作確認が必要
   - CIワークフローの動作確認が必要

### 検証タスク

以下の検証を実行してください：

- [ ] WebビルドでCSP違反が発生しないこと
- [ ] Webでトークンが永続化されていないこと（DevTools確認）
- [ ] モバイルでSecureStorageが正常に動作すること
- [ ] CIワークフロー（security-audit.yml）が正常に動作すること
- [ ] Dart分析でエラー・警告がないこと

### 関連ファイル

- `SECURITY_PR_BODY.md` - PR本文テンプレ
- `FINAL_GO_NO_GO_CHECKLIST.md` - 最終チェックリスト
- `QUICK_VERIFICATION_GUIDE.md` - クイック検証ガイド
- `SUPABASE_ENV_SETUP.md` - Supabase環境変数設定ガイド

---

## 検証実行コマンド

### Web検証

```bash
flutter run -d chrome
```

**確認項目**:
- DevTools → Application → Storage → Local Storageにトークン関連のキーが存在しない
- DevTools → Application → Storage → Session Storageにトークン関連のキーが存在しない
- DevTools → ConsoleでCSP違反ログが0件

### モバイル検証

```bash
flutter run -d ios    # または -d android
```

**確認項目**:
- ログイン → アプリ完全終了 → アプリ再起動 → セッション維持

### Supabase環境変数検証

```bash
export SUPABASE_URL="https://<project-ref>.supabase.co"
export OPS_SERVICE_SECRET="<your-secret>"
./scripts/verify_supabase_env.sh
```

**期待結果**:
- 正常ケース: HTTP 200/204
- 拒否ケース: HTTP 403

### CI検証

GitHub Actionsで以下を確認:
- `security-audit`ワークフローが実行される
- すべてのステップがgreen

---

## コードレビュー

以下のコードをレビューしてください。

### レビュー対象ファイル

1. `lib/core/prefs/secure_prefs.dart`
   - Webでの機密値永続化禁止の実装
   - モバイルでのSecureStorage使用
   - エラーメッセージの適切性

2. `lib/core/prefs/local_store.dart`
   - 機密キーチェックの実装
   - エラーメッセージの適切性

3. `web/index.html`
   - CSP設定の適切性
   - セキュリティヘッダの設定

4. `.github/workflows/security-audit.yml`
   - CIワークフローの設定
   - セキュリティチェックの網羅性

### チェックポイント

- [ ] セキュリティベストプラクティスに準拠しているか
- [ ] エラーハンドリングが適切か
- [ ] ドキュメントが十分か
- [ ] テストが適切か（可能であれば）

---

## トラブルシューティング

### よくある問題

1. **Webでトークンが永続化されている**
   - `SecurePrefs`が正しく使用されているか確認
   - `LocalStore`で機密キーを保存していないか確認
   - ブラウザのキャッシュをクリア

2. **CSP違反が発生している**
   - Consoleの違反ログを確認
   - `web/index.html`のCSP設定を調整
   - 外部リソースが必要な場合は`connect-src`や`img-src`に追加

3. **モバイルでセッションが維持されない**
   - `flutter_secure_storage`が正しくインストールされているか確認
   - iOS: Keychain、Android: EncryptedSharedPreferencesが使用可能か確認

4. **Supabase環境変数が反映されない**
   - Supabase Dashboardで設定を確認
   - Edge Functionを再デプロイ
   - 環境変数の名前が正確か確認

### デバッグコマンド

```bash
# Dart分析
dart analyze lib/core/prefs/secure_prefs.dart lib/core/prefs/local_store.dart

# Flutter依存関係確認
flutter pub get

# Supabase環境変数確認
./scripts/verify_supabase_env.sh
```

