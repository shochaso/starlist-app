# Phase 4 Auto Audit / Self-Heal Overview

## このドキュメントの使い方 / How to Use During 2025-11-14 Event
- Phase 4 当日に観測・自己修復シーケンスを実行する運用者向けのエントリドキュメントです。
- 事前に `phase4-secrets-check.md` と `phase4-retry-policy.md` を確認し、必要な CI ガードが通る状態か検証してください。
- ハンドブックのステップ完了ごとにチェックボックスを更新し、`AUTO_OBSERVER_SUMMARY.md` へ転記します。

## Narrative
1. 手動 Phase 3 の結果を `docs/reports/2025-11-14/RUNS_SUMMARY.json` に取り込み。
2. オブザーバーが `window_days` に基づき GitHub Actions ランと Supabase の結果を集約。
3. 自動リトライロジックが 5xx を検知した場合のみ最大 3 回まで指数バックオフで再実行。
4. 監査完了後、Supabase メトリクスへアップサートし、Slack へマスク済みサマリを投稿。

## Roles
- **Observer Engineer:** `phase4-observer-report.sh` を実行し、KPI と証跡を集計。
- **Automation Operator:** `phase4-auto-collect.sh` でアーティファクトを収集、Manifest を更新。
- **Audit Reviewer:** `PHASE3_AUDIT_SUMMARY.md`（2025-11-14版）を確定し、Go/No-Go 判定を記録。
- **Incident Commander:** `phase4-rollback-killswitch.md` を参照し、必要時に即時停止を判断。

## Objectives
- Phase 3 の手動証跡を自動監査ループに統合し、24h 以内に自己修復完了。
- すべてのリトライは `phase4-retry-guard.yml` に準拠。
- Manifest の更新は `scripts/phase4-manifest-atomic.sh`（Step5 で実装予定）を用いた原子的手順で行う。

## Key References
- `docs/reports/2025-11-14/_manifest.json.template`
- `.github/workflows/phase4-auto-audit.yml`
- `.github/workflows/phase4-retry-guard.yml`
- `scripts/phase4-auto-collect.sh`
- `scripts/phase4-manifest-atomic.sh`

## Manifest Atomic Update Procedure
1. `scripts/phase4-manifest-atomic.sh --run-id <RUN_ID> --artifact-path <relative_path> --evidence-type <type> --recorded-at <UTC>` を実行。
2. スクリプトは既存の `_manifest.json` を読み込み、同一 run_id のエントリを差し替えた上でテンポラリファイルに書き出します。
3. `jq '.'` による JSON バリデーション後、`mv` を用いてテンポラリを本ファイルに置換 (同一ディレクトリ内で行うため atomic)。
4. 失敗時はテンポラリファイルが残るため、内容を確認し原因調査の上で削除します。

## Local Test Snippets
サンプル run_id とファイルパスは実行環境に合わせて置換してください。
実行前に `SUPABASE_URL` / `SUPABASE_SERVICE_KEY` など必要な環境変数をエクスポートしておきます。

```
# 1. アーティファクト収集 (ダウンロードのみ実施)
./scripts/phase4-auto-collect.sh 1234567890 --dry-run --artifact-pattern '*.zip'

# 2. SHA パリティ確認 (取得したファイルを利用)
./scripts/phase4-sha-compare.sh docs/reports/2025-11-14/artifacts/1234567890/raw/app.zip \
  docs/reports/2025-11-14/artifacts/1234567890/raw/provenance-*.json \
  --run-id 1234567890

# 3. KPI 再計算 (事前に RUNS_SUMMARY.json を準備した上で)
./scripts/phase4-observer-report.sh --observer-run-id DRYRUN-001 --window-days 1 --supabase-upsert
```
