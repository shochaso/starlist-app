---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# WS06: SHA256 Validation Results

**Date**: 2025-11-13 (UTC)
**Collector**: Cursor AI

---

## Validation Status

**Current Status**: ⏳ Awaiting successful provenance run

**Prerequisites**:
- Successful provenance run completed
- Artifact downloaded
- Tag exists in repository

---

## Validation Procedure

### Step 1: Download Artifact

```bash
RUN_ID=[RUN_ID]
TAG="v2025.11.13-success-test"

gh run download "${RUN_ID}" \
  --name "provenance-${TAG}" \
  --dir /tmp/provenance_validation
```

### Step 2: Extract Values

```bash
ARTIFACT_FILE=$(find /tmp/provenance_validation -name "provenance-*.json" | head -1)

# PredicateType
PREDICATE_TYPE=$(jq -r '.predicateType // empty' "${ARTIFACT_FILE}")

# Content SHA256 (from metadata)
CONTENT_SHA256=$(jq -r '.metadata.content_sha256 // empty' "${ARTIFACT_FILE}")

# File SHA256 (calculated)
FILE_SHA256=$(sha256sum "${ARTIFACT_FILE}" | cut -d' ' -f1)

# Tag commit SHA
TAG_SHA=$(git rev-parse "${TAG}^{commit}" 2>/dev/null || echo "TAG_NOT_FOUND")
```

### Step 3: Validate

```bash
# PredicateType check
if [ "${PREDICATE_TYPE}" = "https://slsa.dev/provenance/v0.2" ]; then
  echo "✅ PredicateType valid"
else
  echo "❌ PredicateType invalid: ${PREDICATE_TYPE}"
fi

# Content SHA256 check
if [ "${CONTENT_SHA256}" = "${TAG_SHA}" ]; then
  echo "✅ Content SHA256 matches tag commit"
else
  echo "❌ Content SHA256 mismatch: ${CONTENT_SHA256} != ${TAG_SHA}"
fi
```

---

## Validation Results Table

| Check | Expected | Actual | Result | Notes |
|-------|----------|--------|--------|-------|
| PredicateType | `https://slsa.dev/provenance/v0.2` | [記録待ち] | ⏳ | - |
| Content SHA256 | [TAG_SHA] | [記録待ち] | ⏳ | Must match tag commit |
| File SHA256 | [FILE_SHA256] | [記録待ち] | ⏳ | Calculated from file |
| Builder ID | Present | [記録待ち] | ⏳ | - |
| Invocation Release | [TAG] | [記録待ち] | ⏳ | Must match tag |

---

## Expected Output Example

```
✅ PredicateType: https://slsa.dev/provenance/v0.2
✅ Content SHA256: a1b2c3d4e5f6... (matches tag commit)
✅ File SHA256: f6e5d4c3b2a1... (calculated)
✅ Builder ID: github-actions/slsa-provenance
✅ Invocation Release: v2025.11.13-success-test
```

---

## Rollback Procedure

If validation fails:

1. **Review Artifact**
   ```bash
   cat "${ARTIFACT_FILE}" | jq '.'
   ```

2. **Check Workflow Logs**
   ```bash
   gh run view "${RUN_ID}" --log
   ```

3. **Re-run Workflow**
   ```bash
   gh workflow run slsa-provenance.yml -f tag="${TAG}"
   ```

---

**Status**: ⏳ Validation pending (successful run required)

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
