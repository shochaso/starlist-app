#!/usr/bin/env node
/**
 * Phase 4 KPI Aggregator - improved
 * Reads RUNS_SUMMARY.json and writes PHASE3_AUDIT_SUMMARY.json/.md
 */

import * as fs from 'fs/promises';
import * as path from 'path';
import { jstFolderNameForToday, nowUtcIso } from '../../../lib/phase4/time';

interface RunSummary {
  run_id: string | number;
  tag?: string;
  sha256?: string;
  run_url?: string;
  created_at?: string;
  collected_at?: string;
  sha_parity?: boolean;
  validator_verdict?: string;
  latency_ms?: number;
  status?: string;
}

interface RunsSummaryData {
  generated_at: string;
  total_runs: number;
  runs: RunSummary[];
}

function percentile(sorted: number[], p: number): number {
  if (sorted.length === 0) return 0;
  const rank = (p / 100) * (sorted.length - 1);
  const lower = Math.floor(rank);
  const upper = Math.ceil(rank);
  if (lower === upper) return sorted[lower];
  const weight = rank - lower;
  return Math.round(sorted[lower] * (1 - weight) + sorted[upper] * weight);
}

async function atomicWriteFile(filePath: string, content: string) {
  const tmp = `${filePath}.tmp`;
  const fh = await fs.open(tmp, 'w');
  try {
    await fh.writeFile(content, 'utf-8');
    try { await fh.sync(); } catch {}
  } finally {
    await fh.close();
  }
  await fs.rename(tmp, filePath);
}

export async function aggregateKpis(
  runsSummaryPath: string,
  auditSummaryPath: string,
  operator: string = 'system',
  windowDays: number = 7,
  dryRun: boolean = false
): Promise<{ successRate: number; p50: number | 'N/A'; totalRuns: number }> {
  let runsSummary: RunsSummaryData = { generated_at: nowUtcIso(), total_runs: 0, runs: [] };
  try {
    const content = await fs.readFile(runsSummaryPath, 'utf-8');
    runsSummary = JSON.parse(content);
  } catch {
    runsSummary = { generated_at: nowUtcIso(), total_runs: 0, runs: [] };
  }

  const cutoff = new Date();
  cutoff.setDate(cutoff.getDate() - windowDays);

  const runs = (runsSummary.runs || []).filter(r => {
    const ts = r.collected_at || r.created_at;
    if (!ts) return true;
    const d = new Date(ts);
    return d >= cutoff;
  });

  const totalRuns = runs.length;
  const successCount = runs.filter(r => (r.status === 'success') || (r.match === true) || (r.validator_verdict === 'success') || (r.sha_parity === true)).length;
  const successRate = totalRuns > 0 ? +(successCount / totalRuns * 100) : 0;

  const latencies = runs.map(r => (typeof r.latency_ms === 'number' ? r.latency_ms : NaN)).filter(n => !isNaN(n)).sort((a,b)=>a-b);
  const p50 = latencies.length > 0 ? percentile(latencies, 50) : 'N/A';
  const p90 = latencies.length > 0 ? percentile(latencies, 90) : 'N/A';

  const failures = runs.filter(r => (r.status && r.status !== 'success') || (r.sha_parity === false) || (r.validator_verdict && r.validator_verdict !== 'success'))
    .map(r => ({ run_id: r.run_id, reason: r.validator_verdict ?? (r.sha_parity === false ? 'sha-mismatch' : 'failure') }));

  const result = {
    generated_at: nowUtcIso(),
    operator,
    total_runs: totalRuns,
    success_count: successCount,
    success_rate: successRate,
    p50_latency_ms: p50,
    p90_latency_ms: p90,
    failures,
    runs: runs.map(r => ({ run_id: r.run_id, sha256: r.sha256, collected_at: r.collected_at || r.created_at, run_url: r.run_url })),
  };

  console.info(JSON.stringify({ event: 'kpiComputed', ...result }));

  if (!dryRun) {
    const jsonOut = auditSummaryPath.replace(/\.md$|\.json$/i, '.json');
    const mdOut = auditSummaryPath.replace(/\.json$/i, '.md');
    await atomicWriteFile(jsonOut, JSON.stringify(result, null, 2));
    const md = `# Phase 3 Audit Summary

**Generated**: ${nowUtcIso()} (UTC)
**Operator**: ${operator}

## Summary Statistics

- **Total Runs**: ${totalRuns}
- **Success Count**: ${successCount}
- **Success Rate**: ${successRate.toFixed(2)}%
- **P50 Latency (ms)**: ${p50}
- **P90 Latency (ms)**: ${p90}

## Failures

${failures.map(f => `- ${f.run_id}: ${f.reason}`).join('\n')}

## Run Details

${result.runs.map(r => `- Run ${r.run_id}: ${r.run_url ?? ''} (sha=${r.sha256 ?? 'N/A'})`).join('\n')}

*Last updated: ${nowUtcIso()} (UTC)*
`;
    await atomicWriteFile(mdOut, md);
  }

  return { successRate, p50, totalRuns };
}

async function main() {
  const argv = process.argv.slice(2);
  const args: Record<string,string|boolean> = {};
  for (let i=0;i<argv.length;i++){
    const a = argv[i];
    if (a.startsWith('--')) {
      const k = a.replace(/^--/,'');
      const v = argv[i+1];
      if (v && !v.startsWith('--')) { args[k]=v; i++; } else args[k]=true;
    }
  }
  const baseDir = String(args['base-dir'] ?? path.join(process.cwd(),'docs','reports', jstFolderNameForToday()));
  const windowDays = Number(args['window-days'] ?? 7);
  const dryRun = Boolean(args['dry-run'] ?? false);
  const runsSummaryPath = path.join(baseDir, 'RUNS_SUMMARY.json');
  const auditSummaryPath = path.join(baseDir, 'PHASE3_AUDIT_SUMMARY.json');
  try {
    await aggregateKpis(runsSummaryPath, auditSummaryPath, process.env.GITHUB_ACTOR || 'local', windowDays, dryRun);
    console.info(JSON.stringify({ event:'kpiCompleted', baseDir, windowDays, dryRun, ts: nowUtcIso() }));
  } catch (e:any) {
    console.error(JSON.stringify({ event:'kpiError', message: String(e?.message ?? e), ts: nowUtcIso() }));
    process.exit(1);
  }
}

if (require.main === module) {
  main().catch(console.error);
}

