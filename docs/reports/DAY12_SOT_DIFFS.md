# Day12 SOT DIFFS

**Generated**: 2025-11-09T01:04:06.849Z

## 項目標準化（差分/根拠/チケット/成果物）

### 差分
[変更内容の要約]

### 根拠
[なぜこの変更が必要だったか]

### チケット
[関連Issue/PR番号: #xxx]

### 成果物
[生成されたファイル・更新されたファイル一覧]

---

## ステージ差分

```diff
diff --git a/.mlc.json b/.mlc.json
index a203066..fd022fd 100644
--- a/.mlc.json
+++ b/.mlc.json
@@ -1,18 +1,19 @@
 {
-  "replacementPatterns": [
-    {
-      "pattern": "^https://zjwvmoxpacbpwawlwbrd.functions.supabase.co",
-      "replacement": ""
-    }
-  ],
   "ignorePatterns": [
+    {
+      "pattern": "^mailto:"
+    },
+    {
+      "pattern": "^#.+$"
+    },
+    {
+      "pattern": "^https://localhost"
+    },
     {
       "pattern": "^https://zjwvmoxpacbpwawlwbrd.functions.supabase.co"
     }
   ],
-  "timeout": "20s",
   "retryOn429": true,
-  "retryCount": 3,
-  "fallbackRetryDelay": "5s",
-  "aliveStatusCodes": [200, 206, 429]
+  "timeout": "15s",
+  "aliveStatusCodes": [200, 206, 301, 302, 308]
 }
diff --git a/docs/COMPANY_SETUP_GUIDE.md b/docs/COMPANY_SETUP_GUIDE.md
index 20852a9..56eb34c 100644
--- a/docs/COMPANY_SETUP_GUIDE.md
+++ b/docs/COMPANY_SETUP_GUIDE.md
@@ -1,12 +1,12 @@
-Status:: 
-Source-of-Truth:: (TBD)
-Spec-State:: 
-Last-Updated:: 
+Status: beta
+Source-of-Truth: docs/COMPANY_SETUP_GUIDE.md
+Spec-State: beta
+Last-Updated: 2025-11-09
 
 
-# Starlist 会社・環境セットアップガイド（雛形）
+# Starlist 会社・環境セットアップガイド（β版）
 
-新規メンバーのオンボーディングで扱う内容を整理するためのテンプレートです。各章の項目を埋め、社内ルールに合わせて更新してください。
+新規メンバーのオンボーディングで扱う内容を整理したガイドです。Day5〜Day11で確立した運用ルール（Secrets方針、必須ツールバージョン、doc-share運用等）を反映しています。
 
 ---
 
@@ -40,10 +40,12 @@ Last-Updated::
 | --- | --- | --- | --- | --- |
 | Google Workspace | メール, Drive, Calendar | 管理部 | https://admin.google.com/ | [x] |
 | GitHub Org | ソースコード管理 | テックリード | https://github.com/orgs/starlist-app | [x] |
-| Supabase | DB / Storage | テックリード | プロジェクト名: `starlist-prod` | [ ] |
-| Stripe Dashboard | 決済設定 | BizOps | https://dashboard.stripe.com/ | [ ] |
+| Supabase | DB / Storage / Edge Functions | テックリード | プロジェクト名: `starlist-prod`<br/>URL: `https://<project-ref>.supabase.co` | [x] |
+| Stripe Dashboard | 決済設定・監査 | BizOps | https://dashboard.stripe.com/<br/>CLI: `stripe --version` で確認 | [x] |
+| Resend | メール送信（週次要約） | Ops Lead | https://resend.com/<br/>API Key: `RESEND_API_KEY` | [x] |
+| Slack | 通知・週次要約 | Ops Lead | Webhook URL: `SLACK_WEBHOOK_URL` | [x] |
 
-> TODO: 実運用で必要なサービスを追加。
+> **注意**: Supabase/Stripe/Resend/Slackの認証情報は`direnv`で管理し、ローカル平文保存は禁止。
 
 ---
 
@@ -64,38 +66,140 @@ cd starlist
 
 ## 開発環境構築手順
 
-1. **必須ツール**
-   - 例: Flutter SDK, Node.js, Supabase CLI, Docker 等
-2. **プラットフォーム別注意点**
-   - iOS/Android ビルドに必要なセットアップ
-   - Web/デスクトップ用の追加設定
-3. **初回セットアップスクリプト**
-   - `scripts/setup.sh` など存在する場合の説明
-4. **IDE 拡張 / 推奨設定**
+### 必須ツール（バージョン固定）
 
-> TODO: バージョンやダウンロード先リンクを追記。
+| ツール | バージョン | インストール方法 | 検証コマンド |
+| --- | --- | --- | --- |
+| Node.js | v20.x（固定） | `nvm install 20 && nvm use 20` | `node -v`（v20.x.x） |
+| pnpm | 最新 | `corepack enable && corepack prepare pnpm@latest --activate` | `pnpm -v` |
+| Flutter | 3.27.0（stable） | [公式サイト](https://flutter.dev/docs/get-started/install) | `flutter --version` |
+| Supabase CLI | 最新 | `npm install -g supabase` | `supabase --version` |
+| Stripe CLI | 最新 | [公式サイト](https://stripe.com/docs/stripe-cli) | `stripe --version` |
+| direnv | 最新 | `brew install direnv`（macOS） | `direnv --version` |
+
+### プラットフォーム別注意点
+
+- **iOS/Android**: Xcode/Android Studioのセットアップが必要
+- **Web**: Chrome開発用に`scripts/c.sh`を使用（キャッシュクリア＋incognito起動）
+- **デスクトップ**: 各OS用のビルドツールが必要
+
+### 初回セットアップスクリプト
+
+```bash
+# リポジトリクローン
+git clone git@github.com:starlist-app/starlist.git
+cd starlist
+
+# Node.js環境確認（preinstallで自動検証）
+npm ci
+
+# Flutter依存取得
+flutter pub get
+
+# direnv設定（.envrcがあれば）
+direnv allow
+```
+
+### IDE 拡張 / 推奨設定
+
+- **VS Code**: Flutter/Dart拡張、Markdown拡張
+- **Cursor**: 推奨設定は`docs/development/DEVELOPMENT_GUIDE.md`を参照
 
 ---
 
 ## 環境変数・機密情報の取り扱い
 
-- `.env.example` 等のコピー手順
-- 共有 Vault（例: 1Password, Google Drive Secure Folder）の所在
-- 秘密鍵の保管方針（例: ローカル保存禁止、`direnv` 利用推奨 など）
-- 参考ドキュメント: `docs/environment_config.md`
+### Secrets 3行SOP
+
+1) **すべて小文字キーで統一**（例: `resend_api_key`, `supabase_anon_key`）。  
+2) **共有はVault経由、ローカル平文禁止**（`direnv`登録必須）。  
+3) **受領→即`direnv allow`→実行ログに値を残さない**。
+
+### 詳細手順
+
+#### 1. `.env.example`のコピー
+
+```bash
+cp .env.example .env.local
+# .env.localは.gitignoreに含まれているため、コミットされない
+```
+
+#### 2. Secretsの受け取り
+
+- **共有Vault**: 1Password / Google Drive Secure Folder（担当者経由で個別発行）
+- **受け取り後**: 即座に`.envrc`に追加し、`direnv allow`を実行
+- **ローカル保存**: `.env.local`への平文保存は禁止（`direnv`のみ使用）
+
+#### 3. 命名規則
+
+- すべて小文字、アンダースコア区切り
+- 例: `resend_api_key`, `supabase_anon_key`, `stripe_secret_key`
+- GitHub Secretsも同様の命名規則を適用
+
+#### 4. 監査ログ
 
