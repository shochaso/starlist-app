# Phase 4 — 自動監査・自己修復オペレーション統合計画
**実装設計書（2025-11-14）**

---

## ファイル構成と責務表

### ワークフローファイル

#### `.github/workflows/phase4-detection-layer.yml`
**責務**: Detection Layerの統合ワークフロー
- GitHub Actionsメトリクスの異常検知
- Supabaseメトリクスの異常検知
- Slack通知の統合
- 異常検知時の自動トリガー

#### `.github/workflows/phase4-retry-engine.yml`
**責務**: Retry Engineの実装
- 自動再試行ロジック
- 422/403非再試行ポリシー
- 5xx指数バックオフ実装
- 最大3回の再試行制限

#### `.github/workflows/phase4-notification-layer.yml`
**責務**: Notification Layerの統合
- Slack通知の送信
- Issue自動生成
- Supabase挿入
- 監査票連携

#### `.github/workflows/phase4-evidence-collector.yml`
**責務**: Evidence Collectorの実装
- RUNS_SUMMARY.json自動生成
- AUTO_RETRY_MANIFEST.json自動生成
- PHASE4_AUDIT_SUMMARY.md自動生成
- 証跡ファイルの一元管理

#### `.github/workflows/phase4-kpi-tracker.yml`
**責務**: KPI Trackerの実装
- 成功率の算出
- 平均再試行回数の算出
- 処理時間の算出
- 可視化データの生成

#### `.github/workflows/phase4-rollback-engine.yml`
**責務**: Rollback Engineの実装
- ワークフロー停止機能
- Secrets解除機能
- 直前状態への復元機能
- ロールバック履歴の記録

#### `.github/workflows/phase4-killswitch.yml`
**責務**: KillSwitchの実装
- 誤作動時の強制停止機能
- ログ記録機能
- 理由記録機能
- 時刻記録機能

#### `.github/workflows/phase4-audit-generator.yml`
**責務**: Audit Generatorの実装
- 監査票生成機能
- リスク分類機能（HTTPコード別）
- 原因別分類機能
- 監査票の自動保存

#### `.github/workflows/phase4-ci-guard-enhanced.yml`
**責務**: CI Guard強化版の実装
- Phase3 guard拡張
- 再試行カウンタ内包
- 通知連動機能
- ガード違反時の自動対応

#### `.github/workflows/phase4-recovery-handler.yml`
**責務**: Recovery Handlerの実装
- 再試行完了後の状態復旧
- Slack完了報告
- 復旧履歴の記録
- 復旧結果の検証

### スクリプトファイル

#### `scripts/phase4-detection-layer.sh`
**責務**: Detection Layerのスクリプト実装
- GitHub Actionsメトリクス取得
- Supabaseメトリクス取得
- 異常検知ロジック
- 検知結果の通知

#### `scripts/phase4-retry-engine.sh`
**責務**: Retry Engineのスクリプト実装
- 再試行判定ロジック
- 指数バックオフ計算
- 再試行実行
- 再試行結果の記録

#### `scripts/phase4-evidence-collector.sh`
**責務**: Evidence Collectorのスクリプト実装
- Runメタデータ収集
- Artifact収集
- Log収集
- 証跡ファイル生成

#### `scripts/phase4-kpi-tracker.sh`
**責務**: KPI Trackerのスクリプト実装
- KPI計算ロジック
- 統計データ生成
- 可視化データ生成
- KPIレポート生成

#### `scripts/phase4-rollback-engine.sh`
**責務**: Rollback Engineのスクリプト実装
- ロールバック判定ロジック
- ワークフロー停止実行
- Secrets解除実行
- 状態復元実行

#### `scripts/phase4-killswitch.sh`
**責務**: KillSwitchのスクリプト実装
- 強制停止判定ロジック
- 強制停止実行
- ログ記録
- 理由記録

#### `scripts/phase4-audit-generator.sh`
**責務**: Audit Generatorのスクリプト実装
- 監査票生成ロジック
- リスク分類ロジック
- 監査票フォーマット
- 監査票保存

#### `scripts/phase4-evidence-sanitizer.sh`
**責務**: Evidence Sanitizerのスクリプト実装
- マスクルール適用
- token/key/secret除外
- サニタイズ結果の検証
- サニタイズ履歴の記録

#### `scripts/phase4-metrics-upserter.sh`
**責務**: Metrics Upserterのスクリプト実装
- Supabase UPSERT実装
- run_id単位の更新
- 重複防止ロジック
- UPSERT結果の検証

#### `scripts/phase4-observer-2.0.sh`
**責務**: Observer 2.0のスクリプト実装
- 7日間データ統合
- 再試行履歴統合
- ダッシュボード生成
- 統合結果の保存

#### `scripts/phase4-doc-generator.sh`
**責務**: Doc Generatorのスクリプト実装
- OPS_HEALTH_KPI.md生成
- ROLLBACK_PROTOCOL.md生成
- ドキュメント自動更新
- ドキュメント整合性検証

