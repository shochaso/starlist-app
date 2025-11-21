---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# Day12 Cursor Composer用 一括プロンプト集

## 使用方法

各ブランチの実装時に、以下のプロンプトをCursor Composerに貼り付けて実行してください。

---

## 🔐 【A】Security / Compliance

### A1: sec/sbom-compare-history

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
SBOMを前回生成との差分比較し、依存リスク増減を自動算出するスクリプトを実装する。

【前提】
- 環境: Node.js 20+, CycloneDX SBOM形式
- 依存: @cyclonedx/cyclonedx-npm, diffライブラリ
- CI: GitHub Actionsで週次実行

【要件】
- 前回SBOM（Artifact）と現在SBOMを比較
- 追加/削除/更新された依存関係を検出
- リスクスコアを算出（CVE数、重大度別集計）
- Markdownレポート生成
- CIでArtifact保存

【対象ファイル】
- `scripts/compare_sbom.mjs` (新規)
- `.github/workflows/sbom-compare.yml` (新規)
- `docs/security/SBOM_COMPARE_REPORT.md` (新規)

【実装手順】
1. SBOM比較スクリプト作成（diff計算、リスク算出）
2. GitHub Actionsワークフロー追加（週次実行）
3. レポート生成とArtifact保存
4. ドキュメント作成

【テスト】
- 2つのSBOMファイルで差分検出確認
- リスクスコア計算の正確性確認
- CI実行でArtifact生成確認

【ロールバック】
- ワークフロー無効化
- スクリプト削除

【納品物】
- 変更差分
- テストログ
- サンプルレポート
```

### A2: sec/audit-ci-integration

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
RLS Audit を GitHub CIの必須ステップ化し、失敗時にPRマージをブロックする。

【前提】
- 環境: GitHub Actions, Supabase CLI
- 依存: scripts/rls_audit.sql（既存）
- CI: 全PRで実行

【要件】
- RLS Auditを必須チェックに追加
- 失敗時にPRマージブロック
- レポートをPRコメントに投稿
- 成功時のみマージ許可

【対象ファイル】
- `.github/workflows/rls-audit.yml` (更新)
- `.github/workflows/pr-gate.yml` (新規または更新)

【実装手順】
1. RLS Auditワークフローを必須チェックに設定
2. PR GateワークフローでRLS Audit結果を確認
3. PRコメント投稿機能追加
4. ドキュメント更新

【テスト】
- PR作成時にRLS Audit実行確認
- 失敗時にマージブロック確認
- 成功時にマージ許可確認

【ロールバック】
- 必須チェック解除
- ワークフロー無効化

【納品物】
- 変更差分
- CI実行ログ
- PRコメント例
```

### A3: sec/rate-limit-benchmark

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
RateLimiterをK6で負荷テストし、平均応答50ms以下維持を検証する。

【前提】
- 環境: K6, Edge Functions
- 依存: supabase/functions/_shared/rate.ts（既存）
- テスト: 100 req/s負荷

【要件】
- K6スクリプト作成（負荷テスト）
- 平均応答時間50ms以下検証
- レート制限動作確認（100 req/min）
- CIで自動実行

【対象ファイル】
- `k6/rate_limit_test.js` (新規)
- `.github/workflows/rate-limit-benchmark.yml` (新規)
- `docs/security/RATE_LIMIT_BENCHMARK.md` (新規)

【実装手順】
1. K6スクリプト作成
2. GitHub Actionsワークフロー追加
3. ベンチマーク結果をArtifact保存
4. ドキュメント作成

【テスト】
- K6実行で平均応答時間確認
- レート制限動作確認
- CI実行確認

【ロールバック】
- ワークフロー無効化
- K6スクリプト削除

【納品物】
- 変更差分
- ベンチマーク結果
- テストログ
```

### A4: sec/policy-enforcer

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
セキュリティポリシーファイル（.securitypolicy.json）を生成・検証する。

【前提】
- 環境: Node.js 20+
- 依存: JSON Schema検証
- CI: 全PRで検証

【要件】
- セキュリティポリシーJSON Schema定義
- ポリシーファイル生成スクリプト
- CIでポリシー検証
- 違反時にPRコメント

【対象ファイル】
- `.securitypolicy.json` (新規)
- `schemas/security_policy.schema.json` (新規)
- `scripts/generate_security_policy.mjs` (新規)
- `.github/workflows/security-policy-check.yml` (新規)

【実装手順】
1. JSON Schema定義
2. ポリシー生成スクリプト作成
3. CI検証ワークフロー追加
4. ドキュメント作成

【テスト】
- ポリシー生成確認
- Schema検証確認
- CI実行確認

【ロールバック】
- ワークフロー無効化
- ポリシーファイル削除

【納品物】
- 変更差分
- ポリシーファイル例
- 検証ログ
```

### A5: sec/vulnerability-bot

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
Dependabot + SecurityAlertsをSlackに送信する自動化を実装する。

【前提】
- 環境: GitHub Actions, Slack Webhook
- 依存: Dependabot（既存）、Slack API
- CI: Dependabotアラート時実行

【要件】
- DependabotアラートをSlackに送信
- SecurityAlertsをSlackに送信
- 重大度別にチャンネル分け
- 週次サマリー送信

【対象ファイル】
- `.github/workflows/vulnerability-bot.yml` (新規)
- `supabase/functions/vulnerability-notify/index.ts` (新規)
- `docs/security/VULNERABILITY_BOT.md` (新規)

【実装手順】
1. GitHub Actionsワークフロー作成
2. Slack通知Edge Function作成
3. 重大度別チャンネル設定
4. ドキュメント作成

【テスト】
- Dependabotアラート時にSlack送信確認
- SecurityAlerts時にSlack送信確認
- 週次サマリー送信確認

【ロールバック】
- ワークフロー無効化
- Edge Function削除

【納品物】
- 変更差分
- Slack通知例
- テストログ
```

### A6: sec/headers-verify

```markdown
あなたは超一流のコーディングプロンプト「マイン」です。

【目的】
HTTP Security Headersチェック関数を追加し、CSP/XFO/STS等を監査する。

【前提】
- 環境: Node.js 20+, curl
- 依存: 本番URL
- CI: 週次実行

【要件】
- Security Headers検証スクリプト
- CSP/XFO/XCTO/STS/HSTS検証
- 違反時にレポート生成
- CIで自動実行

【対象ファイル】
- `scripts/verify_security_headers.mjs` (新規)
- `.github/workflows/security-headers-check.yml` (新規)
- `docs/security/SECURITY_HEADERS_AUDIT.md` (新規)

【実装手順】
1. ヘッダー検証スクリプト作成
2. GitHub Actionsワークフロー追加
3. レポート生成
4. ドキュメント作成

【テスト】
- 本番URLでヘッダー検証確認
- 違反検出確認
- CI実行確認

【ロールバック】
- ワークフロー無効化
- スクリプト削除

【納品物】
- 変更差分
- 検証レポート
- テストログ
```

### A7: sec/gitleaks-auto-fix

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
gitleaksの違反を自動PR修正する機能を実装する。

【前提】
- 環境: GitHub Actions, gitleaks
- 依存: .gitleaks.toml（既存）
- CI: PR作成時実行

【要件】
- gitleaks違反検出時に自動修正PR作成
- 機密情報を環境変数に置換
- 修正内容をPRコメントに記載
- 手動承認でマージ

【対象ファイル】
- `.github/workflows/gitleaks-auto-fix.yml` (新規)
- `scripts/auto_fix_secrets.mjs` (新規)
- `docs/security/GITLEAKS_AUTO_FIX.md` (新規)

【実装手順】
1. 自動修正スクリプト作成
2. GitHub Actionsワークフロー追加
3. PR作成機能実装
4. ドキュメント作成

【テスト】
- gitleaks違反検出時に自動修正PR作成確認
- 環境変数置換確認
- PRコメント確認

【ロールバック】
- ワークフロー無効化
- スクリプト削除

【納品物】
- 変更差分
- 自動修正PR例
- テストログ
```

