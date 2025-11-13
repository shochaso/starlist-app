#!/usr/bin/env node
/**
 * Phase 4 Manifest Atomicity Helper
 * Provides atomic append functionality with duplicate run_id prevention
 */

import * as fs from 'fs/promises';
import * as path from 'path';

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

      // Check for duplicate run_id
      if (existing.some(e => e.run_id === entry.run_id)) {
        return {
          success: false,
          error: `duplicate-run-id:${entry.run_id}`,
        };
      }

      // Append new entry
      existing.push(entry);

      // Write to temp file with fsync for durability
      const tmpContent = JSON.stringify(existing, null, 2) + '\n';
      const tmpHandle = await fs.open(tmpPath, 'w');
      try {
        await tmpHandle.write(tmpContent, 0, 'utf-8');
        // Fsync to ensure data is written to disk before rename
        try {
          await tmpHandle.sync();
        } catch (fsyncError) {
          // Continue even if fsync fails - rename will still be atomic
        }
      } finally {
        await tmpHandle.close();
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