#### `scripts/phase4-doc-linker.sh`
**責務**: Doc Auto-Linkerのスクリプト実装
- _evidence_index.md自動同期
- RUNS_SUMMARY.json自動同期
- リンク整合性検証
- 同期結果の記録

#### `scripts/phase4-timezone-handler.sh`
**責務**: Timezone Handlerのスクリプト実装
- JSTフォルダ作成
- UTCタイムスタンプ記録
- タイムゾーン変換
- タイムスタンプ整合性検証

#### `scripts/phase4-manifest-atomicity.sh`
**責務**: Manifest Atomicityのスクリプト実装
- tmp→mv方式でatomic更新
- 重複run_id防止
- 原子性保証
- 更新結果の検証

### 設定ファイル

#### `config/phase4-retry-policy.json`
**責務**: Retry Policyの定義
- 422/403非再試行設定
- 5xx指数バックオフ設定
- 最大再試行回数設定
- 再試行間隔設定

#### `config/phase4-detection-rules.json`
**責務**: Detection Rulesの定義
- 異常検知閾値設定
- 検知条件設定
- 通知条件設定
- アクション設定

#### `config/phase4-killswitch-rules.json`
**責務**: KillSwitch Rulesの定義
- 強制停止条件設定
- 停止対象設定
- ログ記録設定
- 通知設定

#### `config/phase4-mask-rules.json`
**責務**: Mask Rulesの定義
- マスク対象パターン設定
- 除外パターン設定
- マスク方法設定
- 検証設定

### データベーススキーマ

#### `supabase/migrations/20251114_phase4_metrics.sql`
**責務**: Phase4 Metricsテーブルの定義
- run_id単位のメトリクス保存
- 再試行履歴保存
- KPIデータ保存
- 監査データ保存

#### `supabase/migrations/20251114_phase4_retry_history.sql`
**責務**: Retry Historyテーブルの定義
- 再試行履歴保存
- 再試行理由保存
- 再試行結果保存
- 再試行時刻保存

#### `supabase/migrations/20251114_phase4_killswitch_log.sql`
**責務**: KillSwitch Logテーブルの定義
- 強制停止履歴保存
- 停止理由保存
- 停止時刻保存
- 停止対象保存

### ドキュメントファイル

#### `docs/ops/PHASE4_DESIGN.md`
**責務**: Phase4設計ドキュメント
- 全体設計
- モジュール設計
- インターフェース設計
- データフロー設計

#### `docs/ops/OPS_HEALTH_KPI.md`
**責務**: OPS Health KPIドキュメント
- KPI定義
- 目標値設定
- 測定方法
- 改善計画

#### `docs/ops/ROLLBACK_PROTOCOL.md`
**責務**: Rollback Protocolドキュメント
- ロールバック手順
- ロールバック条件
- ロールバック検証
- ロールバック履歴

---

## 各モジュールの目的と関数一覧

### Detection Layer

**目的**: GitHub Actions、Supabaseメトリクス、Slackの異常を検知し、自動対応をトリガーする

**主要関数**:
- `detect_github_actions_anomalies()`: GitHub Actionsメトリクスの異常検知
- `detect_supabase_anomalies()`: Supabaseメトリクスの異常検知
- `detect_slack_anomalies()`: Slack通知の異常検知
- `trigger_auto_response()`: 異常検知時の自動対応トリガー
- `log_detection_result()`: 検知結果の記録

**入力**: GitHub Actionsメトリクス、Supabaseメトリクス、Slack通知履歴
**出力**: 異常検知結果、自動対応トリガー、検知ログ

---

### Retry Engine

**目的**: 失敗したワークフローを自動的に再試行し、成功確率を向上させる

**主要関数**:
- `should_retry()`: 再試行判定（422/403非再試行、5xx再試行）
- `calculate_backoff()`: 指数バックオフ計算
- `execute_retry()`: 再試行実行
- `track_retry_count()`: 再試行回数追跡
- `log_retry_result()`: 再試行結果の記録

**入力**: 失敗Run ID、エラーコード、再試行履歴
**出力**: 再試行実行、再試行結果、再試行履歴

**再試行ポリシー**:
- HTTP 422: 非再試行（設定エラーのため）
- HTTP 403: 非再試行（権限エラーのため）
- HTTP 500/502/503: 指数バックオフで再試行（最大3回）
- その他: 個別判定

---

### Notification Layer

**目的**: 実行結果をSlack、Issue、Supabase、監査票に通知する

**主要関数**:
- `send_slack_notification()`: Slack通知送信
- `create_github_issue()`: Issue自動生成
- `insert_supabase_record()`: Supabase挿入
- `link_audit_ticket()`: 監査票連携
- `log_notification_result()`: 通知結果の記録

**入力**: 実行結果、エラー情報、メタデータ
**出力**: Slack通知、Issue、Supabaseレコード、監査票リンク

