---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# WS01-WS20 Execution Package
**Phase 3 Audit Observer Manual Dispatch & Evidence Collection**

**Date**: 2025-11-13 (UTC)
**Purpose**: Complete execution package for manual dispatch verification and audit evidence collection

---

## WS01: workflow_dispatch 差分検出とパッチ案

### 目的
mainブランチに`workflow_dispatch`が含まれているか確認し、未反映なら最小差分パッチを提示

### 手順（実行コマンド）

```bash
# 1. mainブランチのワークフロー確認
git fetch origin main
git show origin/main:.github/workflows/slsa-provenance.yml | grep -A 5 "workflow_dispatch" || echo "⚠️ workflow_dispatch not found in main"
git show origin/main:.github/workflows/provenance-validate.yml | grep -A 5 "workflow_dispatch" || echo "⚠️ workflow_dispatch not found in main"
git show origin/main:.github/workflows/phase3-audit-observer.yml | grep -A 5 "workflow_dispatch" || echo "⚠️ workflow_dispatch not found in main"

# 2. 現在のブランチとの差分確認
git diff origin/main HEAD -- .github/workflows/slsa-provenance.yml | grep -A 10 "workflow_dispatch" || echo "No diff for workflow_dispatch"
git diff origin/main HEAD -- .github/workflows/provenance-validate.yml | grep -A 10 "workflow_dispatch" || echo "No diff for workflow_dispatch"
git diff origin/main HEAD -- .github/workflows/phase3-audit-observer.yml | grep -A 10 "workflow_dispatch" || echo "No diff for workflow_dispatch"
```

### 期待結果（貼り戻す断片）

```yaml
# 最小差分パッチ案（slsa-provenance.yml）
on:
  release:
    types: [published]
  workflow_dispatch:
    inputs:
      tag:
        description: "Tag name to generate provenance for"
        required: false
        type: string

# 最小差分パッチ案（provenance-validate.yml）
on:
  workflow_run:
    workflows: ["slsa-provenance"]
    types: [completed]
  workflow_dispatch:
    inputs:
      run_id:
        description: "Provenance workflow run ID to validate"
        required: false
        type: string
      tag:
        description: "Tag name (optional)"
        required: false
        type: string

# 最小差分パッチ案（phase3-audit-observer.yml）
on:
  workflow_run:
    workflows: ["slsa-provenance", "provenance-validate"]
    types: [completed]
  workflow_dispatch:
    inputs:
      provenance_run_id:
        description: "Provenance workflow run ID to audit"
        required: false
        type: string
      validation_run_id:
        description: "Validation workflow run ID to audit"
        required: false
        type: string
      pr_number:
        description: "PR number to comment on (if successful)"
        required: false
        type: number
  schedule:
    - cron: '0 0 * * *' # Daily at 00:00 UTC
```

---

## WS02: 422回避のための gh workflow run テンプレ

### 目的
HTTP 422エラーを回避するための`gh workflow run`コマンドテンプレートと想定入力例を生成

### 手順（実行コマンド）

```bash
# 1. ワークフローID確認
gh workflow list --repo shochaso/starlist-app | grep -E "slsa-provenance|provenance-validate|phase3-audit-observer"

# 2. 422回避チェック（mainブランチで実行）
gh api repos/shochaso/starlist-app/actions/workflows/slsa-provenance.yml --jq '.id' || echo "Workflow not found"

# 3. 実行可能か確認（mainブランチ）
gh workflow view slsa-provenance.yml --repo shochaso/starlist-app --yaml | grep -A 3 "workflow_dispatch" || echo "⚠️ workflow_dispatch not available"
```

### 期待結果（貼り戻す断片）

```bash
# 成功ケース実行テンプレ
TAG_SUCCESS="vtest-success-$(date +%Y%m%d%H%M%S)"
gh workflow run slsa-provenance.yml \
  --repo shochaso/starlist-app \
  --ref main \
  -f tag="$TAG_SUCCESS"

# 失敗ケース実行テンプレ
TAG_FAIL="vtest-fail-$(date +%Y%m%d%H%M%S)"
gh workflow run slsa-provenance.yml \
  --repo shochaso/starlist-app \
  --ref main \
  -f tag="$TAG_FAIL"

# 並行実行テンプレ（3本）
for i in 1 2 3; do
  gh workflow run slsa-provenance.yml \
    --repo shochaso/starlist-app \
    --ref main \
    -f tag="vtest-conc-$i-$(date +%s)" &
  sleep 1
done
wait

# Observer実行テンプレ
gh workflow run phase3-audit-observer.yml \
  --repo shochaso/starlist-app \
  --ref main \
  -f provenance_run_id="<RUN_ID>" \
  -f validation_run_id="<RUN_ID>" \
  -f pr_number=61
```

---

## WS03: 成功Run用入力の最小ケースと本番相当ケース

### 目的
成功Run用の入力パラメータを2種類（最小ケース・本番相当ケース）提示し、artifact名規約を含める

### 手順（実行コマンド）

```bash
# 1. 既存の成功Runを確認
gh run list --workflow slsa-provenance.yml --limit 5 --json databaseId,displayTitle,conclusion,createdAt --jq '.[] | select(.conclusion=="success") | {id: .databaseId, title: .displayTitle, created: .createdAt}'

# 2. Artifact名規約確認
gh run view <RUN_ID> --json artifacts --jq '.artifacts[] | {name: .name, size: .sizeInBytes}' || echo "No artifacts found"
```

### 期待結果（貼り戻す断片）

```markdown
## 成功Run入力パラメータ

### 最小ケース
- **Tag**: `vtest-success-20251113`
- **Artifact名規約**: `provenance-{tag}`
- **実行コマンド**:
  ```bash
  gh workflow run slsa-provenance.yml \
    --repo shochaso/starlist-app \
    --ref main \
    -f tag="vtest-success-20251113"
  ```
- **期待Artifact**: `provenance-vtest-success-20251113`

### 本番相当ケース
- **Tag**: `v2025.11.13-release`
- **Artifact名規約**: `provenance-{tag}`, `slsa-manifest-{tag}`
- **実行コマンド**:
  ```bash
  gh workflow run slsa-provenance.yml \
    --repo shochaso/starlist-app \
    --ref main \
    -f tag="v2025.11.13-release"
  ```
- **期待Artifact**: 
  - `provenance-v2025.11.13-release`
  - `slsa-manifest-v2025.11.13-release`
- **検証ポイント**:
  - SHA256整合性
  - PredicateType: `https://slsa.dev/provenance/v0.2`
  - Builder ID確認
