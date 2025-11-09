# 最終仕上げ・UIオンリー実行チェックリスト（10×濃縮）

**目的**: UI操作オンリーで最終仕上げを完了する

**対象**: ターミナルを使わない運用者向け

**作成日**: 2025-11-09

---

## 0) 入口確定（30秒）

* PR #39 は**マージ済み**（確認OK）
* `weekly-routine.yml` / `allowlist-sweep.yml` が **main** に存在（Actionsに表示されること）

**合格ライン**：Actions 画面で両ワークフローが一覧に出ている

**現在の状態**: ✅ PR #39はマージ済み（2025-11-09T09:14:30Z）

---

## 1) 週次WFの通電（2〜3分）

### 手順

1. Actions → **weekly-routine** → **Run workflow** をクリック
2. Actions → **allowlist-sweep** → **Run workflow** をクリック
3. 各ワークフローの Run ページで **conclusion=success** を確認
4. Artifacts を1件ダウンロード（監査保管）

**詳細手順**: `docs/ops/RUN_WORKFLOW_GUIDE.md` を参照

**合格ライン**：両方 success、Artifacts ダウンロード完了

---

## 2) Ops健康度の更新（1分）

### 手順

1. `docs/overview/STARLIST_OVERVIEW.md` をWebエディタで開く
2. 必要に応じて**手動で**最新値へ更新
   - 目標：`CI=OK / Reports=（最新件数）/ Gitleaks=0 / LinkErr=0`

**合格ライン**：上記4項目が最新値で保存済み

---

## 3) SOT台帳の整合（自動→微修正）（2分）

### 手順

1. Actions → **Docs Link Check** が走って **success** になることを確認
2. 失敗が出たら、対象SOTに `merged: <PR URL> (YYYY-MM-DD HH:mm JST)` を追記して保存→再実行

**SOT追記フォーマット**:
```
merged: https://github.com/shochaso/starlist-app/pull/39 (2025-11-09 14:32 JST)
```

**合格ライン**：Docs Link Check が success

---

## 4) セキュリティ"戻し運用"の一歩（3〜5分）

### Semgrep

* **2ルールだけ** ERROR に昇格するPRをUIから作成（ドキュメントのサンプルに沿う）

### Trivy(Config)

* `USER` 指定済みのサービスを **1件だけ** strict ON（失敗したら次のサービスで）

**合格ライン**：Semgrep昇格PRが **Green**／Trivy strictが **1サービス success**

---

## 5) ブランチ保護の最終設定（2分）

### 手順

1. **Settings → Branches → Add rule（main）**
2. 以下を設定：
   * Require status checks：`extended-security`, `Docs Link Check`（＋週次WF推奨）
   * Require linear history：ON
   * Allow squash merge only：ON
3. テスト用のダミーPRで **Checks未合格時はマージ不可** を確認

**合格ライン**：Checks未合格では Merge ボタンがブロック

---

## 6) 監査証跡の一本化（3分）

### 手順

1. **Security タブ**：SARIF（Semgrep/Gitleaks）を1枚スクショ
2. **Actions**：Artifacts を1件DLして保管
3. `docs/ops/FINAL_COMPLETION_REPORT_TEMPLATE.md` に以下を記入して保存：
   * Run IDs（週次・allowlist・Docs Link Check）
   * Overview 抜粋（更新前→更新後の差分）
   * SOT 差分（追記行）
   * スクショ3点（貼付）

**合格ライン**：上記を1ページで完結

---

## 7) PM報告（PRコメント貼付）（1分）

以下の本文を **最新数値に差し替えて** PR（もしくは運用スレ）へ貼ってください。

```
=== UI-only Final Landing — Completion Report ===

Workflows: weekly-routine ✅ / allowlist-sweep ✅

Ops Health: CI=OK / Reports=<n> / Gitleaks=0 / LinkErr=0（Overview更新済）

SOT Ledger: OK（PR URL + JST時刻追記／Docs Link Check成功）

Security戻し運用: Semgrep 2ルール昇格PR起票 / Trivy Strict 一部ON

Branch Protection: main に必須Checks設定（lin. history / squashのみ）



Next:

- 週次WFの定例運用（Artifacts/SARIFで可視化）

- Semgrep昇格を週2–3本、Trivy Strictは行列で順次ON

- allowlist 自動PRの棚卸し（期限ラベル）
```

---

## 監査サマリー（JSONテンプレ／そのまま貼付可）

```json
{
  "date_jst": "2025-11-09",
  "workflows": {
    "weekly_routine": {"run_id": "<RID>", "conclusion": "success"},
    "allowlist_sweep": {"run_id": "<RID>", "conclusion": "success"},
    "docs_link_check": {"run_id": "<RID>", "conclusion": "success"}
  },
  "ops_health": {"CI": "OK", "Reports": "<n>", "Gitleaks": 0, "LinkErr": 0},
  "sot_ledger": {"status": "OK", "note": "PR URL + JST時刻追記済み"},
  "security_rehardening": {
    "semgrep_rules_promoted": 2,
    "trivy_config_strict_services_on": 1
  },
  "branch_protection": {
    "required_checks": ["extended-security", "Docs Link Check"],
    "linear_history": true,
    "squash_only": true
  },
  "artifacts_proof": {
    "security_sarif": "captured",
    "weekly_artifact": "downloaded"
  }
}
```

---

## クイックリファレンス（UIで詰まりやすい箇所の最短復旧）

### rg-guard 誤検知

コメントの `Image.asset` / `SvgPicture.asset` という文字列を
→ `Asset-based image loaders` に置換（コード直参照は禁止・Registry/CDN経由で統一）

### Link Check 不安定

`.mlc.json` の `ignorePatterns` と `retryOn429/ retryCount` を維持（既に雛形あり）

### Gitleaks 擬陽性

`.gitleaks.toml` に期限付き allowlist（allowlist-sweep が週次で棚卸し）

---

## 本日の"完了"判定（数値でサインオフ）

* Workflows：**2/2 success**
* Overview：`CI=OK / LinkErr=0 / Gitleaks=0 / Reports=実値更新`
* Docs Link Check：**success**（SOT整合OK）
* Security戻し運用：Semgrep **+2ルール**、Trivy strict **+1サービス**
* Branch保護：**未合格時マージ不可**を確認
* 監査：**1ページの完了レポ**（Run IDs／差分／スクショ）

---

---

## 最終5点（抜け漏れ防止）

1. **Artifactsのファイル名と保管先**を明記（例：`/ops/audit/YYYYMMDD/`）
2. **Overview更新の差分（Before/After）** を1行でメモ
3. **SOT追記の行数と対象PR** を記録（例：`DAY12_SOT_DIFFS.md +1行 (PR#39)`）
4. **Semgrep/Trivyの当日進捗**（昇格数・成功サービス数）
5. **ブランチ保護テストの結果**（未合格時マージ不可＝OK）

---

## 関連ドキュメント

* **FINAL_POLISH_UI_OPERATOR_GUIDE.md**: UIオンリー実行オペレーターガイド（10×拡張）
* **FINAL_POLISH_UI_QA_CHECKSHEET.md**: UIオンリー受入検収シート
* **FINAL_SECURITY_REHARDENING_SOP.md**: セキュリティ"戻し運用"SOP
* **FINAL_PM_REPORT_TEMPLATES.md**: PM報告テンプレート集
* **RUN_WORKFLOW_GUIDE.md**: Run workflow ガイド

---

**作成日**: 2025-11-09  
**ステータス**: ✅ **最終仕上げ・UIオンリー実行チェックリスト完成**

