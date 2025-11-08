# 監査票受け入れ基準（DoD: Definition of Done）

## 1. 再現性

- [ ] 同一Lookbackで監査票が**同一Front-Matter**（report_id以外）を再現
- [ ] `make verify` が**常に成功**

## 2. 網羅性

- [ ] 監査票本文に **Slack/Edge/Stripe/DB** の4面要約が揃う
- [ ] Front-Matterに必須キーがすべて記録されている

## 3. 証跡性

- [ ] 監査票Front-Matterに **artifactsパス** と **git_sha**、**supabase_ref** を必ず記録
- [ ] 生成物はCIの**Artifacts**で90日以上保全
- [ ] Slack Permalinkが取得できている

## 4. 安全性

- [ ] 監査票に機微情報なし（レダクション済）
- [ ] `.gitignore` で原本ログ/JSONの誤コミットなし
- [ ] 個人情報（メール・電話・カード番号）が含まれていない

## 5. 運用性

- [ ] `make all / day11 / pricing / audit / summarize / verify` が**無修正で通る**
- [ ] 失敗時でもCIは**成果物アップロード**を必ず実行
- [ ] `make summarize` で最新監査票の要約が取得できる

## よくある詰まりへの即応メモ

### Stripe 0件
- `HOURS`を72へ一時増量
- `STRIPE_API_KEY`スコープ確認

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

