-- Status:: planned
-- Source-of-Truth:: supabase/migrations/20260101_ops_security_rls.sql
-- Spec-State:: pending

-- Harden ops tables by restricting reads to ops_admin claims/service_role.
-- Requires auth metadata like { "ops_admin": true } or service_role access.

-- Helper expression to detect the ops_admin claim without crashing when missing.
CREATE OR REPLACE FUNCTION public.has_ops_admin_claim() RETURNS boolean AS $$
BEGIN
  RETURN position('"ops_admin":true' IN coalesce(current_setting('request.jwt.claims', true), '')) > 0;
END;
$$ LANGUAGE plpgsql STABLE;

-- ops_metrics (telemetry)
ALTER TABLE public.ops_metrics ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS ops_metrics_select_ops ON public.ops_metrics;
CREATE POLICY ops_metrics_select_ops ON public.ops_metrics
  FOR SELECT
  TO authenticated
  USING (
    auth.role() = 'service_role'
    OR public.has_ops_admin_claim()
  );
DROP POLICY IF EXISTS ops_metrics_insert_edge ON public.ops_metrics;
CREATE POLICY ops_metrics_insert_edge ON public.ops_metrics
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.role() = 'service_role'
    OR public.has_ops_admin_claim()
  );

-- ops_alerts_history (alerts)
ALTER TABLE public.ops_alerts_history ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS ops_alerts_history_select ON public.ops_alerts_history;
CREATE POLICY ops_alerts_history_select ON public.ops_alerts_history
  FOR SELECT
  TO authenticated
  USING (
    auth.role() = 'service_role'
    OR public.has_ops_admin_claim()
  );
DROP POLICY IF EXISTS ops_alerts_history_insert_edge ON public.ops_alerts_history;
CREATE POLICY ops_alerts_history_insert_edge ON public.ops_alerts_history
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.role() = 'service_role'
    OR public.has_ops_admin_claim()
  );

-- ops_summary_email_logs (audit)
ALTER TABLE public.ops_summary_email_logs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS ops_summary_email_logs_select ON public.ops_summary_email_logs;
CREATE POLICY ops_summary_email_logs_select ON public.ops_summary_email_logs
  FOR SELECT
  TO authenticated
  USING (
    auth.role() = 'service_role'
    OR public.has_ops_admin_claim()
  );
DROP POLICY IF EXISTS ops_summary_email_logs_insert_edge ON public.ops_summary_email_logs;
CREATE POLICY ops_summary_email_logs_insert_edge ON public.ops_summary_email_logs
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.role() = 'service_role'
    OR public.has_ops_admin_claim()
  );
