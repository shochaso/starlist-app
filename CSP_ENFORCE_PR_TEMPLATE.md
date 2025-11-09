# CSP Enforce 化 PR 雛形

## 📋 PR タイトル

```
🔐 CSP Enforce: tighten connect/img/font-src based on 72h RO logs
```

## 📝 PR 説明テンプレート

```markdown
## 概要

CSP Report-Only の 48-72時間観測結果に基づき、最小限の許可セットで CSP を Enforce 化します。

## 観測結果サマリ

### Console 違反
- [ ] 重大な違反なし
- [ ] 軽微な違反のみ（対応済み）

### CSP Report エンドポイント
- [ ] `/_/csp-report` に 204 で到達確認
- [ ] ログ確認済み

### 許可が必要なリソース（最小限）
- `connect-src`: [観測結果に基づく最小セット]
- `img-src`: [観測結果に基づく最小セット]
- `font-src`: [観測結果に基づく最小セット]

## 変更内容

### 1. CSP を Report-Only から Enforce に変更

**変更前** (`web/index.html`):
```html
<meta http-equiv="Content-Security-Policy-Report-Only" ...>
```

**変更後** (`web/index.html`):
```html
<meta http-equiv="Content-Security-Policy" ...>
```

### 2. 配信ヘッダでの CSP 適用（推奨）

Supabase Edge Function または CDN で CSP ヘッダーを設定する場合の例:

```typescript
// supabase/functions/_headers.ts または CDN設定
{
  "/*": {
    "Content-Security-Policy": "default-src 'self'; script-src 'self'; connect-src 'self' https://*.supabase.co https://api.segment.io https://sentry.io https://*.sentry.io; img-src 'self' data: blob: https:; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com data:; frame-ancestors 'none'; object-src 'none'; base-uri 'self';"
  }
}
```

### 3. 許可先の最小追加

観測ログに基づき、以下の最小セットを許可:

```html
<!-- 例: 観測結果に基づく最小許可セット -->
<meta http-equiv="Content-Security-Policy"
      content="
        default-src 'self';
        script-src 'self';
        connect-src 'self' https://*.supabase.co https://api.segment.io https://sentry.io https://*.sentry.io;
        img-src 'self' data: blob: https:;
        style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
        font-src 'self' https://fonts.gstatic.com data:;
        frame-ancestors 'none';
        object-src 'none';
        base-uri 'self';
      ">
```

## 検証項目

- [ ] CSP が Enforce モードで動作していること
- [ ] 既存機能が正常に動作すること
- [ ] Console に重大な違反がないこと
- [ ] CSP Report エンドポイントが正常に動作していること

## 関連Issue/PR

- 関連: #20 (CSP Report-Only 実装)
```

---

## 🔧 実装パッチ例

### web/index.html の変更

```diff
-     <!-- Report-Only CSP: まずは運用観察フェーズ -->
-     <meta http-equiv="Content-Security-Policy-Report-Only"
+     <!-- Enforce CSP: 観測結果に基づく最小許可セット -->
+     <meta http-equiv="Content-Security-Policy"
            content="
              default-src 'self';
              script-src 'self';
-             connect-src 'self' https://*.supabase.co https://api.segment.io https://sentry.io https://*.sentry.io;
+             connect-src 'self' https://*.supabase.co https://api.segment.io https://sentry.io https://*.sentry.io;  <!-- 観測結果に基づく最小セット -->
              img-src 'self' data: blob: https:;
              style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
              font-src 'self' https://fonts.gstatic.com data:;
              frame-ancestors 'none';
              object-src 'none';
              base-uri 'self';
-             report-uri /_/csp-report;
+             report-uri /_/csp-report;  <!-- 継続監視のため維持 -->
            ">
```

---

## 📋 CSP 観測チェックリスト（48-72時間）

### 1. Console 違反の確認

```bash
# ブラウザの開発者ツールで確認
# Console タブで CSP 違反がないことを確認
```

### 2. CSP Report エンドポイントの疎通確認

```bash
curl -i -X POST \
  -H "Content-Type: application/csp-report" \
  --data '{"csp-report":{"effective-directive":"connect-src","blocked-uri":"https://example.com","document-uri":"https://starlist.app"}}' \
  "https://zjwvmoxpacbpwawlwbrd.functions.supabase.co/csp-report"

# 期待: HTTP/1.1 204 No Content
```

### 3. CSP Report ログの確認

```bash
# Supabase Dashboard で Edge Function のログを確認
# または、Edge Function のログを取得
```

### 4. 許可が必要なリソースの特定

CSP Report ログから以下を抽出:
- `blocked-uri`: ブロックされたリソースのURL
- `effective-directive`: ブロックされたディレクティブ（connect-src, img-src, font-src など）

---

## 🚀 次のアクション

1. **CSP Report-Only の観測（48-72時間）**
   - Console で重大な違反がないことを確認
   - CSP Report エンドポイントの疎通確認
   - ログから許可が必要なリソースを特定

2. **CSP Enforce 化 PR の作成**
   - 観測結果に基づく最小許可セットを決定
   - 上記テンプレートを使用してPRを作成

3. **検証**
   - CSP が Enforce モードで動作していることを確認
   - 既存機能が正常に動作することを確認

