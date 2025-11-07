Status:: planned  
Source-of-Truth:: docs/ops/OPS-HEALTH-DASHBOARD-001.md  
Spec-State:: 確定済み（集計設計・UI設計）  
Last-Updated:: 2025-11-07

# OPS-HEALTH-DASHBOARD-001 — OPS Health Dashboard仕様

Status: planned  
Last-Updated: 2025-11-07  
Source-of-Truth: Edge Functions (`supabase/functions/ops-health/`) + Flutter (`lib/src/features/ops/`)

> 責任者: ティム（COO/PM）／実装: SRE/データチーム

## 1. 目的

- Day7で実装したOPS Alert Automationのアラート履歴からサービス健全性を可視化する。
- 稼働率・平均応答時間・異常率の推移をグラフで表示し、サービスの健全性を一目で把握できるようにする。
- 「収集 → 可視化 → アラート表示 → ヘルスチェック」のサイクルを完成させる。

## 2. スコープ

- **データ**: `ops_alerts_history`テーブルにアラート履歴を保存
- **Edge Function**: `ops-health`新設（期間別・サービス別に集計）
- **Flutter**: `/ops/health`タブ新設（稼働率・平均応答時間・異常率グラフ）
- **指標**: uptime %, mean p95(ms), alert trend
- **Docs**: 集計設計・UI設計を文書化

## 3. 仕様要点

### 3.1 データモデル

#### 3.1.1 `ops_alerts_history`テーブル

```sql
create table if not exists public.ops_alerts_history (
  id bigserial primary key,
  alerted_at timestamptz not null default now(),
  alert_type text not null check (alert_type in ('failure_rate', 'p95_latency')),
  value numeric not null,
  threshold numeric not null,
  period_minutes integer not null,
  app text,
  env text,
  event text,
  metrics jsonb -- 元のメトリクス情報を保存
);

create index idx_ops_alerts_history_alerted_at on public.ops_alerts_history (alerted_at desc);
create index idx_ops_alerts_history_type_env on public.ops_alerts_history (alert_type, env, alerted_at desc);
```

#### 3.1.2 アラート履歴の保存

- `ops-alert` Edge Functionでアラート検出時に`ops_alerts_history`に保存
- 保存項目: `alerted_at`, `alert_type`, `value`, `threshold`, `period_minutes`, `app`, `env`, `event`, `metrics`

### 3.2 Edge Function `ops-health`

#### 3.2.1 集計機能

- 期間別集計: 1時間/6時間/24時間/7日間
- サービス別集計: app/env/event別
- 指標計算:
  - **Uptime %**: `(1 - failure_rate) * 100`
  - **Mean p95(ms)**: p95遅延の平均値
  - **Alert trend**: アラート発生頻度の推移

#### 3.2.2 レスポンス形式

```json
{
  "ok": true,
  "period": "24h",
  "aggregations": [
    {
      "app": "starlist",
      "env": "prod",
      "uptime_percent": 99.5,
      "mean_p95_ms": 250,
      "alert_count": 3,
      "alert_trend": "decreasing"
    }
  ]
}
```

### 3.3 Flutter `/ops/health`タブ

#### 3.3.1 UI構成

- **稼働率グラフ**: 時系列でuptime %を表示（折れ線グラフ）
- **平均応答時間グラフ**: 時系列でmean p95(ms)を表示（折れ線グラフ）
- **異常率グラフ**: 時系列でalert trendを表示（棒グラフ）
- **期間選択**: 1時間/6時間/24時間/7日間
- **サービスフィルタ**: app/env/event別

#### 3.3.2 データ取得

- Provider: `opsHealthProvider`を新規作成
- Edge Function `ops-health`を呼び出して集計データを取得

## 4. 実装詳細

### 4.1 DBマイグレーション

#### 4.1.1 `ops_alerts_history`テーブル作成

```sql
-- supabase/migrations/YYYYMMDDHHMMSS_ops_alerts_history.sql
create table if not exists public.ops_alerts_history (
  id bigserial primary key,
  alerted_at timestamptz not null default now(),
  alert_type text not null check (alert_type in ('failure_rate', 'p95_latency')),
  value numeric not null,
  threshold numeric not null,
  period_minutes integer not null,
  app text,
  env text,
  event text,
  metrics jsonb
);

create index idx_ops_alerts_history_alerted_at on public.ops_alerts_history (alerted_at desc);
create index idx_ops_alerts_history_type_env on public.ops_alerts_history (alert_type, env, alerted_at desc);

-- RLS
alter table public.ops_alerts_history enable row level security;

create policy ops_alerts_history_select on public.ops_alerts_history
  for select to authenticated
  using (true);
```

