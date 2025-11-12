# Phase 3 — 手動ディスパッチ完走 & 証跡一元化
**運用指示書（2025-11-13 JST）**

---

## セクションA: 全体ロードマップ

### 目的
Phase 3 Audit Observerの手動ディスパッチを完走し、すべての証跡を一元化する。実行結果を記録し、監査要件を満たす。

### 前提条件
- mainブランチにworkflow_dispatchを含む3つのワークフローが存在
- GitHub CLI (gh) がインストール・認証済み
- 実行権限（Maintainer/Admin）を保持
- 証跡保存先ディレクトリが準備済み（docs/reports/2025-11-13/）

### ゴール
- Success/Failure/Concurrencyの各Runが最低1本ずつ実行され、証跡が記録される
- すべてのRun URL、Artifact path、Commit SHA、Manifestが記録される
- _evidence_index.mdにすべての証跡が相互リンクされる
- PHASE3_AUDIT_SUMMARY.mdに実行統計が反映される
- PR #61に承認コメントが投稿される

### リスク
- workflow_dispatchがmainブランチで認識されない（HTTP 422）
- Secretsが未設定でSupabase/Slack連携が失敗
- 並行実行時の競合によるManifest破損
- 実行時間が長く、証跡収集が不完全
- 権限不足による実行失敗

### 実行期間
- 開始: 2025-11-13 JST
- 完了目標: 2025-11-13 JST（同日完了）
- 想定作業時間: 2-3時間

---

## セクションB: 20ワークストリーム（WS01-WS20）

### WS01: main反映の事前検証

**目的**: mainブランチにworkflow_dispatchが反映されているか確認し、未反映の場合は反映手順を提示する

**前提**: 
- GitHub CLIが認証済み
- mainブランチへのアクセス権限あり

**具体ステップ**:
1. GitHub Web UIでmainブランチのワークフローファイルを確認
   - アクセス先: https://github.com/shochaso/starlist-app/blob/main/.github/workflows/slsa-provenance.yml
   - 確認項目: workflow_dispatchセクションの存在
   - 同様にprovenance-validate.ymlとphase3-audit-observer.ymlも確認
2. GitHub CLIでmainブランチのワークフローIDを確認
   - コマンド: gh workflow list --repo shochaso/starlist-app
   - 確認項目: 3つのワークフローが存在し、IDが取得できること
3. workflow_dispatchの認識確認
   - GitHub Web UIでActionsタブを開く
   - 各ワークフローの「Run workflow」ボタンが表示されることを確認
   - 表示されない場合は、mainブランチへのマージが必要

**成果物**:
- ファイル名: docs/reports/2025-11-13/WS01_MAIN_VERIFICATION.md
- 追記内容: 確認日時、確認結果、未反映の場合は反映手順

**受入基準（DoD）**:
- 3つのワークフローすべてにworkflow_dispatchが存在することを確認
- GitHub Web UIで「Run workflow」ボタンが表示されることを確認
- 確認結果がWS01_MAIN_VERIFICATION.mdに記録されている

**想定リスクと即応**:
- リスク: workflow_dispatchが未反映
- 即応: featureブランチからmainブランチへのPRを作成し、マージを依頼

---

### WS02: 成功ケース（GUI/CLI）の運用手順

**目的**: 成功ケースをGUIまたはCLIで実行し、実行結果を記録する

**前提**:
- WS01が完了し、workflow_dispatchが認識されている
- 実行権限を保持している

**具体ステップ**:
1. GUI実行（推奨）
   - GitHub Web UIでActionsタブを開く
   - slsa-provenanceワークフローを選択
   - 「Run workflow」ボタンをクリック
   - Branch: mainを選択
   - Tag入力欄に「vtest-success-20251113」と入力
   - 「Run workflow」ボタンをクリック
   - Run IDを記録（URLから取得）
2. CLI実行（代替）
   - ターミナルでGitHub CLIコマンドを実行
   - コマンド: gh workflow run slsa-provenance.yml --repo shochaso/starlist-app --ref main -f tag="vtest-success-20251113"
   - 実行後、5秒待機
   - 最新のRun IDを取得: gh run list --workflow slsa-provenance.yml --limit 1 --json databaseId -q '.[0].databaseId'
3. 実行完了待機
   - GitHub Web UIでRunの完了を確認（約2-3分）
   - またはCLIで監視: gh run watch <RUN_ID>
4. 実行結果記録
   - Run URLを記録
   - Conclusion（success/failure）を記録
   - 実行時間を記録

**成果物**:
- ファイル名: docs/reports/2025-11-13/WS02_SUCCESS_CASE.md
- 追記内容: Run ID、Run URL、Tag、実行日時（UTC/JST）、Conclusion、実行時間

**受入基準（DoD）**:
- Success Runが1本以上実行されている
- Run URLが記録されている
- Conclusionがsuccessである
- 実行結果がWS02_SUCCESS_CASE.mdに記録されている

**想定リスクと即応**:
- リスク: HTTP 422エラー（workflow_dispatch未認識）
- 即応: GUI実行に切り替え、またはmainブランチへのマージを確認
- リスク: 実行失敗（Conclusionがfailure）
- 即応: ログを確認し、WS03の失敗ケースとして記録

---

### WS03: 失敗ケース（意図的・無害）と復帰手順

**目的**: 意図的な失敗ケースを実行し、失敗時の動作を検証する。実行後は即座に復帰する

**前提**:
- WS02が完了している
- 失敗ケースの実行が安全であることを確認

**具体ステップ**:
1. 失敗ケース実行準備
   - 失敗を引き起こす安全なパラメータを選択（例: 存在しないTag名）
   - Tag名: "vtest-fail-20251113-nonexistent"を準備
2. 失敗ケース実行
   - GUIまたはCLIで実行
   - Tag入力欄に失敗を引き起こすTag名を入力
   - 実行を開始
3. 失敗確認
   - Runの完了を待機
   - Conclusionがfailureであることを確認
   - エラーメッセージを確認
4. 失敗ログ記録
   - Run URLを記録
   - エラーメッセージを記録（機密情報はマスク）
   - 失敗理由を記録
5. 復帰手順
   - 失敗ケースは意図的なため、特別な復帰は不要
   - 正常系の実行（WS02）が成功していることを確認
   - 必要に応じて、失敗ケースのRunをキャンセル（実行中の場合）

**成果物**:
- ファイル名: docs/reports/2025-11-13/WS03_FAILURE_CASE.md
- 追記内容: Run ID、Run URL、Tag、実行日時、Conclusion、エラーメッセージ、失敗理由

