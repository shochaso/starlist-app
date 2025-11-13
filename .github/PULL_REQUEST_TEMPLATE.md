## Linear

- Issue Key: `STA-XX`（必須）
- 自動遷移: PR作成→In Progress / レビュー→In Review / マージ→Done

## 目的

なぜこの変更が必要か（1〜2行）

## Changes

- 主要な変更点を箇条書きで

## Test

- 動作確認手順 or スクショ/ログ

## Checklist

- [ ] タイトルは `[STA-xx]` で始まる
- [ ] `build (pull_request)` と `check (pull_request)` が緑
- [ ] CI が通る / 失敗原因を把握している
- [ ] レビュー観点（破壊的変更、移行、セキュリティ）を明記
- [ ] (Phase4) `docs/reports/2025-11-14/RUNS_SUMMARY.json` に成功/失敗/並列結果を反映
- [ ] (Phase4) 証跡を `docs/reports/2025-11-14/` 以下に保存し `_manifest.json` を更新
- [ ] (Phase4) `scripts/phase4-observer-report.sh --supabase-upsert` の結果を共有 (Supabase応答コード含む)
