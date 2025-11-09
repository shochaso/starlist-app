#!/usr/bin/env bash
set -euo pipefail

MISSING=0
for key in SUPABASE_URL SUPABASE_ANON_KEY OPS_SERVICE_SECRET; do
  if [ -z "${!key:-}" ]; then
    echo "MISSING $key"
    MISSING=1
  else
    echo "OK $key"
  fi
done

if [ "$MISSING" -eq 1 ]; then
  exit 1
fi
