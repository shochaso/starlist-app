Status:: planned
Source-of-Truth:: docs/ops/OPS-MONITORING-V3-001.md
Spec-State:: 確定済み（自動閾値調整＋週次レポート可視化）
Last-Updated:: 2025-11-08

# OPS監視v3 — 自動閾値調整と週次レポート可視化（Day11）

## 概要

Slack通知履歴（`ops_slack_notify_logs`）をもとに、通知頻度や傾向を学習して自動的に閾値を再計算し、結果を週次サマリとしてSlackやNotionに自動投稿することで、「アラートの最適化」と「運用負荷の削減」を実現する。

---

## 目的

1. **自動閾値最適化**: 通知履歴から統計的に最適な閾値を算出し、過剰通知・過少通知を抑制
2. **週次サマリ可視化**: 通知傾向を週次レポートとして自動生成・投稿
3. **運用負荷削減**: 手動での閾値調整作業を自動化し、運用効率を向上

---

## システム構成

| レイヤ | コンポーネント | 役割 |
|--------|----------------|------|
| **Edge Function** | `ops-slack-summary` | 通知履歴集計 → 自動閾値計算 → サマリ生成 |
| **DB / View** | `v_ops_notify_stats` | 通知ログ集約ビュー（期間・レベル別） |
| **Slack Integration** | `SLACK_WEBHOOK_OPS_SUMMARY` | 週次サマリ投稿用Webhook |
| **スケジュール実行** | GitHub Actions (`ops-slack-summary.yml`) | 毎週月曜09:00 JSTに自動実行 |
| **UI拡張** | Flutter: `OpsDashboardPage` | 通知件数と閾値トレンドをグラフ化 |

---

## 自動閾値アルゴリズム（β版）

| 指標 | 算出方法 | 用途 |
|------|----------|------|
| **平均通知数 (μ)** | 直近14日間の通知件数の平均 | 基準値算出 |
| **標準偏差 (σ)** | 同期間の分散の平方根 | 異常判定の振れ幅計算 |
| **新閾値** | `μ + 2σ` | 通常値上限（過剰通知検出） |
| **異常閾値** | `μ + 3σ` | Criticalライン（運用警告） |

### 補足

- 過剰通知が続いた場合、自動で閾値を上方修正（Adaptive Upper Bound）
- 通知が少なすぎる場合は逆に下方補正
- 初期値はDay10の固定閾値（Critical: 98.0%/1500ms, Warning: 99.5%/1000ms）を使用

---

## 週次レポート出力例（Slack）

```
📊 OPS Summary Report（2025-W46）
────────────────────────────
✅ 正常通知：42件（前週比 +6.3%）
⚠ 警告通知：3件（±0）
🔥 重大通知：1件（-50%）

📈 通知平均：37.2件 / σ=4.8
🔧 新閾値：46.8件（μ+2σ）

📅 次回自動閾値再算出：2025-11-17（月）
────────────────────────────
🧠 コメント：通知数は安定傾向。閾値維持。
```

---

## 実装計画（Day11スプリント）

| ステップ | 担当 | 内容 | 期限 |
|---------|------|------|------|
| 1️⃣ DBビュー作成 | Mine | `v_ops_notify_stats` 追加 | 11/09 |
| 2️⃣ Edge Function実装 | Mine | `ops-slack-summary` 新規作成 | 11/10 |
| 3️⃣ Slack連携テスト | Tim | Webhook確認・出力整形 | 11/10 |
| 4️⃣ CI設定 | Tim | `.github/workflows/ops-slack-summary.yml` 追加 | 11/11 |
| 5️⃣ QA / dryRun検証 | Tim / Mine | dryRun & 本送信テスト | 11/12 |
| 6️⃣ ドキュメント更新 | Tim | `STARLIST_OVERVIEW.md` / `COMMON_DOCS_INDEX.md` / `Mermaid.md` | 11/13 |

---

## DB View定義案

### `v_ops_notify_stats`

```sql
CREATE OR REPLACE VIEW v_ops_notify_stats AS
SELECT
  date_trunc('day', inserted_at) AS day,
  level,
  COUNT(*) AS notification_count,
  AVG(success_rate) AS avg_success_rate,
  AVG(p95_ms) AS avg_p95_ms,
  SUM(error_count) AS total_errors
FROM ops_slack_notify_logs
WHERE inserted_at >= NOW() - INTERVAL '14 days'
GROUP BY day, level
ORDER BY day DESC, level;
```

---

## Edge Function仕様

### `ops-slack-summary`

**エンドポイント**: `/functions/v1/ops-slack-summary`

**パラメータ**:
- `dryRun` (boolean, optional): プレビューモード（デフォルト: false）
- `period` (string, optional): 集計期間（デフォルト: "14d"）

**処理フロー**:
1. `v_ops_notify_stats` から直近14日間の通知統計を取得
2. 平均通知数 (μ) と標準偏差 (σ) を計算
3. 新閾値 = `μ + 2σ`、異常閾値 = `μ + 3σ` を算出
4. 週次サマリメッセージを生成
5. dryRun=false の場合、Slack Webhookに投稿

**レスポンス例**:
```json
{
  "ok": true,
  "period": "14d",
  "stats": {
    "mean_notifications": 37.2,
    "std_dev": 4.8,
    "new_threshold": 46.8,
    "critical_threshold": 51.6
  },
  "weekly_summary": {
    "normal": 42,
    "warning": 3,
    "critical": 1,
    "normal_change": "+6.3%",
    "warning_change": "±0",
    "critical_change": "-50%"
  },
  "message": "📊 OPS Summary Report..."
}
```

---

## GitHub Actions仕様

### `.github/workflows/ops-slack-summary.yml`

**スケジュール**: 毎週月曜09:00 JST（cron: `0 0 * * 1`）

**手動実行**: `workflow_dispatch`（dryRunオプション付き）

**処理**:
1. Secrets検証（`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SLACK_WEBHOOK_OPS_SUMMARY`）
2. Edge Function呼び出し（`/functions/v1/ops-slack-summary`）
3. レスポンス検証（`.ok == true`）

---

## Flutter UI拡張（予定）

### `OpsDashboardPage` 拡張

- 週次トレンドチャート追加
- 通知件数と閾値トレンドをグラフ化
- 自動閾値調整の履歴表示

---

## 受け入れ基準（DoD）

- [ ] `v_ops_notify_stats` ビューが作成され、正しく集計される
- [ ] Edge Function `ops-slack-summary` が実装され、自動閾値計算が動作する
- [ ] GitHub Actionsワークフローが作成され、週次スケジュール実行が設定される
- [ ] dryRunモードで動作確認可能
- [ ] 本送信テストでSlackに週次サマリが投稿される
- [ ] ドキュメントが更新される

---

## リスク&ロールバック

**リスク**:
- 自動閾値計算が不適切な値を生成する可能性
- Slack Webhookのレート制限

**緩和**:
- dryRunモードでの事前確認
- 閾値の上限・下限を設定（例: 90% ≤ success_rate ≤ 99.9%）

**ロールバック**:
- GitHub Actionsを無効化
- Edge Functionを前バージョンにロールバック
- 固定閾値に戻す

---

## 更新履歴

| 日付 | 更新者 | 変更概要 |
|------|--------|----------|
| 2025-11-08 | Tim | Day11仕様ドラフト作成 |

