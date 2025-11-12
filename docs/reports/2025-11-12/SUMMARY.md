# 2025-11-12 Governance Evidence

Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## WS0. サマリ
- [x] Release生成の確定: v2025.11.12.1425 ✅
- [ ] Branch Protection Required=2本: UI確認待ち
- [ ] Linear自動遷移: STA-13 Done確認待ち

## WS1. Release & Tag 運用
- [x] 直近3件の Release と tag 一貫性点検: ✅
- [x] 証跡保存: release_check.txt ✅

## WS2. Branch Protection 監査
- [x] 監査ワークフロー手動実行: ✅
- [x] 証跡保存: required_checks.json ✅

## WS3. Secrets/Permissions 健全性
- [x] permissions棚卸し: ✅
- [x] 証跡保存: permissions_audit.md ✅

## WS4. Admin Bypass 監査
- [x] Adminマージ検知ワークフロー実行: ✅
- [x] 証跡保存: admin_bypass.csv ✅

## WS5. SBOM/CycloneDX
- [x] 週次SBOM手動実行: ✅
- [x] 証跡フォルダ準備: sbom/ ✅

## WS6. Gitleaks
- [x] 実行ログ収集準備: ✅
- [x] 証跡フォルダ準備: gitleaks/ ✅

## WS7. CI所要時間・失敗率 週報
- [x] CI週報ワークフロー実行: ✅
- [x] 証跡準備: ci_weekly_report.md ✅

## WS8. Release Notes 自動生成
- [x] 直近2リリースのNotesレビュー準備: ✅
- [x] 証跡保存: release_notes_review.md ✅

## WS9. フレークテスト先出し
- [x] E2E履歴抽出準備: ✅
- [x] 証跡保存: flaky_tests.csv ✅

## WS10. ロールバック一発検証
- [x] Playbook Dry-run: ✅
- [x] 証跡保存: revert_dryrun.log ✅

## 最終サインオフ基準

1. [x] Release v2025.11.12.1425 掲載・タグ整合: ✅
2. [ ] Branch Protection Required=2本（UI確認済）: ⏳
3. [ ] Linear STA-13 = Done（Webhook 200）: ⏳
4. [x] 監査ワークフロー（Admin/Required/SBOM/CI週報）全て成功: ✅
5. [x] docs/reports/2025-11-12/ に証跡一式が保存: ✅
