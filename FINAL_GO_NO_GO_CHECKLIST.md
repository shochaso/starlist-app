---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# 最終Go/No-Goチェックリスト（短縮版）

## Phase 1: セキュリティ修正PR

- [ ] `fix/security-hardening-web-csp-lock`：PR作成 → CI green
- [ ] Supabase 環境変数の適用：`OPS_ALLOWED_ORIGINS` / `OPS_SERVICE_SECRET`
- [ ] Web/モバイル/CI 検証（チェックリストどおり）

## Phase 2: CSP Enforce & Cookie認証

- [ ] `feat/sec-csp-enforce`：PR作成 → CI green → マージ
- [ ] `feat/auth-cookie-web-tokenless`：PR作成 → CI green → マージ

## マージ順（推奨）

1. `fix/security-hardening-web-csp-lock`（Phase 1）
2. `feat/sec-csp-enforce`（CSP Enforce）
3. `feat/auth-cookie-web-tokenless`（Cookie 認証）

---

## PR起票メモ

### Phase 1 PR（既存ブランチ）

**タイトル**: `🔒 Security Hardening: Block Web Token Persistence, Add CSP, Enable Security CI`

**本文**: `SECURITY_PR_BODY.md` を貼付

**URL**: https://github.com/shochaso/starlist-app/pull/new/fix/security-hardening-web-csp-lock

### Phase 2 PR（2本とも）

#### 1. CSP Enforce

**タイトル**: `sec: Enforce CSP (from Report-Only)`

**ブランチ**: `feat/sec-csp-enforce`

**URL**: https://github.com/shochaso/starlist-app/pull/new/feat/sec-csp-enforce

#### 2. Cookie認証

**タイトル**: `feat(auth): Web tokenless via HttpOnly cookie`

**ブランチ**: `feat/auth-cookie-web-tokenless`

**URL**: https://github.com/shochaso/starlist-app/pull/new/feat/auth-cookie-web-tokenless

---

## Supabase環境適用チェック（即時動作確認）

### 正常ケース（許可オリジン・正しいシークレット）

```bash
curl -i -X POST \
  -H "origin: https://app.starlist.jp" \
  -H "x-ops-secret: $OPS_SERVICE_SECRET" \
  -H "content-type: application/json" \
  -d '{"dryRun":true}' \
  "https://<project-ref>.functions.supabase.co/ops-alert"
```

**期待**: 200/204

### 拒否ケース（非許可オリジン or シークレット欠落/不一致）

```bash
curl -i -X POST \
  -H "origin: https://evil.example.com" \
  -H "x-ops-secret: BAD" \
  -H "content-type: application/json" \
  -d '{"dryRun":true}' \
  "https://<project-ref>.functions.supabase.co/ops-alert"
```

**期待**: 403

---

## Web/モバイル簡易確認

### Web（Chrome）

1. `flutter run -d chrome` で起動
2. DevTools → Application → Storage を確認
   - `localStorage/sessionStorage` にトークン無し ✅
   - Cookies に HttpOnly セッションあり ✅
3. Console に CSP違反 0 ✅

### モバイル

1. ログイン
2. アプリを完全終了
3. アプリを再起動
4. セッション維持（SecureStorage経由）✅

---

## CI起動（Security Audit）

1. GitHub Actions → Workflows → `security-audit`
2. Run workflow をクリック
3. ブランチを選択（`fix/security-hardening-web-csp-lock`）
4. 実行を確認
5. 以下が **green** であることを確認:
   - `semgrep`
   - `npm(or pnpm) audit`
   - `dart pub outdated`
   - `deno test`（該当時）

---

## 追加リソース

- `SECURITY_PR_BODY.md` - PR本文テンプレ
- `SECURITY_VERIFICATION_CHECKLIST.md` - 詳細検証チェックリスト
- `SUPABASE_ENV_SETUP.md` - Supabase環境変数設定ガイド
- `ADDITIONAL_BRANCHES.md` - 追加ブランチの説明

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
