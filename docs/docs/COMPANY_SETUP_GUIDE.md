Status:: 
Source-of-Truth:: (TBD)
Spec-State:: 
Last-Updated:: 


# Starlist 会社・環境セットアップガイド（雛形）

新規メンバーのオンボーディングで扱う内容を整理するためのテンプレートです。各章の項目を埋め、社内ルールに合わせて更新してください。

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
| Supabase | DB / Storage | テックリード | プロジェクト名: `starlist-prod` | [ ] |
| Stripe Dashboard | 決済設定 | BizOps | https://dashboard.stripe.com/ | [ ] |

> TODO: 実運用で必要なサービスを追加。

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

1. **必須ツール**
   - 例: Flutter SDK, Node.js, Supabase CLI, Docker 等
2. **プラットフォーム別注意点**
   - iOS/Android ビルドに必要なセットアップ
   - Web/デスクトップ用の追加設定
3. **初回セットアップスクリプト**
   - `scripts/setup.sh` など存在する場合の説明
4. **IDE 拡張 / 推奨設定**

> TODO: バージョンやダウンロード先リンクを追記。

---

## 環境変数・機密情報の取り扱い

- `.env.example` 等のコピー手順
- 共有 Vault（例: 1Password, Google Drive Secure Folder）の所在
- 秘密鍵の保管方針（例: ローカル保存禁止、`direnv` 利用推奨 など）
- 参考ドキュメント: `docs/environment_config.md`

> TODO: チーム標準に合わせた説明を記入。

---

## Supabase Storage `doc-share` 運用

1. 目的（例: ChatGPT 共有用の大容量ファイル保管）。
2. バケット作成・権限付与の手順（Supabase CLI / Dashboard）。
3. アップロード・署名付き URL 発行・削除の流れ。
4. 参考: `docs/ops/supabase_byo_auth.md` の詳細手順。

> TODO: 実運用での運用ルールや命名規則を追記。

---

## 開発フローと QA

- 日常の開発サイクル（ブランチ戦略、PR レビュー、CI/CD）。
- テスト実行方法（ユニット, E2E, Lint）。
- リリース手順またはデプロイ窓口。
- QA チェックリストがあればリンク。

### OPS監視・通知運用（Day10）

- **Slack通知**: `#ops-monitor` チャンネルに日次通知（毎日09:00 JST自動実行）
- **Edge Function**: `ops-slack-notify`（しきい値判定、Slack送信、監査ログ保存）
- **GitHub Actions**: `.github/workflows/ops-slack-notify.yml`（スケジュール実行 + 手動実行）
- **監査ログ**: `ops_slack_notify_logs` テーブルに送信結果を記録
- **運用ルール**: 初見者 `👀`、担当 `🛠`、解消 `✅`。スレッドに原因/対処/再発防止を記録
- **参考ドキュメント**: `DAY10_DEPLOYMENT_RUNBOOK.md`, `docs/reports/DAY10_SOT_DIFFS.md`

> TODO: 実際のフロー、関連ドキュメントへのリンクを補足。

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

## テスト運用ログ（2025-10-??）

- [x] チェックボックスの状態変更がローカルで保存されることを確認。
- [x] Google Workspace / GitHub Org 項目の記述を実データに差し替え。
- [ ] Supabase / Stripe 項目は担当者確認待ち。

---

## 更新履歴

| 日付 | 更新者 | 変更概要 |
| --- | --- | --- |
| 2025-10-?? | 作成者名 | 初版雛形 |
| 2025-11-08 | Tim | Day10 OPS Slack Notify 運用を追加。 |

> TODO: 変更時はここに追記。


## 更新履歴

| 日付 | 更新者 | 変更概要 |
| --- | --- | --- |
| 2025-10-?? | 作成者名 | 初版雛形 |
| 2025-11-08 | Tim | Day10 OPS Slack Notify 運用を追加。 |

> TODO: 変更時はここに追記。
