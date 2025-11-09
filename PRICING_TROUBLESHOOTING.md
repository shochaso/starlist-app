# トラブル時の最短復旧

## 症状別対処表

| 症状 | 典型原因 | 対処 |
|------|---------|------|
| **Webhook 400** | `STRIPE_WEBHOOK_SECRET` 不一致 | Stripe CLIの `whsec_...` を再セット<br>`supabase functions secrets set STRIPE_WEBHOOK_SECRET="<whsec_...>"` |
| **Webhook 500** | SRK未設定／DB権限 | `SUPABASE_SERVICE_ROLE_KEY` をSecretsに設定<br>`supabase functions secrets set SUPABASE_SERVICE_ROLE_KEY="<key>"` |
| **plan_price が NULL** | 金額単位変換ミス | `amount_total`/`unit_amount` の基数を確認<br>日本円の場合、`/100` の要否を調整（`asYen`関数を修正） |
| **価格入力が通る** | バリデーション未結線 | `validatePrice` の結果でCTA活性/非活性を制御<br>`onChanged` で即座にバリデーション実行 |
| **推奨が変わらない** | Config未更新/キャッシュ | `get_app_setting` の再取得フロー（再フェッチ）を実装<br>`ref.invalidate(pricingConfigProvider)` でキャッシュクリア |

## 詳細対処手順

### Webhook 400: STRIPE_WEBHOOK_SECRET 不一致

```bash
# 1. Stripe CLIでWebhookシークレットを取得
stripe listen --print-secret

# 2. Supabase Functions Secretsに設定
supabase functions secrets set STRIPE_WEBHOOK_SECRET="whsec_..."

# 3. Edge Functionを再デプロイ
supabase functions deploy stripe-webhook

# 4. テストイベントを再送信
stripe trigger checkout.session.completed
```

### Webhook 500: SRK未設定／DB権限

```bash
# 1. Supabase Dashboard → Project Settings → API → Service Role Key を取得

# 2. Supabase Functions Secretsに設定
supabase functions secrets set SUPABASE_SERVICE_ROLE_KEY="<service_role_key>"

# 3. subscriptionsテーブルの権限確認
# Supabase Dashboard → SQL Editor で以下を実行:
# GRANT UPDATE ON public.subscriptions TO service_role;

# 4. Edge Functionを再デプロイ
supabase functions deploy stripe-webhook
```

### plan_price が NULL: 金額単位変換ミス

```typescript
// supabase/functions/stripe-webhook/index.ts の asYen 関数を確認

// 日本円の場合、Stripeの amount_total がそのまま円の場合もある
// テストで実値を確認してから調整

const asYen = (amount?: number | null): number => {
  if (amount == null) return 0;
  // 実値確認が必要:
  // - テストイベントで amount_total の値を確認
  // - 100で割る必要があるかどうかを判断
  // デフォルトはcent単位と仮定して/100
  return Math.round(amount / 100);
};
```

**確認方法:**
1. Stripe Dashboard → Events → テストイベントを確認
2. `amount_total` の値を確認（例: 4800 = 48円なら /100、4800 = 4800円ならそのまま）
3. `asYen` 関数を修正

### 価格入力が通る: バリデーション未結線

```dart
// TierCard の onChanged で即座にバリデーション

TextField(
  controller: _controller,
  keyboardType: TextInputType.number,
  decoration: InputDecoration(
    prefixText: '¥',
    hintText: '金額を入力',
    errorText: _errorMessage, // エラーメッセージを表示
  ),
  onChanged: (s) {
    final v = int.tryParse(s) ?? 0;
    final msg = validatePrice(value: v, limits: limits);
    setState(() {
      _errorMessage = msg; // エラーメッセージを状態に反映
    });
    if (msg == null) {
      onChanged(v); // 有効な場合のみコールバック実行
    }
  },
)
```

### 推奨が変わらない: Config未更新/キャッシュ

```dart
// 1. Providerのキャッシュをクリア
ref.invalidate(pricingConfigProvider);

// 2. 再取得をトリガー
ref.refresh(pricingConfigProvider);

// 3. Seedデータを再適用（Supabase Dashboard → SQL Editor）
-- supabase/migrations/20251108_app_settings_pricing.sql の INSERT文を再実行
```

## 監査テーブル（任意・参考）

```sql
-- 監査テーブル例（冪等性担保）
create table if not exists public.audit_payments(
  event_id text primary key,
  type text not null,
  payload jsonb not null,
  created_at timestamptz default now()
);

-- Edge Functionで使用（stripe-webhook/index.ts）
const { error } = await supabase
  .from('audit_payments')
  .insert({
    event_id: evt.id,
    type: evt.type,
    payload: evt.data.object,
  })
  .select()
  .single();

if (error && error.code === '23505') {
  // UNIQUE制約違反 = 既に処理済み
  console.log(`[stripe-webhook] Event ${evt.id} already processed`);
  return new Response(
    JSON.stringify({ ok: true, skipped: true }),
    { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
  );
}
```



