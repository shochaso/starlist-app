---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



Status:: 
Source-of-Truth:: (TBD)
Spec-State:: 
Last-Updated:: 


# STARLIST ドキュメント

このフォルダには、STARLIST プロジェクトに関するすべてのドキュメントが含まれています。  
入口は `docs/overview/`、仕様は `docs/features/`、運用は `docs/ops/`、図は `docs/architecture/`、読み物は `guides/` が正準です。

---

## 📁 ディレクトリ構成

| ディレクトリ | 用途 |
| --- | --- |
| `docs/overview/` | 共通索引 (`COMMON_DOCS_INDEX.md`)、全体概要 (`STARLIST_OVERVIEW.md`) |
| `docs/features/` | 機能仕様（Day1〜DayX、design, payment, auth など） |
| `docs/architecture/` | システム構成図・ER 図・シーケンス図 |
| `docs/development/` | 開発環境・CI/CD・AI支援設定 |
| `docs/ops/` | 監視・運用・インシデント手順 |
| `docs/planning/` | PM 向けの計画・ロードマップ |
| `docs/reports/` | 進捗レポート・移行ログ |
| `docs/api/` | API 設計資料（仕様系は features へ移行中） |
| `docs/journal/` | 雑多ログ（bugs / ideas / daily_log / tasks） |
| `guides/` | ビジネス、AI、ユーザージャーニーなど読み物系 |

---

## 🔍 主要ドキュメント

- `docs/overview/STARLIST_OVERVIEW.md` … プロジェクト全体像
- `docs/overview/COMMON_DOCS_INDEX.md` … 索引とドキュメント運用ルール
- `docs/development/DEVELOPMENT_GUIDE.md` … 開発環境セットアップ
- `docs/planning/Task.md` … 進行中タスク一覧
- `docs/features/day4/` … Day4 仕様パッケージ（AUTH, SEC-RLS, UI-HOME, QA 等）
- `docs/features/payment/PAY-STAR-SUBS-PER-STAR-PRICING.md` … スター単位/可変価格仕様
- `docs/ops/OPS-MONITORING-001.md` … 監視・テレメトリ正準
- `guides/business/*` … ビジネス戦略資料

---

## 🚀 役割別おすすめ導線

### 新規メンバー向け
1. `docs/overview/STARLIST_OVERVIEW.md`
2. `docs/overview/COMMON_DOCS_INDEX.md`
3. `docs/development/DEVELOPMENT_GUIDE.md`
4. `docs/planning/Task.md`

### PM 向け
1. `docs/planning/`
2. `guides/business/`
3. `docs/reports/`

### 開発者向け
1. `docs/architecture/`
2. `docs/features/`
3. `docs/api/`（仕様移行中）
4. `docs/development/`

---

## 📝 ドキュメント運用ルール（サマリ）

1. 設計 → ドキュメント → 実装の順で変更する（コードと同じブランチでレビュー）。
2. 仕様 = `docs/features/`、運用 = `docs/ops/`、図 = `docs/architecture/`、読み物 = `guides/`。
3. 旧資料は `repository/` や `docs/journal/` へ移し、現行版と分離。
4. 重要リンクは `docs/overview/COMMON_DOCS_INDEX.md` に追記する。

### 正準フォルダ原則

- **Source of Truth**: Flutter実装を最優先とし、仕様は実装追従
- **正準配置**: 仕様は `docs/features/`、運用は `docs/ops/`、図は `docs/architecture/`、読み物は `guides/`
- **参照シェル**: Day4参照用シェルは `docs/features/day4/` に配置し、正準は `docs/ops/` を参照

### 監査イベント命名統一

| カテゴリ | イベント名 | 説明 |
| --- | --- | --- |
| `auth.*` | `auth.login.success/failure` | ログイン成功/失敗 |
| | `auth.link.success` | プロバイダリンク成功 |
| | `auth.reauth.triggered` | 再認証トリガー |
| | `auth.sync.dryrun` | 認証同期Dry-run |
| `rls.*` | `rls.access.denied` | RLSアクセス拒否 |
| `ops.subscription.*` | `ops.subscription.price_set` | 価格設定 |
| | `ops.subscription.price_changed` | 価格変更 |
| | `ops.subscription.price_denied` | 価格設定拒否 |

最終更新: 2025-11-07

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
