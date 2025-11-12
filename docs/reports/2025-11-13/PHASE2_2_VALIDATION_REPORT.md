# Phase 2.2 Validation Report

## 課題 (Issues)

### 現在の課題

1. **workflow_dispatch認識遅延**
   - **原因**: GitHub Actionsがワークフローファイルを認識するまで時間が必要
   - **対策**: PRマージ後にmainブランチで実行、またはGitHub UIから手動実行
   - **確認**: workflow_dispatchが認識されるまで最大10分待機

2. **Supabase連携未設定**
   - **原因**: Secrets（SUPABASE_URL, SUPABASE_SERVICE_KEY）が未設定
   - **対策**: リポジトリ設定でSecretsを設定
   - **確認**: SECRETS_PRECHECK.mdの手順に従って検証

3. **Slack通知未設定**
   - **原因**: SLACK_WEBHOOK_URLが未設定（オプション）
   - **対策**: Slack Webhookを作成してSecretsに設定
   - **確認**: WS09_SLACK_WEBHOOK_VERIFICATION.mdで検証

## 原因 (Root Causes)

1. **GitHub Actions認識遅延**: ブランチpush直後はワークフローファイルが認識されない
2. **Secrets未設定**: 環境変数が設定されていない
3. **手動実行依存**: workflow_dispatchが認識されるまで手動実行が必要

## 対策 (Countermeasures)

1. **workflow_dispatch認識遅延対策**
   - PRマージ後にmainブランチで実行
   - GitHub UIから手動実行
   - 最大10分待機してから再試行

2. **Supabase連携対策**
   - SECRETS_PRECHECK.mdの手順に従ってSecretsを設定
   - Supabase接続テストを実施
   - RLSポリシーを確認

3. **Slack通知対策**
   - Slack Webhookを作成
   - Secretsに設定
   - テストメッセージを送信して検証

## 確認 (Verification)

- [ ] workflow_dispatchが認識されている
- [ ] Supabase連携が動作している
- [ ] Slack通知が動作している（オプション）
- [ ] すべての検証が成功している

---

**Collection Date**: 2025-11-13  
**Branch**: feature/slsa-phase2.1-hardened  
**PR**: #61

---

## 1. Playbook Execution Attempts

The sequential playbook runs for the Success, Failure, and Concurrency cases all fail before the workflow starts because GitHub rejects the dispatch request with an HTTP 422. Below are the raw command invocations and the responses:

### 🔷 Success Case (`v2025.11.13-phase2.2-success`)

```bash
gh workflow run slsa-provenance.yml -f tag=v2025.11.13-phase2.2-success
```

```
could not create workflow dispatch event: HTTP 422: Workflow does not have 'workflow_dispatch' trigger
```

### 🔶 Failure Case (`v2025.11.13-phase2.2-fail`)

```bash
gh workflow run slsa-provenance.yml -f tag=v2025.11.13-phase2.2-fail
```

```
could not create workflow dispatch event: HTTP 422: Workflow does not have 'workflow_dispatch' trigger
```

### 🔷 Concurrency Case (`v2025.11.13-phase2.2-concurrent-1`)

```bash
gh workflow run slsa-provenance.yml -f tag=v2025.11.13-phase2.2-concurrent-1
```

```
could not create workflow dispatch event: HTTP 422: Workflow does not have 'workflow_dispatch' trigger
```

Because each dispatch is blocked, no artifacts have been generated yet (Success run), no failure notifications could fire, and no concurrency group actually executed.

### 1.1 Additional dispatch attempts (explicit path + ref)

```bash
gh workflow run .github/workflows/slsa-provenance.yml --ref feature/slsa-phase2.1-hardened -f tag=v2025.11.13-phase2.2-success
gh workflow run .github/workflows/slsa-provenance.yml --ref feature/slsa-phase2.1-hardened -f tag=v2025.11.13-phase2.2-fail
gh workflow run .github/workflows/slsa-provenance.yml --ref feature/slsa-phase2.1-hardened -f tag=v2025.11.13-phase2.2-concurrent-1
```

