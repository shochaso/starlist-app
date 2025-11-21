---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# Copilot: 10x-scale prompt pack — Day12 integration (PR #30–#33)

## 概要
- PR #30〜#33 の Update→Conflict解消→Squash→SOT追記→5分ルーチン を速やかに完了するための Copilot Chat / Inline / Editor 用プロンプト集。
- そのまま Copilot Chat に貼れば動作する指示群（ファイル別テンプレ / マージ方針 / 差分生成要請 等）を収録。

## 使い方
1. 編集コンテキスト（例: PRの競合ファイルをエディタで開いた状態）で該当テンプレを Copilot Chat に貼る。
2. 出力された差分/パッチをローカルで検証後、git apply / commit / push する。
3. マージ後は SOT（docs/reports/DAY12_SOT_DIFFS.md）へ自動追記スニペットを流す。

---

## 1) Copilot Chat：統合オペレーション指示（最上位プロンプト）

```
あなたはリポジトリメンテナです。目的は以下の4PRの完了（Update→Resolve Conflicts→CI Green→Squash→SOT追記）です：

- #30: Day12: Pricing 実務ショートカット強化
- #31: Day12: 監査KPIダッシュボード拡充
- #32: Day12: Security/CI 地固め
- #33: docs: stabilize link checks & add diagram placeholders

要件と制約：

- 優先順：#30 → #31 → #32 → #33
- 競合解決ルール：
  1) docs/reports/DAY12_SOT_DIFFS.md は「両方活かす」。末尾に `* merged: <PR URL> (<YYYY-MM-DD HH:mm:ss>)` を追加
  2) .mlc.json は main 側（theirs）優先。ignore 重複は1つに統合
  3) package.json はブランチ側（ours）優先。`docs:preflight`等 Day12 scripts を必ず残す
  4) docs/diagrams/*.mmd は main 側採用。もう一方は `*-alt.mmd` に退避（後続PRで統合）
- マージ方式：Squash & merge（履歴集約）
- マージ後タスク：SOTにコミットURL追記、週次レポ出力の5分ルーチン実行

Deliverables（生成・提案してほしい内容）：

1) 各PRの Update branch 後に必要な衝突解消パッチ（差分提案）
2) .mlc.json の ignorePatterns の正規化（重複・順序・コメント整理）
3) package.json scripts のマージ後形（`docs:preflight`, `docs:diff-log`, `export:audit-report` 等を保持）
4) SOT追記の自動化スニペット（DAY12_SOT_DIFFS.md 末尾追記）
5) 失敗時の最小ログ採取手順（ジョブ名と末尾10行）
6) ロールバック手順（revert／pricing rollback）

出力スタイル：

- 実行順に番号付きで、**貼り付け可能な差分**（CodeLens/Inline適用）を提示
- 各提案に「理由/根拠」を一言添える
- 競合ファイルは "採用側" を明示し、非採用側の重要行はコメント化して残す案も併記
```

---

## 2) Copilot Chat：ファイル別・衝突即解消テンプレ

**SOT（DAY12_SOT_DIFFS.md）**

```
このファイルのコンフリクトを「両方活かす」方針で解消してください。

- コンフリクトマーカーを除去
- 両側の箇条書きを残す
- 最後に `* merged: <PR URL> (<YYYY-MM-DD HH:mm:ss>)` を1行追記（PR URLはコメントでプレースホルダを残してOK）
- 文末の改行を確実に維持
理由：監査SOTは履歴を積み上げる台帳であり、両取りが正。
```

**.mlc.json（リンク監査）**

```
コンフリクトを main 側（theirs）基準で解消し、ignorePatterns を正規化してください。

- 同一パターンの重複を1つに統合
- アンカー/#、mailto、localhost、429リトライ等の既存ルールは維持
- JSONのキー順序は安定化（ignorePatterns, retryOn429, retryCount, httpHeaders の順）
理由：main側が最新の運用ルール。重複除去で差分縮小。
```

**package.json（scripts保持）**

