# WS10: Branch Protection設定証跡

**実行日時**: 2025-11-13
**作業者**: Cursor AI

## 設定方法

### GUI手順

1. Navigate to: https://github.com/shochaso/starlist-app/settings/branches
2. Edit protection rule for `main` branch
3. Under "Require status checks to pass before merging":
   - Add `provenance-validate` as required check
4. Save changes

### API手順

```bash
# 現在の設定確認
gh api repos/shochaso/starlist-app/branches/main/protection \
  --jq '.required_status_checks.contexts'

# 設定更新（例）
gh api repos/shochaso/starlist-app/branches/main/protection \
  -X PATCH \
  -f required_status_checks[contexts][]=build \
  -f required_status_checks[contexts][]=check \
  -f required_status_checks[contexts][]=provenance-validate
```

## 設定結果

**実行日時**: [記録待ち]
**操作者**: [記録待ち]
**設定前**: [記録待ち]
**設定後**: [記録待ち]

**Required Checks**:
- [ ] build
- [ ] check
- [ ] provenance-validate ← 追加

**状態**: ⏳ 実行待ち
