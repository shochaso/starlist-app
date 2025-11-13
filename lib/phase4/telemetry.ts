/**
 * Phase 4 Telemetry Upsert Layer
 * Handles Supabase upserts with idempotency based on run_id
 */

// TODO: Update table name to match actual Supabase schema
// Expected schema:
// CREATE TABLE ops_auto_audit_runs (
//   run_id BIGINT PRIMARY KEY,
//   tag TEXT,
//   sha256 TEXT,
//   run_url TEXT,
//   created_at TIMESTAMPTZ,
//   sha_parity BOOLEAN,
//   validator_verdict TEXT,
//   updated_at TIMESTAMPTZ DEFAULT NOW()
// );

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
 */
export async function upsertByRunId(
  entry: TelemetryEntry,
  supabaseUrl?: string,
  supabaseServiceKey?: string
): Promise<TelemetryResult> {
  if (!supabaseUrl || !supabaseServiceKey) {
    return {
      status: 'ci-guard-required',
      message: 'SUPABASE_SERVICE_KEY not set',
    };
  }

  try {
    // Use Supabase REST API for upsert
    const response = await fetch(`${supabaseUrl}/rest/v1/ops_auto_audit_runs`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': supabaseServiceKey,
        'Authorization': `Bearer ${supabaseServiceKey}`,
        'Prefer': 'resolution=merge-duplicates',
      },
      body: JSON.stringify({
        run_id: entry.run_id,
        tag: entry.tag,
        sha256: entry.sha256,
        run_url: entry.run_url,
        created_at: entry.created_at,
        sha_parity: entry.sha_parity,
        validator_verdict: entry.validator_verdict,
      }),
    });

    if (response.status === 409) {
      // Conflict - entry already exists (idempotent, treat as success)
      return {
        status: 'ok',
        rowId: entry.run_id,
        message: 'Entry already exists',
      };
    }

    if (!response.ok) {
      const errorText = await response.text();
      return {
        status: 'error',
        message: `Supabase upsert failed: ${response.status} ${errorText}`,
      };
    }

    const result = await response.json();
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