---

**最終更新**: CSP Enforce 化 PR 雛形作成時点


## 📋 PR タイトル

```
🔐 CSP Enforce: tighten connect/img/font-src based on 72h RO logs
```

## 📝 PR 説明テンプレート

```markdown
## 概要

CSP Report-Only の 48-72時間観測結果に基づき、最小限の許可セットで CSP を Enforce 化します。

## 観測結果サマリ

### Console 違反
- [ ] 重大な違反なし
- [ ] 軽微な違反のみ（対応済み）

### CSP Report エンドポイント
- [ ] `/_/csp-report` に 204 で到達確認
- [ ] ログ確認済み

### 許可が必要なリソース（最小限）
- `connect-src`: [観測結果に基づく最小セット]
- `img-src`: [観測結果に基づく最小セット]
- `font-src`: [観測結果に基づく最小セット]

## 変更内容

### 1. CSP を Report-Only から Enforce に変更

**変更前** (`web/index.html`):
```html
<meta http-equiv="Content-Security-Policy-Report-Only" ...>
```

**変更後** (`web/index.html`):
```html
<meta http-equiv="Content-Security-Policy" ...>
```

### 2. 配信ヘッダでの CSP 適用（推奨）

Supabase Edge Function または CDN で CSP ヘッダーを設定する場合の例:

```typescript
// supabase/functions/_headers.ts または CDN設定
{
  "/*": {
    "Content-Security-Policy": "default-src 'self'; script-src 'self'; connect-src 'self' https://*.supabase.co https://api.segment.io https://sentry.io https://*.sentry.io; img-src 'self' data: blob: https:; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com data:; frame-ancestors 'none'; object-src 'none'; base-uri 'self';"
  }
}
```

### 3. 許可先の最小追加

観測ログに基づき、以下の最小セットを許可:

```html
<!-- 例: 観測結果に基づく最小許可セット -->
<meta http-equiv="Content-Security-Policy"
      content="
        default-src 'self';
        script-src 'self';
        connect-src 'self' https://*.supabase.co https://api.segment.io https://sentry.io https://*.sentry.io;
        img-src 'self' data: blob: https:;
        style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
        font-src 'self' https://fonts.gstatic.com data:;
        frame-ancestors 'none';
        object-src 'none';
        base-uri 'self';
      ">
```

## 検証項目

- [ ] CSP が Enforce モードで動作していること
- [ ] 既存機能が正常に動作すること
- [ ] Console に重大な違反がないこと
- [ ] CSP Report エンドポイントが正常に動作していること

## 関連Issue/PR

- 関連: #20 (CSP Report-Only 実装)
```

---

## 🔧 実装パッチ例

### web/index.html の変更

```diff
-     <!-- Report-Only CSP: まずは運用観察フェーズ -->
-     <meta http-equiv="Content-Security-Policy-Report-Only"
+     <!-- Enforce CSP: 観測結果に基づく最小許可セット -->
+     <meta http-equiv="Content-Security-Policy"
            content="
              default-src 'self';
              script-src 'self';
-             connect-src 'self' https://*.supabase.co https://api.segment.io https://sentry.io https://*.sentry.io;
+             connect-src 'self' https://*.supabase.co https://api.segment.io https://sentry.io https://*.sentry.io;  <!-- 観測結果に基づく最小セット -->
              img-src 'self' data: blob: https:;
              style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
              font-src 'self' https://fonts.gstatic.com data:;
              frame-ancestors 'none';
              object-src 'none';
              base-uri 'self';
-             report-uri /_/csp-report;
+             report-uri /_/csp-report;  <!-- 継続監視のため維持 -->
            ">
```

---

## 📋 CSP 観測チェックリスト（48-72時間）

### 1. Console 違反の確認

```bash
# ブラウザの開発者ツールで確認
# Console タブで CSP 違反がないことを確認
```

### 2. CSP Report エンドポイントの疎通確認

```bash
curl -i -X POST \
  -H "Content-Type: application/csp-report" \
  --data '{"csp-report":{"effective-directive":"connect-src","blocked-uri":"https://example.com","document-uri":"https://starlist.app"}}' \
  "https://zjwvmoxpacbpwawlwbrd.functions.supabase.co/csp-report"

# 期待: HTTP/1.1 204 No Content
```

### 3. CSP Report ログの確認

```bash
# Supabase Dashboard で Edge Function のログを確認
# または、Edge Function のログを取得
```

### 4. 許可が必要なリソースの特定

CSP Report ログから以下を抽出:
- `blocked-uri`: ブロックされたリソースのURL
- `effective-directive`: ブロックされたディレクティブ（connect-src, img-src, font-src など）

---

## 🚀 次のアクション

1. **CSP Report-Only の観測（48-72時間）**
   - Console で重大な違反がないことを確認
   - CSP Report エンドポイントの疎通確認
   - ログから許可が必要なリソースを特定

2. **CSP Enforce 化 PR の作成**
   - 観測結果に基づく最小許可セットを決定
   - 上記テンプレートを使用してPRを作成

3. **検証**
   - CSP が Enforce モードで動作していることを確認
   - 既存機能が正常に動作することを確認

---

**最終更新**: CSP Enforce 化 PR 雛形作成時点

