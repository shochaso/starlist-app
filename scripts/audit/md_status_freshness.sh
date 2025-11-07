#!/usr/bin/env bash

set -euo pipefail

ROOT="${1:-docs}"
SINCE="${2:-7.days}"

echo "=== Potentially stale Status (planned but recently modified) ==="
while IFS= read -r -d '' f; do
  status=$(grep -E '^Status:: ' "$f" | head -n1 | sed -E 's/^Status::\s*//')
  if [[ "$status" == "planned" ]]; then
    # 直近コミット有無チェック（git必須）
    if git log --since="$SINCE" --pretty=format:%h -- "$f" | head -n1 | grep -q .; then
      echo "PLANNED but modified recently: $f"
    fi
  fi
done < <(find "$ROOT" -type f -name "*.md" ! -path "*/node_modules/*" ! -path "*/repository/*" -print0)
