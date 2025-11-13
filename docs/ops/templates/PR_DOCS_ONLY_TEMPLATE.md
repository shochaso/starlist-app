# Docs-only PR Template

## 変更範囲

- docs/ops/** + 完了サマリー（アプリコード未変更）

## Evidence

- Logs:
  - docs/ops/audit/logs/markdownlint_YYYYMMDDHHMM.log
  - docs/ops/audit/logs/linkcheck_YYYYMMDDHHMM.log

- Screenshot (Branch Protection proof):
  - docs/ops/audit/branch_protection_ok.png

- One-Pager / Audit JSON:
  - docs/ops/UI_ONLY_PM_ONEPAGER_V2_20251109.md
  - docs/ops/audit/ui_only_pack_v2_20251109.json

## レビューチェックリスト

- [ ] docs/ops/** + ルート .md のみ（コード未変更）
- [ ] markdownlint / link-check: pass（ログ参照可）
- [ ] Branch Protection 実証スクショ確認（png）
- [ ] One-Pager / 監査JSON に Evidence 反映済
- [ ] docs-only 昇格式（paths-filter）適用済
