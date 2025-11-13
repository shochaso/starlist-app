#!/usr/bin/env bash
# Atomic manifest updater for docs/reports/2025-11-14/_manifest.json
# Usage:
#   scripts/phase4-manifest-atomic.sh --run-id <id> --artifact-path <path>
#                                     --evidence-type <type> --recorded-at <utc>
#                                     [--sha-parity <true|false>] [--notes <text>]
#                                     [--manifest <path>]

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_MANIFEST="$ROOT/docs/reports/2025-11-14/_manifest.json"

RUN_ID=""
ARTIFACT_PATH=""
EVIDENCE_TYPE=""
RECORDED_AT=""
SHA_PARITY=""
NOTES=""
MANIFEST_PATH="$DEFAULT_MANIFEST"

usage() {
  cat <<'USAGE'
Usage: scripts/phase4-manifest-atomic.sh --run-id <id> --artifact-path <path> --evidence-type <type> --recorded-at <UTC> [options]

Options:
  --manifest <path>     Manifest file path (default: docs/reports/2025-11-14/_manifest.json)
  --sha-parity <bool>   true/false/unknown (default: unknown)
  --notes <text>        Additional context (no secrets)
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --run-id)
      RUN_ID="$2"
      shift 2
      ;;
    --artifact-path)
      ARTIFACT_PATH="$2"
      shift 2
      ;;
    --evidence-type)
      EVIDENCE_TYPE="$2"
      shift 2
      ;;
    --recorded-at)
      RECORDED_AT="$2"
      shift 2
      ;;
    --sha-parity)
      SHA_PARITY="$2"
      shift 2
      ;;
    --notes)
      NOTES="$2"
      shift 2
      ;;
    --manifest)
      MANIFEST_PATH="$2"
      shift 2
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

if [ -z "$RUN_ID" ] || [ -z "$ARTIFACT_PATH" ] || [ -z "$EVIDENCE_TYPE" ] || [ -z "$RECORDED_AT" ]; then
  usage >&2
  exit 1
fi

if [ -z "$SHA_PARITY" ]; then
  SHA_PARITY="unknown"
fi

mkdir -p "$(dirname "$MANIFEST_PATH")"

if [ ! -f "$MANIFEST_PATH" ]; then
  cat <<'JSON' >"$MANIFEST_PATH"
{
  "entries": []
}
JSON
fi

TMP_PATH="$(dirname "$MANIFEST_PATH")/.$(basename "$MANIFEST_PATH").tmp"

RUN_ID_VAR="$RUN_ID" \
ARTIFACT_PATH_VAR="$ARTIFACT_PATH" \
EVIDENCE_TYPE_VAR="$EVIDENCE_TYPE" \
RECORDED_AT_VAR="$RECORDED_AT" \
SHA_PARITY_VAR="$SHA_PARITY" \
NOTES_VAR="$NOTES" \
python3 - "$MANIFEST_PATH" "$TMP_PATH" <<'PY'
import json, os, sys, pathlib

manifest_path = pathlib.Path(sys.argv[1])
tmp_path = pathlib.Path(sys.argv[2])

if manifest_path.exists():
    data = json.loads(manifest_path.read_text(encoding="utf-8"))
else:
    data = {"entries": []}

entries = data.get("entries", [])
entries = [entry for entry in entries if entry.get("run_id") != os.environ["RUN_ID_VAR"]]

new_entry = {
    "run_id": os.environ["RUN_ID_VAR"],
    "artifact_path": os.environ["ARTIFACT_PATH_VAR"],
    "evidence_type": os.environ["EVIDENCE_TYPE_VAR"],
    "recorded_at_utc": os.environ["RECORDED_AT_VAR"],
    "sha_parity": os.environ["SHA_PARITY_VAR"],
}

notes = os.environ.get("NOTES_VAR")
if notes:
    new_entry["notes"] = notes

entries.append(new_entry)
entries.sort(key=lambda item: item.get("recorded_at_utc", ""))

data["entries"] = entries

tmp_path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
PY

jq '.' "$TMP_PATH" >/dev/null
mv "$TMP_PATH" "$MANIFEST_PATH"

echo "Manifest updated for run_id=$RUN_ID (path=$MANIFEST_PATH)"
