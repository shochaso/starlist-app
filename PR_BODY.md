# Day7: OPS Alert Automation 実装（Edge + Flutter + CI + Docs）

## 概要

- Edge Function `ops-alert` の dryRun / スロットリング / Slack Webhook モック処理を実装し、telemetry との整合性を担保。
- `/ops` ダッシュボードに Recent Alerts セクションを拡張し、dryRun 結果のフェッチ＆リトライ UI を追加。
- CI (`.github/workflows/ops-alert-dryrun.yml`) で edge function の lint / dryRun / E2E smoke を自動検証。
- ドキュメント (`docs/reports/DAY7_SOT_DIFFS.md`, `docs/ops/OPS-TELEMETRY-SYNC-001.md`) を Day7 仕様に更新し、Post-merge 手順を明文化。

## 変更詳細

- Supabase Edge
  - `supabase/functions/ops-alert/index.ts`: dryRun 実装、閾値/サプレッションロジック、Slack/Discord モック、JSONレスポンス整備。
  - `supabase/functions/ops-alert/deno.json`: permissions, import map 更新。
- Flutter
  - `lib/src/features/ops/providers/ops_metrics_provider.dart`: `opsRecentAlertsProvider` を Edge 呼び出しベースに切替。
  - `lib/src/features/ops/pages/ops_dashboard_page.dart`: Recent Alerts リストを API 連動化（リフレッシュ、空/エラー表示、アクセシビリティ改善）。
  - 新規 Widget/Provider テストを追加し、mock alert クライアントで差分検証。
- CI
  - `.github/workflows/ops-alert-dryrun.yml`: deno fmt/check + supabase functions test + Flutter widget smoke。
  - Workflow から `OPS_WEBHOOK_URL` を Secrets 経由で dryRun へ注入。
- Docs & Assets
  - `docs/reports/DAY7_SOT_DIFFS.md`: 実装差分／テスト結果／マージ手順を追記。
  - `docs/ops/OPS-TELEMETRY-SYNC-001.md`: Day7 結果・スクショリンク・Day8 予告を追加。

## 受け入れ基準

- [ ] `/ops` の Recent Alerts が Edge dryRun 結果（最新 10 件）を表示し、失敗時は Retry CTA を表示。
- [ ] `OPS_MOCK=true` モードで疑似アラート列が描画され、CI で snapshot テストが安定。
- [ ] `ops-alert-dryrun` Workflow が緑（lint + dryRun + Flutter widget smoke）。
- [ ] Edge dryRun レスポンスは Slack/Discord 宛 payload を含み、人手で確認できるログが残る。
- [ ] 文書（Day7 SoT, OPS Telemetry spec）が更新され、Post-merge 作業手順が明記。

## 動作確認

```bash
flutter pub get
flutter test

# Edge dryRun (ローカル)
supabase functions serve ops-alert --env-file supabase/.env.local
curl -X POST "http://localhost:54321/functions/v1/ops-alert" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"env":"prod","app":"flutter_web","event_type":"search"}'

# Flutter (mock alerts)
flutter run -d chrome --web-renderer canvaskit \
  --dart-define=OPS_MOCK=true \
  --dart-define=OPS_ALERT_MOCK=true
```

## 影響範囲

- Edge Functions (`telemetry`, `ops-alert`)
- Flutter `/ops` UI & providers
- CI workflows
- Docs / release notes

## リスク & フォローアップ

- Slack/Discord 実機連携はまだ dryRun。Day8 で Webhook 秘密管理と実配送を実装予定。
- ダッシュボードのアラート数が多い場合のページネーションは今後対応。
- 連続失敗時のバナー（3 回閾値）は TODO: `opsAlertsFailureProvider` で管理予定。