---

## 🧠 【B】Operations / Monitoring

### B1: ops/alert-manager

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
Slackアラートを閾値ごとに集約し、週次レポート連携する。

【前提】
- 環境: Supabase Edge Functions, Slack API
- 依存: ops-alert（既存）、ops-slack-summary（既存）
- 実行: リアルタイム + 週次集計

【要件】
- アラートを閾値ごとに集約
- 重複アラートを抑制
- 週次レポートに統合
- 重要度別チャンネル分け

【対象ファイル】
- `supabase/functions/alert-manager/index.ts` (新規)
- `supabase/functions/ops-slack-summary/index.ts` (更新)
- `docs/ops/ALERT_MANAGER.md` (新規)

【実装手順】
1. Alert Manager Edge Function作成
2. 集約ロジック実装
3. 週次レポート連携
4. ドキュメント作成

【テスト】
- アラート集約動作確認
- 重複抑制確認
- 週次レポート統合確認

【ロールバック】
- Edge Function削除
- 既存機能に戻す

【納品物】
- 変更差分
- テストログ
- アラート例
```

### B2: ops/self-heal-retry

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
失敗処理を自動リトライ・バックオフ付き復旧する機能を実装する。

【前提】
- 環境: Supabase Edge Functions
- 依存: _shared/rate.ts（既存）
- 実行: 失敗時自動実行

【要件】
- 失敗処理を自動リトライ
- 指数バックオフ + Jitter
- 最大リトライ回数制限
- 復旧ログ記録

【対象ファイル】
- `supabase/functions/_shared/retry.ts` (新規)
- `supabase/functions/ops-alert/index.ts` (更新)
- `docs/ops/SELF_HEAL_RETRY.md` (新規)

【実装手順】
1. Retryヘルパー作成
2. 各Edge Functionに統合
3. ログ記録機能追加
4. ドキュメント作成

【テスト】
- リトライ動作確認
- バックオフ動作確認
- 最大リトライ確認

【ロールバック】
- Retryヘルパー削除
- 既存機能に戻す

【納品物】
- 変更差分
- テストログ
- リトライ例
```

### B3: ops/audit-dashboard-v2

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
KPIダッシュボードv2でリスクスコア/優先度表示を実装する。

【前提】
- 環境: Flutter Web, Next.js Dashboard
- 依存: ops_dashboard_page.dart（既存）、dashboard/data/latest.json（既存）
- UI: リスクスコア可視化

【要件】
- リスクスコア計算ロジック
- 優先度別表示
- トレンド表示
- アラート統合

【対象ファイル】
- `lib/src/features/ops/screens/ops_dashboard_v2_page.dart` (新規)
- `app/dashboard/audit/page.tsx` (更新)
- `docs/ops/AUDIT_DASHBOARD_V2.md` (新規)

【実装手順】
1. リスクスコア計算ロジック実装
2. Dashboard v2 UI作成
3. 優先度表示実装
4. ドキュメント作成

【テスト】
- リスクスコア計算確認
- UI表示確認
- 優先度表示確認

【ロールバック】
- Dashboard v2削除
- v1に戻す

【納品物】
- 変更差分
- UIスクリーンショット
- テストログ
```

### B4: ops/runtime-observer

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
Edge関数のメモリ/CPU計測をCloudflare Logsから解析する。

【前提】
- 環境: Cloudflare Logs, Supabase Edge Functions
- 依存: Cloudflare API
- 実行: 週次解析

【要件】
- Cloudflare Logsからメモリ/CPU取得
- 解析スクリプト作成
- レポート生成
- CIで自動実行

【対象ファイル】
- `scripts/analyze_runtime_metrics.mjs` (新規)
- `.github/workflows/runtime-observer.yml` (新規)
- `docs/ops/RUNTIME_OBSERVER.md` (新規)

【実装手順】
1. Cloudflare Logs解析スクリプト作成
2. GitHub Actionsワークフロー追加
3. レポート生成
4. ドキュメント作成

【テスト】
- Logs解析確認
- メモリ/CPU取得確認
- CI実行確認

【ロールバック】
- ワークフロー無効化
- スクリプト削除

【納品物】
- 変更差分
- 解析レポート
- テストログ
```

### B5: ops/dryrun-validator

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
各関数のdryRunモードを自動テストする機能を実装する。

【前提】
- 環境: GitHub Actions, Supabase Edge Functions
- 依存: 全Edge Functions
- CI: 全PRで実行

【要件】
- 全Edge FunctionsのdryRunテスト
- 成功/失敗レポート生成
- PRコメント投稿
- 失敗時にマージブロック

【対象ファイル】
- `scripts/validate_dryrun.mjs` (新規)
- `.github/workflows/dryrun-validator.yml` (新規)
- `docs/ops/DRYRUN_VALIDATOR.md` (新規)

【実装手順】
1. dryRun検証スクリプト作成
2. GitHub Actionsワークフロー追加
3. PRコメント機能追加
4. ドキュメント作成

【テスト】
- 全関数のdryRunテスト確認
- レポート生成確認
- PRコメント確認

【ロールバック】
- ワークフロー無効化
- スクリプト削除

【納品物】
- 変更差分
- テストレポート
- PRコメント例
```

### B6: ops/failure-drill

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
フェイルオーバー訓練スクリプト（ops-failure-simulate.mjs）を実装する。

【前提】
- 環境: Node.js 20+, Supabase
- 依存: Edge Functions
- 実行: 手動実行

【要件】
- 障害シミュレーション機能
- フェイルオーバー動作確認
- 復旧手順検証
- レポート生成

【対象ファイル】
- `scripts/ops-failure-simulate.mjs` (新規)
- `docs/ops/FAILURE_DRILL.md` (新規)

【実装手順】
1. 障害シミュレーションスクリプト作成
2. フェイルオーバー検証機能追加
3. レポート生成
4. ドキュメント作成

【テスト】
- 障害シミュレーション確認
- フェイルオーバー動作確認
- 復旧手順確認

【ロールバック】
- スクリプト削除

【納品物】
- 変更差分
- シミュレーション結果
- テストログ
```

---

## ⚙️ 【C】Automation / Infra

### C1: infra/preflight-matrix-validator

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
.env と GitHub Secretsの一致チェックを自動化する。

【前提】
- 環境: GitHub Actions
- 依存: .env.example, GitHub Secrets
- CI: 全PRで実行

【要件】
- .env.exampleとGitHub Secrets比較
- 不一致検出時にエラー
- レポート生成
- PRコメント投稿

【対象ファイル】
- `scripts/validate_env_matrix.mjs` (新規)
- `.github/workflows/preflight-matrix-validator.yml` (新規)
- `docs/infra/ENV_MATRIX_VALIDATOR.md` (新規)

【実装手順】
1. 環境変数検証スクリプト作成
2. GitHub Actionsワークフロー追加
3. PRコメント機能追加
4. ドキュメント作成

【テスト】
- 一致時成功確認
- 不一致時エラー確認
- PRコメント確認

【ロールバック】
- ワークフロー無効化
- スクリプト削除

