# 本番ローンチ運用チェックリスト（1ページ完結）

## 🚀 すぐ使える最短3コマンド（本番直前）

```bash
AUDIT_LOOKBACK_HOURS=48 ./FINAL_INTEGRATION_SUITE.sh
make verify && make summarize
make gonogo
```

---

## 📋 運用フロー（本番前・当日・後日）

### 1) 本番前（5分）

```bash
# 依存ツール導入（初回のみ）
make schema

# 48hスコープで統合スイート実行 → 監査票生成
AUDIT_LOOKBACK_HOURS=48 ./FINAL_INTEGRATION_SUITE.sh

# 監査票の構造検証＋要約
make verify && make summarize

# Go/No-Go 10項目チェック
make gonogo
```

**合格基準（抜粋）**：
- `make verify` 成功
- Slack permalink有効
- DB監査0件
- Stripe×DB突合不一致0件
- p95 予算内
- Artifacts保存OK

---

### 2) 当日（オンデマンド）

```bash
# Day11のみ実施
make day11 HOURS=48

# Pricing監査のみ実施
make pricing HOURS=48

# 監査票のみ再生成（Artifacts/ログから）
make audit HOURS=48
```

**PR提出時**：
- テンプレのチェックボックス（整数/範囲/重複/整合 など）をすべて☑
- 証跡リンク（監査票、Slack permalink、Artifacts）を貼り付け

---

### 3) 後日（定期運用）

- **毎週 月曜 09:05 JST**：`integration-audit.yml` が自動実行
- 失敗しても **Artifacts は必ず保存**（`if: always()`）
- 監査票は Git 管理、元JSON/ログは Git 外＋Artifactsで90日保全

---

## ✅ 最終Go/No-Goクイックチェック（30秒）

```bash
# 1) スキーマ/ツール導入（初回のみ）
make schema

# 2) 48hスコープで統合スイート実行（JST/Front-Matter/レダクション込み）
AUDIT_LOOKBACK_HOURS=48 ./FINAL_INTEGRATION_SUITE.sh

# 3) 監査票の構造検証＆要点ダイジェスト
make verify && make summarize
```

### Go判定条件（最小セット）

- [ ] `make verify` 成功（`schemas/audit_report.schema.json`適合）
- [ ] 監査票Front-Matterに `supabase_ref(20桁) / git_sha / artifacts / slack_permalink` が揃っている
- [ ] **Stripe×DB**：`sql/pricing_audit.sql` と `sql/pricing_reconcile.sql` の不一致ゼロ
- [ ] **Day11**：`p95_latency_ms < P95_LATENCY_BUDGET_MS`、send/dryRun件数の乖離なし
- [ ] **CI**：失敗でもArtifacts保存（`integration-audit.yml` の `if: always()` で確認）

---

## 🚀 本番ローンチ運用（定常化の最短動線）

### A. 手動実行（オンデマンド）

```bash
# Day11だけ
make day11 HOURS=48

# Pricingだけ
make pricing HOURS=48

# 監査票だけ再生成（ソースはArtifacts or tmpから）
make audit HOURS=48
```

### B. 定期実行（すでに設定済）

- **毎週月曜 09:05 JST** に `integration-audit.yml` が起動
- 成果物：監査票（Markdown）＋元JSON/ログ（Artifacts、90日保持）
- PRへ要約自動添付（設定済のPRテンプレとワークフローで反映）

---

## 🧯 即応リカバリ（Exit Code 別）

### Exit 21: Permalink未取得
- **症状**: Slack Webhook 429/5xx/Secret不一致の可能性
- **対処**: Secret再設定
- **再実行**: `make day11`

### Exit 22: Stripe 0件
- **症状**: Stripeイベントが抽出されない
- **対処**: `HOURS=72` に延長／`STRIPE_API_KEY`（読み取り権限）確認
- **再実行**: `make pricing HOURS=72`

### Exit 23: send空
- **症状**: Day11 sendが空、実行失敗
- **対処**: `logs/day11/*_send.json` のHTTP/JSON整合を確認、`ops-slack-summary` 末尾ログでエラー確認
- **再実行**: `make day11`

### 機微情報懸念
```bash
make redact && ./FINAL_INTEGRATION_SUITE.sh --audit-only
```

---

## 🛡️ 運用の要点（再確認）

### 網羅性
- Slack／Edge／Stripe／DB の4面要約を監査票に必ず含める

### 再現性
- JST固定＋Front-Matter＋Schema検証（`make verify`）

### 証跡性
- Front-Matter に `supabase_ref / git_sha / artifacts`
- 元データはArtifactsで保持

### 安全性
- `scripts/utils/redact.sh` でメール/電話/番号を自動マスキング

### 運用性
- `make summarize / verify / clean / distclean` で日々の労力最小化

---

## 🧩 PR提出フォーマット（貼って使える定型）

### 証跡リンク

- 監査票：`docs/reports/<YYYY-MM-DD>_DAY11_AUDIT_<G-WNN>.md`
- Pricing：`docs/reports/<YYYY-MM-DD>_PRICING_AUDIT.md`
- Slack：`<permalink>`
- Artifacts：Actions Run `<link>`

### チェック（全て☑でGo）

- [ ] slack_permalink_exists
- [ ] edge_logs_collected
- [ ] stripe_events_nonzero
- [ ] day11_send_not_empty
- [ ] db_price_range_valid
- [ ] db_integer_ok
- [ ] db_dup_zero
- [ ] db_ref_integrity_ok

---

## 🔍 推奨の"監査KPI"可視化（任意の次ステップ）

### Day11
- `p50/p95 レイテンシ・成功率・Slack投稿率・再送率` を時系列化（既存ダッシュボードにカード追加）

### Pricing
- `checkout成功率 / 金額分布（学生/成人）/ 不一致検知ゼロ連続日数` を可視化

---

## 📋 クイックリファレンス

### よく使うコマンド

```bash
# Go/No-Goチェック
make gonogo

# スモークテスト（30秒）
make smoke-test

# 最新監査票の要約
make summarize

# 構造検証
make verify

# 一時ファイル削除
make clean

# 完全クリーン
make distclean
```

### 環境変数

```bash
# 必須
export SUPABASE_URL='https://<project-ref>.supabase.co'
export SUPABASE_ANON_KEY='<anon-key>'

# オプション（CI/Stripe/Supabase CLI）
export SUPABASE_PROJECT_REF='<project-ref>'
export SUPABASE_ACCESS_TOKEN='<access-token>'
export STRIPE_API_KEY='<stripe-api-key>'

# 監査制御
export AUDIT_LOOKBACK_HOURS=48
export P95_LATENCY_BUDGET_MS=2000
```

---

**最終更新**: 2025-11-08  
**責任者**: Ops Team

