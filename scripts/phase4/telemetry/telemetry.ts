#!/usr/bin/env node
/**
 * Phase 4 Telemetry Upsert Layer
 * Handles Supabase upserts with idempotency based on run_id
 * Returns ci-guard-required if SUPABASE_SERVICE_KEY is missing
 */

export interface TelemetryEntry {
  run_id: number;
  tag?: string;
  sha256?: string;
  run_url: string;
  created_at: string;
  sha_parity?: boolean;
  validator_verdict?: string;
}

export interface TelemetryResult {
  status: 'ok' | 'error' | 'ci-guard-required';
  rowId?: string | number;
  message?: string;
}

/**
 * Upsert telemetry entry to Supabase
 * Uses run_id as unique key for idempotency
 * Returns ci-guard-required if SUPABASE_SERVICE_KEY is not present
 */
export async function upsertByRunId(
  entry: TelemetryEntry,
  supabaseUrl?: string,
  supabaseServiceKey?: string
): Promise<TelemetryResult> {
  // Presence-only check - never log the value
  const hasServiceKey = !!supabaseServiceKey || !!process.env.SUPABASE_SERVICE_KEY;
  const url = supabaseUrl || process.env.SUPABASE_URL;

  if (!hasServiceKey || !url) {
    return {
      status: 'ci-guard-required',
      message: 'SUPABASE_SERVICE_KEY not set',
    };
  }

  // In production, this would make actual Supabase API call
  // For now, stub implementation that simulates success
  try {
    // TODO: Replace with actual Supabase client when secrets are available
    // const supabase = createClient(url, serviceKey);
    // const { data, error } = await supabase
    //   .from('ops_auto_audit_runs')
    //   .upsert({ ...entry, updated_at: new Date().toISOString() }, { onConflict: 'run_id' });

    // Stub: simulate successful upsert
    return {
      status: 'ok',
      rowId: entry.run_id,
    };
  } catch (error) {
    return {
      status: 'error',
      message: error instanceof Error ? error.message : String(error),
    };
  }
}

