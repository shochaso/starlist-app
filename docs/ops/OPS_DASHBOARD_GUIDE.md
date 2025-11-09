# OPS Dashboard Guide

## Flags & Modes
- `OPS_MOCK=true`: 合成データで動作（モックページ `OpsMockDashboardPage` 推奨）。
- `OPS_MOCK=false` で実データ。

## Refresh & Filters
- 画面上の更新（Pull/ボタン/Retry/バッジ）はすべて `manualRefresh()` に集約。
- フィルタ変更は `setFilter()` のみで反映。`ref.refresh` は使いません。

## Auth Badge
- 401/403 は `opsMetricsAuthErrorProvider` を true にする。
- UI は `ref.listen` で SnackBar など副作用のみを出す。

## Timer & Telemetry
- 30秒タイマーは常に単一実行。dispose で `cancel()`。
- `LogAdapter` で `kind/ms/count/hash` を出力し、将来的に Sentry/GA4 へ差し替え可能。

## CI
- `flutter-providers-ci.yml` が providers/helpers/pages(ops) の変更で動きます（Flutterテスト + `dart analyze`）。
