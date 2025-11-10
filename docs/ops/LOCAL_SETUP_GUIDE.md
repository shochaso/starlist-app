# Factory Local セットアップガイド

**作成日時**: 2025-11-09  
**目的**: Factory Bridge接続からローカル開発環境の準備まで

---

## 📋 実行手順

### 1) Factory Bridge を接続

1. **Factory Bridge** アプリを起動（先ほどの黒いウィンドウ）。

2. Factory（ブラウザ）で **New Session → Local** を選ぶと、画面上部に 6桁の **Passkey** が表示されます。

   → Bridgeのウィンドウにその **Passkey** を入力して **Connect**。

   （Passkeyが違う/出ない場合は、セッション画面の「Local」カードに表示された数字を再確認）

3. Bridgeの「Root Directory」は、開発フォルダ（例：`~/dev`）にしておくと便利です。

   必要なら **Browser Tools** をON。

> 接続OKのサイン：FactoryのLocalセッション画面右下の警告が消えます。消えないときはBridge再起動 or 6桁再入力。

---

### 2) リポジトリをLocalで用意

まだクローンしていない場合：

```bash
mkdir -p ~/dev && cd ~/dev
git clone git@github.com:shochaso/starlist-app.git
cd starlist-app
```

> GitHub CLI を使う場合は `gh auth login` でログインしておいてください。

**現在のリポジトリ**:
- パス: `/Users/shochaso/Downloads/starlist-app`
- GitHub CLI認証: ✅ 済み
- リモート: `origin` (https://github.com/shochaso/starlist-app.git)

---

### 3) Factory セッション開始（Local）

1. **New Session → Local**

2. 「Select Workspace」でローカルの `starlist-app` を選択（見えない場合は「Add Local Repo」→フォルダ指定）。

3. 右下 **Next** → チャットが開いたら、右下 **TOOLKIT** で

   * ✅ Code Search / Terminal / Memory（必要なら Web）をON
   * 後でLinear連携テストをするなら **Project Management** もON

---

### 4) ブランチ作成〜PR（ローカルで一気に）

Linearの自動遷移テスト用のサンプル差分です。コピペでOKです。

**方法1: スクリプト実行（推奨）**
```bash
./scripts/local-setup-test.sh
```

**方法2: 手動実行**
```bash
# 最新化
git fetch --all --prune
git checkout -B LIN-001-my-page-wording origin/main || git checkout -B LIN-001-my-page-wording main

# ちょい差分
mkdir -p docs
echo "auto-link test $(date -u +"%Y-%m-%dT%H:%MZ")" >> docs/auto-link-test.md
git add docs/auto-link-test.md
git commit -m "chore(ui): LIN-001 wording tweak"

# プッシュ
git push -u origin LIN-001-my-page-wording

# PR作成（GitHub CLI）
gh pr create \
  --title "chore(ui): LIN-001 wording tweak" \
  --body "Purpose: auto-link test to Linear

DoD: PR→In Progress, Review→In Review, Merge→Done" \
  --base main

# 自分にレビュー依頼
gh pr edit --add-reviewer @me
```

> これで：
> * **PR作成** → Linearが **In Progress**
> * **レビュー依頼/レビュー活動** → **In Review**
> * **マージ** → **Done**
>   の自動遷移が動く想定です（Linear側のGitHubワークフロー設定がONであること）。

---

### 5) よくある詰まり（Local/Bridge）

* **Passkeyが合わない**：セッション画面の6桁を再生成（Back→Next）→Bridgeに再入力

* **権限ダイアログが出ない**：Bridgeを一度終了→再起動、macOSの「システム設定 > セキュリティ/プライバシー」で許可

* **Repoが選べない**：FactoryのLocalセレクタで「Add Local Repo」からフォルダ直指定

* **ghコマンド未導入**：`brew install gh` → `gh auth login`

* **SSH権限**：`ssh -T git@github.com` で成功応答を確認

**現在の状態**:
- ✅ GitHub CLI認証済み
- ⚠️  SSH接続に問題がある可能性（HTTPSでpush可能）

---

### 6) うまくいったら

* PR URL と Linearチケットのステータスが意図どおり動いたか（In Progress → In Review → Done）だけ教えてください。

* 自動遷移が動かない場合は、Linearの **GitHub workflow mapping**（PR open / review activity / merge の各遷移）をこちらで再チェックの手順をご案内します。

---

## 📋 チェックリスト

- [ ] Factory Bridge接続（6桁Passkey入力）
- [ ] Factory Localセッション開始
- [ ] リポジトリ選択（Add Local Repo）
- [ ] TOOLKIT設定（Code Search / Terminal / Memory）
- [ ] Linear自動遷移テストPR作成
- [ ] Linear側でステータス遷移確認

---

**作成完了時刻**: 2025-11-09  
**ステータス**: ✅ **Factory Local セットアップガイド作成完了**

