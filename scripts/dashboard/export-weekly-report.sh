#!/bin/bash
# 週次PDF/PNGエクスポートスクリプト（Next.js 側で静的吐き出し）
# Usage: ./scripts/dashboard/export-weekly-report.sh [format] [output-dir]

set -euo pipefail

FORMAT="${1:-png}"  # png or pdf
OUTPUT_DIR="${2:-docs/reports/dashboard-exports}"

mkdir -p "$OUTPUT_DIR"

echo "=== 週次KPIダッシュボードエクスポート ==="
echo ""

# Check if Next.js app is running
if ! curl -sS http://localhost:3000/dashboard/audit > /dev/null 2>&1; then
  echo "⚠️  Next.js app is not running. Starting..."
  cd app && npm run dev &
  sleep 10
fi

# Generate timestamp
TIMESTAMP=$(date +"%Y%m%d")
OUTPUT_FILE="${OUTPUT_DIR}/audit-kpi-${TIMESTAMP}.${FORMAT}"

echo "📋 Exporting dashboard to: $OUTPUT_FILE"
echo ""

# Use Puppeteer or Playwright to capture screenshot/PDF
if command -v playwright >/dev/null 2>&1; then
  echo "Using Playwright..."
  npx playwright screenshot "http://localhost:3000/dashboard/audit" --full-page --path "$OUTPUT_FILE" || {
    echo "❌ Screenshot failed"
    exit 1
  }
elif command -v node >/dev/null 2>&1; then
  echo "Using Puppeteer (via Node.js)..."
  node -e "
    const puppeteer = require('puppeteer');
    (async () => {
      const browser = await puppeteer.launch();
      const page = await browser.newPage();
      await page.goto('http://localhost:3000/dashboard/audit', { waitUntil: 'networkidle0' });
      if ('${FORMAT}' === 'pdf') {
        await page.pdf({ path: '${OUTPUT_FILE}', format: 'A4' });
      } else {
        await page.screenshot({ path: '${OUTPUT_FILE}', fullPage: true });
      }
      await browser.close();
    })();
  " || {
    echo "❌ Export failed"
    exit 1
  }
else
  echo "❌ Neither Playwright nor Puppeteer found"
  echo "   Install: npm install -D playwright puppeteer"
  exit 1
fi

echo ""
echo "✅ Export completed: $OUTPUT_FILE"
echo "📊 File size: $(du -h "$OUTPUT_FILE" | cut -f1)"