【納品物】
- 変更差分
- 検証レポート
- テストログ
```

### C2: infra/cache-metrics

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
Cloudflare Cache命中率を監視／自動最適化する。

【前提】
- 環境: Cloudflare API, Supabase
- 依存: Cloudflare Analytics API
- 実行: 日次監視

【要件】
- Cache命中率取得
- 閾値監視
- 自動最適化提案
- レポート生成

【対象ファイル】
- `scripts/monitor_cache_metrics.mjs` (新規)
- `.github/workflows/cache-metrics.yml` (新規)
- `docs/infra/CACHE_METRICS.md` (新規)

【実装手順】
1. Cache監視スクリプト作成
2. GitHub Actionsワークフロー追加
3. 最適化提案機能追加
4. ドキュメント作成

【テスト】
- Cache命中率取得確認
- 監視動作確認
- 最適化提案確認

【ロールバック】
- ワークフロー無効化
- スクリプト削除

【納品物】
- 変更差分
- 監視レポート
- テストログ
```

### C3: infra/db-index-analyzer

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
SupabaseテーブルのINDEX自動推奨SQL出力機能を実装する。

【前提】
- 環境: Supabase, PostgreSQL
- 依存: pg_stat_statements
- 実行: 週次解析

【要件】
- クエリパフォーマンス解析
- INDEX推奨SQL生成
- レポート生成
- CIで自動実行

【対象ファイル】
- `scripts/analyze_db_indexes.mjs` (新規)
- `.github/workflows/db-index-analyzer.yml` (新規)
- `docs/infra/DB_INDEX_ANALYZER.md` (新規)

【実装手順】
1. INDEX解析スクリプト作成
2. GitHub Actionsワークフロー追加
3. 推奨SQL生成機能追加
4. ドキュメント作成

【テスト】
- クエリ解析確認
- INDEX推奨確認
- SQL生成確認

【ロールバック】
- ワークフロー無効化
- スクリプト削除

【納品物】
- 変更差分
- 解析レポート
- 推奨SQL例
```

### C4: infra/task-automerge

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
安全チェック通過PRを自動マージする機能を実装する。

【前提】
- 環境: GitHub Actions
- 依存: 必須チェック（CI, Security, Tests）
- CI: PR作成時実行

【要件】
- 必須チェック通過確認
- 自動マージ実行
- マージ前最終確認
- ログ記録

【対象ファイル】
- `.github/workflows/task-automerge.yml` (新規)
- `docs/infra/TASK_AUTOMERGE.md` (新規)

【実装手順】
1. 自動マージワークフロー作成
2. チェック通過確認機能追加
3. マージ実行機能追加
4. ドキュメント作成

【テスト】
- チェック通過時自動マージ確認
- チェック失敗時マージブロック確認
- ログ記録確認

【ロールバック】
- ワークフロー無効化

【納品物】
- 変更差分
- 自動マージ例
- テストログ
```

### C5: infra/edge-deploy-matrix

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
Edge Functionsを全環境へ自動デプロイする機能を実装する。

【前提】
- 環境: Supabase CLI, GitHub Actions
- 依存: 全Edge Functions
- CI: mainマージ時実行

【要件】
- 全環境（dev/stg/prod）への自動デプロイ
- デプロイ前dryRun確認
- デプロイ後検証
- ログ記録

【対象ファイル】
- `.github/workflows/edge-deploy-matrix.yml` (新規)
- `scripts/deploy_edge_matrix.sh` (新規)
- `docs/infra/EDGE_DEPLOY_MATRIX.md` (新規)

【実装手順】
1. デプロイマトリックスワークフロー作成
2. 全環境デプロイスクリプト作成
3. 検証機能追加
4. ドキュメント作成

【テスト】
- dev環境デプロイ確認
- stg環境デプロイ確認
- prod環境デプロイ確認

【ロールバック】
- ワークフロー無効化
- 手動デプロイに戻す

【納品物】
- 変更差分
- デプロイログ
- テストログ
```

---

## 🎨 【D】UI/UX / Frontend

### D1: ui/ops-dashboard-darkmode

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
ダッシュボードにテーマ切替（Dark Mode）機能を実装する。

【前提】
- 環境: Flutter Web
- 依存: ops_dashboard_page.dart（既存）
- UI: Theme切替ボタン

【要件】
- Dark Modeテーマ定義
- テーマ切替機能
- 設定の永続化
- アクセシビリティ対応

【対象ファイル】
- `lib/src/features/ops/screens/ops_dashboard_page.dart` (更新)
- `lib/theme/dark_theme.dart` (新規)
- `docs/ux/DARK_MODE.md` (新規)

【実装手順】
1. Dark Theme定義
2. テーマ切替機能実装
3. 設定永続化
4. ドキュメント作成

【テスト】
- テーマ切替動作確認
- 設定永続化確認
- アクセシビリティ確認

【ロールバック】
- Dark Mode削除
- Light Modeのみに戻す

【納品物】
- 変更差分
- UIスクリーンショット
- テストログ
```

### D2: ui/star-profile-preview

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
スターのプロフィールカード表示機能を実装する。

【前提】
- 環境: Flutter Web
- 依存: star_profilesテーブル
- UI: カード形式表示

【要件】
- プロフィールカードUI作成
- 画像表示
- 基本情報表示
- リンク機能

【対象ファイル】
- `lib/src/features/stars/widgets/star_profile_card.dart` (新規)
- `lib/src/features/stars/screens/star_profile_page.dart` (更新)
- `docs/ux/STAR_PROFILE_PREVIEW.md` (新規)

【実装手順】
1. プロフィールカードウィジェット作成
2. 画像表示機能追加
3. 基本情報表示
4. ドキュメント作成

【テスト】
- カード表示確認
- 画像表示確認
- リンク動作確認

【ロールバック】
- カード削除
- 既存表示に戻す

【納品物】
- 変更差分
- UIスクリーンショット
- テストログ
```

### D3: ui/feedback-form

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
ユーザー意見取得ページ（フォーム送信＋匿名分析）を実装する。

【前提】
- 環境: Flutter Web, Supabase Edge Functions
- 依存: feedbackテーブル
- UI: フォーム送信

【要件】
- フィードバックフォームUI作成
- Edge Functionで送信処理
- 匿名分析機能
- レポート生成

【対象ファイル】
- `lib/src/features/feedback/feedback_form_page.dart` (新規)
- `supabase/functions/feedback-submit/index.ts` (新規)
- `docs/ux/FEEDBACK_FORM.md` (新規)

【実装手順】
1. フィードバックフォームUI作成
2. Edge Function作成
3. 匿名分析機能追加
4. ドキュメント作成

【テスト】
- フォーム送信確認
- Edge Function動作確認
- 匿名分析確認

【ロールバック】
- フォーム削除
- Edge Function削除

【納品物】
- 変更差分
- UIスクリーンショット
- テストログ
```

### D4: ui/notification-center

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
アプリ内通知センターを実装する。

【前提】
- 環境: Flutter Web
- 依存: notificationsテーブル
- UI: 通知一覧表示

【要件】
- 通知センターUI作成
- 通知一覧表示
- 既読/未読管理
- リアルタイム更新

【対象ファイル】
- `lib/src/features/notifications/notification_center_page.dart` (新規)
- `lib/src/features/notifications/widgets/notification_item.dart` (新規)
- `docs/ux/NOTIFICATION_CENTER.md` (新規)

【実装手順】
1. 通知センターUI作成
2. 通知一覧表示機能追加
3. 既読/未読管理機能追加
4. ドキュメント作成

【テスト】
- 通知一覧表示確認
- 既読/未読管理確認
- リアルタイム更新確認

【ロールバック】
- 通知センター削除

