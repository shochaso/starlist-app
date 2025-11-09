# 最終提出テンプレ（4点）完成版

**実行日時**: 2025-11-09  
**実行者**: AI Assistant

---

## ✅ 実行完了項目

1. **ルートB実行**: 新規PR作成（`hotfix/enable-dispatch`）
   - **PR番号**: #39
   - **URL**: https://github.com/shochaso/starlist-app/pull/39
   - **状態**: 競合解消中（ワークフローファイルは`workflow_dispatch`含む）

2. **ワークフローファイル確認**: `workflow_dispatch`が含まれていることを確認
   - `weekly-routine.yml`: ✅ `workflow_dispatch`含む（hotfixブランチ）
   - `allowlist-sweep.yml`: ✅ `workflow_dispatch`含む（hotfixブランチ）

---

## 最終提出テンプレ（4点）

### 1. A/Bどちらのルートで進めたか

**ルートB**: 新規PR作成（`hotfix/enable-dispatch`）

**PR番号**: #39  
**URL**: https://github.com/shochaso/starlist-app/pull/39

**状態**: ⚠️ 競合解消中（UIでの競合解消推奨）

---

### 2. weekly / allowlist の RUN_ID と conclusion

**状態**: ⚠️ **PR #39マージ待ち**

**理由**: PR #39がマージされるまで、ワークフローファイルがmainブランチに反映されないため、`workflow_dispatch`が認識されません

**対応**: PR #39をマージ後、以下を実行してRUN_IDを取得
```bash
gh workflow run weekly-routine.yml
gh workflow run allowlist-sweep.yml
sleep 10
gh run list --limit 30 --json databaseId,name,status,conclusion,headBranch \
  --jq ".[] | select(.name|test(\"weekly|allowlist\"))" \
  | jq -r '.[] | "\(.name) RUN_ID=\(.databaseId) conclusion=\(.conclusion)"'
```

---

### 3. `.tmp_security_ui.txt`（2行：SARIF/Artifacts の YES/NO）

```
security_tab: SARIF visible (Semgrep/Gitleaks)=YES
artifacts: gitleaks/sbom downloaded=YES
```

---

### 4. `.tmp_rg_policy.txt`（1行：policy）

```
policy: migrate_to_registry
```

**`.tmp_dod.txt`（6行：DoD 6点の判定）

```
[DoD]
1) manualRefresh統一：OK
2) setFilterのみ：OK
3) 401/403→赤バッジ＋SnackBar：OK
4) 30sタイマー単一：OK
5) providers-only CI 緑＆ローカル一致：保留
6) OPSガイド単体で再現可：OK
```

---

## 次のステップ（UI操作推奨）

1. **PR #39の競合解消**: GitHub UIから競合を解消
   - URL: https://github.com/shochaso/starlist-app/pull/39
   - **重要**: ワークフローファイル（`weekly-routine.yml`、`allowlist-sweep.yml`）は**hotfixブランチのバージョン**（`workflow_dispatch`含む）を採用

2. **PR #39をマージ**: 競合解消後、**Squash and merge** を実行

3. **ワークフロー実行**: マージ後、GitHub UIから以下を実行
   - **Actions** タブ → **weekly-routine** → **Run workflow**
   - **Actions** タブ → **allowlist-sweep** → **Run workflow**

4. **RUN_ID取得**: 数分後に以下を実行
   ```bash
   gh run list --limit 30 --json databaseId,name,status,conclusion,headBranch \
     --jq ".[] | select(.name|test(\"weekly|allowlist\"))" \
     | jq -r '.[] | "\(.name) RUN_ID=\(.databaseId) conclusion=\(.conclusion)"'
   ```

---

**実行完了時刻**: 2025-11-09  
**ステータス**: ✅ **PR #39作成完了（UIでの競合解消推奨）**

