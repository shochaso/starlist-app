# OPS-TELEMETRY-SYNC-001 — Telemetry/OPS同期仕様

Status: in-progress  
Last-Updated: 2025-11-07  
Source-of-Truth: supabase/migrations/20251107_ops_metrics.sql / supabase/functions/telemetry / Flutter (`lib/src/features/ops/ops_telemetry.dart`)

> 責任者: ティム（COO/PM）／実装: OPS/SRE チーム

## 1. 目的

- Day5 で Telemetry → OPS アラート連携を実装し、Flutter/Edge/Supabase を一気通貫で同期する。  
- 直近 5 分の KPI（件数/失敗率/p95レイテンシ）をダッシュボード表示し、ops-alert で Slack 通知へつなげる。

## 2. スコープ

- `public.ops_metrics` テーブルと 5 分バケットビュー (`v_ops_5min`) のマイグレーション。  
- Edge Functions: `telemetry`（POST ingest）と `ops-alert`（DryRun）。  
- Flutter `OpsTelemetry` クライアント、および QA 用 E2E Workflow (`qa-e2e.yml`)。

## 3. 仕様要点

1. Flutter から `/telemetry` に POST → Edge が Supabase HTTP Interface 経由で `ops_metrics` に挿入。  
2. `ops_metrics` には `app/env/event/ok/latency_ms/err_code/extra` を保存し、RLS で Edge 呼び出し元のみ insert 可能。  
3. `v_ops_5min` ビューで 5 分バケット集計 `(total, avg_latency_ms, p95_latency_ms, failure_rate)` を算出。  
4. `ops-alert` は DryRun で v_ops_5min を参照する想定（現フェーズではログのみ）。  
5. CI (`qa-e2e`) で Telemetry POST / ops-alert DryRun を毎回検証。

## 4. テスト観点

- 正常な Telemetry POST が 201 を返し、`ops_metrics` に 1 行追加されること。  
- `latency_ms` / `err_code` / `extra` の欠損時にも `null` として保存されること。  
- `ops-alert` DryRun が `"dryRun": true` を返し、ログで `[ops-alert] dryRun OK` を確認できること。  
- `qa-e2e` Workflow が `TELEMETRY_URL` シークレットを参照して疎通すること。

## 5. 完了条件 (Day5)

- Supabase migration 適用 + `v_ops_5min` の SELECT 結果をスクショ化。  
- Edge Functions `telemetry` / `ops-alert` の `supabase functions deploy` が成功。  
- Flutter ダミーボタンから Telemetry を送信でき、OPS ダッシュボードで 5 分カードが更新される。  
- QA Workflow が緑、`DAY5_SOT_DIFFS.md` にコード参照を追記。

---

## 差分サマリ (Before/After)

- **Before**: Telemetry/OPS 実装は計画のみ（Day4）。DB/Edge/Flutter/CI の各モジュールが未着手。  
- **After**: マイグレーション雛形と Edge/Flutter/CI の初期実装を配置し、Day5 本実装をすぐ開始できる状態に更新。  
- **追加**: docs/ops に Day5 Telemetry SoT を新設、`Status` を in-progress に変更し、DoD を Day5 手順にリンク。

---

## 6. Day6 `/ops` ダッシュボード（UI確認フロー）

![OPS Dashboard (Day6)](../images/ops_dashboard_day6.png)

1. Flutter アプリ起動後に `/ops` へ遷移（GoRouter: `ops_dashboard`）。  
2. 上部フィルタで `env/app/event/期間` を選択 → 5 秒以内に KPI・グラフ再描画されること。  
3. 30 秒毎の自動リフレッシュ／手動リフレッシュ／空状態／エラーの再読込ボタンが期待どおり動作することを確認。  
4. Asia/Tokyo の時間軸、p95 折れ線＋成功/失敗スタック棒の同期スクロール、直近アラートリストの UI を記録（スクショ 2 枚：データ有/空）。
