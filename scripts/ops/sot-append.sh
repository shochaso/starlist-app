#!/usr/bin/env bash
set -euo pipefail

FILE=docs/reports/DAY12_SOT_DIFFS.md

if [ $# -lt 1 ]; then
  echo "usage: $0 <pr-number> [<pr-number> ...]"
  exit 1
fi

# Ensure we're on main and up to date
git checkout main
git pull --rebase origin main

# Ensure SOT file exists
if [ ! -f "$FILE" ]; then
  mkdir -p "$(dirname "$FILE")"
  echo "# Day12 SOT DIFFS" > "$FILE"
  echo "" >> "$FILE"
fi

# Append each PR URL
for PR in "$@"; do
  URL=$(gh pr view "$PR" --json url --jq .url 2>/dev/null || echo "")
  if [ -z "$URL" ]; then
    echo "[warn] PR #$PR URL not found, skipping"
    continue
  fi
  TS=$(date "+%Y-%m-%d %H:%M:%S JST")
  echo "* merged: $URL  ($TS)" >> "$FILE"
done

# Commit and push
git add "$FILE"
git commit -m "chore(reports): SOT append for PR(s): $*"
git push origin main

echo "✅ SOT updated for PR(s): $*"