## 症状別対処表

| 症状 | 典型原因 | 対処 |
|------|---------|------|
| **Webhook 400** | `STRIPE_WEBHOOK_SECRET` 不一致 | Stripe CLIの `whsec_...` を再セット<br>`supabase functions secrets set STRIPE_WEBHOOK_SECRET="<whsec_...>"` |
| **Webhook 500** | SRK未設定／DB権限 | `SUPABASE_SERVICE_ROLE_KEY` をSecretsに設定<br>`supabase functions secrets set SUPABASE_SERVICE_ROLE_KEY="<key>"` |
| **plan_price が NULL** | 金額単位変換ミス | `amount_total`/`unit_amount` の基数を確認<br>日本円の場合、`/100` の要否を調整（`asYen`関数を修正） |
| **価格入力が通る** | バリデーション未結線 | `validatePrice` の結果でCTA活性/非活性を制御<br>`onChanged` で即座にバリデーション実行 |
| **推奨が変わらない** | Config未更新/キャッシュ | `get_app_setting` の再取得フロー（再フェッチ）を実装<br>`ref.invalidate(pricingConfigProvider)` でキャッシュクリア |

## 詳細対処手順

### Webhook 400: STRIPE_WEBHOOK_SECRET 不一致

```bash
# 1. Stripe CLIでWebhookシークレットを取得
stripe listen --print-secret

# 2. Supabase Functions Secretsに設定
supabase functions secrets set STRIPE_WEBHOOK_SECRET="whsec_..."

# 3. Edge Functionを再デプロイ
supabase functions deploy stripe-webhook

# 4. テストイベントを再送信
stripe trigger checkout.session.completed
```

### Webhook 500: SRK未設定／DB権限

```bash
# 1. Supabase Dashboard → Project Settings → API → Service Role Key を取得

# 2. Supabase Functions Secretsに設定
supabase functions secrets set SUPABASE_SERVICE_ROLE_KEY="<service_role_key>"

# 3. subscriptionsテーブルの権限確認
# Supabase Dashboard → SQL Editor で以下を実行:
# GRANT UPDATE ON public.subscriptions TO service_role;

# 4. Edge Functionを再デプロイ
supabase functions deploy stripe-webhook
```

### plan_price が NULL: 金額単位変換ミス

```typescript
// supabase/functions/stripe-webhook/index.ts の asYen 関数を確認

// 日本円の場合、Stripeの amount_total がそのまま円の場合もある
// テストで実値を確認してから調整

const asYen = (amount?: number | null): number => {
  if (amount == null) return 0;
  // 実値確認が必要:
  // - テストイベントで amount_total の値を確認
  // - 100で割る必要があるかどうかを判断
  // デフォルトはcent単位と仮定して/100
  return Math.round(amount / 100);
};
```

**確認方法:**
1. Stripe Dashboard → Events → テストイベントを確認
2. `amount_total` の値を確認（例: 4800 = 48円なら /100、4800 = 4800円ならそのまま）
3. `asYen` 関数を修正

### 価格入力が通る: バリデーション未結線

```dart
// TierCard の onChanged で即座にバリデーション

TextField(
  controller: _controller,
  keyboardType: TextInputType.number,
  decoration: InputDecoration(
    prefixText: '¥',
    hintText: '金額を入力',
    errorText: _errorMessage, // エラーメッセージを表示
  ),
  onChanged: (s) {
    final v = int.tryParse(s) ?? 0;
    final msg = validatePrice(value: v, limits: limits);
    setState(() {
      _errorMessage = msg; // エラーメッセージを状態に反映
    });
    if (msg == null) {
      onChanged(v); // 有効な場合のみコールバック実行
    }
  },
)
```

### 推奨が変わらない: Config未更新/キャッシュ

```dart
// 1. Providerのキャッシュをクリア
ref.invalidate(pricingConfigProvider);

// 2. 再取得をトリガー
ref.refresh(pricingConfigProvider);

// 3. Seedデータを再適用（Supabase Dashboard → SQL Editor）
-- supabase/migrations/20251108_app_settings_pricing.sql の INSERT文を再実行
```

## 監査テーブル（任意・参考）

```sql
-- 監査テーブル例（冪等性担保）
create table if not exists public.audit_payments(
  event_id text primary key,
  type text not null,
  payload jsonb not null,
  created_at timestamptz default now()
);

-- Edge Functionで使用（stripe-webhook/index.ts）
const { error } = await supabase
  .from('audit_payments')
  .insert({
    event_id: evt.id,
    type: evt.type,
    payload: evt.data.object,
  })
  .select()
  .single();

if (error && error.code === '23505') {
  // UNIQUE制約違反 = 既に処理済み
  console.log(`[stripe-webhook] Event ${evt.id} already processed`);
  return new Response(
    JSON.stringify({ ok: true, skipped: true }),
    { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
  );
}
```


