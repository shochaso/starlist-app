/**
 * Unit tests for Phase 4 Manifest Atomicity
 */

import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import * as fs from 'fs/promises';
import * as path from 'path';
import { atomicAppendManifest, ManifestEntry } from '../../scripts/phase4/manifest/append';

describe('Manifest Atomicity', () => {
  const testDir = path.join(process.cwd(), 'test-tmp');
  const manifestPath = path.join(testDir, '_manifest.json');

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

  it('should create new manifest file', async () => {
    const entry: ManifestEntry = {
      run_id: 123,
      run_url: 'https://example.com/run/123',
      created_at: '2025-11-14T10:00:00Z',
      uploader: 'test',
    };

    const result = await atomicAppendManifest(entry, manifestPath);
    
    expect(result.success).toBe(true);
    
    const content = await fs.readFile(manifestPath, 'utf-8');
    const manifest = JSON.parse(content);
    expect(manifest).toHaveLength(1);
    expect(manifest[0].run_id).toBe(123);
  });

  it('should append to existing manifest', async () => {
    const existing: ManifestEntry[] = [{
      run_id: 100,
      run_url: 'https://example.com/run/100',
      created_at: '2025-11-14T09:00:00Z',
      uploader: 'test',
    }];
    
    await fs.writeFile(manifestPath, JSON.stringify(existing, null, 2), 'utf-8');

    const entry: ManifestEntry = {
      run_id: 200,
      run_url: 'https://example.com/run/200',
      created_at: '2025-11-14T10:00:00Z',
      uploader: 'test',
    };

    const result = await atomicAppendManifest(entry, manifestPath);
    
    expect(result.success).toBe(true);
    
    const content = await fs.readFile(manifestPath, 'utf-8');
    const manifest = JSON.parse(content);
    expect(manifest).toHaveLength(2);
    expect(manifest[0].run_id).toBe(100);
    expect(manifest[1].run_id).toBe(200);
  });

  it('should reject duplicate run_id', async () => {
    const existing: ManifestEntry[] = [{
      run_id: 123,
      run_url: 'https://example.com/run/123',
      created_at: '2025-11-14T09:00:00Z',
      uploader: 'test',
    }];
    
    await fs.writeFile(manifestPath, JSON.stringify(existing, null, 2), 'utf-8');

    const entry: ManifestEntry = {
      run_id: 123,
      run_url: 'https://example.com/run/123',
      created_at: '2025-11-14T10:00:00Z',
      uploader: 'test',
    };

    const result = await atomicAppendManifest(entry, manifestPath);
    
    expect(result.success).toBe(false);
    expect(result.error).toContain('duplicate-run-id:123');
    
    const content = await fs.readFile(manifestPath, 'utf-8');
    const manifest = JSON.parse(content);
    expect(manifest).toHaveLength(1); // Should not have added duplicate
  });

  it('should handle invalid JSON gracefully', async () => {
    await fs.writeFile(manifestPath, 'invalid json', 'utf-8');

    const entry: ManifestEntry = {
      run_id: 123,
      run_url: 'https://example.com/run/123',
      created_at: '2025-11-14T10:00:00Z',
      uploader: 'test',
    };

    const result = await atomicAppendManifest(entry, manifestPath);
    
    expect(result.success).toBe(true); // Should start fresh
    
    const content = await fs.readFile(manifestPath, 'utf-8');
    const manifest = JSON.parse(content);
    expect(manifest).toHaveLength(1);
  });
});

