#!/bin/bash
# Phase 3 Setup Commands
# Copy-pasteable commands for Phase 3 setup and testing

set -euo pipefail

echo "🚀 Phase 3 Audit Observer Setup Commands"
echo "========================================"
echo ""

# 1. Create branch
echo "1. Creating feature branch..."
git checkout -b feature/phase3-audit-observer || git checkout feature/phase3-audit-observer
echo "✅ Branch created/checked out"
echo ""

# 2. Add files
echo "2. Adding files..."
git add .github/workflows/phase3-audit-observer.yml
git add scripts/observe_phase3.sh
git add supabase/ops/slsa_audit_metrics_table.sql
git add docs/reports/PHASE3_AUDIT_SUMMARY.md
git add docs/ops/PHASE3_RUNBOOK.md
echo "✅ Files staged"
echo ""

# 3. Commit
echo "3. Committing changes..."
git commit -m "feat(ops): Phase 3 Audit Observer implementation

- Add phase3-audit-observer.yml workflow
- Add observe_phase3.sh script
- Add slsa_audit_metrics_table.sql DDL
- Add PHASE3_AUDIT_SUMMARY.md template
- Add PHASE3_RUNBOOK.md documentation

Implements Phase 3 audit observer for SLSA Provenance validation:
- SHA256 integrity verification
- PredicateType validation
- Supabase integration verification
- Automatic PR comments on success"
echo "✅ Changes committed"
echo ""

# 4. Push
echo "4. Pushing to remote..."
git push origin feature/phase3-audit-observer
echo "✅ Branch pushed"
echo ""

# 5. Create PR
echo "5. Creating PR..."
gh pr create \
  --title "feat(ops): Phase 3 Audit Observer Implementation" \
  --body "## Phase 3 Audit Observer Implementation

This PR implements Phase 3 Audit Observer for SLSA Provenance validation.

### Changes

- ✅ \`.github/workflows/phase3-audit-observer.yml\` - Audit observer workflow
- ✅ \`scripts/observe_phase3.sh\` - Local audit script
- ✅ \`supabase/ops/slsa_audit_metrics_table.sql\` - Audit metrics table DDL
- ✅ \`docs/reports/PHASE3_AUDIT_SUMMARY.md\` - Audit summary template
- ✅ \`docs/ops/PHASE3_RUNBOOK.md\` - Runbook documentation

### Features

- SHA256 integrity verification
- PredicateType validation (\`https://slsa.dev/provenance/v0.2\`)
- Supabase integration verification
- Automatic PR comments on successful validation
- Failure notifications (GitHub Issues + Slack)

### Testing

After merge, the workflow will:
1. Run automatically on \`slsa-provenance\` and \`provenance-validate\` completion
2. Run daily at 00:00 UTC
3. Can be triggered manually via GitHub UI or CLI

### Required Secrets

- \`SUPABASE_URL\`
- \`SUPABASE_SERVICE_KEY\`
- \`SLACK_WEBHOOK_URL\` (optional)

### Next Steps

1. Set required secrets in repository settings
2. Merge PR
3. Verify workflow runs automatically
4. Test manual execution
5. Proceed to Phase 4 (Telemetry & KPI Dashboard)" \
  --base main
echo "✅ PR created"
echo ""

# 6. Wait for checks
echo "6. Waiting for checks to complete..."
echo "⏳ Please wait for GitHub Actions to complete..."
echo ""

# 7. Test commands
echo "7. Test commands (after PR merge):"
echo ""
echo "# Test manual execution"
echo "gh workflow run phase3-audit-observer.yml"
echo ""
echo "# Test with specific runs"
echo "gh workflow run phase3-audit-observer.yml \\"
echo "  -f provenance_run_id=123456789 \\"
echo "  -f validation_run_id=987654321 \\"
echo "  -f pr_number=61"
echo ""
echo "# Run script locally"
echo "export SUPABASE_URL=\"your-url\""
echo "export SUPABASE_SERVICE_KEY=\"your-key\""
echo "export PR_NUMBER=61"
echo "./scripts/observe_phase3.sh"
echo ""

echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Review PR"
echo "2. Set required secrets"
echo "3. Merge PR"
echo "4. Verify workflow runs"
echo "5. Test manual execution"
