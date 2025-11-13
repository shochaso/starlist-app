---
title: "Phase 3 Manual Dispatch Operations Guide (2025-11-13 JST)"
status: "準備完了"
last_reviewed_at_utc: "2025-11-12T15:00:00Z"
---

# Phase 3 Manual Dispatch Operations Guide

## このドキュメントの使い方 / How to Use During 2025-11-13 Event
- 本書は 2025-11-13 (JST) の手動ディスパッチ運用中に参照する即応ガイドです。
- 全てのタイムスタンプは明示的に UTC と JST を併記してください。
- 作業前に `RUNS_SUMMARY.schema.txt` を確認し、証跡は `_evidence_index.md` に逐次追記します。
- Slack や Supabase のシークレット値は絶対に記載しません。必要に応じて環境変数名のみ言及します。

## Manual Success Flow
1. `workflow_dispatch` から対象ラン(tag または commit)を指定し実行。
2. ジョブ実行後、Artifacts を `phase4-auto-collect.sh` のステップに従って取得。
3. `phase4-sha-compare.sh` を用いて SHA パリティを確認し、結果を RUNS_SUMMARY に登録。
4. Slack 手動通知ではメッセージ要約(ステータス/UTC 時刻/Run ID)のみ共有。

## Manual Failure Flow
1. 失敗ケースは同一タグでリトライせず、`run_id` を別管理。
2. 失敗ログは `docs/reports/2025-11-13/_evidence_index.md` へ証跡リンクを追記。
3. 失敗時は Phase 4 の自動リトライ前提条件(HTTP ステータス分類)を確認し、適切な報告を `PHASE3_AUDIT_SUMMARY.md` へ記録。

## Concurrency Guard
- 手動実行は 1 件ずつ。並列起動が必要な場合は `group: phase3-manual-${{ github.ref }}` の既存設定を再確認。
- 実行中のランがある場合は完了を待ち、証跡の整合性を担保します。

## Observer Coordination
- Phase 3 終了後 24 時間以内に Phase 4 オブザーバーへ手動結果を共有。
- 共有内容は RUNS_SUMMARY の抜粋と `_manifest.json` の最新状態。(Phase4 チームが自動投入する前提のため参照のみ)

## Escalation Matrix
| 状況 | 連絡先 | チャンネル |
| --- | --- | --- |
| ワークフロー停止 | Ops ディレクター | Secure Slack Channel |
| 証跡収集障害 | Evidence 管理者 | PagerDuty / Phone |
| KPI 逸脱 | Audit リード | Slack (マスク済みサマリ) |

## Post-Run Checklist (UTC 記録例)
- [ ] 2025-11-13T04:00Z 成功ランの証跡を `_evidence_index.md` に登録。
- [ ] 2025-11-13T08:00Z 失敗ランのログを Supabase バケットへ保管 (URL は書かない)。
- [ ] `PHASE3_AUDIT_SUMMARY.md` に KPI を暫定入力、 Phase 4 へ引き継ぐ。

## 参考リンク (内部向け)
- `docs/ops/PHASE4_ENTRYPOINT.md`
- `docs/reports/2025-11-14/PHASE3_AUDIT_SUMMARY.md`
