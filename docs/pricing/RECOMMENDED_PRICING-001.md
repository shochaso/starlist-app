Status:: in-progress
Source-of-Truth:: docs/pricing/RECOMMENDED_PRICING-001.md
Spec-State:: 確定済み（推奨価格機能）
Last-Updated:: 2025-11-08

# 推奨価格機能（Recommended Pricing）

## 概要

ユーザーがサブスクリプションを購入する際に、プランごとの推奨価格を表示し、カスタム価格入力時のバリデーションを提供する機能。

---

## 目的

1. **推奨価格の表示**: 各プラン（Light/Standard/Premium）に対して、学生/成人別の推奨価格を表示
2. **価格バリデーション**: 入力された価格が下限/上限/刻みの制約を満たしているか検証
3. **価格履歴の保持**: 購入時の税込価格を `subscriptions.plan_price` に保存（価格改定時も当時の金額を保持）

---

## システム構成

| レイヤ | コンポーネント | 役割 |
|--------|----------------|------|
| **DB** | `app_settings` テーブル | 推奨価格設定を保存（`pricing.recommendations`） |
| **DB** | `get_app_setting()` 関数 | 設定値を取得するヘルパー関数 |
| **DB** | `subscriptions.plan_price` カラム | 購入時の税込価格を保持 |
| **Flutter** | `pricing_repository.dart` | Supabaseから設定を取得 |
| **Flutter** | `pricing_validator.dart` | 価格バリデーションロジック |
| **Flutter** | `pricing_cards.dart` | 価格カードUI（推奨バッジ付き） |
| **Stripe** | Webhook | 購入時の税込価格を `plan_price` に保存 |

---

## DBスキーマ

### `app_settings` テーブル

```sql
create table if not exists public.app_settings (
  key text primary key,
  value jsonb not null,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
```

**RLSポリシー:**
- `app_settings_select_all`: 全ユーザーが閲覧可能
- 書込みはサービスロールのみ（匿名/認証ユーザーは禁止）

### `pricing.recommendations` 設定値

```json
{
  "version": "2025-11-08",
  "tiers": {
    "light": {"student": 100, "adult": 480},
    "standard": {"student": 200, "adult": 1980},
    "premium": {"student": 500, "adult": 4980}
  },
  "limits": {
    "student": {"min": 100, "max": 9999},
    "adult": {"min": 300, "max": 29999},
    "step": 10,
    "currency": "JPY",
    "tax_inclusive": true
  }
}
```

### `subscriptions.plan_price` カラム

```sql
alter table public.subscriptions
  add column if not exists plan_price integer,        -- 税込JPY（円）
  add column if not exists currency   text default 'JPY';
```

---

## Flutter実装

### 1. 設定取得（`pricing_repository.dart`）

```dart
final pricingConfigProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final supabase = Supabase.instance.client;
  final res = await supabase.rpc('get_app_setting', params: {'p_key': 'pricing.recommendations'});
  // フォールバック処理含む
});
```

### 2. バリデーション（`pricing_validator.dart`）

- `validatePrice()`: 価格が下限/上限/刻みの制約を満たしているか検証
- `limitsFromConfig()`: 設定から学生/成人の制限を取得
- `recommendedFor()`: 推奨額を取得

### 3. UI（`pricing_cards.dart`）

- `TierCard`: プランごとの価格カード
- 推奨バッジ表示
- リアルタイムバリデーション
- エラーメッセージ表示

---

## Stripe Webhook統合

### 実装方針

**イベント:**
- `checkout.session.completed`
- `customer.subscription.updated`

**処理:**
1. `event.data.object.amount_total` から当時の税込金額を取得
2. Stripe金額が最小通貨単位（¢）の場合は `/100` して整数の円に変換
3. `subscriptions.plan_price` に保存

**注意:**
- 価格改定時も、既存購読の `plan_price` は不変（当時の金額を保持）
- 更新後の請求に合わせて `plan_price` を更新する場合は、履歴テーブルまたは監査ログに記録

---

## 受け入れ基準（DoD）

- [ ] UI表示: 各ティアに学生/成人の推奨額が表示される（Config値に一致）
- [ ] バリデーション: `min` 未満／`max` 超過／`step` 不整合でエラー表示
- [ ] Checkout成功: `subscriptions.plan_price` に当時の税込円が保存される
- [ ] Config更新: 推奨額を更新しても、既存購読の `plan_price` は不変
- [ ] 学生/成人切替: 推奨表示が切替に追随（UIの文言崩れなし）

---

## 運用ヒント

### 推奨価格の更新

```sql
-- app_settings の1レコード更新で全体に即反映
update public.app_settings
set value = jsonb_build_object(
  'version', '2025-11-15',
  'tiers', jsonb_build_object(
    'light', jsonb_build_object('student', 120, 'adult', 580),
    -- ...
  ),
  'limits', jsonb_build_object(
    -- ...
  )
),
updated_at = now()
where key = 'pricing.recommendations';
```

### バージョン管理

- 大規模変更は `version` を上げる
- クライアント側のテレメトリで「どの版の推奨で購入されたか」を把握可能

### FAQ対応

- 返金・価格改定のFAQは特商法ページとヘルプに**定型文**でリンク

---

## 更新履歴

| 日付 | 更新者 | 変更概要 |
|------|--------|----------|
| 2025-11-08 | Tim | 推奨価格機能仕様作成 |


