# PR作成ステップ（コピペ用）

## Phase 1 PR: セキュリティ修正

### 1. GitHubでPRを作成

**URL**: https://github.com/shochaso/starlist-app/pull/new/fix/security-hardening-web-csp-lock

### 2. タイトル

```
🔒 Security Hardening: Block Web Token Persistence, Add CSP, Enable Security CI
```

### 3. 本文

`SECURITY_PR_BODY.md` の内容をそのままコピーして貼り付け

### 4. ラベル（推奨）

- `security`
- `enhancement`
- `ready-for-review`

### 5. レビュアー（推奨）

- セキュリティ担当者
- フロントエンド担当者

---

## Phase 2 PR: CSP Enforce

### 1. GitHubでPRを作成

**URL**: https://github.com/shochaso/starlist-app/pull/new/feat/sec-csp-enforce

### 2. タイトル

```
sec: Enforce CSP (from Report-Only)
```

### 3. 本文（テンプレ）

```markdown
## 概要

CSPをReport-OnlyからEnforceに昇格します。

## 変更点

- `web/index.html`の`Content-Security-Policy-Report-Only`を`Content-Security-Policy`に変更
- CSP違反の最終確認と調整

## 前提条件

- Phase 1 PRがマージ済み
- 1-3日の運用観察でCSP違反が許容範囲内であることを確認

## 検証

- [ ] WebビルドでCSP違反が発生しないこと
- [ ] 外部リソース（CDN等）が正常に読み込まれること
- [ ] CI green
```

---

## Phase 3 PR: Cookie認証

### 1. GitHubでPRを作成

**URL**: https://github.com/shochaso/starlist-app/pull/new/feat/auth-cookie-web-tokenless

### 2. タイトル

```
feat(auth): Web tokenless via HttpOnly cookie
```

### 3. 本文（テンプレ）

```markdown
## 概要

Webでのトークンレス認証（Cookieベース）を実装します。

## 変更点

- Edge Function経由のCookieベースセッション管理
- HttpOnly/SameSite=Lax Cookieの実装
- Silent Refresh機能の実装

## 前提条件

- Phase 1 PRがマージ済み
- Supabase環境変数が設定済み

## 検証

- [ ] WebでCookieベースのセッション管理が機能すること
- [ ] リロード時にセッションが維持されること
- [ ] XSS攻撃でCookieが取得できないこと（HttpOnly）
- [ ] CI green
```

