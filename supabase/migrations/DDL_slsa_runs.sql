-- Migration: create SLSA provenance audit table
create table if not exists public.slsa_runs (
  run_id bigint primary key,
  tag text not null,
  commit_sha text not null,
  content_sha text not null,
  artifact_path text not null,
  artifact_url text not null,
  release_url text not null,
  actor text not null,
  timestamp timestamptz not null,
  status text not null,
  failure_reason text default '',
  manifest_hash text not null,
  validation_status text default '',
  validated_at timestamptz,
  validation_method text default '',
  metadata jsonb default '{}'::jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create unique index if not exists slsa_runs_tag_idx on public.slsa_runs(tag);
create index if not exists slsa_runs_created_at_idx on public.slsa_runs(created_at);
