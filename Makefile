.PHONY: db-push db-pull fn-deploy fn-logs fn-serve

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