【納品物】
- 変更差分
- UIスクリーンショット
- テストログ
```

### D5: ui/animation-refine

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
ローディング/トランジション統一を実装する。

【前提】
- 環境: Flutter Web
- 依存: 全画面
- UI: アニメーション統一

【要件】
- 共通アニメーション定義
- ローディングアニメーション統一
- トランジション統一
- パフォーマンス最適化

【対象ファイル】
- `lib/ui/animations/common_animations.dart` (新規)
- `lib/ui/widgets/loading_indicator.dart` (新規)
- `docs/ux/ANIMATION_REFINE.md` (新規)

【実装手順】
1. 共通アニメーション定義
2. ローディングアニメーション統一
3. トランジション統一
4. ドキュメント作成

【テスト】
- アニメーション動作確認
- パフォーマンス確認
- 統一性確認

【ロールバック】
- アニメーション削除
- 既存アニメーションに戻す

【納品物】
- 変更差分
- アニメーション例
- テストログ
```

### D6: ui/serviceicon-validation

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
アイコン辞書検証ツール（重複/未参照検出）を実装する。

【前提】
- 環境: Node.js 20+
- 依存: assets/service_icons/
- 実行: CIで自動実行

【要件】
- アイコン重複検出
- 未参照アイコン検出
- レポート生成
- CIで自動実行

【対象ファイル】
- `scripts/validate_service_icons.mjs` (新規)
- `.github/workflows/serviceicon-validation.yml` (新規)
- `docs/ux/SERVICEICON_VALIDATION.md` (新規)

【実装手順】
1. アイコン検証スクリプト作成
2. GitHub Actionsワークフロー追加
3. レポート生成
4. ドキュメント作成

【テスト】
- 重複検出確認
- 未参照検出確認
- CI実行確認

【ロールバック】
- ワークフロー無効化
- スクリプト削除

【納品物】
- 変更差分
- 検証レポート
- テストログ
```

### D7: ui/consumption-timeline

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
ユーザーの視聴/購買履歴タイムラインを実装する。

【前提】
- 環境: Flutter Web
- 依存: content_consumptionsテーブル
- UI: タイムライン表示

【要件】
- タイムラインUI作成
- 視聴/購買履歴表示
- フィルタ機能
- 無限スクロール

【対象ファイル】
- `lib/src/features/consumption/timeline_page.dart` (新規)
- `lib/src/features/consumption/widgets/timeline_item.dart` (新規)
- `docs/ux/CONSUMPTION_TIMELINE.md` (新規)

【実装手順】
1. タイムラインUI作成
2. 履歴表示機能追加
3. フィルタ機能追加
4. ドキュメント作成

【テスト】
- タイムライン表示確認
- フィルタ動作確認
- 無限スクロール確認

【ロールバック】
- タイムライン削除

【納品物】
- 変更差分
- UIスクリーンショット
- テストログ
```

---

## 💰 【E】Business / Analytics

### E1: biz/revenue-insights

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
売上KPI可視化（顧客単価/継続率）を実装する。

【前提】
- 環境: Next.js Dashboard, Supabase
- 依存: subscriptions, paymentsテーブル
- UI: KPI可視化

【要件】
- 売上KPI計算ロジック
- 顧客単価可視化
- 継続率可視化
- レポート生成

【対象ファイル】
- `app/dashboard/revenue/page.tsx` (新規)
- `app/api/revenue/kpi/route.ts` (新規)
- `docs/biz/REVENUE_INSIGHTS.md` (新規)

【実装手順】
1. KPI計算ロジック実装
2. Dashboard UI作成
3. 可視化機能追加
4. ドキュメント作成

【テスト】
- KPI計算確認
- UI表示確認
- レポート生成確認

【ロールバック】
- Dashboard削除
- API削除

【納品物】
- 変更差分
- UIスクリーンショット
- テストログ
```

### E2: biz/price-recommendation-ai

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
GPTによる課金価格最適提案機能を実装する。

【前提】
- 環境: Supabase Edge Functions, OpenAI API
- 依存: subscriptions, star_profilesテーブル
- AI: GPT-4 API

【要件】
- GPT API統合
- 価格最適化ロジック
- 提案生成機能
- レポート生成

【対象ファイル】
- `supabase/functions/price-recommendation-ai/index.ts` (新規)
- `docs/biz/PRICE_RECOMMENDATION_AI.md` (新規)

【実装手順】
1. GPT API統合
2. 価格最適化ロジック実装
3. 提案生成機能追加
4. ドキュメント作成

【テスト】
- GPT API呼び出し確認
- 価格提案確認
- レポート生成確認

【ロールバック】
- Edge Function削除

【納品物】
- 変更差分
- 提案例
- テストログ
```

### E3: biz/star-onboarding-guide

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
スター登録時チュートリアル自動生成機能を実装する。

【前提】
- 環境: Flutter Web
- 依存: star_profilesテーブル
- UI: チュートリアル表示

【要件】
- チュートリアルUI作成
- 自動生成ロジック
- 進捗管理
- 完了記録

【対象ファイル】
- `lib/src/features/stars/onboarding/onboarding_guide_page.dart` (新規)
- `lib/src/features/stars/onboarding/widgets/onboarding_step.dart` (新規)
- `docs/biz/STAR_ONBOARDING_GUIDE.md` (新規)

【実装手順】
1. チュートリアルUI作成
2. 自動生成ロジック実装
3. 進捗管理機能追加
4. ドキュメント作成

【テスト】
- チュートリアル表示確認
- 自動生成確認
- 進捗管理確認

【ロールバック】
- チュートリアル削除

【納品物】
- 変更差分
- UIスクリーンショット
- テストログ
```

### E4: biz/fan-segmentation

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
ファン属性分析（年齢/地域/課金額）を実装する。

【前提】
- 環境: Next.js Dashboard, Supabase
- 依存: users, subscriptionsテーブル
- UI: 分析可視化

【要件】
- 属性分析ロジック
- 年齢/地域/課金額分析
- 可視化機能
- レポート生成

【対象ファイル】
- `app/dashboard/fan-segmentation/page.tsx` (新規)
- `app/api/fan-segmentation/analyze/route.ts` (新規)
- `docs/biz/FAN_SEGMENTATION.md` (新規)

【実装手順】
1. 属性分析ロジック実装
2. Dashboard UI作成
3. 可視化機能追加
4. ドキュメント作成

【テスト】
- 分析ロジック確認
- UI表示確認
- レポート生成確認

【ロールバック】
- Dashboard削除
- API削除

【納品物】
- 変更差分
- UIスクリーンショット
- テストログ
```

### E5: biz/offers-experiment

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
リワード広告とOffer WallのABテスト機能を実装する。

【前提】
- 環境: Flutter Web, Supabase
- 依存: offersテーブル
- UI: ABテスト表示

【要件】
- ABテストロジック
- リワード広告表示
- Offer Wall表示
- 結果分析

【対象ファイル】
- `lib/src/features/offers/ab_test_page.dart` (新規)
- `lib/src/features/offers/widgets/reward_ad.dart` (新規)
- `lib/src/features/offers/widgets/offer_wall.dart` (新規)
- `docs/biz/OFFERS_EXPERIMENT.md` (新規)

【実装手順】
1. ABテストロジック実装
2. リワード広告UI作成
3. Offer Wall UI作成
4. ドキュメント作成

【テスト】
- ABテスト動作確認
- リワード広告表示確認
- Offer Wall表示確認

【ロールバック】
- ABテスト削除
- 既存表示に戻す

【納品物】
- 変更差分
- UIスクリーンショット
- テストログ
```

---

## 📋 共通実装ガイドライン

### コミットメッセージ形式
```
feat(scope): Day12 [ブランチ名] - [簡潔な説明]

