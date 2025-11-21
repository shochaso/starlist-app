---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



Status:: 
Source-of-Truth:: (TBD)
Spec-State:: 
Last-Updated:: 


# QA-E2E-AUTO-001 — E2E自動化仕様

Status: draft  
Last-Updated: 2025-11-07  
Source-of-Truth: Flutter code (`lib/src/features/**`) + Planned CI/CD

> 責任者: QAリード（TBD）／実装: QAチーム + CI/CD担当

## 共通前提（SoT=Flutter/RLS原則/OPS命名）

- **Source of Truth**: Flutter実装を最優先とし、仕様は実装追従
- **RLS原則**: Supabase AuthセッションとPostgres RLSを完全同期、`v_entitlements_effective` で購読判定
- **OPS命名**: 監査イベントを統一（`auth.*`, `auth.sync.dryrun`, `rls.access.denied`, `ops.subscription.price_*`）
- **依存**: QA-E2E-001（Day4 E2Eテスト）、OPS-TELEMETRY-SYNC-001（テレメトリ実シンク）、AUTH-OAUTH-001（認証フロー）

## 1. 目的

- Day4で定義したE2Eテストシナリオ（Google/Appleサインイン、再認証、購読可視性、価格設定）をGitHub Actionsで自動実行する。
- headless Chrome + Flutter WebでE2Eテストを実行し、成功/失敗をCIバッジで可視化する。
- 失敗時はログとスクリーンショットを自動アップロードし、デバッグ時間を短縮する。

## 2. スコープ

- **CI/CD**: `.github/workflows/qa-e2e.yml`の新規作成
- **テストフレームワーク**: Flutter integration_test + Playwright（またはFlutter Web Driver）
- **テストシナリオ**: Day4で定義した主要フロー（認証、RLS、価格設定）
- **アーティファクト**: ログ、スクリーンショット、テレメトリイベント検証結果

## 3. 仕様要点（Reality → Target）

### 3.1 現状（Flutter Reality）

- E2Eテストは手動実行のみ（`flutter test integration_test/`）
- CI/CDにE2Eテストジョブは存在しない
- headless Chromeでの自動実行環境は未整備
- テレメトリイベントの検証は未実装

### 3.2 Target（実装目標）

- GitHub ActionsでE2Eテストを自動実行（PR作成時＋mainブランチへのマージ時）
- headless ChromeでFlutter Webアプリを起動し、主要フローを自動検証
- テスト完了後、`ops_metrics`テーブルを検証してテレメトリイベントが正しく送信されているか確認
- 失敗時はログとスクリーンショットをGitHub Actionsアーティファクトに保存

## 4. テストシナリオ

### 4.1 認証フロー（AUTH-OAUTH-001連携）

| シナリオ | 期待値 | テレメトリ検証 |
| --- | --- | --- |
| メールログイン成功 | ホーム画面に遷移 | `auth.login.success`が`ops_metrics`に記録 |
| メールログイン失敗（不正パスワード） | エラーメッセージ表示 | `auth.login.failure`が`ops_metrics`に記録 |
| セッション失効後の再認証 | 再認証モーダル表示 | `auth.reauth.triggered`が`ops_metrics`に記録 |

### 4.2 RLSフロー（SEC-RLS-SYNC-001連携）

| シナリオ | 期待値 | テレメトリ検証 |
| --- | --- | --- |
| 未購読ユーザーが有料コンテンツにアクセス | アクセス拒否 | `rls.access.denied`が`ops_metrics`に記録 |
| 購読ユーザーが有料コンテンツにアクセス | コンテンツ表示 | RLS拒否イベントなし |

### 4.3 価格設定フロー（PAY-STAR-SUBS-PER-STAR-PRICING連携）

| シナリオ | 期待値 | テレメトリ検証 |
| --- | --- | --- |
| 成人ユーザーが価格を設定 | 価格入力UI表示 | `ops.subscription.price_set`が`ops_metrics`に記録 |
| 未成年ユーザーが上限超え価格を設定 | バリデーションエラー | `ops.subscription.price_denied`が`ops_metrics`に記録 |
| 価格確定 | 決済確認画面表示 | `ops.subscription.price_confirmed`が`ops_metrics`に記録 |

## 5. CI/CD実装

### 5.1 `.github/workflows/qa-e2e.yml`

