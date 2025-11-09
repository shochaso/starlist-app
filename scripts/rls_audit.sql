-- RLS Audit: Check for tables without RLS enabled
-- Usage: supabase db query < scripts/rls_audit.sql

SELECT 
  schemaname,
  tablename,
  CASE 
    WHEN rowsecurity = false THEN '❌ RLS DISABLED'
    ELSE '✅ RLS ENABLED'
  END AS rls_status
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename NOT LIKE 'pg_%'
ORDER BY rowsecurity, tablename;

-- Check for tables with RLS but no policies
SELECT 
  schemaname,
  tablename,
  '⚠️  RLS ENABLED BUT NO POLICIES' AS status
FROM pg_tables t
WHERE schemaname = 'public'
  AND rowsecurity = true
  AND NOT EXISTS (
    SELECT 1 
    FROM pg_policies p 
    WHERE p.schemaname = t.schemaname 
      AND p.tablename = t.tablename
  )
ORDER BY tablename;

