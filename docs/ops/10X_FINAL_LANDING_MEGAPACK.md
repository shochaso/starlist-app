# 10× Final Landing — 超仕上げメガパック（UIオンリー）

**目的**: GitHub UI操作オンリーで、PR #39の着地→週次WF通電→Ops健康度→SOT整合→セキュリティ復帰→ブランチ保護→証跡化まで一気通貫で締め切る

**対象**: ターミナルを使わない運用者向け

**作成日**: 2025-11-09

---

## 0. プリフライト（1分）

* **PR**: #39（`hotfix/enable-dispatch`）
* **想定状態**: 競合あり / `workflow_dispatch` を含むWFがPR側に存在
* **確認**: PR画面の **Files changed / Checks** を開く

**DoD**: ブロッカー=「競合解消」だけであること

**現在の状態**: ✅ PR #39はマージ済み（2025-11-09T09:14:30Z）

---

## 1. 競合解消SOP（5–10分）

**Resolve conflicts** → 画面上で編集 → **Mark as resolved** → **Commit merge**

### 優先ルール（今回固定）

* `.github/workflows/weekly-routine.yml` / `.github/workflows/allowlist-sweep.yml`
  → **PR側採用**（`workflow_dispatch:` を必ず残す）

* `.mlc.json` → **main優先**、`ignorePatterns` を重複マージ（`admin.google.com`, `github.com/orgs/...`, `mailto:`, `localhost`, `#` などは残す）

* `package.json` → **PR側優先**（`docs:*`, `export:audit-report`, `security:*` を保持）

* `docs/reports/*SOT*.md` → **両取り**＋末尾に `merged: <PR URL> (YYYY-MM-DD HH:mm JST)` を1行追記

* `lib/services/**` → **Image.asset / SvgPicture.asset の直参照禁止**（コメント文字列も "Asset-based image loaders" に置換）

**DoD**: 競合0件。Checksが自動再実行へ。

**現在の状態**: ✅ PR #39はマージ済み（競合解消完了）

---

## 2. CIグリーン最短ルート（10分）

**Checks** タブで失敗が出たら、そのジョブの**末尾ログ**を開いて対象のみUI編集で修正→**Commit**。

### よくあるエラーと対処

* **rg-guard**（禁止ローダ検出/誤検知）
  * コード修正：`Image.asset` / `SvgPicture.asset` を使わず、CDN/Registry経由に統一
  * コメント誤検知：文字列を "Asset-based image loaders" へ置換

* **Link Check**
  * `.mlc.json` に `ignorePatterns` 追加（`admin.google.com`, `github.com/orgs/...`, `mailto:`, `localhost`, `#`）

* **Gitleaks**（擬陽性）
  * `.gitleaks.toml` に期限付き allowlist を追記（後で自動棚卸し）

* **Trivy(config)**
  * `Dockerfile` に `USER` 追加（strictは段階ONでOK）

### 数値DoD

* `extended-security=success`
* `Docs Link Check=success`
* `rg-guard=0`
* `Gitleaks=0`

---

## 3. マージ（Squash推奨）（1分）

**Squash and merge** を選択（線形履歴/保護ルールと整合）。

**DoD**: `main` にWFが反映され、**Actions** に表示される

**現在の状態**: ✅ PR #39はマージ済み（Squash and merge完了）

---

## 4. 週次ワークフローの通電確認（2–3分）

### 手順

1. **Actions** → `weekly-routine` → **Run workflow**
2. **Actions** → `allowlist-sweep` → **Run workflow**
3. Artifacts を1件ダウンロード（監査保管）

**DoD**: 両WF **success（2/2）**、Artifacts/SARIF確認

---

## 5. Ops健康度の更新（1分）

`docs/overview/STARLIST_OVERVIEW.md` を確認（遅延時はWebで手直し）

**目標値**：`CI=OK / Reports=<n> / Gitleaks=0 / LinkErr=0`

