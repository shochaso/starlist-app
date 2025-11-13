#!/usr/bin/env node
/**
 * Phase 4 SHA Compare CLI
 * Compares computed SHA256 with provenance metadata SHA256
 */

import * as fs from 'fs/promises';
import * as path from 'path';
import { createHash } from 'crypto';

interface CompareResult {
  computed_sha: string;
  metadata_sha: string | null;
  sha_parity: boolean | null;
  run_id?: string;
}

/**
 * Compute SHA256 of a file
 */
export async function computeSha256(filePath: string): Promise<string> {
  const content = await fs.readFile(filePath);
  return createHash('sha256').update(content).digest('hex');
}

/**
 * Compare artifact SHA256 with provenance metadata SHA256
 */
export async function compare(
  artifactPath: string,
  provPath: string
): Promise<CompareResult> {
  const computedSha = await computeSha256(artifactPath);

  let metadataSha: string | null = null;
  try {
    const provContent = await fs.readFile(provPath, 'utf-8');
    const prov = JSON.parse(provContent);
    metadataSha = prov.metadata?.content_sha256 || null;
  } catch {
    // Provenance file not found or invalid
  }

  const shaParity = metadataSha ? computedSha === metadataSha : null;

  return {
    computed_sha: computedSha,
    metadata_sha: metadataSha,
    sha_parity: shaParity,
  };
}

async function main() {
  const args = process.argv.slice(2);
  let artifactPath: string | undefined;
  let provPath: string | undefined;

  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--artifact' && i + 1 < args.length) {
      artifactPath = args[i + 1];
      i++;
    } else if (args[i] === '--prov' && i + 1 < args.length) {
      provPath = args[i + 1];
      i++;
    }
  }

  if (!artifactPath || !provPath) {
    console.error('Usage: sha-compare.ts --artifact <path> --prov <path>');
    process.exit(1);
  }

  try {
    const result = await compare(artifactPath, provPath);
    console.log(JSON.stringify(result, null, 2));
  } catch (error) {
    console.error(`Error: ${error}`);
    process.exit(1);
  }
}

if (require.main === module) {
  main().catch(console.error);
}

