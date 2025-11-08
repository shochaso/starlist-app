# 追加ブランチ作成コマンド

以下のブランチを作成してプッシュしてください。

## 1. chore/security-gap-closure

セキュリティギャップの追加修正用ブランチ。

```bash
git checkout -b chore/security-gap-closure
git push -u origin chore/security-gap-closure
```

**用途**: 
- Android minSdkVersion確認・更新
- iOS CocoaPods同期
- その他のセキュリティ関連の細かい修正

## 2. feat/sec-csp-enforce

CSPをReport-OnlyからEnforceに昇格するためのブランチ。

```bash
git checkout -b feat/sec-csp-enforce
git push -u origin feat/sec-csp-enforce
```

**用途**:
- `web/index.html`の`Content-Security-Policy-Report-Only`を`Content-Security-Policy`に変更
- CSP違反の最終確認と調整
- 1-3日の運用観察後の本番適用

## 3. feat/auth-cookie-web-tokenless

Webでのトークンレス認証（Cookieベース）実装用ブランチ。

```bash
git checkout -b feat/auth-cookie-web-tokenless
git push -u origin feat/auth-cookie-web-tokenless
```

**用途**:
- Edge Function経由のCookieベースセッション管理
- HttpOnly/SameSite=Lax Cookieの実装
- Silent Refresh機能の実装

## 実行手順

現在のブランチから実行:

```bash
# 現在のブランチを確認
git branch --show-current

# 各ブランチを作成・プッシュ
git checkout -b chore/security-gap-closure
git push -u origin chore/security-gap-closure

git checkout -b feat/sec-csp-enforce
git push -u origin feat/sec-csp-enforce

git checkout -b feat/auth-cookie-web-tokenless
git push -u origin feat/auth-cookie-web-tokenless

# 元のブランチに戻る（必要に応じて）
git checkout fix/security-hardening-web-csp-lock
```

## 注意事項

- 各ブランチは独立して作業可能です
- PRは順次作成してください（先にsecurity-gap-closureから）
- CSP Enforceは運用観察後に実施してください

