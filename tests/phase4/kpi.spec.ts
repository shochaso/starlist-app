import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import * as fs from 'fs';
import * as path from 'path';
import { aggregateKpis } from '../../scripts/phase4/kpi/aggregate';

const base = path.join(__dirname, 'fixtures', 'kpi');

beforeEach(() => {
  if (fs.existsSync(base)) fs.rmSync(base, { recursive: true });
  fs.mkdirSync(base, { recursive: true });
});

afterEach(() => {
  if (fs.existsSync(base)) fs.rmSync(base, { recursive: true });
});

describe('KPI Aggregator', () => {
  it('computes success rate and p50 latency and writes outputs', async () => {
    const runs = [
      { run_id: 'r1', sha256: 'a', collected_at: '2025-11-13T00:00:00Z', status: 'success', latency_ms: 100 },
      { run_id: 'r2', sha256: 'b', collected_at: '2025-11-13T01:00:00Z', status: 'success', latency_ms: 200 },
      { run_id: 'r3', sha256: 'c', collected_at: '2025-11-13T02:00:00Z', status: 'failure', latency_ms: 300 },
    ];
    const runsSummaryPath = path.join(base, 'RUNS_SUMMARY.json');
    fs.writeFileSync(runsSummaryPath, JSON.stringify({ generated_at: new Date().toISOString(), total_runs: 3, runs }, null, 2), 'utf8');

    const auditJson = path.join(base, 'PHASE3_AUDIT_SUMMARY.json');
    await aggregateKpis(runsSummaryPath, auditJson, 'test-operator', 7, false);

    expect(fs.existsSync(auditJson)).toBe(true);
    const content = JSON.parse(fs.readFileSync(auditJson, 'utf8'));
    expect(content.total_runs).toBe(3);
    expect(content.success_count).toBe(2);
    expect(content.success_rate).toBeCloseTo((2/3)*100, 2);
    expect(content.p50_latency_ms).toBeGreaterThanOrEqual(100);
  });
});


