---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# リカバリ即応ガイド（現場メモ）

> **クイックリファレンス**: [LAUNCH_CHECKLIST.md](./LAUNCH_CHECKLIST.md) も参照してください。

## Exit Code別リカバリ手順

### Exit 21: Permalink未取得

**症状**: Slack Webhookの429/5xx、Permalinkが取得できない

**対処**:
1. Slack Webhookの429/5xxを確認
2. Slack側のURL/Secretを再設定
3. 数分後再実行

**確認コマンド**:
```bash
# Slack Webhook URL確認
echo $SLACK_WEBHOOK_OPS_SUMMARY

# 直近のsend.json確認
jq '.[-1] | {ok, status, error}' logs/day11/*_send.json | tail -n1
```

---

### Exit 22: Stripe 0件

**症状**: Stripeイベントが抽出されない

**対処**:
1. `HOURS=72` へ一時延長
2. `STRIPE_API_KEY` のスコープ確認（Read権限不足が多発）

**確認コマンド**:
```bash
# Stripe API Key確認
stripe events list --limit 10

# イベント抽出確認
jq 'length' tmp/audit_stripe/events_starlist.json
```

---

### Exit 23: send空

**症状**: Day11 sendが空、実行失敗

**対処**:
1. `logs/day11/*_send.json` のHTTP/JSON整合を確認
2. `ops-slack-summary` の直近ログ末尾を再チェック

**確認コマンド**:
```bash
# send.json確認
jq '.[-1]' logs/day11/*_send.json

# Edge Functionログ確認
supabase functions logs --function-name ops-slack-summary --since 2h | tail -n 50
```

---

## 情報漏えい懸念時の対処

**症状**: 監査票に機微情報が含まれている可能性

**対処**:
```bash
# レダクション再適用
make redact && ./FINAL_INTEGRATION_SUITE.sh --audit-only
```

**確認コマンド**:
```bash
# レダクション自己診断
printf 'a@b.com 090-1234-5678 4242424242424242\n' | scripts/utils/redact.sh
```

---

## よくある詰まりへの即応メモ

### Stripe 0件
- `HOURS=72` へ一時増量
- `STRIPE_API_KEY` スコープ確認

### Permalink未取得
- Webhook 429/5xxを確認
- Slack側のURL/Secretを再設定
- 数分後再実行

### DB監査0出力
- `supabase login`を実行
- `SUPABASE_ACCESS_TOKEN`の権限確認（read-onlyで可）

---

**最終更新**: 2025-11-08  
**責任者**: Ops Team


> **クイックリファレンス**: [LAUNCH_CHECKLIST.md](./LAUNCH_CHECKLIST.md) も参照してください。

## Exit Code別リカバリ手順

### Exit 21: Permalink未取得

**症状**: Slack Webhookの429/5xx、Permalinkが取得できない

**対処**:
1. Slack Webhookの429/5xxを確認
2. Slack側のURL/Secretを再設定
3. 数分後再実行

**確認コマンド**:
```bash
# Slack Webhook URL確認
echo $SLACK_WEBHOOK_OPS_SUMMARY

# 直近のsend.json確認
jq '.[-1] | {ok, status, error}' logs/day11/*_send.json | tail -n1
```

---

### Exit 22: Stripe 0件

**症状**: Stripeイベントが抽出されない

**対処**:
1. `HOURS=72` へ一時延長
2. `STRIPE_API_KEY` のスコープ確認（Read権限不足が多発）

**確認コマンド**:
```bash
# Stripe API Key確認
stripe events list --limit 10

# イベント抽出確認
jq 'length' tmp/audit_stripe/events_starlist.json
```

---

### Exit 23: send空

**症状**: Day11 sendが空、実行失敗

**対処**:
1. `logs/day11/*_send.json` のHTTP/JSON整合を確認
2. `ops-slack-summary` の直近ログ末尾を再チェック

**確認コマンド**:
```bash
# send.json確認
jq '.[-1]' logs/day11/*_send.json

# Edge Functionログ確認
supabase functions logs --function-name ops-slack-summary --since 2h | tail -n 50
```

---

## 情報漏えい懸念時の対処

**症状**: 監査票に機微情報が含まれている可能性

**対処**:
```bash
# レダクション再適用
make redact && ./FINAL_INTEGRATION_SUITE.sh --audit-only
```

**確認コマンド**:
```bash
# レダクション自己診断
printf 'a@b.com 090-1234-5678 4242424242424242\n' | scripts/utils/redact.sh
```

---

## よくある詰まりへの即応メモ

### Stripe 0件
- `HOURS=72` へ一時増量
- `STRIPE_API_KEY` スコープ確認

### Permalink未取得
- Webhook 429/5xxを確認
- Slack側のURL/Secretを再設定
- 数分後再実行

### DB監査0出力
- `supabase login`を実行
- `SUPABASE_ACCESS_TOKEN`の権限確認（read-onlyで可）

---

**最終更新**: 2025-11-08  
**責任者**: Ops Team

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
