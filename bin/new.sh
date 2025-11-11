#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: bin/new.sh <STA-123> \"summary\" [base=main]"
  exit 1
fi

ISSUE_KEY="$1"                              # 例: STA-6
SUMMARY="$2"                                # 例: Verify PR linkage
BASE="${3:-main}"

# 例: STA-6-verify-pr-linkage
SLUG="$(echo "$SUMMARY" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')"
BRANCH="${ISSUE_KEY}-${SLUG}"

git fetch origin --prune
git switch -C "$BRANCH" "origin/${BASE}" 2>/dev/null || git switch -c "$BRANCH" "${BASE}"

# 変更のたたき台（なければスキップ可）
mkdir -p docs
touch docs/auto-link-test.md
echo "- ${ISSUE_KEY} ${SUMMARY} $(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> docs/auto-link-test.md

git add -A
git commit -m "feat(${ISSUE_KEY}): ${SUMMARY}"
git push -u origin "$BRANCH"

# PR作成（テンプレに準拠）
gh pr create \
  --title "[${ISSUE_KEY}] ${SUMMARY}" \
  --body "Closes ${ISSUE_KEY}.  
- Purpose: ${SUMMARY}
- DoD: PR→In Progress, Review→In Review, Merge→Done (via Linear)"

echo "✅ Created PR for ${ISSUE_KEY}. Consider requesting review: gh pr edit --add-reviewer @me"

