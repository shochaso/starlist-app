#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";

const today = new Date().toISOString().slice(0,10);
const targets = [
  "docs/overview/STARLIST_OVERVIEW.md",
  "docs/COMPANY_SETUP_GUIDE.md",
  "docs/overview/COMMON_DOCS_INDEX.md",
  "guides/CHATGPT_SHARE_GUIDE.md",
  "docs/Mermaid.md"
];

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

