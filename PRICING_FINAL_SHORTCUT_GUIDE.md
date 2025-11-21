---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# 推奨価格機能 最終実務ショートカットガイド

## ✅ 実行サマリ（最短ルート）

```bash
# 0) 前提（置換）
export SUPABASE_URL="https://<project-ref>.supabase.co"
export SUPABASE_ANON_KEY="<anon-key>"

# 1) Webhook 実地検証（Secrets/Deploy/DB反映）
./PRICING_WEBHOOK_VALIDATION.sh

# 2) Flutter 統合確認（ドキュメント手順に沿って画面を確認）
#   - PRICING_FLUTTER_INTEGRATION.md を参照

# 3) 受け入れテスト（ユニット + E2E チェックリスト）
./PRICING_ACCEPTANCE_TEST.sh

# 4) 一発実行（上記①〜③を連結、Go/No-Go 判定まで）
./PRICING_FINAL_SHORTCUT.sh
```

---

## 🔎 成功トレイル（必ず満たす3+1）

1. **UI**：推奨バッジ表示／刻み・上下限バリデーションが即時に効く（不正値はCTA無効）

2. **Checkout→DB**：成功後 `subscriptions.plan_price` が**整数の円**で保存

3. **Webhook**：`checkout.* / subscription.* / invoice.*` がトリガーされ、**plan_price更新**が反映

4. **ログ**：Supabase Functions **200**、例外なし／再送痕跡なし（必要に応じ監査記録もOK）

---

## 🧪 スポット確認（現場で役立つ一行集）

### Stripe CLI（本番エンドポイントにフォワードして擬似イベント送出）

```bash
stripe listen --forward-to "$SUPABASE_URL/functions/v1/stripe-webhook"

stripe trigger checkout.session.completed

stripe trigger customer.subscription.updated

stripe trigger invoice.payment_succeeded
```

### DB 反映（直近の金額が入っているか）

```sql
select subscription_id, plan_price, currency, updated_at
from public.subscriptions
order by updated_at desc
limit 5;
```

### Flutter ユニット（バリデーション）

```bash
flutter test test/src/features/pricing/
```

### 一括実行

```bash
./PRICING_SPOT_COMMANDS.sh [command]
```

利用可能なコマンド:
- `stripe-cli`, `stripe` - Stripe CLI テストコマンド表示
- `db-check`, `db` - DB反映確認SQL表示
- `flutter-test`, `test` - Flutterユニットテスト実行
- `all` - すべてのコマンドを表示（デフォルト）

---

## 🧯 つまずき時の即応（最短復旧メモ）

| 症状 | 原因 | 対処 |
|------|------|------|
| **Webhook 400** | `STRIPE_WEBHOOK_SECRET` 不一致 | Stripe CLIの `whsec_...` を再設定<br>`supabase functions secrets set STRIPE_WEBHOOK_SECRET="<whsec_...>"` |
| **Webhook 500** | `SUPABASE_SERVICE_ROLE_KEY` 未設定 | Functions Secrets に SRK を登録<br>`supabase functions secrets set SUPABASE_SERVICE_ROLE_KEY="<key>"` |
| **plan_price が NULL** | 金額単位の変換誤り | `amount_total` / `unit_amount` の基数をダッシュボードで確認し `/100` の要否を調整 |
| **価格入力が通る** | UI側で `validatePrice` 未結線 | CTA活性/非活性の制御を導入 |
| **推奨が変わらない** | `app_settings` キャッシュ／再フェッチ漏れ | `get_app_setting` 再取得を実装<br>`ref.invalidate(pricingConfigProvider)` |

詳細は `PRICING_TROUBLESHOOTING.md` を参照してください。

---

## 🏁 Go/No-Go（判定用ひな型）

- ✅ UI：推奨表示・刻み/上下限ガードOK
- ✅ DB：`plan_price` 保存（整数円）OK
- ✅ Webhook：対象イベントすべて反映OK
- ✅ Logs：Functions 200、例外・再送なし（必要に応じ監査テーブルに記録）

---

## 📋 実行フロー全体像

```
1. Webhook 実地検証（PRICING_WEBHOOK_VALIDATION.sh）
   ├─ Secrets確認
   ├─ Edge Functionデプロイ確認
   ├─ Stripe CLIテスト（オプション）
   └─ DB反映確認

2. Flutter 統合確認（PRICING_FLUTTER_INTEGRATION.md）
   ├─ Provider取得 → 画面結線
   ├─ 推奨バッジ表示
   ├─ 刻み・上下限バリデーション
   └─ 不正値はCTA無効

3. 受け入れテスト（PRICING_ACCEPTANCE_TEST.sh）
   ├─ ユニットテスト（バリデーション）
   ├─ E2E手動チェックリスト
   ├─ ログ/監査確認
   └─ Go/No-Go判定

4. 最終実務ショートカット（PRICING_FINAL_SHORTCUT.sh）
   ├─ 上記①〜③を連結
   ├─ 成功トレイル確認（3+1）
   └─ Go/No-Go最終判定
```

---

## 📝 実行後の確認事項

1. **Stripeイベントのログ**（`type` と保存後の `subscriptions` レコード）を確認
2. **画面スクショ**を取得
3. **最終レポート**（`PRICING_FINAL_CHECKLIST.md` 反映版）を整形

---

成果（SlackメッセージURL・Webhookイベント種別と保存後レコード・画面スクショ）が揃いましたらお送りください。すぐに**最終レポート（PRICING_FINAL_CHECKLIST.md 反映版）**の体裁まで整えてご提出いたします。