```yaml
name: QA E2E Tests

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  e2e:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'
          channel: 'stable'
      
      - name: Install dependencies
        run: |
          flutter pub get
          npm ci
      
      - name: Setup Chrome
        uses: browser-actions/setup-chrome@latest
      
      - name: Run E2E tests
        env:
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
          SUPABASE_SERVICE_ROLE_KEY: ${{ secrets.SUPABASE_SERVICE_ROLE_KEY }}
          TELEMETRY_DRY_RUN: 'false'
        run: |
          flutter test integration_test/e2e_test.dart \
            --device-id=chrome \
            --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} \
            --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}
        continue-on-error: true
      
      - name: Upload test artifacts
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: e2e-test-results
          path: |
            test_results/
            screenshots/
            logs/
          retention-days: 7
      
      - name: Verify telemetry events
        if: always()
        run: |
          # ops_metricsテーブルからテスト実行中のイベントを検証
          node scripts/verify-telemetry-events.js
      
      - name: Comment PR with test results
        if: github.event_name == 'pull_request' && always()
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const results = fs.readFileSync('test_results/summary.json', 'utf8');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## E2E Test Results\n\`\`\`json\n${results}\n\`\`\``
            });
```

### 5.2 E2Eテストファイル構造

```
integration_test/
  ├── e2e_test.dart          # メインテストファイル
  ├── helpers/
  │   ├── auth_helper.dart   # 認証ヘルパー
  │   ├── rls_helper.dart    # RLS検証ヘルパー
  │   └── price_helper.dart  # 価格設定ヘルパー
  └── fixtures/
      └── test_users.json    # テストユーザー情報
```

### 5.3 テレメトリ検証スクリプト

```javascript
// scripts/verify-telemetry-events.js
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function verifyEvents() {
  const testStartTime = process.env.TEST_START_TIME || new Date().toISOString();
  
  const { data, error } = await supabase
    .from('ops_metrics')
    .select('event_name, source, payload, created_at')
    .gte('created_at', testStartTime)
    .order('created_at', { ascending: false });
  
  if (error) {
    console.error('Failed to fetch metrics:', error);
    process.exit(1);
  }
  
  const expectedEvents = [
    'auth.login.success',
    'ops.subscription.price_set',
    'rls.access.denied',
  ];
  
  const foundEvents = data.map(e => e.event_name);
  const missingEvents = expectedEvents.filter(e => !foundEvents.includes(e));
  
  if (missingEvents.length > 0) {
    console.error('Missing expected events:', missingEvents);
    process.exit(1);
  }
  
  console.log('✅ All expected telemetry events found');
}

verifyEvents();
```

## 6. テスト実行環境

- **OS**: Ubuntu Latest（GitHub Actions）
- **Flutter**: Stable channel
- **Node**: v20
- **Browser**: Chrome (headless)
- **テストタイムアウト**: 30分

## 7. 依存関係

- QA-E2E-001（Day4 E2Eテスト仕様）
- OPS-TELEMETRY-SYNC-001（テレメトリ実シンク）
- AUTH-OAUTH-001（認証フロー）
- SEC-RLS-SYNC-001（RLSフロー）
- PAY-STAR-SUBS-PER-STAR-PRICING（価格設定フロー）

## 8. テスト観点

- 主要フロー（認証、RLS、価格設定）が正常に動作すること
- テレメトリイベントが正しく`ops_metrics`に記録されること
- 失敗時のログとスクリーンショットが保存されること
- CIバッジが正しく更新されること（成功=緑、失敗=赤）

## 9. 完了条件

- `.github/workflows/qa-e2e.yml`の作成と動作確認
- E2Eテストファイル（`integration_test/e2e_test.dart`）の作成
- テレメトリ検証スクリプト（`scripts/verify-telemetry-events.js`）の作成
- CIバッジの追加（README.mdに`![QA E2E](https://github.com/.../workflows/qa-e2e.yml/badge.svg)`）
- テスト実行結果のアーティファクト保存確認
- PRコメントへのテスト結果自動投稿確認

---

## 差分サマリ (Before/After)

- **Before**: E2Eテストは手動実行のみ。CI/CDにE2Eテストジョブなし。テレメトリイベント検証なし。
- **After**: GitHub ActionsでE2Eテストを自動実行。headless Chromeで主要フローを検証。テレメトリイベントを`ops_metrics`から検証。
- **追加**: 失敗時のログとスクリーンショット自動保存、PRコメントへの結果自動投稿を実装。

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