---

### Evidence Collector

**目的**: 実行証跡を自動収集し、構造化された証跡ファイルを生成する

**主要関数**:
- `collect_run_metadata()`: Runメタデータ収集
- `collect_artifacts()`: Artifact収集
- `collect_logs()`: Log収集
- `generate_runs_summary()`: RUNS_SUMMARY.json生成
- `generate_retry_manifest()`: AUTO_RETRY_MANIFEST.json生成
- `generate_audit_summary()`: PHASE4_AUDIT_SUMMARY.md生成

**入力**: Run IDリスト、実行期間、収集条件
**出力**: RUNS_SUMMARY.json、AUTO_RETRY_MANIFEST.json、PHASE4_AUDIT_SUMMARY.md

---

### KPI Tracker

**目的**: 成功率、平均再試行回数、処理時間を算出し、可視化データを生成する

**主要関数**:
- `calculate_success_rate()`: 成功率算出
- `calculate_avg_retry_count()`: 平均再試行回数算出
- `calculate_processing_time()`: 処理時間算出
- `generate_visualization_data()`: 可視化データ生成
- `update_kpi_dashboard()`: KPIダッシュボード更新

**入力**: Run履歴、再試行履歴、実行時間データ
**出力**: KPI統計、可視化データ、ダッシュボード更新

---

### Rollback Engine

**目的**: 問題発生時にワークフローを停止し、直前状態に復元する

**主要関数**:
- `stop_workflow()`: ワークフロー停止
- `remove_secrets()`: Secrets解除
- `restore_previous_state()`: 直前状態への復元
- `log_rollback_history()`: ロールバック履歴の記録
- `verify_rollback()`: ロールバック結果の検証

**入力**: 問題発生Run ID、ロールバック対象、復元先状態
**出力**: ワークフロー停止、Secrets解除、状態復元、ロールバック履歴

---

### KillSwitch

**目的**: 誤作動時に強制停止し、ログ・理由・時刻を自動記録する

**主要関数**:
- `check_killswitch_condition()`: KillSwitch条件確認
- `execute_killswitch()`: 強制停止実行
- `log_killswitch_action()`: KillSwitchログ記録
- `record_killswitch_reason()`: 停止理由記録
- `notify_killswitch()`: KillSwitch通知

**入力**: KillSwitch条件、停止対象、停止理由
**出力**: 強制停止実行、ログ記録、理由記録、通知

---

### Audit Generator

**目的**: 監査票を自動生成し、HTTPコード別・原因別にリスク分類する

**主要関数**:
- `generate_audit_ticket()`: 監査票生成
- `classify_by_http_code()`: HTTPコード別分類
- `classify_by_cause()`: 原因別分類
- `assess_risk_level()`: リスクレベル評価
- `save_audit_ticket()`: 監査票保存

**入力**: 実行履歴、エラー情報、分類条件
**出力**: 監査票、リスク分類、リスクレベル評価

---

### CI Guard Enhanced

**目的**: Phase3 guardを拡張し、再試行カウンタ内包と通知連動を実装する

**主要関数**:
- `check_ci_guard()`: CI Guard確認
- `track_retry_counter()`: 再試行カウンタ追跡
- `trigger_notification()`: 通知連動
- `handle_guard_violation()`: Guard違反時の自動対応
- `log_guard_result()`: Guard結果の記録

**入力**: CI実行結果、再試行履歴、Guard条件
**出力**: Guard確認結果、再試行カウンタ、通知、自動対応

---

### Recovery Handler

**目的**: 再試行完了後に状態を復旧し、Slack完了報告を送信する

**主要関数**:
- `restore_state_after_retry()`: 再試行後の状態復旧
- `send_completion_report()`: Slack完了報告送信
- `log_recovery_history()`: 復旧履歴の記録
- `verify_recovery()`: 復旧結果の検証
- `update_recovery_status()`: 復旧ステータス更新

**入力**: 再試行結果、復旧対象状態、完了条件
**出力**: 状態復旧、完了報告、復旧履歴、検証結果

---

### Manifest Atomicity

**目的**: tmp→mv方式でatomic更新を実装し、重複run_idを防止する

**主要関数**:
- `create_temp_manifest()`: 一時Manifest作成
- `merge_manifest_entries()`: Manifestエントリマージ
- `validate_manifest()`: Manifest検証
- `atomic_update_manifest()`: Atomic更新実行
- `prevent_duplicate_run_id()`: 重複run_id防止

**入力**: 新しいManifestエントリ、既存Manifest、更新条件
**出力**: Atomic更新されたManifest、重複チェック結果

---

### Timezone Handler

**目的**: JSTフォルダ作成とUTCタイムスタンプ記録を両立する

