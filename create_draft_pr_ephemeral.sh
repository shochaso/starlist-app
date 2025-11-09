#!/usr/bin/env bash
set -euo pipefail
BR="${1:?Usage: $0 <branch-name>}"
tmp_body="$(mktemp -t pr_body.XXXXXX.md)"

cat > "$tmp_body" <<'PRMD'
# chore(security): initial extended-security tuning & runner

## 概要
- セキュリティ検証のノイズ抑制＋運用性向上を目的に、最低限の除外設定と成果物アップロードを整備。
- 併せて workflow_dispatch 実行→進捗監視→成果物取得 を自動化する Runner スクリプトを追加。
- まず Draft で検出状況を観察し、段階的に Fail 条件を厳格化します。

## 変更点
- `.semgrep.yml`：third_party/vendor/node_modules/build/.dart_tool、generated、tests を解析対象から適切に除外/緩和（INFOレベル）
- `.trivyignore`：tests/testdata/build/dist/.dart_tool を対象外に（個別IDは後続でピンポイント追加）
- `.github/workflows/extended-security.yml`：
  - SBOM（Syft）出力→Artifact保存
  - Semgrep 実行→JSON出力→Artifact保存
  - Trivy fs スキャン→JSON出力→Artifact保存
- `scripts/extended_security_runner.sh`：
  - `gh workflow run` 起動→ref指定でRun特定→ポーリング→成果物DL
  - `--timeout / --interval` 調整、エラーログ自動出力、Artifacts無時の警告、SIGINTトラップ

## 実行手順（運用）
1. Draft のままワークフロー実行（ブランチ指定）
   ```bash
   gh workflow run extended-security.yml --ref <this-branch>
   scripts/extended_security_runner.sh --ref <this-branch> --out artifacts/extended-security-$(date +%Y%m%d-%H%M%S)

取得Artifacts（semgrep.json / trivy.json / sbom/syft.json）を確認
必要に応じて .trivyignore に 個別ID を追加、.semgrep.yml をルール単位で抑制/対象調整
再実行→安定後に Fail 条件（Semgrep の --error や Trivy の閾値）を段階強化→mainへ
レビュー観点チェックリスト
workflow_dispatch のみで起動（CI 自動実行に影響なし）
除外対象は第三者コード／生成物／テストに限定
SBOM / Semgrep / Trivy を Artifact として必ず出力
Runner の --ref フィルタが有効／Timeout/Interval が妥当
将来の Fail 強化が容易（ワークフロー inputs のみで制御可能）
リスクとロールバック
リスク：除外過多による検出漏れ → 初期は最小除外のみ、アプリ本体はスキャン継続
ロールバック：この PR を revert すれば元に戻せます（Merge commit なら git revert -m 1）
PRMD
gh pr create \
--title "chore(security): Extended Security baseline (Trivy ignore + workflow + runner)" \
--body-file "$tmp_body" \
--base main --head "$BR" --draft \
--label security --label draft --assignee shochaso
rm -f "$tmp_body"
