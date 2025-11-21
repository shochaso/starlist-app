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


# Starlist プロジェクト概要（雛形）

Starlist の全体像を短時間で共有するためのテンプレートです。各章に最新情報を記入して利用してください。

---

## 目次

1. [はじめに](#はじめに)
2. [プロダクトビジョンとターゲット](#プロダクトビジョンとターゲット)
3. [アーキテクチャサマリー](#アーキテクチャサマリー)
4. [主要コンポーネント詳細](#主要コンポーネント詳細)
5. [ディレクトリ構成ハイライト](#ディレクトリ構成ハイライト)
6. [機能マップと進捗](#機能マップと進捗)
7. [外部連携・依存サービス](#外部連携依存サービス)
8. [関連ドキュメント一覧](#関連ドキュメント一覧)
9. [ロードマップ・今後の課題](#ロードマップ今後の課題)
10. [更新履歴](#更新履歴)

---

## はじめに

- ドキュメントの目的と想定読者。
- プロジェクトの現状ステータス（例: α版/β版/本番）。
- 保守・更新の責任者。

> TODO: 最新のプロジェクトステータスを記入。

---

## プロダクトビジョンとターゲット

- Starlist が解決したい課題と提供価値。
- 主要ユーザー（例: スター/ファン/運営）のペルソナ。
- 成功指標（KPI/North Star Metric 等）。

> TODO: ビジネスチームと整合した内容を記載。

---

## アーキテクチャサマリー

- システム全体図（図表やリンクがあれば記載）。
- 主要技術スタック（フロントエンド/バックエンド/データ基盤など）。
- インフラ構成の概要（ホスティング、CI/CD、監視）。

| レイヤ | 技術 | メモ |
| --- | --- | --- |
| フロントエンド | Flutter (Dart) + Riverpod | モバイル/デスクトップ/Web を単一コードベースで提供。Chrome 開発用に `scripts/c.sh` を使用。 |
| バックエンド | NestJS (TypeScript) | `server/src/` 配下で ingest・media・metrics モジュールを提供。 |
| データ基盤 | Supabase (Postgres, Edge Functions) | マイグレーションで RLS を管理し、`exchange`/`sign-url`/`ops-alert`/`ops-health`/`ops-summary-email`/`ops-slack-notify` 関数を稼働。 |
| ストレージ | Supabase Storage | `doc-share` バケットを大容量資料共有向けに追加予定。 |
| 決済 | Stripe | サブスク課金・返金 API を利用。将来はコンビニ/キャリア決済を追加計画。 |

---

## 主要コンポーネント詳細

- フロントエンド（アプリ、Web）: 役割・主要モジュール・依存。
- バックエンド（API、ジョブ、メディア処理）: 役割・インターフェース。
- データ/ストレージ: テーブル概要、RLS ポリシー、Storage バケット。
- 決済/サブスク: 利用サービス、フロー。

> TODO: 内部構造や責任範囲を記述。

---

## ディレクトリ構成ハイライト

| パス | 説明 | 備考 |
| --- | --- | --- |
| `lib/src/` | Flutter コア実装 | `features/`, `services/`, `providers/` に機能を分割。 |
| `server/` | NestJS バックエンド | `ingest/`, `media/`, `metrics/`, `health/` 等をモジュール化。 |
| `supabase/migrations/` | DB スキーマ | RLS・トリガー・ビューの SQL 定義を管理。 |
| `supabase/functions/` | Edge Functions | `exchange`, `sign-url`, `ops-alert`, `ops-health`, `ops-summary-email`, `ops-slack-notify` など Supabase Functions。 |
| `docs/` | ドキュメント群 | `COMMON_DOCS_INDEX.md`, `STARLIST_OVERVIEW.md`, `COMPANY_SETUP_GUIDE.md` を格納。 |
| `scripts/` | 開発/運用スクリプト | `c.sh`, `deploy.sh`, `progress-report.sh` など。 |

> TODO: 主要ファイルやフォルダを必要に応じて追加。

---

## 機能マップと進捗

| 機能カテゴリ | 現状ステータス | 次のアクション |
| --- | --- | --- |
| データインポート | 主要サービスのダミー取り込み UI/診断機能を実装済み。 | サポートマトリクスとアイコン資産の整備を継続。 |
| 決済/サブスク | Stripe ベースの Payment/Subscription Service を実装。 | コンビニ・キャリア決済の仕様検討と実装着手。 |
| 分析/レポート | ランキング/スターデータ画面の初期バージョンを提供。 | 指標ダッシュボード強化とテスト追加。 |
| AI/自動化 | AI 秘書・スケジューラの設計ドキュメントを作成済み。 | PoC 実装とインテグレーションのロードマップ策定。 |
| Day5-9 Telemetry/OPS | Day5: キックオフ（DB/Edge 設計完了）。Day6: OPS Dashboard（フィルタ・KPI・グラフ・自動リフレッシュ）。Day7: OPS Alert Automation（Slack通知準備）。Day8: OPS Health Dashboard（uptime/p95/alert trend）。Day9: OPS Summary Email（週次レポート自動送信）。 | Day10: OPS Slack Notify（日次通知・即時アラート）実装完了。本番デプロイ準備完了。 |
| Day10 OPS Slack Notify | 実装・テスト完了（Edge Function + GitHub Actions + DB監査ログ連携済み）。 | 本番デプロイ + 運用チューニング（1週間運用後、しきい値調整予定）。 |

> TODO: PM/各担当と進捗を整合。

---

## 外部連携・依存サービス

- 例: Stripe、Supabase、Auth0/LINE、SNS API、CDN 等。
- 契約形態や使用制限、認証方式（OAuth、API Key 等）。
- 障害時のエスカレーション先やサポート窓口。

> TODO: 依存関係を一覧化。

---

## 関連ドキュメント一覧

- `docs/overview/COMMON_DOCS_INDEX.md` … ドキュメント目次。
- `docs/COMPANY_SETUP_GUIDE.md` … オンボーディング手順（雛形）。
- `docs/development/DEVELOPMENT_GUIDE.md` … 開発環境構築。
- `docs/features/payment_current_state.md` … 決済実装の現状。
- `docs/CHATGPT_SHARE_GUIDE.md` … ChatGPT 共有フローとチェックリスト。
- `docs/ops/supabase_byo_auth.md` … Supabase BYO Auth / doc-share 運用手順。
- その他関連資料を箇条書きで追記。

> TODO: 追加で参照したい資料があればリストアップ。

---

## ロードマップ・今後の課題

- **Day5-9 (完了)**: Telemetry/OPS 実装（`ops_metrics` / `v_ops_5min` / Edge `telemetry` & `ops-alert`）、OPS Dashboard、Alert Automation、Health Dashboard、Summary Email。  
- **Day10 (完了)**: OPS Slack Notify（日次通知・即時アラート）実装完了。本番デプロイ準備完了。  
- **Day11 (予告)**: 閾値自動チューニング、Dashboard統合、即時アラート（Webhook連携）。  
- **技術的負債**: Edge Dry-run API 設計、スター単位課金の DB 拡張、Mermaid Day5 ノードの最終確定。

---

## 更新履歴

| 日付 | 更新者 | 変更箇所 |
| --- | --- | --- |
| 2025-10-?? | 作成者名 | 雛形作成 |
| 2025-11-07 | Tim | Day5 Telemetry/OPS サマリーとロードマップを更新。 |
| 2025-11-08 | Tim | Day10 OPS Slack Notify 実装完了。機能マップとロードマップを更新。 |

| 2025-11-07 | Tim | Day5 Telemetry/OPS サマリーとロードマップを更新。 |
| 2025-11-08 | Tim | Day10 OPS Slack Notify 実装完了。機能マップとロードマップを更新。 |

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
