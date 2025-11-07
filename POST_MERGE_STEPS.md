# Post-Merge作業手順（マージ後すぐ実行）

## 1. ローカルをmainに更新

```bash
git checkout main
git pull origin main
```

## 2. タグ作成

```bash
git tag v0.6.0-ops-dashboard-beta -m 'feat(ops): Day6 OPS Dashboard filters+charts+auto-refresh'
git push origin v0.6.0-ops-dashboard-beta
```

## 3. CHANGELOG更新

`CHANGELOG.md` に以下を追記（ファイルが存在する場合）:

```
## [0.6.0] - 2025-11-07
### Added
- /ops 監視ダッシュボード（β）公開
  - フィルタ（env/app/event/期間）
  - KPI（Total / Err% / p95 / Errors）
  - p95折れ線 + 成功/失敗スタック棒、30秒Auto Refresh
  - 空/エラー時のUI、Pull-to-refresh
```

## 4. DAY6_SOT_DIFFS.md更新

マージSHAを取得して追記:

```bash
MERGE_SHA=$(git log --oneline -1 origin/main | awk '{print $1}')
echo "Merged: yes" >> docs/reports/DAY6_SOT_DIFFS.md
echo "Merge SHA: $MERGE_SHA" >> docs/reports/DAY6_SOT_DIFFS.md
git add docs/reports/DAY6_SOT_DIFFS.md
git commit -m "docs: Update DAY6_SOT_DIFFS with merge info"
git push origin main
```

## 5. 社内告知（Slack #release）

```
**Release**: /ops 監視ダッシュボード（β）公開

* フィルタ（env/app/event/期間）
* KPI（Total / Err% / p95 / Errors）
* p95折れ線 + 成功/失敗スタック棒、30秒Auto Refresh
* 空/エラー時のUI、Pull-to-refresh

PR: https://github.com/shochaso/starlist-app/pull/XXX
```

## 6. Day7ブランチ作成

```bash
git checkout -b feature/day7-ops-alert-automation
git push -u origin feature/day7-ops-alert-automation
```

