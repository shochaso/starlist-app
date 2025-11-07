Status:: 
Source-of-Truth:: (TBD)
Spec-State:: 
Last-Updated:: 


# OPS-MONITORING-001 — 監視・テレメトリ統合仕様

Status: aligned-with-Flutter  
Last-Updated: 2025-11-07  
Source-of-Truth: Flutter code (`lib/src/features/**`) / Planned Edge Functions

> 責任者: ティム（COO/PM）／実装: SRE/データチーム

## 1. 目的

- Day4 で追加される OAuth/RLS/ UI 変更に対し、可観測性と運用アラートを統合する。
- `audit_auth`, `telemetry`, `searchTelemetryProvider` を 1 つのダッシュボードで追跡。

## 2. スコープ

- Cloud Logging, Supabase 監査ログ、Edge Functions の telemetry。
- アラート設定（Sign-in 成功率, 再認証失敗率, RLS エラー率）。

## 3. 仕様要点（Reality → Target）

- 現状: Flutter から `auth.*` のログ送信は未実装。Edge Functions も存在せず、Supabase へ直接アクセスしているため、監査ログは Supabase の audit log のみ。  
- Target: ユーザーID＋セッションIDで全ログをトレースできるよう共通キーを付与し、以下のイベント命名で構造化ログを出力。  
  - `auth.login.success`, `auth.login.failure`  
  - `auth.link.success`  
  - `auth.reauth.triggered`  
  - `auth.sync.dryrun`  
  - `rls.access.denied` (SQL)  
  - `ops.subscription.price_selected`, `ops.subscription.price_confirmed`（新規課金仕様）  
- 主要 KPI: Sign-in 成功率 ≥ 99.5%, 再認証成功率 ≥ 99.0%。  
- アラートは Slack #ops-alerts へ通知し、PagerDuty と連携。

## 4. 依存関係

- AUTH-OAUTH-001（監査ログ追加）
- SEC-RLS-SYNC-001（RLS 判定ログ）
- QA-E2E-001（監視テスト）

## 5. テスト観点

- 失敗イベント発生時にメトリクスとアラートが発火するか（Dry-run ではログ保存のみ）。  
- Edge Functions のエラーログが漏れなく転送されるか。  
- 監視ダッシュボードで Day4 KPI が可視化されるか。  
- スター単位価格入力時のイベント（`ops.subscription.price_selected`）が収集されるか。

## 6. 完了条件

- 監視ダッシュボードのスクリーンショットと構成手順が docs/ops に追加。  
- アラートのドライラン結果を `docs/reports/` に記録。  
- Mermaid Day4 クラスタで `OPS-MONITORING-001` と新規課金仕様のリンクが有効。  
- 監査イベントが `.env.example` のフラグで切り替えられる。

---

## 差分サマリ (Before/After)

- **Before**: `auth.*` ログや `auth-sync` 連携が既に稼働している前提で記載。  
- **After**: Flutter Reality（ログ送信なし、Edge なし）に合わせ、命名規約と Dry-run 運用を明記。新規課金仕様の OPS イベント (`ops.subscription.*`) を追加。  
- **追加**: `rls.access.denied` を QA/SEC 仕様と共有し、OPS で捕捉する方針を定義。