**主要関数**:
- `create_jst_folder()`: JSTフォルダ作成
- `record_utc_timestamp()`: UTCタイムスタンプ記録
- `convert_timezone()`: タイムゾーン変換
- `validate_timestamp()`: タイムスタンプ整合性検証
- `format_timestamp()`: タイムスタンプフォーマット

**入力**: 実行日時、タイムゾーン設定、フォルダ構造
**出力**: JSTフォルダ、UTCタイムスタンプ、変換結果

---

### Evidence Sanitizer

**目的**: マスクルールを適用し、token/key/secretを除外する

**主要関数**:
- `apply_mask_rules()`: マスクルール適用
- `mask_sensitive_data()`: 機密データマスク
- `exclude_patterns()`: パターン除外
- `verify_sanitization()`: サニタイズ結果検証
- `log_sanitization()`: サニタイズ履歴記録

**入力**: 証跡ファイル、マスクルール、除外パターン
**出力**: サニタイズ済み証跡、検証結果、サニタイズ履歴

---

### Metrics Upserter

**目的**: Supabaseにrun_id単位でUPSERTを実装する

**主要関数**:
- `prepare_upsert_data()`: UPSERTデータ準備
- `check_duplicate_run_id()`: 重複run_id確認
- `execute_upsert()`: UPSERT実行
- `verify_upsert_result()`: UPSERT結果検証
- `log_upsert_history()`: UPSERT履歴記録

**入力**: Runメタデータ、Supabase接続情報、UPSERT条件
**出力**: UPSERT実行結果、検証結果、履歴記録

---

### Observer 2.0

**目的**: 7日間データと再試行履歴を統合し、ダッシュボードを生成する

**主要関数**:
- `collect_7day_data()`: 7日間データ収集
- `integrate_retry_history()`: 再試行履歴統合
- `generate_dashboard()`: ダッシュボード生成
- `update_dashboard_metrics()`: ダッシュボードメトリクス更新
- `save_dashboard()`: ダッシュボード保存

**入力**: 7日間実行履歴、再試行履歴、ダッシュボード設定
**出力**: 統合ダッシュボード、メトリクス更新、保存結果

---

### Governance Doc Generator

**目的**: OPS_HEALTH_KPI.mdとROLLBACK_PROTOCOL.mdを自動生成する

**主要関数**:
- `generate_ops_health_kpi()`: OPS_HEALTH_KPI.md生成
- `generate_rollback_protocol()`: ROLLBACK_PROTOCOL.md生成
- `update_documentation()`: ドキュメント自動更新
- `validate_documentation()`: ドキュメント整合性検証
- `link_documentation()`: ドキュメントリンク設定

**入力**: KPIデータ、ロールバック履歴、ドキュメントテンプレート
**出力**: OPS_HEALTH_KPI.md、ROLLBACK_PROTOCOL.md、更新結果

---

### Doc Auto-Linker

**目的**: _evidence_index.mdとRUNS_SUMMARY.jsonを自動同期する

**主要関数**:
- `sync_evidence_index()`: _evidence_index.md同期
- `sync_runs_summary()`: RUNS_SUMMARY.json同期
- `validate_link_consistency()`: リンク整合性検証
- `update_links()`: リンク更新
- `log_sync_result()`: 同期結果記録

**入力**: _evidence_index.md、RUNS_SUMMARY.json、同期条件
**出力**: 同期されたファイル、整合性検証結果、同期履歴

---

### Scheduling Layer

**目的**: cron、workflow_dispatch、self-triggerに対応する

**主要関数**:
- `schedule_cron_job()`: cronジョブスケジュール
- `handle_workflow_dispatch()`: workflow_dispatch処理
- `trigger_self()`: self-trigger実行
- `manage_schedule()`: スケジュール管理
- `log_schedule_result()`: スケジュール結果記録

**入力**: スケジュール設定、トリガー条件、実行パラメータ
**出力**: スケジュール実行、実行結果、スケジュール履歴

---

### Testing Layer

**目的**: Success、Failure、Auto-Retry、KillSwitchの統合テストを実装する

**主要関数**:
- `test_success_case()`: Successケーステスト
- `test_failure_case()`: Failureケーステスト
- `test_auto_retry()`: Auto-Retryテスト
- `test_killswitch()`: KillSwitchテスト
- `run_integration_tests()`: 統合テスト実行

**入力**: テストケース、テスト条件、期待結果
**出力**: テスト結果、テストレポート、検証結果

---

### Integration Bridge

**目的**: Phase5 API export準備として、メトリクスをREST公開する

**主要関数**:
- `prepare_api_endpoints()`: APIエンドポイント準備
- `export_metrics()`: メトリクスエクスポート
- `format_api_response()`: APIレスポンスフォーマット
- `secure_api_access()`: APIアクセスセキュリティ
- `log_api_access()`: APIアクセスログ記録

**入力**: メトリクスデータ、API設定、アクセス制御
**出力**: APIエンドポイント、メトリクスエクスポート、アクセスログ

---

## 実装タスクリスト（粒度1ファイル）

