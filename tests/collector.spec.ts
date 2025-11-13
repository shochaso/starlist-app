import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import * as fs from 'fs';
import * as path from 'path';
import { collectRun } from '../scripts/phase4/collector/collect';

const base = path.join(__dirname, 'tmp_collector');

beforeEach(() => {
  if (fs.existsSync(base)) fs.rmSync(base, { recursive: true });
  fs.mkdirSync(base, { recursive: true });
});

afterEach(() => {
  if (fs.existsSync(base)) fs.rmSync(base, { recursive: true });
});

describe('collector collectRun dry-run', () => {
  it('creates fixture artifact and does not write manifest', async () => {
    const runId = 'r-dry-1';
    const res = await collectRun(runId, base, true);
    expect(res.status).toBe('dry-run');

    const artifact = path.join(base, 'artifacts', runId, 'artifact.bin');
    expect(fs.existsSync(artifact)).toBe(true);

    const manifest = path.join(base, '_manifest.json');
    expect(fs.existsSync(manifest)).toBe(false);

    const runsSummary = path.join(base, 'RUNS_SUMMARY.json');
    expect(fs.existsSync(runsSummary)).toBe(false);
  });
});


