import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import * as fs from 'fs';
import * as path from 'path';
import { collectRun } from '../scripts/phase4/collector/collect';

const base = path.join(__dirname, 'tmp_collector_download');

beforeEach(() => {
  if (fs.existsSync(base)) fs.rmSync(base, { recursive: true });
  fs.mkdirSync(base, { recursive: true });
});

afterEach(() => {
  if (fs.existsSync(base)) fs.rmSync(base, { recursive: true });
});

describe('collector download fallback (file://)', () => {
  it('downloads from file:// URL and updates manifests', async () => {
    const runId = 'r-download-1';
    // create a source fixture
    const srcDir = path.join(base, 'src');
    fs.mkdirSync(srcDir, { recursive: true });
    const srcFile = path.join(srcDir, 'artifact.bin');
    const content = 'download-content';
    fs.writeFileSync(srcFile, content, 'utf8');
    const fileUrl = `file://${srcFile}`;

    // set artifact map env to point to a JSON file mapping runId->file://...
    const mapPath = path.join(base, 'artifact_map.json');
    fs.writeFileSync(mapPath, JSON.stringify({ [runId]: fileUrl }), 'utf8');
    process.env.PHASE4_ARTIFACT_MAP = mapPath;

    const res = await collectRun(runId, base, false);
    expect(res.status).toBe('collected');

    const artifact = path.join(base, 'artifacts', runId, 'artifact.bin');
    expect(fs.existsSync(artifact)).toBe(true);
    const got = fs.readFileSync(artifact, 'utf8');
    expect(got).toBe(content);

    const manifest = path.join(base, '_manifest.json');
    expect(fs.existsSync(manifest)).toBe(true);
    const runs = path.join(base, 'RUNS_SUMMARY.json');
    expect(fs.existsSync(runs)).toBe(true);
  });
});


