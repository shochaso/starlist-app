#!/usr/bin/env bash
set -euo pipefail

BR="${1:-feature/ui-only-supplement-v2}"

MSG="docs(ops): add UI-Only Supplement Pack v2 — Playbook / Checklist / Audit"

git fetch origin main

git checkout -b "$BR"

git add docs/UI-ONLY_SUPPLEMENT_PACK_V2

git commit -m "$MSG" || true

git push -u origin "$BR"

# ephemeral draft PR body (do not modify tracked files)
tmp_body="$(mktemp -t pr_body.XXXXXX.md)"

cat > "$tmp_body" <<'PRMD'
# docs(ops): add UI-Only Supplement Pack v2 — Playbook / Checklist / Audit

Adds Playbook, PR checklist, audit schema and summary for UI-only operations (docs/ only).

Evidence (attach logs/screenshots under docs/ops/audit/ before merging).
PRMD

gh pr create --title "$MSG" --body-file "$tmp_body" --base main --head "$BR" --draft --label docs --label ops

rm -f "$tmp_body"

echo "Draft PR created for branch: $BR"

