#!/usr/bin/env node
/**
 * Phase 4 Recovery Handler
 * Ensures manifest and Supabase are aligned after retries
 */

import * as fs from 'fs/promises';
import * as path from 'path';
import { upsertByRunId, TelemetryEntry } from '../telemetry/telemetry';
import { nowUtcIso } from '../../lib/phase4/time';

interface AlignmentResult {
  recovery_required: boolean;
  manifest_count: number;
  supabase_count?: number;
  mismatches: number[];
}

/**
 * Align manifest and Supabase after retries
 */
export async function alignManifestAndSupabase(
  manifestPath: string,
  supabaseUrl?: string,
  supabaseServiceKey?: string
): Promise<AlignmentResult> {
  let manifestEntries: any[] = [];
  
  try {
    const content = await fs.readFile(manifestPath, 'utf-8');
    manifestEntries = JSON.parse(content);
  } catch {
    return {
      recovery_required: false,
      manifest_count: 0,
      mismatches: [],
    };
  }

  const mismatches: number[] = [];

  if (supabaseUrl && supabaseServiceKey) {
    // Try to upsert all manifest entries to Supabase
    for (const entry of manifestEntries) {
      const telemetryEntry: TelemetryEntry = {
        run_id: entry.run_id,
        tag: entry.tag,
        sha256: entry.sha256,
        run_url: entry.run_url,
        created_at: entry.created_at,
        sha_parity: entry.sha_parity,
        validator_verdict: entry.validator_verdict,
      };

      const result = await upsertByRunId(telemetryEntry, supabaseUrl, supabaseServiceKey);
      if (result.status !== 'ok') {
        mismatches.push(entry.run_id);
      }
    }
  }

  return {
    recovery_required: mismatches.length > 0,
    manifest_count: manifestEntries.length,
    mismatches,
  };
}

async function main() {
  const reportDir = process.env.REPORT_DIR || path.join(process.cwd(), 'docs/reports/2025-11-14');
  const manifestPath = path.join(reportDir, '_manifest.json');

  const result = await alignManifestAndSupabase(
    manifestPath,
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_KEY
  );

  console.log(JSON.stringify({
    event: 'recovery_alignment',
    ...result,
    timestamp: nowUtcIso(),
  }));
}

if (require.main === module) {
  main().catch(console.error);
}

