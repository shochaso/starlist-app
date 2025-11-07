#!/usr/bin/env bash

set -euo pipefail

ROOT="${1:-docs}"
DATE="$(TZ=Asia/Tokyo date +%Y-%m-%d)"

# 空のStatus値を修正
fix_empty_status() {
  local file="$1"
  local tmp="$(mktemp)"
  
  # 空のStatus::行を修正（コロン1つまたは2つに対応）
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -E '1,100s/^Status::?\s*$/Status:: planned/' "$file" | \
    sed -E '1,100s/^Source-of-Truth::?\s*$/Source-of-Truth:: (TBD)/' | \
    sed -E '1,100s/^Spec-State::?\s*$/Spec-State:: 初期案/' | \
    sed -E "1,100s/^Last-Updated::?\s*$/Last-Updated:: ${DATE}/" > "$tmp"
  else
    sed -E '1,100s/^Status::?\s*$/Status:: planned/; 1,100s/^Source-of-Truth::?\s*$/Source-of-Truth:: (TBD)/; 1,100s/^Spec-State::?\s*$/Spec-State:: 初期案/; 1,100s/^Last-Updated::?\s*$/Last-Updated:: '"${DATE}"'/' "$file" > "$tmp"
  fi
  
  mv "$tmp" "$file"
  echo "FIXED: $file"
}

export -f fix_empty_status

# 空のStatus値を持つファイルを修正（コロン1つまたは2つに対応）
find "$ROOT" -type f -name "*.md" ! -path "*/node_modules/*" ! -path "*/repository/*" \
  -print0 | while IFS= read -r -d '' f; do
  if grep -qE '^Status::?\s*$' "$f"; then
    fix_empty_status "$f"
  fi
done

