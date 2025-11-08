.PHONY: db-push db-pull fn-deploy fn-logs fn-serve day11 pricing audit all smoke verify schema lint redact

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
	AUDIT_LOOKBACK_HOURS=$(HOURS) ./FINAL_INTEGRATION_SUITE.sh --day11-only || true

## Pricing E2E test only
pricing:
	chmod +x ./FINAL_INTEGRATION_SUITE.sh
	AUDIT_LOOKBACK_HOURS=$(HOURS) ./FINAL_INTEGRATION_SUITE.sh --pricing-only || true

## Generate audit reports only
audit:
	chmod +x ./generate_audit_report.sh
	AUDIT_LOOKBACK_HOURS=$(HOURS) ./generate_audit_report.sh || true

## Run full integration suite
all:
	chmod +x ./FINAL_INTEGRATION_SUITE.sh
	./FINAL_INTEGRATION_SUITE.sh

## Quick smoke test (env & tools check)
smoke:
	@[ -n "$$SUPABASE_URL" ] || (echo "SUPABASE_URL missing"; exit 1)
	@[ -n "$$SUPABASE_ANON_KEY" ] || (echo "SUPABASE_ANON_KEY missing"; exit 1)
	@command -v jq >/dev/null || (echo "jq missing"; exit 1)
	@echo "Smoke OK"

## Summarize latest audit report
summarize:
	@FILE=$$(ls -1 docs/reports/*_DAY11_AUDIT_*.md 2>/dev/null | tail -n1); \
	[ -n "$$FILE" ] || { echo "No audit file"; exit 2; }; \
	echo "== $$FILE =="; \
	awk '/^## 1\. 件数サマリ/{flag=1;next}/^## /{flag=0}flag' "$$FILE" | tr -d '\n' | sed 's/  */ /g'; echo

## Front-matter schema validation
verify:
	@which ajv >/dev/null || npm i -g ajv-cli >/dev/null
	@which yq  >/dev/null || echo "Install yq for full verify"
	@FILE=$$(ls -1 docs/reports/*_DAY11_AUDIT_*.md 2>/dev/null | tail -n1); \
	[ -n "$$FILE" ] || { echo "No audit file"; exit 2; }; \
	awk '/^---$$/{f++} f==1{print} /^---$$/{if(f==2) exit}' "$$FILE" | sed '1d;$$d' \
	| yq -o=json \
	| ajv validate -s schemas/audit_report.schema.json -d /dev/stdin

## Install schema validation tools
schema:
	@npm i -g ajv-cli >/dev/null 2>&1 || echo "ajv-cli install failed (may need sudo)"
	@command -v yq >/dev/null || (echo "yq not found. Install: snap install yq or brew install yq" && exit 1)
	@echo "Schema tools ready"

## Redact sensitive information from audit artifacts
redact:
	@find tmp -type f \( -name "*.json" -o -name "*.log" \) -maxdepth 2 \
	  -exec bash -c 'scripts/utils/redact.sh < "{}" > "{}.safe" && echo "Redacted: {}"' \;

## Lint markdown files
lint:
	@[ -f scripts/lint-md-local.sh ] && bash scripts/lint-md-local.sh || echo "skip"

## Clean temporary audit artifacts
clean:
	rm -rf tmp/ .day11_cache/

## Deep clean (including edge logs)
distclean: clean
	rm -f docs/reports/*_edge_logs.txt
