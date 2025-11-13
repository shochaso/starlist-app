/**
 * Unit tests for Phase 4 SHA Compare
 */

import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import * as fs from 'fs/promises';
import * as path from 'path';
import { computeSha256, compare } from '../../scripts/phase4/sha-compare';

describe('SHA Compare', () => {
  const testDir = path.join(process.cwd(), 'test-tmp');

  beforeEach(async () => {
    await fs.mkdir(testDir, { recursive: true });
  });

  afterEach(async () => {
    try {
      await fs.rm(testDir, { recursive: true, force: true });
    } catch {
      // Ignore cleanup errors
    }
  });

  it('should compute SHA256 correctly', async () => {
    const testFile = path.join(testDir, 'test.txt');
    await fs.writeFile(testFile, 'test content', 'utf-8');

    const sha = await computeSha256(testFile);
    expect(sha).toMatch(/^[a-f0-9]{64}$/);
  });

  it('should compare SHA256 with provenance metadata', async () => {
    const testContent = 'test artifact content';
    const artifactFile = path.join(testDir, 'artifact.bin');
    await fs.writeFile(artifactFile, testContent, 'utf-8');

    const computedSha = await computeSha256(artifactFile);

    const provFile = path.join(testDir, 'provenance.json');
    const provenance = {
      predicateType: 'https://slsa.dev/provenance/v0.2',
      metadata: {
        content_sha256: computedSha,
      },
    };
    await fs.writeFile(provFile, JSON.stringify(provenance), 'utf-8');

    const result = await compare(artifactFile, provFile);
    
    expect(result.computed_sha).toBe(computedSha);
    expect(result.metadata_sha).toBe(computedSha);
    expect(result.sha_parity).toBe(true);
  });

  it('should detect SHA mismatch', async () => {
    const artifactFile = path.join(testDir, 'artifact.bin');
    await fs.writeFile(artifactFile, 'content1', 'utf-8');

    const provFile = path.join(testDir, 'provenance.json');
    const provenance = {
      predicateType: 'https://slsa.dev/provenance/v0.2',
      metadata: {
        content_sha256: 'different_sha256_hash_that_does_not_match',
      },
    };
    await fs.writeFile(provFile, JSON.stringify(provenance), 'utf-8');

    const result = await compare(artifactFile, provFile);
    
    expect(result.sha_parity).toBe(false);
  });

  it('should handle missing metadata gracefully', async () => {
    const artifactFile = path.join(testDir, 'artifact.bin');
    await fs.writeFile(artifactFile, 'content', 'utf-8');

    const provFile = path.join(testDir, 'provenance.json');
    const provenance = {
      predicateType: 'https://slsa.dev/provenance/v0.2',
    };
    await fs.writeFile(provFile, JSON.stringify(provenance), 'utf-8');

    const result = await compare(artifactFile, provFile);
    
    expect(result.computed_sha).toBeTruthy();
    expect(result.metadata_sha).toBeNull();
    expect(result.sha_parity).toBeNull();
  });
});

