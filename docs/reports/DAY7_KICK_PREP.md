# Day7 キック準備

## ブランチ情報

- **Branch**: `feature/day7-ops-alert-automation`
- **ベース**: `main`（Day6マージ後）

## Scope

### Edge Function `ops-alert`
- `p95`/`fail_rate` 閾値 & `dryRun`
- Slack/Discord 通知連携

### Flutter
- 「Recent Alerts」セクション実装
  - 空状態
  - エラー状態
  - ローディング状態
  - 自動更新

### CI
- `ops-alert` ダミー発火ワークフロー追加

## Docs

- `OPS-ALERT-AUTOMATION-001.md` 新設
  - 検証手順
  - 通知payload仕様
  - スクショ欄

## リスク最終確認

- 大量差分（492 files, +32,705/-19,337）：**Squash**で履歴を圧縮、緊急時は `v0.6.0-ops-dashboard-beta` タグから即ロールバック方針
- fl_chart 追加後の `flutter pub get` 実施をPR本文に明記
- `/ops` 空データ系の回帰はスクショで担保（empty/data 両パターン）


