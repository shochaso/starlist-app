# クイック検証ガイド

## Web検証（Chrome）

### 1. アプリ起動

```bash
flutter run -d chrome
```

### 2. DevToolsで確認

1. Chrome DevToolsを開く（F12）
2. **Application**タブを選択
3. **Storage**セクションを確認:

   - **Local Storage** → トークン関連のキーが存在しない ✅
   - **Session Storage** → トークン関連のキーが存在しない ✅
   - **Cookies** → HttpOnlyセッションCookieが存在 ✅

4. **Console**タブを確認:

   - CSP違反ログが0件 ✅
   - エラーログが許容範囲内 ✅

### 3. リロードテスト

1. ページをリロード（F5）
2. トークンが永続化されていないことを確認 ✅
3. 再認証が必要な場合は正常動作 ✅

---

## モバイル検証

### iOS

```bash
flutter run -d ios
```

1. アプリでログイン
2. アプリを完全終了（スワイプアップで終了）
3. アプリを再起動
4. セッションが維持されていることを確認 ✅

### Android

```bash
flutter run -d android
```

1. アプリでログイン
2. アプリを完全終了
3. アプリを再起動
4. セッションが維持されていることを確認 ✅

---

## Supabase環境変数検証

### スクリプト実行

```bash
export SUPABASE_URL="https://<project-ref>.supabase.co"
export OPS_SERVICE_SECRET="<your-secret>"
chmod +x scripts/verify_supabase_env.sh
./scripts/verify_supabase_env.sh
```

### 手動確認

```bash
# 正常ケース
curl -i -X POST \
  -H "origin: https://app.starlist.jp" \
  -H "x-ops-secret: $OPS_SERVICE_SECRET" \
  -H "content-type: application/json" \
  -d '{"dryRun":true}' \
  "https://<project-ref>.functions.supabase.co/ops-alert"

# 期待: HTTP 200/204

# 拒否ケース
curl -i -X POST \
  -H "origin: https://evil.example.com" \
  -H "x-ops-secret: BAD" \
  -H "content-type: application/json" \
  -d '{"dryRun":true}' \
  "https://<project-ref>.functions.supabase.co/ops-alert"

# 期待: HTTP 403
```

---

## CI検証

### GitHub Actions

1. GitHubリポジトリにアクセス
2. **Actions**タブを選択
3. **security-audit**ワークフローを選択
4. **Run workflow**をクリック
5. ブランチを選択（`fix/security-hardening-web-csp-lock`）
6. **Run workflow**をクリック
7. 実行結果を確認:

   - ✅ `semgrep` - 成功
   - ✅ `pnpm audit` - 成功（または警告のみ）
   - ✅ `dart pub outdated` - 成功
   - ✅ 全体がgreen

---

## トラブルシューティング

### Webでトークンが永続化されている

- `SecurePrefs`が正しく使用されているか確認
- `LocalStore`で機密キーを保存していないか確認
- ブラウザのキャッシュをクリアして再テスト

### CSP違反が発生している

- Consoleの違反ログを確認
- `web/index.html`のCSP設定を調整
- 外部リソースが必要な場合は`connect-src`や`img-src`に追加

### モバイルでセッションが維持されない

- `flutter_secure_storage`が正しくインストールされているか確認
- iOS: Keychain、Android: EncryptedSharedPreferencesが使用可能か確認
- アプリの権限設定を確認

### Supabase環境変数が反映されない

- Supabase Dashboardで設定を確認
- Edge Functionを再デプロイ
- 環境変数の名前が正確か確認（大文字小文字に注意）