```

---

## WS04: 失敗Run再現のための意図的バッドパラメータ集

### 目的
失敗Runを再現するための安全・可逆なバッドパラメータ集とロールバック手順を提示

### 手順（実行コマンド）

```bash
# 1. 既存の失敗Runを確認
gh run list --workflow slsa-provenance.yml --limit 5 --json databaseId,displayTitle,conclusion,createdAt --jq '.[] | select(.conclusion=="failure") | {id: .databaseId, title: .displayTitle, created: .createdAt}'

# 2. 失敗ログ確認
gh run view <RUN_ID> --log | grep -i "error\|fail" | head -10
```

### 期待結果（貼り戻す断片）

```markdown
## 意図的バッドパラメータ集（安全・可逆）

### 1. 無効なTag名
- **Tag**: `invalid-tag-!@#$`
- **期待結果**: Validation error
- **実行コマンド**:
  ```bash
  gh workflow run slsa-provenance.yml \
    --repo shochaso/starlist-app \
    --ref main \
    -f tag="invalid-tag-!@#$"
  ```
- **ロールバック**: 不要（実行失敗のみ）

### 2. 存在しないTag
- **Tag**: `v9999.99.99-nonexistent`
- **期待結果**: Tag not found error
- **実行コマンド**:
  ```bash
  gh workflow run slsa-provenance.yml \
    --repo shochaso/starlist-app \
    --ref main \
    -f tag="v9999.99.99-nonexistent"
  ```
- **ロールバック**: 不要（実行失敗のみ）

### 3. 空のTag（意図的）
- **Tag**: `""` (空文字列)
- **期待結果**: Parameter validation error
- **実行コマンド**:
  ```bash
  gh workflow run slsa-provenance.yml \
    --repo shochaso/starlist-app \
    --ref main \
    -f tag=""
  ```
- **ロールバック**: 不要（実行失敗のみ）

### ロールバック手順
1. 失敗Runを確認: `gh run view <RUN_ID>`
2. ログを保存: `gh run view <RUN_ID> --log > failure_log.txt`
3. 証跡を記録: `docs/reports/2025-11-13/FAILURE_CASE_<RUN_ID>.md`
4. 再実行（正常系）: `gh workflow run slsa-provenance.yml -f tag="vtest-success-$(date +%Y%m%d%H%M%S)"`
```

---

## WS05: Concurrencyロック検証手順

### 目的
同時実行時のロック検証手順（同時実行→ロック→解放までの観測ポイント）を提示

### 手順（実行コマンド）

```bash
# 1. Concurrency設定確認
grep -A 5 "concurrency:" .github/workflows/slsa-provenance.yml || echo "No concurrency setting"

# 2. 同時実行テスト
for i in 1 2 3; do
  gh workflow run slsa-provenance.yml \
    --repo shochaso/starlist-app \
    --ref main \
    -f tag="vtest-conc-$i-$(date +%s)" &
  sleep 1
done
wait

# 3. 実行状況確認
sleep 10
gh run list --workflow slsa-provenance.yml --limit 5 --json databaseId,status,createdAt --jq '.[] | {id: .databaseId, status: .status, created: .createdAt}'
```

### 期待結果（貼り戻す断片）

```markdown
## Concurrencyロック検証手順

### 観測ポイント

1. **同時実行開始**
   - 3つのRunが同時にキューイングされる
   - 実行コマンド:
     ```bash
     for i in 1 2 3; do
       gh workflow run slsa-provenance.yml -f tag="vtest-conc-$i-$(date +%s)" &
       sleep 1
     done
     wait
     ```

2. **ロック確認**
   - 最初のRunが実行中
   - 2番目・3番目のRunが`queued`状態
   - 確認コマンド:
     ```bash
     gh run list --workflow slsa-provenance.yml --limit 5 --json databaseId,status --jq '.[] | "\(.databaseId): \(.status)"'
     ```

3. **解放確認**
   - 最初のRun完了後、2番目のRunが開始
   - 2番目のRun完了後、3番目のRunが開始
   - 確認コマンド:
     ```bash
     gh run watch <RUN_ID>
     ```

### 期待結果
- ✅ 同時実行は1つずつ処理される
- ✅ ロックが正常に機能している
- ✅ キューイング順序が保持される

### 証跡記録
- Run URL: 3つのRun URLを記録
- 実行順序: 開始時刻と完了時刻を記録
- ロック時間: 各Runの待機時間を記録
```

---

## WS06: すべてのRunから収集すべきメタと収集コマンド

### 目的
すべてのRunから収集すべきメタデータ（run-id, html_url, head_sha, artifact名, サイズ, 経過時間）と収集コマンド（gh + jq）を提示

### 手順（実行コマンド）

```bash
# 1. 最新5件のRunメタ収集
gh run list --workflow slsa-provenance.yml --limit 5 --json databaseId,url,headSha,createdAt,updatedAt,conclusion,displayTitle --jq '.[] | {run_id: .databaseId, url: .url, head_sha: .headSha, created: .createdAt, updated: .updatedAt, conclusion: .conclusion, title: .displayTitle}'

# 2. Artifact情報収集
RUN_ID="<RUN_ID>"
gh run view "$RUN_ID" --json artifacts --jq '.artifacts[] | {name: .name, size: .sizeInBytes, created: .createdAt}'

# 3. 実行時間計算
gh run view "$RUN_ID" --json createdAt,updatedAt --jq '(.updatedAt | fromdateiso8601) - (.createdAt | fromdateiso8601)'
```

### 期待結果（貼り戻す断片）

```bash
# Runメタ収集コマンド（全ワークフロー）
for workflow in slsa-provenance.yml provenance-validate.yml phase3-audit-observer.yml; do
  echo "=== $workflow ==="
  gh run list --workflow "$workflow" --limit 10 --json databaseId,url,headSha,createdAt,updatedAt,conclusion,displayTitle,status \
    --jq '.[] | {
      run_id: .databaseId,
      html_url: .url,
      head_sha: .headSha,
      created_at: .createdAt,
      updated_at: .updatedAt,
      conclusion: .conclusion,
      status: .status,
      title: .displayTitle,
      duration_seconds: ((.updatedAt | fromdateiso8601) - (.createdAt | fromdateiso8601))
    }' > "docs/reports/2025-11-13/${workflow//\//_}_runs.json"
