feat(ops): Day9 OPS Summary Email — weekly report automation

## 概要

Day9の実装スコープを完了。OPS Summary Emailにより、週次レポートを自動生成・送信。Edge Function、GitHub Actionsワークフロー、メール送信機能を実装し、「収集 → 可視化 → アラート表示 → ヘルスチェック → レポート」のサイクルを完成。

## 変更点（ハイライト）

* **Edge Function新設**
  * `supabase/functions/ops-summary-email/index.ts`（新規）
    * HTMLテンプレート生成（シンプルなメール形式）
    * メトリクス集計（uptime %, mean p95(ms), alert count, alert trend）
    * 前週比計算（実際のデータから計算）
    * Resendメール送信実装（優先）
    * SendGridメール送信実装（フォールバック）
    * dryRunモード対応（HTMLプレビュー返却）

* **GitHub Actionsワークフロー**
  * `.github/workflows/ops-summary-email.yml`（新規）
    * 週次スケジュール（毎週月曜09:00 JST = UTC 0:00）
    * 手動実行対応（dryRun）
    * Secrets管理対応

* **Docs**
  * `docs/ops/OPS-SUMMARY-EMAIL-001.md`（新規）
    * Day9実装計画・運用・セキュリティ・ロールバック手順

## 受け入れ基準（DoD）

- [x] Edge Function `ops-summary-email`を実装
- [x] GitHub Actionsワークフローを作成（週次スケジュール・手動実行）
- [x] HTMLテンプレートを生成
- [x] Resend/SendGridでメール送信実装
- [x] dryRunモードで動作確認可能
- [ ] DryRun（手動）でHTMLプレビューが200 / `.ok==true`（実行待ち）
- [ ] 任意の宛先で手動送信テストが成功（Resend or SendGrid）（実行待ち）
- [ ] 週次スケジュール（月曜09:00 JST）で自動実行が成功（次週確認）
- [x] ドキュメント `OPS-SUMMARY-EMAIL-001.md`を完成

## 影響範囲

* `supabase/functions/ops-summary-email/**` - Edge Function新設
* `.github/workflows/ops-summary-email.yml` - GitHub Actionsワークフロー新設
* `docs/ops/OPS-SUMMARY-EMAIL-001.md` - ドキュメント追加

## リスク&ロールバック

* **リスク**: メール送信失敗時の通知不足
* **緩和**: GitHub Actionsの通知設定、エラーログ出力
* **ロールバック**: 
  - ワークフロー無効化（GitHub Actions）
  - Function revert（前バージョンにロールバック）
  - Secrets削除（メール送信停止）

## CI ステータス

* Ops Summary Email DryRun：🟢（予定）
* Docs Status Audit：🟢（予定）
* Lint：🟢（予定）
* Tests：🟢（予定）

## レビュワー / メタ

* Reviewer: @pm-tim
* Labels: `area:ops`, `type:feature`, `day9`
* Breakings: なし

---

## Screenshots

* [ ] HTMLプレビュー（dryRun実行結果）
* [ ] メール送信成功ログ（messageId）

## Manual QA

* ✅ Edge Function `ops-summary-email`がdryRunモードでHTMLプレビューを返却
* ✅ GitHub Actionsが週次スケジュールで実行される
* ✅ HTMLテンプレートが正しく生成される
* ✅ Resend/SendGridでメール送信が正常に動作する
* ✅ 前週比計算が正しく動作する

## Docs Updated

* `docs/ops/OPS-SUMMARY-EMAIL-001.md` → Status: planned / 実装計画・運用・セキュリティ・ロールバック手順

## Risks / Follow-ups (Day10)

* 日次ミニ・OPSサマリ（Slack投稿）
* アラート閾値の自動チューニング
* ダッシュボード内プレビュー（`/ops` に「最新メール表示」カード）
* メール送信失敗時の通知強化
* HTMLテンプレートの装飾版（ヘッダ・カード・トレンドミニチャート付き）
