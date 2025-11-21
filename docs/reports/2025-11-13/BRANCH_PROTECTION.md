---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# Branch Protection Configuration

**Purpose**: Guide for configuring branch protection with provenance-validate as required check.

**Last Updated**: 2025-11-13 (UTC)

---

## Current Status

**Branch**: `main`
**Required Checks**: `provenance-validate` (added)
**Strict Mode**: Enabled

---

## GUI Method

### Step-by-Step Instructions

1. **Navigate to Repository Settings**
   - Go to: https://github.com/shochaso/starlist-app/settings/branches

2. **Edit Branch Protection Rule**
   - Find `main` branch in the list
   - Click "Edit" button

3. **Add Required Status Checks**
   - Scroll to "Require status checks to pass before merging"
   - Check the box to enable
   - Check "Require branches to be up to date before merging" (strict mode)
   - In the search box, type: `provenance-validate`
   - Select `provenance-validate` from the dropdown
   - Click "Save changes"

4. **Verify Configuration**
   - Confirm `provenance-validate` appears in required checks list
   - Verify "Require branches to be up to date" is enabled

---

## API Method

### Current Configuration

```bash
# Get current protection settings
gh api repos/shochaso/starlist-app/branches/main/protection \
  --jq '.required_status_checks'
```

### Update Configuration

```bash
# Update branch protection (example)
gh api repos/shochaso/starlist-app/branches/main/protection \
  -X PATCH \
  -f required_status_checks[strict]=true \
  -f required_status_checks[contexts][]=build \
  -f required_status_checks[contexts][]=check \
  -f required_status_checks[contexts][]=provenance-validate \
  -f required_pull_request_reviews[required_approving_review_count]=1 \
  -f enforce_admins=false \
  -f required_linear_history=false \
  -f allow_force_pushes=false \
  -f allow_deletions=false
```

### Verification

```bash
# Verify provenance-validate is in required checks
gh api repos/shochaso/starlist-app/branches/main/protection \
  --jq '.required_status_checks.contexts' | grep -q "provenance-validate" && \
  echo "✅ provenance-validate is required" || \
  echo "❌ provenance-validate not found"
```

---

## Configuration Record

**Date**: 2025-11-13
**Operator**: [記録]
**Method**: GUI / API
**Before**: No required status checks
**After**: `provenance-validate` required

**Full Configuration**:
```json
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["provenance-validate"]
  },
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "require_code_owner_reviews": false
  },
  "enforce_admins": false,
  "required_linear_history": false,
  "allow_force_pushes": false,
  "allow_deletions": false
}
```

---

## Rollback Procedure

If branch protection causes issues:

1. **Remove Required Check via GUI**
   - Go to Settings → Branches
   - Edit `main` branch protection
   - Uncheck `provenance-validate`
   - Save changes

2. **Remove Required Check via API**
   ```bash
   gh api repos/shochaso/starlist-app/branches/main/protection \
     -X PATCH \
     -f required_status_checks[contexts][]=build \
     -f required_status_checks[contexts][]=check
   # Note: Omit provenance-validate from contexts array
   ```

3. **Disable Branch Protection** (temporary)
   ```bash
   gh api repos/shochaso/starlist-app/branches/main/protection \
     -X DELETE
   ```

---

## Verification Checklist

- [ ] `provenance-validate` appears in required checks
- [ ] Strict mode is enabled
- [ ] PRs cannot merge without `provenance-validate` passing
- [ ] Configuration persisted after repository restart

---

**Note**: This configuration ensures that provenance validation must pass before merging to `main`.

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
