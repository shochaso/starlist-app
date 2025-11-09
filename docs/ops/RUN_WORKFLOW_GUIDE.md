# Run workflow ボタン到達 → 手動実行 → RUN_ID取得 → 成功確認 ガイド

**目的**: GitHub Actionsのワークフローを手動実行し、RUN_IDを取得して成功を確認する

**対象**: UI操作オンリー + CLI代替

**作成日**: 2025-11-09

---

## 1) GUIでの到達ルート（確実にボタンへ）

**どれか一つでOK。**

### A. 左サイドバーから

1. **Actions** タブを開いたまま、左の一覧で
   `.github/workflows/weekly-routine.yml` をクリック
2. 右上 **Run workflow** → **Branch: main** を選択 → **Run workflow**

### B. パンくず（見出しリンク）から

1. 実行履歴一覧の上部に出ている **`weekly-routine.yml`** をクリック
2. 右上 **Run workflow** → **main** → **Run**

### C. 直接URL（ブックマーク用）

* `https://github.com/shochaso/starlist-app/actions/workflows/weekly-routine.yml`
* `https://github.com/shochaso/starlist-app/actions/workflows/allowlist-sweep.yml`

各ページ右上に **Run workflow**。

### D. 画面幅で隠れている場合

* ブラウザ横幅を広げる／ズーム 90–100% に戻す／**Cmd+R（F5）** で再描画

### E. 権限チェック

* ご自身の権限が **Write 以上**でないと **Run workflow** は表示されません。

---

## 2) CLIでの代替（同内容をコマンド実行）

> UIが混み合う時でも即実行できます。**main** で叩く前提。

```bash
# 認証確認
gh auth status

# ワークフロー名の存在をざっと確認
gh workflow list | rg -n 'weekly|allowlist' || true

# main を手動実行（両方）
gh workflow run weekly-routine.yml
gh workflow run allowlist-sweep.yml

# 数秒待ってから直近 RUN を取得（RUN_ID 収集）
sleep 12
gh run list --limit 30 --json databaseId,name,status,conclusion,headBranch \
  -q '.[] | select(.name|test("weekly|allowlist"))' \
| jq -r '.[] | "\(.name)\tRUN_ID=\(.databaseId)\tstatus=\(.status)\tconclusion=\(.conclusion)\tbranch=\(.headBranch)"'
```

### ログ＆失敗10行だけ切り出し（原因即特定）

```bash
RID_WEEK=$(gh run list --limit 20 --json databaseId,name -q '.[] | select(.name|test("weekly")).databaseId' | head -n1)
RID_ALLOW=$(gh run list --limit 20 --json databaseId,name -q '.[] | select(.name|test("allowlist")).databaseId' | head -n1)

gh run view "$RID_WEEK"  --log > .tmp_week_log.txt  2>/dev/null || true
gh run view "$RID_ALLOW" --log > .tmp_allow_log.txt 2>/dev/null || true

grep -nE "error|fail|denied|not found|No such|permission" .tmp_week_log.txt  | head -n 10 || true
grep -nE "error|fail|denied|not found|No such|permission" .tmp_allow_log.txt | head -n 10 || true
```

---

## 3) 「Run workflow」が出ない時の原因 → 直し方（即断用）

| 症状                       | 主因                                                                | すぐの対処                                                                   |
| ------------------------ | ----------------------------------------------------------------- | ----------------------------------------------------------------------- |
| ボタン自体が出ない                | default branch（=main）の YAML に `on: workflow_dispatch:` がない / 反映待ち | `main` 上のファイルを開いて `workflow_dispatch:` があるか確認。なければPRを反映。反映直後は**UI再読込**。 |
| Select branch に main が無い | ファイルが main に未反映                                                   | 先に PR を **merge**。                                                      |
| 押せるが即 422                | 反映遅延／ファイル名不一致                                                     | **UIから実行**を一度試す → 数十秒後に CLI 再試行。                                        |
| 押すと Permission denied    | 権限不足                                                              | Repo 権限を **Write** 以上へ。                                                 |
| 走るが途中で失敗                 | Node/Secrets/ワークフロー内条件                                            | エラーログ上位10行を確認（上のコマンド）。                                                  |

