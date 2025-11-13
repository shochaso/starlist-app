#!/usr/bin/env node
/**
 * Phase 4 Evidence Collector
 * Collects run logs, artifacts, and SHA comparison results
 */

import * as fs from 'fs/promises';
import * as path from 'path';
import { execSync } from 'child_process';

interface CollectConfig {
  reportDir: string;
  runIds?: number[];
}

async function collectRunLogs(runId: number, reportDir: string, dryRun: boolean = false): Promise<void> {
  const logDir = path.join(reportDir, 'logs');
  const logPath = path.join(logDir, `run_${runId}.log`);
  
  if (dryRun) {
    console.info(JSON.stringify({ event: 'dry_run_collect_logs', run_id: runId, log_path: logPath }));
    return;
  }

  await fs.mkdir(logDir, { recursive: true });
  
  try {
    execSync(`gh run view ${runId} --log > "${logPath}"`, { stdio: 'inherit' });
  } catch (error) {
    console.warn(`Failed to collect logs for run ${runId}: ${error}`);
  }
}

async function collectArtifactListing(runId: number, reportDir: string, dryRun: boolean = false): Promise<void> {
  const artifactDir = path.join(reportDir, 'artifacts', String(runId));
  const listingPath = path.join(artifactDir, 'artifact_listing.json');
  
  if (dryRun) {
    console.info(JSON.stringify({ event: 'dry_run_collect_artifacts', run_id: runId, listing_path: listingPath }));
    return;
  }

  await fs.mkdir(artifactDir, { recursive: true });
  
  try {
    const output = execSync(
      `gh run view ${runId} --json artifacts --jq '.artifacts'`,
      { encoding: 'utf-8' }
    );
    await fs.writeFile(listingPath, output, 'utf-8');
  } catch (error) {
    console.warn(`Failed to collect artifact listing for run ${runId}: ${error}`);
  }
}

async function collectSHACompare(runId: number, reportDir: string, dryRun: boolean = false): Promise<void> {
  const artifactDir = path.join(reportDir, 'artifacts', String(runId));
  const shaComparePath = path.join(artifactDir, 'sha_compare.json');
  
  if (dryRun) {
    console.info(JSON.stringify({ event: 'dry_run_sha_compare', run_id: runId }));
    return;
  }
  
  try {
    const files = await fs.readdir(artifactDir, { recursive: true });
    const provenanceFiles = files.filter(f => f.includes('provenance') && f.endsWith('.json'));
    
    if (provenanceFiles.length === 0) {
      return;
    }

    const results = [];
    for (const file of provenanceFiles) {
      const filePath = path.join(artifactDir, file);
      
      try {
        const result = await compare(filePath, filePath);
        results.push({ ...result, run_id: runId, file });
      } catch (error) {
        console.warn(`Failed to compare SHA for ${file}: ${error}`);
      }
    }
    
    if (results.length > 0) {
      await fs.writeFile(shaComparePath, JSON.stringify(results, null, 2), 'utf-8');
    }
  } catch (error) {
    console.warn(`Failed to collect SHA compare for run ${runId}: ${error}`);
  }
}

async function extractSlackExcerpts(runId: number, reportDir: string, dryRun: boolean = false): Promise<void> {
  const logPath = path.join(reportDir, 'logs', `run_${runId}.log`);
  const excerptPath = path.join(reportDir, 'slack_excerpts', `${runId}.log`);
  
  if (dryRun) {
    console.info(JSON.stringify({ event: 'dry_run_extract_slack', run_id: runId }));
    return;
  }
  
  await fs.mkdir(path.dirname(excerptPath), { recursive: true });
  
  try {
    const logContent = await fs.readFile(logPath, 'utf-8');
    const lines = logContent.split('\n');
    
    const excerpts: string[] = [];
    for (const line of lines) {
      if (line.match(/slack|webhook|POST/i)) {
        // Extract HTTP status code
        const statusMatch = line.match(/(\d{3})/);
        const status = statusMatch ? statusMatch[1] : 'N/A';
        
        // Extract timestamp
        const timeMatch = line.match(/(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})/);
        const timestamp = timeMatch ? timeMatch[1] : 'N/A';
        
        // Extract summary (first 100 chars)
        const summary = line.substring(0, 100).replace(/https?:\/\/[^\s]+/g, '[URL_MASKED]');
        
        excerpts.push(`[${timestamp}] HTTP ${status}: ${summary}`);
      }
    }
    
    if (excerpts.length > 0) {
      await fs.writeFile(excerptPath, excerpts.join('\n'), 'utf-8');
    }
  } catch (error) {
    console.warn(`Failed to extract Slack excerpts for run ${runId}: ${error}`);
  }
}

