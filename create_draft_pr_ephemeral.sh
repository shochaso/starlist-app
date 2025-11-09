#!/usr/bin/env bash
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