```
競合をブランチ側（ours）優先で解消し、Day12の scripts を確実に残してください。

- `docs:preflight`, `docs:update-dates`, `docs:diff-log`, `export:audit-report`, `lint:md:local` 等を維持
- main 側の新規 scripts があれば衝突しない名称で追記
- engines/engineStrict, preinstall ガードは維持
理由：Day12の運用スクリプトがCIと監査の土台。
```

**Mermaid（*.mmd）**

```
main 側を採用し、もう一方の内容で重要なものがあれば末尾にコメント化して残してください。

- 非採用側は別ファイル `*-alt.mmd` への退避も提案
理由：図は外部参照があり、main基準で差分を最小化する方が安全。
```

---

## 3) Copilot Inline（エディタ内）：SOT追記スニペット

```md
* merged: <PR URL>  (2025-11-09 10:45:00 JST)
```

※ `<PR URL>` を後で置換する旨と、時刻生成ヘルパ（new Date()）の提案をあわせて依頼すると良いです。

---

## 4) Copilot Chat：.mlc.json 正規化プロンプト（重複除去）

```
この .mlc.json の ignorePatterns から重複・近似重複を除去し、最小集合に正規化してください。

- admin.google.com, github.com/orgs/..., mailto, localhost, #anchor は残す
- retryOn429=true, retryCount=2 の構成は維持
- 可能なら各パターンの簡潔なコメント（役割）を付けてください
- 出力は完全なJSON（整形）で
```

---

## 5) Copilot Chat：package.json scripts マージ補助

```
この `package.json` の scripts を、競合を解消した上で「Day12のCI/監査運用に必要な最小セット」を維持・補強してください：

- 保持必須: docs:preflight, docs:update-dates, docs:diff-log, export:audit-report, lint:md:local
- 既存の test/lint/security 周りは現状維持。重複名は解消
- 追加が必要な場合はスクリプト本体か shell を提示
- 出力は package.json の完全差分
```

---

## 6) Copilot Chat：PR本文テンプレ（レビュー用・共通）

```
PR本文を生成してください（日本語、簡潔）：

- 目的（1行）
- 変更点（箇条書き）
- 受入基準（DoD）
- ロールバック手順（1–2行）
- 監査ログ（DAY12_SOT_DIFFS.md 追記予定）
- 影響範囲（CI/Docs/Workflow）
- 確認方法（UI本線/CLI並走の要点）
```

---

## 7) Copilot Chat：マージ後5分ルーチンの"実行ログ要約"作成

```
以下のコマンド結果（貼付）を読み取り、5行以内で「本番化チェックOK/NG」と根拠を要約してください：

- gh run list --workflow extended-security.yml --limit 5
- PRICING_FINAL_SHORTCUT.sh --dry-run の1行結果
- export:audit-report の生成物（ls -1）
- npm run lint:md:local の終了コード/要約
```

---

## 8) Copilot Chat：失敗時の最小ログ抽出プロンプト

```
このPRの最新失敗ジョブの末尾10行を抽出し、原因候補を2つ、暫定対処を2つ提案してください。

必要なら再実行コマンド（gh run rerun …）も示してください。
```

---

## 9) Copilot Chat：Revert／Rollback支援

```
直前のSquashマージを Revert する手順を、GitHub UI と CLI の両方で提示してください。

加えて、Pricing の `--rollback-latest` 実行時の注意点（3分以内目安、影響範囲、監査追記）も1行で示してください。
```

---

## 10) Copilot Chat：Mermaid占位→本実装差し替えPRのひな形

```
docs/diagrams/** の *-alt.mmd を本実装へ統合するPRの差分と本文を作成してください。

- 既存ノード/エッジ保持、ops/reports 関連の相互参照を明示
- 図の凡例（legend）を追加
- リンク元md（Mermaid.md, Common Index）のアンカーも更新
```

---

### 運用提案
- このファイルをリポジトリに入れておくと再現性が上がります（チーム共有用）。
- 「Copilot Chat に貼る」→「返ってきた差分を git apply」→「CI 緑を確認」の短ループを推奨。

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
