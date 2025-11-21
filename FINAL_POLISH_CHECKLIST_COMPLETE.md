---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# 最終仕上げ・UIオンリー実行チェックリスト 作成完了

**作成日時**: 2025-11-09  
**実行者**: AI Assistant

---

## ✅ 作成ファイル

1. **`docs/ops/FINAL_POLISH_UI_CHECKLIST.md`**
   - 最終仕上げ・UIオンリー実行チェックリスト（10×濃縮）
   - 0) 入口確定 から 7) PM報告 まで
   - 監査サマリー（JSONテンプレ）、クイックリファレンス、完了判定を含む

2. **`docs/ops/FINAL_COMPLETION_REPORT_TEMPLATE.md`**（更新）
   - 監査サマリー（JSONテンプレ）を追加

---

## 📋 現在の状態

### PR #39

- **状態**: ✅ マージ済み
- **マージ時刻**: 2025-11-09T09:14:30Z
- **マージコミット**: c6ce2db26bd2e396f00582ce950af5b708f915c9
- **URL**: https://github.com/shochaso/starlist-app/pull/39

### 次のステップ

1. **週次WFの通電**: GitHub UIから **Actions** → **weekly-routine** / **allowlist-sweep** → **Run workflow**
2. **Ops健康度の更新**: `docs/overview/STARLIST_OVERVIEW.md`を確認
3. **SOT台帳の整合**: Docs Link Checkの自動実行を確認
4. **セキュリティ"戻し運用"**: Semgrep 2ルール昇格PR作成
5. **ブランチ保護**: **Settings → Branches → Add rule（main）**
6. **監査証跡の一本化**: Securityタブ、Artifacts、完了レポート作成
7. **PM報告**: PRコメントを貼付

---

## 🎯 最終仕上げチェックリストの特徴

1. **UI操作オンリー**: すべてGitHub UIとWebエディタで完結
2. **7ステップで完全着地**: 入口確定からPM報告まで
3. **数値化された判定基準**: 各ステップで明確な合格ラインを提示
4. **監査サマリー（JSONテンプレ）**: そのまま貼り付け可能
5. **クイックリファレンス**: よくあるエラーを最短で修正する方法を提供

---

## 📚 ドキュメント構成

```
docs/ops/
├── FINAL_POLISH_UI_CHECKLIST.md        ← 最終仕上げチェックリスト（最新・推奨）
├── 10X_FINAL_LANDING_MEGAPACK.md       ← 超仕上げメガパック
├── UI_ONLY_FINAL_LANDING_ROUTE.md      ← UIオンリー最終着地ルート
├── UI_ONLY_FINAL_LANDING_PACK.md       ← 詳細パック（20×）
├── UI_ONLY_QUICK_REFERENCE.md          ← クイックリファレンス
├── FINAL_COMPLETION_REPORT_TEMPLATE.md ← 実績記録テンプレート
└── QUICK_FIX_PRESETS.md                ← 微修正プリセット
```

---

## 🔧 クイックリファレンス（UIで詰まりやすい箇所）

| エラー | 対処方法 | 参照 |
|--------|---------|------|
| rg-guard誤検知 | コメント文言を "Asset-based image loaders" に置換 | `QUICK_FIX_PRESETS.md` |
| Link Check不安定 | `.mlc.json` に `retryOn429: true`, `retryCount: 2` を追加 | `QUICK_FIX_PRESETS.md` |
| Gitleaks擬陽性 | `.gitleaks.toml` に期限付きallowlistを追加 | `QUICK_FIX_PRESETS.md` |

---

## 📊 本日の"完了"判定（数値でサインオフ）

* Workflows：**2/2 success**
* Overview：`CI=OK / LinkErr=0 / Gitleaks=0 / Reports=実値更新`
* Docs Link Check：**success**（SOT整合OK）
* Security戻し運用：Semgrep **+2ルール**、Trivy strict **+1サービス**
* Branch保護：**未合格時マージ不可**を確認
* 監査：**1ページの完了レポ**（Run IDs／差分／スクショ）

---

**作成完了時刻**: 2025-11-09  
**ステータス**: ✅ **最終仕上げ・UIオンリー実行チェックリスト作成完了**

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
