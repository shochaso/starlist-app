#!/usr/bin/env node
import process from "node:process";

const major = Number(process.versions.node.split(".")[0]);
if (Number.isNaN(major) || major < 20) {
  console.error(
    `\n[ERROR] Node v20+ が必須です（現在: v${process.versions.node}).\n` +
      "nvm use 20 && npm ci && 再度コマンドを実行してください。\n",
  );
  process.exit(1);
}
