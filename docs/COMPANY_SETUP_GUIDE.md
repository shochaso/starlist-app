Status: beta
Source-of-Truth: docs/COMPANY_SETUP_GUIDE.md
Spec-State: beta
Last-Updated: 2025-11-09


# Starlist 会社・環境セットアップガイド（β版）

新規メンバーのオンボーディングで扱う内容を整理したガイドです。Day5〜Day11で確立した運用ルール（Secrets方針、必須ツールバージョン、doc-share運用等）を反映しています。

---

## 目次

1. [概要と対象範囲](#概要と対象範囲)
2. [アカウント・権限一覧](#アカウント・権限一覧)
3. [リポジトリとバージョン管理](#リポジトリとバージョン管理)
4. [開発環境構築手順](#開発環境構築手順)
5. [環境変数・機密情報の取り扱い](#環境変数機密情報の取り扱い)
6. [Supabase Storage `doc-share` 運用](#supabase-storage-doc-share-運用)
7. [開発フローと QA](#開発フローと-qa)
8. [サポート連絡先](#サポート連絡先)
9. [更新履歴](#更新履歴)

---

## 概要と対象範囲

- このガイドの目的（例: 「Starlist チームメンバーが初日に準備すべき事項を網羅」）。
- 想定読者（例: 正社員・業務委託エンジニア・BizOps）。
- 運用責任者（役職または部署名）。

> TODO: チームの運用ルールに合わせて文章を追記。

---

## アカウント・権限一覧

| サービス | 利用目的 | 申請先/担当者 | 備考・URL | チェック |
| --- | --- | --- | --- | --- |
| Google Workspace | メール, Drive, Calendar | 管理部 | https://admin.google.com/ | [x] |
| GitHub Org | ソースコード管理 | テックリード | https://github.com/orgs/starlist-app | [x] |
| Supabase | DB / Storage / Edge Functions | テックリード | プロジェクト名: `starlist-prod`<br/>URL: `https://<project-ref>.supabase.co` | [x] |
| Stripe Dashboard | 決済設定・監査 | BizOps | https://dashboard.stripe.com/<br/>CLI: `stripe --version` で確認 | [x] |
| Resend | メール送信（週次要約） | Ops Lead | https://resend.com/<br/>API Key: `RESEND_API_KEY` | [x] |
| Slack | 通知・週次要約 | Ops Lead | Webhook URL: `SLACK_WEBHOOK_URL` | [x] |

> **注意**: Supabase/Stripe/Resend/Slackの認証情報は`direnv`で管理し、ローカル平文保存は禁止。

---

## リポジトリとバージョン管理

- メインリポジトリのクローン方法、必須ブランチルール。
- 他に参照すべきリポジトリやテンプレートがある場合は一覧化。
- リポジトリへのアクセス権限の申請手順。

```
git clone git@github.com:starlist-app/starlist.git
cd starlist
```

> TODO: 実際の運用に合わせて記述を補完。

---

## 開発環境構築手順

### 必須ツール（バージョン固定）

| ツール | バージョン | インストール方法 | 検証コマンド |
| --- | --- | --- | --- |
| Node.js | v20.x（固定） | `nvm install 20 && nvm use 20` | `node -v`（v20.x.x） |
| pnpm | 最新 | `corepack enable && corepack prepare pnpm@latest --activate` | `pnpm -v` |
| Flutter | 3.27.0（stable） | [公式サイト](https://flutter.dev/docs/get-started/install) | `flutter --version` |
| Supabase CLI | 最新 | `npm install -g supabase` | `supabase --version` |
| Stripe CLI | 最新 | [公式サイト](https://stripe.com/docs/stripe-cli) | `stripe --version` |
| direnv | 最新 | `brew install direnv`（macOS） | `direnv --version` |

### プラットフォーム別注意点

- **iOS/Android**: Xcode/Android Studioのセットアップが必要
- **Web**: Chrome開発用に`scripts/c.sh`を使用（キャッシュクリア＋incognito起動）
- **デスクトップ**: 各OS用のビルドツールが必要

### 初回セットアップスクリプト

```bash
# リポジトリクローン
git clone git@github.com:starlist-app/starlist.git
cd starlist

# Node.js環境確認（preinstallで自動検証）
npm ci

# Flutter依存取得
flutter pub get

# direnv設定（.envrcがあれば）
direnv allow
```

### IDE 拡張 / 推奨設定

- **VS Code**: Flutter/Dart拡張、Markdown拡張
- **Cursor**: 推奨設定は`docs/development/DEVELOPMENT_GUIDE.md`を参照

---

## 環境変数・機密情報の取り扱い

### Secrets 3行SOP

1) **すべて小文字キーで統一**（例: `resend_api_key`, `supabase_anon_key`）。  
2) **共有はVault経由、ローカル平文禁止**（`direnv`登録必須）。  
3) **受領→即`direnv allow`→実行ログに値を残さない**。

### 詳細手順

#### 1. `.env.example`のコピー

```bash
cp .env.example .env.local
# .env.localは.gitignoreに含まれているため、コミットされない
```

#### 2. Secretsの受け取り

- **共有Vault**: 1Password / Google Drive Secure Folder（担当者経由で個別発行）
- **受け取り後**: 即座に`.envrc`に追加し、`direnv allow`を実行
- **ローカル保存**: `.env.local`への平文保存は禁止（`direnv`のみ使用）

#### 3. 命名規則

- すべて小文字、アンダースコア区切り
- 例: `resend_api_key`, `supabase_anon_key`, `stripe_secret_key`
- GitHub Secretsも同様の命名規則を適用

#### 4. 監査ログ

- Secrets受け渡しは`docs/reports/DAY12_SOT_DIFFS.md`に記録
- 再発行時は旧キーを無効化し、ログに残す

### 参考ドキュメント

- `docs/environment_config.md` - 環境変数の詳細設定
- `docs/ops/LAUNCH_CHECKLIST.md` - Secrets指紋・ローテーション手順

---

## Supabase Storage `doc-share` 運用

### doc-share 3行SOP

1) **Supabase Storage `doc-share` に格納し、期限付き署名URLを発行**。  
2) **共有は最少権限（期限/閲覧のみ）、再配布は禁止**。  
3) **失効期限前に必要分のみ再発行（旧URLは無効化ログを残す）**。

### 詳細手順

#### 1. バケット作成（初回のみ）

```bash
# Supabase CLIでログイン
supabase login

# doc-shareバケット作成（既存の場合はスキップ）
supabase storage create doc-share --public false
```

#### 2. ファイルアップロード

```bash
# ファイルをアップロード
supabase storage upload doc-share path/to/file.pdf

# または、Supabase Dashboardから手動アップロード
```

#### 3. 署名付きURL発行

```bash
# 期限付きURL発行（例: 7日間有効）
supabase storage create-signed-url doc-share file.pdf --expires-in 604800
```

#### 4. 共有・配布

- **共有先**: ChatGPT / 外部パートナー / チーム内
- **期限**: 必要最小限（通常7日、最大30日）
- **再配布**: 禁止（必要に応じて再発行）
- **失効**: 期限切れ後は自動無効化

#### 5. ログ・監査

- URL発行ログは`docs/reports/DAY12_SOT_DIFFS.md`に記録
- 再発行時は旧URLを無効化し、ログに残す

### 参考ドキュメント

- `docs/ops/supabase_byo_auth.md` - Supabase BYO Auth / doc-share 詳細手順
- `guides/CHATGPT_SHARE_GUIDE.md` - ChatGPT共有時のdoc-share活用方法

---

## 開発フローと QA

- **Node.js**: v20 固定。`nvm use 20 && npm ci` が必須。`scripts/ensure-node20.js` が preinstall で検証します。  
- **Lint / LinkCheck**: `npm run lint:md:local`（内部で Node20 を確認 → `markdown-link-check` 実行）。  
- **CI**: `.github/workflows/docs-link-check.yml` が PR ごとに自動実行し、README のバッジに反映。  
- **ブランチ戦略**: `feature/<topic>` → `PR` → `Node20 CI` → `main`。  
- **QA**: `QA-E2E-001` で Telemetry/OPS の疎通 2 ケースを自動実行予定。

> 具体的な作業フローやチェックリストは `docs/reports/STARLIST_DAY5_SUMMARY.md` と `docs/features/day4/AUTH-OAUTH-001_impl_and_review.md` を参照。

---

## サポート連絡先

- 管理部（アカウント作成など）
- テックリード/DevOps（技術的な質問）
- BizOps（決済・事業連携）
- セキュリティ incident 連絡窓口

| 区分 | 連絡先 | 備考 |
| --- | --- | --- |
| 管理部 | `admin@starlist.app` | 例 |
| テックサポート | `dev-lead@starlist.app` | 例 |

> TODO: 実際の連絡体制に合わせて更新。

---

## テスト運用ログ（2025-11-08）

- [x] チェックボックスの状態変更がローカルで保存されることを確認。
- [x] Google Workspace / GitHub Org 項目の記述を実データに差し替え。
- [x] Supabase / Stripe / Resend / Slack 項目を実運用値で更新。
- [x] Secrets運用SOP（3行版＋詳細版）を追加。
- [x] doc-share運用SOP（3行版＋詳細版）を追加。
- [x] 必須ツールバージョンを固定（Node 20 / Flutter 3.27.0等）。

---

## 更新履歴

| 日付 | 更新者 | 変更概要 |
| --- | --- | --- |
| 2025-10-?? | 作成者名 | 初版雛形 |
| 2025-11-08 | Tim | Day12 β統合：Secrets運用SOP、doc-share運用SOP、必須ツールバージョン固定を追加。 |
