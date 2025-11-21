#!/usr/bin/env node
const process = require("node:process");

const MIN_MAJOR = 18;
const WARN_MAJOR = 20;
const major = Number(process.versions.node.split(".")[0]);

if (Number.isNaN(major) || major < MIN_MAJOR) {
  console.error(
    `\n[ERROR] Node v${MIN_MAJOR}+ が必須です（現在: v${process.versions.node}).\n` +
      "nvm use 18 && npm ci && 再度コマンドを実行してください。\n",
  );
  process.exit(1);
}

if (major < WARN_MAJOR) {
  console.warn(
    `\n[WARN] Node v${WARN_MAJOR}+ を推奨しています（現在: v${process.versions.node}).\n` +
      "最新版を利用できない場合は、既知のエラーがないか注意して続行してください。\n",
  );
}

if (typeof globalThis.File === "undefined") {
  globalThis.File = class File {};
}
