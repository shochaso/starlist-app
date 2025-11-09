# Pricing Final Shortcut Guide

## Overview

`PRICING_FINAL_SHORTCUT.sh` is an automated end-to-end validation script for the pricing recommendation feature.

## Usage

### Via npm script

```bash
npm run pricing:final
```

### Direct execution

```bash
chmod +x PRICING_FINAL_SHORTCUT.sh
./PRICING_FINAL_SHORTCUT.sh
```

## Prerequisites

### Required Environment Variables

- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_ANON_KEY` - Supabase anonymous key

### Optional Environment Variables

- `DATABASE_URL` - PostgreSQL connection string (for direct DB checks)
- `STRIPE_API_KEY` - Stripe API key (for Stripe CLI operations)

### Required Tools

- `bash` >= 5.0
- `stripe` CLI (optional, for Stripe validation)
- `psql` (optional, for direct DB checks)
- `flutter` (optional, for Flutter tests)

## Execution Flow

1. **Environment Check**
   - Validates `SUPABASE_URL` and `SUPABASE_ANON_KEY`
   - Checks for required tools

2. **Stripe CLI Validation**
   - Verifies Stripe CLI is installed and working
   - Skips if not available

3. **DB Validation**
   - Checks `subscriptions.plan_price` is integer (if `DATABASE_URL` available)
   - Falls back to Supabase Dashboard instructions if not available

4. **Flutter Tests**
   - Runs `flutter test --no-pub`
   - Skips if Flutter not available

5. **Webhook Validation**
   - Executes `PRICING_WEBHOOK_VALIDATION.sh` if present
   - Validates webhook secrets, deployment, and DB reflection

6. **Acceptance Tests**
   - Executes `PRICING_ACCEPTANCE_TEST.sh` if present
   - Runs unit and E2E test checklist

7. **Success Trail Confirmation**
   - Manual confirmation of 4 success criteria:
     - UI: Recommendation badge display, validation works
     - DB: `plan_price` saved as integer yen
     - Webhook: Events trigger and reflect `plan_price` updates
     - Logs: Supabase Functions return 200, no exceptions

8. **Go/No-Go Decision**
   - Final manual confirmation
   - Exit code 0 on Go, 1 on No-Go

## Exit Codes

- `0` - Success (all checks passed, Go decision)
- `1` - Failure (any check failed or No-Go decision)
- `11` - Missing required environment variable
- `12` - Missing required binary

## Error Handling

The script uses `set -euo pipefail` for strict error handling:
- `-e` - Exit immediately on error
- `-u` - Exit on undefined variable
- `-o pipefail` - Exit on pipe failure

## Summary Output

After successful execution, the script outputs:

```
📊 実行サマリ:
  ✅ Stripe CLI: Ready
  ✅ DB確認: plan_price integer check passed
  ✅ Flutter test: All tests passed
  ✅ Webhook検証: Passed
  ✅ 受け入れテスト: Passed

Exit code: 0 (Success)
```

## Troubleshooting

### Stripe CLI not found

Install Stripe CLI:
```bash
# macOS
brew install stripe/stripe-cli/stripe

# Linux
# See: https://stripe.com/docs/stripe-cli
```

### Flutter tests fail

Check Flutter test output:
```bash
flutter test --no-pub -v
```

### DB connection fails

Use Supabase Dashboard to verify:
1. Go to Supabase Dashboard > Database
2. Check `subscriptions` table
3. Verify `plan_price` column contains integers only

## Related Files

- `PRICING_WEBHOOK_VALIDATION.sh` - Webhook validation script
- `PRICING_ACCEPTANCE_TEST.sh` - Acceptance test script
- `PRICING_FLUTTER_INTEGRATION.md` - Flutter integration guide
- `PRICING_TROUBLESHOOTING.md` - Troubleshooting guide

---

**Last Updated**: 2025-11-08
**Maintainer**: SRE Team

