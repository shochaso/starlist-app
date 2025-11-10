# Linear & GitHub 最終セットアップガイド

**作成日時**: 2025-11-09  
**目的**: Linear一括初期化から動作確認、GitHub/Factory連携の最終仕上げまで

---

## 📋 実行手順

### 1) Linear一括初期化（本番実行）

**APIキーを環境変数で渡す**のが安全です（ファイルに書き込まない）。

```bash
# ① 必要なら jq を導入（無ければ）
brew install jq

# ② 実行（TEAM_KEYとAPIキーを実値に）
TEAM_KEY=SL LINEAR_API_KEY=lin_xxxxxxxxxxxxx ./scripts/linear_bootstrap.sh
```

**うまくいかない時（鍵3つ）**:
- `TEAM_KEYが違う` → Linearの Team settings で **Key** を確認
- `APIキー権限不足` → WorkspaceレベルのAPIキーを再作成
- `permission denied` → `chmod +x scripts/linear_bootstrap.sh`

**TEAM_KEYが分からない場合**:
```bash
LINEAR_API_KEY=lin_xxxxxxxxxxxxx ./scripts/check_linear_teams.sh
```

---

### 2) 作成結果の"正しい見え方"（受入チェック）

Linear Webの対象チームで：

- **Labels** に以下が並ぶ
  - `area/ui, area/api, area/infra, risk/security, size/S, size/M, size/L, prio/P0, prio/P1, prio/P2, blocked, regression`

- **Issue Templates** に **Feature / Security / Ops** が増えている

- もし重複が出たら UI から不要分を削除して問題ありません（スクリプトは再実行しても致命的な副作用なし）

---

### 3) GitHub 側の確認（既に完了済の妥当性確認）

```bash
# PRテンプレが有効か（PR作成画面で自動挿入されるか）
gh pr create --title "tmp/check-template" --body "" --draft
# → 画面でテンプレ挿入を目視確認し、すぐcloseしてOK

# ラベル一覧
gh label list
```

**テンプレ自動挿入が出ない場合**:
- ファイルパスを再確認：`.github/PULL_REQUEST_TEMPLATE.md` と `.github/ISSUE_TEMPLATE/*.yml`

---

### 4) Linear ↔ GitHub 自動遷移（仕上げ設定）

Linearの **GitHub連携設定** で次を選択：

- Draft PR open → **No action**
- PR open → **In Progress**
- PR review request / activity → **In Review**
- PR ready for merge → **Ready for Merge**（または *Awaiting QA*）
- PR merge → **Done**

> これで**手動の進捗更新が不要**になります。

---

### 5) Factory への組み込み（TOOLKIT）

Factory（Droid）の **TOOLKIT** で次をON：

- ✅ **Project Management**（Linear連携がConnected後にON）
- ✅ **Memory**
- ✅ **Code Search**
- ✅ **Terminal**
- ✅ **Web**
- ⛔ **Browser**（当面OFFで可）
- （任意）**Slack** 連携が済んだらON

---

### 6) PR #49 の仕上げ

1. **Labels** を付与：`ops`, `chore`, `area/infra` ✅ 完了
2. **本文**に作成物一覧と実行手順の抜粋を追記 ✅ 完了
3. **レビュー依頼**を自分に／またはドラフト維持でOK
4. マージ後：`gh workflow run`（存在すれば）でテンプレ適用の簡易CIを回しておく

---

### 7) pre-commit の注意点（次で詰まらないために）

次の開発前に以下を実行しておくと、コミット時のエラー減ります。

```bash
# 初回
pipx install pre-commit || pip install pre-commit
pre-commit install

# 既存リポ全体を一度クリーンアップ
pre-commit run --all-files
```

> やむを得ず一時回避したい時は `git commit -m "..." --no-verify` ですが、恒常運用は **フックを通す** のが安全です。

---

### 8) オプション：LinearのTEAM_KEYが分からない時のAPI確認

```bash
# すべてのチーム一覧からKeyとIDを取る（表示用）
LINEAR_API_KEY=lin_xxxxxxxxxxxxx ./scripts/check_linear_teams.sh
```

---

## 🎯 この後の最短ゴール（2本立て）

### A. 運用開始ルート

1. Linearで **Backlog→Planned** を選別
2. 最優先3カードを **In Progress**
3. ブランチ名に `LIN-###` を入れてPR作成（テンプレ自動挿入）
4. 自動遷移が動くのを確認 → マージ → **Done**

---

### B. 自動化強化ルート（任意）

- Slackへ GitHub App と Linear App を導入
- チャンネル `#dev-pr` `#dev-ops` `#dev-daily` を作り、通知を振り分け
- FactoryのReliability/Code Droidに「LinearのIn Reviewのみ解析」などの運用を覚えさせる

---

## 📋 チェックリスト

- [ ] Linear API Keyを取得
- [ ] Linear一括初期化スクリプトを実行
- [ ] Linear側でLabelsとTemplatesを確認
- [ ] GitHub側でPR/Issueテンプレートを確認
- [ ] Linear ↔ GitHub 自動遷移設定
- [ ] Factory TOOLKIT設定
- [ ] pre-commit設定（任意）
- [ ] PR #49のマージ

---

**作成完了時刻**: 2025-11-09  
**ステータス**: ✅ **Linear & GitHub 最終セットアップガイド作成完了**

