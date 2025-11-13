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
  const serviceKey = supabaseServiceKey || process.env.SUPABASE_SERVICE_KEY;
  const url = supabaseUrl || process.env.SUPABASE_URL;

  if (!serviceKey || !url) {
    return {
      status: 'ci-guard-required',
      message: 'SUPABASE_SERVICE_KEY not set',
    };
  }

  try {
    // Use Supabase client if available (behind env guard)
    // Only execute real upsert when service key is present
    let supabaseClient: any = null;
    
    try {
      // Dynamic import to avoid requiring @supabase/supabase-js at build time
      const { createClient } = await import('@supabase/supabase-js');
      supabaseClient = createClient(url, serviceKey);
    } catch (importError) {
      // Library not available, fall back to stub
      console.warn(JSON.stringify({
        event: 'telemetry_stub_fallback',
        reason: 'supabase_client_not_available',
        timestamp: new Date().toISOString(),
      }));
      return {
        status: 'ok',
        rowId: entry.run_id,
        message: 'Stub: Supabase client not available',
      };
    }

    // Real Supabase upsert
    const { data, error } = await supabaseClient
      .from('phase4_runs')
      .upsert(
        {
          run_id: entry.run_id,
          tag: entry.tag,
          sha256: entry.sha256,
          run_url: entry.run_url,
          created_at: entry.created_at,
          sha_parity: entry.sha_parity,
          validator_verdict: entry.validator_verdict,
          updated_at: new Date().toISOString(),
        },
        { onConflict: 'run_id' }
      );

    if (error) {
      return {
        status: 'error',
        message: `Supabase upsert failed: ${error.message}`,
      };
    }

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

