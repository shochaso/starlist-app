#!/usr/bin/env bash
set -euo pipefail

mkdir -p tmp/audit_day11 tmp/audit_stripe tmp/audit_edge logs/day11

# send.json（100件：成功90/失敗10、latency 100–3000ms）
jq -n '[range(0;100)|{status:(if .%10==0 then 500 else 200 end), latency_ms:(100+(.%30)*100)}]' \
  > tmp/audit_day11/send.json

# metrics.json
jq -n '{p95_latency_ms: 2800}' > tmp/audit_day11/metrics.json

# Stripe mock
jq -n '{data:[range(0;20)|{id:"evt_" + (.|tostring), type:"checkout.session.completed", data:{object:{amount_total:1000, currency:"jpy"}}}]}' \
  > tmp/audit_stripe/events_starlist.json

echo "ok" > tmp/audit_edge/ops-slack-summary.log

touch logs/day11/permalink.txt
echo "https://workspace.slack.com/archives/AA1/p1234567890123456" > logs/day11/permalink.txt

echo "[fake] data generated"