---

## 4) 実行後の提出テンプレ（この形で教えてください）

```
weekly-routine RUN_ID=XXXXXXXX conclusion=success
allowlist-sweep RUN_ID=YYYYYYYY conclusion=success

security_tab: SARIF visible (Semgrep/Gitleaks)=YES
artifacts: gitleaks/sbom downloaded=YES
```

※ `conclusion=success` であれば受入OK判定に進めます。

---

## 5) そのまま続行（Security 可視化と成果物の確認）

* **Security** タブ → **Code scanning alerts** に **Semgrep / Gitleaks** が出ている（No alerts でもOK）
* 対象 Run の **Artifacts** に `sec-gitleaks-full` / `sec-gitleaks-fast` / `sbom` が存在し、**Download** できる

---

## 6) ワンストップ最短チェック（UI派向け）

1. **Actions → 左の `weekly-routine.yml`** をクリック
2. 右上 **Run workflow** → **main** → **Run**
3. 同様に **`allowlist-sweep.yml`** でも実行
4. 数十秒後、各ページで **最新Runの緑チェック** と **Artifacts** を確認
5. 上のテンプレで **RUN_ID / conclusion** を共有

---

## 実行例（CLI）

```bash
# ワークフロー実行
gh workflow run weekly-routine.yml
gh workflow run allowlist-sweep.yml

# RUN_ID取得（数秒待ってから）
sleep 12
gh run list --limit 30 --json databaseId,name,status,conclusion,headBranch \
  --jq '.[] | select(.name|test("weekly|allowlist"))' \
  | jq -r '.[] | "\(.name)\tRUN_ID=\(.databaseId)\tconclusion=\(.conclusion)"'
```

---

---

## 付録：10倍密度・即実行パック拡張版

### 1) オペレーター1枚紙（最短ルート）

#### UI派（推奨）

1. Actions → 左の **`weekly-routine.yml`** をクリック
2. 右上 **Run workflow** → **Branch: main** → **Run**
3. 同様に **`allowlist-sweep.yml`** でも実行
4. 数十秒後、各ページで **緑チェック** と **Artifacts** を確認

#### CLI派（同等）

```bash
gh workflow run weekly-routine.yml
gh workflow run allowlist-sweep.yml
sleep 12
gh run list --limit 30 --json databaseId,name,status,conclusion,headBranch \
  -q '.[] | select(.name|test("weekly|allowlist"))' \
| jq -r '.[] | "\(.name)\tRUN_ID=\(.databaseId)\tconclusion=\(.conclusion)\tbranch=\(.headBranch)"'
```

---

### 2) 成功判定・提出テンプレ（4点）

> そのまま貼って提出してください（**実測値で**）。

```
weekly-routine RUN_ID=XXXXXXXX conclusion=success
allowlist-sweep RUN_ID=YYYYYYYY conclusion=success

security_tab: SARIF visible (Semgrep/Gitleaks)=YES
artifacts: gitleaks/sbom downloaded=YES
```

> これを満たせば、**セキュリティ運用の受け入れOK**に進めます。

---

### 3) 失敗時の即時切り分け（10行抜粋×3段）

**目的：** 原因カテゴリを**1分以内**に確定

**やること：** ログ10行×2（weekly/allowlist）、**結論1行**で要約

```bash
RID_WEEK=$(gh run list --limit 20 --json databaseId,name -q '.[] | select(.name|test("weekly")).databaseId' | head -n1)
RID_ALLOW=$(gh run list --limit 20 --json databaseId,name -q '.[] | select(.name|test("allowlist")).databaseId' | head -n1)

gh run view "$RID_WEEK"  --log > .tmp_week_log.txt  2>/dev/null || true
gh run view "$RID_ALLOW" --log > .tmp_allow_log.txt 2>/dev/null || true

echo "---- weekly (top10) ----";   grep -nE "error|fail|denied|not found|No such|permission" .tmp_week_log.txt  | head -n 10 || true
echo "---- allowlist (top10) ----";grep -nE "error|fail|denied|not found|No such|permission" .tmp_allow_log.txt | head -n 10 || true
```

