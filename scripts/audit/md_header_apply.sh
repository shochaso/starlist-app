#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-docs}"
DATE="$(TZ=Asia/Tokyo date +%Y-%m-%d)"

DEFAULT_STATUS="planned"
DEFAULT_SPEC_STATE="初期案"

apply_header() {
  local file="$1"
  local head tmp new_header
  head="$(head -n 100 "$file")"
  tmp="$(mktemp)"
  new_header=""

  if ! grep -qE '^Status:: ' <<<"$head"; then
    new_header+="Status:: ${DEFAULT_STATUS}\n"
  fi
  if ! grep -qE '^Source-of-Truth:: ' <<<"$head"; then
    new_header+="Source-of-Truth:: (TBD)\n"
  fi
  if ! grep -qE '^Spec-State:: ' <<<"$head"; then
    new_header+="Spec-State:: ${DEFAULT_SPEC_STATE}\n"
  fi
  if ! grep -qE '^Last-Updated:: ' <<<"$head"; then
    new_header+="Last-Updated:: ${DATE}\n"
  fi

  if [[ -n "$new_header" ]]; then
    printf "%b\n\n" "$new_header" > "$tmp"
    cat "$file" >> "$tmp"
    mv "$tmp" "$file"
    echo "UPDATED: $file"
  else
    sed -i.bak -E "1,100{s/^Last-Updated:: .*/Last-Updated:: ${DATE}/}" "$file" && rm -f "$file.bak"
    echo "TOUCHED (Last-Updated): $file"
  fi
}

export -f apply_header

find "$ROOT" -type f -name "*.md" ! -path "*/node_modules/*" ! -path "*/repository/*" -print0 \
  | xargs -0 -I{} bash -c 'apply_header "$@"' _ {}
