#!/usr/bin/env node
import { execSync } from "node:child_process";

// ignorePatterns拡張（mailto/local/anchor）は既に.mlc.jsonに含まれている
// リトライ/並列オプションはmarkdown-link-checkのデフォルト設定を使用

// Find all markdown files
import { execSync } from "node:child_process";
import { readdirSync, statSync } from "node:fs";
import { join } from "node:path";

function findMarkdownFiles(dir, fileList = []) {
  const files = readdirSync(dir);
  files.forEach(file => {
    const filePath = join(dir, file);
    const stat = statSync(filePath);
    if (stat.isDirectory() && !file.startsWith('.') && file !== 'node_modules') {
      findMarkdownFiles(filePath, fileList);
    } else if (file.endsWith('.md')) {
      fileList.push(filePath);
    }
  });
  return fileList;
}

const mdFiles = [
  ...findMarkdownFiles('docs'),
  ...findMarkdownFiles('guides')
];

if (mdFiles.length === 0) {
  console.warn("⚠️  No markdown files found");
  process.exit(0);
}

try {
  // Run markdown-link-check for each file
  for (const file of mdFiles) {
    execSync(`npx markdown-link-check -c .mlc.json "${file}" -q`, { stdio: "inherit" });
  }
} catch (e) {
  console.error("❌ Link check failed");
  process.exit(1);
}

