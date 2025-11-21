---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# 推奨価格機能 最終移行チェックリスト

## ✅ 最終移行チェック（DB & 関数）

### 1) マイグレーション実行（Supabase CLI 例）

```bash
supabase db push

# or

supabase db execute --file supabase/migrations/20251108_app_settings_pricing.sql
supabase db execute --file supabase/migrations/20251108_subscriptions_plan_price.sql
```

### 2) 仕上げ検証SQL（RLS・Seed・関数）

```sql
-- RLS有効
select relname, relrowsecurity from pg_class where relname='app_settings';

-- Seed確認
select value->'tiers' as tiers, value->'limits' as limits
from public.app_settings where key='pricing.recommendations';

-- 関数で取得
select public.get_app_setting('pricing.recommendations') as cfg;

-- subscriptionsにplan_priceがあるか
select column_name, data_type
from information_schema.columns
where table_schema='public' and table_name='subscriptions' and column_name in ('plan_price','currency');
```

---

## 💳 Stripe Webhook 仕上げ（Edge Function / TypeScript）

**ファイル**: `supabase/functions/stripe-webhook/index.ts`

**実装内容:**
- `checkout.session.completed`: 購入時の税込金額を保存
- `customer.subscription.updated`: 更新時の税込金額を保存
- `customer.subscription.created`: 作成時の税込金額を保存
- `invoice.payment_succeeded`: 請求成功時の税込金額を保存
- `charge.refunded`: 返金時の監査ログ（必要に応じて）

**要点:**
- **冪等性**: Stripe `event.id` を監査テーブルで `UNIQUE` にする設計が望ましい（多重送信対策）
- **金額の単位**: 円課金でも `amount_total` の基数が環境で異なる場合があるため、テストで**実値**を必ず確認
- **SRK使用**: Webhookはサーバー側書込みが必要なため **Service Role Key** を使用（安全なデプロイ先でのみ）

**Secrets設定:**
- `STRIPE_API_KEY`: Stripe APIキー
- `STRIPE_WEBHOOK_SECRET`: Stripe Webhookシークレット
- `SUPABASE_URL`: Supabase URL
- `SUPABASE_SERVICE_ROLE_KEY`: Supabase Service Role Key

---

## 🧩 Flutter 組込の最終ポイント（Lintsも同時に解消）

### 1) Repository 非同期取得のエラーハンドリング

- `catch (e, st)` でスタックトレースも取得
- フォールバック設定を返す
- ログ基盤への送信をTODOコメントで明記

### 2) Lint対策の即効箇所

- `prefer_const_constructors`: 定数Widgetには `const` を付与
- `prefer_final_fields` / `unnecessary_this`: State/クラス内の不変は `final`
- `avoid_print`: `print` をアプリ共通ロガーへ置換（TODOコメントで明記）
- `use_build_context_synchronously`: `await` 後の `context` 参照は `mounted` チェック
- `always_declare_return_types`: 型推論に頼らず戻り値型を明記
- `public_member_api_docs`: 公開APIに簡潔なdartdoc追加

---

## 🧪 受け入れテスト（CLI & Flutter）

### 1) CLI スモーク（DB/Config）

```bash
psql "$SUPABASE_DB_URL" -c "select value from public.app_settings where key='pricing.recommendations';"
```

### 2) Flutter ユニット（既存 `pricing_validator_test.dart` に追加済み）

- `price limits & step`: 下限/上限/刻みのバリデーションテスト
- `recommended value read`: 推奨価格の取得テスト

### 3) E2E（手動・画面）

- [ ] プランカードに**推奨価格バッジ**が出る
- [ ] 入力に応じて**即時バリデーション**
- [ ] Checkout完了 → DBの `subscriptions.plan_price` に**整数の円**で保存
- [ ] Config更新（Seed再実行）→ 推奨表示が**即反映**／既存購読の `plan_price` は**不変**

---

## 🧱 トラブル時の即応

| 症状 | 原因 | 対応 |
|------|------|------|
| Webhook 500 | SRK未設定／DB権限 | 関数のClient生成をSRKに変更、テーブル権限確認 |
| plan_priceがNULL | 金額単位変換ミス | `amount_total`/`unit_amount`の単位を実値確認、`/100`の有無を修正 |
| Config取得失敗 | RLS/関数未作成 | `get_app_setting` 存在、RLSでselect許可、Key一致を確認 |
| Lintが多発 | const/Logger/mounted | 上記Lint対策の4点を重点修正 |

---

## 🧭 次アクション（この順で完了）

1. **マイグレーション実行**（上のSQL確認を含む）
2. **Stripe Webhook** をデプロイ（SRK・秘密鍵確認）
3. **Flutter UI** を既存課金画面に結線（TierCard利用）
4. **受け入れテスト**（ユニット＋E2E）→ `plan_price` 保存を目視
5. **ドキュメント更新**：`RECOMMENDED_PRICING-001.md` に最終スクショとテスト結果を添付

---

## 📋 実行コマンド（まとめ）

```bash
# 1. マイグレーション実行
supabase db push

# 2. 検証SQL実行（Supabase Dashboard → SQL Editor）
# 上記の「仕上げ検証SQL」を実行

# 3. Stripe Webhookデプロイ
supabase functions deploy stripe-webhook

# 4. Secrets設定（Supabase Dashboard → Edge Functions → stripe-webhook → Settings → Secrets）
# STRIPE_API_KEY, STRIPE_WEBHOOK_SECRET, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY

# 5. Flutterテスト実行
flutter test test/src/features/pricing/

# 6. E2Eテスト（手動）
# アプリを起動して価格カードの表示とバリデーションを確認
```



