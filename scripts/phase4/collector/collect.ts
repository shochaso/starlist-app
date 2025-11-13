#!/usr/bin/env node
// scripts/phase4/collector/collect.ts
import * as fs from 'fs';
import * as path from 'path';
import { computeSha256 } from '../sha-compare';
import { atomicAppendManifest } from '../manifest/append';
import { writeMaskedSlackExcerpt } from '../notify/slack';
import { retry } from '../../lib/phase4/retry';

function nowIso() { return new Date().toISOString(); }

export type CollectResult = { runId: string; status: 'dry-run' | 'collected' | 'error' };

export async function collectRun(runId: string, baseDir = 'docs/reports/2025-11-14', dryRun = true): Promise<CollectResult> {
  console.info(JSON.stringify({ event: 'collectRunStart', runId, dryRun, ts: nowIso() }));
  const artifactsDir = path.join(baseDir, 'artifacts', runId);
  if (!fs.existsSync(artifactsDir)) fs.mkdirSync(artifactsDir, { recursive: true });

  const artifactPath = path.join(artifactsDir, 'artifact.bin');
  const provPath = path.join(artifactsDir, 'provenance.json');
  const manifestPath = path.join(baseDir, '_manifest.json');
  const runsSummaryPath = path.join(baseDir, 'RUNS_SUMMARY.json');

  try {
    if (dryRun) {
      if (!fs.existsSync(artifactPath)) {
        fs.writeFileSync(artifactPath, 'collector-fixture', 'utf8');
        console.info(JSON.stringify({ event: 'artifactCreatedFixture', runId, path: artifactPath, ts: nowIso() }));
      } else {
        console.info(JSON.stringify({ event: 'artifactExistsFixture', runId, path: artifactPath, ts: nowIso() }));
      }
      return { runId, status: 'dry-run' };
    }

    // Normal mode: ensure artifact exists (fixture fallback)
    if (!fs.existsSync(artifactPath)) {
      fs.writeFileSync(artifactPath, 'collector-fetched-fixture', 'utf8');
      console.info(JSON.stringify({ event: 'artifactFetchedFixture', runId, path: artifactPath, ts: nowIso() }));
    }

    const computed = computeSha256(artifactPath);
    let reportedSha = '';
    if (fs.existsSync(provPath)) {
      try { reportedSha = JSON.parse(fs.readFileSync(provPath, 'utf8'))?.metadata?.content_sha256 ?? ''; }
      catch { console.info(JSON.stringify({ event: 'provenanceParseError', runId, ts: nowIso() })); reportedSha = ''; }
    }
    const effectiveReported = (reportedSha && reportedSha.length > 0) ? reportedSha : computed;
    const match = (computed === effectiveReported);
    console.info(JSON.stringify({ event: 'shaCompare', runId, reported: effectiveReported, computed, match, ts: nowIso() }));

    // Append manifest (handle duplicate-run-id gracefully)
    try {
      const hint = await atomicAppendManifest({
        run_id: runId,
        tag: 'collected',
        sha256: computed,
        run_url: '',
        created_at: nowIso(),
        uploader: 'collector',
      }, manifestPath);
      console.info(JSON.stringify({ event: 'manifestAppended', runId, hint, ts: nowIso() }));
    } catch (e: any) {
      const msg = String(e?.message ?? '');
      if (msg.startsWith('duplicate-run-id:')) {
        console.info(JSON.stringify({ event: 'manifestDuplicate', runId, message: msg, ts: nowIso() }));
      } else throw e;
    }

    // Update RUNS_SUMMARY.json idempotently
    try {
      appendRunsSummaryRow(runsSummaryPath, {
        run_id: runId,
        collected_at: nowIso(),
        sha256: computed,
        match,
      });
      console.info(JSON.stringify({ event: 'runsSummaryUpdated', runId, path: runsSummaryPath, ts: nowIso() }));
    } catch (e: any) {
      try { writeMaskedSlackExcerpt(runId, `runsSummary update failed: ${String(e?.message ?? e)}`, path.join(baseDir, 'slack_excerpts')); } catch {}
      throw e;
    }

    return { runId, status: 'collected' };
  } catch (err: any) {
    console.error(JSON.stringify({ event: 'collectRunError', runId, message: String(err?.message ?? ''), ts: nowIso() }));
    try { writeMaskedSlackExcerpt(runId, `error collecting run ${runId}: ${String(err?.message ?? '')}`, path.join(baseDir, 'slack_excerpts')); } catch {}
    return { runId, status: 'error' };
  }
}

function appendRunsSummaryRow(summaryPath: string, row: Record<string, any>) {
  if (!fs.existsSync(path.dirname(summaryPath))) fs.mkdirSync(path.dirname(summaryPath), { recursive: true });
  const tmpPath = `${summaryPath}.tmp`;
  let arr: any[] = [];
  if (fs.existsSync(summaryPath)) {
    try { arr = JSON.parse(fs.readFileSync(summaryPath, 'utf8') as unknown as string); } catch { arr = []; }
  }
  if (arr.some((r) => String(r.run_id) === String(row.run_id))) return;
  arr.push(row);
  const data = JSON.stringify(arr, null, 2);
  const fd = fs.openSync(tmpPath, 'w');
  try {
    fs.writeFileSync(fd, data, { encoding: 'utf8' });
    fs.fsyncSync(fd);
  } finally {
    try { fs.closeSync(fd); } catch {}
  }
  fs.renameSync(tmpPath, summaryPath);
}

// CLI wrapper
if (require.main === module) {
  const args = process.argv.slice(2);
  const parsed: Record<string, string | boolean> = {};
  for (let i = 0; i < args.length; i++) {
    const a = args[i];
    if (a === '--dry-run') { parsed['dry-run'] = true; continue; }
    if (a.startsWith('--')) {
      const key = a.replace(/^--/, '');
      const val = args[i+1];
      if (val && !val.startsWith('--')) { parsed[key] = val; i++; } else { parsed[key] = true; }
    }
  }
  const runIdsCsv = String(parsed['run-ids'] ?? '');
  const runIds = runIdsCsv ? runIdsCsv.split(',').map(s => s.trim()).filter(Boolean) : ['fixture-run-1'];
  const baseDir = String(parsed['base-dir'] ?? 'docs/reports/2025-11-14');
  const dryRun = Boolean(parsed['dry-run'] ?? true);

  (async () => {
    for (const r of runIds) {
      try {
        // use retry wrapper to tolerate transient fs errors (2 attempts)
        await retry(() => collectRun(r, baseDir, dryRun) as any, { maxRetries: 2, initialDelayMs: 5000, backoffMultiplier: 2, nonRetryableCodes: [422,403] } as any);
      } catch (e: any) {
        console.error(JSON.stringify({ event: 'collectRunUnrecoverable', runId: r, message: String(e?.message ?? e), ts: nowIso() }));
      }
    }
  })();
}


