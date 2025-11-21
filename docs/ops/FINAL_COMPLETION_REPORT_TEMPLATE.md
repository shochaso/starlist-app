---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# FINAL_COMPLETION_REPORT.md テンプレート

**作成日**: 2025-11-09  
**用途**: 本日の実績を1ページに集約（Web編集で記録）

---

## Run IDs

### weekly-routine
- RUN_ID: `<取得待ち>`
- conclusion: `<取得待ち>`
- 実行日時: `<取得待ち>`

### allowlist-sweep
- RUN_ID: `<取得待ち>`
- conclusion: `<取得待ち>`
- 実行日時: `<取得待ち>`

### extended-security
- RUN_ID: `<取得待ち>`
- conclusion: `<取得待ち>`
- 実行日時: `<取得待ち>`

---

## 主要Checks

| Check名 | 状態 | 備考 |
|---------|------|------|
| extended-security | `<取得待ち>` | |
| Docs Link Check | `<取得待ち>` | SOT検証含む |
| rg-guard | `<取得待ち>` | 誤検知0件目標 |

---

## Overview抜粋

**ファイル**: `docs/overview/STARLIST_OVERVIEW.md`

**Ops健康度**:
- CI: `<取得待ち>`
- Reports: `<取得待ち>`
- Gitleaks: `<取得待ち>`
- LinkErr: `<取得待ち>`

---

## SOT差分

**ファイル**: `docs/reports/DAY12_SOT_DIFFS.md`

**最新追記**: `<取得待ち>`

**検証結果**: Docs Link Checkワークフローで自動検証

---

## Securityタブスクショ

**SARIF表示**: YES/NO

**Artifacts**:
- gitleaks: YES/NO
- SBOM: YES/NO

**スクショ貼付**: `<ここにスクショを貼付>`

---

## 監査サマリー（JSONテンプレ）

```json
{
  "date_jst": "2025-11-09",
  "workflows": {
    "weekly_routine": {"run_id": "<RID>", "conclusion": "success"},
    "allowlist_sweep": {"run_id": "<RID>", "conclusion": "success"},
    "docs_link_check": {"run_id": "<RID>", "conclusion": "success"}
  },
  "ops_health": {"CI": "OK", "Reports": "<n>", "Gitleaks": 0, "LinkErr": 0},
  "sot_ledger": {"status": "OK", "note": "PR URL + JST時刻追記済み"},
  "security_rehardening": {
    "semgrep_rules_promoted": 2,
    "trivy_config_strict_services_on": 1
  },
  "branch_protection": {
    "required_checks": ["extended-security", "Docs Link Check"],
    "linear_history": true,
    "squash_only": true
  },
  "artifacts_proof": {
    "security_sarif": "captured",
    "weekly_artifact": "downloaded"
  }
}
```

---

## PR #39 マージ情報

**マージ時刻**: 2025-11-09T09:14:30Z  
**マージコミット**: c6ce2db26bd2e396f00582ce950af5b708f915c9  
**URL**: https://github.com/shochaso/starlist-app/pull/39

---

**作成完了時刻**: 2025-11-09  
**ステータス**: ⏳ **テンプレート作成完了（実績記録待ち）**

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
