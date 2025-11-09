# Web Cookie-based Auth (Tokenless)

## Goals
- Flutter Web でトークン非保持（XSS耐性強化）
- サーバ側で HttpOnly / SameSite=Lax Cookie によりセッション管理

## Client
- `BrowserClient()..withCredentials = true` を利用（`lib/core/network/http_client.dart`）
- `localStorage/sessionStorage/cookie` にトークンは保存しない

## Server
- 同一オリジン配下に API を用意（Next.js or Edge）
- Cookie 属性: `HttpOnly; Secure; SameSite=Lax; Path=/`
- CORS/Allowed Origins は `https://starlist.jp, https://app.starlist.jp` のみ

## Verification
- ページ再読込でセッション維持
- Application/Storage で機密未保存を確認
