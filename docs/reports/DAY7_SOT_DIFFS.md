# Day7 — OPS Alert Automation SoT

Status: ready  
Date: 2025-11-08  
Owner: OPS/SRE × Flutter × Docs

## 実装サマリ

| 領域 | 変更内容 |
| --- | --- |
| Supabase Edge | `ops-alert` 関数に dryRun, 閾値管理, Slack/Discord Webhook モック, JSONレスポンス整備, supabase config 更新 |
| Flutter | `/ops` ダッシュボードで Recent Alerts を Edge 連動化、手動/自動リフレッシュ、エラー/空状態、アクセシビリティを追加 |
| CI | `.github/workflows/ops-alert-dryrun.yml` 作成：deno fmt/check → supabase functions test → Flutter widget smoke |
| Docs | `OPS-TELEMETRY-SYNC-001.md` Day7 追記、PR テンプレ `PR_BODY.md`、本 SoT ドキュメント |

## 受け入れ項目

- [x] Edge dryRun で Slack/Discord payload を含むレスポンスが得られる。
- [x] `/ops` の Recent Alerts リストが API 結果を 5 秒以内に再描画し、空/エラーで適切な CTA を表示。
- [x] `flutter test` および `ops-alert-dryrun` Workflow が緑。
- [x] ドキュメントと PR テンプレが最新状態。

## QAログ

```bash
flutter pub get
flutter test
deno task lint --cwd supabase/functions/ops-alert
supabase functions serve ops-alert --env-file supabase/.env.local
curl -X POST http://localhost:54321/functions/v1/ops-alert -d '{"env":"prod"}'
```

## マージ手順

1. PR: https://github.com/shochaso/starlist-app/pull/new/feature/day7-ops-alert-automation
2. Reviewer: @pm-tim
3. CI: `.github/workflows/ops-alert-dryrun.yml`
4. Merge strategy: Squash & merge（CI 緑化後）

## Post-merge

1. タグ: `git tag v0.7.0-ops-alert-beta && git push origin v0.7.0-ops-alert-beta`
2. CHANGELOG: Day7 セクションに OPS Alert Automation を追記
3. Slack: `#release` に PR リンク／サマリ／スクショ投稿

## Day8 予告

- Slack/Discord 実Webhook 実装、Secrets 管理 (`OPS_ALERT_SLACK_WEBHOOK`, など)
- 通知テンプレート (KPI, 期間, 影響範囲, 推奨アクション)
- 実アラートサプレッション & 审計ログ (`audit_ops_alerts`)