Identical responses (`HTTP 422: Workflow does not have 'workflow_dispatch' trigger`) prove that the default branch workflow (Workflow ID 206322579) lacks the manual dispatch hook even though the feature branch defines it. GitHub resolves dispatch events against the default branch metadata, not the branch specified with `--ref`.

### 1.2 Invalid runs summary (JST times)

| Run ID | Event | Created | Conclusion |
| --- | --- | --- | --- |
| 19303053744 | push | 2025-11-13 00:40:39 JST (`2025-11-12T15:40:39Z`) | failure |
| 19302690592 | push | 2025-11-12 24:28:54 JST (`2025-11-12T15:28:54Z`) | failure |
| 19302689701 | push | 2025-11-12 24:28:52 JST (`2025-11-12T15:28:52Z`) | failure |
| 19302628134 | push | 2025-11-12 24:26:55 JST (`2025-11-12T15:26:55Z`) | failure |
| 19302542584 | push | 2025-11-12 24:24:10 JST (`2025-11-12T15:24:10Z`) | failure |

These push-triggered runs finish without artifacts because the workflow intentionally skips when no release context exists (`steps.resolve_tag.outputs.skip == 'true'`).

## 2. Workflow & Artifact State

The most recent `slsa-provenance` runs are all from push events and concluded with `failure` because they skip without a release context. The list below is the current state pulled from GitHub:

```json
[{"conclusion":"failure","createdAt":"2025-11-12T15:40:39Z","databaseId":19303053744,"event":"push","headBranch":"feature/slsa-phase2.1-hardened","status":"completed","workflowName":".github/workflows/slsa-provenance.yml"},{"conclusion":"failure","createdAt":"2025-11-12T15:28:54Z","databaseId":19302690592,"event":"push","headBranch":"feature/slsa-phase2.1-hardened","status":"completed","workflowName":".github/workflows/slsa-provenance.yml"},{"conclusion":"failure","createdAt":"2025-11-12T15:28:52Z","databaseId":19302689701,"event":"push","headBranch":"feature/slsa-phase2.1-hardened","status":"completed","workflowName":".github/workflows/slsa-provenance.yml"},{"conclusion":"failure","createdAt":"2025-11-12T15:26:55Z","databaseId":19302628134,"event":"push","headBranch":"feature/slsa-phase2.1-hardened","status":"completed","workflowName":".github/workflows/slsa-provenance.yml"},{"conclusion":"failure","createdAt":"2025-11-12T15:24:10Z","databaseId":19302542584,"event":"push","headBranch":"feature/slsa-phase2.1-hardened","status":"completed","workflowName":".github/workflows/slsa-provenance.yml"}]
```

Because the manual dispatch never triggered, there are no provenance artifacts to download, no SHA256 to compare, and the `provenance-validate` job never ran.

## 3. Manifest Status

The manifest managed under `docs/reports/_manifest.json` still contains zero entries, so there is no per-day JSON to inspect yet.

```bash
cat docs/reports/_manifest.json | jq '.'
```

```
[]
```

Without a successful run there was also no manifest append commit or SHA256 proof to validate.

## 4. Supabase & Notifications

- No Supabase credentials are available in this environment (`SUPABASE_URL`, `SUPABASE_SERVICE_KEY`, and `SUPABASE_ANON_KEY` were unset), so no ingestion query or telemetry post could be performed (`env | rg -i supabase` returned nothing).
- Slack + issue notifications could not be observed because the failure path never executed—the `notify-on-failure` job is gated on the provenance job completing (which never happened).

## 5. Phase 3 audit observer attempt

```bash
gh workflow run phase3-audit-observer.yml --ref feature/slsa-phase2.1-hardened \
  -f provenance_run_id=19302628134 \
  -f validation_run_id=19303053984
```

```
could not create workflow dispatch event: HTTP 422: Workflow does not have 'workflow_dispatch' trigger
```

The only `phase3-audit-observer` runs to date were push-triggered and failed because they never resolved a valid provenance/validation pair. The workflow already advertises a daily schedule, but it cannot progress until the upstream workflows can be manually dispatched (or the release event succeeds).

## 6. Branch Protection

Branch protection on `main` was previously limited to a single approving review and no required status checks. A custom patch (see the latest REST response below) now enforces `provenance-validate` as a required status check with `strict=true`.

