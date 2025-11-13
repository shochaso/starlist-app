# Phase 4 Audit & Self-Heal Entrypoint

## このドキュメントの使い方 / How to Use During 2025-11-13–2025-11-14 Events
- Phase 3 手動ディスパッチ (2025-11-13 JST) と Phase 4 自動監査 (2025-11-14 JST) を横断的に管理するためのハブです。
- 業務開始前に以下のチェックリストを確認し、必要ファイルを開いておきます。
- すべてのタイムスタンプは UTC を基準とし、JST が必要な場合のみ併記してください。

## Quick Links
- Phase 3 Manual Docs: `docs/reports/2025-11-13/`
  - Runbook: `PHASE3_MANUAL_DISPATCH_OPERATIONS_GUIDE.md`
  - Evidence Index: `_evidence_index.md`
  - KPI Template: `PHASE3_AUDIT_SUMMARY.md`
- Phase 4 Auto Docs: `docs/reports/2025-11-14/`
  - RUNS Summary JSON: `RUNS_SUMMARY.json` (schema: `RUNS_SUMMARY.schema.txt`)
  - Manifest: `_manifest.json` (template: `_manifest.json.template`)
  - Observer Log: `AUTO_OBSERVER_SUMMARY.md`
  - Slack Masking: `slack_excerpts/README.md`

## Operational Sequence
1. **Before Phase 3 (2025-11-13 JST)**
   - Review manual runbook (`PHASE3_MANUAL_DISPATCH_OPERATIONS_GUIDE.md`).
   - Prepare evidence folders, confirm `_evidence_index.md` is empty and ready.
2. **During Phase 3**
   - After each manual run, update `_evidence_index.md` and `RUNS_SUMMARY.json` (via `phase4-auto-collect.sh`).
   - Log KPI snapshots in `PHASE3_AUDIT_SUMMARY.md`.
3. **Phase 3 → Phase 4 Handoff**
   - Copy validated RUNS summary entries into `docs/reports/2025-11-14/RUNS_SUMMARY.json`.
   - Ensure `_manifest.json` reflects all Phase 3 artifacts.
   - Notify Phase 4 observer with run list and parity status.
4. **Phase 4 Auto Observer Execution (2025-11-14 JST)**
   - Trigger `.github/workflows/phase4-auto-audit.yml` (workflow_dispatch or schedule).
   - Execute scripts:
     ```
     ./scripts/phase4-auto-collect.sh <run_id>
     ./scripts/phase4-observer-report.sh --observer-run-id <workflow_run_id> --window-days 7 --supabase-upsert
     ```
   - Review outputs in `PHASE3_AUDIT_SUMMARY.md` and `AUTO_OBSERVER_SUMMARY.md`.

## Evidence Map
| Artifact | Location | Notes |
| --- | --- | --- |
| Manual run logs | `docs/reports/2025-11-13/_evidence_index.md` | Add entry within 5 mins |
| Automated artifacts | `docs/reports/2025-11-14/artifacts/<run_id>/` | Managed via `phase4-auto-collect.sh` |
| Manifest of artifacts | `docs/reports/2025-11-14/_manifest.json` | Update via `phase4-manifest-atomic.sh` |
| Slack summaries | `docs/reports/2025-11-13/slack_excerpts/`, `docs/reports/2025-11-14/slack_excerpts/` | Status/timestamp only |
| KPIs | `PHASE3_AUDIT_SUMMARY.md` (both days) | Observer script overwrites 2025-11-14 version |

## Checklist
- [ ] Phase 3 runbook reviewed (2025-11-13).
- [ ] Phase 3 evidence index initialized.
- [ ] `phase4-auto-collect.sh` dry-run executed with sample run_id.
- [ ] `_manifest.json` validated via `jq`.
- [ ] Supabase presence check passed (`phase4-secrets-check.md`).
- [ ] `phase4-observer-report.sh --supabase-upsert` executed and results logged.
- [ ] Slack excerpts stored with masking policy.

## Escalation
- Secrets missing → Follow `phase4-secrets-check.md` escalation chain.
- Retry policy deviation → Reference `.github/workflows/phase4-retry-guard.yml`.
- KillSwitch activation → `phase4-rollback-killswitch.md` を参照。
