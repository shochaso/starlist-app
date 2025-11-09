# Run workflow ガイド V2 追加完了

**作成日時**: 2025-11-09  
**実行者**: AI Assistant

---

## ✅ 更新ファイル

1. **`docs/ops/RUN_WORKFLOW_GUIDE.md`**（更新）
   - 付録V2：10倍密度・即実行パック｜最終仕上げセット（V2）を追加
   - 0) いますぐ実行 から 10) SOT 3行サマリ まで
   - ご提出いただきたい最小セット（4点）を追加

---

## 📋 追加内容（付録V2セクション）

1. **いますぐ実行（GUI最短ルート）**: 4ステップの簡潔な手順
2. **RUN_ID取得＆貼り付けテンプレ**: コマンドと提出テンプレ
3. **失敗時の即断（10行ダンプ）＋カテゴリ化**: 即断マトリクス付き
4. **証跡フォルダ作成（JSTタイムスタンプ）**: 標準ディレクトリ構成
5. **Security可視化（実査）メモ**: 記録方法
6. **PRコメント雛形**: RUN_ID確定後に貼付可能
7. **ブランチ保護 "貼るだけチェック"**: 監査TIPS付き
8. **rg-guard方針**: 今回触らず／方針のみ固定
9. **DoD 6点の確定ブロック**: OK/保留の判定
10. **ロールバック最短（安全版）**: 強制版の注意事項も記載
11. **SOT 3行サマリ**: そのまま貼付可能

---

## 🎯 ご提出いただきたい最小セット（4点）

1. `weekly-routine RUN_ID=… conclusion=…`
2. `allowlist-sweep RUN_ID=… conclusion=…`
3. `security_tab: … / artifacts: …`（2行）
4. DoD 6点ブロック（OK/保留）

この4点が揃い次第、**最終サインオフ**を発行いたします。

---

## 📚 ドキュメント構成

```
docs/ops/
├── RUN_WORKFLOW_GUIDE.md              ← 完全な運用Runbook（最新・推奨・V2追加済み）
├── FINAL_POLISH_UI_ROLLUP_CHECKS.md   ← Rollup Checks
├── SECURITY_DAILY_TICKETS.md          ← Security日次チケット雛形
├── OPS_OVERVIEW_UPDATE_GUIDE.md      ← Ops健康度UI更新ガイド
├── SOT_APPEND_RULES.md                ← SOT追記ルール
├── LINK_CHECK_PLAYBOOK.md             ← Link Check PLAYBOOK
├── RG_GUARD_FALSE_POSITIVE_RECIPES.md ← rg-guard誤検知回避レシピ
├── BRANCH_PROTECTION_VERIFICATION_CASES.md ← Branch Protection検証ケース
├── AUDIT_PROOF_SNAPSHOT_TEMPLATE.md   ← 監査スナップショット雛形
├── PM_SLACK_REPORT_TEMPLATES.md       ← PM向けSlack報告テンプレ
└── ...（その他のドキュメント）
```

---

## 🔧 いますぐ実行（GUI最短ルート）

1. **Actions → 左の `weekly-routine.yml`** をクリック
2. 右上 **Run workflow** → **Branch: main** → **Run**
3. 同様に **`allowlist-sweep.yml`** でも実行
4. すぐ下の「1) RUN_ID 取得コマンド」でIDと結論を採取

---

**作成完了時刻**: 2025-11-09  
**ステータス**: ✅ **Run workflow ガイド V2追加完了**

