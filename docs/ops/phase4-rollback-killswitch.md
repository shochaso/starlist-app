# Phase 4 Rollback & KillSwitch Runbook

## このドキュメントの使い方 / How to Use During 2025-11-14 Event
- 自動監査ループで重大な逸脱を検知した際に即時停止するための Runbook です。
- 実行前に Slack / PagerDuty でインシデントチャンネルを開設し、各ステップ完了を UTC で記録してください。

## KillSwitch Criteria
1. Supabase upsert が 5 分間で 3 回連続 5xx を返す。
2. Manifest 更新が競合し `_manifest.json` の整合性が崩れた兆候 (JSON parse エラー)。
3. 同一ランで成功/失敗ステータスが二重記録され、監査 KPI に重大な矛盾が生じる。

## Immediate Actions
1. `.github/workflows/phase4-auto-audit.yml` のスケジュールトリガーを無効化 (Actions UI)。
2. 進行中のジョブをキャンセルし、`AUTO_OBSERVER_SUMMARY.md` にキャンセル理由を追記。
3. `scripts/phase4-manifest-atomic.sh --rollback` を実行し、直前のバックアップファイルへ復旧。
4. Slack へマスク済みステータスを投稿 (status, timestamp, summary のみ)。

## Rollback Procedure
1. `git status` を確認し、未コミットの manifest 変更がある場合はローカルで退避。
2. `scripts/phase4-auto-collect.sh` を停止し、再実行時は `--dry-run` オプションで影響を評価。
3. 必要であれば Phase 3 ドキュメント (`docs/reports/2025-11-13/PHASE3_MANUAL_DISPATCH_OPERATIONS_GUIDE.md`) にフォールバック。

## Restart Criteria
- Secrets チェックを再度実施し、`phase4-secrets-check.md` のチェックボックスがすべて ✅。
- Manifest 整合性テスト (`jq empty`) が成功し、重複 run_id が存在しない。
- Supabase upsert のテストリクエストが 2xx を返す。

## Escalation Matrix
| 役割 | 連絡方法 | SLA |
| --- | --- | --- |
| Incident Commander | PagerDuty Major Channel | 5 分以内に応答 |
| Supabase Admin | Secure Slack DM | 10 分以内 |
| Audit Lead | Slack Audit Channel | 15 分以内 |
