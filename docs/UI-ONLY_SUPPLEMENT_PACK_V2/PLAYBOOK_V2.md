# UI-Only Supplement Pack v2 — Playbook (A → J)

目的：UI操作のみで完了する運用パターンの欠落を補い、監査・記録・復旧を確実にする。

## A. 目的とスコープ

- 対象作業：ワークフローの手動起動、アーティファクト回収、簡易解析、SOT追記、UI-only Branch Protectionの検証

- 役割：実行者（オペレーター）、レビュワー（PM/SEC）、監査者（Ops）

## B. 事前チェック（3分）

- `gh auth status`
- ブランチとファイル存在確認（`.github/workflows/extended-security.yml`）
- ログインユーザ／権限確認（UI: Settings → Collaborators / CLI: `gh auth status`）

## C. ワークフロー起動（UI と CLI 両対応）

- UI: Actions → 対象Workflow → Run workflow（refを選択、inputsを設定）
- CLI: `WF_ID=$(gh workflow view extended-security.yml --json id -q .id); gh api -X POST ... dispatches -f ref=main -f inputs[...]`
- 起動時は観察フェーズ（`semgrep_fail_on=false`）を初回推奨

## D. 進捗監視（最短コマンド）

- `gh run list --workflow extended-security.yml --limit 5`
- `gh run view <RUN_ID> --log`
- ポーリング：20分タイムアウト、15秒間隔（runner推奨）

## E. アーティファクト取得と最小解析

- `gh run download <RUN_ID> --dir artifacts/...`
- `jq`でSemgrep/Trivyの件数抽出（テンプレ付属）
- 欠陥の簡易優先付け → Critical/High/FP候補へ振り分け

## F. SOT 更新（手順）

- `docs/reports/DAY12_SOT_DIFFS.md` を開く
- 追記フォーマット：`* merged: <PR URL> (YYYY-MM-DD HH:mm:ss JST)`
- commit & push（BranchがProtectedの場合はPR経由）

## G. 監査ログ（OPS-SUMMARY）

- `docs/reports/OPS-SUMMARY-LOGS.md` に `logs/security_<RUN_ID>/` と要約を行頭に追加
- フォーマット：日時 / run-id / artifactsパス / Semgrep/Trivy counts / quick note

## H. トラブル対応（失敗時）

- まず `gh run view <RUN_ID> --log` の末尾20行を保存
- 再実行: `gh run rerun <RUN_ID>`
- 必要ならPRで revert 指示（簡易手順テンプレあり）

## I. 復旧（Roll back）

- 直近マージを revert: `gh pr list` → `gh pr view` → `gh pr merge/revert` 手順を文書化
- Pricing等の重要操作はロールバックスクリプト（audit記録を残す）を実行

## J. エスカレーション & 5分ルーチン

- 重大度High以上は即時Slack通知 + 1on1
- 5分ルーチン: run-id, artifacts, Semgrep/Trivy top3, next-action（自動テンプレ）