### ワークフローファイル実装タスク

1. **phase4-detection-layer.yml実装**
   - GitHub Actionsメトリクス取得ステップ
   - Supabaseメトリクス取得ステップ
   - 異常検知ロジックステップ
   - 自動対応トリガーステップ
   - 検知結果記録ステップ

2. **phase4-retry-engine.yml実装**
   - 再試行判定ステップ
   - 指数バックオフ計算ステップ
   - 再試行実行ステップ
   - 再試行回数追跡ステップ
   - 再試行結果記録ステップ

3. **phase4-notification-layer.yml実装**
   - Slack通知送信ステップ
   - Issue自動生成ステップ
   - Supabase挿入ステップ
   - 監査票連携ステップ
   - 通知結果記録ステップ

4. **phase4-evidence-collector.yml実装**
   - Runメタデータ収集ステップ
   - Artifact収集ステップ
   - Log収集ステップ
   - RUNS_SUMMARY.json生成ステップ
   - AUTO_RETRY_MANIFEST.json生成ステップ
   - PHASE4_AUDIT_SUMMARY.md生成ステップ

5. **phase4-kpi-tracker.yml実装**
   - 成功率算出ステップ
   - 平均再試行回数算出ステップ
   - 処理時間算出ステップ
   - 可視化データ生成ステップ
   - KPIダッシュボード更新ステップ

6. **phase4-rollback-engine.yml実装**
   - ワークフロー停止ステップ
   - Secrets解除ステップ
   - 状態復元ステップ
   - ロールバック履歴記録ステップ
   - ロールバック結果検証ステップ

7. **phase4-killswitch.yml実装**
   - KillSwitch条件確認ステップ
   - 強制停止実行ステップ
   - KillSwitchログ記録ステップ
   - 停止理由記録ステップ
   - KillSwitch通知ステップ

8. **phase4-audit-generator.yml実装**
   - 監査票生成ステップ
   - HTTPコード別分類ステップ
   - 原因別分類ステップ
   - リスクレベル評価ステップ
   - 監査票保存ステップ

9. **phase4-ci-guard-enhanced.yml実装**
   - CI Guard確認ステップ
   - 再試行カウンタ追跡ステップ
   - 通知連動ステップ
   - Guard違反時自動対応ステップ
   - Guard結果記録ステップ

10. **phase4-recovery-handler.yml実装**
    - 状態復旧ステップ
    - Slack完了報告ステップ
    - 復旧履歴記録ステップ
    - 復旧結果検証ステップ
    - 復旧ステータス更新ステップ

### スクリプトファイル実装タスク

11. **phase4-detection-layer.sh実装**
    - GitHub Actionsメトリクス取得関数
    - Supabaseメトリクス取得関数
    - 異常検知ロジック関数
    - 検知結果通知関数
    - 検知結果記録関数

12. **phase4-retry-engine.sh実装**
    - 再試行判定関数
    - 指数バックオフ計算関数
    - 再試行実行関数
    - 再試行回数追跡関数
    - 再試行結果記録関数

13. **phase4-evidence-collector.sh実装**
    - Runメタデータ収集関数
    - Artifact収集関数
    - Log収集関数
    - RUNS_SUMMARY.json生成関数
    - AUTO_RETRY_MANIFEST.json生成関数
    - PHASE4_AUDIT_SUMMARY.md生成関数

14. **phase4-kpi-tracker.sh実装**
    - 成功率算出関数
    - 平均再試行回数算出関数
    - 処理時間算出関数
    - 可視化データ生成関数
    - KPIダッシュボード更新関数

15. **phase4-rollback-engine.sh実装**
    - ワークフロー停止関数
    - Secrets解除関数
    - 状態復元関数
    - ロールバック履歴記録関数
    - ロールバック結果検証関数

16. **phase4-killswitch.sh実装**
    - KillSwitch条件確認関数
    - 強制停止実行関数
    - KillSwitchログ記録関数
    - 停止理由記録関数
    - KillSwitch通知関数

17. **phase4-audit-generator.sh実装**
    - 監査票生成関数
    - HTTPコード別分類関数
    - 原因別分類関数
    - リスクレベル評価関数
    - 監査票保存関数

18. **phase4-evidence-sanitizer.sh実装**
    - マスクルール適用関数
    - 機密データマスク関数
    - パターン除外関数
    - サニタイズ結果検証関数
    - サニタイズ履歴記録関数

19. **phase4-metrics-upserter.sh実装**
    - UPSERTデータ準備関数
    - 重複run_id確認関数
    - UPSERT実行関数
    - UPSERT結果検証関数
    - UPSERT履歴記録関数

20. **phase4-observer-2.0.sh実装**
    - 7日間データ収集関数
    - 再試行履歴統合関数
    - ダッシュボード生成関数
    - ダッシュボードメトリクス更新関数
    - ダッシュボード保存関数