async function updateEvidenceIndex(reportDir: string): Promise<void> {
  const indexPath = path.join(reportDir, '_evidence_index.md');
  const artifactsDir = path.join(reportDir, 'artifacts');
  const logsDir = path.join(reportDir, 'logs');
  const excerptsDir = path.join(reportDir, 'slack_excerpts');
  
  // Import time helper dynamically
  const { nowUtcIso } = await import('../../lib/phase4/time');
  
  let indexContent = `# Evidence Index

**Last Updated**: ${nowUtcIso()} (UTC)

## Evidence Files

### Generated Files

- \`_manifest.json\`: Run manifest with atomic updates
- \`RUNS_SUMMARY.json\`: Summary of all runs
- \`PHASE3_AUDIT_SUMMARY.md\`: Audit summary with KPI metrics
- \`slack_excerpts/<run_id>.log\`: Masked Slack excerpts (HTTP codes, timestamps, summaries only)

## Run Evidence

`;

  try {
    const runDirs = await fs.readdir(artifactsDir);
    for (const runDir of runDirs) {
      const runId = runDir;
      indexContent += `### Run ${runId}\n\n`;
      indexContent += `- Artifacts: [./artifacts/${runId}/](./artifacts/${runId}/)\n`;
      indexContent += `- Logs: [./logs/run_${runId}.log](./logs/run_${runId}.log)\n`;
      
      try {
        await fs.access(path.join(excerptsDir, `${runId}.log`));
        indexContent += `- Slack Excerpts: [./slack_excerpts/${runId}.log](./slack_excerpts/${runId}.log)\n`;
      } catch {
        // File doesn't exist
      }
      
      indexContent += '\n';
    }
  } catch {
    // Directory doesn't exist yet
  }

  await fs.writeFile(indexPath, indexContent, 'utf-8');
}

async function discoverRunIds(): Promise<number[]> {
  try {
    const output = execSync(
      'gh run list --workflow slsa-provenance.yml --limit 50 --json databaseId --jq ".[].databaseId"',
      { encoding: 'utf-8' }
    );
    return output.trim().split('\n').map(id => parseInt(id, 10)).filter(id => !isNaN(id));
  } catch {
    return [];
  }
}

export async function collect(runId: string | number, dryRun: boolean = false): Promise<void> {
  const reportDir = process.env.REPORT_DIR || path.join(process.cwd(), 'docs/reports', jstFolderNameForToday());
  const runIdNum = typeof runId === 'string' ? parseInt(runId, 10) : runId;
  
  console.log(`Collecting evidence for run ${runIdNum}...`);
  
  await collectRunLogs(runIdNum, reportDir, dryRun);
  await collectArtifactListing(runIdNum, reportDir, dryRun);
  await collectSHACompare(runIdNum, reportDir, dryRun);
  await extractSlackExcerpts(runIdNum, reportDir, dryRun);
}

async function main() {
  const reportDir = process.env.REPORT_DIR || path.join(process.cwd(), 'docs/reports', jstFolderNameForToday());
  const runIdsEnv = process.env.RUN_IDS;
  const dryRun = process.argv.includes('--dry-run') || process.env.DRY_RUN === 'true';
  
  const config: CollectConfig = {
    reportDir,
    runIds: runIdsEnv ? runIdsEnv.split(',').map(id => parseInt(id, 10)) : undefined,
  };

  const runIds = config.runIds || await discoverRunIds();
  
  if (dryRun) {
    console.log(`Dry run: Would collect evidence for ${runIds.length} runs`);
    return;
  }
  
  console.log(`Collecting evidence for ${runIds.length} runs...`);

  for (const runId of runIds) {
    console.log(`Processing run ${runId}...`);
    await collect(runId, dryRun);
  }

  if (!dryRun) {
    await updateEvidenceIndex(reportDir);
  }
  console.log('Evidence collection completed');
}

if (require.main === module) {
  main().catch(console.error);
}

