#!/usr/bin/env bash
set -euo pipefail
required=(SUPABASE_URL SUPABASE_ANON_KEY OPS_SERVICE_SECRET DATABASE_URL)
missing=0
for v in "${required[@]}"; do
  if [ -z "${!v:-}" ]; then
    echo "missing $v" >&2
    missing=1
  fi
done
if [ $missing -ne 0 ]; then
  exit 1
fi
