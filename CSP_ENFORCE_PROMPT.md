# CSP Enforce 実装プロンプト

## 【目的】

Flutter Web + Supabase アプリのCSP（Content Security Policy）を配信ヘッダでEnforce化し、強化ディレクティブ（object-src, manifest-src, worker-src, media-src）を追加してセキュリティを向上させる。

---

## 【前提】

- **環境**: Flutter Web + Supabase
- **配信経路**: Vercel または Cloudflare Pages（片方のみ使用）
- **依存**:
  - Supabase API (`https://*.supabase.co`, `wss://*.supabase.co`)
  - Segment Analytics (`https://api.segment.io`)
  - Sentry Error Tracking (`https://sentry.io`, `https://*.sentry.io`)
  - Google Fonts (`https://fonts.googleapis.com`, `https://fonts.gstatic.com`)
- **既存実装**: Report-Only CSP metaタグは削除済み、配信ヘッダで統一

---

## 【要件】

### 変更点
1. **CSP Enforce化**: Report-Only → Enforce（配信ヘッダで適用）
2. **強化ディレクティブ追加**:
   - `object-src 'none';` - オブジェクト要素の無効化
   - `manifest-src 'self';` - Web App Manifest の読み込み制限
   - `worker-src 'self' blob:;` - Service Worker / Web Worker の許可（CanvasKit使用時）
   - `media-src 'self' https: blob:;` - メディアリソースの許可（CanvasKit使用時）

### 非機能要件
- **差分最小**: 既存の許可先（Supabase/Segment/Sentry/Fonts）を維持
- **ロールバック容易**: 配信ヘッダの変更のみで切り戻し可能（`Content-Security-Policy` → `Content-Security-Policy-Report-Only`）
- **既存通信への影響なし**: Sign-in、API呼び出し、画像/フォント読み込みが正常に動作

### ロールバック方針
- `Content-Security-Policy` → `Content-Security-Policy-Report-Only` に即時切替
- 必要に応じて `web/index.html` の Report-Only meta を一時復活

---

## 【対象ファイル】

### Vercel運用の場合
- `vercel.json` - CSPヘッダー設定を追加/更新

### Cloudflare Pages運用の場合
- `_headers` - CSPヘッダー設定を追加/更新

### NGINX運用の場合
- `nginx-csp-example.conf` - CSPヘッダー設定例を追加/更新

### 共通
- `web/index.html` - CSP metaタグ削除（コメント化）
- `CSP_ENFORCE_VERIFICATION.md` - 検証ログに追記

---

## 【実装手順】

### 1. 現在の配信環境を確認

```bash
# Vercel運用の場合
ls -la vercel.json

# Cloudflare Pages運用の場合
ls -la _headers

# NGINX運用の場合
ls -la nginx-csp-example.conf
```

### 2. CSPヘッダー設定を追加/更新

#### Vercel運用の場合

**ファイル**: `vercel.json`

