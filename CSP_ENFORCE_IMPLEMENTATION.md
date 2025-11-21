---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# CSP Enforce 実装完了

## 📋 実装内容

### 1. Vercel 配信の場合

**作成ファイル**: `vercel.json`

```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "Content-Security-Policy",
          "value": "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: https:; font-src 'self' https://fonts.gstatic.com data:; connect-src 'self' https://*.supabase.co wss://*.supabase.co https://api.segment.io https://sentry.io https://*.sentry.io; frame-ancestors 'none'; base-uri 'self'; form-action 'self'; upgrade-insecure-requests"
        },
        {
          "key": "X-Frame-Options",
          "value": "DENY"
        },
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        },
        {
          "key": "Referrer-Policy",
          "value": "strict-origin-when-cross-origin"
        }
      ]
    }
  ]
}
```bash

### 2. Cloudflare Pages の場合

**作成ファイル**: `_headers`

```bash
/*
  Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: https:; font-src 'self' https://fonts.gstatic.com data:; connect-src 'self' https://*.supabase.co wss://*.supabase.co https://api.segment.io https://sentry.io https://*.sentry.io; frame-ancestors 'none'; base-uri 'self'; form-action 'self'; upgrade-insecure-requests
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
```

### 3. NGINX の場合

**参考ファイル**: `nginx-csp-example.conf`

```bash
add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: https:; font-src 'self' https://fonts.gstatic.com data:; connect-src 'self' https://*.supabase.co wss://*.supabase.co https://api.segment.io https://sentry.io https://*.sentry.io; frame-ancestors 'none'; base-uri 'self'; form-action 'self'; upgrade-insecure-requests" always;
```

### 4. Flutter Web: `web/index.html`

**変更内容**:
- Report-Only CSP meta タグを削除（コメント化）
- セキュリティヘッダーの meta タグもコメント化（配信ヘッダで適用）

---

## 🔍 CSP 許可セット（最小限）

### connect-src
- `'self'`
- `https://*.supabase.co` (Supabase API)
- `wss://*.supabase.co` (Supabase WebSocket)
- `https://api.segment.io` (Segment Analytics)
- `https://sentry.io` (Sentry Error Tracking)
- `https://*.sentry.io` (Sentry CDN)

### img-src
- `'self'`
- `data:` (Base64画像)
- `https:` (外部画像リソース)

### font-src
- `'self'`
- `https://fonts.gstatic.com` (Google Fonts)
- `data:` (Base64フォント)

---

## ✅ 検証項目

### 1. DevTools Console に CSP エラーがないこと

```bash
# ブラウザの開発者ツール（F12）を開く
# Console タブで CSP 違反がないことを確認
```

### 2. Sign-in → API 呼び出し → 画像/フォントの読み込みを手動確認

- [ ] サインインが正常に動作する
- [ ] Supabase API 呼び出しが正常に動作する
- [ ] 画像の読み込みが正常に動作する
- [ ] フォントの読み込みが正常に動作する

### 3. ブラウザ保存の痕跡確認

```bash
grep -R --line-number -E "supabase\.auth\.token|jwt|access_token" build/ web/ || true
```

**確認結果**: ✅ token 関連の保存コードは見つかりませんでした

### 4. モバイル（該当時）

- [ ] ログイン → タスクキル → 再起動でセッション復元（flutter_secure_storage）

---

## 🔄 ロールバック手順

### 1. Vercel の場合

`vercel.json` の `Content-Security-Policy` を `Content-Security-Policy-Report-Only` に変更:

```json
{
  "key": "Content-Security-Policy-Report-Only",
  "value": "..."
}
```

### 2. Cloudflare Pages の場合

`_headers` の `Content-Security-Policy` を `Content-Security-Policy-Report-Only` に変更:

```bash
Content-Security-Policy-Report-Only: ...
```

### 3. NGINX の場合

`add_header` の `Content-Security-Policy` を `Content-Security-Policy-Report-Only` に変更:

```bash
add_header Content-Security-Policy-Report-Only "..." always;
```

### 4. 緊急時

必要に応じて `web/index.html` の Report-Only meta を一時復活:

```html
<meta http-equiv="Content-Security-Policy-Report-Only" content="...">
```

---

## 📋 追加が必要な許可先（候補）

観測ログに基づき、以下の許可先を追加する可能性があります:

1. **https://api.resend.com** - メール送信サービス（Resend使用時）
2. **https://*.cloudflare.com** - Cloudflare CDN（使用時）
3. **https://*.vercel.app** - Vercel プレビュー環境（使用時）
4. **https://cdn.jsdelivr.net** - CDN（使用時）
5. **https://unpkg.com** - CDN（使用時）

---

## 🚀 デプロイ後の確認

1. **CSP ヘッダーの確認**
   ```bash
   curl -I https://your-domain.com | grep -i content-security-policy
   ```

2. **Console エラーの確認**
   - ブラウザの開発者ツールで Console タブを確認
   - CSP 違反がないことを確認

3. **機能テスト**
   - サインイン
   - API 呼び出し
   - 画像/フォントの読み込み

