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

## ポストマージ検証結果（2025-11-12）

### Release / 署名 / 凍結
- 最新タグ: v2025.11.12.1425
- Releaseワークフロー: ✅ success (Run ID: 19301134428)
- Freeze Window: ✅ 設定確認済み（現在は凍結期間中: governance test）
- 署名検証: ⚠️ タグは存在（GPG鍵がローカルにないため検証は未実施、GitHub上で確認が必要）

### Protected Tags
- UI設定: ⏳ Settings → Repository → Tags → v* を保護（要設定）
- テスト: ⏳ ローカルでのpush拒否テストは後で実施

### Backport
- ワークフロー: ✅ mainブランチにマージ済み
- 実行履歴: ✅ success (Run ID: 19301130746)
- ラベル: ⏳ backport-to-lts で自動PR生成されることを確認予定（次のPRマージ時）

### KillSwitch
- 実装: ✅ lib/src/core/config/killswitch.dart 存在確認済み
- 動作確認: ⏳ アプリ実行時に環境変数 KILL_UI=true で確認予定

### DORAメトリクス
- スクリプト: ✅ 正常に実行可能
- 生成ファイル: dora_metrics.json
- 主要数値:
  - deployment_frequency: 0.06
  - lead_time_days: 0.09
  - mttr_days: 0.09
  - change_failure_rate_percent: 40.0000

### 監査インデックス
- _index.json: ✅ docs/reports/2025-11-12/_index.json 存在確認済み
- 更新: ⏳ 自動生成ワークフローが日次で実行予定

### SLSA provenance
- ワークフロー: ⚠️ 実行済み（Run ID: 19301133810）
- 状態: ❌ failure（原因調査が必要）
- 備考: トリガーは `release: published` だが、`push` イベントで実行されている可能性
- 次のrelease作成時に再実行予定
