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

## 12. 参考リンク

- `docs/ops/OPS-HEALTH-DASHBOARD-001.md` - OPS Health Dashboard仕様
- `docs/ops/OPS-ALERT-AUTOMATION-001.md` - OPS Alert Automation仕様
- `supabase/functions/ops-health/index.ts` - ops-health Edge Function実装

