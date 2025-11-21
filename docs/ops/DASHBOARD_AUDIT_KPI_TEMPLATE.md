---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















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

## 合否判定UI（μ±2σ/3σで色分岐）

各KPIカードに合否判定バッジを表示：
- **✅ Pass**: 値がμ±2σ以内（緑色ボーダー）
- **⚠️ Warning**: 値がμ±2σ超、μ±3σ以内（黄色ボーダー）
- **❌ Fail**: 値がμ±3σ超（赤色ボーダー）

**実装**: `app/components/kpi/KPIStat.tsx`で`verdict`プロップと`mean`/`stdDev`プロップを使用

## RACI/リスク登録票/受入テストへの導線

ダッシュボードヘッダーにワンクリックリンクを追加：
- **📋 RACI**: `/docs/ops/RACI_MATRIX.md`
- **⚠️ リスク登録票**: `/docs/ops/RISK_REGISTER.md`
- **✅ 受入テスト**: `/docs/ops/DASHBOARD_FINAL_CHECKLIST.md`

**実装**: `app/dashboard/audit/page.tsx`のヘッダー部分に`Link`コンポーネントを追加

## 週次PDF/PNGエクスポート

**スクリプト**: `scripts/dashboard/export-weekly-report.sh`

**使用方法**:
```bash
# PNG形式でエクスポート（デフォルト）
./scripts/dashboard/export-weekly-report.sh png

# PDF形式でエクスポート
./scripts/dashboard/export-weekly-report.sh pdf

# 出力ディレクトリを指定
./scripts/dashboard/export-weekly-report.sh png docs/reports/custom-dir
```

**出力先**: `docs/reports/dashboard-exports/audit-kpi-YYYYMMDD.{png|pdf}`

**前提条件**:
- Next.jsアプリが`http://localhost:3000`で起動していること
- PlaywrightまたはPuppeteerがインストールされていること

## フッター「10×強化パック」リンク

ダッシュボードフッターに固定リンクを追加：
- **📦 Day12 10×強化パック**: `/docs/planning/DAY12_10X_EXECUTION_PROMPTS.md`

**実装**: `app/dashboard/audit/page.tsx`のフッター部分に`Link`コンポーネントを追加

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



## 概要

* ページ: `/dashboard/audit`
* カード:
  * Day11 成功率（週次）
  * Day11 p95(ms)（週次）
  * Pricing Checkout 成功率（週次）
  * 不一致検知ゼロ連続日数（カウンタ）
* API: `GET /api/audit/latest`（Edge Function 経由）
* 更新: CI成功時に `dashboard/data/latest.json` を上書き

## 合否判定UI（μ±2σ/3σで色分岐）

各KPIカードに合否判定バッジを表示：
- **✅ Pass**: 値がμ±2σ以内（緑色ボーダー）
- **⚠️ Warning**: 値がμ±2σ超、μ±3σ以内（黄色ボーダー）
- **❌ Fail**: 値がμ±3σ超（赤色ボーダー）

**実装**: `app/components/kpi/KPIStat.tsx`で`verdict`プロップと`mean`/`stdDev`プロップを使用

## RACI/リスク登録票/受入テストへの導線

ダッシュボードヘッダーにワンクリックリンクを追加：
- **📋 RACI**: `/docs/ops/RACI_MATRIX.md`
- **⚠️ リスク登録票**: `/docs/ops/RISK_REGISTER.md`
- **✅ 受入テスト**: `/docs/ops/DASHBOARD_FINAL_CHECKLIST.md`

**実装**: `app/dashboard/audit/page.tsx`のヘッダー部分に`Link`コンポーネントを追加

## 週次PDF/PNGエクスポート

**スクリプト**: `scripts/dashboard/export-weekly-report.sh`

**使用方法**:
```bash
# PNG形式でエクスポート（デフォルト）
./scripts/dashboard/export-weekly-report.sh png

# PDF形式でエクスポート
./scripts/dashboard/export-weekly-report.sh pdf

# 出力ディレクトリを指定
./scripts/dashboard/export-weekly-report.sh png docs/reports/custom-dir
```

**出力先**: `docs/reports/dashboard-exports/audit-kpi-YYYYMMDD.{png|pdf}`

**前提条件**:
- Next.jsアプリが`http://localhost:3000`で起動していること
- PlaywrightまたはPuppeteerがインストールされていること

## フッター「10×強化パック」リンク

ダッシュボードフッターに固定リンクを追加：
- **📦 Day12 10×強化パック**: `/docs/planning/DAY12_10X_EXECUTION_PROMPTS.md`

**実装**: `app/dashboard/audit/page.tsx`のフッター部分に`Link`コンポーネントを追加

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

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
