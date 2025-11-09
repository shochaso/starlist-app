# CSP Enforce 実装検証ログ

## 📋 実装完了サマリ

### 作成・変更したファイル

1. **vercel.json** - Vercel配信用CSPヘッダー設定
2. **_headers** - Cloudflare Pages用CSPヘッダー設定
3. **nginx-csp-example.conf** - NGINX用CSPヘッダー設定例
4. **web/index.html** - Report-Only CSP meta削除（コメント化）
5. **CSP_ENFORCE_IMPLEMENTATION.md** - 実装ドキュメント

---

## 🔍 CSP許可セット（最小限）

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

## ✅ 検証結果

### ブラウザ保存の痕跡確認

```bash
grep -R --line-number -E "supabase\.auth\.token|jwt|access_token" build/ web/ || true
```

**結果**: ✅ token関連の保存コードは見つかりませんでした

**確認箇所**:
- `lib/core/prefs/forbidden_keys.dart`: token関連のキーは禁止リストに含まれており、保存を防止

---

## 🧪 テスト項目

### 1. DevTools Console に CSP エラーがないこと

**確認方法**:
1. ブラウザの開発者ツール（F12）を開く
2. Console タブで CSP 違反がないことを確認

**期待結果**: CSP 違反エラーなし

---

### 2. Sign-in → API 呼び出し → 画像/フォントの読み込みを手動確認

**確認項目**:
- [ ] サインインが正常に動作する
- [ ] Supabase API 呼び出しが正常に動作する
- [ ] 画像の読み込みが正常に動作する
- [ ] フォントの読み込みが正常に動作する

---

### 3. ブラウザ保存の痕跡確認

**確認コマンド**:
```bash
grep -R --line-number -E "supabase\.auth\.token|jwt|access_token" build/ web/ || true
```

**期待結果**: token関連の保存コードなし

**確認結果**: ✅ 見つかりませんでした

---

### 4. モバイル（該当時）

**確認項目**:
- [ ] ログイン → タスクキル → 再起動でセッション復元（flutter_secure_storage）

---

## 🔄 ロールバック手順

### Vercel の場合

`vercel.json` の `Content-Security-Policy` を `Content-Security-Policy-Report-Only` に変更:

```json
{
  "key": "Content-Security-Policy-Report-Only",
  "value": "..."
}
```

### Cloudflare Pages の場合

`_headers` の `Content-Security-Policy` を `Content-Security-Policy-Report-Only` に変更:

```
Content-Security-Policy-Report-Only: ...
```

### NGINX の場合

`add_header` の `Content-Security-Policy` を `Content-Security-Policy-Report-Only` に変更:

```nginx
add_header Content-Security-Policy-Report-Only "..." always;
```

### 緊急時

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

### 1. CSP ヘッダーの確認

```bash
curl -I https://your-domain.com | grep -i content-security-policy
```

**期待結果**: `Content-Security-Policy` ヘッダーが設定されていること

### 2. Console エラーの確認

- ブラウザの開発者ツールで Console タブを確認
- CSP 違反がないことを確認

### 3. 機能テスト

- [ ] サインイン
- [ ] API 呼び出し
- [ ] 画像/フォントの読み込み

---

---

## 🔒 CSP 強化ディレクティブ追加（追記）

### 追加日時
2025-11-08 (実装完了時点)

### 追加ディレクティブ
- `object-src 'none';` - オブジェクト要素の無効化
- `manifest-src 'self';` - Web App Manifest の読み込み制限
- `worker-src 'self' blob:;` - Service Worker / Web Worker の許可（CanvasKit使用時）
- `media-src 'self' https: blob:;` - メディアリソースの許可（CanvasKit使用時）

### Stripe iframe 用（将来使用時）
```csp
frame-src https://js.stripe.com https://hooks.stripe.com;
```

---

## ✅ 強化後の検証結果

### 1. CSP ヘッダーの確認

```bash
curl -I https://your-domain.com | grep -i content-security-policy
```

**期待結果**: `Content-Security-Policy` ヘッダーが1本のみ出力される

**確認結果**: [デプロイ後に記録]

---

### 2. Console エラー確認結果

**確認方法**: ブラウザの開発者ツール（F12）→ Console タブ

**確認結果**: [デプロイ後に記録]
- CSP 違反エラー: [有/無]
- エラー内容: [記録]

---

### 3. curl 出力（1行）

```bash
curl -I https://your-domain.com | grep -i content-security-policy
```

**出力結果**: [デプロイ後に記録]

---

### 4. 既存通信OK確認

**確認項目**:
- [ ] Sign-in が正常に動作する
- [ ] Supabase API 呼び出しが正常に動作する
- [ ] 画像の読み込みが正常に動作する
- [ ] フォントの読み込みが正常に動作する
- [ ] Service Worker / Web Worker が正常に動作する（CanvasKit使用時）
- [ ] メディアリソースの読み込みが正常に動作する（CanvasKit使用時）

**確認結果**: [デプロイ後に記録]

---

### 5. Local/Session/Cookie に token類保存なし

**確認コマンド**:
```bash
grep -R --line-number -E "supabase\.auth\.token|jwt|access_token" build/ web/ || true
```

**確認結果**: ✅ token関連の保存コードは見つかりませんでした

---

**最終更新**: CSP 強化ディレクティブ追加完了時点

