-- Detect public tables without RLS policies for quick audit
select table_schema, table_name
from information_schema.tables
where table_schema = 'public'
  and table_type = 'BASE TABLE'
  and not exists (
    select 1 from pg_policies p
    where p.schemaname = 'public' and p.tablename = table_name
  );
