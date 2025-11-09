#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";

const today = new Date().toISOString().slice(0,10);

// デフォルトターゲット（4本柱＋Mermaid）
const defaultTargets = [
  "docs/overview/STARLIST_OVERVIEW.md",
  "docs/COMPANY_SETUP_GUIDE.md",
  "docs/overview/COMMON_DOCS_INDEX.md",
  "guides/CHATGPT_SHARE_GUIDE.md",
  "docs/Mermaid.md"
];

// コマンドライン引数からフィルタを取得
const args = process.argv.slice(2);
let includePatterns = [];
let excludePatterns = [];

for (let i = 0; i < args.length; i++) {
  if (args[i] === "--include" && args[i + 1]) {
    includePatterns.push(args[i + 1]);
    i++;
  } else if (args[i] === "--exclude" && args[i + 1]) {
    excludePatterns.push(args[i + 1]);
    i++;
  }
}

// ファイル選択フィルタ
function shouldInclude(filePath) {
  if (includePatterns.length > 0) {
    return includePatterns.some(pattern => filePath.includes(pattern));
  }
  if (excludePatterns.length > 0) {
    return !excludePatterns.some(pattern => filePath.includes(pattern));
  }
  return true;
}

// ターゲットファイルを決定
const targets = includePatterns.length > 0
  ? defaultTargets.filter(shouldInclude)
  : defaultTargets.filter(shouldInclude);

for (const p of targets) {
  if (!fs.existsSync(p)) {
    console.warn(`⚠️  File not found: ${p}`);
    continue;
  }
  let t = fs.readFileSync(p, "utf8");
  if (/Last-Updated:/.test(t)) {
    t = t.replace(/Last-Updated:\s*\d{4}-\d{2}-\d{2}/, `Last-Updated: ${today}`);
  } else if (/Status::/.test(t)) {
    // Status行の後に追加
    t = t.replace(/Status::.*\n/, (match) => `${match}Last-Updated: ${today}\n`);
  } else {
    t = `Last-Updated: ${today}\n\n` + t;
  }
  fs.writeFileSync(p, t);
  console.log(`✅ Updated: ${p}`);
}


import path from "node:path";

const today = new Date().toISOString().slice(0,10);

// デフォルトターゲット（4本柱＋Mermaid）
const defaultTargets = [
  "docs/overview/STARLIST_OVERVIEW.md",
  "docs/COMPANY_SETUP_GUIDE.md",
  "docs/overview/COMMON_DOCS_INDEX.md",
  "guides/CHATGPT_SHARE_GUIDE.md",
  "docs/Mermaid.md"
];

// コマンドライン引数からフィルタを取得
const args = process.argv.slice(2);
let includePatterns = [];
let excludePatterns = [];

for (let i = 0; i < args.length; i++) {
  if (args[i] === "--include" && args[i + 1]) {
    includePatterns.push(args[i + 1]);
    i++;
  } else if (args[i] === "--exclude" && args[i + 1]) {
    excludePatterns.push(args[i + 1]);
    i++;
  }
}

// ファイル選択フィルタ
function shouldInclude(filePath) {
  if (includePatterns.length > 0) {
    return includePatterns.some(pattern => filePath.includes(pattern));
  }
  if (excludePatterns.length > 0) {
    return !excludePatterns.some(pattern => filePath.includes(pattern));
  }
  return true;
}

// ターゲットファイルを決定
const targets = includePatterns.length > 0
  ? defaultTargets.filter(shouldInclude)
  : defaultTargets.filter(shouldInclude);

for (const p of targets) {
  if (!fs.existsSync(p)) {
    console.warn(`⚠️  File not found: ${p}`);
    continue;
  }
  let t = fs.readFileSync(p, "utf8");
  if (/Last-Updated:/.test(t)) {
    t = t.replace(/Last-Updated:\s*\d{4}-\d{2}-\d{2}/, `Last-Updated: ${today}`);
  } else if (/Status::/.test(t)) {
    // Status行の後に追加
    t = t.replace(/Status::.*\n/, (match) => `${match}Last-Updated: ${today}\n`);
  } else {
    t = `Last-Updated: ${today}\n\n` + t;
  }
  fs.writeFileSync(p, t);
  console.log(`✅ Updated: ${p}`);
}

