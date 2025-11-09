# Run workflow ガイド 作成完了

**作成日時**: 2025-11-09  
**実行者**: AI Assistant

---

## ✅ 作成ファイル

1. **`docs/ops/RUN_WORKFLOW_GUIDE.md`**
   - Run workflow ボタン到達 → 手動実行 → RUN_ID取得 → 成功確認 ガイド
   - GUIでの到達ルート（A〜Eの方法）
   - CLIでの代替方法
   - 「Run workflow」が出ない時の原因と対処法
   - 実行後の提出テンプレ
   - Security可視化と成果物の確認
   - ワンストップ最短チェック

2. **`docs/ops/FINAL_POLISH_UI_CHECKLIST.md`**（更新）
   - RUN_WORKFLOW_GUIDE.mdへの参照を追加

---

## 📋 現在の状態

### PR #39

- **状態**: ✅ マージ済み
- **マージ時刻**: 2025-11-09T09:14:30Z
- **マージコミット**: c6ce2db26bd2e396f00582ce950af5b708f915c9
- **URL**: https://github.com/shochaso/starlist-app/pull/39

### ワークフローファイル

- ✅ `weekly-routine.yml`: `workflow_dispatch`含む（mainブランチに反映済み）
- ✅ `allowlist-sweep.yml`: `workflow_dispatch`含む（mainブランチに反映済み）

---

## 🎯 Run workflow ガイドの特徴

1. **GUIでの到達ルート**: 5つの方法（A〜E）を提示
2. **CLIでの代替**: UIが混み合う時でも即実行可能
3. **トラブルシューティング**: 「Run workflow」が出ない時の原因と対処法を表形式で提示
4. **実行後の提出テンプレ**: RUN_IDとconclusionを共有する形式を提示
5. **ワンストップ最短チェック**: UI派向けの簡潔な手順

---

## 📚 ドキュメント構成

```
docs/ops/
├── RUN_WORKFLOW_GUIDE.md              ← Run workflow ガイド（最新・推奨）
├── FINAL_POLISH_UI_CHECKLIST.md       ← 最終仕上げチェックリスト
├── 10X_FINAL_LANDING_MEGAPACK.md      ← 超仕上げメガパック
├── UI_ONLY_FINAL_LANDING_ROUTE.md     ← UIオンリー最終着地ルート
├── UI_ONLY_FINAL_LANDING_PACK.md      ← 詳細パック（20×）
├── UI_ONLY_QUICK_REFERENCE.md         ← クイックリファレンス
├── FINAL_COMPLETION_REPORT_TEMPLATE.md ← 実績記録テンプレート
└── QUICK_FIX_PRESETS.md               ← 微修正プリセット
```

---

## 🔧 よくある問題と対処法

| 症状 | 主因 | すぐの対処 |
|------|------|----------|
| ボタン自体が出ない | `workflow_dispatch:` がない / 反映待ち | `main` 上のファイルを確認。UI再読込。 |
| Select branch に main が無い | ファイルが main に未反映 | PRを **merge**。 |
| 押せるが即 422 | 反映遅延／ファイル名不一致 | UIから実行 → 数十秒後に CLI 再試行。 |
| 押すと Permission denied | 権限不足 | Repo 権限を **Write** 以上へ。 |
| 走るが途中で失敗 | Node/Secrets/ワークフロー内条件 | エラーログ上位10行を確認。 |

---

## 📊 実行後の提出テンプレ

```
weekly-routine RUN_ID=XXXXXXXX conclusion=success
allowlist-sweep RUN_ID=YYYYYYYY conclusion=success

security_tab: SARIF visible (Semgrep/Gitleaks)=YES
artifacts: gitleaks/sbom downloaded=YES
```

---

**作成完了時刻**: 2025-11-09  
**ステータス**: ✅ **Run workflow ガイド作成完了**

