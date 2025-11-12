# Evidence Index

**Purpose**: Centralized index of all evidence collected during Phase 2/3 implementation and validation.

**Last Updated**: 2025-11-13

---

## Evidence Collection Summary

| WS | Evidence Type | File Path | URL/Reference | Timestamp | Collector |
|----|---------------|-----------|---------------|-----------|-----------|
| WS01 | Workflow Change | `docs/reports/2025-11-13/WS01_workflow_dispatch_added.md` | - | 2025-11-13 | Cursor AI |
| WS02 | Execution Log | `docs/reports/2025-11-13/WS02_SUCCESS_CASE_EXECUTION.md` | [Run URL待ち] | 2025-11-13 | Cursor AI |
| WS03 | Execution Log | `docs/reports/2025-11-13/WS03_FAILURE_CASE_EXECUTION.md` | [Run URL待ち] | 2025-11-13 | Cursor AI |
| WS04 | Execution Log | `docs/reports/2025-11-13/WS04_CONCURRENCY_EXECUTION.md` | [Run URLs待ち] | 2025-11-13 | Cursor AI |
| WS05 | Validation Report | `docs/reports/2025-11-13/PHASE2_2_VALIDATION_REPORT.md` | - | 2025-11-13 | Cursor AI |
| WS06 | Validation Log | `docs/reports/2025-11-13/WS06_SHA256_VALIDATION.md` | [Artifact URL待ち] | 2025-11-13 | Cursor AI |
| WS07 | Manifest | `docs/reports/2025-11-13/_manifest.json` | - | 2025-11-13 | Cursor AI |
| WS08 | API Response | `docs/reports/2025-11-13/WS08_SUPABASE_REST_VERIFICATION.md` | [Response JSON待ち] | 2025-11-13 | Cursor AI |
| WS09 | Webhook Log | `docs/reports/2025-11-13/WS09_SLACK_WEBHOOK_VERIFICATION.md` | [Response JSON待ち] | 2025-11-13 | Cursor AI |
| WS10 | Config Change | `docs/reports/2025-11-13/WS10_BRANCH_PROTECTION.md` | [GitHub Settings URL] | 2025-11-13 | Cursor AI |
| WS11 | PR Comment | `docs/reports/2025-11-13/WS11_PR_COMMENT.md` | [Comment URL待ち] | 2025-11-13 | Cursor AI |
| WS12 | Startup Log | `docs/reports/2025-11-13/WS12_PHASE3_OBSERVER_STARTUP.md` | [Run URL待ち] | 2025-11-13 | Cursor AI |
| WS13 | Audit Summary | `docs/reports/2025-11-13/PHASE3_AUDIT_SUMMARY.md` | - | 2025-11-13 | Cursor AI |
| WS14 | API Response | `docs/reports/2025-11-13/WS14_OBSERVER_SUPABASE_POST.md` | [Response JSON待ち] | 2025-11-13 | Cursor AI |
| WS15 | Procedure Doc | `docs/ops/SECRETS_PRECHECK.md` | - | 2025-11-13 | Cursor AI |
| WS16 | Policy Doc | `docs/ops/CI_RUNTIME_POLICY.md` | - | 2025-11-13 | Cursor AI |
| WS17 | Index Doc | `docs/reports/_evidence_index.md` | - | 2025-11-13 | Cursor AI |
| WS18 | Updated Report | `docs/reports/2025-11-13/PHASE2_2_VALIDATION_REPORT.md` | - | 2025-11-13 | Cursor AI |
| WS19 | Naming Guide | `docs/ops/NAMING_GUIDE.md` | - | 2025-11-13 | Cursor AI |
| WS20 | Handoff Doc | `docs/ops/TELEMETRY_HANDOFF.md` | - | 2025-11-13 | Cursor AI |

---

## Artifacts Index

| Artifact Name | Run ID | Tag | SHA256 | URL | Timestamp |
|---------------|--------|-----|--------|-----|-----------|
| [記録待ち] | [記録待ち] | [記録待ち] | [記録待ち] | [記録待ち] | [記録待ち] |