### 4.2 Edge Function `ops-health`

#### 4.2.1 実装

```typescript
// supabase/functions/ops-health/index.ts
interface HealthQuery {
  period?: string; // '1h', '6h', '24h', '7d'
  app?: string;
  env?: string;
  event?: string;
}

serve(async (req) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const query = req.method === "GET" 
      ? Object.fromEntries(new URL(req.url).searchParams.entries())
      : await req.json().catch(() => ({})) as HealthQuery;

    const period = query.period || '24h';
    const periodMinutes = {
      '1h': 60,
      '6h': 360,
      '24h': 1440,
      '7d': 10080,
    }[period] || 1440;

    const since = new Date(Date.now() - periodMinutes * 60 * 1000).toISOString();

    // Get alert history
    const { data: alerts, error: alertsError } = await supabase
      .from('ops_alerts_history')
      .select('*')
      .gte('alerted_at', since)
      .order('alerted_at', { ascending: false });

    if (alertsError) {
      throw alertsError;
    }

    // Get metrics from v_ops_5min
    const { data: metrics, error: metricsError } = await supabase
      .from('v_ops_5min')
      .select('*')
      .gte('bucket_5m', since)
      .order('bucket_5m', { ascending: true });

    if (metricsError) {
      throw metricsError;
    }

    // Aggregate by app/env/event
    const aggregations = aggregateHealthMetrics(alerts, metrics, query);

    return new Response(
      JSON.stringify({
        ok: true,
        period,
        aggregations,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("[ops-health] Error:", error);
    return new Response(
      JSON.stringify({ error: String(error) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
```

### 4.3 Flutter実装

#### 4.3.1 Provider追加

```dart
// lib/src/features/ops/providers/ops_metrics_provider.dart
final opsHealthProvider = FutureProvider<OpsHealthData>((ref) async {
  final client = ref.read(supabaseClientProvider);
  final period = ref.watch(opsHealthPeriodProvider);
  
  try {
    final response = await client.functions.invoke(
      'ops-health',
      body: {
        'period': period,
      },
    );

    if (response.data == null) {
      return OpsHealthData.empty();
    }

    return OpsHealthData.fromJson(response.data as Map<String, dynamic>);
  } catch (e) {
    print('[opsHealthProvider] Error: $e');
    return OpsHealthData.empty();
  }
});

final opsHealthPeriodProvider = StateProvider<String>((ref) => '24h');
```

#### 4.3.2 UI実装

```dart
// lib/src/features/ops/screens/ops_health_page.dart
class OpsHealthPage extends ConsumerWidget {
  const OpsHealthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(opsHealthProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('OPS Health Dashboard'),
      ),
      body: healthAsync.when(
        data: (health) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPeriodSelector(ref),
            const SizedBox(height: 16),
            _buildUptimeChart(health),
            const SizedBox(height: 16),
            _buildMeanP95Chart(health),
            const SizedBox(height: 16),
            _buildAlertTrendChart(health),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
```

## 5. 指標定義

### 5.1 Uptime %

- **計算式**: `(1 - failure_rate) * 100`
- **データソース**: `v_ops_5min`ビュー
- **表示**: 時系列折れ線グラフ

### 5.2 Mean p95(ms)

- **計算式**: p95遅延の平均値
- **データソース**: `v_ops_5min`ビュー
- **表示**: 時系列折れ線グラフ

### 5.3 Alert Trend

- **計算式**: アラート発生頻度の推移
- **データソース**: `ops_alerts_history`テーブル
- **表示**: 時系列棒グラフ

## 6. テスト観点

- `ops_alerts_history`テーブルにアラート履歴が正しく保存されること
- Edge Function `ops-health`が期間別・サービス別に集計できること
- Flutter `/ops/health`タブで稼働率・平均応答時間・異常率グラフが表示されること
- 期間選択・サービスフィルタが正しく動作すること

## 7. 完了条件 (Day8)

- `ops_alerts_history`テーブルを作成
- Edge Function `ops-health`を実装
- Flutter `/ops/health`タブを実装
- 稼働率・平均応答時間・異常率グラフを表示
- ドキュメント `OPS-HEALTH-DASHBOARD-001.md`を完成

## 8. 参考リンク

- `docs/ops/OPS-MONITORING-002.md` - OPS Dashboard仕様
- `docs/ops/OPS-ALERT-AUTOMATION-001.md` - OPS Alert Automation仕様
- `supabase/functions/ops-alert/index.ts` - ops-alert Edge Function実装

