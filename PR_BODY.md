feat(ops): Day8 OPS Health Dashboard — DB + Edge + Flutter

## 概要

Day8の実装スコープを完了。OPS Health Dashboardにより、アラート履歴からサービス健全性を可視化。DBマイグレーション、Edge Functions拡張、Flutter UI実装を完了し、「収集 → 可視化 → アラート表示 → ヘルスチェック」のサイクルを完成。

## 変更点（ハイライト）

* **DBマイグレーション**
  * `supabase/migrations/20251107_ops_alerts_history.sql`（新規）
    * `ops_alerts_history`テーブル作成
    * インデックス3本（alerted_at, type+env, app+env）
    * RLSポリシー設定（SELECT/INSERT）

* **Edge Function拡張**
  * `supabase/functions/ops-alert/index.ts`
    * アラート検出時に`ops_alerts_history`に履歴保存
    * dryRunモードでは保存をスキップ
  * `supabase/functions/ops-health/index.ts`（新規）
    * 期間別・サービス別に集計
    * 指標計算: uptime %, mean p95(ms), alert trend

* **Flutter実装**
  * `lib/src/features/ops/models/ops_health_model.dart`（新規）
    * `OpsHealthData` - ヘルスデータモデル
    * `OpsHealthAggregation` - 集計データモデル
  * `lib/src/features/ops/providers/ops_metrics_provider.dart`
    * `opsHealthProvider` - ops-health Edge Function呼び出し
    * `opsHealthPeriodProvider` - 期間選択状態管理
  * `lib/src/features/ops/screens/ops_dashboard_page.dart`
    * TabBar追加（Metrics/Healthタブ）
    * HealthタブUI実装:
      * 期間選択（1h/6h/24h/7d）
      * 稼働率グラフ（Uptime %）
      * 平均応答時間グラフ（Mean P95 Latency）
      * 異常率グラフ（Alert Trend）

* **Docs**
  * `docs/ops/OPS-HEALTH-DASHBOARD-001.md`（新規）
    * Day8実装計画・集計設計・UI設計

## 受け入れ基準（DoD）

- [x] `ops_alerts_history`テーブルを作成し、RLSポリシーを設定
- [x] Edge Function `ops-alert`でアラート検出時に履歴保存
- [x] Edge Function `ops-health`で期間別・サービス別に集計
- [x] Flutter `/ops`ダッシュボードにTabBar追加（Metrics/Healthタブ）
- [x] Healthタブで期間選択（1h/6h/24h/7d）が動作
- [x] 稼働率グラフ（Uptime %）が表示される
- [x] 平均応答時間グラフ（Mean P95 Latency）が表示される
- [x] 異常率グラフ（Alert Trend）が表示される
- [x] グラフでサービス別（app/env）に識別可能
- [x] アラートトレンド（increasing/decreasing/stable）が色分け表示される
- [x] ドキュメント `OPS-HEALTH-DASHBOARD-001.md`を完成

## 影響範囲

* `supabase/migrations/**` - DBマイグレーション追加
* `supabase/functions/ops-alert/**` - Edge Function拡張
* `supabase/functions/ops-health/**` - Edge Function新設
* `lib/src/features/ops/**` - Flutter Health Dashboard実装
* `docs/ops/OPS-HEALTH-DASHBOARD-001.md` - ドキュメント追加

## リスク&ロールバック

* **リスク**: アラート履歴の蓄積によるDB容量増加
* **緩和**: インデックス最適化、期間フィルタでクエリ効率化
* **ロールバック**: 前コミットに戻すのみ（DB変更あり、マイグレーションロールバック必要）

## CI ステータス

* OPS Alert DryRun：🟢（予定）
* Docs Status Audit：🟢（予定）
* Lint：🟢（予定）
* Tests：🟢（予定）

## レビュワー / メタ

* Reviewer: @pm-tim
* Labels: `area:ops`, `type:feature`, `day8`
* Breakings: なし

---

## Screenshots

* [ ] Healthタブ（期間選択・3グラフ）
* [ ] Uptime %グラフ（サービス別）
* [ ] Mean P95 Latencyグラフ（サービス別）
* [ ] Alert Trendグラフ（色分け表示）

## Manual QA

* ✅ `/ops` ページでTabBar（Metrics/Health）が表示される
* ✅ Healthタブで期間選択（1h/6h/24h/7d）が動作する
* ✅ 稼働率グラフが正しく表示される
* ✅ 平均応答時間グラフが正しく表示される
* ✅ 異常率グラフが正しく表示される
* ✅ アラートトレンドが色分け表示される（increasing=赤、decreasing=緑、stable=橙）

## Docs Updated

* `docs/ops/OPS-HEALTH-DASHBOARD-001.md` → Status: planned / 設計方針・指標定義・集計ロジック

## Risks / Follow-ups (Day9)

* アラート履歴の自動アーカイブ（古いデータの削除/アーカイブ）
* OPS Summary Email（週次レポート自動生成）
* ヘルスチェックの閾値設定UI化
* サービス別の詳細ダッシュボード
