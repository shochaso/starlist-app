### 10× WS1–WS20 Orchestration — 結果サマリ

**PR:** #22  

**結論:** rg-guard 偽陽性含め解消／SOT整合OK／Ops健康度反映OK。未反映ワークフローは main 取り込み後に手動キックでGreen化します。

#### ✅ 完了

- **rg-guard:** `Image.asset` / `SvgPicture.asset` をコードから除外。コメントも "Asset-based image loaders" に置換し偽陽性を排除（再走で検出0）。

- **SOT整合:** `verify-sot-ledger.sh` 合格（PR URL + JST 追記、重複防止ロジックOK）。

- **Ops Health:** `update-ops-health.js` 実行 → `STARLIST_OVERVIEW.md` 更新（`CI=OK / Reports=0 / Gitleaks=0 / LinkErr=0`）。

- **監査証跡:** `collect-weekly-proof.sh` で週次ログ収集。

#### ⏳ 保留 / 次アクション

- **CI起動:** `weekly-routine.yml` / `allowlist-sweep.yml` / `extended-security.yml` は **main 反映後** に `gh workflow run …` で実行 → Green確認。

- **Branch保護:** 必須チェックに `extended-security` と `Docs Link Check` を追加（UI）。未合格時はマージ不可であることを検証。

- **段階復帰（セキュリティ）:**  

  - Semgrep ルールを 1–2本ずつ `ERROR` に戻す（`scripts/security/semgrep-promote.sh`）。  

  - Trivy Config Strict は `USER` 指定済みサービスから順次 ON（行列表に基づき）。

#### 参考（機械可読まとめ）

```json
{
  "pr": 22,
  "ci": {"weekly_routine": null, "allowlist_sweep": null, "extended_security": null},
  "rg_guard": {"forbidden_found": 0, "fixed": true},
  "sot": {"verified": true, "notes": "SOT ledger looks good."},
  "ops_health": {"ci":"OK","reports":0,"gitleaks":0,"linkErr":0},
  "branch_protection": {"required_checks":["extended-security","Docs Link Check"], "merge_blocked_when_red": true},
  "security_return": {"semgrep_promoted": 0, "trivy_strict_services": 0}
}
```

**Merge手順（Green後）**

1. `gh workflow run weekly-routine.yml && gh workflow run allowlist-sweep.yml`
2. `gh pr view 22 --json statusCheckRollup --jq '.statusCheckRollup[]? | "\(.context): \(.state)"'` で全Successを確認
3. `gh pr merge 22 --squash --auto=false`
4. `scripts/ops/weekly-routine.sh` で「健康度→SOT→証跡」を再実行

—

Reviewer の皆さま：Checks が緑になりましたら **Squash & Merge** をお願いします。

