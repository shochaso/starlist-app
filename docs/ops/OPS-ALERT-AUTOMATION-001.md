Status:: planned  
Source-of-Truth:: docs/ops/OPS-ALERT-AUTOMATION-001.md  
Spec-State:: 確定済み（Slack通知・Recent Alerts・CI検証）  
Last-Updated:: 2025-11-07

# OPS-ALERT-AUTOMATION-001 — OPS Alert Automation仕様

Status: planned  
Last-Updated: 2025-11-07  
Source-of-Truth: Edge Functions (`supabase/functions/ops-alert/`) + Flutter (`lib/src/features/ops/`)

> 責任者: ティム（COO/PM）／実装: SRE/データチーム

## 1. 目的

- Day6で実装したOPS Dashboardにアラート通知機能を追加し、「収集 → 可視化 → 通知」の三位一体サイクルを完成させる。
- 閾値超過時にSlack通知を自動送信し、FlutterダッシュボードでRecent Alertsを表示する。
- CIでダミーアラートを自動検証し、通知パイプラインの動作を保証する。

## 2. スコープ

- **Edge Function**: `ops-alert` の拡張（Slack Webhook連携）
- **Flutter**: `/ops` ダッシュボード下部に「Recent Alerts」セクション追加
- **CI**: `ops-alert-dryrun.yml` にてダミー通知を自動検証
- **Docs**: 検証手順・通知ペイロード仕様を文書化

## 3. 仕様要点

### 3.1 Edge Function `ops-alert` 拡張

#### 3.1.1 Slack通知連携

- 環境変数: `SLACK_WEBHOOK_URL` を設定
- 閾値超過時にSlack WebhookにPOSTリクエストを送信
- 通知ペイロード形式:

```json
{
  "text": "🚨 OPS Alert",
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*Alert Type:* High failure rate\n*Value:* 12.5%\n*Threshold:* 10.0%\n*Period:* 15 minutes"
      }
    }
  ]
}
```

#### 3.1.2 閾値監視

- **失敗率**: デフォルト10.0%（環境変数 `FAILURE_RATE_THRESHOLD` で設定可能）
- **P95遅延**: デフォルト500ms（環境変数 `P95_LATENCY_THRESHOLD` で設定可能）
- 監視期間: デフォルト15分（`minutes` パラメータで設定可能）

#### 3.1.3 アラート履歴の保存

- `ops_alerts` テーブルにアラート履歴を保存（オプション）
- 保存項目: `alerted_at`, `alert_type`, `value`, `threshold`, `period_minutes`

### 3.2 Flutter「Recent Alerts」セクション

#### 3.2.1 UI実装

- `/ops` ダッシュボード下部に「Recent Alerts」カードを追加
- 直近10件のアラートを時系列で表示
- アラート種別（失敗率/遅延）をアイコンで識別
- アラート時刻をJST（Asia/Tokyo）で表示

#### 3.2.2 データ取得

- `ops_alerts` テーブルから取得（実装済みの場合）
- または `ops-alert` Edge Functionのレスポンスから取得
- Provider: `opsRecentAlertsProvider` を新規作成

### 3.3 CI検証

#### 3.3.1 `ops-alert-dryrun.yml` ワークフロー

- PR作成時に自動実行
- `ops-alert` Edge Functionを `dry_run=true` で呼び出し
- レスポンスの `dryRun: true` と `alerts` フィールドを検証
- ダミーアラートが正しく検出されることを確認

## 4. 実装詳細

### 4.1 Edge Function拡張

#### 4.1.1 Slack通知実装

```typescript
// supabase/functions/ops-alert/index.ts
const slackWebhookUrl = Deno.env.get("SLACK_WEBHOOK_URL");

if (!dryRun && alerts.length > 0 && slackWebhookUrl) {
  const slackPayload = {
    text: "🚨 OPS Alert",
    blocks: alerts.map(alert => ({
      type: "section",
      text: {
        type: "mrkdwn",
        text: `*${alert}*\n*Period:* ${minutes} minutes`
      }
    }))
  };
  
  await fetch(slackWebhookUrl, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(slackPayload)
  });
}
```

#### 4.1.2 環境変数

- `SLACK_WEBHOOK_URL`: Slack Webhook URL（オプション）
- `FAILURE_RATE_THRESHOLD`: 失敗率閾値（デフォルト: 10.0）
- `P95_LATENCY_THRESHOLD`: P95遅延閾値（デフォルト: 500）