**DoD**: Overview が上記値へ更新

---

## 6. SOT台帳の整合（自動＋微修正）（1–2分）

Docs Link Check が `verify-sot-ledger.sh` を自動実行。

失敗時は該当SOTのURL/JST表記をWeb修正→再実行で success。

### 1行SOT追記フォーマット（テンプレ）

```
merged: https://github.com/shochaso/starlist-app/pull/39 (2025-11-09 14:32 JST)
```

**DoD**: Docs Link Check **success**（SOT OK）

---

## 7. セキュリティ"戻し運用"（Todayは小さく1本）

* **Semgrep**：**2ルールだけ** ERROR へ昇格（1PR）
* **Trivy Config Strict**：`USER` 済みの1サービスからON（失敗なら戻して次回PRで対応）

**DoD**: Semgrep昇格PR=Green / Trivy strict復帰=1サービス以上

---

## 8. ブランチ保護（最終）（2分）

**Settings → Branches → Add rule（main）**

* Require status checks → `extended-security`, `Docs Link Check`（＋週次WF推奨）
* **Require linear history** / **Allow squash merge only**
* ダミーPRでChecks未合格時の**Merge不可**を確認

**DoD**: Mergeボタンが Checks 合格までブロック

---

## 9. 監査証跡の一本化（3分）

* **Security** タブ：SARIF（Semgrep/Gitleaks）を確認してスクショ
* **Artifacts**：週次成果を1件DL
* `docs/ops/FINAL_COMPLETION_REPORT_TEMPLATE.md` へ、Run IDs／Overview差分／SOT差分／スクショ3点を貼付

**DoD**: 1ページ完結の **最終完了レポート** を保存

---

## 10. 翌日以降の安定運用（継続タスク）

* Semgrep 昇格PR：**週2–3本**（細切れで確実にGreen化）
* Trivy strict：サービス行列で**順次ON**
* allowlist-sweep 自動PR：期限ラベルで棚卸し→古いものから削減

---

## そのまま貼れる：PRコメント本文（完成形）

```
=== UI-only Final Landing Report (PR #39) ===

Checks: ALL GREEN（extended-security / Docs Link Check）

Workflows: weekly-routine ✅ / allowlist-sweep ✅（手動Run）

Ops Health: CI=OK / Reports=<n> / Gitleaks=0 / LinkErr=0（Overview更新済）

SOT Ledger: OK（PR URL + JST時刻追記／Docs Link Check成功）

Security復帰: Semgrep 2ルール昇格PR起票 / Trivy Strict 一部ON



Next:

- 週次WFの定例運用（Artifacts/SARIFで可視化）

- Semgrep昇格PRを週2–3本、Trivy Strictは行列で順次ON

- allowlist自動PRの棚卸し（期限ラベル）
```

---

## 最終サインオフ基準（数値）

* Workflows：`weekly-routine` / `allowlist-sweep` **success（2/2）**
* Security：`rg-guard=0` / `Gitleaks=0`
* Overview：`CI=OK / LinkErr=0 / Gitleaks=0 / Reports>=1`
* SOT：Docs Link Check **success**
* Branch保護：未合格時 **Merge不可** を確認

---

## 付録A：UIだけで直す"よくある3症状"

* **rg-guard誤検知**：コメント文言を "Asset-based image loaders" に置換
* **Link Check不安定**：`.mlc.json` の `ignorePatterns` と `retry/timeout` を強化
* **Gitleaks擬陽性**：期限コメント付きallowlist（自動棚卸しWFがPR化）

---

## 付録B：UIオンリーの成果物テンプレ

* **PR コメント**：上記ブロックを貼付（`<n>` は実値）
* **完了レポ**：`docs/ops/FINAL_COMPLETION_REPORT_TEMPLATE.md` に Run IDs/スクショ/差分を記入

---

**作成日**: 2025-11-09  
**ステータス**: ✅ **10× Final Landing 超仕上げメガパック完成**

