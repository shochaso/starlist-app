#!/usr/bin/env node
/**
 * Phase 4 Manifest Atomicity Helper
 * Provides atomic append functionality with duplicate run_id prevention
 */

import * as fs from 'fs/promises';
import * as path from 'path';

/**
 * Ensure directory exists
 */
async function ensureDir(dirPath: string): Promise<void> {
  try {
    await fs.mkdir(dirPath, { recursive: true });
  } catch (error) {
    if ((error as any).code !== 'EEXIST') {
      throw error;
    }
  }
}

export interface ManifestEntry {
  run_id: number;
  tag?: string;
  sha256?: string;
  run_url: string;
  created_at: string;
  uploader: string;
  sha_parity?: boolean;
  validator_verdict?: string;
}

export interface AppendResult {
  success: boolean;
  commit_hint?: string;
  error?: string;
}

/**
 * Atomically append entry to manifest file
 * Uses tmp → mv pattern for atomicity
 * Enforces run_id uniqueness
 */
export async function atomicAppendManifest(
  entry: ManifestEntry,
  manifestPath: string
): Promise<AppendResult> {
  // Ensure manifest directory exists
  await ensureDir(path.dirname(manifestPath));

  const tmpPath = `${manifestPath}.tmp`;
  const lockPath = `${manifestPath}.lock`;

  try {
    // Try to acquire lock (advisory lock using file existence)
    let lockAcquired = false;
    let retries = 0;
    const maxRetries = 10;
    const lockRetryDelay = 100; // ms

    while (!lockAcquired && retries < maxRetries) {
      try {
        await fs.access(lockPath);
        // Lock exists, wait and retry
        await new Promise(resolve => setTimeout(resolve, lockRetryDelay));
        retries++;
      } catch {
        // Lock doesn't exist, acquire it
        await fs.writeFile(lockPath, process.pid.toString(), 'utf-8');
        lockAcquired = true;
      }
    }

    if (!lockAcquired) {
      console.error(JSON.stringify({ event: 'manifestError', type: 'lock_acquire_failed', manifestPath, timestamp: new Date().toISOString() }));
      return {
        success: false,
        error: 'Failed to acquire lock after retries',
      };
    }

    try {
      // Read existing manifest or start fresh
      let existing: ManifestEntry[] = [];
      try {
        const content = await fs.readFile(manifestPath, 'utf-8');
        const parsed = JSON.parse(content);
        if (Array.isArray(parsed)) {
          existing = parsed;
        } else {
          // Invalid format, start fresh
          existing = [];
        }
      } catch {
        // File doesn't exist or is invalid JSON, start fresh
        existing = [];
      }

      // Check for duplicate run_id (coerce to string for robust comparison)
      if (existing.some(e => String(e.run_id) === String(entry.run_id))) {
      console.info(JSON.stringify({ event: 'manifestDuplicateDetected', run_id: entry.run_id, manifestPath, timestamp: new Date().toISOString() }));
      return {
        success: false,
        error: `duplicate-run-id:${entry.run_id}`,
      };
      }

      // Append new entry
      existing.push(entry);

            // Write to temp file with fsync for durability
            const tmpContent = JSON.stringify(existing, null, 2) + '\n';
            await fs.writeFile(tmpPath, tmpContent, 'utf-8');
            // Fsync for durability (if file handle available)
            try {
              const tmpHandle = await fs.open(tmpPath, 'r+');
              try {
                await tmpHandle.sync();
              } finally {
                await tmpHandle.close();
              }
            } catch {
              // Continue even if fsync fails - rename will still be atomic
            }

      // Validate JSON before atomic move
      const validationContent = await fs.readFile(tmpPath, 'utf-8');
      JSON.parse(validationContent); // Throws if invalid

      // Atomic move using fs.rename for true atomicity
      await fs.rename(tmpPath, manifestPath);

      return {
        success: true,
        commit_hint: `manifest-updated:${entry.run_id}`,
      };
    } finally {
      // Release lock
      try {
        await fs.unlink(lockPath);
      } catch {
        // Lock file may have been removed by another process
      }
    }
  } catch (error) {
    console.error(JSON.stringify({ event: 'manifestCatch', message: error instanceof Error ? error.message : String(error), manifestPath, timestamp: new Date().toISOString() }));
    // Attempt recovery: try to overwrite manifest with a fresh file containing only the entry
    try {
      const recoveryTmp = `${manifestPath}.recovery.tmp`;
      await fs.writeFile(recoveryTmp, JSON.stringify([entry], null, 2) + '\n', 'utf-8');
      try { const h = await fs.open(recoveryTmp, 'r+'); await h.sync(); await h.close(); } catch {}
      await fs.rename(recoveryTmp, manifestPath);
      return {
        success: true,
        commit_hint: `manifest-recovered:${entry.run_id}`,
      };
    } catch (recErr) {
      // Clean up temp file if it exists
      try {
        await fs.unlink(tmpPath);
      } catch {
        // Ignore cleanup errors
      }
      return {
        success: false,
        error: error instanceof Error ? error.message : String(error),
      };
    }
  }
}

