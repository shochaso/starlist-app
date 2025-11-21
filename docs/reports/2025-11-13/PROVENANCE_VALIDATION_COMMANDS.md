---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# Provenance Validation Commands

**Purpose**: Commands for validating provenance artifacts (predicateType, SHA256, content integrity).

**Last Updated**: 2025-11-13 (UTC)

---

## Prerequisites

- `jq` installed: `sudo apt-get install -y jq` or `brew install jq`
- `sha256sum` available (standard on Linux/macOS)
- Artifact downloaded from GitHub Actions

---

## Download Artifact

```bash
# Download artifact for specific run
RUN_ID=123456789
TAG="v2025.11.13-success-test"

gh run download "${RUN_ID}" \
  --name "provenance-${TAG}" \
  --dir /tmp/provenance_artifacts
```

---

## Validation Commands

### 1. Extract PredicateType

```bash
ARTIFACT_FILE="/tmp/provenance_artifacts/provenance-${TAG}.json"

PREDICATE_TYPE=$(jq -r '.predicateType // empty' "${ARTIFACT_FILE}")

echo "PredicateType: ${PREDICATE_TYPE}"

# Validate
if [ "${PREDICATE_TYPE}" = "https://slsa.dev/provenance/v0.2" ]; then
  echo "✅ PredicateType valid"
else
  echo "❌ PredicateType invalid: ${PREDICATE_TYPE}"
  exit 1
fi
```

### 2. Extract Content SHA256

```bash
CONTENT_SHA256=$(jq -r '.metadata.content_sha256 // empty' "${ARTIFACT_FILE}")

echo "Content SHA256: ${CONTENT_SHA256}"

# Validate against tag commit
TAG_SHA=$(git rev-parse "${TAG}^{commit}" 2>/dev/null || git rev-parse HEAD)

if [ "${CONTENT_SHA256}" = "${TAG_SHA}" ]; then
  echo "✅ Content SHA256 matches tag commit"
else
  echo "❌ Content SHA256 mismatch: ${CONTENT_SHA256} != ${TAG_SHA}"
  exit 1
fi
```

### 3. Calculate File SHA256

```bash
FILE_SHA256=$(sha256sum "${ARTIFACT_FILE}" | cut -d' ' -f1)

echo "File SHA256: ${FILE_SHA256}"
```

### 4. Validate Builder ID

```bash
BUILDER_ID=$(jq -r '.builder.id // empty' "${ARTIFACT_FILE}")

echo "Builder ID: ${BUILDER_ID}"

if [ -n "${BUILDER_ID}" ]; then
  echo "✅ Builder ID present"
else
  echo "❌ Builder ID missing"
  exit 1
fi
```

### 5. Validate Invocation Release

```bash
INV_RELEASE=$(jq -r '.invocation.release // empty' "${ARTIFACT_FILE}")

echo "Invocation Release: ${INV_RELEASE}"

if [ "${INV_RELEASE}" = "${TAG}" ]; then
  echo "✅ Invocation release matches tag"
else
  echo "❌ Invocation release mismatch: ${INV_RELEASE} != ${TAG}"
  exit 1
fi
```

---

## Complete Validation Script

```bash
#!/bin/bash
set -euo pipefail

RUN_ID="${1:-}"
TAG="${2:-}"

if [ -z "${RUN_ID}" ] || [ -z "${TAG}" ]; then
  echo "Usage: $0 <RUN_ID> <TAG>"
  exit 1
fi

# Download artifact
echo "📦 Downloading artifact..."
gh run download "${RUN_ID}" \
  --name "provenance-${TAG}" \
  --dir /tmp/provenance_validation

ARTIFACT_FILE=$(find /tmp/provenance_validation -name "provenance-*.json" | head -1)

if [ -z "${ARTIFACT_FILE}" ]; then
  echo "❌ Artifact not found"
  exit 1
fi

echo "✅ Artifact found: ${ARTIFACT_FILE}"

# Validate PredicateType
PREDICATE_TYPE=$(jq -r '.predicateType // empty' "${ARTIFACT_FILE}")
if [ "${PREDICATE_TYPE}" != "https://slsa.dev/provenance/v0.2" ]; then
  echo "❌ PredicateType invalid: ${PREDICATE_TYPE}"
  exit 1
fi
echo "✅ PredicateType: ${PREDICATE_TYPE}"

# Validate Content SHA256
CONTENT_SHA256=$(jq -r '.metadata.content_sha256 // empty' "${ARTIFACT_FILE}")
TAG_SHA=$(git rev-parse "${TAG}^{commit}" 2>/dev/null || git rev-parse HEAD)
if [ "${CONTENT_SHA256}" != "${TAG_SHA}" ]; then
  echo "❌ Content SHA256 mismatch: ${CONTENT_SHA256} != ${TAG_SHA}"
  exit 1
fi
echo "✅ Content SHA256: ${CONTENT_SHA256}"

# Calculate File SHA256
FILE_SHA256=$(sha256sum "${ARTIFACT_FILE}" | cut -d' ' -f1)
echo "✅ File SHA256: ${FILE_SHA256}"

# Validate Builder ID
BUILDER_ID=$(jq -r '.builder.id // empty' "${ARTIFACT_FILE}")
if [ -z "${BUILDER_ID}" ]; then
  echo "❌ Builder ID missing"
  exit 1
fi
echo "✅ Builder ID: ${BUILDER_ID}"

# Validate Invocation Release
INV_RELEASE=$(jq -r '.invocation.release // empty' "${ARTIFACT_FILE}")
if [ "${INV_RELEASE}" != "${TAG}" ]; then
  echo "❌ Invocation release mismatch: ${INV_RELEASE} != ${TAG}"
  exit 1
fi
echo "✅ Invocation Release: ${INV_RELEASE}"

echo ""
echo "✅ All validations passed"
```

---

## Validation Results Table Template

| Check | Expected | Actual | Result |
|-------|----------|--------|--------|
| PredicateType | `https://slsa.dev/provenance/v0.2` | [記録] | ✅/❌ |
| Content SHA256 | [TAG_SHA] | [記録] | ✅/❌ |
| File SHA256 | [FILE_SHA256] | [記録] | ✅/❌ |
| Builder ID | Present | [記録] | ✅/❌ |
| Invocation Release | [TAG] | [記録] | ✅/❌ |

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

**Note**: Validation results should be recorded in `WS06_SHA256_VALIDATION.md` and `PHASE2_2_VALIDATION_REPORT.md`.

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
