-- Status:: planned
-- Source-of-Truth:: supabase/migrations/20251107_ops_metrics.sql
-- Spec-State:: 確定済み
-- Last-Updated:: 2025-11-07

create table if not exists public.ops_metrics (
  id             bigserial primary key,
  ts_ingested    timestamptz not null default now(),
  app            text not null,
  env            text not null check (env in ('dev','stg','prod')),
  event          text not null,
  ok             boolean not null,
  latency_ms     integer,
  err_code       text,
  extra          jsonb
);

create index if not exists idx_ops_metrics_ts on public.ops_metrics (ts_ingested desc);
create index if not exists idx_ops_metrics_event_ts on public.ops_metrics (event, ts_ingested desc);
create index if not exists idx_ops_metrics_ok_ts on public.ops_metrics (ok, ts_ingested desc);

-- RLS
alter table public.ops_metrics enable row level security;

do $$ begin
  if not exists (select 1 from pg_policies where tablename = 'ops_metrics' and policyname = 'ops_metrics_insert_edge') then
    create policy ops_metrics_insert_edge on public.ops_metrics
      for insert to authenticated
      with check (auth.uid() in (select user_id from public.edge_function_callers));
  end if;
end $$;

-- 5分バケットの集計ビュー
create or replace view public.v_ops_5min as
select
  date_trunc('minute', ts_ingested) - make_interval(mins => extract(minute from ts_ingested)::int % 5) as bucket_5m,
  app, env, event,
  count(*) as total,
  avg(latency_ms) filter (where latency_ms is not null) as avg_latency_ms,
  percentile_cont(0.95) within group (order by latency_ms) as p95_latency_ms,
  (sum(case when ok then 0 else 1 end)::float / greatest(count(*),1)) as failure_rate
from public.ops_metrics
group by 1,2,3,4
order by 1 desc;
