# Branch Protection Required Checks

## provenance-validate.yml Registration

The `provenance-validate.yml` workflow should be registered as a required check in branch protection rules.

### Manual Registration Steps

1. Go to Repository Settings → Branches → Branch protection rules
2. Edit protection rule for `main` branch
3. Under "Require status checks to pass before merging":
   - Add `provenance-validate` as a required check
   - Ensure it appears in the list of required checks

### Verification

```bash
# Check if provenance-validate is required
gh api repos/:owner/:repo/branches/main/protection | jq '.required_status_checks.contexts'
```

### Expected Output

```json
[
  "build",
  "check",
  "provenance-validate"
]
```

## Notes

- This check ensures that all provenance artifacts are validated before merging to main
- The check runs automatically after `slsa-provenance.yml` completes
- Manual dispatch is also supported for re-validation
