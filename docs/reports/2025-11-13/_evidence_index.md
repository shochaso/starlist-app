---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# Evidence Index (2025-11-13)

All evidence listed below lives under `docs/reports/2025-11-13/` (except where noted) and is referenced by the new Phase 2.2 and Phase 3 reports.

## 1. Dispatch / workflow logs

| Evidence | Details | Location / Link |
| --- | --- | --- |
| Manual dispatch attempts | `gh workflow run slsa-provenance.yml -f tag=...` (success/failure/concurrency) all returned `HTTP 422` (recorded in `PHASE2_2_VALIDATION_REPORT.md`). | `docs/reports/2025-11-13/PHASE2_2_VALIDATION_REPORT.md#playbook-execution-attempts` |
| `workflow_dispatch` path + ref | Additional explicit path commands (`.github/workflows/slsa-provenance.yml --ref ...`) showed the same 422 because Workflow ID 206322579 on `main` still lacks the hook. | `docs/reports/2025-11-13/PHASE2_2_VALIDATION_REPORT.md#additional-dispatch-attempts-explicit-path-ref` |
| Phase 3 observer dispatch | `gh workflow run phase3-audit-observer.yml --ref ...` also failed with 422 while the feature file advertises the inputs. | `docs/reports/2025-11-13/PHASE3_AUDIT_SUMMARY.md#1-manual-audit-dispatch-attempt` |

## 2. Run metadata snapshots

| Workflow | Latest runs (UTC) | Graph URL |
| --- | --- | --- |
| `slsa-provenance.yml` | 19303053744 (failure, 2025-11-12T15:40:39Z), 19302690592, 19302689701, 19302628134, 19302542584 | https://github.com/shochaso/starlist-app/actions/runs/19303053744 |
| `provenance-validate.yml` | 19303257146, 19303256080, 19303070560, 19303063465, 19303053984 (all failures) | https://github.com/shochaso/starlist-app/actions/runs/19303257146 |
| `phase3-audit-observer.yml` | 19303259295, 19303254816 (failures) | https://github.com/shochaso/starlist-app/actions/runs/19303259295 |

## 3. Manifest state

| Evidence | Details | Location / Link |
| --- | --- | --- |
| `_manifest.json` | remains `[]` because no manifest entries have been appended yet (no successful runs yet) | `docs/reports/_manifest.json` |

## 4. Branch protection

| Evidence | Details | Location / Link |
| --- | --- | --- |
| Required checks patch | Added `provenance-validate` in `required_status_checks.contexts` and kept strict enforcement in `main` branch protection | https://api.github.com/repos/shochaso/starlist-app/branches/main/protection |

## 5. Evidence for Supabase / Slack

| Evidence | Details | Location / Link |
| --- | --- | --- |
| Supabase credentials missing | `SUPABASE_URL`, `SUPABASE_SERVICE_KEY`, `SUPABASE_ANON_KEY` were unset in this environment, so no telemetry ingestion could be performed | `docs/reports/2025-11-13/PHASE2_2_VALIDATION_REPORT.md#supabase--notifications` |
| Slack notifications blocked | The failure path never executed, so the notify-on-failure job never had a run to report | same as above |

## 6. Screenshots / URLs

1. Workflow run viewer (slsa-provenance push failure): https://github.com/shochaso/starlist-app/actions/runs/19303053744  
2. Workflow run viewer (provenance-validate failure): https://github.com/shochaso/starlist-app/actions/runs/19303257146  
3. Workflow run viewer (phase3 audit failure): https://github.com/shochaso/starlist-app/actions/runs/19303259295  
4. Branch protection API payload: https://api.github.com/repos/shochaso/starlist-app/branches/main/protection  
5. PR #61 comment: https://github.com/shochaso/starlist-app/pull/61#issuecomment-3522651640

## 7. Supporting documentation

- `docs/ops/SECRETS_PRECHECK.md`: Steps to verify Supabase/Slack/dispatch secrets before executing the validation suite.
- `docs/ops/CI_RUNTIME_POLICY.md`: Concurrency, timeout, and retry guidance for the provenance/validation jobs and the Phase 3 observer.

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
