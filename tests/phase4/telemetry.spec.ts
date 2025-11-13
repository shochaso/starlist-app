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
        upsert: vi.fn(),
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

  it('should return ok when SUPABASE_SERVICE_KEY is present and Supabase client available', async () => {
    process.env.SUPABASE_SERVICE_KEY = 'test-key';
    process.env.SUPABASE_URL = 'https://test.supabase.co';

    const { createClient } = await import('@supabase/supabase-js');
    const mockUpsert = vi.fn().mockResolvedValue({ data: {}, error: null });
    const mockFrom = vi.fn().mockReturnValue({ upsert: mockUpsert });
    vi.mocked(createClient).mockReturnValue({ from: mockFrom } as any);

    const entry: TelemetryEntry = {
      run_id: 123,
      run_url: 'https://example.com/run/123',
      created_at: '2025-11-14T10:00:00Z',
    };

    const result = await upsertByRunId(entry);

    expect(result.status).toBe('ok');
    expect(result.rowId).toBe(123);
    expect(mockFrom).toHaveBeenCalledWith('phase4_runs');
    expect(mockUpsert).toHaveBeenCalledWith(
      expect.objectContaining({ run_id: 123 }),
      { onConflict: 'run_id' }
    );
  });

  it('should return error when Supabase upsert fails', async () => {
    process.env.SUPABASE_SERVICE_KEY = 'test-key';
    process.env.SUPABASE_URL = 'https://test.supabase.co';

    const { createClient } = await import('@supabase/supabase-js');
    const mockUpsert = vi.fn().mockResolvedValue({
      data: null,
      error: { message: 'Database error' },
    });
    const mockFrom = vi.fn().mockReturnValue({ upsert: mockUpsert });
    vi.mocked(createClient).mockReturnValue({ from: mockFrom } as any);

    const entry: TelemetryEntry = {
      run_id: 456,
      run_url: 'https://example.com/run/456',
      created_at: '2025-11-14T10:00:00Z',
    };

    const result = await upsertByRunId(entry);

    expect(result.status).toBe('error');
    expect(result.message).toContain('Supabase upsert failed');
  });

  it('should accept supabaseUrl and supabaseServiceKey as parameters', async () => {
    const { createClient } = await import('@supabase/supabase-js');
    const mockUpsert = vi.fn().mockResolvedValue({ data: {}, error: null });
    const mockFrom = vi.fn().mockReturnValue({ upsert: mockUpsert });
    vi.mocked(createClient).mockReturnValue({ from: mockFrom } as any);

    const entry: TelemetryEntry = {
      run_id: 789,
      run_url: 'https://example.com/run/789',
      created_at: '2025-11-14T10:00:00Z',
    };

    const result = await upsertByRunId(entry, 'https://test.supabase.co', 'test-key');

    expect(result.status).toBe('ok');
    expect(result.rowId).toBe(789);
    expect(createClient).toHaveBeenCalledWith('https://test.supabase.co', 'test-key');
  });
});