21. **phase4-doc-generator.sh実装**
    - OPS_HEALTH_KPI.md生成関数
    - ROLLBACK_PROTOCOL.md生成関数
    - ドキュメント自動更新関数
    - ドキュメント整合性検証関数
    - ドキュメントリンク設定関数

22. **phase4-doc-linker.sh実装**
    - _evidence_index.md同期関数
    - RUNS_SUMMARY.json同期関数
    - リンク整合性検証関数
    - リンク更新関数
    - 同期結果記録関数

23. **phase4-timezone-handler.sh実装**
    - JSTフォルダ作成関数
    - UTCタイムスタンプ記録関数
    - タイムゾーン変換関数
    - タイムスタンプ整合性検証関数
    - タイムスタンプフォーマット関数

24. **phase4-manifest-atomicity.sh実装**
    - 一時Manifest作成関数
    - Manifestエントリマージ関数
    - Manifest検証関数
    - Atomic更新実行関数
    - 重複run_id防止関数

### 設定ファイル実装タスク

25. **phase4-retry-policy.json実装**
    - 422/403非再試行設定
    - 5xx指数バックオフ設定
    - 最大再試行回数設定
    - 再試行間隔設定

26. **phase4-detection-rules.json実装**
    - 異常検知閾値設定
    - 検知条件設定
    - 通知条件設定
    - アクション設定

27. **phase4-killswitch-rules.json実装**
    - 強制停止条件設定
    - 停止対象設定
    - ログ記録設定
    - 通知設定

28. **phase4-mask-rules.json実装**
    - マスク対象パターン設定
    - 除外パターン設定
    - マスク方法設定
    - 検証設定

### データベーススキーマ実装タスク

29. **20251114_phase4_metrics.sql実装**
    - run_id単位メトリクステーブル定義
    - 再試行履歴テーブル定義
    - KPIデータテーブル定義
    - 監査データテーブル定義
    - インデックス定義
    - RLSポリシー定義

30. **20251114_phase4_retry_history.sql実装**
    - 再試行履歴テーブル定義
    - 再試行理由カラム定義
    - 再試行結果カラム定義
    - 再試行時刻カラム定義
    - インデックス定義
    - RLSポリシー定義

31. **20251114_phase4_killswitch_log.sql実装**
    - 強制停止履歴テーブル定義
    - 停止理由カラム定義
    - 停止時刻カラム定義
    - 停止対象カラム定義
    - インデックス定義
    - RLSポリシー定義

### ドキュメントファイル実装タスク

32. **PHASE4_DESIGN.md実装**
    - 全体設計記述
    - モジュール設計記述
    - インターフェース設計記述
    - データフロー設計記述

33. **OPS_HEALTH_KPI.md実装**
    - KPI定義記述
    - 目標値設定記述
    - 測定方法記述
    - 改善計画記述

34. **ROLLBACK_PROTOCOL.md実装**
    - ロールバック手順記述
    - ロールバック条件記述
    - ロールバック検証記述
    - ロールバック履歴記述

---

## エラー／再試行ポリシー定義

### エラーハンドリングポリシー

#### HTTP 422: Workflow does not have 'workflow_dispatch' trigger
**分類**: 設定エラー
**再試行**: 非再試行
**対応**: workflow_dispatchがmainブランチに反映されていることを確認し、必要に応じてPRを作成してマージ

#### HTTP 403: Resource not accessible by integration
**分類**: 権限エラー
**再試行**: 非再試行
**対応**: ワークフローの権限設定を確認し、必要な権限を付与

#### HTTP 500/502/503: Internal server error
**分類**: 一時的エラー
**再試行**: 指数バックオフで再試行（最大3回）
**対応**: GitHub Statusを確認し、復旧を待ってから再試行

#### HTTP 404: Resource not found
**分類**: リソースエラー
**再試行**: 非再試行
**対応**: リソースの存在を確認し、必要に応じて作成

#### Network Timeout
**分類**: 一時的エラー
**再試行**: 指数バックオフで再試行（最大3回）
**対応**: ネットワーク接続を確認し、再試行

#### Secrets未設定エラー
**分類**: 設定エラー
**再試行**: 非再試行
**対応**: Secretsの存在を確認し、必要に応じて設定

### 再試行ポリシー

#### 再試行可能なエラー
- HTTP 500/502/503（GitHub Actionsインフラエラー）
- Network Timeout（ネットワークタイムアウト）
- Rate Limit（レート制限、指数バックオフで再試行）

#### 再試行不可能なエラー
- HTTP 422（設定エラー）
- HTTP 403（権限エラー）
- HTTP 404（リソースエラー）
- Secrets未設定エラー（設定エラー）

#### 指数バックオフ計算式
- 1回目: 5秒待機
- 2回目: 10秒待機（5秒 × 2）
- 3回目: 20秒待機（5秒 × 4）
- 最大3回まで再試行

