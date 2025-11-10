# Linear & GitHub テンプレート初期化ガイド

**作成日時**: 2025-11-09  
**目的**: Linear一括初期化とGitHub PR/Issueテンプレート配置

---

## 📋 前提条件

### 必要な情報

- **GitHub リポジトリ**: `shochaso/starlist-app`
- **Linear チームキー**: 例として `SL`（任意）
  - Linear Web → Team settings で確認可能
- **Linear API Key**: Workspace settings → API → Create new
  - 文字列 `lin_xxxxx` を控える

### 必要なツール

- `jq`: `brew install jq`
- `gh`: `gh auth login`
- `curl`: 通常インストール済み

---

## 🚀 実行手順

### ステップ1: Linear 一括初期化

**1. スクリプトを編集**

`scripts/linear_bootstrap.sh` を開き、以下を設定:

```bash
TEAM_KEY="SL"                         # ← Linear のチームキーに置き換え
LINEAR_API_KEY="lin_xxxxxxxxxxxxx"    # ← Linear のAPIキーに置き換え
```

**2. 実行**

```bash
chmod +x scripts/linear_bootstrap.sh
./scripts/linear_bootstrap.sh
```

**成功時の出力**:
- ✓ TEAM_ID=...
- → ラベル作成（12個）
- → Issueテンプレ作成（Feature/Security/Ops）
- ✓ Linear 初期化 完了

---

### ステップ2: GitHub ラベル作成

**1. リポジトリをデフォルトに設定**

```bash
gh repo set-default shochaso/starlist-app
```

**2. ラベル作成スクリプトを実行**

```bash
chmod +x scripts/github_labels.sh
./scripts/github_labels.sh
```

**または、個別に作成**:

```bash
gh label create "feature"      -c "#6E5AED" -d "新機能"
gh label create "security"     -c "#EF4444" -d "セキュリティ"
gh label create "ops"          -c "#0EA5E9" -d "運用/監視"
gh label create "area/ui"      -c "#6E5AED"
gh label create "area/api"     -c "#0EA5E9"
gh label create "area/infra"   -c "#F59E0B"
gh label create "risk/security"-c "#EF4444"
gh label create "size/S"       -c "#10B981"
gh label create "size/M"       -c "#84CC16"
gh label create "size/L"       -c "#22C55E"
gh label create "prio/P0"      -c "#DC2626"
gh label create "prio/P1"      -c "#F97316"
gh label create "prio/P2"      -c "#F59E0B"
gh label create "blocked"      -c "#64748B"
gh label create "regression"   -c "#9333EA"
```

---

### ステップ3: GitHub テンプレート確認

**作成されたファイル**:
- `.github/PULL_REQUEST_TEMPLATE.md` - PRテンプレート
- `.github/ISSUE_TEMPLATE/feature.yml` - Feature Issueテンプレート
- `.github/ISSUE_TEMPLATE/bug.yml` - Bug Issueテンプレート
- `.github/ISSUE_TEMPLATE/security.yml` - Security Issueテンプレート

**確認方法**:
- GitHub → New Pull Request → テンプレートが表示されるか確認
- GitHub → New Issue → テンプレートが選択できるか確認

---

### ステップ4: コミット・PR作成

```bash
# ブランチ作成
git checkout -b chore/templates-boot

# ファイルをステージング
git add .github scripts

# コミット
git commit -m "chore: add PR/Issue templates and Linear bootstrap scripts"

# プッシュ
git push -u origin chore/templates-boot

# PR作成
gh pr create \
  --title "chore: repo templates & Linear bootstrap" \
  --body "初期テンプレとLinear一括初期化スクリプトを追加

## 変更内容
- PRテンプレート追加
- Issueテンプレート追加（Feature/Bug/Security）
- Linear一括初期化スクリプト追加
- GitHubラベル作成スクリプト追加

## 実行手順
1. Linear API Keyを設定して \`scripts/linear_bootstrap.sh\` を実行
2. \`scripts/github_labels.sh\` を実行してラベルを作成

## 関連
- Issue: #38"
```

---

## 🔧 Linear ↔ GitHub 自動遷移の推奨設定

**ワークフロー設定**（Linear側）:
- Draft PR open → **No action**
- PR open → **In Progress**
- PR review request/activity → **In Review**
- PR ready for merge → **Ready for Merge**（or Awaiting QA）
- PR merge → **Done**

---

## 🔧 トラブルシューティング

### TEAM_KEYが違う

**対処**:
- Linearのチーム設定画面でKeyを確認
- `scripts/linear_bootstrap.sh` の `TEAM_KEY` を修正

---

### APIキー権限不足

**対処**:
- Workspace全体のAPIキーを使用
- Linear → Workspace settings → API → Create new

---

### jq未導入

**対処**:
```bash
brew install jq
```

---

### gh未ログイン

**対処**:
```bash
gh auth login
```

---

### テンプレがLinearに見えない

**対処**:
- チームを切り替えて「Templates」を確認
- Linear Web → Team settings → Templates

---

## 📋 チェックリスト

- [ ] Linear API Keyを取得
- [ ] `scripts/linear_bootstrap.sh` の `TEAM_KEY` と `LINEAR_API_KEY` を設定
- [ ] Linear一括初期化スクリプトを実行
- [ ] GitHubラベル作成スクリプトを実行
- [ ] GitHubテンプレートが表示されるか確認
- [ ] コミット・PR作成

---

**作成完了時刻**: 2025-11-09  
**ステータス**: ✅ **Linear & GitHub テンプレート初期化ガイド作成完了**

