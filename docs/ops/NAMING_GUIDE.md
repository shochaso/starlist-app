# Naming Guide

**Purpose**: Standardize naming conventions for branches, artifacts, and reports.

---

## Branch Naming

### Format

```
<type>/<scope>-<description>
```

### Types

- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation
- `refactor/` - Code refactoring
- `test/` - Test additions/changes
- `chore/` - Maintenance tasks

### Examples

```
feature/slsa-phase2-implementation
fix/provenance-validate-permissions
docs/phase3-runbook
refactor/supabase-integration
test/provenance-validation-suite
chore/update-dependencies
```

---

## Artifact Naming

### Format

```
<workflow>-<identifier>-<run_id>
```

### Examples

```
provenance-v2025.11.13-123456789
slsa-manifest-v2025.11.13-123456789
phase3-audit-summary-123456789
```

### Naming Rules

- Use lowercase with hyphens
- Include workflow name or type
- Include identifier (tag, date, etc.)
- Include run ID for uniqueness

---

## Report Naming

### Format

```
<prefix>_<description>.md
```

### Prefixes

- `WS##` - Workstream evidence (WS01, WS02, etc.)
- `PHASE##` - Phase reports (PHASE2_2_VALIDATION_REPORT.md)
- `[WORKFLOW]_[TYPE]` - Workflow-specific reports

### Examples

```
WS01_workflow_dispatch_added.md
WS02_SUCCESS_CASE_EXECUTION.md
PHASE2_2_VALIDATION_REPORT.md
PHASE3_AUDIT_SUMMARY.md
```

---

## File Naming

### Directories

```
docs/reports/<YYYY-MM-DD>/
docs/ops/
scripts/
supabase/ops/
.github/workflows/
```

### Files

- **Workflows**: `kebab-case.yml` (e.g., `slsa-provenance.yml`)
- **Scripts**: `snake_case.sh` (e.g., `observe_phase3.sh`)
- **SQL**: `snake_case.sql` (e.g., `slsa_audit_metrics_table.sql`)
- **Docs**: `UPPER_SNAKE_CASE.md` (e.g., `PHASE3_AUDIT_SUMMARY.md`)

---

## Tag Naming

### Format

```
v<YYYY>.<MM>.<DD>[-<identifier>]
```

### Examples

```
v2025.11.13
v2025.11.13-success-test
v2025.11.13-fail-test
v2025.11.13-concurrent-1
```

---

## Run ID Naming

### Format

```
<workflow>-<run_id>
```

### Examples

```
slsa-provenance-123456789
provenance-validate-987654321
phase3-audit-observer-111222333
```

---

## Database Table Naming

### Format

```
<prefix>_<entity>_<suffix>
```

### Examples

```
slsa_runs
slsa_audit_metrics
v_ops_slsa_status
v_ops_slsa_audit_kpi
```

### Naming Rules

- Use snake_case
- Prefix views with `v_`
- Prefix operational views with `v_ops_`
- Use descriptive names

---

## API Endpoint Naming

### Format

```
/rest/v1/<resource>[?<query>]
```

### Examples

```
/rest/v1/slsa_runs
/rest/v1/slsa_runs?select=*&limit=10
/rest/v1/slsa_audit_metrics
```

---

## Environment Variable Naming

### Format

```
<PROVIDER>_<RESOURCE>_<TYPE>
```

### Examples

```
SUPABASE_URL
SUPABASE_SERVICE_KEY
SUPABASE_ANON_KEY
SLACK_WEBHOOK_URL
GITHUB_TOKEN
```

---

## Best Practices

1. **Consistency**: Use the same naming convention throughout
2. **Descriptive**: Names should clearly indicate purpose
3. **Lowercase**: Use lowercase for files and directories
4. **Hyphens**: Use hyphens for multi-word names in files
5. **Snake Case**: Use snake_case for scripts and SQL
6. **Prefixes**: Use prefixes to group related items

---

## Naming Checklist

- [ ] Branch name follows format
- [ ] Artifact name includes identifier
- [ ] Report name includes prefix
- [ ] File name uses correct case
- [ ] Tag name follows version format
- [ ] Database table uses snake_case
- [ ] Environment variable uses UPPER_SNAKE_CASE

---

**Last Updated**: 2025-11-13

