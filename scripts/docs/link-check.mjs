#!/usr/bin/env node
import { execSync } from "node:child_process";

// ignorePatterns拡張（mailto/local/anchor）は既に.mlc.jsonに含まれている
// リトライ/並列オプションはmarkdown-link-checkのデフォルト設定を使用

try {
  execSync("npx markdown-link-check -c .mlc.json \"docs/**/*.md\" \"guides/**/*.md\" -q", { stdio: "inherit" });
} catch (e) {
  console.error("❌ Link check failed");
  process.exit(1);
}

