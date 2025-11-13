import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import * as fs from 'fs';
import * as path from 'path';
import { collectRun } from '../scripts/phase4/collector/collect';
import { createHash } from 'crypto';

const base = path.join(__dirname, 'tmp_collector_normal');

beforeEach(() => {
  if (fs.existsSync(base)) fs.rmSync(base, { recursive: true });
  fs.mkdirSync(base, { recursive: true });
});

afterEach(() => {
  if (fs.existsSync(base)) fs.rmSync(base, { recursive: true });
});

describe('collector normal run', () => {
  it('writes manifest and RUNS_SUMMARY when provenance matches', async () => {
    const runId = 'r-normal-1';
    const artifactsDir = path.join(base, 'artifacts', runId);
    fs.mkdirSync(artifactsDir, { recursive: true });

    const artifactPath = path.join(artifactsDir, 'artifact.bin');
    const content = 'real-artifact-content';
    fs.writeFileSync(artifactPath, content, 'utf8');

    const sha = createHash('sha256').update(Buffer.from(content)).digest('hex');
    const prov = {
      metadata: { content_sha256: sha },
    };
    fs.writeFileSync(path.join(artifactsDir, 'provenance.json'), JSON.stringify(prov), 'utf8');

    const res = await collectRun(runId, base, false);
    expect(res.status).toBe('collected');

    const manifest = path.join(base, '_manifest.json');
    expect(fs.existsSync(manifest)).toBe(true);
    const manifestContent = JSON.parse(fs.readFileSync(manifest, 'utf8'));
    // manifest run_id may be string or number; compare loosely
    expect(manifestContent.some((e: any) => String(e.run_id) === runId)).toBe(true);

    const runs = path.join(base, 'RUNS_SUMMARY.json');
    expect(fs.existsSync(runs)).toBe(true);
    const runsContent = JSON.parse(fs.readFileSync(runs, 'utf8'));
    expect(runsContent.some((r: any) => String(r.run_id) === runId && r.sha256 === sha)).toBe(true);
  });
});