## ✅ 最終移行チェック（DB & 関数）

### 1) マイグレーション実行（Supabase CLI 例）

```bash
supabase db push

# or

supabase db execute --file supabase/migrations/20251108_app_settings_pricing.sql
supabase db execute --file supabase/migrations/20251108_subscriptions_plan_price.sql
```

### 2) 仕上げ検証SQL（RLS・Seed・関数）

```sql
-- RLS有効
select relname, relrowsecurity from pg_class where relname='app_settings';

-- Seed確認
select value->'tiers' as tiers, value->'limits' as limits
from public.app_settings where key='pricing.recommendations';

-- 関数で取得
select public.get_app_setting('pricing.recommendations') as cfg;

-- subscriptionsにplan_priceがあるか
select column_name, data_type
from information_schema.columns
where table_schema='public' and table_name='subscriptions' and column_name in ('plan_price','currency');
```

---

## 💳 Stripe Webhook 仕上げ（Edge Function / TypeScript）

**ファイル**: `supabase/functions/stripe-webhook/index.ts`

**実装内容:**
- `checkout.session.completed`: 購入時の税込金額を保存
- `customer.subscription.updated`: 更新時の税込金額を保存
- `customer.subscription.created`: 作成時の税込金額を保存
- `invoice.payment_succeeded`: 請求成功時の税込金額を保存
- `charge.refunded`: 返金時の監査ログ（必要に応じて）

**要点:**
- **冪等性**: Stripe `event.id` を監査テーブルで `UNIQUE` にする設計が望ましい（多重送信対策）
- **金額の単位**: 円課金でも `amount_total` の基数が環境で異なる場合があるため、テストで**実値**を必ず確認
- **SRK使用**: Webhookはサーバー側書込みが必要なため **Service Role Key** を使用（安全なデプロイ先でのみ）

**Secrets設定:**
- `STRIPE_API_KEY`: Stripe APIキー
- `STRIPE_WEBHOOK_SECRET`: Stripe Webhookシークレット
- `SUPABASE_URL`: Supabase URL
- `SUPABASE_SERVICE_ROLE_KEY`: Supabase Service Role Key

---

## 🧩 Flutter 組込の最終ポイント（Lintsも同時に解消）

### 1) Repository 非同期取得のエラーハンドリング

- `catch (e, st)` でスタックトレースも取得
- フォールバック設定を返す
- ログ基盤への送信をTODOコメントで明記

### 2) Lint対策の即効箇所

- `prefer_const_constructors`: 定数Widgetには `const` を付与
- `prefer_final_fields` / `unnecessary_this`: State/クラス内の不変は `final`
- `avoid_print`: `print` をアプリ共通ロガーへ置換（TODOコメントで明記）
- `use_build_context_synchronously`: `await` 後の `context` 参照は `mounted` チェック
- `always_declare_return_types`: 型推論に頼らず戻り値型を明記
- `public_member_api_docs`: 公開APIに簡潔なdartdoc追加

---

## 🧪 受け入れテスト（CLI & Flutter）

### 1) CLI スモーク（DB/Config）

```bash
psql "$SUPABASE_DB_URL" -c "select value from public.app_settings where key='pricing.recommendations';"
```

### 2) Flutter ユニット（既存 `pricing_validator_test.dart` に追加済み）

- `price limits & step`: 下限/上限/刻みのバリデーションテスト
- `recommended value read`: 推奨価格の取得テスト

### 3) E2E（手動・画面）

- [ ] プランカードに**推奨価格バッジ**が出る
- [ ] 入力に応じて**即時バリデーション**
- [ ] Checkout完了 → DBの `subscriptions.plan_price` に**整数の円**で保存
- [ ] Config更新（Seed再実行）→ 推奨表示が**即反映**／既存購読の `plan_price` は**不変**

---

## 🧱 トラブル時の即応

| 症状 | 原因 | 対応 |
|------|------|------|
| Webhook 500 | SRK未設定／DB権限 | 関数のClient生成をSRKに変更、テーブル権限確認 |
| plan_priceがNULL | 金額単位変換ミス | `amount_total`/`unit_amount`の単位を実値確認、`/100`の有無を修正 |
| Config取得失敗 | RLS/関数未作成 | `get_app_setting` 存在、RLSでselect許可、Key一致を確認 |
| Lintが多発 | const/Logger/mounted | 上記Lint対策の4点を重点修正 |

---

## 🧭 次アクション（この順で完了）

1. **マイグレーション実行**（上のSQL確認を含む）
2. **Stripe Webhook** をデプロイ（SRK・秘密鍵確認）
3. **Flutter UI** を既存課金画面に結線（TierCard利用）
4. **受け入れテスト**（ユニット＋E2E）→ `plan_price` 保存を目視
5. **ドキュメント更新**：`RECOMMENDED_PRICING-001.md` に最終スクショとテスト結果を添付

---

## 📋 実行コマンド（まとめ）

```bash
# 1. マイグレーション実行
supabase db push

# 2. 検証SQL実行（Supabase Dashboard → SQL Editor）
# 上記の「仕上げ検証SQL」を実行

# 3. Stripe Webhookデプロイ
supabase functions deploy stripe-webhook

# 4. Secrets設定（Supabase Dashboard → Edge Functions → stripe-webhook → Settings → Secrets）
# STRIPE_API_KEY, STRIPE_WEBHOOK_SECRET, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY

# 5. Flutterテスト実行
flutter test test/src/features/pricing/

# 6. E2Eテスト（手動）
# アプリを起動して価格カードの表示とバリデーションを確認
```

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