Source-of-Truth:: docs/pricing/RECOMMENDED_PRICING-001.md
Spec-State:: 確定済み（推奨価格機能）
Last-Updated:: 2025-11-08

# 推奨価格機能（Recommended Pricing）

## 概要

ユーザーがサブスクリプションを購入する際に、プランごとの推奨価格を表示し、カスタム価格入力時のバリデーションを提供する機能。

---

## 目的

1. **推奨価格の表示**: 各プラン（Light/Standard/Premium）に対して、学生/成人別の推奨価格を表示
2. **価格バリデーション**: 入力された価格が下限/上限/刻みの制約を満たしているか検証
3. **価格履歴の保持**: 購入時の税込価格を `subscriptions.plan_price` に保存（価格改定時も当時の金額を保持）

---

## システム構成

| レイヤ | コンポーネント | 役割 |
|--------|----------------|------|
| **DB** | `app_settings` テーブル | 推奨価格設定を保存（`pricing.recommendations`） |
| **DB** | `get_app_setting()` 関数 | 設定値を取得するヘルパー関数 |
| **DB** | `subscriptions.plan_price` カラム | 購入時の税込価格を保持 |
| **Flutter** | `pricing_repository.dart` | Supabaseから設定を取得 |
| **Flutter** | `pricing_validator.dart` | 価格バリデーションロジック |
| **Flutter** | `pricing_cards.dart` | 価格カードUI（推奨バッジ付き） |
| **Stripe** | Webhook | 購入時の税込価格を `plan_price` に保存 |

---

## DBスキーマ

### `app_settings` テーブル

```sql
create table if not exists public.app_settings (
  key text primary key,
  value jsonb not null,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
```

**RLSポリシー:**
- `app_settings_select_all`: 全ユーザーが閲覧可能
- 書込みはサービスロールのみ（匿名/認証ユーザーは禁止）

### `pricing.recommendations` 設定値

```json
{
  "version": "2025-11-08",
  "tiers": {
    "light": {"student": 100, "adult": 480},
    "standard": {"student": 200, "adult": 1980},
    "premium": {"student": 500, "adult": 4980}
  },
  "limits": {
    "student": {"min": 100, "max": 9999},
    "adult": {"min": 300, "max": 29999},
    "step": 10,
    "currency": "JPY",
    "tax_inclusive": true
  }
}
```

### `subscriptions.plan_price` カラム

```sql
alter table public.subscriptions
  add column if not exists plan_price integer,        -- 税込JPY（円）
  add column if not exists currency   text default 'JPY';
```

---

## Flutter実装

### 1. 設定取得（`pricing_repository.dart`）

```dart
final pricingConfigProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final supabase = Supabase.instance.client;
  final res = await supabase.rpc('get_app_setting', params: {'p_key': 'pricing.recommendations'});
  // フォールバック処理含む
});
```

### 2. バリデーション（`pricing_validator.dart`）

- `validatePrice()`: 価格が下限/上限/刻みの制約を満たしているか検証
- `limitsFromConfig()`: 設定から学生/成人の制限を取得
- `recommendedFor()`: 推奨額を取得

### 3. UI（`pricing_cards.dart`）

- `TierCard`: プランごとの価格カード
- 推奨バッジ表示
- リアルタイムバリデーション
- エラーメッセージ表示

---

## Stripe Webhook統合

### 実装方針

**イベント:**
- `checkout.session.completed`
- `customer.subscription.updated`

**処理:**
1. `event.data.object.amount_total` から当時の税込金額を取得
2. Stripe金額が最小通貨単位（¢）の場合は `/100` して整数の円に変換
3. `subscriptions.plan_price` に保存

**注意:**
- 価格改定時も、既存購読の `plan_price` は不変（当時の金額を保持）
- 更新後の請求に合わせて `plan_price` を更新する場合は、履歴テーブルまたは監査ログに記録

---

## 受け入れ基準（DoD）

- [ ] UI表示: 各ティアに学生/成人の推奨額が表示される（Config値に一致）
- [ ] バリデーション: `min` 未満／`max` 超過／`step` 不整合でエラー表示
- [ ] Checkout成功: `subscriptions.plan_price` に当時の税込円が保存される
- [ ] Config更新: 推奨額を更新しても、既存購読の `plan_price` は不変
- [ ] 学生/成人切替: 推奨表示が切替に追随（UIの文言崩れなし）

---

## 運用ヒント

### 推奨価格の更新

```sql
-- app_settings の1レコード更新で全体に即反映
update public.app_settings
set value = jsonb_build_object(
  'version', '2025-11-15',
  'tiers', jsonb_build_object(
    'light', jsonb_build_object('student', 120, 'adult', 580),
    -- ...
  ),
  'limits', jsonb_build_object(
    -- ...
  )
),
updated_at = now()
where key = 'pricing.recommendations';
```

### バージョン管理

- 大規模変更は `version` を上げる
- クライアント側のテレメトリで「どの版の推奨で購入されたか」を把握可能

### FAQ対応

- 返金・価格改定のFAQは特商法ページとヘルプに**定型文**でリンク

---

## 更新履歴

| 日付 | 更新者 | 変更概要 |
|------|--------|----------|
| 2025-11-08 | Tim | 推奨価格機能仕様作成 |