done

# Artifact情報収集コマンド
RUN_ID="<RUN_ID>"
gh run view "$RUN_ID" --json artifacts --jq '{
  run_id: .databaseId,
  artifacts: [.artifacts[] | {
    name: .name,
    size_bytes: .sizeInBytes,
    created_at: .createdAt,
    download_url: .archiveDownloadUrl
  }]
}' > "docs/reports/2025-11-13/artifacts_${RUN_ID}.json"

# 実行時間計算コマンド
gh run view "$RUN_ID" --json createdAt,updatedAt --jq '{
  run_id: .databaseId,
  created_at: .createdAt,
  updated_at: .updatedAt,
  duration_seconds: ((.updatedAt | fromdateiso8601) - (.createdAt | fromdateiso8601)),
  duration_human: (((.updatedAt | fromdateiso8601) - (.createdAt | fromdateiso8601)) | strftime("%H:%M:%S"))
}'
```

---

## WS07: 収集メタを RUNS_SUMMARY.json に整形するスニペット

### 目的
収集したメタデータを`docs/reports/2025-11-13/RUNS_SUMMARY.json`に整形するスニペットを提示

### 手順（実行コマンド）

```bash
# 1. 日付ディレクトリ確認
mkdir -p docs/reports/2025-11-13

# 2. 既存のRunデータ確認
ls -la docs/reports/2025-11-13/*_runs.json 2>/dev/null || echo "No run data files found"
```

### 期待結果（貼り戻す断片）

```bash
#!/bin/bash
# RUNS_SUMMARY.json生成スクリプト

REPORT_DIR="docs/reports/2025-11-13"
SUMMARY_FILE="$REPORT_DIR/RUNS_SUMMARY.json"

# 全ワークフローのRunデータを統合
jq -s '{
  generated_at: (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
  summary: {
    total_runs: (map(length) | add),
    workflows: {
      slsa_provenance: (.[0] | length),
      provenance_validate: (.[1] | length),
      phase3_audit_observer: (.[2] | length)
    }
  },
  runs: {
    slsa_provenance: .[0],
    provenance_validate: .[1],
    phase3_audit_observer: .[2]
  }
}' \
  "$REPORT_DIR/slsa-provenance.yml_runs.json" \
  "$REPORT_DIR/provenance-validate.yml_runs.json" \
  "$REPORT_DIR/phase3-audit-observer.yml_runs.json" \
  > "$SUMMARY_FILE"

echo "✅ RUNS_SUMMARY.json generated: $SUMMARY_FILE"
cat "$SUMMARY_FILE" | jq '.summary'
```

---

## WS08: _evidence_index.md に追記するMarkdown断片

### 目的
`_evidence_index.md`に追記するMarkdown断片（Run一覧・PR #61コメントリンク・Slack Permalink）を提示

### 手順（実行コマンド）

```bash
# 1. 既存の_evidence_index.md確認
cat docs/reports/_evidence_index.md | tail -20

# 2. PR #61コメント確認
gh pr view 61 --repo shochaso/starlist-app --json comments --jq '.comments[] | {id: .id, url: .url, created: .createdAt}'
```

### 期待結果（貼り戻す断片）

```markdown
## 2025-11-13 Evidence Collection

### Success Runs
| Run ID | URL | Tag | Artifacts | Status |
|--------|-----|-----|-----------|--------|
| 19303622894 | https://github.com/shochaso/starlist-app/actions/runs/19303622894 | vtest-success-20251113 | provenance-vtest-success-20251113 | ✅ Success |
| [RUN_ID] | [URL] | [TAG] | [ARTIFACT_NAME] | [STATUS] |

### Failure Runs
| Run ID | URL | Tag | Error Type | Status |
|--------|-----|-----|------------|--------|
| [RUN_ID] | [URL] | [TAG] | [ERROR_TYPE] | ❌ Failure |

### Concurrency Runs
| Run ID | URL | Tag | Execution Order | Status |
|--------|-----|-----|-----------------|--------|
| [RUN_ID_1] | [URL_1] | vtest-conc-1-* | 1st | ✅ Success |
| [RUN_ID_2] | [URL_2] | vtest-conc-2-* | 2nd | ✅ Success |
| [RUN_ID_3] | [URL_3] | vtest-conc-3-* | 3rd | ✅ Success |

### PR #61 Comments
- [Phase 3 Audit Operationalization Verified](https://github.com/shochaso/starlist-app/pull/61#issuecomment-<COMMENT_ID>)
- [Validation Results](https://github.com/shochaso/starlist-app/pull/61#issuecomment-<COMMENT_ID>)

### Slack Notifications
- [Success Notification](<SLACK_PERMALINK>) - 2025-11-13 10:00 JST
- [Failure Notification](<SLACK_PERMALINK>) - 2025-11-13 10:05 JST

### Related Documents
- [PHASE2_2_VALIDATION_REPORT.md](./2025-11-13/PHASE2_2_VALIDATION_REPORT.md)
- [PHASE3_AUDIT_SUMMARY.md](./2025-11-13/PHASE3_AUDIT_SUMMARY.md)
- [RUNS_SUMMARY.json](./2025-11-13/RUNS_SUMMARY.json)
```

---

## WS09: PHASE3_AUDIT_SUMMARY.md に追記するKPIテンプレ

### 目的
`PHASE3_AUDIT_SUMMARY.md`に追記するKPI（成功率、中央値実行時間、失敗タイプ上位3件）テンプレートを提示

### 手順（実行コマンド）

```bash
# 1. 既存のPHASE3_AUDIT_SUMMARY.md確認
cat docs/reports/2025-11-13/PHASE3_AUDIT_SUMMARY.md 2>/dev/null || echo "File not found"

# 2. Run統計計算
gh run list --workflow slsa-provenance.yml --limit 20 --json conclusion,createdAt,updatedAt --jq '[.[] | {
  conclusion: .conclusion,
  duration: ((.updatedAt | fromdateiso8601) - (.createdAt | fromdateiso8601))
}] | {
  total: length,
  success: map(select(.conclusion=="success")) | length,
  failure: map(select(.conclusion=="failure")) | length,
  success_rate: (map(select(.conclusion=="success")) | length) / length * 100,
  median_duration: ([.[] | .duration] | sort | .[length/2 | floor])
}'
```

### 期待結果（貼り戻す断片）

```markdown
## KPI Summary (2025-11-13)

### Execution Statistics
- **Total Runs**: [COUNT]
- **Success Runs**: [COUNT]
- **Failure Runs**: [COUNT]
- **Success Rate**: [PERCENTAGE]%
- **Median Execution Time**: [SECONDS]s ([HUMAN_READABLE])

### Failure Type Breakdown (Top 3)
| Error Type | Count | Percentage | Example Run |
|------------|-------|------------|-------------|
| Validation Error | [COUNT] | [%] | [RUN_URL] |
| Timeout | [COUNT] | [%] | [RUN_URL] |
| Network Error | [COUNT] | [%] | [RUN_URL] |

### Execution Time Distribution
- **Min**: [SECONDS]s
- **Median**: [SECONDS]s
- **Max**: [SECONDS]s
- **95th Percentile**: [SECONDS]s

### Artifact Statistics
- **Total Artifacts Generated**: [COUNT]
- **Total Artifact Size**: [BYTES] ([HUMAN_READABLE])
- **Average Artifact Size**: [BYTES] ([HUMAN_READABLE])

### Notification Status
- **Slack Notifications Sent**: [COUNT]
- **GitHub Issues Created**: [COUNT]
- **PR Comments Posted**: [COUNT]
```

---

## WS10: PHASE2_2_VALIDATION_REPORT.md に試行履歴を追記する表テンプレ

### 目的
`PHASE2_2_VALIDATION_REPORT.md`に試行履歴（成功/失敗/並行）を追記する表テンプレートを提示

### 手順（実行コマンド）

```bash
# 1. 既存のPHASE2_2_VALIDATION_REPORT.md確認
cat docs/reports/2025-11-13/PHASE2_2_VALIDATION_REPORT.md 2>/dev/null | tail -30 || echo "File not found"

# 2. Run履歴収集
gh run list --workflow slsa-provenance.yml --limit 10 --json databaseId,url,conclusion,createdAt,displayTitle --jq '.[] | {
  run_id: .databaseId,
  url: .url,
  conclusion: .conclusion,
  created: .createdAt,
  title: .displayTitle
}'
```

### 期待結果（貼り戻す断片）

```markdown
## Execution History (2025-11-13)

### Success Cases
| Run ID | URL | Tag | Executed At (UTC/JST) | Duration | Artifacts |
|--------|-----|-----|----------------------|----------|-----------|
| 19303622894 | https://github.com/shochaso/starlist-app/actions/runs/19303622894 | vtest-success-20251113 | 2025-11-13T01:00:00Z / 2025-11-13 10:00:00+09:00 | 120s | provenance-vtest-success-20251113 |
| [RUN_ID] | [URL] | [TAG] | [UTC] / [JST] | [DURATION] | [ARTIFACT_NAME] |

### Failure Cases
| Run ID | URL | Tag | Executed At (UTC/JST) | Error Type | Error Message |
|--------|-----|-----|----------------------|------------|---------------|
| [RUN_ID] | [URL] | [TAG] | [UTC] / [JST] | [ERROR_TYPE] | [ERROR_MESSAGE] |

### Concurrency Cases
| Run ID | URL | Tag | Executed At (UTC/JST) | Execution Order | Status |
|--------|-----|-----|----------------------|-----------------|--------|
| [RUN_ID_1] | [URL_1] | vtest-conc-1-* | [UTC] / [JST] | 1st | ✅ Success |
| [RUN_ID_2] | [URL_2] | vtest-conc-2-* | [UTC] / [JST] | 2nd | ✅ Success |
| [RUN_ID_3] | [URL_3] | vtest-conc-3-* | [UTC] / [JST] | 3rd | ✅ Success |

### Summary
- **Total Executions**: [COUNT]
- **Success Rate**: [PERCENTAGE]%
- **Average Duration**: [SECONDS]s
- **Concurrency Tests**: [COUNT] (all passed)
```

---

## WS11: Secrets 自動点検のためのコマンド雛形

### 目的
Secrets自動点検のための`gh secret list`/`gh secret set`コマンド雛形を提示

### 手順（実行コマンド）

```bash
# 1. 現在のSecrets確認
gh secret list --repo shochaso/starlist-app

# 2. 必須Secrets確認
gh secret list --repo shochaso/starlist-app | grep -E "SUPABASE_URL|SUPABASE_SERVICE_KEY|SLACK_WEBHOOK_URL" || echo "⚠️ Some secrets not found"

# 3. Secrets設定確認（値は表示しない）
for secret in SUPABASE_URL SUPABASE_SERVICE_KEY SLACK_WEBHOOK_URL; do
  if gh secret list --repo shochaso/starlist-app | grep -q "$secret"; then
    echo "✅ $secret: Found"
  else
    echo "❌ $secret: Not found"
  fi
done
```

### 期待結果（貼り戻す断片）

```bash
# Secrets自動点検スクリプト
#!/bin/bash

REPO="shochaso/starlist-app"
REQUIRED_SECRETS=("SUPABASE_URL" "SUPABASE_SERVICE_KEY")
OPTIONAL_SECRETS=("SLACK_WEBHOOK_URL")

echo "🔐 Secrets Audit for $REPO"
echo "================================"

# 必須Secrets確認
echo ""
echo "Required Secrets:"
for secret in "${REQUIRED_SECRETS[@]}"; do
  if gh secret list --repo "$REPO" | grep -q "$secret"; then
    CREATED=$(gh secret list --repo "$REPO" | grep "$secret" | awk '{print $2}')
    echo "  ✅ $secret: Found (created: $CREATED)"
  else
    echo "  ❌ $secret: NOT FOUND"
  fi
done

# オプションSecrets確認
echo ""
echo "Optional Secrets:"
for secret in "${OPTIONAL_SECRETS[@]}"; do
  if gh secret list --repo "$REPO" | grep -q "$secret"; then
    CREATED=$(gh secret list --repo "$REPO" | grep "$secret" | awk '{print $2}')
    echo "  ✅ $secret: Found (created: $CREATED)"
  else
    echo "  ⚠️  $secret: Not set (optional)"
  fi
done

# Secrets設定コマンド（実行は手動）
echo ""
echo "To set missing secrets:"
echo "  gh secret set SUPABASE_URL --repo $REPO"
echo "  gh secret set SUPABASE_SERVICE_KEY --repo $REPO"
echo "  gh secret set SLACK_WEBHOOK_URL --repo $REPO  # Optional"
```

---

## WS12: SUPABASE_SERVICE_KEY 不足時の是正PR案

### 目的
`SUPABASE_SERVICE_KEY`不足時の是正PR案（docs/SECRETS_PRECHECK.md改訂 + CIガードのyml差分案）を提示

### 手順（実行コマンド）

```bash
# 1. 既存のSECRETS_PRECHECK.md確認
cat docs/ops/SECRETS_PRECHECK.md 2>/dev/null | head -30 || echo "File not found"

# 2. CIガード確認
grep -r "SUPABASE_SERVICE_KEY" .github/workflows/ || echo "No CI guard found"
```

### 期待結果（貼り戻す断片）

```markdown
# PR Title
fix(ops): Add SUPABASE_SERVICE_KEY secret check and CI guard

# PR Description
## Problem
`SUPABASE_SERVICE_KEY` secret is not configured, causing Supabase integration failures.

## Solution
1. Update `docs/ops/SECRETS_PRECHECK.md` with setup instructions
2. Add CI guard to fail workflow if secret is missing

## Changes
- Update `docs/ops/SECRETS_PRECHECK.md`
- Add secret check step to `.github/workflows/slsa-provenance.yml`

# File: docs/ops/SECRETS_PRECHECK.md (追加)
## SUPABASE_SERVICE_KEY Setup

### Prerequisites
- Supabase project created
- Service role key generated

### Setup Steps
1. Go to Supabase Dashboard → Project Settings → API
2. Copy "service_role" key (starts with `eyJ...`)
3. Set secret in GitHub:
   ```bash
   gh secret set SUPABASE_SERVICE_KEY --repo shochaso/starlist-app
   ```
4. Verify:
   ```bash
   gh secret list --repo shochaso/starlist-app | grep SUPABASE_SERVICE_KEY
   ```

### CI Guard
The workflow will fail if `SUPABASE_SERVICE_KEY` is not set.

# File: .github/workflows/slsa-provenance.yml (追加)
- name: Check Required Secrets
  run: |
    if [ -z "${{ secrets.SUPABASE_SERVICE_KEY }}" ]; then
      echo "❌ SUPABASE_SERVICE_KEY is not set"
      echo "Please set it using: gh secret set SUPABASE_SERVICE_KEY --repo shochaso/starlist-app"
      exit 1
    fi
    echo "✅ SUPABASE_SERVICE_KEY is set"
```

---

## WS13: Slack Webhook 任意接続の動作確認メッセージ案

### 目的
Slack Webhook任意接続の動作確認メッセージ案（観測用Jsonと想定スクショ見本の説明）を提示

### 手順（実行コマンド）

```bash
# 1. Slack Webhook URL確認（存在のみ）
gh secret list --repo shochaso/starlist-app | grep SLACK_WEBHOOK_URL || echo "SLACK_WEBHOOK_URL not set"

# 2. テストメッセージ送信（手動実行用）
echo "Test message payload (do not execute automatically):"
cat << 'EOF'
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"Test message from SLSA Provenance workflow"}' \
  <SLACK_WEBHOOK_URL>
EOF
```

### 期待結果（貼り戻す断片）

```markdown
## Slack Webhook動作確認

### テストメッセージ送信
```bash
# 注意: 実際のWebhook URLはSecretsから取得
WEBHOOK_URL=$(gh secret get SLACK_WEBHOOK_URL --repo shochaso/starlist-app 2>/dev/null || echo "")

if [ -n "$WEBHOOK_URL" ]; then
  curl -X POST -H 'Content-type: application/json' \
    --data '{
      "text": "🧪 SLSA Provenance Test Message",
      "blocks": [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "*Test Message*\nThis is a test message from SLSA Provenance workflow."
          }
        }
      ]
    }' \
    "$WEBHOOK_URL"
  echo "✅ Test message sent"
else
  echo "⚠️ SLACK_WEBHOOK_URL not set"
fi
```

### 観測用JSON
```json
{
  "timestamp": "2025-11-13T10:00:00Z",
  "event": "test_message",
  "workflow": "slsa-provenance",
  "run_id": "test-run-id",
  "status": "success",
  "message": "Test message from SLSA Provenance workflow"
}
```

### 想定スクショ見本
1. **Slack通知画面**
   - チャンネル: `#slsa-provenance` (例)
   - メッセージ: "🧪 SLSA Provenance Test Message"
   - タイムスタンプ: 2025-11-13 10:00 JST

2. **GitHub Actionsログ**
   - Step: "Send Slack Notification"
   - Status: "Success"
   - Output: "Message sent to Slack"

3. **Slack API Response**
   - Status: 200 OK
   - Response: `{"ok": true, "ts": "1234567890.123456"}`
```

---

## WS14: RETRY_TIPS.md に実Run結果を踏まえた追記断片

### 目的
`RETRY_TIPS.md`に実Run結果を踏まえた追記断片（よくある422/403/5xxの切り分け表）を提示

### 手順（実行コマンド）

```bash
# 1. 既存のRETRY_TIPS.md確認
cat docs/ops/RETRY_TIPS.md 2>/dev/null | head -30 || echo "File not found"

# 2. エラー統計確認
gh run list --workflow slsa-provenance.yml --limit 20 --json conclusion,createdAt --jq '[.[] | select(.conclusion=="failure")] | length'
```

### 期待結果（貼り戻す断片）

```markdown
## Common Error Codes and Troubleshooting

### HTTP 422: Workflow does not have 'workflow_dispatch' trigger
**Cause**: workflow_dispatch not recognized on feature branch
**Solution**:
1. Merge PR to main branch
2. Or use GitHub UI to run workflow
3. Wait 5-10 minutes for GitHub to recognize workflow

**Prevention**: Always merge workflow changes to main before testing

### HTTP 403: Resource not accessible by integration
**Cause**: Insufficient permissions or token scope
**Solution**:
1. Check workflow permissions in `.github/workflows/*.yml`
2. Verify `GITHUB_TOKEN` permissions
3. Check repository settings → Actions → General → Workflow permissions

**Prevention**: Set minimal required permissions

### HTTP 500/502/503: Internal server error
**Cause**: GitHub Actions infrastructure issue
**Solution**:
1. Wait 5-10 minutes and retry
2. Check GitHub Status: https://www.githubstatus.com/
3. Retry with exponential backoff

**Prevention**: Implement retry logic with exponential backoff

### Error Code Summary
| Code | Frequency | Cause | Solution |
|------|-----------|-------|----------|
| 422 | High | workflow_dispatch not recognized | Merge to main |
| 403 | Medium | Permission issue | Check permissions |
| 500/502/503 | Low | Infrastructure issue | Retry with backoff |
| 404 | Low | Resource not found | Check resource exists |
```

---

## WS15: CI_RUNTIME_POLICY.md に手動ディスパッチ時の運用ルール追記断片

### 目的
`CI_RUNTIME_POLICY.md`に手動ディスパッチ時の運用ルール追記断片（誰が・いつ・どこにログ残すか）を提示

### 手順（実行コマンド）

```bash
# 1. 既存のCI_RUNTIME_POLICY.md確認
cat docs/ops/CI_RUNTIME_POLICY.md 2>/dev/null | head -30 || echo "File not found"

# 2. 手動実行履歴確認
gh run list --workflow slsa-provenance.yml --limit 10 --json event,actor,createdAt --jq '.[] | select(.event=="workflow_dispatch") | {actor: .actor.login, created: .createdAt}'
```

### 期待結果（貼り戻す断片）

```markdown
## Manual Dispatch Policy

### Who Can Execute
- **Authorized Roles**: Maintainers, Admins
- **Verification**: Check repository permissions before execution

### When to Execute
- **Scheduled**: Daily at 00:00 UTC (automatic)
- **Manual**: 
  - After code changes affecting provenance generation
  - For testing new features
  - For troubleshooting failures
  - Before releases

### Execution Logging
1. **Before Execution**:
   - Record executor name and timestamp
   - Document reason for manual execution
   - Save to `docs/reports/<YYYY-MM-DD>/MANUAL_EXECUTION_LOG.md`

2. **After Execution**:
   - Record Run ID and URL
   - Document execution result
   - Update `_evidence_index.md`

### Execution Template
```markdown
## Manual Execution Log

**Date**: 2025-11-13 (UTC)
**Executor**: [USERNAME]
**Reason**: [REASON]
**Workflow**: slsa-provenance.yml
**Tag**: [TAG]
**Run ID**: [RUN_ID]
**Run URL**: [URL]
**Result**: [SUCCESS/FAILURE]
**Notes**: [NOTES]
```

### Audit Trail
- All manual executions are logged
- Logs are stored in `docs/reports/<YYYY-MM-DD>/`
- Logs are reviewed weekly
```

---

## WS16: PROVENANCE_RUN_MANUAL.md の「最短実行レシピ」アップデート断片

### 目的
`PROVENANCE_RUN_MANUAL.md`の「最短実行レシピ」アップデート断片（3行で回せる版）を提示

### 手順（実行コマンド）

```bash
# 1. 既存のPROVENANCE_RUN_MANUAL.md確認
cat docs/reports/2025-11-13/PROVENANCE_RUN_MANUAL.md 2>/dev/null | head -30 || echo "File not found"
```

### 期待結果（貼り戻す断片）

```markdown
## 最短実行レシピ（3行版）

### Success Case
```bash
TAG="vtest-success-$(date +%Y%m%d%H%M%S)" && \
gh workflow run slsa-provenance.yml --repo shochaso/starlist-app --ref main -f tag="$TAG" && \
sleep 5 && gh run list --workflow slsa-provenance.yml --limit 1 --json databaseId,url -q '.[0] | "Run ID: \(.databaseId)\nURL: \(.url)"'
```

### Failure Case
```bash
TAG="vtest-fail-$(date +%Y%m%d%H%M%S)" && \
gh workflow run slsa-provenance.yml --repo shochaso/starlist-app --ref main -f tag="$TAG" && \
sleep 5 && gh run list --workflow slsa-provenance.yml --limit 1 --json databaseId,url,conclusion -q '.[0] | "Run ID: \(.databaseId)\nURL: \(.url)\nConclusion: \(.conclusion)"'
```

### Concurrency Case
```bash
for i in 1 2 3; do gh workflow run slsa-provenance.yml --repo shochaso/starlist-app --ref main -f tag="vtest-conc-$i-$(date +%s)" & sleep 1; done && \
wait && \
sleep 10 && \
gh run list --workflow slsa-provenance.yml --limit 3 --json databaseId,url,status -q '.[] | "\(.databaseId): \(.status) - \(.url)"'
```

### 実行後の確認
```bash
RUN_ID="<RUN_ID>" && \
gh run view "$RUN_ID" --json conclusion,status,url && \
gh run download "$RUN_ID" --dir "docs/reports/2025-11-13/artifacts/$RUN_ID"
```
```

---

## WS17: PR #61 用のコメント定型（成功/失敗それぞれ）とチェックボックス

### 目的
PR #61用のコメント定型（成功/失敗それぞれ）とチェックボックスを提示

### 手順（実行コマンド）

```bash
# 1. PR #61確認
gh pr view 61 --repo shochaso/starlist-app --json number,title,state

# 2. 既存コメント確認
gh pr view 61 --repo shochaso/starlist-app --json comments --jq '.comments[] | {id: .id, body: .body, created: .createdAt}' | head -20
```

### 期待結果（貼り戻す断片）

```markdown
## Success Comment Template

```markdown
## ✅ Phase 3 Audit Operationalization Verified

All validation checks passed successfully.

### Execution Results
- ✅ Success Run: [RUN_ID] - [URL]
- ✅ Failure Run: [RUN_ID] - [URL] (intentional)
- ✅ Concurrency Test: 3 runs completed successfully
- ✅ SHA256 Validation: Passed
- ✅ PredicateType Validation: Passed
- ✅ Manifest Updated: [ENTRY_COUNT] entries

### Evidence Files
- [PHASE2_2_VALIDATION_REPORT.md](./docs/reports/2025-11-13/PHASE2_2_VALIDATION_REPORT.md)
- [PHASE3_AUDIT_SUMMARY.md](./docs/reports/2025-11-13/PHASE3_AUDIT_SUMMARY.md)
- [RUNS_SUMMARY.json](./docs/reports/2025-11-13/RUNS_SUMMARY.json)

### Checklist
- [x] Success case executed
- [x] Failure case executed
- [x] Concurrency test passed
- [x] SHA256 validated
- [x] Manifest updated
- [x] Evidence files created
- [x] PR comment posted

**✅ Phase 3 Audit Operationalization Verified — Proceed to Phase 4 (Telemetry & KPI Dashboard)**
```

## Failure Comment Template

```markdown
## ⚠️ Phase 3 Audit Operationalization — Issues Found

Some validation checks failed. Please review and fix.

### Execution Results
- ✅ Success Run: [RUN_ID] - [URL]
- ❌ Failure Run: [RUN_ID] - [URL] - [ERROR_MESSAGE]
- ⚠️ Concurrency Test: [STATUS]
- ⚠️ SHA256 Validation: [STATUS]
- ⚠️ Manifest Updated: [STATUS]

### Issues
1. [ISSUE_1]
2. [ISSUE_2]

### Next Steps
1. [ACTION_1]
2. [ACTION_2]

### Checklist
- [ ] Success case executed
- [ ] Failure case executed
- [ ] Concurrency test passed
- [ ] SHA256 validated
- [ ] Manifest updated
- [ ] Evidence files created
- [ ] Issues resolved
```
```

---

## WS18: DAY11_SOT_DIFFS.md にロールバック/再実行の差分ログ追記断片

### 目的
`DAY11_SOT_DIFFS.md`にロールバック/再実行の差分ログ追記断片を提示

### 手順（実行コマンド）

```bash
# 1. 既存のDAY11_SOT_DIFFS.md確認
cat docs/reports/2025-11-13/DAY11_SOT_DIFFS.md 2>/dev/null | head -30 || echo "File not found"

# 2. 差分確認
git log --oneline --since="2025-11-13" --until="2025-11-14" | head -10
```

### 期待結果（貼り戻す断片）

```markdown
## Rollback and Re-execution Log (2025-11-13)

### Rollback Operations
| Date | Operation | Target | Reason | Rollback Method | Status |
|------|-----------|--------|--------|-----------------|--------|
| 2025-11-13 10:00 JST | Revert workflow change | slsa-provenance.yml | Intentional fail step removal | `git revert <COMMIT>` | ✅ Completed |
| [DATE] | [OPERATION] | [TARGET] | [REASON] | [METHOD] | [STATUS] |

### Re-execution Operations
| Date | Original Run ID | Re-execution Run ID | Reason | Status |
|------|-----------------|---------------------|--------|--------|
| 2025-11-13 10:05 JST | [RUN_ID_1] | [RUN_ID_2] | Artifact download failure | ✅ Completed |
| [DATE] | [RUN_ID] | [RUN_ID] | [REASON] | [STATUS] |

### Diff Log
```diff
# Rollback: Remove intentional fail step
- name: Intentional failure for testing
-   run: |
-     if echo "${{ github.event.inputs.tag }}" | grep -q "fail"; then
-       echo "Intentional failure"; exit 1
-     fi

# Re-execution: Add retry logic
+ name: Retry on failure
+   if: failure()
+   run: |
+     echo "Retrying workflow..."
```

### Rollback Commands
```bash
# Rollback workflow change
git revert <COMMIT_SHA>
git push origin main

# Rollback secret (if needed)
gh secret delete SUPABASE_SERVICE_KEY --repo shochaso/starlist-app

# Rollback branch protection (if needed)
gh api repos/shochaso/starlist-app/branches/main/protection \
  -X DELETE
```

### Re-execution Commands
```bash
# Re-execute workflow
gh workflow run slsa-provenance.yml \
  --repo shochaso/starlist-app \
  --ref main \
  -f tag="<TAG>"

# Re-execute with different parameters
gh workflow run slsa-provenance.yml \
  --repo shochaso/starlist-app \
  --ref main \
  -f tag="<NEW_TAG>"
```
```

---

## WS19: 監査用スクショの推奨構図リスト

### 目的
監査用スクショの推奨構図リスト（Checksタブ/Artifactsダウンロード/Slack通知/Secrets設定画面）を提示

### 手順（実行コマンド）

```bash
# 1. スクショ保存先確認
mkdir -p docs/reports/2025-11-13/screenshots

# 2. 推奨構図リスト作成
cat > docs/reports/2025-11-13/screenshots/README.md << 'EOF'
# Screenshot Guidelines
EOF
```

### 期待結果（貼り戻す断片）

```markdown
## 監査用スクショ推奨構図リスト

### 1. GitHub Actions Checks Tab
**URL**: `https://github.com/shochaso/starlist-app/actions/runs/<RUN_ID>`
**構図**:
- ワークフロー名とRun IDが表示されている
- すべてのジョブのステータスが表示されている
- 実行時間が表示されている
- 結論（Success/Failure）が表示されている

**保存先**: `docs/reports/2025-11-13/screenshots/checks_<RUN_ID>.png`

### 2. Artifacts Download
**URL**: `https://github.com/shochaso/starlist-app/actions/runs/<RUN_ID>`
**構図**:
- Artifactsセクションが表示されている
- Artifact名とサイズが表示されている
- ダウンロードボタンが表示されている

**保存先**: `docs/reports/2025-11-13/screenshots/artifacts_<RUN_ID>.png`

### 3. Slack Notification
**構図**:
- チャンネル名が表示されている
- メッセージ内容が表示されている
- タイムスタンプが表示されている
- リンクがクリック可能である

**保存先**: `docs/reports/2025-11-13/screenshots/slack_<TIMESTAMP>.png`

### 4. Secrets Settings
**URL**: `https://github.com/shochaso/starlist-app/settings/secrets/actions`
**構図**:
- Secrets一覧が表示されている
- 必須Secrets（SUPABASE_URL, SUPABASE_SERVICE_KEY）が表示されている
- オプションSecrets（SLACK_WEBHOOK_URL）が表示されている
- 値は非表示（マスクされている）

**保存先**: `docs/reports/2025-11-13/screenshots/secrets_settings.png`

### 5. Branch Protection Settings
**URL**: `https://github.com/shochaso/starlist-app/settings/branches`
**構図**:
- Branch protection rulesが表示されている
- Required checksに`provenance-validate`が含まれている
- "Admin also requires checks"が有効になっている

**保存先**: `docs/reports/2025-11-13/screenshots/branch_protection.png`

### 6. Workflow Run Logs
**URL**: `https://github.com/shochaso/starlist-app/actions/runs/<RUN_ID>`
**構図**:
- ログが完全に表示されている
- エラーメッセージが表示されている（失敗時）
- 成功メッセージが表示されている（成功時）

**保存先**: `docs/reports/2025-11-13/screenshots/logs_<RUN_ID>.png`

### スクショ命名規則
- `checks_<RUN_ID>.png` - Checks tab
- `artifacts_<RUN_ID>.png` - Artifacts
- `slack_<TIMESTAMP>.png` - Slack notification
- `secrets_settings.png` - Secrets settings
- `branch_protection.png` - Branch protection
- `logs_<RUN_ID>.png` - Workflow logs
```

---

## WS20: 完了宣言チェックリスト

### 目的
完了宣言チェックリスト（リンク全有効・JSON整合・日付フォルダ揃い・差分説明の有無）を提示

### 手順（実行コマンド）

```bash
# 1. 日付フォルダ確認
ls -la docs/reports/2025-11-13/ 2>/dev/null || echo "Directory not found"

# 2. ファイル存在確認
for file in PHASE2_2_VALIDATION_REPORT.md PHASE3_AUDIT_SUMMARY.md RUNS_SUMMARY.json _manifest.json _evidence_index.md; do
  if [ -f "docs/reports/2025-11-13/$file" ]; then
    echo "✅ $file exists"
  else
    echo "❌ $file missing"
  fi
done

# 3. JSON整合性確認
jq '.' docs/reports/2025-11-13/RUNS_SUMMARY.json > /dev/null 2>&1 && echo "✅ RUNS_SUMMARY.json is valid JSON" || echo "❌ RUNS_SUMMARY.json is invalid JSON"
jq '.' docs/reports/2025-11-13/_manifest.json > /dev/null 2>&1 && echo "✅ _manifest.json is valid JSON" || echo "❌ _manifest.json is invalid JSON"

# 4. リンク確認（簡易）
grep -r "https://github.com" docs/reports/2025-11-13/*.md | wc -l
```

### 期待結果（貼り戻す断片）

```markdown
## 完了宣言チェックリスト

### ファイル存在確認
- [ ] `docs/reports/2025-11-13/PHASE2_2_VALIDATION_REPORT.md` exists
- [ ] `docs/reports/2025-11-13/PHASE3_AUDIT_SUMMARY.md` exists
- [ ] `docs/reports/2025-11-13/RUNS_SUMMARY.json` exists
- [ ] `docs/reports/2025-11-13/_manifest.json` exists
- [ ] `docs/reports/2025-11-13/_evidence_index.md` exists
- [ ] `docs/reports/2025-11-13/DAY11_SOT_DIFFS.md` exists

### 実行結果確認
- [ ] Success Run executed (minimum 1 run)
- [ ] Failure Run executed (minimum 1 run)
- [ ] Concurrency Run executed (minimum 3 runs)
- [ ] Run URLs recorded
- [ ] Artifact paths recorded
- [ ] Commit SHAs recorded

### JSON整合性確認
- [ ] `RUNS_SUMMARY.json` is valid JSON
- [ ] `_manifest.json` is valid JSON
- [ ] All JSON files parse correctly

### リンク確認
- [ ] All Run URLs are accessible
- [ ] PR #61 comment links are accessible
- [ ] Slack permalinks are accessible (if applicable)
- [ ] All internal document links are valid

### 証跡確認
- [ ] `_evidence_index.md` contains all Run URLs
- [ ] `_evidence_index.md` contains PR #61 comment links
- [ ] `_evidence_index.md` contains Slack permalinks (if applicable)
- [ ] `PHASE2_2_VALIDATION_REPORT.md` contains execution history
- [ ] `PHASE3_AUDIT_SUMMARY.md` contains KPI summary

### 差分説明確認
- [ ] `DAY11_SOT_DIFFS.md` contains rollback procedures
- [ ] `DAY11_SOT_DIFFS.md` contains re-execution procedures
- [ ] All workflow changes are documented

### Secrets確認
- [ ] `SUPABASE_URL` is set
- [ ] `SUPABASE_SERVICE_KEY` is set (or documented as missing)
- [ ] `SLACK_WEBHOOK_URL` is set (optional)

### スクショ確認（オプション）
- [ ] Checks tab screenshot saved
- [ ] Artifacts screenshot saved
- [ ] Slack notification screenshot saved (if applicable)
- [ ] Secrets settings screenshot saved

### 最終確認
- [ ] All checkboxes above are checked
- [ ] All files are committed and pushed
- [ ] PR #61 comment posted (if applicable)
- [ ] Evidence collection complete

---

## Completion Declaration

**Date**: 2025-11-13 (UTC)
**Status**: ✅ Complete / ⏳ In Progress / ❌ Blocked

**Summary**:
- Total Runs Executed: [COUNT]
- Success Rate: [PERCENTAGE]%
- Evidence Files Created: [COUNT]
- Issues Found: [COUNT]

**Next Steps**:
1. [ACTION_1]
2. [ACTION_2]

**Signed**: [USERNAME]
```

---

## 実行パッケージまとめ

すべてのWS01-WS20の実行手順とテンプレートを`docs/reports/2025-11-13/WS01-WS20_EXECUTION_PACKAGE.md`にまとめました。

各ワークストリームは以下の構成です：
1. **目的**: 何を達成するか
2. **手順**: 実行可能なコマンド/操作
3. **期待結果**: 貼り戻す断片

実行はユーザーがターミナル/ブラウザで行い、結果を貼り戻すことで証跡が完成します。

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
