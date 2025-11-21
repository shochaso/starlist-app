---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



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

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
