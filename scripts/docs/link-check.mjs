#!/usr/bin/env node
import { execSync } from "node:child_process";

execSync("npx markdown-link-check -c .mlc.json \"docs/**/*.md\" -q", { stdio: "inherit" });

