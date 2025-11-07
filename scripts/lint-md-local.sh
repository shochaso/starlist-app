#!/usr/bin/env bash
set -euo pipefail

if command -v nvm >/dev/null 2>&1; then
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  # shellcheck disable=SC1090
  [[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
  nvm use 20 >/dev/null || true
fi

node scripts/ensure-node20.js
npm run lint:md
