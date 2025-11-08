# 本番ローンチ運用チェックリスト（1ページ完結）

## ✅ 最終グリーンライト（PM最終確認：3点だけ）

1. `make gonogo` が **ALL PASS**
2. 直近監査票に **Slack/Edge/Stripe/DB** の4面要約と **Front-Matter必須キー**（`supabase_ref / git_sha / artifacts / checks`）が揃っている
3. `integration-audit.yml` の **Artifacts保存（if: always()）が有効**（直近Runで確認）

→ 3点ともOKで**Go**判定です。

---

## 🚀 すぐ使える最短3コマンド（本番直前）

```bash
AUDIT_LOOKBACK_HOURS=48 ./FINAL_INTEGRATION_SUITE.sh
make verify && make summarize
make gonogo
```

---

## 📅 本日ローンチの段取り（推奨）

* **T-15分**：上記3コマンド → SlackでGo宣言（時刻を残す）
* **T+0〜45分**：必要に応じて
  ```bash
  make day11 HOURS=48
  make pricing HOURS=48
  ```
* **T+45分**：成功判定 or バックアウト
  * 成功ならPRテンプレのチェックを**全て☑**→マージ
  * バックアウトなら
    ```bash
    echo "$(date -Iseconds) mark send as invalid (rollback)" >> logs/day11/recovery_marks.log
    ./DAY11_RECOVERY_TEMPLATE.sh
    ```
    Slackにバックアウト宣言（permalinkを監査票に追記）

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

## 🧯 運用リスクの最終つぶし（超要点）

### Permalink未取得（Exit 21）
- **症状**: Slack Webhookの429/5xx・Secret不一致
- **対処**: Secret再設定
- **再実行**: `make day11`

### Stripe 0件（Exit 22）
- **症状**: Stripeイベントが抽出されない
- **対処**: `HOURS=72` へ一時延長 + API KeyのRead権限確認
- **再実行**: `make pricing HOURS=72`

### send空（Exit 23）
- **症状**: Day11 sendが空、実行失敗
- **対処**: `*_send.json` と `ops-slack-summary` 末尾ログでHTTP/JSON整合確認
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

---

## ✅ Ready-to-Launch 最終確認（追加チェック 8つ）

1. **変更凍結ウィンドウ**：ローンチ前後±2時間はデプロイ停止（CIの手動承認を必須化）
2. **バックアウトタイマー**：Go宣言から**45分**で"成功判定 or バックアウト"を自動促す
3. **Secretsローテーション計画**：Slack/Stripe/Supabaseのキー更新日を記録（下記参照）
4. **Artifacts保存SLA**：90日保持→**120日**へ引き上げ（必要ならActions設定を更新）
5. **監査票バッジ**：READMEに「直近監査ステータス」バッジ（CI結果）を追加
6. **オンコール体制**：当日1名（主要）＋バックアップ1名の連絡先と応答SLA（5分）
7. **エスカレーション表**：障害レベルごとの連絡順（Slack → 電話）を記載
8. **事後レビュー雛形**：軽量ポストモーテム（5項目）テンプレを準備

---

## 🕒 D-Day 運用ミニ・ランブック（貼って即運用）

### D-0 直前（T-15m）

```bash
# スモーク（48h・JST・Front-Matter検証）
make schema && AUDIT_LOOKBACK_HOURS=48 ./FINAL_INTEGRATION_SUITE.sh && make verify && make summarize
```

**判定**：`make gonogo` で10項目ALL PASS → **Go宣言**（Slackで時刻を残す）

### D-0 実行（T+0〜45m）

```bash
# Day11のみ/ Pricingのみの分割実行（必要に応じて）
make day11 HOURS=48
make pricing HOURS=48

# バックアウトタイマー（45分後に自動プロンプト）
( sleep 2700 && echo "[NOTICE] 45m経過。成功判定 or バックアウトを選択してください。" ) &
```

### 成功判定（T+≤45m）

- 監査票に **4面要約（Slack/Edge/Stripe/DB）** が整い、**不一致0**、**p95予算内**を確認
- PRテンプレのチェックボックスを**全て☑** → マージ

### バックアウト（T+45m）

```bash
# 直近送信の無効化マーキング（ログに残す）
echo "$(date -Iseconds) mark send as invalid (rollback)" >> logs/day11/recovery_marks.log

# 復旧テンプレ実行
./DAY11_RECOVERY_TEMPLATE.sh
```

Slackに**バックアウト宣言**（permalinkを監査票に追記）→ 48h後に再Try（根因つぶし後）

---

## 🔐 秘密情報・安全網の最終メモ

