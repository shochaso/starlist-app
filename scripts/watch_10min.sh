#!/usr/bin/env bash
set -euo pipefail

for i in 1 2; do
  jq 'def p(v;n):(v|sort)[(length*n|floor)];
      {count:length,
       ok:(map(select((.status//200)==200))|length),
       p95_latency_ms:((map(.latency_ms//null)|del(.[]|select(.==null))) as $L | p($L;0.95))}' \
     tmp/audit_day11/send.json
  [[ $i -lt 2 ]] && sleep 600
done


set -euo pipefail

for i in 1 2; do
  jq 'def p(v;n):(v|sort)[(length*n|floor)];
      {count:length,
       ok:(map(select((.status//200)==200))|length),
       p95_latency_ms:((map(.latency_ms//null)|del(.[]|select(.==null))) as $L | p($L;0.95))}' \
     tmp/audit_day11/send.json
  [[ $i -lt 2 ]] && sleep 600
done