(#day12)
```

### テスト要件
- 各ブランチで単体テスト実装
- CIで自動実行確認
- ドキュメントにテスト方法記載

### ドキュメント要件
- 実装内容の説明
- 使用方法
- トラブルシューティング
- ロールバック手順

---

**最終更新**: 2025-11-08
**ステータス**: 📋 プロンプト準備完了


## 使用方法

各ブランチの実装時に、以下のプロンプトをCursor Composerに貼り付けて実行してください。

---

## 🔐 【A】Security / Compliance

### A1: sec/sbom-compare-history

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
SBOMを前回生成との差分比較し、依存リスク増減を自動算出するスクリプトを実装する。

【前提】
- 環境: Node.js 20+, CycloneDX SBOM形式
- 依存: @cyclonedx/cyclonedx-npm, diffライブラリ
- CI: GitHub Actionsで週次実行

【要件】
- 前回SBOM（Artifact）と現在SBOMを比較
- 追加/削除/更新された依存関係を検出
- リスクスコアを算出（CVE数、重大度別集計）
- Markdownレポート生成
- CIでArtifact保存

【対象ファイル】
- `scripts/compare_sbom.mjs` (新規)
- `.github/workflows/sbom-compare.yml` (新規)
- `docs/security/SBOM_COMPARE_REPORT.md` (新規)

【実装手順】
1. SBOM比較スクリプト作成（diff計算、リスク算出）
2. GitHub Actionsワークフロー追加（週次実行）
3. レポート生成とArtifact保存
4. ドキュメント作成

【テスト】
- 2つのSBOMファイルで差分検出確認
- リスクスコア計算の正確性確認
- CI実行でArtifact生成確認

【ロールバック】
- ワークフロー無効化
- スクリプト削除

【納品物】
- 変更差分
- テストログ
- サンプルレポート
```

### A2: sec/audit-ci-integration

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
RLS Audit を GitHub CIの必須ステップ化し、失敗時にPRマージをブロックする。

【前提】
- 環境: GitHub Actions, Supabase CLI
- 依存: scripts/rls_audit.sql（既存）
- CI: 全PRで実行

【要件】
- RLS Auditを必須チェックに追加
- 失敗時にPRマージブロック
- レポートをPRコメントに投稿
- 成功時のみマージ許可

【対象ファイル】
- `.github/workflows/rls-audit.yml` (更新)
- `.github/workflows/pr-gate.yml` (新規または更新)

【実装手順】
1. RLS Auditワークフローを必須チェックに設定
2. PR GateワークフローでRLS Audit結果を確認
3. PRコメント投稿機能追加
4. ドキュメント更新

【テスト】
- PR作成時にRLS Audit実行確認
- 失敗時にマージブロック確認
- 成功時にマージ許可確認

【ロールバック】
- 必須チェック解除
- ワークフロー無効化

【納品物】
- 変更差分
- CI実行ログ
- PRコメント例
```

### A3: sec/rate-limit-benchmark

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
RateLimiterをK6で負荷テストし、平均応答50ms以下維持を検証する。

【前提】
- 環境: K6, Edge Functions
- 依存: supabase/functions/_shared/rate.ts（既存）
- テスト: 100 req/s負荷

【要件】
- K6スクリプト作成（負荷テスト）
- 平均応答時間50ms以下検証
- レート制限動作確認（100 req/min）
- CIで自動実行

【対象ファイル】
- `k6/rate_limit_test.js` (新規)
- `.github/workflows/rate-limit-benchmark.yml` (新規)
- `docs/security/RATE_LIMIT_BENCHMARK.md` (新規)

【実装手順】
1. K6スクリプト作成
2. GitHub Actionsワークフロー追加
3. ベンチマーク結果をArtifact保存
4. ドキュメント作成

【テスト】
- K6実行で平均応答時間確認
- レート制限動作確認
- CI実行確認

【ロールバック】
- ワークフロー無効化
- K6スクリプト削除

【納品物】
- 変更差分
- ベンチマーク結果
- テストログ
```

### A4: sec/policy-enforcer

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
セキュリティポリシーファイル（.securitypolicy.json）を生成・検証する。

【前提】
- 環境: Node.js 20+
- 依存: JSON Schema検証
- CI: 全PRで検証

【要件】
- セキュリティポリシーJSON Schema定義
- ポリシーファイル生成スクリプト
- CIでポリシー検証
- 違反時にPRコメント

【対象ファイル】
- `.securitypolicy.json` (新規)
- `schemas/security_policy.schema.json` (新規)
- `scripts/generate_security_policy.mjs` (新規)
- `.github/workflows/security-policy-check.yml` (新規)

【実装手順】
1. JSON Schema定義
2. ポリシー生成スクリプト作成
3. CI検証ワークフロー追加
4. ドキュメント作成

【テスト】
- ポリシー生成確認
- Schema検証確認
- CI実行確認

【ロールバック】
- ワークフロー無効化
- ポリシーファイル削除

【納品物】
- 変更差分
- ポリシーファイル例
- 検証ログ
```

### A5: sec/vulnerability-bot

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
Dependabot + SecurityAlertsをSlackに送信する自動化を実装する。

【前提】
- 環境: GitHub Actions, Slack Webhook
- 依存: Dependabot（既存）、Slack API
- CI: Dependabotアラート時実行

【要件】
- DependabotアラートをSlackに送信
- SecurityAlertsをSlackに送信
- 重大度別にチャンネル分け
- 週次サマリー送信

【対象ファイル】
- `.github/workflows/vulnerability-bot.yml` (新規)
- `supabase/functions/vulnerability-notify/index.ts` (新規)
- `docs/security/VULNERABILITY_BOT.md` (新規)

【実装手順】
1. GitHub Actionsワークフロー作成
2. Slack通知Edge Function作成
3. 重大度別チャンネル設定
4. ドキュメント作成

【テスト】
- Dependabotアラート時にSlack送信確認
- SecurityAlerts時にSlack送信確認
- 週次サマリー送信確認

【ロールバック】
- ワークフロー無効化
- Edge Function削除

【納品物】
- 変更差分
- Slack通知例
- テストログ
```

### A6: sec/headers-verify

```markdown
あなたは超一流のコーディングプロンプト「マイン」です。

【目的】
HTTP Security Headersチェック関数を追加し、CSP/XFO/STS等を監査する。

【前提】
- 環境: Node.js 20+, curl
- 依存: 本番URL
- CI: 週次実行

【要件】
- Security Headers検証スクリプト
- CSP/XFO/XCTO/STS/HSTS検証
- 違反時にレポート生成
- CIで自動実行

【対象ファイル】
- `scripts/verify_security_headers.mjs` (新規)
- `.github/workflows/security-headers-check.yml` (新規)
- `docs/security/SECURITY_HEADERS_AUDIT.md` (新規)

【実装手順】
1. ヘッダー検証スクリプト作成
2. GitHub Actionsワークフロー追加
3. レポート生成
4. ドキュメント作成

【テスト】
- 本番URLでヘッダー検証確認
- 違反検出確認
- CI実行確認

【ロールバック】
- ワークフロー無効化
- スクリプト削除

【納品物】
- 変更差分
- 検証レポート
- テストログ
```

### A7: sec/gitleaks-auto-fix

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
gitleaksの違反を自動PR修正する機能を実装する。

【前提】
- 環境: GitHub Actions, gitleaks
- 依存: .gitleaks.toml（既存）
- CI: PR作成時実行

【要件】
- gitleaks違反検出時に自動修正PR作成
- 機密情報を環境変数に置換
- 修正内容をPRコメントに記載
- 手動承認でマージ

【対象ファイル】
- `.github/workflows/gitleaks-auto-fix.yml` (新規)
- `scripts/auto_fix_secrets.mjs` (新規)
- `docs/security/GITLEAKS_AUTO_FIX.md` (新規)

【実装手順】
1. 自動修正スクリプト作成
2. GitHub Actionsワークフロー追加
3. PR作成機能実装
4. ドキュメント作成

【テスト】
- gitleaks違反検出時に自動修正PR作成確認
- 環境変数置換確認
- PRコメント確認

【ロールバック】
- ワークフロー無効化
- スクリプト削除

【納品物】
- 変更差分
- 自動修正PR例
- テストログ
```

---

## 🧠 【B】Operations / Monitoring

### B1: ops/alert-manager

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
Slackアラートを閾値ごとに集約し、週次レポート連携する。

【前提】
- 環境: Supabase Edge Functions, Slack API
- 依存: ops-alert（既存）、ops-slack-summary（既存）
- 実行: リアルタイム + 週次集計

【要件】
- アラートを閾値ごとに集約
- 重複アラートを抑制
- 週次レポートに統合
- 重要度別チャンネル分け

【対象ファイル】
- `supabase/functions/alert-manager/index.ts` (新規)
- `supabase/functions/ops-slack-summary/index.ts` (更新)
- `docs/ops/ALERT_MANAGER.md` (新規)

【実装手順】
1. Alert Manager Edge Function作成
2. 集約ロジック実装
3. 週次レポート連携
4. ドキュメント作成

【テスト】
- アラート集約動作確認
- 重複抑制確認
- 週次レポート統合確認

【ロールバック】
- Edge Function削除
- 既存機能に戻す

【納品物】
- 変更差分
- テストログ
- アラート例
```

### B2: ops/self-heal-retry

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
失敗処理を自動リトライ・バックオフ付き復旧する機能を実装する。

【前提】
- 環境: Supabase Edge Functions
- 依存: _shared/rate.ts（既存）
- 実行: 失敗時自動実行

【要件】
- 失敗処理を自動リトライ
- 指数バックオフ + Jitter
- 最大リトライ回数制限
- 復旧ログ記録

【対象ファイル】
- `supabase/functions/_shared/retry.ts` (新規)
- `supabase/functions/ops-alert/index.ts` (更新)
- `docs/ops/SELF_HEAL_RETRY.md` (新規)

【実装手順】
1. Retryヘルパー作成
2. 各Edge Functionに統合
3. ログ記録機能追加
4. ドキュメント作成

【テスト】
- リトライ動作確認
- バックオフ動作確認
- 最大リトライ確認

【ロールバック】
- Retryヘルパー削除
- 既存機能に戻す

【納品物】
- 変更差分
- テストログ
- リトライ例
```

### B3: ops/audit-dashboard-v2

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
KPIダッシュボードv2でリスクスコア/優先度表示を実装する。

【前提】
- 環境: Flutter Web, Next.js Dashboard
- 依存: ops_dashboard_page.dart（既存）、dashboard/data/latest.json（既存）
- UI: リスクスコア可視化

【要件】
- リスクスコア計算ロジック
- 優先度別表示
- トレンド表示
- アラート統合

【対象ファイル】
- `lib/src/features/ops/screens/ops_dashboard_v2_page.dart` (新規)
- `app/dashboard/audit/page.tsx` (更新)
- `docs/ops/AUDIT_DASHBOARD_V2.md` (新規)

【実装手順】
1. リスクスコア計算ロジック実装
2. Dashboard v2 UI作成
3. 優先度表示実装
4. ドキュメント作成

【テスト】
- リスクスコア計算確認
- UI表示確認
- 優先度表示確認

【ロールバック】
- Dashboard v2削除
- v1に戻す

【納品物】
- 変更差分
- UIスクリーンショット
- テストログ
```

### B4: ops/runtime-observer

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
Edge関数のメモリ/CPU計測をCloudflare Logsから解析する。

【前提】
- 環境: Cloudflare Logs, Supabase Edge Functions
- 依存: Cloudflare API
- 実行: 週次解析

【要件】
- Cloudflare Logsからメモリ/CPU取得
- 解析スクリプト作成
- レポート生成
- CIで自動実行

【対象ファイル】
- `scripts/analyze_runtime_metrics.mjs` (新規)
- `.github/workflows/runtime-observer.yml` (新規)
- `docs/ops/RUNTIME_OBSERVER.md` (新規)

【実装手順】
1. Cloudflare Logs解析スクリプト作成
2. GitHub Actionsワークフロー追加
3. レポート生成
4. ドキュメント作成

【テスト】
- Logs解析確認
- メモリ/CPU取得確認
- CI実行確認

【ロールバック】
- ワークフロー無効化
- スクリプト削除

【納品物】
- 変更差分
- 解析レポート
- テストログ
```

### B5: ops/dryrun-validator

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
各関数のdryRunモードを自動テストする機能を実装する。

【前提】
- 環境: GitHub Actions, Supabase Edge Functions
- 依存: 全Edge Functions
- CI: 全PRで実行

【要件】
- 全Edge FunctionsのdryRunテスト
- 成功/失敗レポート生成
- PRコメント投稿
- 失敗時にマージブロック

【対象ファイル】
- `scripts/validate_dryrun.mjs` (新規)
- `.github/workflows/dryrun-validator.yml` (新規)
- `docs/ops/DRYRUN_VALIDATOR.md` (新規)

【実装手順】
1. dryRun検証スクリプト作成
2. GitHub Actionsワークフロー追加
3. PRコメント機能追加
4. ドキュメント作成

【テスト】
- 全関数のdryRunテスト確認
- レポート生成確認
- PRコメント確認

【ロールバック】
- ワークフロー無効化
- スクリプト削除

【納品物】
- 変更差分
- テストレポート
- PRコメント例
```

### B6: ops/failure-drill

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
フェイルオーバー訓練スクリプト（ops-failure-simulate.mjs）を実装する。

【前提】
- 環境: Node.js 20+, Supabase
- 依存: Edge Functions
- 実行: 手動実行

【要件】
- 障害シミュレーション機能
- フェイルオーバー動作確認
- 復旧手順検証
- レポート生成

【対象ファイル】
- `scripts/ops-failure-simulate.mjs` (新規)
- `docs/ops/FAILURE_DRILL.md` (新規)

【実装手順】
1. 障害シミュレーションスクリプト作成
2. フェイルオーバー検証機能追加
3. レポート生成
4. ドキュメント作成

【テスト】
- 障害シミュレーション確認
- フェイルオーバー動作確認
- 復旧手順確認

【ロールバック】
- スクリプト削除

【納品物】
- 変更差分
- シミュレーション結果
- テストログ
```

---

## ⚙️ 【C】Automation / Infra

### C1: infra/preflight-matrix-validator

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
.env と GitHub Secretsの一致チェックを自動化する。

【前提】
- 環境: GitHub Actions
- 依存: .env.example, GitHub Secrets
- CI: 全PRで実行

【要件】
- .env.exampleとGitHub Secrets比較
- 不一致検出時にエラー
- レポート生成
- PRコメント投稿

【対象ファイル】
- `scripts/validate_env_matrix.mjs` (新規)
- `.github/workflows/preflight-matrix-validator.yml` (新規)
- `docs/infra/ENV_MATRIX_VALIDATOR.md` (新規)

【実装手順】
1. 環境変数検証スクリプト作成
2. GitHub Actionsワークフロー追加
3. PRコメント機能追加
4. ドキュメント作成

【テスト】
- 一致時成功確認
- 不一致時エラー確認
- PRコメント確認

【ロールバック】
- ワークフロー無効化
- スクリプト削除

【納品物】
- 変更差分
- 検証レポート
- テストログ
```

### C2: infra/cache-metrics

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
Cloudflare Cache命中率を監視／自動最適化する。

【前提】
- 環境: Cloudflare API, Supabase
- 依存: Cloudflare Analytics API
- 実行: 日次監視

【要件】
- Cache命中率取得
- 閾値監視
- 自動最適化提案
- レポート生成

【対象ファイル】
- `scripts/monitor_cache_metrics.mjs` (新規)
- `.github/workflows/cache-metrics.yml` (新規)
- `docs/infra/CACHE_METRICS.md` (新規)

【実装手順】
1. Cache監視スクリプト作成
2. GitHub Actionsワークフロー追加
3. 最適化提案機能追加
4. ドキュメント作成

【テスト】
- Cache命中率取得確認
- 監視動作確認
- 最適化提案確認

【ロールバック】
- ワークフロー無効化
- スクリプト削除

【納品物】
- 変更差分
- 監視レポート
- テストログ
```

### C3: infra/db-index-analyzer

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
SupabaseテーブルのINDEX自動推奨SQL出力機能を実装する。

【前提】
- 環境: Supabase, PostgreSQL
- 依存: pg_stat_statements
- 実行: 週次解析

【要件】
- クエリパフォーマンス解析
- INDEX推奨SQL生成
- レポート生成
- CIで自動実行

【対象ファイル】
- `scripts/analyze_db_indexes.mjs` (新規)
- `.github/workflows/db-index-analyzer.yml` (新規)
- `docs/infra/DB_INDEX_ANALYZER.md` (新規)

【実装手順】
1. INDEX解析スクリプト作成
2. GitHub Actionsワークフロー追加
3. 推奨SQL生成機能追加
4. ドキュメント作成

【テスト】
- クエリ解析確認
- INDEX推奨確認
- SQL生成確認

【ロールバック】
- ワークフロー無効化
- スクリプト削除

【納品物】
- 変更差分
- 解析レポート
- 推奨SQL例
```

### C4: infra/task-automerge

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
安全チェック通過PRを自動マージする機能を実装する。

【前提】
- 環境: GitHub Actions
- 依存: 必須チェック（CI, Security, Tests）
- CI: PR作成時実行

【要件】
- 必須チェック通過確認
- 自動マージ実行
- マージ前最終確認
- ログ記録

【対象ファイル】
- `.github/workflows/task-automerge.yml` (新規)
- `docs/infra/TASK_AUTOMERGE.md` (新規)

【実装手順】
1. 自動マージワークフロー作成
2. チェック通過確認機能追加
3. マージ実行機能追加
4. ドキュメント作成

【テスト】
- チェック通過時自動マージ確認
- チェック失敗時マージブロック確認
- ログ記録確認

【ロールバック】
- ワークフロー無効化

【納品物】
- 変更差分
- 自動マージ例
- テストログ
```

### C5: infra/edge-deploy-matrix

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
Edge Functionsを全環境へ自動デプロイする機能を実装する。

【前提】
- 環境: Supabase CLI, GitHub Actions
- 依存: 全Edge Functions
- CI: mainマージ時実行

【要件】
- 全環境（dev/stg/prod）への自動デプロイ
- デプロイ前dryRun確認
- デプロイ後検証
- ログ記録

【対象ファイル】
- `.github/workflows/edge-deploy-matrix.yml` (新規)
- `scripts/deploy_edge_matrix.sh` (新規)
- `docs/infra/EDGE_DEPLOY_MATRIX.md` (新規)

【実装手順】
1. デプロイマトリックスワークフロー作成
2. 全環境デプロイスクリプト作成
3. 検証機能追加
4. ドキュメント作成

【テスト】
- dev環境デプロイ確認
- stg環境デプロイ確認
- prod環境デプロイ確認

【ロールバック】
- ワークフロー無効化
- 手動デプロイに戻す

【納品物】
- 変更差分
- デプロイログ
- テストログ
```

---

## 🎨 【D】UI/UX / Frontend

### D1: ui/ops-dashboard-darkmode

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
ダッシュボードにテーマ切替（Dark Mode）機能を実装する。

【前提】
- 環境: Flutter Web
- 依存: ops_dashboard_page.dart（既存）
- UI: Theme切替ボタン

【要件】
- Dark Modeテーマ定義
- テーマ切替機能
- 設定の永続化
- アクセシビリティ対応

【対象ファイル】
- `lib/src/features/ops/screens/ops_dashboard_page.dart` (更新)
- `lib/theme/dark_theme.dart` (新規)
- `docs/ux/DARK_MODE.md` (新規)

【実装手順】
1. Dark Theme定義
2. テーマ切替機能実装
3. 設定永続化
4. ドキュメント作成

【テスト】
- テーマ切替動作確認
- 設定永続化確認
- アクセシビリティ確認

【ロールバック】
- Dark Mode削除
- Light Modeのみに戻す

【納品物】
- 変更差分
- UIスクリーンショット
- テストログ
```

### D2: ui/star-profile-preview

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
スターのプロフィールカード表示機能を実装する。

【前提】
- 環境: Flutter Web
- 依存: star_profilesテーブル
- UI: カード形式表示

【要件】
- プロフィールカードUI作成
- 画像表示
- 基本情報表示
- リンク機能

【対象ファイル】
- `lib/src/features/stars/widgets/star_profile_card.dart` (新規)
- `lib/src/features/stars/screens/star_profile_page.dart` (更新)
- `docs/ux/STAR_PROFILE_PREVIEW.md` (新規)

【実装手順】
1. プロフィールカードウィジェット作成
2. 画像表示機能追加
3. 基本情報表示
4. ドキュメント作成

【テスト】
- カード表示確認
- 画像表示確認
- リンク動作確認

【ロールバック】
- カード削除
- 既存表示に戻す

【納品物】
- 変更差分
- UIスクリーンショット
- テストログ
```

### D3: ui/feedback-form

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
ユーザー意見取得ページ（フォーム送信＋匿名分析）を実装する。

【前提】
- 環境: Flutter Web, Supabase Edge Functions
- 依存: feedbackテーブル
- UI: フォーム送信

【要件】
- フィードバックフォームUI作成
- Edge Functionで送信処理
- 匿名分析機能
- レポート生成

【対象ファイル】
- `lib/src/features/feedback/feedback_form_page.dart` (新規)
- `supabase/functions/feedback-submit/index.ts` (新規)
- `docs/ux/FEEDBACK_FORM.md` (新規)

【実装手順】
1. フィードバックフォームUI作成
2. Edge Function作成
3. 匿名分析機能追加
4. ドキュメント作成

【テスト】
- フォーム送信確認
- Edge Function動作確認
- 匿名分析確認

【ロールバック】
- フォーム削除
- Edge Function削除

【納品物】
- 変更差分
- UIスクリーンショット
- テストログ
```

### D4: ui/notification-center

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
アプリ内通知センターを実装する。

【前提】
- 環境: Flutter Web
- 依存: notificationsテーブル
- UI: 通知一覧表示

【要件】
- 通知センターUI作成
- 通知一覧表示
- 既読/未読管理
- リアルタイム更新

【対象ファイル】
- `lib/src/features/notifications/notification_center_page.dart` (新規)
- `lib/src/features/notifications/widgets/notification_item.dart` (新規)
- `docs/ux/NOTIFICATION_CENTER.md` (新規)

【実装手順】
1. 通知センターUI作成
2. 通知一覧表示機能追加
3. 既読/未読管理機能追加
4. ドキュメント作成

【テスト】
- 通知一覧表示確認
- 既読/未読管理確認
- リアルタイム更新確認

【ロールバック】
- 通知センター削除

【納品物】
- 変更差分
- UIスクリーンショット
- テストログ
```

### D5: ui/animation-refine

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
ローディング/トランジション統一を実装する。

【前提】
- 環境: Flutter Web
- 依存: 全画面
- UI: アニメーション統一

【要件】
- 共通アニメーション定義
- ローディングアニメーション統一
- トランジション統一
- パフォーマンス最適化

【対象ファイル】
- `lib/ui/animations/common_animations.dart` (新規)
- `lib/ui/widgets/loading_indicator.dart` (新規)
- `docs/ux/ANIMATION_REFINE.md` (新規)

【実装手順】
1. 共通アニメーション定義
2. ローディングアニメーション統一
3. トランジション統一
4. ドキュメント作成

【テスト】
- アニメーション動作確認
- パフォーマンス確認
- 統一性確認

【ロールバック】
- アニメーション削除
- 既存アニメーションに戻す

【納品物】
- 変更差分
- アニメーション例
- テストログ
```

### D6: ui/serviceicon-validation

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
アイコン辞書検証ツール（重複/未参照検出）を実装する。

【前提】
- 環境: Node.js 20+
- 依存: assets/service_icons/
- 実行: CIで自動実行

【要件】
- アイコン重複検出
- 未参照アイコン検出
- レポート生成
- CIで自動実行

【対象ファイル】
- `scripts/validate_service_icons.mjs` (新規)
- `.github/workflows/serviceicon-validation.yml` (新規)
- `docs/ux/SERVICEICON_VALIDATION.md` (新規)

【実装手順】
1. アイコン検証スクリプト作成
2. GitHub Actionsワークフロー追加
3. レポート生成
4. ドキュメント作成

【テスト】
- 重複検出確認
- 未参照検出確認
- CI実行確認

【ロールバック】
- ワークフロー無効化
- スクリプト削除

【納品物】
- 変更差分
- 検証レポート
- テストログ
```

### D7: ui/consumption-timeline

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
ユーザーの視聴/購買履歴タイムラインを実装する。

【前提】
- 環境: Flutter Web
- 依存: content_consumptionsテーブル
- UI: タイムライン表示

【要件】
- タイムラインUI作成
- 視聴/購買履歴表示
- フィルタ機能
- 無限スクロール

【対象ファイル】
- `lib/src/features/consumption/timeline_page.dart` (新規)
- `lib/src/features/consumption/widgets/timeline_item.dart` (新規)
- `docs/ux/CONSUMPTION_TIMELINE.md` (新規)

【実装手順】
1. タイムラインUI作成
2. 履歴表示機能追加
3. フィルタ機能追加
4. ドキュメント作成

【テスト】
- タイムライン表示確認
- フィルタ動作確認
- 無限スクロール確認

【ロールバック】
- タイムライン削除

【納品物】
- 変更差分
- UIスクリーンショット
- テストログ
```

---

## 💰 【E】Business / Analytics

### E1: biz/revenue-insights

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
売上KPI可視化（顧客単価/継続率）を実装する。

【前提】
- 環境: Next.js Dashboard, Supabase
- 依存: subscriptions, paymentsテーブル
- UI: KPI可視化

【要件】
- 売上KPI計算ロジック
- 顧客単価可視化
- 継続率可視化
- レポート生成

【対象ファイル】
- `app/dashboard/revenue/page.tsx` (新規)
- `app/api/revenue/kpi/route.ts` (新規)
- `docs/biz/REVENUE_INSIGHTS.md` (新規)

【実装手順】
1. KPI計算ロジック実装
2. Dashboard UI作成
3. 可視化機能追加
4. ドキュメント作成

【テスト】
- KPI計算確認
- UI表示確認
- レポート生成確認

【ロールバック】
- Dashboard削除
- API削除

【納品物】
- 変更差分
- UIスクリーンショット
- テストログ
```

### E2: biz/price-recommendation-ai

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
GPTによる課金価格最適提案機能を実装する。

【前提】
- 環境: Supabase Edge Functions, OpenAI API
- 依存: subscriptions, star_profilesテーブル
- AI: GPT-4 API

【要件】
- GPT API統合
- 価格最適化ロジック
- 提案生成機能
- レポート生成

【対象ファイル】
- `supabase/functions/price-recommendation-ai/index.ts` (新規)
- `docs/biz/PRICE_RECOMMENDATION_AI.md` (新規)

【実装手順】
1. GPT API統合
2. 価格最適化ロジック実装
3. 提案生成機能追加
4. ドキュメント作成

【テスト】
- GPT API呼び出し確認
- 価格提案確認
- レポート生成確認

【ロールバック】
- Edge Function削除

【納品物】
- 変更差分
- 提案例
- テストログ
```

### E3: biz/star-onboarding-guide

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
スター登録時チュートリアル自動生成機能を実装する。

【前提】
- 環境: Flutter Web
- 依存: star_profilesテーブル
- UI: チュートリアル表示

【要件】
- チュートリアルUI作成
- 自動生成ロジック
- 進捗管理
- 完了記録

【対象ファイル】
- `lib/src/features/stars/onboarding/onboarding_guide_page.dart` (新規)
- `lib/src/features/stars/onboarding/widgets/onboarding_step.dart` (新規)
- `docs/biz/STAR_ONBOARDING_GUIDE.md` (新規)

【実装手順】
1. チュートリアルUI作成
2. 自動生成ロジック実装
3. 進捗管理機能追加
4. ドキュメント作成

【テスト】
- チュートリアル表示確認
- 自動生成確認
- 進捗管理確認

【ロールバック】
- チュートリアル削除

【納品物】
- 変更差分
- UIスクリーンショット
- テストログ
```

### E4: biz/fan-segmentation

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
ファン属性分析（年齢/地域/課金額）を実装する。

【前提】
- 環境: Next.js Dashboard, Supabase
- 依存: users, subscriptionsテーブル
- UI: 分析可視化

【要件】
- 属性分析ロジック
- 年齢/地域/課金額分析
- 可視化機能
- レポート生成

【対象ファイル】
- `app/dashboard/fan-segmentation/page.tsx` (新規)
- `app/api/fan-segmentation/analyze/route.ts` (新規)
- `docs/biz/FAN_SEGMENTATION.md` (新規)

【実装手順】
1. 属性分析ロジック実装
2. Dashboard UI作成
3. 可視化機能追加
4. ドキュメント作成

【テスト】
- 分析ロジック確認
- UI表示確認
- レポート生成確認

【ロールバック】
- Dashboard削除
- API削除

【納品物】
- 変更差分
- UIスクリーンショット
- テストログ
```

### E5: biz/offers-experiment

```markdown
あなたは超一流のコーディングプロンプター「マイン」です。

【目的】
リワード広告とOffer WallのABテスト機能を実装する。

【前提】
- 環境: Flutter Web, Supabase
- 依存: offersテーブル
- UI: ABテスト表示

【要件】
- ABテストロジック
- リワード広告表示
- Offer Wall表示
- 結果分析

【対象ファイル】
- `lib/src/features/offers/ab_test_page.dart` (新規)
- `lib/src/features/offers/widgets/reward_ad.dart` (新規)
- `lib/src/features/offers/widgets/offer_wall.dart` (新規)
- `docs/biz/OFFERS_EXPERIMENT.md` (新規)

【実装手順】
1. ABテストロジック実装
2. リワード広告UI作成
3. Offer Wall UI作成
4. ドキュメント作成

【テスト】
- ABテスト動作確認
- リワード広告表示確認
- Offer Wall表示確認

【ロールバック】
- ABテスト削除
- 既存表示に戻す

【納品物】
- 変更差分
- UIスクリーンショット
- テストログ
```

---

## 📋 共通実装ガイドライン

### コミットメッセージ形式
```
feat(scope): Day12 [ブランチ名] - [簡潔な説明]

(#day12)
```

### テスト要件
- 各ブランチで単体テスト実装
- CIで自動実行確認
- ドキュメントにテスト方法記載

### ドキュメント要件
- 実装内容の説明
- 使用方法
- トラブルシューティング
- ロールバック手順

---

**最終更新**: 2025-11-08
**ステータス**: 📋 プロンプト準備完了

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
