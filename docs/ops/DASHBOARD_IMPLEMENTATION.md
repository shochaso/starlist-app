---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# 継続監査KPIダッシュボード — 実装ガイド

## 目的（1行）

**p95レイテンシ／成功率／不一致ゼロ連続日数／リカバリ時間**を継続可視化し、Go/No-Goの"勘所"を**定量**で監督します。

## 情報アーキテクチャ（最小構成）

```
/app
  /dashboard/audit/page.tsx        # ダッシュボードUI（Next.js App Router）
  /components/kpi/KPIStat.tsx      # 数値カード
  /components/kpi/TrendChart.tsx   # 折れ線/棒グラフ（Recharts）
/app/api/audit/latest/route.ts     # (任意) 直近KPI API（ローカルJSONを返却）
/dashboard/data/latest.json        # CIが上書きする最新KPIスナップショット
/types/audit.ts                    # 型定義（KPI型、イベント型）
```

## データ契約

型定義は `types/audit.ts`、サンプルデータは `dashboard/data/latest.json` を参照。

## Next.js実装

実装コードは以下のファイルを参照：
- `/app/dashboard/audit/page.tsx` - ダッシュボードUI本体
- `/components/kpi/KPIStat.tsx` - KPI数値カードコンポーネント
- `/components/kpi/TrendChart.tsx` - トレンドチャートコンポーネント（Recharts）
- `/app/api/audit/latest/route.ts` - APIルート（任意）

## CI連携

`.github/workflows/integration-audit.yml` に以下を追記：

```yaml
- name: Publish latest KPI (on success)
  if: success()
  run: |
    mkdir -p dashboard/data
    # 監査生成物からKPI抽出（存在しなければ安全なデフォルト）
    DAY11_COUNT=$(jq 'length' tmp/audit_day11/send.json 2>/dev/null || echo 0)
    P95=$(jq '.p95_latency_ms' tmp/audit_day11/metrics.json 2>/dev/null || echo 0)
    STRIPE=$(jq 'length' tmp/audit_stripe/events_starlist.json 2>/dev/null || echo 0)
    # 成功率は存在時のみ算出（安全なfallback）
    OK=$(jq '[.[] | select((.status//200)==200)] | length' tmp/audit_day11/send.json 2>/dev/null || echo 0)
    SR=$( [ "$DAY11_COUNT" -gt 0 ] && awk "BEGIN{printf \"%.4f\", $OK/$DAY11_COUNT}" || echo 0 )
    CSR=$(jq '.checkout_success_rate // 0' dashboard/data/latest.json 2>/dev/null || echo 0)

    jq -n \
      --arg now "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      --argjson c "$DAY11_COUNT" \
      --argjson p "$P95" \
      --argjson s "$SR" \
      --argjson cs "$CSR" \
      --argjson mismatches "$(jq '. | length' tmp/audit_stripe/mismatches.json 2>/dev/null || echo 0)" \
      --argjson streak "$(jq '.mismatch_streak_zero_days // 0' dashboard/data/latest.json 2>/dev/null || echo 0)" \
      '{updated_at:$now, day11_count:$c, p95_latency_ms:$p, slack_success_rate:$s, checkout_success_rate:$cs, mismatches_today:$mismatches, mismatch_streak_zero_days:$streak}' \
      > dashboard/data/latest.json

- name: Commit KPI snapshot
  run: |
    git config user.name "ci-bot"
    git config user.email "ci@example.com"
    git add dashboard/data/latest.json
    git commit -m "chore: update KPI snapshot" || echo "no changes"
    git push || true
```

## セキュリティ／個人情報ガード

* **latest.json** は**集計値のみ**（IDやメール等は非保存）。
* CIは**Artifacts原本**から計算→**ダッシュボードには要約のみ反映**。
* 既存の `scripts/utils/redact.sh` は引き続き**送信前に必ず適用**。

## 受け入れ基準（このフェーズのDoD）

1. `dashboard/data/latest.json` がCI成功時に更新される
2. `/dashboard/audit` で **4指標**（成功率/件数/p95/不一致）が可視化
3. 「latest.jsonのみGit管理／原本はArtifacts」で情報流通が分離
4. 本番当日、**T+10分ウォッチ**を2回実施し、トレンドが安定（p95上昇なし）

## 導入手順（最短）

```bash
# 1) テンプレファイルを追加（上記を保存）
# 2) 依存導入
npm i recharts

# 3) ローカル確認
npm run dev   # → http://localhost:3000/dashboard/audit

# 4) CI実行後、latest.json が更新されUIに反映される
```



