#!/usr/bin/env node
import process from "node:process";

const MIN_MAJOR = 18;
const major = Number(process.versions.node.split(".")[0]);
if (Number.isNaN(major) || major < MIN_MAJOR) {
  console.error(
    `\n[ERROR] Node v${MIN_MAJOR}+ が必須です（現在: v${process.versions.node}).\n` +
      "nvm use 18 && npm ci && 再度コマンドを実行してください。\n",
  );
  process.exit(1);
}
