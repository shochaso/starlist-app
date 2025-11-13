/**
 * Unit tests for Phase 4 Telemetry
 */

import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { upsertByRunId, TelemetryEntry } from '../../scripts/phase4/telemetry/telemetry';

describe('Telemetry Upsert', () => {
  const originalEnv = process.env;

  beforeEach(() => {
    process.env = { ...originalEnv };
  });

  afterEach(() => {
    process.env = originalEnv;
  });

  it('should return ci-guard-required when SUPABASE_SERVICE_KEY is missing', async () => {
    delete process.env.SUPABASE_SERVICE_KEY;
    delete process.env.SUPABASE_URL;

    const entry: TelemetryEntry = {
      run_id: 123,
      run_url: 'https://example.com/run/123',
      created_at: '2025-11-14T10:00:00Z',
    };

    const result = await upsertByRunId(entry);

    expect(result.status).toBe('ci-guard-required');
    expect(result.message).toContain('SUPABASE_SERVICE_KEY');
  });

  it('should return ok when SUPABASE_SERVICE_KEY is present', async () => {
    process.env.SUPABASE_SERVICE_KEY = 'test-key';
    process.env.SUPABASE_URL = 'https://test.supabase.co';

    const entry: TelemetryEntry = {
      run_id: 123,
      run_url: 'https://example.com/run/123',
      created_at: '2025-11-14T10:00:00Z',
    };

    const result = await upsertByRunId(entry);

    expect(result.status).toBe('ok');
    expect(result.rowId).toBe(123);
  });

  it('should accept supabaseUrl and supabaseServiceKey as parameters', async () => {
    const entry: TelemetryEntry = {
      run_id: 456,
      run_url: 'https://example.com/run/456',
      created_at: '2025-11-14T10:00:00Z',
    };

    const result = await upsertByRunId(entry, 'https://test.supabase.co', 'test-key');

    expect(result.status).toBe('ok');
    expect(result.rowId).toBe(456);
  });
});