## 目的（1行）

**p95レイテンシ／成功率／不一致ゼロ連続日数／リカバリ時間**を継続可視化し、Go/No-Goの"勘所"を**定量**で監督します。

## 情報アーキテクチャ（最小構成）

```
/app
  /dashboard/audit/page.tsx        # ダッシュボードUI（Next.js App Router）
  /components/kpi/KPIStat.tsx      # 数値カード
  /components/kpi/TrendChart.tsx   # 折れ線/棒グラフ（Recharts）
/app/api/audit/latest/route.ts     # (任意) 直近KPI API（ローカルJSONを返却）
/dashboard/data/latest.json        # CIが上書きする最新KPIスナップショット
/types/audit.ts                    # 型定義（KPI型、イベント型）
```

## データ契約

型定義は `types/audit.ts`、サンプルデータは `dashboard/data/latest.json` を参照。

## Next.js実装

実装コードは以下のファイルを参照：
- `/app/dashboard/audit/page.tsx` - ダッシュボードUI本体
- `/components/kpi/KPIStat.tsx` - KPI数値カードコンポーネント
- `/components/kpi/TrendChart.tsx` - トレンドチャートコンポーネント（Recharts）
- `/app/api/audit/latest/route.ts` - APIルート（任意）

## CI連携

`.github/workflows/integration-audit.yml` に以下を追記：

```yaml
- name: Publish latest KPI (on success)
  if: success()
  run: |
    mkdir -p dashboard/data
    # 監査生成物からKPI抽出（存在しなければ安全なデフォルト）
    DAY11_COUNT=$(jq 'length' tmp/audit_day11/send.json 2>/dev/null || echo 0)
    P95=$(jq '.p95_latency_ms' tmp/audit_day11/metrics.json 2>/dev/null || echo 0)
    STRIPE=$(jq 'length' tmp/audit_stripe/events_starlist.json 2>/dev/null || echo 0)
    # 成功率は存在時のみ算出（安全なfallback）
    OK=$(jq '[.[] | select((.status//200)==200)] | length' tmp/audit_day11/send.json 2>/dev/null || echo 0)
    SR=$( [ "$DAY11_COUNT" -gt 0 ] && awk "BEGIN{printf \"%.4f\", $OK/$DAY11_COUNT}" || echo 0 )
    CSR=$(jq '.checkout_success_rate // 0' dashboard/data/latest.json 2>/dev/null || echo 0)

    jq -n \
      --arg now "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      --argjson c "$DAY11_COUNT" \
      --argjson p "$P95" \
      --argjson s "$SR" \
      --argjson cs "$CSR" \
      --argjson mismatches "$(jq '. | length' tmp/audit_stripe/mismatches.json 2>/dev/null || echo 0)" \
      --argjson streak "$(jq '.mismatch_streak_zero_days // 0' dashboard/data/latest.json 2>/dev/null || echo 0)" \
      '{updated_at:$now, day11_count:$c, p95_latency_ms:$p, slack_success_rate:$s, checkout_success_rate:$cs, mismatches_today:$mismatches, mismatch_streak_zero_days:$streak}' \
      > dashboard/data/latest.json

- name: Commit KPI snapshot
  run: |
    git config user.name "ci-bot"
    git config user.email "ci@example.com"
    git add dashboard/data/latest.json
    git commit -m "chore: update KPI snapshot" || echo "no changes"
    git push || true
```

## セキュリティ／個人情報ガード

* **latest.json** は**集計値のみ**（IDやメール等は非保存）。
* CIは**Artifacts原本**から計算→**ダッシュボードには要約のみ反映**。
* 既存の `scripts/utils/redact.sh` は引き続き**送信前に必ず適用**。

## 受け入れ基準（このフェーズのDoD）

1. `dashboard/data/latest.json` がCI成功時に更新される
2. `/dashboard/audit` で **4指標**（成功率/件数/p95/不一致）が可視化
3. 「latest.jsonのみGit管理／原本はArtifacts」で情報流通が分離
4. 本番当日、**T+10分ウォッチ**を2回実施し、トレンドが安定（p95上昇なし）

## 導入手順（最短）

```bash
# 1) テンプレファイルを追加（上記を保存）
# 2) 依存導入
npm i recharts

# 3) ローカル確認
npm run dev   # → http://localhost:3000/dashboard/audit

# 4) CI実行後、latest.json が更新されUIに反映される
```

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
