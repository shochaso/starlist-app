# Phase4 KPI Aggregator README

Overview
--------
This component reads `RUNS_SUMMARY.json` under a reports directory and computes KPI metrics:
- total_runs
- success_count / success_rate
- p50 / p90 latency (ms)
- failures list

CLI
---
Usage:

```bash
node scripts/phase4/kpi/aggregate.ts --base-dir ./docs/reports/2025-11-14 --window-days 7 --dry-run
```

Flags:
- `--base-dir`: base report directory (default: `docs/reports/<JST date>`)
- `--window-days`: lookback window in days (default 7)
- `--dry-run`: do not write output files, only log metrics

Outputs
-------
- `PHASE3_AUDIT_SUMMARY.json` — machine-readable KPI output
- `PHASE3_AUDIT_SUMMARY.md` — human-readable summary

Acceptance
----------
- `npx vitest tests/phase4/kpi.spec.ts` passes
- `node scripts/phase4/kpi/aggregate.ts --base-dir ./tests/fixtures/kpi --dry-run` logs `kpiComputed`
- Dry-run does not create files; normal run creates both `.json` and `.md`


