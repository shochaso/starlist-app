#!/usr/bin/env node
// scripts/docs/update-mlc.js
// Update .mlc.json with additional ignore patterns (no moreutils/jq required)

const fs = require('fs');
const path = require('path');

const mlcFile = path.join(process.cwd(), '.mlc.json');

try {
  const content = fs.readFileSync(mlcFile, 'utf8');
  const config = JSON.parse(content);

  // Ensure ignorePatterns array exists
  if (!Array.isArray(config.ignorePatterns)) {
    config.ignorePatterns = [];
  }

  // Additional ignore patterns (avoid duplicates)
  const additionalPatterns = [
    { pattern: 'admin\\.google\\.com' },
    { pattern: 'github\\.com/orgs/.+' },
    { pattern: '^mailto:' },
    { pattern: 'localhost' },
    { pattern: '#' }
  ];

  // Add patterns if not already present
  additionalPatterns.forEach(newPattern => {
    const exists = config.ignorePatterns.some(
      existing => existing.pattern === newPattern.pattern
    );
    if (!exists) {
      config.ignorePatterns.push(newPattern);
    }
  });

  // Ensure retry settings
  config.retryOn429 = true;
  config.retryCount = config.retryCount || 3;

  // Write back with proper formatting
  fs.writeFileSync(mlcFile, JSON.stringify(config, null, 2) + '\n');
  console.log('✅ Updated .mlc.json');
} catch (error) {
  console.error('❌ Error updating .mlc.json:', error.message);
  process.exit(1);
}

