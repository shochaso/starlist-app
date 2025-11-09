#!/usr/bin/env bash
set -euo pipefail

: "${DATABASE_URL:?DATABASE_URL is required}"

echo "Running RLS audit against $DATABASE_URL"
psql "$DATABASE_URL" <<'SQL'
SELECT current_database();
SELECT session_user;
SQL