### 4.2 Flutter実装

#### 4.2.1 Provider追加

```dart
// lib/src/features/ops/providers/ops_metrics_provider.dart
final opsRecentAlertsProvider = FutureProvider<List<OpsAlert>>((ref) async {
  final client = ref.read(supabaseClientProvider);
  final response = await client
      .from('ops_alerts')
      .select()
      .order('alerted_at', ascending: false)
      .limit(10);
  
  return (response ?? []).map((json) => OpsAlert.fromJson(json)).toList();
});
```

#### 4.2.2 UI追加

```dart
// lib/src/features/ops/screens/ops_dashboard_page.dart
Widget _buildRecentAlerts(BuildContext context) {
  final alertsAsync = ref.watch(opsRecentAlertsProvider);
  
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Alerts',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          alertsAsync.when(
            data: (alerts) => alerts.isEmpty
                ? const Text('No alerts in the last 24 hours')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: alerts.length,
                    itemBuilder: (context, index) {
                      final alert = alerts[index];
                      return ListTile(
                        leading: Icon(
                          alert.type == 'failure_rate' ? Icons.error : Icons.timer,
                          color: Colors.red,
                        ),
                        title: Text(alert.message),
                        subtitle: Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(alert.alertedAt)),
                      );
                    },
                  ),
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text('Error: $error'),
          ),
        ],
      ),
    ),
  );
}
```

### 4.3 CI実装

#### 4.3.1 ワークフローファイル

```yaml
# .github/workflows/ops-alert-dryrun.yml
name: OPS Alert DryRun

on:
  pull_request:
    paths:
      - "supabase/functions/ops-alert/**"
      - ".github/workflows/ops-alert-dryrun.yml"

jobs:
  dryrun:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Test ops-alert dryRun
        env:
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
        run: |
          RESPONSE=$(curl -sS -X GET "$SUPABASE_URL/functions/v1/ops-alert?dry_run=true&minutes=15" \
            -H "Authorization: Bearer $SUPABASE_ANON_KEY")
          echo "$RESPONSE" | jq .
          echo "$RESPONSE" | jq -e '.dryRun == true' || exit 1
          echo "ops-alert dryRun test passed"
```

## 5. テスト観点

- `ops-alert` Edge Functionが閾値超過時にSlack通知を送信すること
- `dryRun=true` の場合は通知を送信しないこと
- FlutterダッシュボードでRecent Alertsが正しく表示されること
- CIでダミーアラートが正しく検出されること

## 6. 完了条件 (Day7)

- Edge Function `ops-alert` にSlack通知連携を実装
- Flutter `/ops` ダッシュボードに「Recent Alerts」セクションを追加
- CI `ops-alert-dryrun.yml` でダミー通知を自動検証
- ドキュメント `OPS-ALERT-AUTOMATION-001.md` を完成

## 7. 検証手順

### 7.1 ローカル検証

1. Edge Functionをローカルで実行:
   ```bash
   supabase functions serve ops-alert
   ```

2. ダミーデータで閾値超過をシミュレート:
   ```bash
   curl -X GET "http://localhost:54321/functions/v1/ops-alert?dry_run=true&minutes=15"
   ```

3. Flutterアプリで `/ops` にアクセスし、Recent Alertsセクションを確認

### 7.2 CI検証

1. PRを作成
2. `ops-alert-dryrun.yml` が自動実行されることを確認
3. ダミーアラートが正しく検出されることを確認

## 8. 通知ペイロード仕様

### 8.1 Slack通知フォーマット

```json
{
  "text": "🚨 OPS Alert",
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*Alert Type:* High failure rate\n*Value:* 12.5%\n*Threshold:* 10.0%\n*Period:* 15 minutes\n*Environment:* production"
      }
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*Alert Type:* High p95 latency\n*Value:* 650ms\n*Threshold:* 500ms\n*Period:* 15 minutes\n*Environment:* production"
      }
    }
  ]
}
```

### 8.2 アラート種別

- `failure_rate`: 失敗率超過
- `p95_latency`: P95遅延超過

## 9. 参考リンク

- `docs/ops/OPS-MONITORING-002.md` - OPS Dashboard仕様
- `docs/ops/OPS-TELEMETRY-SYNC-001.md` - Telemetry同期仕様
- `supabase/functions/ops-alert/index.ts` - Edge Function実装