**受入基準（DoD）**:
- Failure Runが1本以上実行されている
- Run URLが記録されている
- Conclusionがfailureである
- エラーメッセージが記録されている（機密情報はマスク）
- 実行結果がWS03_FAILURE_CASE.mdに記録されている

**想定リスクと即応**:
- リスク: 意図しない失敗（システムエラー）
- 即応: ログを確認し、システムエラーと意図的失敗を区別。システムエラーの場合は再実行を検討
- リスク: 失敗ケースが成功してしまう
- 即応: 別の失敗パターンを試すか、失敗ケースの設計を見直す

---

### WS04: 並行実行（2～3本）の観測と衝突回避

**目的**: 2～3本のワークフローを並行実行し、Concurrency制御が正常に機能することを確認する

**前提**:
- WS02が完了している
- Concurrency設定がワークフローに含まれている

**具体ステップ**:
1. 並行実行準備
   - 3つの異なるTag名を準備（例: vtest-conc-1-20251113, vtest-conc-2-20251113, vtest-conc-3-20251113）
   - 実行順序を記録するためのタイムスタンプを取得
2. 並行実行開始
   - GUIの場合: 3つのブラウザタブを開き、ほぼ同時に実行開始
   - CLIの場合: 3つのコマンドをバックグラウンドで実行
   - 各実行の開始時刻を記録
3. 実行状況観測
   - 5秒ごとに実行状況を確認
   - 各Runのステータス（queued/running/completed）を記録
   - 実行順序を確認（1つずつ処理されることを確認）
4. Manifest追記の衝突回避確認
   - 各Runが完了したら、Manifestファイルを確認
   - 重複エントリがないことを確認
   - 原子的更新（tmp→mv）が正常に機能していることを確認
5. 実行結果記録
   - 3つのRun IDを記録
   - 実行順序を記録
   - 各Runの実行時間を記録
   - Manifestの整合性を記録

**成果物**:
- ファイル名: docs/reports/2025-11-13/WS04_CONCURRENCY_CASE.md
- 追記内容: 3つのRun ID、Run URL、実行順序、各Runの実行時間、Manifest整合性確認結果

**受入基準（DoD）**:
- 3本のRunが並行実行されている
- 実行順序が記録されている
- 各Runが1つずつ処理されている（Concurrency制御が機能）
- Manifestに重複エントリがない
- 実行結果がWS04_CONCURRENCY_CASE.mdに記録されている

**想定リスクと即応**:
- リスク: Manifestの競合による破損
- 即応: Manifestファイルをバックアップし、競合が発生した場合は復元。原子的更新の運用ルールを確認
- リスク: 並行実行が同時に処理される（Concurrency制御が機能しない）
- 即応: ワークフローのConcurrency設定を確認し、必要に応じて修正

---

### WS05: Run/Artifact/Log収集（保存粒度・命名規約・配置パス）

**目的**: すべてのRunからArtifactとLogを収集し、適切な粒度・命名規約・配置パスで保存する

**前提**:
- WS02-WS04が完了し、Run IDが記録されている
- 証跡保存先ディレクトリが準備済み

**具体ステップ**:
1. 収集対象のRun IDリスト作成
   - WS02-WS04で記録したRun IDをリストアップ
   - 各Runの種類（Success/Failure/Concurrency）を記録
2. Artifact収集
   - 各Run IDに対してArtifactをダウンロード
   - 保存先: docs/reports/2025-11-13/artifacts/<RUN_ID>/
   - 命名規約: 元のArtifact名を保持
   - サイズを記録
3. Log収集
   - 各Run IDに対してLogをダウンロード
   - 保存先: docs/reports/2025-11-13/logs/run_<RUN_ID>.log
   - 機密情報（Secrets値）はマスク
4. Runメタデータ収集
   - Run ID、URL、Head SHA、実行日時、Conclusion、実行時間を記録
   - 保存先: docs/reports/2025-11-13/RUNS_METADATA.json
   - JSON形式で保存
5. 収集結果確認
   - すべてのArtifactがダウンロードされていることを確認
   - すべてのLogがダウンロードされていることを確認
   - メタデータが正確に記録されていることを確認

