# CI Runtime Policy

**Purpose**: Define recommended values for retry, timeout, and concurrency in CI workflows.

---

## Retry Policy

### Recommended Values

| Operation | Max Retries | Retry Delay | Use Case |
|-----------|-------------|-------------|----------|
| HTTP Requests | 3 | Exponential backoff (1s, 2s, 4s) | External API calls |
| Artifact Downloads | 3 | Linear backoff (5s, 10s, 15s) | GitHub Actions artifacts |
| Database Queries | 2 | Linear backoff (2s, 4s) | Supabase queries |
| Slack Notifications | 2 | Linear backoff (3s, 6s) | Non-critical notifications |

### Implementation Example

```yaml
- name: Retry HTTP request
  run: |
    for i in {1..3}; do
      if curl -sS --fail --max-time 30 "${URL}"; then
        echo "✅ Request succeeded on attempt $i"
        break
      fi
      if [ $i -eq 3 ]; then
        echo "❌ Request failed after 3 attempts"
        exit 1
      fi
      sleep $((2 ** ($i - 1)))
    done
```

---

## Timeout Policy

### Recommended Values

| Operation | Timeout | Reason |
|-----------|---------|--------|
| Workflow Job | 60 minutes | GitHub Actions default |
| HTTP Requests | 30 seconds | External API calls |
| Artifact Downloads | 5 minutes | Large artifacts |
| Database Queries | 10 seconds | Supabase queries |
| Slack Notifications | 10 seconds | Non-critical |

### Implementation Example

```yaml
jobs:
  example:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    steps:
      - name: HTTP request with timeout
        run: |
          curl -sS --fail --max-time 30 "${URL}"
```

---

## Concurrency Policy

### Recommended Values

| Workflow | Concurrency Group | Cancel In Progress | Reason |
|----------|-------------------|-------------------|--------|
| slsa-provenance | `slsa-${{ github.ref }}` | `true` | One provenance per ref |
| provenance-validate | `provenance-validate-${{ github.ref }}-${{ github.event.workflow_run.id }}` | `true` | One validation per provenance run |
| phase3-audit-observer | `phase3-audit-observer-${{ github.ref }}` | `false` | Allow parallel audits |

### Implementation Example

```yaml
concurrency:
  group: workflow-name-${{ github.ref }}
  cancel-in-progress: true  # or false
```

---

## Parallel Execution Policy

### Recommended Limits

| Resource | Max Parallel | Reason |
|----------|--------------|--------|
| Workflow Runs | 5 per repository | GitHub Actions limits |
| API Requests | 10 per second | Rate limiting |
| Database Connections | 20 per workflow | Supabase connection pool |

### Implementation Example

```yaml
jobs:
  parallel-tasks:
    strategy:
      max-parallel: 5
      matrix:
        task: [1, 2, 3, 4, 5]
    steps:
      - name: Run task ${{ matrix.task }}
        run: echo "Task ${{ matrix.task }}"
```

---

## Best Practices

### 1. Use Exponential Backoff for Retries

```yaml
- name: Retry with exponential backoff
  run: |
    for i in {1..3}; do
      if command; then break; fi
      sleep $((2 ** ($i - 1)))
    done
```

### 2. Set Appropriate Timeouts

```yaml
- name: Request with timeout
  run: |
    timeout 30 curl -sS --fail "${URL}"
```

### 3. Use Concurrency Groups

```yaml
concurrency:
  group: workflow-${{ github.ref }}
  cancel-in-progress: true
```

### 4. Handle Failures Gracefully

```yaml
- name: Non-critical operation
  continue-on-error: true
  run: |
    curl -sS "${URL}" || echo "⚠️ Operation failed (non-blocking)"
```

---

## Monitoring

### Track Retry Rates

```sql
-- Query retry rates from audit metrics
SELECT
  date_trunc('hour', audit_timestamp) as hour,
  count(*) as total_audits,
  count(*) filter (where provenance_status = 'failure') as failures,
  round(100.0 * count(*) filter (where provenance_status = 'failure') / count(*), 2) as failure_rate
FROM slsa_audit_metrics
GROUP BY hour
ORDER BY hour DESC;
```

### Track Timeout Rates

Monitor workflow run durations and identify timeouts:

```bash
gh run list --workflow=slsa-provenance.yml --limit 100 \
  --json conclusion,duration,createdAt \
  --jq '.[] | select(.conclusion == "failure") | .duration'
```

---

## Policy Compliance Checklist

- [ ] Retry policies implemented for HTTP requests
- [ ] Timeout values set for all operations
- [ ] Concurrency groups configured for workflows
- [ ] Parallel execution limits respected
- [ ] Failure handling implemented
- [ ] Monitoring in place

---

**Last Updated**: 2025-11-13
