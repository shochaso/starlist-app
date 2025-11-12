# Telemetry Handoff Document

**Purpose**: Define Phase 4 telemetry integration requirements and handoff criteria.

---

## Phase 4 Overview

Phase 4 focuses on Telemetry & KPI Dashboard implementation, building on Phase 3 audit observer results.

---

## Minimum Schema Requirements

### Audit Metrics Table

```sql
-- Already implemented in Phase 3
-- Table: slsa_audit_metrics
-- Views: v_ops_slsa_audit_kpi, v_ops_slsa_audit_failures
```

### Telemetry Events Table

```sql
create table if not exists public.telemetry_events (
  id bigserial primary key,
  event_type text not null,
  event_timestamp timestamptz not null default now(),
  run_id bigint,
  tag text,
  metadata jsonb default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index idx_telemetry_events_event_type on public.telemetry_events (event_type);
create index idx_telemetry_events_event_timestamp on public.telemetry_events (event_timestamp desc);
```

### KPI Aggregation Table

```sql
create table if not exists public.kpi_aggregations (
  id bigserial primary key,
  metric_name text not null,
  metric_value numeric not null,
  aggregation_period text not null, -- 'hour', 'day', 'week'
  period_start timestamptz not null,
  period_end timestamptz not null,
  metadata jsonb default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index idx_kpi_aggregations_metric_name on public.kpi_aggregations (metric_name);
create index idx_kpi_aggregations_period_start on public.kpi_aggregations (period_start desc);
```

---

## Key Metrics

### Provenance Metrics

- **Success Rate**: Percentage of successful provenance generations
- **Average Duration**: Average time to generate provenance
- **Failure Rate**: Percentage of failed provenance generations
- **Validation Rate**: Percentage of validated provenance artifacts

### Audit Metrics

- **Audit Success Rate**: Percentage of successful audits
- **SHA256 Verification Rate**: Percentage of SHA256 verifications passed
- **PredicateType Verification Rate**: Percentage of PredicateType verifications passed
- **Supabase Sync Rate**: Percentage of successful Supabase synchronizations

### Operational Metrics

- **Workflow Run Duration**: Average workflow run duration
- **Artifact Size**: Average artifact size
- **API Response Time**: Average API response time
- **Error Rate**: Percentage of errors

---

## SLO (Service Level Objectives)

### Provenance Generation SLO

- **Availability**: 99.9% (3 nines)
- **Latency**: P95 < 5 minutes
- **Error Rate**: < 1%

### Validation SLO

- **Availability**: 99.9% (3 nines)
- **Latency**: P95 < 2 minutes
- **Error Rate**: < 0.5%

### Audit Observer SLO

- **Availability**: 99.5% (2.5 nines)
- **Latency**: P95 < 3 minutes
- **Error Rate**: < 2%

---

## Integration Points

### Phase 3 → Phase 4

1. **Audit Metrics**: Use `slsa_audit_metrics` table
2. **KPI Views**: Use `v_ops_slsa_audit_kpi` view
3. **Failure Tracking**: Use `v_ops_slsa_audit_failures` view

### Phase 4 Components

1. **Telemetry Collector**: Collect metrics from workflows
2. **KPI Aggregator**: Aggregate metrics by period
3. **Dashboard**: Visualize metrics and KPIs
4. **Alerting**: Alert on SLO violations

---

## Handoff Criteria

### Phase 3 Completion

- [x] Phase 3 audit observer implemented
- [x] Audit metrics table created
- [x] KPI views created
- [x] Documentation complete

### Phase 4 Prerequisites

- [ ] Audit metrics table populated with data
- [ ] KPI views returning data
- [ ] Telemetry events table created
- [ ] KPI aggregation table created
- [ ] Dashboard requirements defined
- [ ] Alerting rules defined

---

## Phase 4 Implementation Plan

### Step 1: Telemetry Collection

- Implement telemetry event collection in workflows
- Store events in `telemetry_events` table
- Aggregate events by period

### Step 2: KPI Aggregation

- Implement KPI aggregation jobs
- Store aggregated metrics in `kpi_aggregations` table
- Calculate success rates, error rates, etc.

### Step 3: Dashboard

- Create dashboard UI (Supabase Dashboard or custom)
- Visualize metrics and KPIs
- Add filters and time ranges

### Step 4: Alerting

- Implement alerting rules
- Send alerts on SLO violations
- Integrate with Slack/Email

---

## Data Flow

```
Workflows → Telemetry Events → KPI Aggregation → Dashboard
                ↓
         Audit Metrics → KPI Views → Alerting
```

---

## Success Criteria

### Phase 4 Completion

- [ ] Telemetry events collected
- [ ] KPI aggregations calculated
- [ ] Dashboard operational
- [ ] Alerting configured
- [ ] SLO monitoring in place

---

## Next Steps

1. **Review Phase 3 Results**: Analyze audit metrics data
2. **Define Dashboard Requirements**: Specify metrics to display
3. **Implement Telemetry Collection**: Add event collection to workflows
4. **Create Dashboard**: Build visualization dashboard
5. **Configure Alerting**: Set up alerting rules

---

**Last Updated**: 2025-11-13
**Status**: Ready for Phase 4 handoff