---

## Run URLs Index

| Workflow | Run ID | Status | Conclusion | URL | Timestamp |
|----------|--------|--------|------------|-----|-----------|
| slsa-provenance | [記録待ち] | [記録待ち] | [記録待ち] | [記録待ち] | [記録待ち] |
| provenance-validate | [記録待ち] | [記録待ち] | [記録待ち] | [記録待ち] | [記録待ち] |
| phase3-audit-observer | [記録待ち] | [記録待ち] | [記録待ち] | [記録待ち] | [記録待ち] |

---

## API Responses Index

| API Endpoint | Method | Status | Response JSON | Timestamp |
|--------------|--------|--------|---------------|-----------|
| `/rest/v1/slsa_runs` | GET | [記録待ち] | [記録待ち] | [記録待ち] |
| `/rest/v1/slsa_audit_metrics` | POST | [記録待ち] | [記録待ち] | [記録待ち] |
| Slack Webhook | POST | [記録待ち] | [記録待ち] | [記録待ち] |

---

**Note**: This index will be updated as evidence is collected during execution.

---

## Additional Evidence Files (2025-11-13)

| File | Type | Purpose | Status |
|------|------|---------|--------|
| `PROVENANCE_RUN_MANUAL.md` | Manual | UI/CLI execution guide | ✅ Created |
| `PROVENANCE_VALIDATION_COMMANDS.md` | Commands | Validation command reference | ✅ Created |
| `BRANCH_PROTECTION.md` | Config | Branch protection setup | ✅ Created |
| `DAY11_SOT_DIFFS.md` | Rollback | Rollback procedures | ✅ Created |

---

## Execution Status Summary

| WS | Status | Evidence File | Notes |
|----|--------|---------------|-------|
| WS01 | ✅ | WS01_workflow_dispatch_added.md | workflow_dispatch追加済み |
| WS02 | ⏳ | WS02_SUCCESS_CASE_EXECUTION.md | 実行待ち（workflow_dispatch認識待ち） |
| WS03 | ⏳ | WS03_FAILURE_CASE_EXECUTION.md | 実行待ち |
| WS04 | ⏳ | WS04_CONCURRENCY_EXECUTION.md | 実行待ち |
| WS05 | ✅ | PHASE2_2_VALIDATION_REPORT.md | 実績テンプレート追記済み |
| WS06 | ⏳ | WS06_SHA256_VALIDATION.md | 検証コマンド準備済み |
| WS07 | ✅ | _manifest.json | 初期エントリ追加済み |
| WS08 | ⏳ | WS08_SUPABASE_REST_VERIFICATION.md | Secrets未設定のため保留 |
| WS09 | ⏳ | WS09_SLACK_WEBHOOK_VERIFICATION.md | Webhook未設定のため保留 |
| WS10 | ✅ | BRANCH_PROTECTION.md | provenance-validate追加済み（ユーザー確認済み） |
| WS11 | ⏳ | WS11_PR_COMMENT.md | 条件整うまで待機 |
| WS12 | ⏳ | WS12_PHASE3_OBSERVER_STARTUP.md | 起動確認待ち |
| WS13 | ✅ | PHASE3_AUDIT_SUMMARY.md | テンプレート作成済み |
| WS14 | ⏳ | WS14_OBSERVER_SUPABASE_POST.md | 実行待ち |
| WS15 | ✅ | SECRETS_PRECHECK.md | 手順作成済み |
| WS16 | ✅ | CI_RUNTIME_POLICY.md | ポリシー作成済み |
| WS17 | ✅ | _evidence_index.md | 索引作成済み |
| WS18 | ✅ | PHASE2_2_VALIDATION_REPORT.md | 課題/原因/対策/確認追加済み |
| WS19 | ✅ | NAMING_GUIDE.md | ガイド作成済み |
| WS20 | ✅ | TELEMETRY_HANDOFF.md | ハンドオフドキュメント作成済み |

---

**Last Updated**: 2025-11-13 (UTC)
