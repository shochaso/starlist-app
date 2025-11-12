-- SLSA Provenance Runs Table
-- Stores provenance generation and validation results for audit and KPI

create table if not exists public.slsa_runs (
  id bigserial primary key,
  run_id bigint not null unique,
  tag text not null,
  sha256 text not null,
  artifact_url text,
  actor text not null,
  timestamp timestamptz not null default now(),
  status text not null check (status in ('success', 'failure', 'skipped')),
  governance_flag text default 'provenance-ready',
  release_url text,
  failure_reason text,
  predicate_type text,
  builder_id text,
  validated_at timestamptz,
  validated_status text check (validated_status in ('success', 'failure', null)),
  metadata jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Indexes
create index if not exists idx_slsa_runs_run_id on public.slsa_runs (run_id);
create index if not exists idx_slsa_runs_tag on public.slsa_runs (tag);
create index if not exists idx_slsa_runs_timestamp on public.slsa_runs (timestamp desc);
create index if not exists idx_slsa_runs_status on public.slsa_runs (status);
create index if not exists idx_slsa_runs_validated_status on public.slsa_runs (validated_status);

-- RLS
alter table public.slsa_runs enable row level security;

-- RLS Policy: Service role can insert/update/select
create policy "Service role full access"
  on public.slsa_runs
  for all
  using (auth.role() = 'service_role')
  with check (auth.role() = 'service_role');

-- RLS Policy: Authenticated users can read
create policy "Authenticated users can read"
  on public.slsa_runs
  for select
  using (auth.role() = 'authenticated');

-- Updated_at trigger
create or replace function update_slsa_runs_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger update_slsa_runs_updated_at
  before update on public.slsa_runs
  for each row
  execute function update_slsa_runs_updated_at();

-- KPI View
create or replace view public.v_ops_slsa_status as
select
  date_trunc('day', timestamp) as date,
  count(*) as total_runs,
  count(*) filter (where status = 'success') as success_count,
  count(*) filter (where status = 'failure') as failure_count,
  count(*) filter (where status = 'skipped') as skipped_count,
  count(*) filter (where validated_status = 'success') as validated_count,
  count(*) filter (where validated_status = 'failure') as validation_failure_count,
  round(100.0 * count(*) filter (where status = 'success') / nullif(count(*), 0), 2) as success_rate,
  round(100.0 * count(*) filter (where validated_status = 'success') / nullif(count(*) filter (where status = 'success'), 0), 2) as validation_rate
from public.slsa_runs
group by date_trunc('day', timestamp)
order by date desc;

-- Grant access
grant select on public.slsa_runs to authenticated;
grant select on public.v_ops_slsa_status to authenticated;
