---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



## Day5: Telemetry/OPS 実装完了

- DB: ops_metrics + v_ops_5min（RLS/Index）
- Edge: telemetry(POST→DB), ops-alert(dryRun)
- Flutter: OpsTelemetry クライアント, ProdSearchTelemetry（サンプリング）
- UI: OPS Dashboard（Auth/RLS/Subscription/Performanceメトリクス可視化）
- CI: qa-e2e テレメトリPOST/ops-alert 検証

### DoD

- [x] Telemetry→ops_metrics 挿入
- [x] v_ops_5min 集計確認
- [x] ops-alert dryRun 成功
- [x] QA E2E 緑
- [x] OPS Dashboard UI実装

### Docs

- OPS-TELEMETRY-SYNC-001.md → Status: aligned-with-Flutter
- DAY5_SOT_DIFFS.md → CodeRefs 追記

### Checks

- [ ] Docs Status Audit（CI）緑
- [ ] Docs Link Check（CI）緑
- [ ] Node20 ガード確認（ensure-node20.js）

### 実装ファイル

- `supabase/migrations/20251107_ops_metrics.sql`
- `supabase/functions/telemetry/index.ts`
- `supabase/functions/ops-alert/index.ts`
- `lib/src/features/ops/ops_telemetry.dart`
- `lib/core/telemetry/prod_search_telemetry.dart`
- `lib/src/features/ops/models/ops_metrics_model.dart`
- `lib/src/features/ops/providers/ops_metrics_provider.dart`
- `lib/src/features/ops/screens/ops_dashboard_page.dart`
- `.github/workflows/qa-e2e.yml`

### Feature Flag

- `STARLIST_FF_PROD_TELEMETRY=true` でProdSearchTelemetryを有効化

Reviewer: @pm-tim

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
