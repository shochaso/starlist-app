#!/usr/bin/env node
/**
 * Phase 4 KPI Aggregator
 * Aggregates metrics from RUNS_SUMMARY.json and generates PHASE3_AUDIT_SUMMARY.md
 */

import * as fs from 'fs/promises';
import * as path from 'path';
import { jstFolderNameForToday, nowUtcIso } from '../../lib/phase4/time';

interface RunSummary {
  run_id: number;
  tag?: string;
  sha256?: string;
  run_url: string;
  created_at: string;
  sha_parity?: boolean;
  validator_verdict?: string;
}

interface RunsSummaryData {
  generated_at: string;
  total_runs: number;
  runs: RunSummary[];
}

/**
 * Calculate percentile from sorted array
 */
function percentile(sorted: number[], p: number): number {
  if (sorted.length === 0) return 0;
  const index = Math.ceil((p / 100) * sorted.length) - 1;
  return sorted[Math.max(0, index)];
}

/**
 * Aggregate KPIs from RUNS_SUMMARY.json
 */
export async function aggregateKpis(
  runsSummaryPath: string,
  auditSummaryPath: string,
  operator: string = 'system'
): Promise<void> {
  let runsSummary: RunsSummaryData;

  try {
    const content = await fs.readFile(runsSummaryPath, 'utf-8');
    runsSummary = JSON.parse(content);
  } catch (error) {
    // If file doesn't exist, create empty summary
    runsSummary = {
      generated_at: nowUtcIso(),
      total_runs: 0,
      runs: [],
    };
  }

  const runs = runsSummary.runs || [];
  const totalRuns = runs.length;
  const successCount = runs.filter(r => r.validator_verdict === 'success').length;
  const successRate = totalRuns > 0 ? (successCount / totalRuns * 100).toFixed(2) : '0.00';
  
  const validatorPassCount = runs.filter(r => r.validator_verdict === 'success').length;
  const validatorTotal = runs.filter(r => r.validator_verdict).length;
  const validatorPassRate = validatorTotal > 0 
    ? (validatorPassCount / validatorTotal * 100).toFixed(2) 
    : '0.00';

  // Calculate latencies (placeholder - would need actual timing data)
  const latencies: number[] = []; // TODO: Extract from run metadata if available
  const p50Latency = latencies.length > 0 
    ? percentile([...latencies].sort((a, b) => a - b), 50).toFixed(2)
    : 'N/A';
  const p90Latency = latencies.length > 0
    ? percentile([...latencies].sort((a, b) => a - b), 90).toFixed(2)
    : 'N/A';

  const summary = `# Phase 3 Audit Summary

**Generated**: ${nowUtcIso()} (UTC)
**Operator**: ${operator}

## Summary Statistics

- **Total Runs**: ${totalRuns}
- **Success Count**: ${successCount}
- **Success Rate**: ${successRate}%
- **Validator Pass Count**: ${validatorPassCount}
- **Validator Pass Rate**: ${validatorPassRate}%
- **P50 Validation Latency**: ${p50Latency}s
- **P90 Validation Latency**: ${p90Latency}s

## Run Details

${runs.map(r => `- Run ${r.run_id}: ${r.run_url} (SHA Parity: ${r.sha_parity ?? 'N/A'}, Validator: ${r.validator_verdict ?? 'N/A'})`).join('\n')}

---

*Last updated: ${nowUtcIso()} (UTC)*
`;

  // Append to existing file or create new
  try {
    await fs.appendFile(auditSummaryPath, summary + '\n\n', 'utf-8');
  } catch {
    // File doesn't exist, create it
    await fs.writeFile(auditSummaryPath, summary + '\n\n', 'utf-8');
  }
}

async function main() {
  const reportDir = process.env.REPORT_DIR || path.join(process.cwd(), 'docs/reports', jstFolderNameForToday());
  const runsSummaryPath = path.join(reportDir, 'RUNS_SUMMARY.json');
  const auditSummaryPath = path.join(reportDir, 'PHASE3_AUDIT_SUMMARY.md');
  const operator = process.env.GITHUB_ACTOR || 'local';

  await aggregateKpis(runsSummaryPath, auditSummaryPath, operator);
  console.log('KPI aggregation completed');
}

if (require.main === module) {
  main().catch(console.error);
}

