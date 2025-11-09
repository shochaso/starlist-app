# Security Observation Logs

- CSP report capture: Playwright `tests/e2e/csp.spec.ts` ensures `/functions/v1/csp-report` is requested during smoke run.
- Environment verification helper: `scripts/security/verify_env.sh` checks SUPABASE_URL/ANON/OPS/DATABASE.