-> TODO: チーム標準に合わせた説明を記入。
+- Secrets受け渡しは`docs/reports/DAY12_SOT_DIFFS.md`に記録
+- 再発行時は旧キーを無効化し、ログに残す
+
+### 参考ドキュメント
+
+- `docs/environment_config.md` - 環境変数の詳細設定
+- `docs/ops/LAUNCH_CHECKLIST.md` - Secrets指紋・ローテーション手順
 
 ---
 
 ## Supabase Storage `doc-share` 運用
 
-1. 目的（例: ChatGPT 共有用の大容量ファイル保管）。
-2. バケット作成・権限付与の手順（Supabase CLI / Dashboard）。
-3. アップロード・署名付き URL 発行・削除の流れ。
-4. 参考: `docs/ops/supabase_byo_auth.md` の詳細手順。
+### doc-share 3行SOP
+
+1) **Supabase Storage `doc-share` に格納し、期限付き署名URLを発行**。  
+2) **共有
... (truncated)
```

## 変更ファイル一覧

- .mlc.json
- docs/COMPANY_SETUP_GUIDE.md
- docs/Mermaid.md
- docs/ops/SSOT_RULES.md
- docs/overview/COMMON_DOCS_INDEX.md
- docs/overview/STARLIST_OVERVIEW.md
- guides/CHATGPT_SHARE_GUIDE.md
- package.json
- scripts/docs/generate-diff-log.mjs
- scripts/docs/link-check.mjs
- scripts/docs/update-last-updated.mjs

---

**Note**: This file is auto-generated. Manual edits may be overwritten.

- .mlc.json
- docs/COMPANY_SETUP_GUIDE.md
- docs/Mermaid.md
- docs/ops/SSOT_RULES.md
- docs/overview/COMMON_DOCS_INDEX.md
- docs/overview/STARLIST_OVERVIEW.md
- guides/CHATGPT_SHARE_GUIDE.md
- package.json
- scripts/docs/generate-diff-log.mjs
- scripts/docs/link-check.mjs
- scripts/docs/update-last-updated.mjs

---

**Note**: This file is auto-generated. Manual edits may be overwritten.
* rebase-merge: 2025-11-09 12:57:23 JST branch=feature/day12-security-ci-hardening
* merge-conflict-resolved: 2025-11-09 13:21:55 JST branch=feature/day12-security-ci-hardening
* merged: https://github.com/shochaso/starlist-app/pull/32  (2025-11-09 13:55:07 JST)
* merged: https://github.com/shochaso/starlist-app/pull/32  (2025-11-09 13:56:14 JST)
* merged: https://github.com/shochaso/starlist-app/pull/32  (2025-11-09 13:57:13 JST)
* merged: https://github.com/shochaso/starlist-app/pull/30  (2025-11-09 14:14:18 JST)
* merged: https://github.com/shochaso/starlist-app/pull/31  (2025-11-09 14:14:19 JST)
* merged: https://github.com/shochaso/starlist-app/pull/32  (2025-11-09 14:14:20 JST)
* merged: https://github.com/shochaso/starlist-app/pull/33  (2025-11-09 14:14:20 JST)
* merged: https://github.com/shochaso/starlist-app/pull/30  (2025-11-09 14:14:52 JST)
* merged: https://github.com/shochaso/starlist-app/pull/31  (2025-11-09 14:14:52 JST)
* merged: https://github.com/shochaso/starlist-app/pull/32  (2025-11-09 14:14:53 JST)