**即断マトリクス**

* **422**：`workflow_dispatch` 反映待ち / main 未反映 → UIから実行 or 1〜2分後に再試行
* **permission/denied**：権限不足（Write以上に）
* **not found**：YAML名誤り／ブランチ参照ミス
* **Node mismatch**：`setup-node` と `package.json` engines 不一致
* **Secrets**：必要変数（Resend/Supabase 等）未設定

---

### 4) UI↔CLI 相互代替ルート表

| やりたいこと       | UI                         | CLI                                         |
| ------------ | -------------------------- | ------------------------------------------- |
| ワークフロー実行     | Actions→対象yml→Run workflow | `gh workflow run <file>.yml [--ref branch]` |
| 直近 RUN_ID 確認 | 対象Runをクリック                 | `gh run list … \| jq …`                    |
| ログ閲覧         | 対象Run→View full log        | `gh run view <RUN_ID> --log`                |
| 成果物DL        | Run→Artifacts              | `gh run download <RUN_ID>`                  |

---

### 5) RUN_ID 記録フォーマット

#### JSON（機械処理向け）

```json
{
  "weekly_routine": {"run_id":"XXXXXXXX","conclusion":"success","branch":"main"},
  "allowlist_sweep": {"run_id":"YYYYYYYY","conclusion":"success","branch":"main"}
}
```

#### Markdown（SOT貼付用）

```
- weekly-routine: RUN_ID=XXXXXXXX / conclusion=success / branch=main
- allowlist-sweep: RUN_ID=YYYYYYYY / conclusion=success / branch=main
```

---

### 6) 監査ログの標準ディレクトリ構成

```
out/security/YYYY-MM-DD/
  RUNS.json            # 上記JSON
  SECURITY_TAB.txt     # "SARIF visible=YES/NO" / "Artifacts downloaded=YES/NO"
  WEEKLY.log           # weekly のログ10行
  ALLOWLIST.log        # allowlist のログ10行
  SOT.txt              # 3行サマリ（下記）
```

---

### 7) ブランチ保護 "貼るだけチェック"

* 必須チェック：`extended-security`, `Docs Link Check`（導入済みなら `flutter-providers-ci` も）
* Require status checks to pass：**ON**
* Dismiss stale reviews：**ON**
* Force pushes：**禁止**
* Include administrators：任意

> 設定変更の**スクショ2枚**（Before/After）を `out/security/YYYY-MM-DD/` に保存すると監査が楽です。

---

### 8) FAQ（10本）

1. **Runボタンが無い**：main上のYAMLに `workflow_dispatch:` が無い/反映待ち → ファイル確認/更新、ページ再読込
2. **Branch選択にmainが無い**：PR未マージ → 先にマージ
3. **押したら422**：反映待ち → UIから実行 or 少し待つ
4. **Permission denied**：権限がWrite未満 → 権限付与
5. **Artifactsが無い**：ワークフロー内の `if: always()` や `upload` ステップを確認
6. **SecurityタブにSARIFが無い**：`upload-sarif` ステップ未実行 or フィルタ条件不一致
7. **Nodeエラー**：`setup-node` と `engines` を Node 20 で揃える
8. **Secrets不足**：Resend/Supabase 等のSecretを設定
9. **UIが古い**：ブラウザ幅が狭い/キャッシュ → 幅を広げる・リロード
10. **同じRunが乱立**：多重起動 → UI/CLIどちらかに統一、並列制御（concurrency）を運用で徹底

---

### 9) ロールバック最短（安全版／強制版）

#### 安全版（直前の良品コミットへ）