---

**最終更新**: CSP Enforce 実装完了時点


## 📋 実装内容

### 1. Vercel 配信の場合

**作成ファイル**: `vercel.json`

```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "Content-Security-Policy",
          "value": "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: https:; font-src 'self' https://fonts.gstatic.com data:; connect-src 'self' https://*.supabase.co wss://*.supabase.co https://api.segment.io https://sentry.io https://*.sentry.io; frame-ancestors 'none'; base-uri 'self'; form-action 'self'; upgrade-insecure-requests"
        },
        {
          "key": "X-Frame-Options",
          "value": "DENY"
        },
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        },
        {
          "key": "Referrer-Policy",
          "value": "strict-origin-when-cross-origin"
        }
      ]
    }
  ]
}
```

### 2. Cloudflare Pages の場合

**作成ファイル**: `_headers`

```bash
/*
  Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: https:; font-src 'self' https://fonts.gstatic.com data:; connect-src 'self' https://*.supabase.co wss://*.supabase.co https://api.segment.io https://sentry.io https://*.sentry.io; frame-ancestors 'none'; base-uri 'self'; form-action 'self'; upgrade-insecure-requests
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
```

### 3. NGINX の場合

**参考ファイル**: `nginx-csp-example.conf`

```bash
add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: https:; font-src 'self' https://fonts.gstatic.com data:; connect-src 'self' https://*.supabase.co wss://*.supabase.co https://api.segment.io https://sentry.io https://*.sentry.io; frame-ancestors 'none'; base-uri 'self'; form-action 'self'; upgrade-insecure-requests" always;
```

### 4. Flutter Web: `web/index.html`

**変更内容**:
- Report-Only CSP meta タグを削除（コメント化）
- セキュリティヘッダーの meta タグもコメント化（配信ヘッダで適用）

---

## 🔍 CSP 許可セット（最小限）

### connect-src
- `'self'`
- `https://*.supabase.co` (Supabase API)
- `wss://*.supabase.co` (Supabase WebSocket)
- `https://api.segment.io` (Segment Analytics)
- `https://sentry.io` (Sentry Error Tracking)
- `https://*.sentry.io` (Sentry CDN)

### img-src
- `'self'`
- `data:` (Base64画像)
- `https:` (外部画像リソース)

### font-src
- `'self'`
- `https://fonts.gstatic.com` (Google Fonts)
- `data:` (Base64フォント)

---

## ✅ 検証項目

### 1. DevTools Console に CSP エラーがないこと

```bash
# ブラウザの開発者ツール（F12）を開く
# Console タブで CSP 違反がないことを確認
```

### 2. Sign-in → API 呼び出し → 画像/フォントの読み込みを手動確認

- [ ] サインインが正常に動作する
- [ ] Supabase API 呼び出しが正常に動作する
- [ ] 画像の読み込みが正常に動作する
- [ ] フォントの読み込みが正常に動作する

### 3. ブラウザ保存の痕跡確認

```bash
grep -R --line-number -E "supabase\.auth\.token|jwt|access_token" build/ web/ || true
```

**確認結果**: ✅ token 関連の保存コードは見つかりませんでした

### 4. モバイル（該当時）

- [ ] ログイン → タスクキル → 再起動でセッション復元（flutter_secure_storage）

---

## 🔄 ロールバック手順

### 1. Vercel の場合

`vercel.json` の `Content-Security-Policy` を `Content-Security-Policy-Report-Only` に変更:

```json
{
  "key": "Content-Security-Policy-Report-Only",
  "value": "..."
}
```

### 2. Cloudflare Pages の場合

`_headers` の `Content-Security-Policy` を `Content-Security-Policy-Report-Only` に変更:

```bash
Content-Security-Policy-Report-Only: ...
```

### 3. NGINX の場合

`add_header` の `Content-Security-Policy` を `Content-Security-Policy-Report-Only` に変更:

```bash
add_header Content-Security-Policy-Report-Only "..." always;
```

### 4. 緊急時

必要に応じて `web/index.html` の Report-Only meta を一時復活:

```html
<meta http-equiv="Content-Security-Policy-Report-Only" content="...">
```

---

## 📋 追加が必要な許可先（候補）

観測ログに基づき、以下の許可先を追加する可能性があります:

1. **https://api.resend.com** - メール送信サービス（Resend使用時）
2. **https://*.cloudflare.com** - Cloudflare CDN（使用時）
3. **https://*.vercel.app** - Vercel プレビュー環境（使用時）
4. **https://cdn.jsdelivr.net** - CDN（使用時）
5. **https://unpkg.com** - CDN（使用時）

---

## 🚀 デプロイ後の確認

1. **CSP ヘッダーの確認**
   ```bash
   curl -I https://your-domain.com | grep -i content-security-policy
   ```

2. **Console エラーの確認**
   - ブラウザの開発者ツールで Console タブを確認
   - CSP 違反がないことを確認

3. **機能テスト**
   - サインイン
   - API 呼び出し
   - 画像/フォントの読み込み

---

**最終更新**: CSP Enforce 実装完了時点

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
