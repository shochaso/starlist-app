/**
 * Unit tests for Phase 4 Observer
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';
import * as fs from 'fs/promises';
import * as path from 'path';
import { runObserver } from '../../scripts/phase4/observer/index';

// Mock dependencies
vi.mock('child_process', () => ({
  execSync: vi.fn(),
}));

vi.mock('fs/promises', () => ({
  default: {
    mkdir: vi.fn(),
    readFile: vi.fn(),
    writeFile: vi.fn(),
    readdir: vi.fn(),
    rename: vi.fn(),
    appendFile: vi.fn(),
  },
  mkdir: vi.fn(),
  readFile: vi.fn(),
  writeFile: vi.fn(),
  readdir: vi.fn(),
  rename: vi.fn(),
  appendFile: vi.fn(),
}));

describe('Observer', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    process.env.REPORT_DIR = path.join(process.cwd(), 'test-tmp');
  });

  it('should run in dry-run mode without writing files', async () => {
    const { execSync } = await import('child_process');
    vi.mocked(execSync).mockReturnValue('[]');

    await runObserver({ windowDays: 7, dryRun: true });

    // Should not write any files in dry-run
    expect(vi.mocked(fs.writeFile)).not.toHaveBeenCalled();
  });

  it('should discover runs from GitHub API', async () => {
    const { execSync } = await import('child_process');
    const mockRuns = [
      {
        databaseId: 123,
        url: 'https://github.com/test/repo/actions/runs/123',
        headSha: 'abc123',
        createdAt: new Date().toISOString(),
        conclusion: 'success',
        status: 'completed',
        displayTitle: 'tag: v1.0.0',
      },
    ];
    vi.mocked(execSync).mockReturnValue(JSON.stringify(mockRuns));

    await runObserver({ windowDays: 7, dryRun: true });

    expect(execSync).toHaveBeenCalled();
  });
});