**成果物**:
- ファイル名: 
  - docs/reports/2025-11-13/artifacts/<RUN_ID>/*（Artifactファイル）
  - docs/reports/2025-11-13/logs/run_<RUN_ID>.log（Logファイル）
  - docs/reports/2025-11-13/RUNS_METADATA.json（メタデータ）
- 追記内容: 収集日時、収集者、収集対象Run IDリスト、収集結果サマリー

**受入基準（DoD）**:
- すべてのRunのArtifactが収集されている
- すべてのRunのLogが収集されている
- メタデータがJSON形式で記録されている
- 命名規約と配置パスが統一されている
- 収集結果がWS05_COLLECTION.mdに記録されている

**想定リスクと即応**:
- リスク: Artifactのダウンロード失敗
- 即応: 再試行。失敗が続く場合は、GitHub Web UIから手動ダウンロード
- リスク: Logファイルが大きすぎる
- 即応: 必要な部分のみ抽出し、完全なLogは別途保存

---

### WS06: SHA検証（実ファイルと報告ハッシュの一致確認フロー）

**目的**: 収集したArtifactファイルのSHA256ハッシュを計算し、Provenanceファイル内のメタデータと一致することを確認する

**前提**:
- WS05が完了し、Artifactが収集されている
- Provenance JSONファイルが存在する

**具体ステップ**:
1. Provenanceファイル特定
   - 各RunのArtifactディレクトリからProvenance JSONファイルを特定
   - ファイル名パターン: provenance-*.json
2. 実ファイルのSHA256計算
   - 各Provenanceファイルに対してSHA256ハッシュを計算
   - コマンド: shasum -a 256 <FILE_PATH>
   - 計算結果を記録
3. メタデータからのSHA256取得
   - Provenance JSONファイルを開く
   - metadata.content_sha256フィールドを取得
   - 取得結果を記録
4. 一致確認
   - 実ファイルのSHA256とメタデータのSHA256を比較
   - 一致する場合はOK、不一致の場合はNGを記録
5. PredicateType確認
   - Provenance JSONファイルからpredicateTypeフィールドを取得
   - 期待値: https://slsa.dev/provenance/v0.2
   - 一致することを確認
6. 検証結果記録
   - 各Runの検証結果を表形式で記録
   - Run ID、Tag、実ファイルSHA256、メタデータSHA256、一致結果、PredicateTypeを記録

**成果物**:
- ファイル名: docs/reports/2025-11-13/WS06_SHA_VALIDATION.md
- 追記内容: 検証日時、検証者、各Runの検証結果表、一致/不一致のサマリー

**受入基準（DoD）**:
- すべてのProvenanceファイルのSHA256が計算されている
- メタデータからのSHA256が取得されている
- 一致確認が完了している
- PredicateTypeが期待値と一致している
- 検証結果がWS06_SHA_VALIDATION.mdに記録されている

**想定リスクと即応**:
- リスク: SHA256が不一致
- 即応: Artifactファイルの破損を確認。再ダウンロードを試行。不一致が続く場合は、ワークフローの問題を調査
- リスク: PredicateTypeが期待値と不一致
- 即応: ワークフローの設定を確認し、必要に応じて修正

---

### WS07: Manifest追記（原子的更新の運用ルール）

**目的**: Manifestファイルに新しいRunエントリを原子的に追記する。競合を回避し、データ整合性を保つ

**前提**:
- WS02-WS04が完了し、Run IDが記録されている
- Manifestファイルが存在する（存在しない場合は初期化）

**具体ステップ**:
1. Manifestファイル確認
   - ファイルパス: docs/reports/2025-11-13/_manifest.json
   - 既存のエントリを確認
   - JSON形式が正しいことを確認
2. 新しいエントリ作成
   - Run ID、Tag、SHA256、Run URL、作成日時を含むエントリを作成
   - JSON形式で作成
3. 原子的更新実行
   - 一時ファイル（_manifest.json.tmp）に新しいエントリを追加
   - 既存のエントリと新しいエントリをマージ
   - JSON形式が正しいことを確認
   - 一時ファイルを正式ファイルに移動（mvコマンド）
   - これにより、原子的更新が保証される
4. 更新結果確認
   - Manifestファイルを開き、新しいエントリが追加されていることを確認
   - JSON形式が正しいことを確認
   - 重複エントリがないことを確認
5. 更新履歴記録
   - 更新日時、更新者、追加されたエントリ数を記録

**成果物**:
- ファイル名: docs/reports/2025-11-13/_manifest.json
- 追記内容: 新しいRunエントリ（Run ID、Tag、SHA256、Run URL、作成日時）

**受入基準（DoD）**:
- Manifestファイルが原子的に更新されている
- 新しいエントリが追加されている
- JSON形式が正しい
- 重複エントリがない
- 更新履歴がWS07_MANIFEST_UPDATE.mdに記録されている

**想定リスクと即応**:
- リスク: 並行更新による競合
- 即応: 原子的更新（tmp→mv）の運用ルールを遵守。競合が発生した場合は、Manifestファイルをバックアップし、手動でマージ
- リスク: JSON形式エラー
- 即応: JSON形式を確認し、エラーを修正。必要に応じて、JSONバリデーションツールを使用

---

### WS08: Slack抜粋のマスキング方針

**目的**: Slack通知のログから機密情報をマスクし、HTTPコード、時刻、短い要約のみを記録する

**前提**:
- WS03が完了し、失敗ケースのLogが収集されている
- Slack Webhook URLが設定されている（設定されていない場合はスキップ）

**具体ステップ**:
1. LogファイルからSlack関連ログ抽出
   - 失敗ケースのLogファイルを開く
   - "slack"、"webhook"、"POST"などのキーワードで検索
   - 該当する行を抽出
2. 機密情報マスキング
   - Webhook URLをマスク（例: https://hooks.slack.com/services/***/***/***）
   - トークンや認証情報をマスク
   - HTTPリクエストボディの機密情報をマスク
3. 記録対象情報抽出
   - HTTPステータスコード（200、400、500など）
   - タイムスタンプ（実行時刻）
   - 短い要約（成功/失敗、エラーメッセージの要約）
4. 抜粋ファイル作成
   - 保存先: docs/reports/2025-11-13/slack_excerpts/<RUN_ID>.log
   - マスク済みのログ抜粋を保存
   - HTTPコード、時刻、要約を含む
5. 抜粋結果確認
   - 機密情報がマスクされていることを確認
   - 必要な情報（HTTPコード、時刻、要約）が含まれていることを確認

**成果物**:
- ファイル名: docs/reports/2025-11-13/slack_excerpts/<RUN_ID>.log
- 追記内容: マスク済みSlackログ抜粋（HTTPコード、時刻、要約）

**受入基準（DoD）**:
- Slackログが抽出されている
- 機密情報がマスクされている
- HTTPコード、時刻、要約が記録されている
- 抜粋ファイルが作成されている
- マスキング結果がWS08_SLACK_EXCERPT.mdに記録されている

**想定リスクと即応**:
- リスク: 機密情報の漏洩
- 即応: マスキングルールを厳格に適用。漏洩が疑われる場合は、抜粋ファイルを削除し、再作成
- リスク: Slack Webhook URLが未設定
- 即応: Slack抜粋をスキップし、WS08_SLACK_EXCERPT.mdに「Slack Webhook URL未設定のためスキップ」と記録

---

### WS09: Secrets前提チェック（存在確認・誰が確認するか・ログ方針）

**目的**: 必須Secretsの存在を確認し、未設定の場合は是正手順を提示する

**前提**:
- GitHub CLIが認証済み
- Secrets確認権限を保持

**具体ステップ**:
1. 必須Secretsリスト作成
   - SUPABASE_URL（必須）
   - SUPABASE_SERVICE_KEY（必須）
   - SLACK_WEBHOOK_URL（オプション）
2. Secrets存在確認
   - GitHub Web UIで確認: Settings → Secrets and variables → Actions
   - またはCLIで確認: gh secret list --repo shochaso/starlist-app
   - 各Secretの存在を確認（値は表示しない）
3. 確認結果記録
   - 各Secretの存在/不存在を記録
   - 存在する場合は作成日時を記録
   - 存在しない場合は是正手順を記録
4. 確認者記録
   - 確認者の名前を記録
   - 確認日時を記録
5. ログ方針確認
   - Secretsの値は一切ログに出力しない
   - 存在/不存在のみを記録
   - 是正手順は別ファイルに記録

**成果物**:
- ファイル名: docs/reports/2025-11-13/WS09_SECRETS_CHECK.md
- 追記内容: 確認日時、確認者、各Secretの存在/不存在、是正手順（未設定の場合）

**受入基準（DoD）**:
- すべての必須Secretsの存在が確認されている
- 存在/不存在が記録されている
- 未設定の場合は是正手順が記録されている
- Secretsの値がログに出力されていない
- 確認結果がWS09_SECRETS_CHECK.mdに記録されている

**想定リスクと即応**:
- リスク: Secretsが未設定
- 即応: 是正手順を提示し、Secrets設定を依頼。設定完了まで実行を保留
- リスク: Secretsの値がログに出力される
- 即応: ログを確認し、値が出力されている場合は、ログを削除し、再実行

---

### WS10: Branch Protection確認（strict=trueの運用手順）

**目的**: Branch Protection設定を確認し、provenance-validateがRequired Checkとして設定されていることを確認する

**前提**:
- GitHub Web UIへのアクセス権限あり
- Branch Protection設定権限あり（確認のみの場合は読み取り権限で可）

**具体ステップ**:
1. Branch Protection設定画面アクセス
   - GitHub Web UIでSettings → Branchesを開く
   - mainブランチの保護ルールを確認
2. Required Checks確認
   - "Require status checks to pass before merging"が有効であることを確認
   - Required checksリストに"provenance-validate"が含まれていることを確認
3. Strict Mode確認
   - "Require branches to be up to date before merging"が有効であることを確認
   - これがstrict=trueに相当
4. Admin Bypass確認
   - "Do not allow bypassing the above settings"が有効であることを確認
   - Adminもチェックを必須とする設定
5. 設定結果記録
   - 設定日時を記録
   - 設定者を記録（可能な場合）
   - 設定内容を記録

**成果物**:
- ファイル名: docs/reports/2025-11-13/WS10_BRANCH_PROTECTION.md
- 追記内容: 確認日時、確認者、設定内容、provenance-validateの存在確認結果

**受入基準（DoD）**:
- Branch Protectionが有効であることを確認
- provenance-validateがRequired Checkとして設定されていることを確認
- Strict Modeが有効であることを確認
- Admin Bypassが無効であることを確認
- 確認結果がWS10_BRANCH_PROTECTION.mdに記録されている

**想定リスクと即応**:
- リスク: Branch Protectionが未設定
- 即応: Branch Protection設定手順を提示し、設定を依頼。設定完了まで実行を保留
- リスク: provenance-validateがRequired Checkに含まれていない
- 即応: Required Checkにprovenance-validateを追加する手順を提示

---

### WS11: Observer手動実行の運用（window/集計範囲の決め方）

**目的**: Phase 3 Audit Observerを手動実行し、集計範囲とwindowを適切に設定する

**前提**:
- WS02-WS04が完了し、Run IDが記録されている
- phase3-audit-observerワークフローが存在する

**具体ステップ**:
1. 集計範囲決定
   - 対象期間を決定（例: 2025-11-13 00:00 JST ～ 2025-11-13 23:59 JST）
   - 対象ワークフローを決定（slsa-provenance、provenance-validate）
   - 対象Run IDを決定（WS02-WS04で記録したRun ID）
2. Observer実行
   - GUIまたはCLIで実行
   - 入力パラメータ:
     - provenance_run_id: Success RunのID
     - validation_run_id: Validation RunのID（存在する場合）
     - pr_number: 61（PR #61にコメントを投稿する場合）
3. 実行完了待機
   - Runの完了を待機（約1-2分）
   - Conclusionがsuccessであることを確認
4. 集計結果確認
   - Observerが生成したサマリーを確認
   - 集計範囲内のRunがすべて含まれていることを確認
   - KPI（成功率、実行時間など）が計算されていることを確認
5. 実行結果記録
   - Observer Run IDを記録
   - 集計範囲を記録
   - 集計結果を記録

**成果物**:
- ファイル名: docs/reports/2025-11-13/WS11_OBSERVER_EXECUTION.md
- 追記内容: 実行日時、実行者、集計範囲、Observer Run ID、集計結果

**受入基準（DoD）**:
- Observerが実行されている
- 集計範囲が明確に定義されている
- 集計結果が記録されている
- Observer Run IDが記録されている
- 実行結果がWS11_OBSERVER_EXECUTION.mdに記録されている

**想定リスクと即応**:
- リスク: Observer実行失敗
- 即応: ログを確認し、エラー原因を特定。必要に応じて、入力パラメータを修正し、再実行
- リスク: 集計範囲外のRunが含まれる
- 即応: 集計範囲を再確認し、必要に応じて、Observerの設定を修正

---

### WS12: Supabase記録の検収（挿入可否・重複抑止の確認観点）

**目的**: Supabaseへの記録が正常に挿入されていることを確認し、重複エントリがないことを確認する

**前提**:
- WS02-WS04が完了し、Run IDが記録されている
- SUPABASE_URLとSUPABASE_SERVICE_KEYが設定されている
- Supabaseへのアクセス権限あり

**具体ステップ**:
1. Supabase接続確認
   - Supabase Dashboardにアクセス
   - 接続が正常であることを確認
2. テーブル確認
   - slsa_runsテーブルを確認
   - テーブル構造を確認
3. 記録確認
   - WS02-WS04で記録したRun IDがSupabaseに存在することを確認
   - 各Runの記録内容（Run ID、Tag、SHA256、Statusなど）が正確であることを確認
4. 重複確認
   - 同じRun IDが複数回記録されていないことを確認
   - 重複エントリがないことを確認
5. 検収結果記録
   - 検収日時を記録
   - 検収者を記録
   - 記録されたRun IDリストを記録
   - 重複エントリの有無を記録

**成果物**:
- ファイル名: docs/reports/2025-11-13/WS12_SUPABASE_VERIFICATION.md
- 追記内容: 検収日時、検収者、記録されたRun IDリスト、重複エントリの有無、検収結果

**受入基準（DoD）**:
- Supabaseへの記録が確認されている
- すべてのRun IDが記録されている
- 重複エントリがない
- 記録内容が正確である
- 検収結果がWS12_SUPABASE_VERIFICATION.mdに記録されている

**想定リスクと即応**:
- リスク: Supabase接続失敗
- 即応: 接続情報を確認し、必要に応じて、Secretsを再設定。接続が復旧するまで実行を保留
- リスク: 重複エントリが存在する
- 即応: 重複エントリを特定し、原因を調査。必要に応じて、重複エントリを削除

---

### WS13: 失敗時の一次切り分け（トークンスコープ/権限/Ref/Inputs）

**目的**: 実行失敗時の原因を一次切り分けし、トークンスコープ、権限、Ref、Inputsの観点から問題を特定する

**前提**:
- WS03が完了し、失敗ケースが記録されている
- 失敗Runのログが収集されている

**具体ステップ**:
1. 失敗ログ確認
   - 失敗Runのログを開く
   - エラーメッセージを確認
2. トークンスコープ確認
   - エラーメッセージに"token"、"scope"、"permission"などのキーワードが含まれているか確認
   - トークンスコープ不足が原因の場合は、必要なスコープを特定
3. 権限確認
   - エラーメッセージに"permission"、"access"、"forbidden"などのキーワードが含まれているか確認
   - 権限不足が原因の場合は、必要な権限を特定
4. Ref確認
   - 実行時に指定したRef（ブランチ名）が存在するか確認
   - Refが存在しない場合は、正しいRefを特定
5. Inputs確認
   - 実行時に指定したInputs（Tagなど）が正しいか確認
   - Inputsが不正な場合は、正しいInputsを特定
6. 切り分け結果記録
   - 失敗原因を記録
   - 切り分け観点（トークンスコープ/権限/Ref/Inputs）を記録
   - 是正手順を記録

**成果物**:
- ファイル名: docs/reports/2025-11-13/WS13_FAILURE_TROUBLESHOOTING.md
- 追記内容: 失敗Run ID、エラーメッセージ、切り分け結果、是正手順

**受入基準（DoD）**:
- 失敗原因が特定されている
- 切り分け観点が明確である
- 是正手順が記録されている
- 切り分け結果がWS13_FAILURE_TROUBLESHOOTING.mdに記録されている

**想定リスクと即応**:
- リスク: 失敗原因が特定できない
- 即応: ログを詳細に確認し、必要に応じて、GitHub Supportに問い合わせ
- リスク: 複数の原因が絡み合っている
- 即応: 各原因を個別に確認し、優先順位をつけて対処

---

### WS14: リトライ設計（再試行の要否判定表・禁止条件）

**目的**: 実行失敗時のリトライ要否を判定し、リトライ可能な場合と禁止条件を明確にする

**前提**:
- WS13が完了し、失敗原因が特定されている

**具体ステップ**:
1. リトライ要否判定表作成
   - 失敗原因ごとにリトライ要否を判定
   - リトライ可能な失敗: 一時的なネットワークエラー、GitHub Actionsの一時的な障害
   - リトライ禁止の失敗: 設定エラー、権限不足、無効なInputs
2. リトライ禁止条件明確化
   - 設定エラー: ワークフロー設定が不正な場合
   - 権限不足: 必要な権限が不足している場合
   - 無効なInputs: 入力パラメータが不正な場合
   - 意図的な失敗: テスト目的で意図的に失敗させた場合
3. リトライ実行手順作成
   - リトライ可能な場合の実行手順を記録
   - リトライ間隔（例: 5分後）を記録
   - 最大リトライ回数（例: 3回）を記録
4. リトライ結果記録
   - リトライ実行日時を記録
   - リトライ結果（成功/失敗）を記録
   - リトライ回数を記録

**成果物**:
- ファイル名: docs/reports/2025-11-13/WS14_RETRY_DESIGN.md
- 追記内容: リトライ要否判定表、リトライ禁止条件、リトライ実行手順、リトライ結果

**受入基準（DoD）**:
- リトライ要否判定表が作成されている
- リトライ禁止条件が明確である
- リトライ実行手順が記録されている
- リトライ結果がWS14_RETRY_DESIGN.mdに記録されている

**想定リスクと即応**:
- リスク: リトライ禁止条件を誤ってリトライしてしまう
- 即応: リトライ要否判定表を厳格に適用。禁止条件の場合はリトライしない
- リスク: リトライが無限ループになる
- 即応: 最大リトライ回数を設定し、超過した場合はリトライを停止

---

### WS15: 時刻・日付命名規約（JST/UTCの扱い・日付フォルダ粒度）

**目的**: 時刻・日付の命名規約を明確にし、JST/UTCの扱いと日付フォルダの粒度を統一する

**前提**:
- 証跡ファイルの命名が必要

**具体ステップ**:
1. 時刻形式決定
   - UTC形式: 2025-11-13T01:00:00Z（ISO 8601形式）
   - JST形式: 2025-11-13 10:00:00+09:00（ISO 8601形式、タイムゾーン明示）
   - 両方を記録する場合: UTC / JSTの形式で併記
2. 日付フォルダ粒度決定
   - 日単位: docs/reports/2025-11-13/
   - すべての証跡を日付フォルダに配置
3. ファイル命名規約決定
   - パターン: WS<番号>_<目的>_<日付>.md
   - 例: WS02_SUCCESS_CASE_20251113.md
   - 日付はYYYYMMDD形式（UTC基準）
4. 命名規約適用
   - 既存ファイルの命名を確認
   - 命名規約に従っていない場合は、リネームを検討
5. 命名規約文書化
   - 命名規約を文書化
   - 運用ルールとして記録

**成果物**:
- ファイル名: docs/reports/2025-11-13/WS15_NAMING_CONVENTION.md
- 追記内容: 時刻形式、日付フォルダ粒度、ファイル命名規約、適用結果

**受入基準（DoD）**:
- 時刻形式が明確である
- JST/UTCの扱いが統一されている
- 日付フォルダ粒度が統一されている
- ファイル命名規約が明確である
- 命名規約がWS15_NAMING_CONVENTION.mdに記録されている

**想定リスクと即応**:
- リスク: 時刻形式が統一されていない
- 即応: 命名規約を厳格に適用し、既存ファイルも規約に従うよう修正
- リスク: 日付フォルダが複数作成される
- 即応: 日付フォルダ粒度を統一し、証跡を適切なフォルダに配置

---

### WS16: PR #61 への承認コメント雛形（要約/リンク/KPI）

**目的**: PR #61に承認コメントを投稿し、要約、リンク、KPIを含める

**前提**:
- WS02-WS11が完了し、すべての証跡が記録されている
- PR #61が存在する

**具体ステップ**:
1. コメント内容作成
   - 要約: Phase 3 Audit Observerの手動ディスパッチが完了したことを要約
   - リンク: 主要な証跡ファイルへのリンクを追加
   - KPI: 実行統計（成功率、実行時間など）を追加
2. コメント投稿
   - GitHub Web UIでPR #61を開く
   - コメント欄にコメントを投稿
   - またはCLIで投稿: gh pr comment 61 --repo shochaso/starlist-app --body "<コメント内容>"
3. コメントURL記録
   - 投稿したコメントのURLを記録
   - コメントIDを記録
4. コメント内容確認
   - コメントが正しく投稿されていることを確認
   - リンクが有効であることを確認

**成果物**:
- ファイル名: docs/reports/2025-11-13/WS16_PR_COMMENT.md
- 追記内容: コメント投稿日時、コメントURL、コメント内容、KPI

**受入基準（DoD）**:
- PR #61にコメントが投稿されている
- コメントに要約、リンク、KPIが含まれている
- コメントURLが記録されている
- コメント内容がWS16_PR_COMMENT.mdに記録されている

**想定リスクと即応**:
- リスク: PR #61が存在しない
- 即応: PR #61の存在を確認。存在しない場合は、コメント投稿をスキップ
- リスク: コメント投稿失敗
- 即応: 権限を確認し、必要に応じて、権限のあるユーザーに依頼

---

### WS17: レビュー観点表（セキュリティ/監査/再現性/可逆性）

**目的**: 証跡のレビュー観点を明確にし、セキュリティ、監査、再現性、可逆性の観点から確認する

**前提**:
- WS02-WS16が完了し、すべての証跡が記録されている

**具体ステップ**:
1. セキュリティ観点確認
   - 機密情報（Secrets値）がマスクされていることを確認
   - ログに機密情報が含まれていないことを確認
   - アクセス権限が適切であることを確認
2. 監査観点確認
   - すべてのRunが記録されていることを確認
   - 実行日時が記録されていることを確認
   - 実行者が記録されていることを確認
3. 再現性観点確認
   - 実行手順が記録されていることを確認
   - 入力パラメータが記録されていることを確認
   - 実行環境が記録されていることを確認
4. 可逆性観点確認
   - ロールバック手順が記録されていることを確認
   - 復元手順が記録されていることを確認
   - 変更履歴が記録されていることを確認
5. レビュー結果記録
   - 各観点の確認結果を記録
   - 問題点があれば記録
   - 是正手順があれば記録

**成果物**:
- ファイル名: docs/reports/2025-11-13/WS17_REVIEW_CHECKLIST.md
- 追記内容: レビュー日時、レビュー者、各観点の確認結果、問題点、是正手順

**受入基準（DoD）**:
- セキュリティ観点が確認されている
- 監査観点が確認されている
- 再現性観点が確認されている
- 可逆性観点が確認されている
- レビュー結果がWS17_REVIEW_CHECKLIST.mdに記録されている

**想定リスクと即応**:
- リスク: 機密情報が漏洩している
- 即応: 機密情報をマスクし、漏洩したファイルを削除。必要に応じて、Secretsを再設定
- リスク: 再現性が確保されていない
  即応: 実行手順を詳細に記録し、再現可能な状態にする

---

### WS18: 監査スクショ指示書（構図/不足時の代替証跡）

**目的**: 監査用スクリーンショットの撮影指示を作成し、構図と不足時の代替証跡を明確にする

**前提**:
- スクリーンショット撮影が可能

**具体ステップ**:
1. 撮影対象画面決定
   - GitHub Actions Checks Tab
   - Artifacts Download画面
   - Slack通知画面（設定されている場合）
   - Secrets Settings画面
   - Branch Protection Settings画面
2. 構図指示作成
   - 各画面の構図を明確に指示
   - 必要な情報が表示されていることを確認
   - 不要な情報をマスク
3. 保存先決定
   - 保存先: docs/reports/2025-11-13/screenshots/
   - ファイル名: <画面名>_<日付>.png
4. 代替証跡準備
   - スクリーンショットが撮影できない場合の代替証跡を準備
   - 例: ログ出力、テキスト記録
5. 撮影結果確認
   - スクリーンショットが正しく撮影されていることを確認
   - 必要な情報が含まれていることを確認

**成果物**:
- ファイル名: docs/reports/2025-11-13/screenshots/<画面名>_<日付>.png
- 追記内容: 撮影日時、撮影者、構図説明、代替証跡（撮影できない場合）

**受入基準（DoD）**:
- 主要な画面のスクリーンショットが撮影されている
- 構図が適切である
- 代替証跡が準備されている（撮影できない場合）
- 撮影結果がWS18_SCREENSHOTS.mdに記録されている

**想定リスクと即応**:
- リスク: スクリーンショットが撮影できない
- 即応: 代替証跡（ログ出力、テキスト記録）を使用
- リスク: 機密情報がスクリーンショットに含まれる
- 即応: 機密情報をマスクし、必要に応じて、スクリーンショットを再撮影

---

### WS19: 運用継続SOP（週次点検・棚卸し・古い証跡の保持方針）

**目的**: 運用継続のためのSOPを作成し、週次点検、棚卸し、古い証跡の保持方針を明確にする

**前提**:
- Phase 3が完了し、運用が開始される

**具体ステップ**:
1. 週次点検項目決定
   - ワークフローの実行状況確認
   - エラー発生状況確認
   - Secrets有効性確認
   - Artifact保持状況確認
2. 棚卸し項目決定
   - 証跡ファイルの整理
   - 古い証跡のアーカイブ
   - 不要な証跡の削除
3. 古い証跡の保持方針決定
   - 保持期間: 90日（3ヶ月）
   - アーカイブ方法: 日付フォルダごとにアーカイブ
   - 削除基準: 保持期間を超過した証跡
4. SOP文書化
   - 週次点検手順を文書化
   - 棚卸し手順を文書化
   - 保持方針を文書化
5. SOP適用
   - SOPに従って週次点検を実施
   - 棚卸しを実施
   - 古い証跡をアーカイブ

**成果物**:
- ファイル名: docs/ops/PHASE3_CONTINUOUS_OPERATIONS_SOP.md
- 追記内容: 週次点検項目、棚卸し項目、保持方針、SOP適用結果

**受入基準（DoD）**:
- 週次点検項目が明確である
- 棚卸し項目が明確である
- 保持方針が明確である
- SOPが文書化されている
- SOPがPHASE3_CONTINUOUS_OPERATIONS_SOP.mdに記録されている

**想定リスクと即応**:
- リスク: 週次点検が実施されない
- 即応: 週次点検をスケジュールし、リマインダーを設定
- リスク: 古い証跡が削除される
- 即応: 保持方針を厳格に適用し、保持期間内の証跡は削除しない

---

### WS20: 移行宣言（Phase 4 へのハンドオフ要件）

**目的**: Phase 3からPhase 4への移行要件を明確にし、ハンドオフ要件を記録する

**前提**:
- WS01-WS19が完了している
- Phase 3の目標が達成されている

**具体ステップ**:
1. Phase 3完了確認
   - すべてのWSが完了していることを確認
   - すべての証跡が記録されていることを確認
   - すべてのDoDが満たされていることを確認
2. Phase 4要件確認
   - Phase 4の目標を確認
   - Phase 4に必要な要件を確認
   - Phase 3からPhase 4への移行要件を確認
3. ハンドオフ要件記録
   - Phase 3の成果物を記録
   - Phase 4に必要な情報を記録
   - 移行手順を記録
4. 移行宣言作成
   - Phase 3完了を宣言
   - Phase 4開始を宣言
   - ハンドオフ要件を明記
5. 移行宣言投稿
   - PR #61に移行宣言を投稿
   - または、専用の移行宣言ドキュメントを作成

**成果物**:
- ファイル名: docs/reports/2025-11-13/WS20_PHASE4_HANDOFF.md
- 追記内容: Phase 3完了確認、Phase 4要件、ハンドオフ要件、移行宣言

**受入基準（DoD）**:
- Phase 3が完了している
- Phase 4要件が明確である
- ハンドオフ要件が記録されている
- 移行宣言が作成されている
- 移行宣言がWS20_PHASE4_HANDOFF.mdに記録されている

**想定リスクと即応**:
- リスク: Phase 3が未完了
- 即応: 未完了のWSを完了させ、Phase 3を完了させる
- リスク: Phase 4要件が不明確
- 即応: Phase 4要件を明確にし、ハンドオフ要件を更新

---

## セクションC: 実行ダッシュボード（チェックリストと責任分担）

### 実行チェックリスト

#### 準備フェーズ
- [ ] WS01: main反映の事前検証（実行者: [名前]）
- [ ] WS09: Secrets前提チェック（実行者: [名前]）
- [ ] WS10: Branch Protection確認（実行者: [名前]）

#### 実行フェーズ
- [ ] WS02: 成功ケース実行（実行者: [名前]）
- [ ] WS03: 失敗ケース実行（実行者: [名前]）
- [ ] WS04: 並行実行（実行者: [名前]）

#### 収集フェーズ
- [ ] WS05: Run/Artifact/Log収集（実行者: [名前]）
- [ ] WS06: SHA検証（実行者: [名前]）
- [ ] WS07: Manifest追記（実行者: [名前]）
- [ ] WS08: Slack抜粋（実行者: [名前]）

#### 検証フェーズ
- [ ] WS11: Observer手動実行（実行者: [名前]）
- [ ] WS12: Supabase記録検収（実行者: [名前]）
- [ ] WS13: 失敗時一次切り分け（実行者: [名前]）
- [ ] WS14: リトライ設計（実行者: [名前]）

#### 記録フェーズ
- [ ] WS15: 時刻・日付命名規約（実行者: [名前]）
- [ ] WS16: PR #61コメント（実行者: [名前]）
- [ ] WS17: レビュー観点表（実行者: [名前]）
- [ ] WS18: 監査スクショ（実行者: [名前]）

#### 完了フェーズ
- [ ] WS19: 運用継続SOP（実行者: [名前]）
- [ ] WS20: 移行宣言（実行者: [名前]）

### 責任分担

- **実行責任者**: Phase 3の実行を統括し、すべてのWSの完了を確認
- **証跡責任者**: 証跡の収集・記録を担当し、証跡の整合性を確認
- **レビュー責任者**: 証跡のレビューを担当し、セキュリティ・監査・再現性・可逆性を確認
- **運用責任者**: 運用継続SOPの実施を担当し、週次点検・棚卸しを実施

---

## セクションD: 監査反映パック（貼り戻し用テンプレ）

### _evidence_index.md 追記テンプレ

```
## 2025-11-13 Evidence Collection

### Success Runs
| Run ID | URL | Tag | Artifacts | Status |
|--------|-----|-----|-----------|--------|
| [RUN_ID] | [URL] | [TAG] | [ARTIFACT_NAME] | ✅ Success |

### Failure Runs
| Run ID | URL | Tag | Error Type | Status |
|--------|-----|-----|------------|--------|
| [RUN_ID] | [URL] | [TAG] | [ERROR_TYPE] | ❌ Failure |

### Concurrency Runs
| Run ID | URL | Tag | Execution Order | Status |
|--------|-----|-----|-----------------|--------|
| [RUN_ID_1] | [URL_1] | [TAG_1] | 1st | ✅ Success |
| [RUN_ID_2] | [URL_2] | [TAG_2] | 2nd | ✅ Success |
| [RUN_ID_3] | [URL_3] | [TAG_3] | 3rd | ✅ Success |

### Related Documents
- [PHASE2_2_VALIDATION_REPORT.md](./2025-11-13/PHASE2_2_VALIDATION_REPORT.md)
- [PHASE3_AUDIT_SUMMARY.md](./2025-11-13/PHASE3_AUDIT_SUMMARY.md)
- [RUNS_METADATA.json](./2025-11-13/RUNS_METADATA.json)
```

### PHASE3_AUDIT_SUMMARY.md 追記テンプレ

```
## Execution Summary (2025-11-13)

### Overall Statistics
- **Total Runs**: [COUNT]
- **Success Runs**: [COUNT]
- **Failure Runs**: [COUNT]
- **Success Rate**: [PERCENTAGE]%
- **Median Execution Time**: [SECONDS]s

### Run Details
- **Success Run**: [RUN_ID] - [URL]
- **Failure Run**: [RUN_ID] - [URL]
- **Concurrency Runs**: [RUN_ID_1], [RUN_ID_2], [RUN_ID_3]

### Validation Results
- **SHA256 Validation**: ✅ Passed / ❌ Failed
- **PredicateType Validation**: ✅ Passed / ❌ Failed
- **Manifest Update**: ✅ Completed / ❌ Failed

### Next Steps
1. [ACTION_1]
2. [ACTION_2]
```

### PHASE2_2_VALIDATION_REPORT.md 追記テンプレ

```
## Execution History (2025-11-13)

### Success Case
- **Run ID**: [RUN_ID]
- **Run URL**: [URL]
- **Tag**: [TAG]
- **Executed At**: [UTC] / [JST]
- **Duration**: [SECONDS]s
- **Artifacts**: [ARTIFACT_NAME]

### Failure Case
- **Run ID**: [RUN_ID]
- **Run URL**: [URL]
- **Tag**: [TAG]
- **Executed At**: [UTC] / [JST]
- **Error Type**: [ERROR_TYPE]
- **Error Message**: [ERROR_MESSAGE]

### Concurrency Case
- **Run IDs**: [RUN_ID_1], [RUN_ID_2], [RUN_ID_3]
- **Execution Order**: 1st, 2nd, 3rd
- **Status**: ✅ All Success
```

---

## セクションE: リスクカタログ

### HTTP 422: Workflow does not have 'workflow_dispatch' trigger

**原因**: workflow_dispatchがmainブランチで認識されていない

**影響**: ワークフローを手動実行できない

**対策**:
1. mainブランチにworkflow_dispatchが含まれていることを確認
2. GitHub Web UIで「Run workflow」ボタンが表示されることを確認
3. 表示されない場合は、featureブランチからmainブランチへのPRを作成し、マージを依頼

**検知方法**: GitHub CLIで実行時にHTTP 422エラーが発生

**復旧手順**: mainブランチへのマージを実施

---

### HTTP 403: Resource not accessible by integration

**原因**: トークンスコープまたは権限が不足している

**影響**: ワークフローの実行またはリソースへのアクセスができない

**対策**:
1. ワークフローの権限設定を確認
2. 必要な権限を付与
3. トークンスコープを確認し、必要に応じて拡張

**検知方法**: ワークフロー実行時にHTTP 403エラーが発生

**復旧手順**: 権限設定を修正し、再実行

---

### HTTP 500/502/503: Internal server error

**原因**: GitHub Actionsのインフラストラクチャの問題

**影響**: ワークフローの実行が失敗する

**対策**:
1. GitHub Statusを確認: https://www.githubstatus.com/
2. 5-10分待機してから再実行
3. 指数バックオフでリトライ

**検知方法**: ワークフロー実行時にHTTP 500/502/503エラーが発生

**復旧手順**: GitHub Statusが復旧するまで待機し、再実行

---

### Secrets欠落

**原因**: 必須Secrets（SUPABASE_URL、SUPABASE_SERVICE_KEY）が設定されていない

**影響**: Supabase連携が失敗し、記録が保存されない

**対策**:
1. Secretsの存在を確認
2. 未設定の場合は、Secrets設定手順に従って設定
3. 設定後、ワークフローを再実行

**検知方法**: ワークフロー実行時にSecrets未設定エラーが発生

**復旧手順**: Secretsを設定し、再実行

---

### 権限不足

**原因**: ワークフロー実行に必要な権限が不足している

**影響**: ワークフローの実行が失敗する

**対策**:
1. 実行者の権限を確認
2. 必要な権限を付与
3. ワークフローの権限設定を確認

**検知方法**: ワークフロー実行時に権限エラーが発生

**復旧手順**: 権限を付与し、再実行

---

### 分岐未反映

**原因**: workflow_dispatchがfeatureブランチにのみ存在し、mainブランチに反映されていない

**影響**: mainブランチでワークフローを手動実行できない

**対策**:
1. featureブランチからmainブランチへのPRを作成
2. PRをマージ
3. mainブランチでworkflow_dispatchが認識されることを確認

**検知方法**: mainブランチでワークフローを実行しようとするとHTTP 422エラーが発生

**復旧手順**: PRを作成し、マージを実施

---

## セクションF: ロールバック&キルスイッチ運用

### ロールバック手順

#### ワークフロー変更のロールバック
1. ロールバック対象のコミットを特定
2. ロールバック用のPRを作成
3. ロールバック内容を確認
4. PRをマージ
5. ロールバック後の動作を確認

#### Secretsのロールバック
1. 変更されたSecretsを特定
2. 以前の値に戻す（可能な場合）
3. または、Secretsを削除し、再設定
4. Secrets変更後の動作を確認

#### Branch Protectionのロールバック
1. Branch Protection設定を確認
2. 変更前の設定に戻す
3. 設定変更後の動作を確認

### キルスイッチ運用

#### ワークフローの一時停止
1. ワークフローファイルを無効化（コメントアウトまたは削除）
2. 実行中のワークフローをキャンセル
3. 一時停止の理由を記録
4. 復旧手順を記録

#### Secretsの無効化
1. Secretsを削除または無効化
2. ワークフローがSecretsを使用できない状態にする
3. 無効化の理由を記録
4. 復旧手順を記録

#### 緊急時の連絡先
- **実行責任者**: [名前] - [連絡先]
- **証跡責任者**: [名前] - [連絡先]
- **レビュー責任者**: [名前] - [連絡先]
- **運用責任者**: [名前] - [連絡先]

---

## セクションG: Go/No-Go判定基準

### 必須KPI

#### 実行KPI
- **Success Run実行数**: 最低1本
- **Failure Run実行数**: 最低1本
- **Concurrency Run実行数**: 最低3本
- **成功率**: 80%以上（Concurrency Runを除く）

#### 証跡KPI
- **Artifact収集率**: 100%（実行されたRunのすべてのArtifactが収集されている）
- **Log収集率**: 100%（実行されたRunのすべてのLogが収集されている）
- **メタデータ記録率**: 100%（実行されたRunのすべてのメタデータが記録されている）

#### 検証KPI
- **SHA256検証率**: 100%（収集されたProvenanceファイルのすべてが検証されている）
- **PredicateType検証率**: 100%（収集されたProvenanceファイルのすべてが検証されている）
- **Manifest更新率**: 100%（実行されたRunのすべてがManifestに記録されている）

### 判断ロジック

#### Go判定
すべての必須KPIが達成されている場合、Phase 3は完了と判定し、Phase 4への移行を承認する。

#### No-Go判定
以下のいずれかに該当する場合、Phase 3は未完了と判定し、Phase 4への移行を保留する。

1. Success Runが1本も実行されていない
2. Artifact収集率が100%未満
3. SHA256検証率が100%未満
4. 機密情報が漏洩している
5. 必須Secretsが未設定で、Supabase連携が失敗している

#### 条件付きGo判定
以下の条件を満たす場合、条件付きでPhase 4への移行を承認する。

1. 必須KPIは達成されているが、一部のオプションKPIが未達成
2. 未達成のKPIについて、是正計画が明確である
3. 是正計画の実行が承認されている

---

## 完了宣言

**実行日**: 2025-11-13 JST
**実行者**: [名前]
**ステータス**: ✅ Complete / ⏳ In Progress / ❌ Blocked

**サマリー**:
- 実行されたRun数: [COUNT]
- 成功率: [PERCENTAGE]%
- 証跡ファイル数: [COUNT]
- 発見された問題数: [COUNT]

**次のステップ**:
1. [ACTION_1]
2. [ACTION_2]

**署名**: [名前] - [日時]