```json
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["provenance-validate"]
  },
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "require_code_owner_reviews": false,
    "dismiss_stale_reviews": false,
    "require_last_push_approval": false
  },
  "enforce_admins": false,
  "required_linear_history": false,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_conversation_resolution": false,
  "lock_branch": false,
  "allow_fork_syncing": false
}
```

This matches the response from `curl https://api.github.com/repos/shochaso/starlist-app/branches/main/protection` after adding the new contexts. The `provenance-validate` check is therefore a gate that must pass before merging to `main`.

## 7. Blockers & Next Steps

1. **Enable manual dispatch** – GitHub refuses to run `slsa-provenance.yml` via `workflow_dispatch` even though the feature branch defines it. Confirm the `workflow_dispatch` trigger is active on the workflow that `gh` sees (typically the default branch version) or rely on a release event to fire the job.
2. **Re-run the Success, Failure, and Concurrency cases once dispatch works**:
   - Collect provenance artifacts (`artifacts/slsa/<tag>/provenance-<tag>.json`), compute SHA256, validate `predicateType` / `content_sha256`, and capture the artifact log.
   - Inspect `docs/reports/_manifest.json` and the per-day `manifest.json` entry for unique `run_id` and `sha` values and a commit hash.
   - Run `scripts/verify_slsa_provenance.sh <RUN_ID> <TAG>` to print predicate metadata and ensure `provenance-validate` completes.
3. **Query Supabase** once `SUPABASE_URL` & service-key secrets are present: `curl ... /rest/v1/slsa_runs?select=...` to prove RLS works and ingestion succeeded.
4. **Watch for Slack/Issue notifications** from the failure run, or manually trigger the `notify-on-failure` job once the provenance job has a non-`success` result.
5. **Monitor the newly required status check** (`provenance-validate`) in branch protection and ensure it fails fast when provenance creation or validation fails.

Once all three playbook cases complete end-to-end, this report should be updated with:
- The `manifest.json` diff and commit hash for each run;
- SHA256 checks and predicate verification logs;
- Supabase ingestion rows + telemetry log entries;
- Evidence that Slack and the fallback issue were delivered; and
- Confirmation that `provenance-validate` succeeded and appears in the required-status-check list.

---

## Evidence tracking

- The `docs/reports/2025-11-13/_evidence_index.md` file lists every command, GIF URL, and API link we can point to while the workflows are waiting for `workflow_dispatch`.
- Branch protection changes and the PR #61 comment (https://github.com/shochaso/starlist-app/pull/61#issuecomment-3522651640) are captured there as well so reviewers can follow the tracing chain.

## WS05: 3ケース実績追記

**追記日時**: 2025-11-13

### 成功ケース

- **Run ID**: (not started yet; manual dispatch returns HTTP 422)
- **Tag**: v2025.11.13-success-test
- **実行方法**: `gh workflow run slsa-provenance.yml --ref feature/slsa-phase2.1-hardened -f tag=v2025.11.13-phase2.2-success`
- **Artifacts**: blocked because the workflow never starts
- **SHA256**: blocked
- **Status**: ⚠️ Awaiting `workflow_dispatch` (missing on default branch)

### 失敗ケース

- **Run ID**: (not started yet; manual dispatch returns HTTP 422)
- **Tag**: v2025.11.13-fail-test
- **実行方法**: `gh workflow run slsa-provenance.yml --ref feature/slsa-phase2.1-hardened -f tag=v2025.11.13-phase2.2-fail`
- **ログ抜粋**: tools/REST responded `HTTP 422: Workflow does not have 'workflow_dispatch' trigger`
- **Status**: ⚠️ Awaiting `workflow_dispatch`

### 同時実行ケース

- **Run IDs**: (not started yet; manual dispatch returns HTTP 422)
- **Tags**: v2025.11.13-concurrent-1/2/3
- **実行方法**: `gh workflow run slsa-provenance.yml --ref feature/slsa-phase2.1-hardened -f tag=...` (three commands)
- **キュー/キャンセル挙動**: blocked because dispatch cannot run
- **Status**: ⚠️ Awaiting `workflow_dispatch`

---

**Note**: 実行完了後、上記項目を更新します。
