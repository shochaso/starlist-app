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

最終更新: 2025-11-07
