#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-docs}"
EXIT=0

find "$ROOT" -type f -name "*.md" ! -path "*/node_modules/*" ! -path "*/repository/*" -print0 \
  | while IFS= read -r -d '' f; do
      head="$(head -n 100 "$f")"
      miss=()
      grep -qE '^Status:: ' <<<"$head" || miss+=("Status::")
      grep -qE '^Source-of-Truth:: ' <<<"$head" || miss+=("Source-of-Truth::")
      grep -qE '^Spec-State:: ' <<<"$head" || miss+=("Spec-State::")
      grep -qE '^Last-Updated:: ' <<<"$head" || miss+=("Last-Updated::")
      if ((${#miss[@]})); then
        printf "MISSING: %s -> %s\n" "$f" "${miss[*]}"
        EXIT=1
      else
        status=$(grep -E '^Status:: ' "$f" | head -n1 | sed -E 's/^Status::\s*//')
        if [[ -n "$status" ]] && ! [[ "$status" =~ ^(planned|in-progress|aligned-with-Flutter)$ ]]; then
          echo "INVALID Status: $f -> '$status'"
          EXIT=1
        fi
      fi
    done

exit $EXIT
