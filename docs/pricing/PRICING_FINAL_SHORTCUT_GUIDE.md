---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# Pricing Final Shortcut Guide

## Overview

`PRICING_FINAL_SHORTCUT.sh` is an automated end-to-end validation script for the pricing recommendation feature.

## Usage

### Via npm script

```bash
npm run pricing:final
```

### Direct execution

```bash
chmod +x PRICING_FINAL_SHORTCUT.sh
./PRICING_FINAL_SHORTCUT.sh
```

## Prerequisites

### Required Environment Variables

- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_ANON_KEY` - Supabase anonymous key

### Optional Environment Variables

- `DATABASE_URL` - PostgreSQL connection string (for direct DB checks)
- `STRIPE_API_KEY` - Stripe API key (for Stripe CLI operations)

### Required Tools

- `bash` >= 5.0
- `stripe` CLI (optional, for Stripe validation)
- `psql` (optional, for direct DB checks)
- `flutter` (optional, for Flutter tests)

## Execution Flow

1. **Environment Check**
   - Validates `SUPABASE_URL` and `SUPABASE_ANON_KEY`
   - Checks for required tools

2. **Stripe CLI Validation**
   - Verifies Stripe CLI is installed and working
   - Skips if not available

3. **DB Validation**
   - Checks `subscriptions.plan_price` is integer (if `DATABASE_URL` available)
   - Falls back to Supabase Dashboard instructions if not available

4. **Flutter Tests**
   - Runs `flutter test --no-pub`
   - Skips if Flutter not available

5. **Webhook Validation**
   - Executes `PRICING_WEBHOOK_VALIDATION.sh` if present
   - Validates webhook secrets, deployment, and DB reflection

6. **Acceptance Tests**
   - Executes `PRICING_ACCEPTANCE_TEST.sh` if present
   - Runs unit and E2E test checklist

7. **Success Trail Confirmation**
   - Manual confirmation of 4 success criteria:
     - UI: Recommendation badge display, validation works
     - DB: `plan_price` saved as integer yen
     - Webhook: Events trigger and reflect `plan_price` updates
     - Logs: Supabase Functions return 200, no exceptions

8. **Go/No-Go Decision**
   - Final manual confirmation
   - Exit code 0 on Go, 1 on No-Go

## Exit Codes

- `0` - Success (all checks passed, Go decision)
- `1` - Failure (any check failed or No-Go decision)
- `11` - Missing required environment variable
- `12` - Missing required binary

## Error Handling

The script uses `set -euo pipefail` for strict error handling:
- `-e` - Exit immediately on error
- `-u` - Exit on undefined variable
- `-o pipefail` - Exit on pipe failure

## Summary Output

After successful execution, the script outputs:

```
📊 実行サマリ:
  ✅ Stripe CLI: Ready
  ✅ DB確認: plan_price integer check passed
  ✅ Flutter test: All tests passed
  ✅ Webhook検証: Passed
  ✅ 受け入れテスト: Passed

Exit code: 0 (Success)
```

## Troubleshooting

### Stripe CLI not found

Install Stripe CLI:
```bash
# macOS
brew install stripe/stripe-cli/stripe

