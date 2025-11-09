#!/usr/bin/env node
import { execSync } from "node:child_process";
import fs from "node:fs";

const out = "docs/reports/DAY12_SOT_DIFFS.md";
let diff = "";
let commitHash = "";
let commitUrl = "";

try {
  diff = execSync("git diff --staged", { encoding: "utf8" });
  commitHash = execSync("git rev-parse HEAD", { encoding: "utf8" }).trim();
} catch (e) {
  try {
    diff = execSync("git diff HEAD", { encoding: "utf8" });
    commitHash = execSync("git rev-parse HEAD", { encoding: "utf8" }).trim();
  } catch (e2) {
    diff = "No staged changes found.\n";
    commitHash = "N/A";
  }
}

// GitHubリポジトリURLを取得（.git/configから）
let repoUrl = "";
try {
  const gitConfig = execSync("git config --get remote.origin.url", { encoding: "utf8" }).trim();
  if (gitConfig.includes("github.com")) {
    // git@github.com:owner/repo.git または https://github.com/owner/repo.git
    const match = gitConfig.match(/(?:git@|https:\/\/)github\.com[:/]([^\/]+)\/([^\/\.]+)/);
    if (match) {
      const [, owner, repo] = match;
      repoUrl = `https://github.com/${owner}/${repo}`;
      commitUrl = `${repoUrl}/commit/${commitHash}`;
    }
  }
} catch (e) {
  // GitHubリポジトリでない場合や取得失敗時はスキップ
}

const timestamp = new Date().toISOString();
const body = `# Day12 SOT DIFFS

**Generated**: ${timestamp}
${commitHash !== "N/A" ? `**Commit**: [${commitHash.substring(0, 7)}](${commitUrl || `#${commitHash}`})` : ""}

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

