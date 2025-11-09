Status:: planned  
Source-of-Truth:: docs/ops/OPS-SUMMARY-EMAIL-001.md  
Spec-State:: 確定済み（週次レポート自動送信）  
Last-Updated:: 2025-11-07

# OPS-SUMMARY-EMAIL-001 — OPS Summary Email仕様

Status: planned  
Last-Updated: 2025-11-07  
Source-of-Truth: Edge Functions (`supabase/functions/ops-summary-email/`) + GitHub Actions (`.github/workflows/ops-summary-email.yml`)

> 責任者: ティム（COO/PM）／実装: SRE/データチーム

## 1. 目的

- Day8で実装したOPS Health Dashboardのデータを週次レポートとして自動送信する。
- 毎週月曜09:00 JSTにHTMLメールを自動生成・送信し、サービスの健全性を定期的に報告する。
- 「収集 → 可視化 → アラート表示 → ヘルスチェック → レポート」のサイクルを完成させる。

## 2. スコープ

- **Edge Function**: `ops-summary-email`新設（週次レポート生成）
- **GitHub Actions**: 週次スケジュール実行（毎週月曜09:00 JST）
- **HTMLテンプレート**: 稼働率・平均応答時間・異常率を可視化
- **メール送信**: SendGrid/Resend等のメールAPI連携

## 3. 仕様要点

### 3.1 Edge Function `ops-summary-email`

#### 3.1.1 機能

- 直近7日間のデータを集計
- `ops-health` Edge Functionまたは直接DBクエリでメトリクス取得
- HTMLテンプレートを生成
- dryRunモードでプレビュー可能

#### 3.1.2 出力指標

- **Uptime %**: 稼働率（100 - failure_rate）
- **Mean P95 Latency**: 平均P95遅延（ms）
- **Alert Count**: アラート件数
- **Alert Trend**: 前週比（↑/↓/→）

### 3.2 GitHub Actionsワークフロー

#### 3.2.1 スケジュール

- 毎週月曜09:00 JST実行（UTC 0:00）
- `workflow_dispatch`で手動実行も可能

#### 3.2.2 実行モード

- **DryRun**: 手動実行時はHTMLプレビューを返却
- **Production**: スケジュール実行時はメール送信

### 3.3 HTMLテンプレート

- シンプルなHTMLメール形式
- メトリクスをカード形式で表示
- トレンドを色分け表示（緑=改善、赤=悪化）

## 4. 実装詳細

### 4.1 Edge Function実装

- 期間指定（デフォルト7日間）
- メトリクス集計（uptime, mean p95, alert count）
- HTMLテンプレート生成
- dryRunモード対応

### 4.2 GitHub Actions実装

- 週次スケジュール設定
- 手動実行対応（dryRun）
- Secrets管理（SUPABASE_URL, SUPABASE_ANON_KEY, RESEND_API_KEY等）

### 4.3 メール送信（TODO）

- SendGrid/Resend等のメールAPI連携
- HTMLメール送信
- 送信先設定（環境変数または設定ファイル）

## 7. テスト観点

- Edge Function `ops-summary-email`がdryRunモードでHTMLプレビューを返却すること
- GitHub Actionsが週次スケジュールで実行されること
- HTMLテンプレートが正しく生成されること
- Resend/SendGridでメール送信が正常に動作すること
- 前週比計算が正しく動作すること

## 8. 受け入れ基準（DoD for Day9）

- [x] Edge Function `ops-summary-email`を実装
- [x] GitHub Actionsワークフローを作成
- [x] HTMLテンプレートを生成
- [x] Resend/SendGridでメール送信実装
- [x] dryRunモードで動作確認可能
- [ ] DryRun（手動）でHTMLプレビューが200 / `.ok==true`（実行待ち）
- [ ] 任意の宛先で手動送信テストが成功（Resend or SendGrid）（実行待ち）
- [ ] 週次スケジュール（月曜09:00 JST）で自動実行が成功（次週確認）
- [x] `docs/ops/OPS-SUMMARY-EMAIL-001.md`に本文サンプル・指標定義・ロールバックを追記
- [ ] `DAY9_SOT_DIFFS.md`に実行ログ・プレビュー画像を貼付（実行後）

## 9. ロールバック手順

- **ワークフロー無効化**: GitHub Actionsでワークフローを無効化
- **Function revert**: 前バージョンのEdge Functionにロールバック
- **Secrets削除**: メール送信用Secretsを削除して送信停止

## 10. 本文サンプル