```bash
git switch main && git pull --ff-only
LAST_OK=$(git rev-list -n1 HEAD -- .github/workflows/weekly-routine.yml .github/workflows/allowlist-sweep.yml)
git checkout "$LAST_OK" -- .github/workflows/weekly-routine.yml .github/workflows/allowlist-sweep.yml
git commit -m "revert: workflows to last-known-good"
git push
```

#### 強制版（どうしても止めたい時のみ）

* 一時的に **Actions → Disable**、収束後 **Enable**（監査メモ必須）

---

### 10) 仕上げチェックリスト（SOT用3行サマリ）

#### DoD（6/6）

* manualRefresh 統一：OK
* setFilter のみ：OK
* 401/403→バッジ＋SnackBar：OK
* 30s タイマー単一：OK
* providers-only CI 緑＆ローカル一致：OK（未導入時は"保留"のまま運用可）
* ガイド単体で再現：OK

#### SOT 3行（提出フォーマット）

```
成果：weekly/allowlist を main で手動起動し RUN_ID 確定、Securityタブで SARIF/Artifacts を確認。
検証：ログ10行抜粋でエラー無／DoD6点=OK／ブランチ保護は必須チェックを適用。
次：監査ログを out/security/<date>/ に保存し、SOTへ3行サマリを追記。
```

---

---

## 付録V2：10倍密度・即実行パック｜最終仕上げセット（V2）

### 0) いますぐ実行（GUI最短ルート）

1. **Actions → 左の `weekly-routine.yml`** をクリック
2. 右上 **Run workflow** → **Branch: main** → **Run**
3. 同様に **`allowlist-sweep.yml`** でも実行
4. すぐ下の「1) RUN_ID 取得コマンド」でIDと結論を採取

---

### 1) RUN_ID 取得＆貼り付けテンプレ

```bash
# 直近の weekly / allowlist 実行一覧（RUN_ID/結論/ブランチ）
gh run list --limit 30 --json databaseId,name,status,conclusion,headBranch \
  -q '.[] | select(.name|test("weekly|allowlist"))' \
| jq -r '.[] | "\(.name)\tRUN_ID=\(.databaseId)\tstatus=\(.status)\tconclusion=\(.conclusion)\tbranch=\(.headBranch)"'
```

**提出テンプレ（そのまま貼り付け）**

```
weekly-routine RUN_ID=XXXXXXXX conclusion=success
allowlist-sweep RUN_ID=YYYYYYYY conclusion=success

security_tab: SARIF visible (Semgrep/Gitleaks)=YES
artifacts: gitleaks/sbom downloaded=YES
```

---

### 2) 失敗時の即断（10行ダンプ）＋カテゴリ化

```bash
RID_WEEK=$(gh run list --limit 20 --json databaseId,name -q '.[] | select(.name|test("weekly")).databaseId' | head -n1)
RID_ALLOW=$(gh run list --limit 20 --json databaseId,name -q '.[] | select(.name|test("allowlist")).databaseId' | head -n1)

gh run view "$RID_WEEK"  --log > .tmp_week_log.txt  2>/dev/null || true
gh run view "$RID_ALLOW" --log > .tmp_allow_log.txt 2>/dev/null || true

echo "---- weekly (top10) ----";   grep -nE "error|fail|denied|not found|No such|permission" .tmp_week_log.txt  | head -n 10 || true
echo "---- allowlist (top10) ----";grep -nE "error|fail|denied|not found|No such|permission" .tmp_allow_log.txt | head -n 10 || true
```

**即断マトリクス**

* `422`：dispatch 反映遅延／main未反映 → UIから先に実行 or 数分後再試行
* `permission/denied`：権限不足 → Repo 権限 **Write以上**
* `not found`：ファイル名/参照ブランチ不整合 → YAML名・ref確認
* Node不一致：`setup-node` と `package.json#engines` を **Node 20** に統一
* Secrets欠落：Resend/Supabase 等を補填

---

### 3) 証跡フォルダ作成（JSTタイムスタンプ）

```bash
DATE=$(date -u +"%Y-%m-%dT%H%M%SZ")   # 監査ではUTC推奨（JST併記可）
mkdir -p out/security/$DATE
```

