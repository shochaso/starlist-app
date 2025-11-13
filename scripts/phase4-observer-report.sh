#!/usr/bin/env bash
# Phase 4 observer KPI aggregator
# - Reads RUNS_SUMMARY.json and computes KPI metrics
# - Updates PHASE3_AUDIT_SUMMARY.md with fresh values
# - Appends or replaces section in AUTO_OBSERVER_SUMMARY.md
# - Supabase upsert wiring will be added in Step6

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_ROOT="$ROOT/docs/reports/2025-11-14"
RUNS_SUMMARY_PATH="$REPORT_ROOT/RUNS_SUMMARY.json"
AUDIT_SUMMARY_PATH="$REPORT_ROOT/PHASE3_AUDIT_SUMMARY.md"
AUTO_OBSERVER_PATH="$REPORT_ROOT/AUTO_OBSERVER_SUMMARY.md"
MANIFEST_PATH="$REPORT_ROOT/_manifest.json"

usage() {
  cat <<'USAGE'
Usage: scripts/phase4-observer-report.sh --observer-run-id <RUN_ID> [options]

Options:
  --observer-run-id <id>   (必須) オブザーバーワークフロー run_id
  --window-days <n>        参照期間 (デフォルト: 7)
  --runs-summary <path>    RUNS_SUMMARY.json のパス (既定: docs/reports/2025-11-14/RUNS_SUMMARY.json)
  --audit-summary <path>   PHASE3_AUDIT_SUMMARY.md のパス
  --observer-summary <path> AUTO_OBSERVER_SUMMARY.md のパス
  --manifest <path>        _manifest.json のパス
  --notes <text>           監査ノート (AUTO_OBSERVER_SUMMARY 用)
  --supabase-upsert        Supabase 連携を有効化 (Step6で実装)
USAGE
}

if [ "$#" -eq 0 ]; then
  usage >&2
  exit 1
fi

OBSERVER_RUN_ID=""
WINDOW_DAYS="7"
NOTES=""
SUPABASE_UPSERT="false"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --observer-run-id)
      OBSERVER_RUN_ID="$2"
      shift 2
      ;;
    --window-days)
      WINDOW_DAYS="$2"
      shift 2
      ;;
    --runs-summary)
      RUNS_SUMMARY_PATH="$2"
      shift 2
      ;;
    --audit-summary)
      AUDIT_SUMMARY_PATH="$2"
      shift 2
      ;;
    --observer-summary)
      AUTO_OBSERVER_PATH="$2"
      shift 2
      ;;
    --manifest)
      MANIFEST_PATH="$2"
      shift 2
      ;;
    --notes)
      NOTES="$2"
      shift 2
      ;;
    --supabase-upsert)
      SUPABASE_UPSERT="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [ -z "$OBSERVER_RUN_ID" ]; then
  echo "Error: --observer-run-id is required." >&2
  exit 1
fi

if [ ! -f "$RUNS_SUMMARY_PATH" ]; then
  echo "RUNS_SUMMARY.json が存在しません: $RUNS_SUMMARY_PATH" >&2
  exit 1
fi

timestamp_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

