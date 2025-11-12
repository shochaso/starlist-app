-- SLSA Audit Metrics Table
-- Stores Phase 3 audit observer results for operational monitoring and KPI tracking

-- Table definition (idempotent)
create table if not exists public.slsa_audit_metrics (
  id bigserial primary key,
  audit_run_id bigint not null unique,
  provenance_run_id bigint,
  validation_run_id bigint,
  audit_timestamp timestamptz not null default now(),
  provenance_status text not null check (provenance_status in ('success', 'failure', 'skipped', 'unknown')),
  validation_status text not null check (validation_status in ('success', 'failure', 'skipped', 'unknown')),
  sha256_verified boolean not null default false,
  predicate_type_verified boolean not null default false,
  supabase_provenance_synced boolean not null default false,
  supabase_validation_synced boolean not null default false,
  tag text,
  sha256 text,
  predicate_type text,
  builder_id text,
  content_sha256 text,
  provenance_run_url text,
  validation_run_url text,
  metadata jsonb default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Indexes for performance
create index if not exists idx_slsa_audit_metrics_audit_run_id on public.slsa_audit_metrics (audit_run_id);
create index if not exists idx_slsa_audit_metrics_provenance_run_id on public.slsa_audit_metrics (provenance_run_id);
create index if not exists idx_slsa_audit_metrics_validation_run_id on public.slsa_audit_metrics (validation_run_id);
create index if not exists idx_slsa_audit_metrics_audit_timestamp on public.slsa_audit_metrics (audit_timestamp desc);
create index if not exists idx_slsa_audit_metrics_provenance_status on public.slsa_audit_metrics (provenance_status);
create index if not exists idx_slsa_audit_metrics_validation_status on public.slsa_audit_metrics (validation_status);
create index if not exists idx_slsa_audit_metrics_tag on public.slsa_audit_metrics (tag);

-- RLS enabled
alter table public.slsa_audit_metrics enable row level security;

-- RLS Policy: Service role can insert/update/select (narrow-scope)
create policy "Service role narrow-scope access"
  on public.slsa_audit_metrics
  for all
  using (
    auth.role() = 'service_role' AND
    (auth.jwt() ->> 'claims' IS NOT NULL)
  )
  with check (
    auth.role() = 'service_role' AND
    (auth.jwt() ->> 'claims' IS NOT NULL)
  );

-- RLS Policy: Authenticated users can read
create policy "Authenticated users can read"
  on public.slsa_audit_metrics
  for select
  using (auth.role() = 'authenticated');

-- Updated_at trigger
create or replace function update_slsa_audit_metrics_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger update_slsa_audit_metrics_updated_at
  before update on public.slsa_audit_metrics
  for each row
  execute function update_slsa_audit_metrics_updated_at();

-- KPI View: Audit success rate
create or replace view public.v_ops_slsa_audit_kpi as
select
  date_trunc('day', audit_timestamp) as date,
  count(*) as total_audits,
  count(*) filter (where provenance_status = 'success' and validation_status = 'success') as success_count,
  count(*) filter (where provenance_status = 'failure' or validation_status = 'failure') as failure_count,
  count(*) filter (where sha256_verified = true) as sha256_verified_count,
  count(*) filter (where predicate_type_verified = true) as predicate_type_verified_count,
  count(*) filter (where supabase_provenance_synced = true) as supabase_provenance_synced_count,
  count(*) filter (where supabase_validation_synced = true) as supabase_validation_synced_count,
  round(100.0 * count(*) filter (where provenance_status = 'success' and validation_status = 'success') / nullif(count(*), 0), 2) as success_rate,
  round(100.0 * count(*) filter (where sha256_verified = true) / nullif(count(*), 0), 2) as sha256_verification_rate,
  round(100.0 * count(*) filter (where predicate_type_verified = true) / nullif(count(*), 0), 2) as predicate_type_verification_rate,
  round(100.0 * count(*) filter (where supabase_provenance_synced = true) / nullif(count(*), 0), 2) as supabase_provenance_sync_rate,
  round(100.0 * count(*) filter (where supabase_validation_synced = true) / nullif(count(*), 0), 2) as supabase_validation_sync_rate
from public.slsa_audit_metrics
group by date_trunc('day', audit_timestamp)
order by date desc;

-- KPI View: Recent audit failures
create or replace view public.v_ops_slsa_audit_failures as
select
  audit_run_id,
  audit_timestamp,
  provenance_run_id,
  validation_run_id,
  provenance_status,
  validation_status,
  sha256_verified,
  predicate_type_verified,
  supabase_provenance_synced,
  supabase_validation_synced,
  tag,
  provenance_run_url,
  validation_run_url,
  metadata
from public.slsa_audit_metrics
where provenance_status = 'failure' or validation_status = 'failure'
order by audit_timestamp desc
limit 100;

-- Grant access
grant select on public.slsa_audit_metrics to authenticated;
grant select on public.v_ops_slsa_audit_kpi to authenticated;
grant select on public.v_ops_slsa_audit_failures to authenticated;

