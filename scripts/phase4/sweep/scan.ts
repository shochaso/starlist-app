#!/usr/bin/env node
/**
 * Phase 4 Security Sweep
 * Scans evidence files for token-like patterns
 */

import * as fs from 'fs/promises';
import * as path from 'path';

const PATTERNS = [
  /token[=:]\s*[^\s]+/i,
  /Bearer\s+[A-Za-z0-9_-]+/i,
  /key[=:]\s*[^\s]+/i,
  /x-access[=:]\s*[^\s]+/i,
];

const SCAN_EXTENSIONS = ['.log', '.txt', '.json'];

/**
 * Check if file should be scanned
 */
function shouldScan(filePath: string): boolean {
  const ext = path.extname(filePath);
  return SCAN_EXTENSIONS.includes(ext);
}

/**
 * Scan file for token-like patterns
 */
async function scanFile(filePath: string): Promise<string[]> {
  const findings: string[] = [];
  
  try {
    const content = await fs.readFile(filePath, 'utf-8');
    
    for (const pattern of PATTERNS) {
      const matches = content.match(pattern);
      if (matches) {
        findings.push(...matches);
      }
    }
  } catch (error) {
    // Skip files that can't be read
  }

  return findings;
}

/**
 * Recursively scan directory for token-like patterns
 */
async function scanDirectory(dirPath: string): Promise<{ file: string; findings: string[] }[]> {
  const results: { file: string; findings: string[] }[] = [];
  
  try {
    const entries = await fs.readdir(dirPath, { withFileTypes: true });
    
    for (const entry of entries) {
      const fullPath = path.join(dirPath, entry.name);
      
      if (entry.isDirectory()) {
        // Skip node_modules and .git
        if (entry.name === 'node_modules' || entry.name === '.git') {
          continue;
        }
        const subResults = await scanDirectory(fullPath);
        results.push(...subResults);
      } else if (entry.isFile() && shouldScan(fullPath)) {
        const findings = await scanFile(fullPath);
        if (findings.length > 0) {
          results.push({ file: fullPath, findings });
        }
      }
    }
  } catch (error) {
    // Skip directories that can't be read
  }

  return results;
}

async function main() {
  const reportDir = process.env.REPORT_DIR || path.join(process.cwd(), 'docs/reports/2025-11-14');
  
  console.log(JSON.stringify({ event: 'sweepStarted', directory: reportDir }));

  const results = await scanDirectory(reportDir);

  if (results.length > 0) {
    console.error(JSON.stringify({ 
      event: 'sweepFound', 
      count: results.length,
      files: results.map(r => ({ file: r.file, findings: r.findings.length }))
    }));
    process.exit(2);
  } else {
    console.log(JSON.stringify({ event: 'sweepClean' }));
    process.exit(0);
  }
}

if (require.main === module) {
  main().catch(error => {
    console.error(JSON.stringify({ event: 'sweepError', error: String(error) }));
    process.exit(1);
  });
}