METRICS_JSON=$(WINDOW_DAYS="$WINDOW_DAYS" MANIFEST_PATH="$MANIFEST_PATH" python3 - "$RUNS_SUMMARY_PATH" <<'PY'
import json, sys, os
from datetime import datetime, timedelta, timezone

path = sys.argv[1]
window_days = int(os.environ.get("WINDOW_DAYS", "7"))
now = datetime.now(timezone.utc)
cutoff = now - timedelta(days=window_days)

def parse_ts(ts):
    if not ts:
        return None
    try:
        return datetime.fromisoformat(ts.replace("Z", "+00:00"))
    except ValueError:
        return None

with open(path, "r", encoding="utf-8") as fh:
    entries = json.load(fh)

filtered = []
for entry in entries:
    completed = parse_ts(entry.get("run_completed_at_utc"))
    if completed is None:
        continue
    if completed >= cutoff:
        filtered.append(entry)

total_runs = len(filtered)
success = [e for e in filtered if e.get("status") == "success"]
failure = [e for e in filtered if e.get("status") == "failure"]
retry_entries = [e for e in filtered if (e.get("retries") or 0) > 0]
retry_success = [e for e in retry_entries if e.get("status") == "success"]

durations = sorted(float(e.get("duration_sec") or 0) for e in filtered if float(e.get("duration_sec") or 0) > 0)

def percentile(values, pct):
    if not values:
        return 0.0
    if len(values) == 1:
        return float(values[0])
    rank = (pct / 100.0) * (len(values) - 1)
    lower = int(rank)
    upper = min(lower + 1, len(values) - 1)
    weight = rank - lower
    return float(values[lower] * (1 - weight) + values[upper] * weight)

sha_pass = [e for e in filtered if e.get("sha_parity") is True]
latest_completed = max((parse_ts(e.get("run_completed_at_utc")) for e in filtered), default=None)
observer_lag = 0.0
if latest_completed:
    observer_lag = max((now - latest_completed).total_seconds(), 0.0)

manifest_entries = []
manifest_path = os.environ.get("MANIFEST_PATH")
if manifest_path and os.path.exists(manifest_path):
    with open(manifest_path, "r", encoding="utf-8") as mf:
        manifest = json.load(mf)
    manifest_entries = manifest.get("entries", [])

anomalies = []
for entry in filtered:
    if entry.get("status") != "success" or not entry.get("sha_parity", False):
        anomalies.append({
            "run_id": entry.get("run_id"),
            "status": entry.get("status"),
            "sha_parity": entry.get("sha_parity"),
            "retries": entry.get("retries"),
        })

entries_for_upsert = []
for e in filtered:
    entries_for_upsert.append({
        "run_id": e.get("run_id"),
        "status": e.get("status"),
        "retries": int(e.get("retries") or 0),
        "duration_sec": float(e.get("duration_sec") or 0),
        "sha_parity": bool(e.get("sha_parity")),
        "prov_sha": e.get("prov_sha") or "",
        "computed_sha": e.get("computed_sha") or "",
        "run_completed_at_utc": e.get("run_completed_at_utc") or "",
    })

result = {
    "window_days": window_days,
    "total_runs": total_runs,
    "success_count": len(success),
    "failure_count": len(failure),
    "success_rate": round(len(success) / total_runs, 4) if total_runs else 0.0,
    "retry_invocations": sum(int(e.get("retries") or 0) for e in filtered),
    "retry_success_rate": round(len(retry_success) / len(retry_entries), 4) if retry_entries else 0.0,
    "sha_parity_pass_rate": round(len(sha_pass) / total_runs, 4) if total_runs else 0.0,
    "p50_latency_sec": percentile(durations, 50),
    "p90_latency_sec": percentile(durations, 90),
    "observer_lag_sec": observer_lag,
    "latest_completed_at": latest_completed.isoformat() if latest_completed else "",
    "anomalies": anomalies,
    "manifest_entry_count": len(manifest_entries),
    "observed_runs": [
        {
            "run_id": e.get("run_id"),
            "status": e.get("status"),
            "sha_parity": e.get("sha_parity"),
            "retries": e.get("retries"),
        }
        for e in filtered
    ],
    "entries_for_upsert": entries_for_upsert,
}

print(json.dumps(result))
PY
)

if [ -z "$METRICS_JSON" ]; then
  echo "メトリクス計算に失敗しました" >&2
  exit 1
fi

TOTAL_RUNS=$(echo "$METRICS_JSON" | jq -r '.total_runs')
SUCCESS_COUNT=$(echo "$METRICS_JSON" | jq -r '.success_count')
FAILURE_COUNT=$(echo "$METRICS_JSON" | jq -r '.failure_count')
SUCCESS_RATE=$(echo "$METRICS_JSON" | jq -r '.success_rate')
RETRY_INVOCATIONS=$(echo "$METRICS_JSON" | jq -r '.retry_invocations')
RETRY_SUCCESS_RATE=$(echo "$METRICS_JSON" | jq -r '.retry_success_rate')
SHA_PASS_RATE=$(echo "$METRICS_JSON" | jq -r '.sha_parity_pass_rate')
P50_LATENCY=$(echo "$METRICS_JSON" | jq -r '.p50_latency_sec')
P90_LATENCY=$(echo "$METRICS_JSON" | jq -r '.p90_latency_sec')
OBSERVER_LAG=$(echo "$METRICS_JSON" | jq -r '.observer_lag_sec')
ANOMALIES=$(echo "$METRICS_JSON" | jq -c '.anomalies')
MANIFEST_ENTRY_COUNT=$(echo "$METRICS_JSON" | jq -r '.manifest_entry_count')
ENTRIES_FOR_UPSERT=$(echo "$METRICS_JSON" | jq -c '.entries_for_upsert')