# Linux
# See: https://stripe.com/docs/stripe-cli
```

### Flutter tests fail

Check Flutter test output:
```bash
flutter test --no-pub -v
```

### DB connection fails

Use Supabase Dashboard to verify:
1. Go to Supabase Dashboard > Database
2. Check `subscriptions` table
3. Verify `plan_price` column contains integers only

## 有料プラン価格仕様 v1（MVP）

| 区分 | プラン | 推奨価格 | 最小価格 | 最大価格 | 刻み | 備考 |
| --- | --- | --- | --- | --- | --- | --- |
| **未成年（student）** | Light | 100円 | 100円 | 300円 | 10円 | 保護者負担感を考慮し、上限は1,000円未満に抑制 |
| | Standard | 200円 | 300円 | 500円 | 10円 | 保護者同意のもと、安全な標準価格帯 |
| | Premium | 500円 | 500円 | 1,000円 | 10円 | プレミアムでも上限1,000円（保護者同意） |
| **成人（adult）** | Light | 980円 | 980円 | 30,000円 | 10円 | MVPでは最も柔軟なエントリープラン |
| | Standard | 1,980円 | 1,980円 | 50,000円 | 10円 | 人気プランの中心レンジ |
| | Premium | 2,980円 | 2,980円 | 100,000円 | 10円 | 特別体験を提供するハイエンドプラン |

価格はすべて税込表示とし、Flutter UI では各ティアの「おすすめ」バッジで推奨価格（上表の推奨価格列）を明示します。

## スーパーチャット（投げ銭）ティア v1

- ティア金額: 100円 / 500円 / 1,000円 / 2,000円 / 5,000円 / 10,000円 / 30,000円 / 50,000円 / 100,000円
- 上限: 100,000円（10万円）までをハード制約とし、それ以上の入力はバリデーションで拒否
- 各ティアは `super_chat_pricing` の `tier_x_threshold` に連動し、Tier 1〜9 でピン留め/表示時間/バッジなどの特典を切り替える
- 未成年スター向けには 1,000円以下のティアを推奨し、Super Chat 送金時に保護者同意表示を併設

この表は `docs/pricing/RECOMMENDED_PRICING-001.md` と Supabase `pricing.recommendations` 設定の `limits`/`tiers` と同期させること。

## 失敗時ロールバック手順

### 1コマンドロールバック

```bash
./scripts/pricing_rollback.sh <stripe_price_id>
```

**手順**:
1. Stripe Priceを非有効化（`stripe prices update <price_id> --active=false`）
2. 直前バージョンを有効化（Stripe DashboardまたはCLI）
3. ログに記録（`docs/reports/ROLLBACK_LOG_TEMPLATE.md`）

**所要時間**: 約3分以内

### 手動ロールバック

1. **Stripe Dashboard**: Products → Prices → 該当Priceを非有効化
2. **直前バージョン**: 履歴から直前バージョンを有効化
3. **DB確認**: `subscriptions.plan_price`が正しく保存されているか確認
4. **ログ記録**: `docs/reports/ROLLBACK_LOG_TEMPLATE.md`に記録

## 実行結果の1行要約

成功時:
```
✅ OK | sha256:abc123... | Stripe CLI: Ready | DB: plan_price integer OK | Flutter test: Passed | Webhook: Passed | Acceptance: Passed
```

失敗時:
```
❌ NG | sha256:def456... | Stripe CLI: Ready | DB: plan_price integer OK | Flutter test: Failed | Webhook: Passed | Acceptance: Failed
```

**署名ID**: `sha256:<hash>`（実行ログの整合性検証用）

## 料金関連の環境変数一覧

| 変数名 | 用途 | 設定場所 | 参照ドキュメント |
| --- | --- | --- | --- |
| `SUPABASE_URL` | SupabaseプロジェクトURL | `.envrc`, GitHub Secrets | `docs/COMPANY_SETUP_GUIDE.md` |
| `SUPABASE_ANON_KEY` | Supabase匿名キー | `.envrc`, GitHub Secrets | `docs/COMPANY_SETUP_GUIDE.md` |
| `DATABASE_URL` | PostgreSQL接続文字列（オプション） | `.envrc`, GitHub Secrets | `docs/COMPANY_SETUP_GUIDE.md` |
| `STRIPE_API_KEY` | Stripe APIキー（オプション） | `.envrc`, GitHub Secrets | `docs/COMPANY_SETUP_GUIDE.md` |
| `STRIPE_SECRET_KEY` | Stripe Secretキー（Webhook用） | Supabase Edge Function env | `docs/COMPANY_SETUP_GUIDE.md` |

**相互リンク**:
- `docs/COMPANY_SETUP_GUIDE.md` - Secrets運用SOP、権限マトリクス
- `docs/overview/STARLIST_OVERVIEW.md` - KPI表、ロードマップ表

## Related Files

- `PRICING_WEBHOOK_VALIDATION.sh` - Webhook validation script
- `PRICING_ACCEPTANCE_TEST.sh` - Acceptance test script
- `PRICING_FLUTTER_INTEGRATION.md` - Flutter integration guide
- `PRICING_TROUBLESHOOTING.md` - Troubleshooting guide
- `scripts/pricing_rollback.sh` - ロールバックスクリプト（新規）

---

**Last Updated**: 2025-11-08
**Maintainer**: SRE Team


## Overview

`PRICING_FINAL_SHORTCUT.sh` is an automated end-to-end validation script for the pricing recommendation feature.

## Usage

### Via npm script

```bash
npm run pricing:final
```

### Direct execution

```bash
chmod +x PRICING_FINAL_SHORTCUT.sh
./PRICING_FINAL_SHORTCUT.sh
```

## Prerequisites

### Required Environment Variables

- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_ANON_KEY` - Supabase anonymous key

### Optional Environment Variables

- `DATABASE_URL` - PostgreSQL connection string (for direct DB checks)
- `STRIPE_API_KEY` - Stripe API key (for Stripe CLI operations)

### Required Tools

- `bash` >= 5.0
- `stripe` CLI (optional, for Stripe validation)
- `psql` (optional, for direct DB checks)
- `flutter` (optional, for Flutter tests)

## Execution Flow

1. **Environment Check**
   - Validates `SUPABASE_URL` and `SUPABASE_ANON_KEY`
   - Checks for required tools

2. **Stripe CLI Validation**
   - Verifies Stripe CLI is installed and working
   - Skips if not available

3. **DB Validation**
   - Checks `subscriptions.plan_price` is integer (if `DATABASE_URL` available)
   - Falls back to Supabase Dashboard instructions if not available

4. **Flutter Tests**
   - Runs `flutter test --no-pub`
   - Skips if Flutter not available

