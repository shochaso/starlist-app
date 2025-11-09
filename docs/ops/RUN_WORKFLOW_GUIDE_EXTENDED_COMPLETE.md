# Run workflow ガイド拡張版 作成完了

**作成日時**: 2025-11-09  
**実行者**: AI Assistant

---

## ✅ 更新ファイル

1. **`docs/ops/RUN_WORKFLOW_GUIDE.md`**（更新）
   - 付録：10倍密度・即実行パック拡張版を追加
   - 1) オペレーター1枚紙 から 10) 仕上げチェックリスト まで
   - 完全な運用Runbookとして完成

---

## 📋 追加内容

### 付録セクション

1. **オペレーター1枚紙（最短ルート）**: UI派とCLI派の両方の手順
2. **成功判定・提出テンプレ（4点）**: そのまま貼って提出可能
3. **失敗時の即時切り分け（10行抜粋×3段）**: 原因カテゴリを1分以内に確定
4. **UI↔CLI 相互代替ルート表**: 操作の相互変換表
5. **RUN_ID 記録フォーマット**: JSON/Markdown形式
6. **監査ログの標準ディレクトリ構成**: 標準的な保存場所
7. **ブランチ保護 "貼るだけチェック"**: 設定項目のチェックリスト
8. **FAQ（10本）**: よくある質問と回答
9. **ロールバック最短（安全版／強制版）**: ロールバック手順
10. **仕上げチェックリスト（SOT用3行サマリ）**: DoDとSOT追記フォーマット

---

## 🎯 完全な運用Runbookの特徴

1. **UI操作オンリー**: すべてGitHub UIとWebエディタで完結
2. **CLI代替**: UIが混み合う時でも即実行可能
3. **即時切り分け**: 失敗時の原因を1分以内に特定
4. **相互代替**: UIとCLIの操作を相互変換可能
5. **標準化**: 監査ログの保存場所とフォーマットを統一
6. **FAQ**: よくある質問に即答可能
7. **ロールバック**: 安全版と強制版の両方を提供
8. **SOT対応**: 3行サマリでSOTに追記可能

---

## 📚 ドキュメント構成

```
docs/ops/
├── RUN_WORKFLOW_GUIDE.md              ← 完全な運用Runbook（最新・推奨）
├── FINAL_POLISH_UI_CHECKLIST.md       ← 最終仕上げチェックリスト
├── FINAL_POLISH_UI_OPERATOR_GUIDE.md  ← UIオンリー実行オペレーターガイド
├── FINAL_POLISH_UI_QA_CHECKSHEET.md   ← UIオンリー受入検収シート
├── FINAL_SECURITY_REHARDENING_SOP.md  ← セキュリティ"戻し運用"SOP
├── FINAL_PM_REPORT_TEMPLATES.md       ← PM報告テンプレート集
├── 10X_FINAL_LANDING_MEGAPACK.md      ← 超仕上げメガパック
├── UI_ONLY_FINAL_LANDING_ROUTE.md     ← UIオンリー最終着地ルート
├── UI_ONLY_FINAL_LANDING_PACK.md      ← 詳細パック（20×）
├── UI_ONLY_QUICK_REFERENCE.md         ← クイックリファレンス
├── FINAL_COMPLETION_REPORT_TEMPLATE.md ← 実績記録テンプレート
└── QUICK_FIX_PRESETS.md               ← 微修正プリセット
```

---

## 🔧 成功判定・提出テンプレ（4点）

```
weekly-routine RUN_ID=XXXXXXXX conclusion=success
allowlist-sweep RUN_ID=YYYYYYYY conclusion=success

security_tab: SARIF visible (Semgrep/Gitleaks)=YES
artifacts: gitleaks/sbom downloaded=YES
```

---

## 📊 SOT 3行（提出フォーマット）

```
成果：weekly/allowlist を main で手動起動し RUN_ID 確定、Securityタブで SARIF/Artifacts を確認。
検証：ログ10行抜粋でエラー無／DoD6点=OK／ブランチ保護は必須チェックを適用。
次：監査ログを out/security/<date>/ に保存し、SOTへ3行サマリを追記。
```

---

**作成完了時刻**: 2025-11-09  
**ステータス**: ✅ **Run workflow ガイド拡張版作成完了（完全な運用Runbook）**

