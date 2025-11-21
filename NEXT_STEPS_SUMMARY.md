---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# 次のステップ実行サマリ

## 実行済みチェック

### ✅ ファイル存在確認
- `lib/core/prefs/secure_prefs.dart` - 存在確認済み
- `lib/core/prefs/local_store.dart` - 存在確認済み
- `web/index.html` - 存在確認済み
- `.github/workflows/security-audit.yml` - 存在確認済み
- `pubspec.yaml` - 存在確認済み（flutter_secure_storage追加済み）

### ✅ CSP設定確認
- `Content-Security-Policy-Report-Only` - 設定済み
- `X-Frame-Options` - 設定済み
- `X-Content-Type-Options` - 設定済み
- `Referrer-Policy` - 設定済み

### ✅ ドキュメント準備
- `PR_CREATION_STEPS.md` - PR作成ガイド
- `FINAL_GO_NO_GO_CHECKLIST.md` - 最終チェックリスト
- `QUICK_VERIFICATION_GUIDE.md` - クイック検証ガイド
- `SECURITY_PR_BODY.md` - PR本文テンプレ
- `SUPABASE_ENV_SETUP.md` - Supabase環境変数設定ガイド

---

## 次のアクション

### 1. GitHubでPRを作成（最優先）

**URL**: https://github.com/shochaso/starlist-app/pull/new/fix/security-hardening-web-csp-lock

**手順**:
1. 上記URLにアクセス
2. タイトルを入力: `🔒 Security Hardening: Block Web Token Persistence, Add CSP, Enable Security CI`
3. 本文に`SECURITY_PR_BODY.md`の内容をコピー
4. Create pull requestをクリック

**詳細**: `PR_CREATION_STEPS.md`を参照

---

### 2. Supabase環境変数を設定

**設定場所**: Supabase Dashboard → Project Settings → Edge Functions → Environment Variables

**必要な変数**:
- `OPS_ALLOWED_ORIGINS` = `https://starlist.jp,https://app.starlist.jp`
- `OPS_SERVICE_SECRET` = ランダム文字列（32バイト推奨）

**生成方法**:
```bash
openssl rand -hex 32
# または
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

**検証**:
```bash
export SUPABASE_URL="https://<project-ref>.supabase.co"
export OPS_SERVICE_SECRET="<your-secret>"
./scripts/verify_supabase_env.sh
```

**詳細**: `SUPABASE_ENV_SETUP.md`を参照

---

### 3. 検証を実行

#### Web検証
```bash
flutter run -d chrome
```
- DevTools → Application → Storage でトークンが永続化されていないことを確認
- ConsoleでCSP違反が0件であることを確認

#### モバイル検証
```bash
flutter run -d ios    # または -d android
```
- ログイン → アプリ再起動 → セッション維持を確認

#### CI検証
- GitHub Actions → Workflows → `security-audit` → Run workflow
- ブランチ: `fix/security-hardening-web-csp-lock`
- 実行結果がgreenであることを確認

**詳細**: `QUICK_VERIFICATION_GUIDE.md`を参照

---

### 4. Phase 2 PRの準備（Phase 1マージ後）

#### CSP Enforce
- ブランチ: `feat/sec-csp-enforce`
- `web/index.html`の`Content-Security-Policy-Report-Only`を`Content-Security-Policy`に変更
- 1-3日の運用観察後に実施

#### Cookie認証
- ブランチ: `feat/auth-cookie-web-tokenless`
- Edge Function経由のCookieベースセッション管理を実装
- HttpOnly/SameSite=Lax Cookieの実装

**詳細**: `ADDITIONAL_BRANCHES.md`を参照

---

## マージ順（推奨）

1. `fix/security-hardening-web-csp-lock`（Phase 1）
2. `feat/sec-csp-enforce`（CSP Enforce）
3. `feat/auth-cookie-web-tokenless`（Cookie認証）

---

## トラブルシューティング

### PR作成時の問題
- GitHubでブランチが見つからない場合: プッシュを確認
- タイトルが長すぎる場合: 簡略版を使用

### Supabase環境変数の問題
- 設定が反映されない場合: Edge Functionを再デプロイ
- 検証スクリプトが失敗する場合: 環境変数の値を確認

### 検証時の問題
- Flutterがインストールされていない場合: `flutter doctor`で確認
- CSP違反が発生する場合: Consoleログを確認してポリシーを調整

---

## 関連ドキュメント

- `PR_CREATION_STEPS.md` - PR作成ステップガイド
- `FINAL_GO_NO_GO_CHECKLIST.md` - 最終チェックリスト
- `QUICK_VERIFICATION_GUIDE.md` - クイック検証ガイド
- `SECURITY_PR_BODY.md` - PR本文テンプレ
- `SUPABASE_ENV_SETUP.md` - Supabase環境変数設定ガイド
- `ADDITIONAL_BRANCHES.md` - 追加ブランチの説明

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
