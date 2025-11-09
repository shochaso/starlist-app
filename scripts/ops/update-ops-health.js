#!/usr/bin/env node
// scripts/ops/update-ops-health.js
// 週次成果物とCI状態から「Ops健康度」を1行に集計し、STARLIST_OVERVIEW.mdを書き換え

import { execSync } from 'child_process';
import fs from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const rootDir = join(__dirname, '../..');

const mdPath = join(rootDir, 'docs/overview/STARLIST_OVERVIEW.md');

try {
  // CI状態を取得
  let ciStatus = 'unknown';
  try {
    const result = execSync(
      'gh run list --workflow extended-security.yml --limit 1 --json conclusion --jq ".[0].conclusion"',
      { encoding: 'utf8', cwd: rootDir, stdio: 'pipe' }
    ).trim();
    ciStatus = result === 'success' ? 'OK' : 'NG';
  } catch (err) {
    console.warn('⚠️  Could not fetch CI status:', err.message);
    ciStatus = 'unknown';
  }

  // 週次レポート数を取得
  let reportsCount = 0;
  try {
    const reportsDir = join(rootDir, 'out/reports');
    if (fs.existsSync(reportsDir)) {
      const files = fs.readdirSync(reportsDir);
      reportsCount = files.filter(f => /weekly-.*\.(pdf|png)$/i.test(f)).length;
    }
  } catch (err) {
    console.warn('⚠️  Could not count reports:', err.message);
  }

  // Gitleaks allowlist数（将来実装）
  const gitleaksCount = 0;

  // Linkエラー数（将来実装）
  const linkErrCount = 0;

  // 健康度行を生成（機能マップテーブルのOps健康度列を更新）
  const green = ciStatus === 'OK';
  const statusIcon = green ? '✅' : '⚠️';
  const healthValue = `CI=${ciStatus}, Reports=${reportsCount}, Gitleaks=${gitleaksCount}, LinkErr=${linkErrCount}`;

  // ファイルを読み込んで置換
  let content = fs.readFileSync(mdPath, 'utf8');
  
  // 機能マップテーブルの「Day5 Telemetry/OPS」行のOps健康度列を更新
  const pattern = /(\| Day5 Telemetry\/OPS \|[\s\S]*?\|)([\s\S]*?)(\|$)/m;
  const match = content.match(pattern);
  
  if (match) {
    // 既存のOps健康度列を置換
    const updatedLine = match[0].replace(/\| CI成功率:.*$/, `| ${healthValue} |`);
    content = content.replace(pattern, updatedLine);
    fs.writeFileSync(mdPath, content);
    console.log('✅ Updated Ops Health in Day5 Telemetry/OPS row:', healthValue);
  } else {
    // パターンが見つからない場合は、Ops健康度列を追加
    const day5Pattern = /(\| Day5 Telemetry\/OPS \|[\s\S]*?\|)([\s\S]*?)(\|$)/m;
    if (day5Pattern.test(content)) {
      content = content.replace(day5Pattern, `$1 $2 | ${healthValue} |`);
      fs.writeFileSync(mdPath, content);
      console.log('✅ Added Ops Health to Day5 Telemetry/OPS row:', healthValue);
    } else {
      console.warn('⚠️  Day5 Telemetry/OPS row not found in STARLIST_OVERVIEW.md');
      console.log('Generated value:', healthValue);
    }
  }
} catch (error) {
  console.error('❌ Error updating Ops Health:', error.message);
  process.exit(1);
}