**格納物**：

```
out/security/$DATE/
  RUNS.json              # RUN_ID/結論/ブランチ
  SECURITY_TAB.txt       # "SARIF visible=YES/NO" / "Artifacts downloaded=YES/NO"
  WEEKLY.log             # weekly 失敗トップ10
  ALLOWLIST.log          # allowlist 失敗トップ10
  SOT.txt                # 3行サマリ（末尾テンプレ）
```

---

### 4) Security 可視化（実査）メモ

* **Security → Code scanning alerts** に **Semgrep / Gitleaks** が表示（件数0でもOK）
* 対象Runの **Artifacts** に `sec-gitleaks-full` / `sec-gitleaks-fast` / `sbom` が存在し **Download** 可能

**記録**：`out/security/$DATE/SECURITY_TAB.txt` に下記2行を保存

```
security_tab: SARIF visible (Semgrep/Gitleaks)=YES
artifacts: gitleaks/sbom downloaded=YES
```

---

### 5) PRコメント雛形（RUN_ID 確定後に貼付）

```
Security verification: ALL PASS (RUN_ID= weekly:<ID>, allowlist:<ID>)

- SARIF: Semgrep/Gitleaks 可視（Securityタブ）

- Artifacts: sec-gitleaks-*/SBOM 確認

- OPS: manualRefresh/setFilter統一、Auth可視、30s単一タイマー

- providers-only CI: green（ローカル一致）

→ Ready & Merge (--merge)
```

---

### 6) ブランチ保護 "貼るだけチェック"

* 必須チェック：`extended-security`, `Docs Link Check`（導入済みなら `flutter-providers-ci` も）
* Require status checks to pass：**ON**
* Dismiss stale reviews：**ON**
* Force pushes：**禁止**
* Include administrators：任意

**監査TIPS**：設定画面の **Before/After スクショ** を `out/security/$DATE/` に保存

---

### 7) rg-guard 方針（今回触らず／方針のみ固定）

```
policy: migrate_to_registry
```

検出：`Image.asset` 7件（CDN/レジストリへ順次移行。機能影響回避のため今回のRunでは非変更）

---

### 8) DoD 6点の確定ブロック

```
[DoD]
1) manualRefresh統一：OK
2) setFilterのみ：OK
3) 401/403→赤バッジ＋SnackBar：OK
4) 30sタイマー単一：OK
5) providers-only CI 緑＆ローカル一致：OK（未導入なら"保留"のまま）
6) ガイド単体で再現可：OK
```

---

### 9) ロールバック最短（安全版）

```bash
git switch main && git pull --ff-only
LAST_OK=$(git rev-list -n1 HEAD -- .github/workflows/weekly-routine.yml .github/workflows/allowlist-sweep.yml)
git checkout "$LAST_OK" -- .github/workflows/weekly-routine.yml .github/workflows/allowlist-sweep.yml
git commit -m "revert: workflows to last-known-good"
git push
```

※ 強制停止が必要な場合のみ：Actions を一時 **Disable** → 収束後 **Enable**（監査メモ必須）

---

### 10) SOT 3行サマリ（そのまま貼付）

```
成果：weekly/allowlist を main で手動起動し RUN_ID 確定、Securityタブで SARIF/Artifacts を確認。
検証：ログ10行抜粋でエラー無／DoD6点=OK／ブランチ保護は必須チェックを適用。
次：監査ログを out/security/<date>/ に保存し、SOTへ3行サマリを追記。
```

---

### ご提出いただきたい最小セット（4点）

1. `weekly-routine RUN_ID=… conclusion=…`
2. `allowlist-sweep RUN_ID=… conclusion=…`
3. `security_tab: … / artifacts: …`（2行）
4. DoD 6点ブロック（OK/保留）

この4点が揃い次第、**最終サインオフ**を発行いたします。

---

**作成日**: 2025-11-09  
**ステータス**: ✅ **Run workflow ガイド完成（付録V2追加済み）**