```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "Content-Security-Policy",
          "value": "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: https:; font-src 'self' https://fonts.gstatic.com data:; connect-src 'self' https://*.supabase.co wss://*.supabase.co https://api.segment.io https://sentry.io https://*.sentry.io; frame-ancestors 'none'; base-uri 'self'; form-action 'self'; object-src 'none'; manifest-src 'self'; worker-src 'self' blob:; media-src 'self' https: blob:; upgrade-insecure-requests"
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

#### Cloudflare Pages運用の場合

**ファイル**: `_headers`

```
/*
  Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: https:; font-src 'self' https://fonts.gstatic.com data:; connect-src 'self' https://*.supabase.co wss://*.supabase.co https://api.segment.io https://sentry.io https://*.sentry.io; frame-ancestors 'none'; base-uri 'self'; form-action 'self'; object-src 'none'; manifest-src 'self'; worker-src 'self' blob:; media-src 'self' https: blob:; upgrade-insecure-requests
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
```

#### NGINX運用の場合

**ファイル**: `nginx-csp-example.conf`

```nginx
server {
    # ... 既存の設定 ...

    # CSP Enforce ヘッダー
    add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: https:; font-src 'self' https://fonts.gstatic.com data:; connect-src 'self' https://*.supabase.co wss://*.supabase.co https://api.segment.io https://sentry.io https://*.sentry.io; frame-ancestors 'none'; base-uri 'self'; form-action 'self'; object-src 'none'; manifest-src 'self'; worker-src 'self' blob:; media-src 'self' https: blob:; upgrade-insecure-requests" always;

    # その他のセキュリティヘッダー
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # ... 既存の設定 ...
}
```

### 3. web/index.html の CSP metaタグを削除（コメント化）

**ファイル**: `web/index.html`

```html
<!-- CSP Enforce: 配信ヘッダで適用（vercel.json または _headers で設定）
     72h Report-Only 観測結果に基づく最小許可セット
     connect-src: https://*.supabase.co wss://*.supabase.co https://api.segment.io https://sentry.io https://*.sentry.io
     img-src: 'self' data: https:
     font-src: 'self' https://fonts.gstatic.com data:
-->
<!-- セキュリティヘッダー: 配信ヘッダで適用（vercel.json または _headers で設定）
     X-Frame-Options: DENY
     X-Content-Type-Options: nosniff
     Referrer-Policy: strict-origin-when-cross-origin
-->
```

### 4. 変更をコミット・プッシュ

```bash
git add vercel.json _headers nginx-csp-example.conf web/index.html CSP_ENFORCE_VERIFICATION.md
git commit -m "feat(security): implement CSP Enforce via delivery headers with hardening directives"
git push origin fix/security-hardening-web-csp-lock
```

### 5. デプロイ後の確認

```bash
# CSPヘッダーの確認（1本のみ出力されることを確認）
curl -I https://your-domain.com | grep -i content-security-policy
```

---

## 【テスト】

### DevTools Console

**確認方法**:
1. ブラウザの開発者ツール（F12）を開く
2. Console タブで CSP 違反がないことを確認

**合否基準**:
- ✅ CSP 違反エラーなし
- ✅ 警告のみ（非ブロッキング）は許容

### CLI

**確認コマンド**:
```bash
# CSPヘッダーの確認（1本のみ出力）
curl -I https://your-domain.com | grep -i content-security-policy

# token関連の保存コード確認
grep -R --line-number -E "supabase\.auth\.token|jwt|access_token" build/ web/ || true
```

**合否基準**:
- ✅ `Content-Security-Policy` ヘッダーが1本のみ出力される
- ✅ token関連の保存コードが見つからない

### E2E（手動確認）

**確認項目**:
- [ ] Sign-in が正常に動作する
- [ ] Supabase API 呼び出しが正常に動作する
- [ ] 画像の読み込みが正常に動作する
- [ ] フォントの読み込みが正常に動作する
- [ ] Service Worker / Web Worker が正常に動作する（CanvasKit使用時）
- [ ] メディアリソースの読み込みが正常に動作する（CanvasKit使用時）

**合否基準**:
- ✅ すべての項目が正常に動作する
- ✅ Console に CSP 違反エラーが出ない

---

## 【ロールバック】

### Vercel の場合

**ファイル**: `vercel.json`

```json
{
  "key": "Content-Security-Policy-Report-Only",
  "value": "..."
}
```

**手順**:
1. `vercel.json` の `Content-Security-Policy` を `Content-Security-Policy-Report-Only` に変更
2. コミット・プッシュ
3. Vercel が自動デプロイ

### Cloudflare Pages の場合

**ファイル**: `_headers`

```
Content-Security-Policy-Report-Only: ...
```

**手順**:
1. `_headers` の `Content-Security-Policy` を `Content-Security-Policy-Report-Only` に変更
2. コミット・プッシュ
3. Cloudflare Pages が自動デプロイ

### NGINX の場合

**ファイル**: `nginx-csp-example.conf`

```nginx
add_header Content-Security-Policy-Report-Only "..." always;
```

**手順**:
1. NGINX設定ファイルの `Content-Security-Policy` を `Content-Security-Policy-Report-Only` に変更
2. NGINX設定をリロード: `sudo nginx -t && sudo systemctl reload nginx`

### 緊急時

必要に応じて `web/index.html` の Report-Only meta を一時復活:

```html
<meta http-equiv="Content-Security-Policy-Report-Only" content="...">
```

---

## 【納品物】

### 変更差分

1. **vercel.json** - Vercel配信用CSPヘッダー設定
2. **_headers** - Cloudflare Pages用CSPヘッダー設定
3. **nginx-csp-example.conf** - NGINX用CSPヘッダー設定例
4. **web/index.html** - CSP metaタグ削除（コメント化）

### 検証ログ

**ファイル**: `CSP_ENFORCE_VERIFICATION.md`

**記録項目**:
- ✅ 強化ヘッダ反映日時: 2025-11-08
- ⏳ Consoleエラー確認結果: [デプロイ後に記録]
- ⏳ `curl`出力1行: [デプロイ後に記録]
- ⏳ 既存通信OK確認: [デプロイ後に記録]

### スクリーンショット（任意）

- DevTools Console（CSPエラーなしの状態）
- Network タブ（CSPヘッダーが設定されている状態）

---

## 📋 CSP許可セット（最終版）

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

### 強化ディレクティブ
- `object-src 'none';` - オブジェクト要素の無効化
- `manifest-src 'self';` - Web App Manifest の読み込み制限
- `worker-src 'self' blob:;` - Service Worker / Web Worker の許可
- `media-src 'self' https: blob:;` - メディアリソースの許可

### Stripe iframe用（将来使用時）
```csp
frame-src https://js.stripe.com https://hooks.stripe.com;
```

---

**最終更新**: CSP Enforce 実装プロンプト作成時点


## 【目的】

Flutter Web + Supabase アプリのCSP（Content Security Policy）を配信ヘッダでEnforce化し、強化ディレクティブ（object-src, manifest-src, worker-src, media-src）を追加してセキュリティを向上させる。

---

## 【前提】

- **環境**: Flutter Web + Supabase
- **配信経路**: Vercel または Cloudflare Pages（片方のみ使用）
- **依存**:
  - Supabase API (`https://*.supabase.co`, `wss://*.supabase.co`)
  - Segment Analytics (`https://api.segment.io`)
  - Sentry Error Tracking (`https://sentry.io`, `https://*.sentry.io`)
  - Google Fonts (`https://fonts.googleapis.com`, `https://fonts.gstatic.com`)
- **既存実装**: Report-Only CSP metaタグは削除済み、配信ヘッダで統一

---

## 【要件】

### 変更点
1. **CSP Enforce化**: Report-Only → Enforce（配信ヘッダで適用）
2. **強化ディレクティブ追加**:
   - `object-src 'none';` - オブジェクト要素の無効化
   - `manifest-src 'self';` - Web App Manifest の読み込み制限
   - `worker-src 'self' blob:;` - Service Worker / Web Worker の許可（CanvasKit使用時）
   - `media-src 'self' https: blob:;` - メディアリソースの許可（CanvasKit使用時）

### 非機能要件
- **差分最小**: 既存の許可先（Supabase/Segment/Sentry/Fonts）を維持
- **ロールバック容易**: 配信ヘッダの変更のみで切り戻し可能（`Content-Security-Policy` → `Content-Security-Policy-Report-Only`）
- **既存通信への影響なし**: Sign-in、API呼び出し、画像/フォント読み込みが正常に動作

### ロールバック方針
- `Content-Security-Policy` → `Content-Security-Policy-Report-Only` に即時切替
- 必要に応じて `web/index.html` の Report-Only meta を一時復活

---

## 【対象ファイル】

### Vercel運用の場合
- `vercel.json` - CSPヘッダー設定を追加/更新

### Cloudflare Pages運用の場合
- `_headers` - CSPヘッダー設定を追加/更新

### NGINX運用の場合
- `nginx-csp-example.conf` - CSPヘッダー設定例を追加/更新

### 共通
- `web/index.html` - CSP metaタグ削除（コメント化）
- `CSP_ENFORCE_VERIFICATION.md` - 検証ログに追記

---

## 【実装手順】

### 1. 現在の配信環境を確認

```bash
# Vercel運用の場合
ls -la vercel.json

# Cloudflare Pages運用の場合
ls -la _headers

# NGINX運用の場合
ls -la nginx-csp-example.conf
```

### 2. CSPヘッダー設定を追加/更新

#### Vercel運用の場合

**ファイル**: `vercel.json`

```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "Content-Security-Policy",
          "value": "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: https:; font-src 'self' https://fonts.gstatic.com data:; connect-src 'self' https://*.supabase.co wss://*.supabase.co https://api.segment.io https://sentry.io https://*.sentry.io; frame-ancestors 'none'; base-uri 'self'; form-action 'self'; object-src 'none'; manifest-src 'self'; worker-src 'self' blob:; media-src 'self' https: blob:; upgrade-insecure-requests"
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

#### Cloudflare Pages運用の場合

**ファイル**: `_headers`

```
/*
  Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: https:; font-src 'self' https://fonts.gstatic.com data:; connect-src 'self' https://*.supabase.co wss://*.supabase.co https://api.segment.io https://sentry.io https://*.sentry.io; frame-ancestors 'none'; base-uri 'self'; form-action 'self'; object-src 'none'; manifest-src 'self'; worker-src 'self' blob:; media-src 'self' https: blob:; upgrade-insecure-requests
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
```

#### NGINX運用の場合

**ファイル**: `nginx-csp-example.conf`

```nginx
server {
    # ... 既存の設定 ...

    # CSP Enforce ヘッダー
    add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: https:; font-src 'self' https://fonts.gstatic.com data:; connect-src 'self' https://*.supabase.co wss://*.supabase.co https://api.segment.io https://sentry.io https://*.sentry.io; frame-ancestors 'none'; base-uri 'self'; form-action 'self'; object-src 'none'; manifest-src 'self'; worker-src 'self' blob:; media-src 'self' https: blob:; upgrade-insecure-requests" always;

    # その他のセキュリティヘッダー
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # ... 既存の設定 ...
}
```

### 3. web/index.html の CSP metaタグを削除（コメント化）

**ファイル**: `web/index.html`

```html
<!-- CSP Enforce: 配信ヘッダで適用（vercel.json または _headers で設定）
     72h Report-Only 観測結果に基づく最小許可セット
     connect-src: https://*.supabase.co wss://*.supabase.co https://api.segment.io https://sentry.io https://*.sentry.io
     img-src: 'self' data: https:
     font-src: 'self' https://fonts.gstatic.com data:
-->
<!-- セキュリティヘッダー: 配信ヘッダで適用（vercel.json または _headers で設定）
     X-Frame-Options: DENY
     X-Content-Type-Options: nosniff
     Referrer-Policy: strict-origin-when-cross-origin
-->
```

### 4. 変更をコミット・プッシュ

```bash
git add vercel.json _headers nginx-csp-example.conf web/index.html CSP_ENFORCE_VERIFICATION.md
git commit -m "feat(security): implement CSP Enforce via delivery headers with hardening directives"
git push origin fix/security-hardening-web-csp-lock
```

### 5. デプロイ後の確認

```bash
# CSPヘッダーの確認（1本のみ出力されることを確認）
curl -I https://your-domain.com | grep -i content-security-policy
```

---

## 【テスト】

### DevTools Console

**確認方法**:
1. ブラウザの開発者ツール（F12）を開く
2. Console タブで CSP 違反がないことを確認

**合否基準**:
- ✅ CSP 違反エラーなし
- ✅ 警告のみ（非ブロッキング）は許容

### CLI

**確認コマンド**:
```bash
# CSPヘッダーの確認（1本のみ出力）
curl -I https://your-domain.com | grep -i content-security-policy

# token関連の保存コード確認
grep -R --line-number -E "supabase\.auth\.token|jwt|access_token" build/ web/ || true
```

**合否基準**:
- ✅ `Content-Security-Policy` ヘッダーが1本のみ出力される
- ✅ token関連の保存コードが見つからない

### E2E（手動確認）

**確認項目**:
- [ ] Sign-in が正常に動作する
- [ ] Supabase API 呼び出しが正常に動作する
- [ ] 画像の読み込みが正常に動作する
- [ ] フォントの読み込みが正常に動作する
- [ ] Service Worker / Web Worker が正常に動作する（CanvasKit使用時）
- [ ] メディアリソースの読み込みが正常に動作する（CanvasKit使用時）

**合否基準**:
- ✅ すべての項目が正常に動作する
- ✅ Console に CSP 違反エラーが出ない

---

## 【ロールバック】

### Vercel の場合

**ファイル**: `vercel.json`

```json
{
  "key": "Content-Security-Policy-Report-Only",
  "value": "..."
}
```

**手順**:
1. `vercel.json` の `Content-Security-Policy` を `Content-Security-Policy-Report-Only` に変更
2. コミット・プッシュ
3. Vercel が自動デプロイ

### Cloudflare Pages の場合

**ファイル**: `_headers`

```
Content-Security-Policy-Report-Only: ...
```

**手順**:
1. `_headers` の `Content-Security-Policy` を `Content-Security-Policy-Report-Only` に変更
2. コミット・プッシュ
3. Cloudflare Pages が自動デプロイ

### NGINX の場合

**ファイル**: `nginx-csp-example.conf`

```nginx
add_header Content-Security-Policy-Report-Only "..." always;
```

**手順**:
1. NGINX設定ファイルの `Content-Security-Policy` を `Content-Security-Policy-Report-Only` に変更
2. NGINX設定をリロード: `sudo nginx -t && sudo systemctl reload nginx`

### 緊急時

必要に応じて `web/index.html` の Report-Only meta を一時復活:

```html
<meta http-equiv="Content-Security-Policy-Report-Only" content="...">
```

---

## 【納品物】

### 変更差分

1. **vercel.json** - Vercel配信用CSPヘッダー設定
2. **_headers** - Cloudflare Pages用CSPヘッダー設定
3. **nginx-csp-example.conf** - NGINX用CSPヘッダー設定例
4. **web/index.html** - CSP metaタグ削除（コメント化）

### 検証ログ

**ファイル**: `CSP_ENFORCE_VERIFICATION.md`

**記録項目**:
- ✅ 強化ヘッダ反映日時: 2025-11-08
- ⏳ Consoleエラー確認結果: [デプロイ後に記録]
- ⏳ `curl`出力1行: [デプロイ後に記録]
- ⏳ 既存通信OK確認: [デプロイ後に記録]

### スクリーンショット（任意）

- DevTools Console（CSPエラーなしの状態）
- Network タブ（CSPヘッダーが設定されている状態）

---

## 📋 CSP許可セット（最終版）

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

### 強化ディレクティブ
- `object-src 'none';` - オブジェクト要素の無効化
- `manifest-src 'self';` - Web App Manifest の読み込み制限
- `worker-src 'self' blob:;` - Service Worker / Web Worker の許可
- `media-src 'self' https: blob:;` - メディアリソースの許可

### Stripe iframe用（将来使用時）
```csp
frame-src https://js.stripe.com https://hooks.stripe.com;
```

---

**最終更新**: CSP Enforce 実装プロンプト作成時点

