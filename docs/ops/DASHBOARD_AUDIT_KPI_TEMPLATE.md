# 監査KPIダッシュボード設計テンプレート

## 概要

* ページ: `/dashboard/audit`
* カード:
  * Day11 成功率（週次）
  * Day11 p95(ms)（週次）
  * Pricing Checkout 成功率（週次）
  * 不一致検知ゼロ連続日数（カウンタ）
* API: `GET /api/audit/latest`（Edge Function 経由）
* 更新: CI成功時に `dashboard/data/latest.json` を上書き

## Edge Function 雛形

`supabase/functions/audit-latest/index.ts`

```ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

serve(async () => {
  const data = await Deno.readTextFile("./data/latest.json").catch(()=> "{}");
  return new Response(data, { headers: { "content-type":"application/json" }});
});
```

## CI 追記（成功時反映）

`.github/workflows/integration-audit.yml` に追加：

```yaml
- name: Publish latest KPI (on success)
  if: success()
  run: |
    mkdir -p dashboard/data
    jq -n --slurpfile d tmp/audit_day11/send.json --slurpfile m tmp/audit_day11/metrics.json --slurpfile s tmp/audit_stripe/events_starlist.json \
    '{updated_at: (now|todate), day11_count: ($d[0]|length), p95_latency_ms: ($m[0].p95_latency_ms), stripe_events: ($s[0]|length)}' \
    > dashboard/data/latest.json
```

