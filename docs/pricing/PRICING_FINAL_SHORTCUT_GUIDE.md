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

## 未成年/成人の推奨料金テーブル

| 区分 | プラン | 最小価格 | 推奨価格 | 上限価格 | 刻み | 根拠 |
| --- | --- | --- | --- | --- | --- | --- |
| **未成年（student）** | Light | 100円 | 100円 | 9,999円 | 10円 | 学生向け軽量プラン |
| | Standard | 100円 | 200円 | 9,999円 | 10円 | 学生向け標準プラン |
| | Premium | 100円 | 500円 | 9,999円 | 10円 | 学生向けプレミアムプラン |
| **成人（adult）** | Light | 300円 | 480円 | 29,999円 | 10円 | 成人向け軽量プラン |
| | Standard | 300円 | 1,980円 | 29,999円 | 10円 | 成人向け標準プラン |
| | Premium | 300円 | 4,980円 | 29,999円 | 10円 | 成人向けプレミアムプラン |

**根拠**:
- **未成年**: 保護者同意が必要なため、上限を9,999円に設定（`app_settings.pricing.recommendations.limits.student.max`）
- **成人**: より柔軟な価格設定を許可し、上限を29,999円に設定（`app_settings.pricing.recommendations.limits.adult.max`）
- **刻み**: 10円単位で統一（`app_settings.pricing.recommendations.limits.step`）

**参考**: `docs/pricing/RECOMMENDED_PRICING-001.md`, `supabase/migrations/20251108_app_settings_pricing.sql`

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

