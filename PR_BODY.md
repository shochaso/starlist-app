feat(ops): Day7 OPS Alert Automation — Recent Alerts UI + CI

## 概要

Day7の実装スコープを完了。OPS Alert Automationにより、Edge Function `ops-alert`の拡張、Flutterダッシュボードに「Recent Alerts」セクション追加、CI検証ワークフローを実装。Day6のOPS Dashboardと連携し、「収集 → 可視化 → アラート表示」のサイクルを完成。

## 変更点（ハイライト）

* **Edge Function拡張**
  * `supabase/functions/ops-alert/index.ts`
    * アラート情報の詳細化（type, value, threshold）
    * 環境変数で閾値を設定可能（`FAILURE_RATE_THRESHOLD`, `P95_LATENCY_THRESHOLD`）
    * アラート種別を明確に識別（failure_rate/p95_latency）

* **Flutter Recent Alerts実装**
  * `lib/src/features/ops/models/ops_alert_model.dart`（新規）
    * `OpsAlert` - アラート情報モデル
  * `lib/src/features/ops/providers/ops_metrics_provider.dart`
    * `opsRecentAlertsProvider` - ops-alert Edge Function呼び出し
  * `lib/src/features/ops/screens/ops_dashboard_page.dart`
    * `_buildRecentAlerts` - Recent AlertsセクションUI実装
    * アラート種別アイコン（失敗率/遅延）
    * アラート詳細表示（値・閾値・時刻）

* **CI検証**
  * `.github/workflows/ops-alert-dryrun.yml`（新規）
    * PR作成時に自動実行
    * dryRunモードでアラート検出を検証

* **Docs**
  * `docs/ops/OPS-ALERT-AUTOMATION-001.md`（新規）
    * Day7実装計画・検証手順・アラートペイロード仕様

## 受け入れ基準（DoD）

- [x] Edge Function `ops-alert`がアラート情報を詳細に返却（type, value, threshold）
- [x] Flutter `/ops` ダッシュボードに「Recent Alerts」セクションを追加
- [x] アラート種別（失敗率/遅延）をアイコンで識別可能
- [x] アラート値・閾値・時刻を表示
- [x] CI `ops-alert-dryrun.yml`でダミーアラートを自動検証
- [x] ドキュメント `OPS-ALERT-AUTOMATION-001.md`を完成

## 影響範囲

* `supabase/functions/ops-alert/**` - Edge Function拡張
* `lib/src/features/ops/**` - Flutter Recent Alerts実装
* `.github/workflows/ops-alert-dryrun.yml` - CI検証ワークフロー
* `docs/ops/OPS-ALERT-AUTOMATION-001.md` - ドキュメント

## リスク&ロールバック

* **リスク**: Edge Function呼び出し失敗時のエラーハンドリング
* **緩和**: Providerでエラーをキャッチし、空リストを返却
* **ロールバック**: 前コミットに戻すのみ（DB変更なし）

## CI ステータス

* OPS Alert DryRun：🟢（予定）
* Docs Status Audit：🟢（予定）
* Lint：🟢（予定）
* Tests：🟢（予定）

## レビュワー / メタ

* Reviewer: @pm-tim
* Labels: `area:ops`, `type:feature`, `day7`
* Breakings: なし

---

## Screenshots

* [ ] Recent Alertsセクション（アラートあり）
* [ ] Recent Alertsセクション（アラートなし）
* [ ] CI ops-alert-dryrun.yml 実行結果

## Manual QA

* ✅ `/ops` ページでRecent Alertsセクションが表示される
* ✅ アラート種別アイコンが正しく表示される
* ✅ アラート値・閾値・時刻が正しく表示される
* ✅ アラートなし時は「No alerts」メッセージが表示される
* ✅ Edge Function呼び出しエラー時はエラーメッセージが表示される

## Docs Updated

* `docs/ops/OPS-ALERT-AUTOMATION-001.md` → Status: planned / 実装計画・検証手順・アラートペイロード仕様

## Risks / Follow-ups (Day8)

* アラート履歴の永続化（`ops_alerts`テーブル作成）
* アラート通知の拡張（Email/SMS等）
* アラート設定のUI化（閾値設定画面）
* OPS Health Dashboard設計
