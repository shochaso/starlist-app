# 🔒 セキュリティ修正PR 検証チェックリスト

## 基本チェック

- [ ] Web：リロードでトークン未永続化 **OK**
- [ ] Web：CSP Report-Only で大きなブロック無し **OK**
- [ ] iOS/Android：セッション復元 **OK**
- [ ] CI：`security-audit` green **OK**
- [ ] `pnpm-lock.yaml`（該当時）：追加済 **OK**

## 詳細検証手順

### 1. Web検証

```bash
flutter run -d chrome
```

**確認項目**:
- DevTools → Application → Storage → Local Storage にトークン関連のキーが存在しない
- DevTools → Application → Storage → Session Storage にトークン関連のキーが存在しない
- DevTools → Application → Storage → Cookies にトークン関連のCookieが存在しない
- DevTools → Console で CSP Report-Only の違反ログを確認（許容範囲内であること）

### 2. iOS/Android検証

```bash
flutter run -d ios    # または -d android
```

**確認項目**:
- ログイン後、アプリを完全終了
- アプリを再起動
- セッションが復元されていること（再ログイン不要）

### 3. CI検証

GitHub Actionsで以下を確認:
- `.github/workflows/security-audit.yml` が実行される
- `pnpm audit` が成功（または警告のみ）
- `dart pub outdated` が成功
- Semgrepが実行される（エラーがあってもcontinue-on-errorで継続）

## 追加チェック結果

### localStorage探索
- ✅ `lib/core/prefs/local_store.dart`: 非機密データ用として使用（問題なし）
- ✅ `lib/core/prefs/secure_prefs.dart`: コメント内のみ（問題なし）

### Android minSdkVersion
- ⚠️ `android/app/build.gradle` の確認が必要
- `flutter_secure_storage` は minSdk >= 23 を推奨

### package.json
- ✅ 存在確認済み
- ⚠️ `pnpm-lock.yaml` の生成が必要（Node.js 20環境で実行）

## 既知のリスクと対処

### Webの再認証導線
- **リスク**: UXに影響が出る可能性
- **対処**: Edge Function経由のセッション再発行（短命Cookie）を実装し、Silent Refreshを実現

### CSP調整
- **リスク**: 外部CDN等を利用している場合、CSP違反が発生する可能性
- **対処**: `connect-src/img-src/style-src` を最小範囲で許可に追記

## ロールバック手順

1. **CSPをReport-Onlyに戻す**: `web/index.html` の `Content-Security-Policy-Report-Only` を削除
2. **SecurePrefs→従来実装へ戻す**: `lib/core/prefs/local_store.dart` の `_assertKey` チェックを削除
3. **セキュリティCIを無効化**: `.github/workflows/security-audit.yml` を削除または無効化


## 基本チェック

- [ ] Web：リロードでトークン未永続化 **OK**
- [ ] Web：CSP Report-Only で大きなブロック無し **OK**
- [ ] iOS/Android：セッション復元 **OK**
- [ ] CI：`security-audit` green **OK**
- [ ] `pnpm-lock.yaml`（該当時）：追加済 **OK**

## 詳細検証手順

### 1. Web検証

```bash
flutter run -d chrome
```

**確認項目**:
- DevTools → Application → Storage → Local Storage にトークン関連のキーが存在しない
- DevTools → Application → Storage → Session Storage にトークン関連のキーが存在しない
- DevTools → Application → Storage → Cookies にトークン関連のCookieが存在しない
- DevTools → Console で CSP Report-Only の違反ログを確認（許容範囲内であること）

### 2. iOS/Android検証

```bash
flutter run -d ios    # または -d android
```

**確認項目**:
- ログイン後、アプリを完全終了
- アプリを再起動
- セッションが復元されていること（再ログイン不要）

### 3. CI検証

GitHub Actionsで以下を確認:
- `.github/workflows/security-audit.yml` が実行される
- `pnpm audit` が成功（または警告のみ）
- `dart pub outdated` が成功
- Semgrepが実行される（エラーがあってもcontinue-on-errorで継続）

## 追加チェック結果

### localStorage探索
- ✅ `lib/core/prefs/local_store.dart`: 非機密データ用として使用（問題なし）
- ✅ `lib/core/prefs/secure_prefs.dart`: コメント内のみ（問題なし）

### Android minSdkVersion
- ⚠️ `android/app/build.gradle` の確認が必要
- `flutter_secure_storage` は minSdk >= 23 を推奨

### package.json
- ✅ 存在確認済み
- ⚠️ `pnpm-lock.yaml` の生成が必要（Node.js 20環境で実行）

## 既知のリスクと対処

### Webの再認証導線
- **リスク**: UXに影響が出る可能性
- **対処**: Edge Function経由のセッション再発行（短命Cookie）を実装し、Silent Refreshを実現

### CSP調整
- **リスク**: 外部CDN等を利用している場合、CSP違反が発生する可能性
- **対処**: `connect-src/img-src/style-src` を最小範囲で許可に追記

## ロールバック手順

1. **CSPをReport-Onlyに戻す**: `web/index.html` の `Content-Security-Policy-Report-Only` を削除
2. **SecurePrefs→従来実装へ戻す**: `lib/core/prefs/local_store.dart` の `_assertKey` チェックを削除
3. **セキュリティCIを無効化**: `.github/workflows/security-audit.yml` を削除または無効化