### HTMLメールプレビュー

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .header { background: #2563eb; color: white; padding: 20px; text-align: center; }
    .content { padding: 20px; }
    .metric { margin: 20px 0; padding: 15px; background: #f3f4f6; border-radius: 8px; }
    .metric-label { font-weight: bold; color: #6b7280; }
    .metric-value { font-size: 24px; color: #111827; margin-top: 5px; }
    .trend { color: #10b981; } /* 改善時は緑、悪化時は赤 */
  </style>
</head>
<body>
  <div class="header">
    <h1>STARLIST OPS Weekly Summary</h1>
    <p>Period: Last 7 days</p>
  </div>
  <div class="content">
    <div class="metric">
      <div class="metric-label">Uptime</div>
      <div class="metric-value">99.95%</div>
    </div>
    <div class="metric">
      <div class="metric-label">Mean P95 Latency</div>
      <div class="metric-value">420ms</div>
    </div>
    <div class="metric">
      <div class="metric-label">Alerts</div>
      <div class="metric-value">
        12 
        <span class="trend">(↓2 WoW)</span>
      </div>
    </div>
  </div>
</body>
</html>
```

## 11. 到達性テスト手順

1. **dryRun実行**: GitHub Actionsで手動実行し、HTMLプレビューを確認
2. **本送信テスト**: テスト宛先でメール送信を確認
3. **スケジュール確認**: 次週月曜09:00 JSTに自動実行されることを確認
4. **メール受信確認**: 宛先にメールが届くことを確認
5. **メトリクス検証**: メール内のメトリクスが正しいことを確認

## 12. 到達率・冪等性・監査

### 12.1 送信の冪等化

- 同一週に重複送信を防ぐため、`report_week`（YYYY-Wnn）＋`channel`（email）＋`provider`をキーに送信ログを1行upsert
- 既に存在する場合はスキップし、ログに「skipped: already sent」を出力
- `ops_summary_email_logs`テーブルで管理

### 12.2 配信品質（迷惑対策）

- HTMLヘッダに`List-Unsubscribe`（`mailto:`と`https:`両方）を付与
- Preheaderテキスト（先頭の見えない要約）を埋め込み、開封率改善
- 差出人名（`STARLIST OPS`）は運用メールとブランドを一致

### 12.3 監査ログ

- `ops_summary_email_logs`テーブルに以下を保存:
  - `run_id`, `provider`, `message_id`, `to_count`, `subject`
  - `sent_at_utc`, `sent_at_jst`, `duration_ms`
  - `ok`, `error_code`, `error_message`
- 障害時はEdge Functionログ＋GitHub Run ArtifactsにHTMLプレビューを保存

### 12.4 フォールバック設計

- Resend送信失敗時のみSendGridへ切替
- 両方成功の二重送信を防ぐため、成功したprovider名をログ保存→以降は同週スキップ

### 12.5 宛先の安全策

- MVPではOPS/DEVのみに限定（`@starlist.jp`ドメインのみ許可）
- 将来的な対象拡大時はサプレッションリスト運用を同梱

## 13. 本番切替プレイブック

### 13.1 事前状態の確認

- DKIM/SPF：Resend Verification完了／SendGrid Sender Auth済み
- Secrets：GitHub（repo）とSupabase Functions（本番）に同一値を登録済み
- 宛先：`RESEND_TO_LIST`は`@starlist.jp`のみ（誤爆防止）

### 13.2 手動dryRun → プレビュー確認

- `.ok == true`をログで確認
- HTMLプレビューのPreheader表示とList-Unsubscribeヘッダーを目視確認
- 失敗時はログ末尾のエラーコードを`DAY9_SOT_DIFFS.md`の「Known Issues」に即追記

### 13.3 単発の本送信テスト

- Resend本送信 → 届信確認（迷惑振分け無し）
- 失敗時のみSendGridフォールバック（二重送信防止の冪等ガードは実装済）
- `DAY9_SOT_DIFFS.md`にRun ID / Provider / Message ID / JST時刻を記録

### 13.4 週次自動スケジュールの確定

- GitHub Actions `cron: 0 0 * * 1`（UTC）＝ JST月曜09:00
- サマータイム影響なし（日本）

### 13.5 PRマージ → 運用開始

- ラベル：`ops`, `docs`, `ci`を付与
- マージ後にActions実行権限を再確認

## 14. 運用監視ポイント（初週）

### 14.1 DBログの健全性

- 同一`report_week × channel × provider`が1行のみ（ユニーク制約OK）
- `ok=true`で`error_code`/`error_message`が`NULL`または空文字
- `to_count`と`RESEND_TO_LIST`の件数が一致

### 14.2 到達率・品質

- 開封率の初期指標：SubjectとPreheaderの関連性を維持
- 迷惑振分けゼロが理想。入った場合は差出人名or DKIMセレクタ再調整

### 14.3 冪等性

- 手動再送しても同週はskipログになることを確認
- Providerが異なる再送（Resend→SendGrid）でも2通化しない

## 15. 運用で使うSQLコマンド

### 15.1 直近10件の送信ログ（JST整形）

```sql
select run_id, provider, message_id, to_count,
       (sent_at_utc at time zone 'Asia/Tokyo') as sent_at_jst,
       ok, error_code
from ops_summary_email_logs
order by sent_at_utc desc
limit 10;
```

### 15.2 今週分が既に送られているか確認

```sql
-- 例: 2025-W45
select count(*) from ops_summary_email_logs
where report_week = '2025-W45' and channel='email' and ok = true;
```

### 15.3 二重送信の有無（安全確認）

```sql
select report_week, channel, provider, count(*) as cnt
from ops_summary_email_logs
group by 1,2,3
having count(*) > 1;
```

## 16. ロールバック最短手順（想定5分）

1. **Actions停止**: `ops-summary-email.yml`を`workflow_dispatch:`のみに切替 → push
2. **送信ガード**: Edge Functionのenvに`OPS_EMAIL_SUSPEND=true`を追加し即デプロイ
3. **通知**: `DAY9_SOT_DIFFS.md`に障害サマリを追記（Run ID / 事象 / 暫定対応 / 次アクション）

## 17. 参考リンク

- `docs/ops/OPS-HEALTH-DASHBOARD-001.md` - OPS Health Dashboard仕様
- `docs/ops/OPS-ALERT-AUTOMATION-001.md` - OPS Alert Automation仕様
- `supabase/functions/ops-health/index.ts` - ops-health Edge Function実装



### 13.2 手動dryRun → プレビュー確認

- `.ok == true`をログで確認
- HTMLプレビューのPreheader表示とList-Unsubscribeヘッダーを目視確認
- 失敗時はログ末尾のエラーコードを`DAY9_SOT_DIFFS.md`の「Known Issues」に即追記

### 13.3 単発の本送信テスト

- Resend本送信 → 届信確認（迷惑振分け無し）
- 失敗時のみSendGridフォールバック（二重送信防止の冪等ガードは実装済）
- `DAY9_SOT_DIFFS.md`にRun ID / Provider / Message ID / JST時刻を記録

### 13.4 週次自動スケジュールの確定

- GitHub Actions `cron: 0 0 * * 1`（UTC）＝ JST月曜09:00
- サマータイム影響なし（日本）

### 13.5 PRマージ → 運用開始

- ラベル：`ops`, `docs`, `ci`を付与
- マージ後にActions実行権限を再確認

## 14. 運用監視ポイント（初週）

### 14.1 DBログの健全性

- 同一`report_week × channel × provider`が1行のみ（ユニーク制約OK）
- `ok=true`で`error_code`/`error_message`が`NULL`または空文字
- `to_count`と`RESEND_TO_LIST`の件数が一致

### 14.2 到達率・品質

- 開封率の初期指標：SubjectとPreheaderの関連性を維持
- 迷惑振分けゼロが理想。入った場合は差出人名or DKIMセレクタ再調整

### 14.3 冪等性

- 手動再送しても同週はskipログになることを確認
- Providerが異なる再送（Resend→SendGrid）でも2通化しない

## 15. 運用で使うSQLコマンド

### 15.1 直近10件の送信ログ（JST整形）

```sql
select run_id, provider, message_id, to_count,
       (sent_at_utc at time zone 'Asia/Tokyo') as sent_at_jst,
       ok, error_code
from ops_summary_email_logs
order by sent_at_utc desc
limit 10;
```

### 15.2 今週分が既に送られているか確認

```sql
-- 例: 2025-W45
select count(*) from ops_summary_email_logs
where report_week = '2025-W45' and channel='email' and ok = true;
```

### 15.3 二重送信の有無（安全確認）

```sql
select report_week, channel, provider, count(*) as cnt
from ops_summary_email_logs
group by 1,2,3
having count(*) > 1;
```

## 16. ロールバック最短手順（想定5分）

1. **Actions停止**: `ops-summary-email.yml`を`workflow_dispatch:`のみに切替 → push
2. **送信ガード**: Edge Functionのenvに`OPS_EMAIL_SUSPEND=true`を追加し即デプロイ
3. **通知**: `DAY9_SOT_DIFFS.md`に障害サマリを追記（Run ID / 事象 / 暫定対応 / 次アクション）

## 17. 参考リンク

- `docs/ops/OPS-HEALTH-DASHBOARD-001.md` - OPS Health Dashboard仕様
- `docs/ops/OPS-ALERT-AUTOMATION-001.md` - OPS Alert Automation仕様
- `supabase/functions/ops-health/index.ts` - ops-health Edge Function実装

