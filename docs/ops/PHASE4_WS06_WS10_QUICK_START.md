---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# Phase 4 WS06-WS10 Quick Start Guide

## Overview

This guide provides copy-paste commands to implement and test WS06-WS10 components.

## Prerequisites

```bash
# Ensure dependencies installed
npm ci

# Verify Node version (18+)
node --version
```

## Implementation Commands

### WS06: Collector Enhancements

```bash
# Task 1: Create CLI parser
cat > scripts/phase4/collector/cli.ts << 'EOF'
#!/usr/bin/env node
// CLI argument parser for collector
import { parseArgs } from 'util';

export interface CollectorConfig {
  runIds: string[];
  dryRun: boolean;
  reportDir: string;
}

export function parseCollectorArgs(): CollectorConfig {
  const { values } = parseArgs({
    options: {
      'run-ids': { type: 'string', default: '' },
      'dry-run': { type: 'boolean', default: false },
      'report-dir': { type: 'string', default: process.env.REPORT_DIR || 'docs/reports/2025-11-14' },
    },
  });

  const runIds = values['run-ids'] 
    ? values['run-ids'].split(',').map(id => id.trim()).filter(Boolean)
    : [];

  return {
    runIds,
    dryRun: values['dry-run'] || false,
    reportDir: values['report-dir'] || 'docs/reports/2025-11-14',
  };
}

if (require.main === module) {
  const config = parseCollectorArgs();
  console.log(JSON.stringify(config, null, 2));
}
EOF

# Test CLI
node scripts/phase4/collector/cli.ts --run-ids 123,456 --dry-run
```

### WS07: KPI Aggregator

```bash
# Task 6: Create RUNS_SUMMARY reader
cat > scripts/phase4/kpi/reader.ts << 'EOF'
#!/usr/bin/env node
import * as fs from 'fs/promises';
import * as path from 'path';

export interface RunsSummary {
  generated_at: string;
  total_runs: number;
  runs: Array<{
    run_id: number;
    tag?: string;
    sha256?: string;
    run_url: string;
    created_at: string;
    sha_parity?: boolean;
    validator_verdict?: string;
  }>;
}

export async function readRunsSummary(summaryPath: string): Promise<RunsSummary> {
  try {
    const content = await fs.readFile(summaryPath, 'utf-8');
    return JSON.parse(content);
  } catch (error) {
    // Return empty summary if file missing
    return {
      generated_at: new Date().toISOString(),
      total_runs: 0,
      runs: [],
    };
  }
}

if (require.main === module) {
  const summaryPath = process.argv[2] || 'docs/reports/2025-11-14/RUNS_SUMMARY.json';
  readRunsSummary(summaryPath).then(summary => {
    console.log(JSON.stringify(summary, null, 2));
  });
}
EOF

# Test reader
node scripts/phase4/kpi/reader.ts docs/reports/2025-11-14/RUNS_SUMMARY.json
```

### WS08: Sweep Enhancements

```bash
# Task 10: Create exclusions config
cat > sweep-exclusions.json << 'EOF'
{
  "exclusions": [
    {
      "pattern": ".*\\.md$",
      "reason": "Documentation files"
    },
    {
      "pattern": ".*test.*",
      "reason": "Test files"
    },
    {
      "pattern": ".*fixture.*",
      "reason": "Test fixtures"
    }
  ],
  "tokenPatterns": [
    "ghp_[A-Za-z0-9]{36}",
    "gho_[A-Za-z0-9]{36}",
    "AKIA[0-9A-Z]{16}",
    "sk_live_[A-Za-z0-9]{32}"
  ]
}
EOF
```

### WS09: Manifest Git Integration

```bash
# Task 13: Create git helper
cat > scripts/phase4/manifest/git.ts << 'EOF'
#!/usr/bin/env node
import { execSync } from 'child_process';

export interface GitMetadata {
  branch?: string;
  commit?: string;
  isGitRepo: boolean;
}

export async function getGitMetadata(): Promise<GitMetadata> {
  try {
    execSync('git rev-parse --git-dir', { stdio: 'ignore' });
    const branch = execSync('git rev-parse --abbrev-ref HEAD', { encoding: 'utf-8' }).trim();
    const commit = execSync('git rev-parse HEAD', { encoding: 'utf-8' }).trim();
    return { branch, commit, isGitRepo: true };
  } catch {
    return { isGitRepo: false };
  }
}

if (require.main === module) {
  getGitMetadata().then(metadata => {
    console.log(JSON.stringify(metadata, null, 2));
  });
}
EOF

# Test git helper
node scripts/phase4/manifest/git.ts
```

### WS10: Telemetry Implementation

```bash
# Task 16: Create Supabase client factory
cat > scripts/phase4/telemetry/client.ts << 'EOF'
#!/usr/bin/env node
export async function createSupabaseClient(url?: string, key?: string) {
  const supabaseUrl = url || process.env.SUPABASE_URL;
  const supabaseKey = key || process.env.SUPABASE_SERVICE_KEY;

  if (!supabaseUrl || !supabaseKey) {
    return null;
  }

  try {
    const { createClient } = await import('@supabase/supabase-js');
    return createClient(supabaseUrl, supabaseKey);
  } catch (error) {
    if (error instanceof Error && error.message.includes('Cannot find module')) {
      return null;
    }
    throw error;
  }
}

if (require.main === module) {
  createSupabaseClient().then(client => {
    console.log(JSON.stringify({ clientAvailable: !!client }, null, 2));
  });
}
EOF

# Test client factory (without real credentials)
node scripts/phase4/telemetry/client.ts
```

## Testing Commands

```bash
# Run all Phase4 tests
npm test tests/phase4/

# Run specific test suite
npm test tests/phase4/collector/
npm test tests/phase4/kpi/
npm test tests/phase4/sweep/
npm test tests/phase4/manifest/
npm test tests/phase4/telemetry/

# Dry-run tests
npm run phase4:collect -- --run-ids 123,456 --dry-run
npm run phase4:kpi -- docs/reports/2025-11-14
npm run phase4:sweep -- docs/reports/2025-11-14
```

## CI Integration

Add to `.github/workflows/phase4-auto-audit.yml`:

```yaml
collector:
  name: Evidence Collector
  needs: guard
  if: needs.guard.outputs.guard-passed == 'true'
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '20'
    - name: Install dependencies
      run: npm ci
    - name: Run Collector
      env:
        REPORT_DIR: docs/reports/2025-11-14
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      run: |
        npm run phase4:collect -- --run-ids ${{ github.run_id }} --report-dir ${{ env.REPORT_DIR }}

kpi:
  name: KPI Aggregator
  needs: [observer, collector]
  if: always() && needs.guard.outputs.guard-passed == 'true'
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '20'
    - name: Install dependencies
      run: npm ci
    - name: Run KPI Aggregator
      env:
        REPORT_DIR: docs/reports/2025-11-14
      run: |
        npm run phase4:kpi -- ${{ env.REPORT_DIR }}
```

## Acceptance Checklist

- [ ] All 20 tasks implemented
- [ ] All tests passing (100% pass rate)
- [ ] Dry-run mode works for all scripts
- [ ] No secrets logged or committed
- [ ] Idempotency maintained
- [ ] CI workflows updated
- [ ] Documentation updated

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
