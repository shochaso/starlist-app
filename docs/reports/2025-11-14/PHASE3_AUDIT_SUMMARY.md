---
title: "Phase 4 Audit Summary Template (Phase 3 Handoff Included)"
event_date_jst: "2025-11-14"
last_updated_utc: "2025-11-12T15:25:00Z"
---

# Phase 4 Audit Summary (Automated Observer Loop)

## このドキュメントの使い方 / How to Use During 2025-11-14 Event
- Phase 3 手動結果を受け取り、自動監査ループで得られた KPI を集約するテンプレートです。
- オブザーバースクリプト実行後に本テンプレートを複製し、`AUTO_OBSERVER_SUMMARY.md` の該当セクションへリンクを記載します。

## KPIs
- **total_runs (window_days=__):** 
- **success_count:** 
- **failure_count:** 
- **retry_invocations:** 
- **retry_success_rate:** 
- **sha_parity_pass_rate:** 
- **p50_latency_sec:** 
- **p90_latency_sec:** 
- **observer_lag_sec:** 

## Automated Findings
- Autoretry outcomes (UTC):
- Detected anomalies:
- Supabase ingestion status:

## Manual Backstop Review
- Phase 3 audit delta applied? (yes/no + notes)
- Manifest integrity confirmed? (yes/no + notes)
- KillSwitch invoked? (yes/no + timestamp if yes)

## Compliance Checks
- [ ] `_manifest.json` atomic updateログ確認済み
- [ ] `RUNS_SUMMARY.json` jq バリデーション済み
- [ ] Supabase upsert ステータスを `_evidence_index.md` に記録
- [ ] Slack サマリを slack_excerpts に追加

## Change Log
- 2025-11-14T__:__Z — Auto observer initial write by ______
- 2025-11-14T__:__Z — KPI verified with audit reviewer ______
