# Phase4 WS01-WS05 Verification Steps

## Prerequisites
- Node.js 18+ (tested with Node 20)
- npm installed

## Step 1: Install Dependencies
\`\`\`bash
npm ci
\`\`\`
**Expected**: Dependencies installed successfully

## Step 2: Run Unit Tests
\`\`\`bash
npm test
\`\`\`
**Expected Output**:
- Test Files: 6 passed
- Tests: 27+ passed
- All Phase4 tests green

## Step 3: Dry-Run Observer
\`\`\`bash
npm run phase4:observer -- --dry-run
\`\`\`
**Expected Output**: JSON lines including:
- `{"event":"dry_run",...}`
- `{"event":"shaCompare","match":true,"note":"provenance_missing_or_empty_using_computed",...}`

## Step 4: Security Sweep
\`\`\`bash
npm run phase4:sweep -- docs/reports/2025-11-14
\`\`\`
**Expected Output**:
- Exit code: 0 (clean) or 2 (tokens found)
- JSON: `{"event":"sweepClean"}` or `{"event":"sweepFound",...}`

## Step 5: Telemetry Guard Test
\`\`\`bash
# Without secrets
unset SUPABASE_SERVICE_KEY
npm run phase4:observer -- --dry-run 2>&1 | grep -i "ci-guard" || echo "Guard check passed"

# With stub secret
SUPABASE_SERVICE_KEY=stub SUPABASE_URL=https://test.supabase.co npm run phase4:observer -- --dry-run
\`\`\`
**Expected**: No errors, dry-run completes

## Git Commands
\`\`\`bash
git add -A
git commit -m "fix(phase4): enhance telemetry with Supabase client integration"
git push -u origin feat/phase4-auto-audit-20251114
\`\`\`

## Create PR
\`\`\`bash
gh pr create --base main --head feat/phase4-auto-audit-20251114 \
  --title "feat(phase4): Automated Audit & Self-Heal — WS01–WS05" \
  --body-file PR_BODY_PHASE4.md
\`\`\`
