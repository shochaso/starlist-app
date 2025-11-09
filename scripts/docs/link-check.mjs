#!/usr/bin/env node
import { execSync } from "node:child_process";
import { readdirSync, statSync } from "node:fs";
import { join } from "node:path";

// ignorePatterns拡張（mailto/local/anchor）は既に.mlc.jsonに含まれている
// リトライ/並列オプションはmarkdown-link-checkのデフォルト設定を使用

// Retry configuration
const MAX_RETRIES = 3;
const RETRY_DELAY_MS = 1000;
const PARALLEL_LIMIT = 5; // Process up to 5 files in parallel

// Find all markdown files
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

// Retry wrapper
function retryWithBackoff(fn, retries = MAX_RETRIES) {
  return new Promise((resolve, reject) => {
    const attempt = (remaining) => {
      fn()
        .then(resolve)
        .catch((error) => {
          if (remaining <= 0) {
            reject(error);
          } else {
            setTimeout(() => attempt(remaining - 1), RETRY_DELAY_MS);
          }
        });
    };
    attempt(retries);
  });
}

// Process files in parallel batches
async function checkLinksParallel(files) {
  const results = [];
  for (let i = 0; i < files.length; i += PARALLEL_LIMIT) {
    const batch = files.slice(i, i + PARALLEL_LIMIT);
    const batchPromises = batch.map(file =>
      retryWithBackoff(() => {
        return new Promise((resolve, reject) => {
          try {
            execSync(`npx markdown-link-check -c .mlc.json "${file}" -q`, { stdio: "inherit" });
            resolve();
          } catch (e) {
            reject(e);
          }
        });
      })
    );
    await Promise.allSettled(batchPromises);
  }
  return results;
}

(async () => {
  try {
    // Run markdown-link-check with retry and parallel processing
    await checkLinksParallel(mdFiles);
    console.log("✅ Link check completed");
  } catch (e) {
    console.error("❌ Link check failed after retries");
    process.exit(1);
  }
})();


import { readdirSync, statSync } from "node:fs";
import { join } from "node:path";

// ignorePatterns拡張（mailto/local/anchor）は既に.mlc.jsonに含まれている
// リトライ/並列オプションはmarkdown-link-checkのデフォルト設定を使用

// Retry configuration
const MAX_RETRIES = 3;
const RETRY_DELAY_MS = 1000;
const PARALLEL_LIMIT = 5; // Process up to 5 files in parallel

// Find all markdown files
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

// Retry wrapper
function retryWithBackoff(fn, retries = MAX_RETRIES) {
  return new Promise((resolve, reject) => {
    const attempt = (remaining) => {
      fn()
        .then(resolve)
        .catch((error) => {
          if (remaining <= 0) {
            reject(error);
          } else {
            setTimeout(() => attempt(remaining - 1), RETRY_DELAY_MS);
          }
        });
    };
    attempt(retries);
  });
}

// Process files in parallel batches
async function checkLinksParallel(files) {
  const results = [];
  for (let i = 0; i < files.length; i += PARALLEL_LIMIT) {
    const batch = files.slice(i, i + PARALLEL_LIMIT);
    const batchPromises = batch.map(file =>
      retryWithBackoff(() => {
        return new Promise((resolve, reject) => {
          try {
            execSync(`npx markdown-link-check -c .mlc.json "${file}" -q`, { stdio: "inherit" });
            resolve();
          } catch (e) {
            reject(e);
          }
        });
      })
    );
    await Promise.allSettled(batchPromises);
  }
  return results;
}

(async () => {
  try {
    // Run markdown-link-check with retry and parallel processing
    await checkLinksParallel(mdFiles);
    console.log("✅ Link check completed");
  } catch (e) {
    console.error("❌ Link check failed after retries");
    process.exit(1);
  }
})();