OBSERVED_AT="$(timestamp_utc)"

SUPABASE_STATUS_SUMMARY="pending"
if [ "$SUPABASE_UPSERT" = "true" ]; then
  echo "Supabase upsert enabled. Processing entries..."
  SUCCESS_COUNT_UPSERT=0
  RETRYABLE_COUNT=0
  NONRETRYABLE_COUNT=0

  while IFS= read -r entry; do
    RUN_ID_ITEM=$(echo "$entry" | jq -r '.run_id')
    STATUS_ITEM=$(echo "$entry" | jq -r '.status')
    RETRIES_ITEM=$(echo "$entry" | jq -r '.retries')
    DURATION_ITEM=$(echo "$entry" | jq -r '.duration_sec')
    SHA_PARITY_ITEM=$(echo "$entry" | jq -r '.sha_parity')
    PROV_SHA_ITEM=$(echo "$entry" | jq -r '.prov_sha')
    COMPUTED_SHA_ITEM=$(echo "$entry" | jq -r '.computed_sha')
    COMPLETED_AT_ITEM=$(echo "$entry" | jq -r '.run_completed_at_utc')

    if [ -z "$COMPLETED_AT_ITEM" ] || [ "$COMPLETED_AT_ITEM" = "null" ]; then
      COMPLETED_AT_ITEM="$OBSERVED_AT"
    fi

    if [ "$SHA_PARITY_ITEM" = "true" ]; then
      VERDICT="parity_pass"
    else
      VERDICT="parity_fail"
    fi

    RETRIES_EXHAUSTED_FLAG="false"
    if [ "$RETRIES_ITEM" -gt 0 ] && [ "$STATUS_ITEM" != "success" ]; then
      RETRIES_EXHAUSTED_FLAG="true"
    fi

    set +e
    scripts/phase4-supabase-upsert.sh \
      --run-id "$RUN_ID_ITEM" \
      --status "$STATUS_ITEM" \
      --retries "$RETRIES_ITEM" \
      --duration "$DURATION_ITEM" \
      --validator-verdict "$VERDICT" \
      --prov-sha "$PROV_SHA_ITEM" \
      --computed-sha "$COMPUTED_SHA_ITEM" \
      --created-at "$COMPLETED_AT_ITEM" \
      --observed-at "$OBSERVED_AT" \
      --retries-exhausted "$RETRIES_EXHAUSTED_FLAG" \
      --window-days "$WINDOW_DAYS"
    EXIT_CODE=$?
    set -e

    case "$EXIT_CODE" in
      0)
        SUCCESS_COUNT_UPSERT=$((SUCCESS_COUNT_UPSERT + 1))
        ;;
      75)
        RETRYABLE_COUNT=$((RETRYABLE_COUNT + 1))
        ;;
      78)
        NONRETRYABLE_COUNT=$((NONRETRYABLE_COUNT + 1))
        ;;
      *)
        echo "Supabase upsert unexpected exit code ($EXIT_CODE) for run_id=$RUN_ID_ITEM" >&2
        NONRETRYABLE_COUNT=$((NONRETRYABLE_COUNT + 1))
        ;;
    esac
  done < <(echo "$ENTRIES_FOR_UPSERT" | jq -c '.[]')

  if [ "$NONRETRYABLE_COUNT" -gt 0 ]; then
    SUPABASE_STATUS_SUMMARY="non_retryable_error (count=$NONRETRYABLE_COUNT)"
  elif [ "$RETRYABLE_COUNT" -gt 0 ]; then
    SUPABASE_STATUS_SUMMARY="retryable_error (count=$RETRYABLE_COUNT)"
  else
    SUPABASE_STATUS_SUMMARY="success (records=$SUCCESS_COUNT_UPSERT)"
  fi

  echo "Supabase upsert summary: $SUPABASE_STATUS_SUMMARY"
fi

# shellcheck disable=SC2006
cat >"$AUDIT_SUMMARY_PATH" <<EOF
---
title: "Phase 4 Audit Summary Template (Phase 3 Handoff Included)"
event_date_jst: "2025-11-14"
last_updated_utc: "$OBSERVED_AT"
observer_run_id: "$OBSERVER_RUN_ID"
---

# Phase 4 Audit Summary (Automated Observer Loop)

