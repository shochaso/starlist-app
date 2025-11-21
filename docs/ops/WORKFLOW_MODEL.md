---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# Cursor / Factory / Linear 運用モデル

## 全体方針（1行要約）

* **実装は Cursor ローカル中心**
* **重い処理・自動化・安全な権限実行は Factory**（Remote/Workflow＋GitHub App）
* **状態管理と自動遷移は Linear**（PR/レビュー/マージにフック）

---

## 役割分担（何をどこでやるか）

### Cursor（主戦場）

* コーディング／テスト／小さなコミットループ
* `bin/new.sh` でブランチ＆PR作成、`bin/finish.sh` でマージ標準化
* 速いコード検索・編集、ローカルでの実行確認

### Factory（ここが強み）

* **Remote Workspace**：大きい依存（Flutter/LLM/DB）・GPU・マルチサービスの統合実行
* **GitHub連携の"確実な"PR操作**：bypass/管理者権限・自動レビュー付与・タイトル規約CI
* **再現性のある自動スクリプト**：ワンコマンドで「ブランチ→PR→レビュー依頼→マージ」
* **監査性**：誰が・いつ・何をしたか（手動より確実）

### Linear（真実のソース）

* ステータスは **PR作成→In Progress、レビュー依頼→In Review、マージ→Done** を自動
* 優先度・期日・担当の調整、Backlog整流化

---

## デイリーフロー（毎日の動き方）

### 1. Issue を取る（Linear）

例：`STA-12 Improve onboarding copy`

### 2. 作業開始（Cursor）

```bash
bin/new.sh STA-12 "Improve onboarding copy"
```

→ ブランチ＆PR自動作成、Linear が **In Progress** に

### 3. 実装→小さくコミット（Cursor）

```bash
git add -A
git commit -m "feat(ui): refine onboarding copy"
git push
```

### 4. レビュー依頼（どちらでもOK）

* Cursor から `gh pr edit --add-reviewer @reviewer`
* もしくは Factory の「Manage GitHub → Request review」

→ Linear が **In Review**

### 5. レビュー対応→マージ（基本は Cursor、権限絡みは Factory）

* `bin/finish.sh`（または `gh pr merge --squash --delete-branch`）
* チェックが厳しい／管理者bypassが必要なら Factory で実行

→ Linear が **Done**

### 6. ハウスキーピング（Cursor）

```bash
git fetch --all --prune
git switch -C main origin/main
git branch --merged | egrep -v '^\*|main' | xargs -n1 git branch -d
```

---

## いつ Factory を使うべき？

* **CIが重い/ローカルに依存が無い**（Flutter, Android, iOS, GPU, DB）
* **PR操作に管理者権限が絡む**（bypass、保護ブランチ、失敗 CI の一時回避）
* **"作業を記録して安全に"自動化したい**（スクリプト実行ログ・再実行性）
* **チーム共有が必要**（Remote 環境を共通化）

---

## 設定／運用のベストプラクティス

### PRタイトル規約

`[STA-XX] <summary>`（ワークフロー `conventions.yml` で検証）

### レビュー依頼で In Review を確実に

```bash
gh pr edit --add-reviewer @<user>
```

またはルールで自動化

### 失敗CIの扱い

* **恒久**：ワークフロー修正（デバイス指定/セットアップ追加）
* **暫定**：optional化 or 一時的な bypass（Factory 側から実施、理由をPRに明記）

### 秘密情報

GitHub Secrets/Org Secrets、Factory 側 App 権限で扱い、**PRに直接書かない**

### テンプレ

`.github/PULL_REQUEST_TEMPLATE.md` で DoD とリンクを固定

---

## "詰まり"を解決する即効リファレンス

### worktree 競合

```bash
git worktree list
git worktree prune
git worktree remove --force <path>  # エラーに出た残骸を削除
```

### Flutter CI が落ちる

* デバイスを一意に指定、`flutter doctor`/SDK セットアップを step 追加
* 暫定は `continue-on-error: true` で optional 化、必須チェックから外す

### タイトル規約NG

```bash
gh pr edit --title "[STA-12] Improve onboarding copy"
```

---

## 1日の締め（軽量チェック）

* Linear：自分の Issue が **In Progress** のまま寝ていないか
* GitHub：レビュー待ちPRにレビュワーが付いているか／CI 失敗はないか
* main：`git pull --ff-only` で手元をクリーンに

---

## 小さく回すための合図（コメント定型）

### In Review トリガー（保険）

```
Triggering Linear In Review transition.
```

### bypass 実施時

```
Admin bypass merge due to <理由>. Permanent fix will follow.
```

### クローズ

```
Merged via squash. Linear should be in "Done" ✅
```

---

## 関連ファイル

* `bin/new.sh` - IssueからPR作成まで自動化
* `bin/finish.sh` - PRマージの標準化
* `.github/workflows/conventions.yml` - PRタイトル規約チェック
* `.github/PULL_REQUEST_TEMPLATE.md` - PRテンプレート

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
