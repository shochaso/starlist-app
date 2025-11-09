# Day8 最終チェックリスト実行用コマンド

## 1. Secrets登録（どちらか一方）

```bash
# A) 直接Edge URL（推奨）
gh secret set OPS_ALERT_URL --body "https://<edge-domain>/ops-alert"
gh secret set OPS_ALERT_TOKEN --body "<bearer-token>"

# B) Supabase REST
gh secret set SUPABASE_URL --body "https://<project-ref>.supabase.co"
gh secret set SUPABASE_ANON_KEY --body "<anon-key>"
```

## 2. DryRun実行（Day8ブランチで）

```bash
gh workflow run .github/workflows/ops-alert-dryrun.yml --ref feature/day8-ops-health-dashboard
```

## 3. RUN_ID取得 → ログ確認

```bash
RUN_ID=$(gh run list \
  --workflow .github/workflows/ops-alert-dryrun.yml \
  --json databaseId,headBranch,createdAt \
  -q '[.[] | select(.headBranch=="feature/day8-ops-health-dashboard")] | sort_by(.createdAt) | reverse | .[0].databaseId' \
  --limit 50)

echo "$RUN_ID"
gh run view "$RUN_ID" --log
```

## 4. SoT追記（テンプレ反映）

`docs/reports/DAY8_SOT_DIFFS.md` の DryRun 結果セクションに以下を記入：
- Run ID
- 実行時刻(JST)
- 呼び出し経路（Direct Edge or Supabase REST）
- 成功ログ抜粋（`[ops] dryrun success ...`）

```bash
git add docs/reports/DAY8_SOT_DIFFS.md
git commit -m "Day8: record Ops Health dryrun success (RUN_ID=$RUN_ID)"
git push
```

## 5. PR作成（未作成なら）＋ ラベル付与

```bash
gh pr create \
  --base main \
  --head feature/day8-ops-health-dashboard \
  --title "Day8: OPS Health Dashboard 実装（DB + Edge + Flutter）" \
  --body-file PR_BODY.md

gh pr edit "$(gh pr view --json number -q .number)" --add-label ops,docs,ci
gh pr view --web
```

## Done判定（Day8）

- [ ] DryRun 成功（緑）
- [ ] SoT に Run ID＋ログ添付
- [ ] PR 作成・ラベル付与（ops, docs, ci）
- [ ] PR 本文に DoD & スクショ要約

