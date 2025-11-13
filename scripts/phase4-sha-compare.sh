#!/usr/bin/env bash
# Phase 4 SHA Parity Checker
# Usage: scripts/phase4-sha-compare.sh <artifact_file> <provenance_metadata_json> [--run-id <RUN_ID>]
# Output: key=value pairs on a single line (run_id, metadata_sha, computed_sha, sha_parity)

set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <artifact_file> <provenance_metadata_json> [--run-id <RUN_ID>]" >&2
  exit 1
fi

ARTIFACT_PATH="$1"
PROVENANCE_PATH="$2"
shift 2

RUN_ID="unknown"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --run-id)
      RUN_ID="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [ ! -f "$ARTIFACT_PATH" ]; then
  echo "Artifact not found: $ARTIFACT_PATH" >&2
  exit 1
fi

if [ ! -f "$PROVENANCE_PATH" ]; then
  echo "Provenance metadata not found: $PROVENANCE_PATH" >&2
  exit 1
fi

COMPUTED_SHA=$(sha256sum "$ARTIFACT_PATH" | awk '{print $1}')

METADATA_SHA=$(jq -r '
  (
    .metadata.content_sha256 //
    (.subject // [] | map(.digest.sha256) | .[0]) //
    (.predicate.materials // [] | map(.digest.sha256) | .[0])
  ) // empty
' "$PROVENANCE_PATH")

if [ -z "$METADATA_SHA" ] || [ "$METADATA_SHA" = "null" ]; then
  echo "metadata.content_sha256 または subject.digest.sha256 を取得できませんでした: $PROVENANCE_PATH" >&2
  exit 1
fi

if [ "$METADATA_SHA" = "$COMPUTED_SHA" ]; then
  PARITY="true"
else
  PARITY="false"
fi

printf 'run_id=%s metadata_sha=%s computed_sha=%s sha_parity=%s\n' "$RUN_ID" "$METADATA_SHA" "$COMPUTED_SHA" "$PARITY"
