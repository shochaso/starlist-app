# セキュリティ・秘匿情報ガイド（監査票生成）

## 最小権限の原則

### CIシークレット（GitHub Actions）

以下のシークレットのみを設定してください：

- `SUPABASE_URL` - SupabaseプロジェクトURL
- `SUPABASE_ANON_KEY` - Supabase匿名キー（読み取り専用）
- `SUPABASE_PROJECT_REF` - プロジェクト参照ID（20桁）
- `SUPABASE_ACCESS_TOKEN` - Supabaseアクセストークン（Edge Functionsログ取得用）
- `STRIPE_API_KEY` - Stripe APIキー（イベント取得用）

**含めないもの:**
- Service Role Key（書き込み権限）
- 個人情報（メールアドレス、カード番号）
- パスワード・トークン（長期有効）

## 監査票への情報制限

### 含めるもの

- イベントID・タイプ・金額（集計値）
- 実行日時・環境情報
- エラーメッセージ（個人情報を除く）
- チェックサム（sha256）

### 含めないもの

- 個人情報（メールアドレス、氏名、電話番号）
- カード番号・CVV
- 完全なStripe Customer ID（必要に応じて末尾4桁のみ）
- 完全なSupabase User ID（必要に応じてハッシュ化）

## ログファイルの取り扱い

### 一時ファイル（tmp/）

- `tmp/audit_day11/*.json` - Day11実行ログ
- `tmp/audit_stripe/*.json` - Stripeイベント
- `tmp/audit_edge/*.log` - Edge Functionログ

**取り扱い:**
- `.gitignore` に `tmp/**` を登録
- CI Artifactsで90日間保持
- PRには含めない（監査票Markdownのみ）

### 監査票（docs/reports/）

- `docs/reports/<YYYY-MM-DD>_DAY11_AUDIT_<G-WNN>.md`
- `docs/reports/<YYYY-MM-DD>_PRICING_AUDIT.md`

**取り扱い:**
- 監査票のみをPRに含める
- 個人情報を含まない要約のみ
- 原本（JSON/ログ）はArtifactsで保全

## 漏えい防止チェックリスト

- [ ] `set +x` でデバッグ出力を無効化
- [ ] 環境変数のログ出力をマスク（`${VAR:0:20}...`）
- [ ] 監査票に完全なAPIキー・トークンを記載しない
- [ ] Stripeイベントから個人情報を除外（ID/型/金額のみ）
- [ ] Git LFSを使用する場合は、大きなログファイルをLFSに配置

## トラブルシューティング

### シークレット漏えいが疑われる場合

1. **即座にシークレットをローテーション**
   - GitHub Secretsを更新
   - Supabase Keysを再生成
   - Stripe API Keyを再生成

2. **監査票の確認**
   - 過去の監査票に機密情報が含まれていないか確認
   - 含まれている場合は、該当ファイルを削除・修正

3. **ログの確認**
   - CIログに機密情報が出力されていないか確認
   - 出力されている場合は、該当ジョブを削除

## 運用ルール

- **最小権限**: 必要な権限のみを付与
- **定期ローテーション**: シークレットは定期的に更新
- **監査証跡**: すべてのアクセスをログに記録
- **分離**: 本番環境とテスト環境のシークレットを分離

---

**最終更新**: 2025-11-08  
**責任者**: Ops Team

