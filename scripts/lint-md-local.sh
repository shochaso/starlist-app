#!/usr/bin/env bash
set -euo pipefail
if command -v nvm >/dev/null 2>&1; then
  # shellcheck disable=SC1090
  [[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
  nvm use 20 >/dev/null || true
fi
node -e "process.exit((+process.versions.node.split('.')[0])<20?1:0)" || {
  echo "[ERROR] Node v20+ が必須です。'nvm use 20' 実行後に再試行してください。"; exit 1;
}
files=$(git ls-files '*.md')
if [ -z "$files" ]; then
  echo "No markdown files found"; exit 0;
fi
npx markdown-link-check -c .mlc.json -q $files
echo "[OK] markdown-link-check passed on Node $(node -v)"