5. **Webhook Validation**
   - Executes `PRICING_WEBHOOK_VALIDATION.sh` if present
   - Validates webhook secrets, deployment, and DB reflection

6. **Acceptance Tests**
   - Executes `PRICING_ACCEPTANCE_TEST.sh` if present
   - Runs unit and E2E test checklist

7. **Success Trail Confirmation**
   - Manual confirmation of 4 success criteria:
     - UI: Recommendation badge display, validation works
     - DB: `plan_price` saved as integer yen
     - Webhook: Events trigger and reflect `plan_price` updates
     - Logs: Supabase Functions return 200, no exceptions

8. **Go/No-Go Decision**
   - Final manual confirmation
   - Exit code 0 on Go, 1 on No-Go

## Exit Codes

- `0` - Success (all checks passed, Go decision)
- `1` - Failure (any check failed or No-Go decision)
- `11` - Missing required environment variable
- `12` - Missing required binary

## Error Handling

The script uses `set -euo pipefail` for strict error handling:
- `-e` - Exit immediately on error
- `-u` - Exit on undefined variable
- `-o pipefail` - Exit on pipe failure

## Summary Output

After successful execution, the script outputs:

```
📊 実行サマリ:
  ✅ Stripe CLI: Ready
  ✅ DB確認: plan_price integer check passed
  ✅ Flutter test: All tests passed
  ✅ Webhook検証: Passed
  ✅ 受け入れテスト: Passed

Exit code: 0 (Success)
```

## Troubleshooting

### Stripe CLI not found

Install Stripe CLI:
```bash
# macOS
brew install stripe/stripe-cli/stripe

# Linux
# See: https://stripe.com/docs/stripe-cli
```

### Flutter tests fail

Check Flutter test output:
```bash
flutter test --no-pub -v
```

### DB connection fails

Use Supabase Dashboard to verify:
1. Go to Supabase Dashboard > Database
2. Check `subscriptions` table
3. Verify `plan_price` column contains integers only

## 失敗時ロールバック手順

### 1コマンドロールバック

```bash
./scripts/pricing_rollback.sh <stripe_price_id>
```

**手順**:
1. Stripe Priceを非有効化（`stripe prices update <price_id> --active=false`）
2. 直前バージョンを有効化（Stripe DashboardまたはCLI）
3. ログに記録（`docs/reports/ROLLBACK_LOG_TEMPLATE.md`）

**所要時間**: 約3分以内

### 手動ロールバック

1. **Stripe Dashboard**: Products → Prices → 該当Priceを非有効化
2. **直前バージョン**: 履歴から直前バージョンを有効化
3. **DB確認**: `subscriptions.plan_price`が正しく保存されているか確認
4. **ログ記録**: `docs/reports/ROLLBACK_LOG_TEMPLATE.md`に記録

## 実行結果の1行要約

成功時:
```
✅ OK | sha256:abc123... | Stripe CLI: Ready | DB: plan_price integer OK | Flutter test: Passed | Webhook: Passed | Acceptance: Passed
```

失敗時:
```
❌ NG | sha256:def456... | Stripe CLI: Ready | DB: plan_price integer OK | Flutter test: Failed | Webhook: Passed | Acceptance: Failed
```

**署名ID**: `sha256:<hash>`（実行ログの整合性検証用）

## 料金関連の環境変数一覧

| 変数名 | 用途 | 設定場所 | 参照ドキュメント |
| --- | --- | --- | --- |
| `SUPABASE_URL` | SupabaseプロジェクトURL | `.envrc`, GitHub Secrets | `docs/COMPANY_SETUP_GUIDE.md` |
| `SUPABASE_ANON_KEY` | Supabase匿名キー | `.envrc`, GitHub Secrets | `docs/COMPANY_SETUP_GUIDE.md` |
| `DATABASE_URL` | PostgreSQL接続文字列（オプション） | `.envrc`, GitHub Secrets | `docs/COMPANY_SETUP_GUIDE.md` |
| `STRIPE_API_KEY` | Stripe APIキー（オプション） | `.envrc`, GitHub Secrets | `docs/COMPANY_SETUP_GUIDE.md` |
| `STRIPE_SECRET_KEY` | Stripe Secretキー（Webhook用） | Supabase Edge Function env | `docs/COMPANY_SETUP_GUIDE.md` |

**相互リンク**:
- `docs/COMPANY_SETUP_GUIDE.md` - Secrets運用SOP、権限マトリクス
- `docs/overview/STARLIST_OVERVIEW.md` - KPI表、ロードマップ表

## Related Files

- `PRICING_WEBHOOK_VALIDATION.sh` - Webhook validation script
- `PRICING_ACCEPTANCE_TEST.sh` - Acceptance test script
- `PRICING_FLUTTER_INTEGRATION.md` - Flutter integration guide
- `PRICING_TROUBLESHOOTING.md` - Troubleshooting guide
- `scripts/pricing_rollback.sh` - ロールバックスクリプト（新規）

---

**Last Updated**: 2025-11-08
**Maintainer**: SRE Team

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