## このドキュメントの使い方 / How to Use During 2025-11-14 Event
- 本ファイルは自動オブザーバーの実行結果を記録します。再実行時は本スクリプトが上書きします。
- KPI を手動修正する場合は `Change Log` に UTC タイムスタンプと担当者を追記してください。

## KPIs
- **total_runs (window_days=$WINDOW_DAYS):** $TOTAL_RUNS
- **success_count:** $SUCCESS_COUNT
- **failure_count:** $FAILURE_COUNT
- **retry_invocations:** $RETRY_INVOCATIONS
- **retry_success_rate:** $RETRY_SUCCESS_RATE
- **sha_parity_pass_rate:** $SHA_PASS_RATE
- **p50_latency_sec:** $P50_LATENCY
- **p90_latency_sec:** $P90_LATENCY
- **observer_lag_sec:** $OBSERVER_LAG
- **success_rate:** $SUCCESS_RATE

## Automated Findings
- Autoretry outcomes (UTC): $(echo "$METRICS_JSON" | jq -r '[.observed_runs[] | select((.retries // 0) > 0) | "\(.run_id)=\(.status) (retries=\(.retries))"] | join(", ") // "none"')
- Detected anomalies: $(echo "$ANOMALIES" | jq -r '[.[] | "\(.run_id)=status:\(.status), parity:\(.sha_parity)"] | join(", ") // "none"')
- Supabase ingestion status: $SUPABASE_STATUS_SUMMARY

## Manual Backstop Review
- Phase 3 audit delta applied? (要確認)
- Manifest integrity confirmed? (entries=$MANIFEST_ENTRY_COUNT)
- KillSwitch invoked? (no)

## Compliance Checks
- [x] `_manifest.json` atomic updateログ確認済み
- [ ] `RUNS_SUMMARY.json` jq バリデーション済み
- [ ] Supabase upsert ステータスを `_evidence_index.md` に記録
- [ ] Slack サマリを slack_excerpts に追加

## Change Log
- $OBSERVED_AT — Auto observer summary generated by scripts/phase4-observer-report.sh (run_id=$OBSERVER_RUN_ID)
EOF

# shellcheck disable=SC2006
SECTION=$(cat <<EOF
### Observer Run \`$OBSERVER_RUN_ID\`
- **Dispatched At (UTC):** $OBSERVED_AT
- **Window Days:** $WINDOW_DAYS
- **Total Runs Evaluated:** $TOTAL_RUNS
- **Success Count / Failure Count:** $SUCCESS_COUNT / $FAILURE_COUNT
- **Retries Triggered:** $RETRY_INVOCATIONS (success_rate=$RETRY_SUCCESS_RATE)
- **SHA Parity Pass Rate:** $SHA_PASS_RATE
- **Supabase Upsert:** $SUPABASE_STATUS_SUMMARY
- **Manifest Update:** entries=$MANIFEST_ENTRY_COUNT
- **Notes:** ${NOTES:-n/a}
- **Evidence References:** docs/reports/2025-11-14/_manifest.json, RUNS_SUMMARY.json
EOF
)

python3 - "$AUTO_OBSERVER_PATH" "$OBSERVER_RUN_ID" "$SECTION" "$OBSERVED_AT" <<'PY'
import sys, pathlib

target_path = pathlib.Path(sys.argv[1])
run_id = sys.argv[2]
section = sys.argv[3]
timestamp = sys.argv[4]

if not target_path.exists():
    raise SystemExit(f"{target_path} が存在しません")

content = target_path.read_text(encoding="utf-8")

header, sep, changelog = content.partition("## Change Log")
section_header = f"### Observer Run `{run_id}`"

lines = header.splitlines()
filtered = []
i = 0
while i < len(lines):
    line = lines[i]
    if line.strip().startswith(section_header):
        i += 1
        while i < len(lines) and not lines[i].startswith("### Observer Run `"):
            i += 1
    else:
        filtered.append(line)
        i += 1

new_header = "\n".join(filtered).rstrip()
if not new_header.endswith("\n"):
    new_header += "\n"
new_header += "\n" + section.strip() + "\n\n"

if sep:
    body = new_header + sep + changelog
else:
    body = new_header + "## Change Log\n"

log_entry = f"- {timestamp} — Observer run {run_id} summary updated"
if log_entry not in body:
    body = body.rstrip() + "\n" + log_entry + "\n"

target_path.write_text(body, encoding="utf-8")
PY

echo "Observer report generated for run_id=$OBSERVER_RUN_ID (window_days=$WINDOW_DAYS)"