#### 再試行条件
- エラーコードが再試行可能なエラーであること
- 再試行回数が最大回数未満であること
- 再試行間隔が経過していること

---

## 監査項目・出力ファイル名・保存階層

### 監査項目

#### 実行監査項目
- Run ID、Run URL、実行日時、実行者、実行結果、実行時間
- Artifact名、Artifactサイズ、Artifact SHA256
- Logファイル名、Logサイズ、Log内容（マスク済み）

#### 再試行監査項目
- 再試行Run ID、元のRun ID、再試行回数、再試行理由、再試行結果
- 再試行間隔、再試行時刻、再試行成功/失敗

#### エラー監査項目
- エラーコード、エラーメッセージ、エラー発生時刻、エラー発生Run ID
- エラー分類（HTTPコード別、原因別）、リスクレベル

#### KillSwitch監査項目
- KillSwitch実行時刻、実行者、停止理由、停止対象
- KillSwitchログ、KillSwitch通知結果

### 出力ファイル名

#### 証跡ファイル
- `RUNS_SUMMARY.json`: Runサマリー（全Runのメタデータ）
- `AUTO_RETRY_MANIFEST.json`: 自動再試行マニフェスト（再試行履歴）
- `PHASE4_AUDIT_SUMMARY.md`: Phase4監査サマリー（監査結果）
- `OPS_HEALTH_KPI.md`: OPS Health KPI（KPI統計）
- `ROLLBACK_PROTOCOL.md`: ロールバックプロトコル（ロールバック手順）

#### ログファイル
- `detection_log_YYYYMMDD.log`: Detection Layerログ
- `retry_log_YYYYMMDD.log`: Retry Engineログ
- `notification_log_YYYYMMDD.log`: Notification Layerログ
- `killswitch_log_YYYYMMDD.log`: KillSwitchログ

#### 監査ファイル
- `audit_ticket_YYYYMMDD_HHMMSS.json`: 監査票（JSON形式）
- `audit_ticket_YYYYMMDD_HHMMSS.md`: 監査票（Markdown形式）

### 保存階層

```
docs/reports/YYYY-MM-DD/
├── RUNS_SUMMARY.json
├── AUTO_RETRY_MANIFEST.json
├── PHASE4_AUDIT_SUMMARY.md
├── OPS_HEALTH_KPI.md
├── ROLLBACK_PROTOCOL.md
├── logs/
│   ├── detection_log_YYYYMMDD.log
│   ├── retry_log_YYYYMMDD.log
│   ├── notification_log_YYYYMMDD.log
│   └── killswitch_log_YYYYMMDD.log
├── audit_tickets/
│   ├── audit_ticket_YYYYMMDD_HHMMSS.json
│   └── audit_ticket_YYYYMMDD_HHMMSS.md
├── artifacts/
│   └── <RUN_ID>/
└── screenshots/
    └── <SCREENSHOT_NAME>.png
```

---

## 成功／失敗時の挙動定義

### 成功時の挙動

#### Detection Layer成功時
1. 異常検知結果を記録
2. 正常状態を通知（Slack、Supabase）
3. メトリクスを更新
4. 成功ログを記録

#### Retry Engine成功時
1. 再試行成功を記録
2. 元のRunを成功としてマーク
3. 再試行履歴を更新
4. 成功通知を送信（Slack、Supabase）
5. 成功ログを記録

#### Notification Layer成功時
1. 通知送信成功を記録
2. 通知履歴を更新
3. 通知結果を検証
4. 成功ログを記録

#### Evidence Collector成功時
1. 証跡ファイル生成成功を記録
2. 証跡ファイルを保存
3. 証跡ファイルの整合性を検証
4. 成功ログを記録

#### KPI Tracker成功時
1. KPI計算成功を記録
2. KPIデータを更新
3. ダッシュボードを更新
4. 成功ログを記録

### 失敗時の挙動

#### Detection Layer失敗時
1. 異常検知失敗を記録
2. 失敗理由を記録
3. 失敗通知を送信（Slack、Issue）
4. 失敗ログを記録
5. 再試行を検討（Retry Engineに委譲）

#### Retry Engine失敗時
1. 再試行失敗を記録
2. 最大再試行回数に達した場合は最終失敗としてマーク
3. 失敗通知を送信（Slack、Issue）
4. 失敗ログを記録
5. Rollback Engineに委譲を検討

#### Notification Layer失敗時
1. 通知送信失敗を記録
2. 失敗理由を記録
3. 代替通知方法を試行（Slack失敗時はIssue、Issue失敗時はログ）
4. 失敗ログを記録
5. 再試行を検討（Retry Engineに委譲）

#### Evidence Collector失敗時
1. 証跡収集失敗を記録
2. 失敗理由を記録
3. 部分的な証跡収集を試行
4. 失敗通知を送信（Slack、Issue）
5. 失敗ログを記録