## ✅ 実行サマリ（最短ルート）

```bash
# 0) 前提（置換）
export SUPABASE_URL="https://<project-ref>.supabase.co"
export SUPABASE_ANON_KEY="<anon-key>"

# 1) Webhook 実地検証（Secrets/Deploy/DB反映）
./PRICING_WEBHOOK_VALIDATION.sh

# 2) Flutter 統合確認（ドキュメント手順に沿って画面を確認）
#   - PRICING_FLUTTER_INTEGRATION.md を参照

# 3) 受け入れテスト（ユニット + E2E チェックリスト）
./PRICING_ACCEPTANCE_TEST.sh

# 4) 一発実行（上記①〜③を連結、Go/No-Go 判定まで）
./PRICING_FINAL_SHORTCUT.sh
```

---

## 🔎 成功トレイル（必ず満たす3+1）

1. **UI**：推奨バッジ表示／刻み・上下限バリデーションが即時に効く（不正値はCTA無効）

2. **Checkout→DB**：成功後 `subscriptions.plan_price` が**整数の円**で保存

3. **Webhook**：`checkout.* / subscription.* / invoice.*` がトリガーされ、**plan_price更新**が反映

4. **ログ**：Supabase Functions **200**、例外なし／再送痕跡なし（必要に応じ監査記録もOK）

---

## 🧪 スポット確認（現場で役立つ一行集）

### Stripe CLI（本番エンドポイントにフォワードして擬似イベント送出）

```bash
stripe listen --forward-to "$SUPABASE_URL/functions/v1/stripe-webhook"

stripe trigger checkout.session.completed

stripe trigger customer.subscription.updated

stripe trigger invoice.payment_succeeded
```

### DB 反映（直近の金額が入っているか）

```sql
select subscription_id, plan_price, currency, updated_at
from public.subscriptions
order by updated_at desc
limit 5;
```

### Flutter ユニット（バリデーション）

```bash
flutter test test/src/features/pricing/
```

### 一括実行

```bash
./PRICING_SPOT_COMMANDS.sh [command]
```

利用可能なコマンド:
- `stripe-cli`, `stripe` - Stripe CLI テストコマンド表示
- `db-check`, `db` - DB反映確認SQL表示
- `flutter-test`, `test` - Flutterユニットテスト実行
- `all` - すべてのコマンドを表示（デフォルト）

---

## 🧯 つまずき時の即応（最短復旧メモ）

| 症状 | 原因 | 対処 |
|------|------|------|
| **Webhook 400** | `STRIPE_WEBHOOK_SECRET` 不一致 | Stripe CLIの `whsec_...` を再設定<br>`supabase functions secrets set STRIPE_WEBHOOK_SECRET="<whsec_...>"` |
| **Webhook 500** | `SUPABASE_SERVICE_ROLE_KEY` 未設定 | Functions Secrets に SRK を登録<br>`supabase functions secrets set SUPABASE_SERVICE_ROLE_KEY="<key>"` |
| **plan_price が NULL** | 金額単位の変換誤り | `amount_total` / `unit_amount` の基数をダッシュボードで確認し `/100` の要否を調整 |
| **価格入力が通る** | UI側で `validatePrice` 未結線 | CTA活性/非活性の制御を導入 |
| **推奨が変わらない** | `app_settings` キャッシュ／再フェッチ漏れ | `get_app_setting` 再取得を実装<br>`ref.invalidate(pricingConfigProvider)` |

詳細は `PRICING_TROUBLESHOOTING.md` を参照してください。

---

## 🏁 Go/No-Go（判定用ひな型）

- ✅ UI：推奨表示・刻み/上下限ガードOK
- ✅ DB：`plan_price` 保存（整数円）OK
- ✅ Webhook：対象イベントすべて反映OK
- ✅ Logs：Functions 200、例外・再送なし（必要に応じ監査テーブルに記録）

---

## 📋 実行フロー全体像

```
1. Webhook 実地検証（PRICING_WEBHOOK_VALIDATION.sh）
   ├─ Secrets確認
   ├─ Edge Functionデプロイ確認
   ├─ Stripe CLIテスト（オプション）
   └─ DB反映確認

2. Flutter 統合確認（PRICING_FLUTTER_INTEGRATION.md）
   ├─ Provider取得 → 画面結線
   ├─ 推奨バッジ表示
   ├─ 刻み・上下限バリデーション
   └─ 不正値はCTA無効

3. 受け入れテスト（PRICING_ACCEPTANCE_TEST.sh）
   ├─ ユニットテスト（バリデーション）
   ├─ E2E手動チェックリスト
   ├─ ログ/監査確認
   └─ Go/No-Go判定

4. 最終実務ショートカット（PRICING_FINAL_SHORTCUT.sh）
   ├─ 上記①〜③を連結
   ├─ 成功トレイル確認（3+1）
   └─ Go/No-Go最終判定
```

---

## 📝 実行後の確認事項

1. **Stripeイベントのログ**（`type` と保存後の `subscriptions` レコード）を確認
2. **画面スクショ**を取得
3. **最終レポート**（`PRICING_FINAL_CHECKLIST.md` 反映版）を整形

---

成果（SlackメッセージURL・Webhookイベント種別と保存後レコード・画面スクショ）が揃いましたらお送りください。すぐに**最終レポート（PRICING_FINAL_CHECKLIST.md 反映版）**の体裁まで整えてご提出いたします。

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
