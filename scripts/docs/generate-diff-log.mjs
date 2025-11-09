#!/usr/bin/env node
import { execSync } from "node:child_process";
import fs from "node:fs";

const out = "docs/reports/DAY12_SOT_DIFFS.md";
let diff = "";
try {
  diff = execSync("git diff --staged", { encoding: "utf8" });
} catch (e) {
  try {
    diff = execSync("git diff HEAD", { encoding: "utf8" });
  } catch (e2) {
    diff = "No staged changes found.\n";
  }
}

const timestamp = new Date().toISOString();
const body = `# Day12 SOT DIFFS

**Generated**: ${timestamp}

## ステージ差分

\`\`\`diff
${diff.substring(0, 5000)}${diff.length > 5000 ? "\n... (truncated)" : ""}
\`\`\`

## 変更ファイル一覧

${execSync("git diff --staged --name-only 2>/dev/null || git diff HEAD --name-only 2>/dev/null || echo 'No changes'", { encoding: "utf8" }).trim().split("\n").map(f => `- ${f}`).join("\n")}

---

**Note**: This file is auto-generated. Manual edits may be overwritten.
`;

fs.mkdirSync("docs/reports", { recursive: true });
fs.writeFileSync(out, body);
console.log(`✅ Generated: ${out}`);