- 監査票は**Git管理**、元JSON/ログは**Git外＋Artifacts**（レダクション済みの要約のみMDに掲載）
- `scripts/utils/redact.sh` を **EdgeログとStripe要約に常時適用**
- `schemas/audit_report.schema.json` に**必須キー**（`supabase_ref / git_sha / artifacts / checks`）を固定
- `make verify` が**赤**なら即No-Go（例外なし）

---

## 📈 KPI ミニ定義（次の可視化用）

| 区分      | 指標          | 目安                                     |
| ------- | ----------- | -------------------------------------- |
| Day11   | Slack投稿成功率  | 99%+                                   |
| Day11   | p95 latency | **< 2,000ms**（`P95_LATENCY_BUDGET_MS`） |
| Pricing | Checkout成功率 | 96%+                                   |
| Pricing | 不一致検知       | 0件連続 **14日**                           |

---

## 📝 事後レビュー（軽量テンプレ：5分で書ける）

```markdown
# Postmortem (MM-DD)

- 何が起きた？（1行）
- 影響範囲（ユーザー/時間）
- 根因（技術/運用）
- 是正（コード/Runbook/CI）
- 再発防止（期限/担当）
```

---

## 🔄 Secretsローテーション計画

| サービス      | キー名                    | 最終更新日   | 次回更新予定日 | 担当者 |
| --------- | ---------------------- | -------- | -------- | ---- |
| Slack     | SLACK_WEBHOOK_OPS_SUMMARY | YYYY-MM-DD | YYYY-MM-DD | -    |
| Stripe    | STRIPE_API_KEY         | YYYY-MM-DD | YYYY-MM-DD | -    |
| Supabase  | SUPABASE_ACCESS_TOKEN  | YYYY-MM-DD | YYYY-MM-DD | -    |

### Secrets Rotation Log

- 2025-11-08: Slack Webhook 更新（管理者：@xxx）/ 次回レビュー：2026-01-15
- 2025-11-08: STRIPE_API_KEY Read-Only 確認（@xxx）/ 次回レビュー：2026-02-01
- 2025-11-08: Supabase Access Token（CI）更新（@xxx）/ 次回レビュー：2026-02-01

---

## 📞 オンコール体制

| 役割     | 担当者 | 連絡先        | 応答SLA |
| ------ | --- | ---------- | ------ |
| 主要     | -   | Slack/電話   | 5分    |
| バックアップ | -   | Slack/電話   | 5分    |

---

## 🚨 エスカレーション表

| Sev | 例 | 連絡順 | SLA |
| --- | --- | --- | --- |
| P0 | 決済不可/監査壊滅 | On-call→PM→全体Slack/電話 | 5分内対応/45分判定 |
| P1 | 一部遅延/部分不一致 | On-call→PM | 15分内初動/当日中是正 |
| P2 | 軽微/表示のみ | 担当者内共有 | 翌営業日内 |

---

## 🎯 クイックコマンド（3本）

```bash
# 監査 → 検証 → 要約（30秒）
AUDIT_LOOKBACK_HOURS=48 ./FINAL_INTEGRATION_SUITE.sh && make verify && make summarize

# Go/No-Go（10項目）
make gonogo

# 失敗時の再生成（レダクション適用）
make redact && ./FINAL_INTEGRATION_SUITE.sh --audit-only
```

### バックアウト45分タイマー（ワンライナー）

```bash
( sleep 2700 && echo "[NOTICE] 45m経過。成功判定 or バックアウトを選択してください。" ) &
```

---

## 💬 Slackアナウンステンプレ（コピペ用）

### Go宣言（T-15m）

```
:rocket: [GO] Day11 & Pricing 本番実行開始（JST）
- Scope: 過去48h
- 監査票: <link to _DAY11_AUDIT_*.md> / <link to _PRICING_AUDIT.md>
- On-call: 主要 <@user> / Backups <@user>
- バックアウト判定: T+45m
```

### 成功判定（T+≤45m）

```
:white_check_mark: 成功判定（p95予算内／不一致0／監査票4面OK）
- PRチェック全☑ → マージ
- 監査KPI: Slack成功率, p95, Checkout成功率, 不一致ゼロ連続日数
```

### バックアウト（T+45m）

```
:warning: Backout 実施
- 理由: <短く>
- 監査票: <link>
- 対応: 無効化マーキング + 復旧テンプレ実行
- 再実行目安: 48h後（是正完了後）
```

---

---

## 📌 最後の運用メモ（恒常化）

### 定期実行
- **毎週 月曜 09:05 JST** 自動実行（失敗でもArtifacts保存）

### 可視化の次ステップ（任意）
- `p95 latency / 成功率 / 不一致ゼロ連続日数` をダッシュボードにカード追加

### Secrets管理
- Slack/Stripe/Supabaseの更新日を `LAUNCH_CHECKLIST.md` 末尾に追記（ローテ計画）

---

**最終更新**: 2025-11-08  
**責任者**: Ops Team

