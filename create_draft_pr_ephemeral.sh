#!/usr/bin/env bash
<<<<<<< HEAD
set -euo pipefail
BRANCH="${1:?Usage: $0 <branch-name>}"
TMP_BODY="$(mktemp -t pr_body.XXXXXX.md)"

cat >"$TMP_BODY" <<'EOF'
# chore(security): bootstrap extended security workflow

## Summary
- add workflow_dispatch-enabled extended security pipeline (SBOM / Semgrep / Trivy)
- include helper runner + draft PR script for manual dispatch and artifact collection
- introduce baseline `.semgrep.yml` and `.trivyignore` for noise reduction during observation

## Testing
- Manual workflow dispatch planned after merge
EOF

gh pr create \
  --title "chore(security): bootstrap extended security workflow" \
  --body-file "$TMP_BODY" \
  --base main \
  --head "$BRANCH" \
  --draft

rm -f "$TMP_BODY"
=======
# create_draft_pr_ephemeral.sh
set -euo pipefail
command -v gh >/dev/null 2>&1 || { echo "gh not found"; exit 1; }

TS="$(TZ='Asia/Tokyo' date +%Y%m%d-%H%M%S)"
BASE="${BASE_BRANCH:-main}"
BR="ephemeral/security-verify-${TS}"

git fetch origin --prune
git checkout -b "$BR" "origin/$BASE"

if ! git diff --quiet; then
  git add -A
  git commit -m "chore(security): ephemeral verification run $TS"
fi

git push -u origin "$BR"

TITLE="Security verification (ephemeral) — $BR"
BODY="$(cat <<'EOT'
目的: セキュリティ検証のDraft PR（deno fmt/lint/test, semgrep, trivy, playwright, RLS）
- 実行ログは docs/reports/OPS-SUMMARY-LOGS.md に追記
- 失敗ジョブは先頭20行を次コメントに貼付予定
マージ方針: Merge commit（履歴保全）
EOT
)"
gh pr create --draft --base "$BASE" --head "$BR" --title "$TITLE" --body "$BODY"
echo "Draft PR created for $BR"
>>>>>>> 8abb626 (feat(ops): add ultra pack enhancements — Makefile, audit bundle, risk register, RACI matrix)