#### KPI Tracker失敗時
1. KPI計算失敗を記録
2. 失敗理由を記録
3. 部分的なKPI計算を試行
4. 失敗通知を送信（Slack、Issue）
5. 失敗ログを記録

---

## RollbackとKillSwitchの仕様定義

### Rollback仕様

#### ロールバック条件
- ワークフロー実行が連続して3回失敗した場合
- 重大なエラーが発生した場合（Secrets漏洩、データ破損など）
- 手動でロールバックが指示された場合

#### ロールバック対象
- 実行中のワークフロー
- 設定されたSecrets
- 変更された設定ファイル
- 生成された証跡ファイル（必要に応じて）

#### ロールバック手順
1. ロールバック条件を確認
2. ロールバック対象を特定
3. 直前の正常状態を確認
4. ワークフローを停止
5. Secretsを解除（必要に応じて）
6. 設定ファイルを復元（必要に応じて）
7. ロールバック結果を検証
8. ロールバック履歴を記録
9. ロールバック通知を送信

#### ロールバック検証
- ワークフローが停止されていることを確認
- Secretsが解除されていることを確認（必要に応じて）
- 設定ファイルが復元されていることを確認（必要に応じて）
- システムが正常状態に戻っていることを確認

### KillSwitch仕様

#### KillSwitch条件
- 誤作動が検知された場合
- 無限ループが発生した場合
- リソース消費が異常に高い場合
- 手動でKillSwitchが指示された場合

#### KillSwitch対象
- 実行中のワークフロー
- スケジュールされたワークフロー
- 再試行中のワークフロー

#### KillSwitch手順
1. KillSwitch条件を確認
2. KillSwitch対象を特定
3. 強制停止を実行
4. 停止理由を記録
5. 停止時刻を記録
6. KillSwitchログを記録
7. KillSwitch通知を送信
8. KillSwitch結果を検証

#### KillSwitch検証
- ワークフローが停止されていることを確認
- KillSwitchログが記録されていることを確認
- KillSwitch通知が送信されていることを確認
- システムが安全な状態にあることを確認

---

## Phase5移行の前提仕様

### API Export準備

#### エンドポイント設計
- `/api/v1/metrics`: メトリクス取得エンドポイント
- `/api/v1/runs`: Run履歴取得エンドポイント
- `/api/v1/retry-history`: 再試行履歴取得エンドポイント
- `/api/v1/kpi`: KPI取得エンドポイント

#### 認証・認可
- APIキー認証
- トークンベース認証
- ロールベースアクセス制御

#### レスポンス形式
- JSON形式
- エラーレスポンス形式
- ページネーション対応

#### レート制限
- リクエスト数制限
- 時間あたりリクエスト数制限
- IPアドレスベース制限

### データエクスポート

#### エクスポート対象データ
- Runメタデータ
- 再試行履歴
- KPIデータ
- 監査データ

#### エクスポート形式
- JSON形式
- CSV形式（オプション）
- Excel形式（オプション）

#### エクスポート頻度
- リアルタイムエクスポート
- バッチエクスポート（日次、週次）

### 移行チェックリスト

- [ ] APIエンドポイントが実装されている
- [ ] 認証・認可が実装されている
- [ ] レスポンス形式が定義されている
- [ ] レート制限が実装されている
- [ ] データエクスポート機能が実装されている
- [ ] エクスポート形式が定義されている
- [ ] エクスポート頻度が定義されている
- [ ] Phase5移行ドキュメントが作成されている

---

## 実装優先順位

### Phase 4.1: 基盤実装（優先度: 高）
1. Detection Layer実装
2. Retry Engine実装
3. Notification Layer実装
4. Evidence Collector実装

### Phase 4.2: 拡張実装（優先度: 中）
5. KPI Tracker実装
6. Rollback Engine実装
7. KillSwitch実装
8. Audit Generator実装

### Phase 4.3: 統合実装（優先度: 中）
9. CI Guard Enhanced実装
10. Recovery Handler実装
11. Manifest Atomicity実装
12. Timezone Handler実装

### Phase 4.4: 最適化実装（優先度: 低）
13. Evidence Sanitizer実装
14. Metrics Upserter実装
15. Observer 2.0実装
16. Governance Doc Generator実装

### Phase 4.5: 移行準備（優先度: 低）
17. Doc Auto-Linker実装
18. Scheduling Layer実装
19. Testing Layer実装
20. Integration Bridge実装

---

## 完了宣言

**設計日**: 2025-11-14
**設計者**: IDEエージェント
**ステータス**: ✅ 設計完了

**サマリー**:
- モジュール数: 20
- ワークフローファイル数: 10
- スクリプトファイル数: 14
- 設定ファイル数: 4
- データベーススキーマ数: 3
- ドキュメントファイル数: 3

**次のステップ**:
1. Phase 4.1基盤実装から開始
2. 各モジュールの実装を順次進行
3. 統合テストを実施
4. Phase5移行準備を完了

**署名**: IDEエージェント - 2025-11-14

