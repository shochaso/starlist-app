.PHONY: db-push db-pull fn-deploy fn-logs fn-serve day11 pricing audit all smoke

## Supabase DB を dev 環境へ反映
db-push:
	@supabase db push

## dev の状態をローカルへ反映
db-pull:
	@supabase db pull

## Edge Functions をデプロイ
fn-deploy:
	@supabase functions deploy --project-ref zjwvmoxpacbpwawlwbrd

## Edge Functions のログを閲覧
fn-logs:
	@supabase functions logs --function $(FUNC)

## Edge Functions をローカルで起動（`.env` 必須）
fn-serve:
	@supabase functions serve --env-file ./supabase/.env --no-verify-jwt=false

## Day11 Go-Live only
day11:
	chmod +x ./FINAL_INTEGRATION_SUITE.sh
	AUDIT_LOOKBACK_HOURS=48 ./FINAL_INTEGRATION_SUITE.sh --day11-only || true

## Pricing E2E test only
pricing:
	chmod +x ./FINAL_INTEGRATION_SUITE.sh
	AUDIT_LOOKBACK_HOURS=48 ./FINAL_INTEGRATION_SUITE.sh --pricing-only || true

## Generate audit reports only
audit:
	chmod +x ./generate_audit_report.sh
	AUDIT_LOOKBACK_HOURS=48 ./generate_audit_report.sh || true

## Run full integration suite
all:
	chmod +x ./FINAL_INTEGRATION_SUITE.sh
	./FINAL_INTEGRATION_SUITE.sh

## Quick smoke test (env & tools check)
smoke:
	@[ -n "$$SUPABASE_URL" ] || (echo "SUPABASE_URL missing" && exit 1)
	@[ -n "$$SUPABASE_ANON_KEY" ] || (echo "SUPABASE_ANON_KEY missing" && exit 1)
	@echo "OK: env"
	@command -v jq >/dev/null && echo "OK: jq" || (echo "jq missing" && exit 1)
	@command -v curl >/dev/null && echo "OK: curl" || (echo "curl missing" && exit 1)
	@command -v date >/dev/null && echo "OK: date" || (echo "date missing" && exit 1)
	@echo "Smoke test passed"
