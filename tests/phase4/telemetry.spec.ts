/**
 * Unit tests for Phase 4 Telemetry
 */

import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { upsertByRunId, TelemetryEntry } from '../../scripts/phase4/telemetry/telemetry';

// Mock @supabase/supabase-js
vi.mock('@supabase/supabase-js', () => {
  return {
    createClient: vi.fn(() => ({
      from: vi.fn(() => ({
        upsert: vi.fn(async (data: any, options: any) => {
          return {
            data: data,
            error: null,
          };
        }),
      })),
    })),
  };
});

describe('Telemetry Upsert', () => {
  const originalEnv = process.env;

  beforeEach(() => {
    process.env = { ...originalEnv };
    vi.clearAllMocks();
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

  it('should return ok when SUPABASE_SERVICE_KEY is present and use Supabase client', async () => {
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

  it('should handle Supabase client errors', async () => {
    const { createClient } = await import('@supabase/supabase-js');
    const mockClient = {
      from: vi.fn(() => ({
        upsert: vi.fn(async () => ({
          data: null,
          error: { message: 'Database error' },
        })),
      })),
    };
    vi.mocked(createClient).mockReturnValue(mockClient as any);

    process.env.SUPABASE_SERVICE_KEY = 'test-key';
    process.env.SUPABASE_URL = 'https://test.supabase.co';

    const entry: TelemetryEntry = {
      run_id: 789,
      run_url: 'https://example.com/run/789',
      created_at: '2025-11-14T10:00:00Z',
    };

    const result = await upsertByRunId(entry);

    expect(result.status).toBe('error');
    expect(result.message).toContain('Supabase upsert failed');
  });
});

