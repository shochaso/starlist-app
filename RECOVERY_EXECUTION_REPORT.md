---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# 即時リカバリ手順 実行レポート

**実行日時**: 2025-11-09  
**実行者**: AI Assistant

---

## 0) セーフティ（ブランチ健全化）

✅ **完了**: ブランチ `hotfix/ops-ci-rg-YYYYMMDD-HHMMSS` を作成

---

## 1) rg-guard検出の是正

### 事前スキャン結果

**検出箇所**:
- `lib/features/star_data/presentation/widgets/star_data_card.dart:252`
- `lib/src/features/subscription/presentation/screens/payment_method_screen.dart`（複数箇所: 318, 332, 364, 394, 425, 452）

### 対応方針

これらのファイルは`lib/services/`外にあるため、`rg-guard`の制限対象外の可能性がありますが、統一性のためCDNベースの解決に置き換えることを推奨します。

**検証**: 再スキャン結果を確認中

---

## 2) 定期ワークフローに workflow_dispatch を付与

✅ **確認**: `workflow_dispatch:` が既に存在

**ファイル**:
- `.github/workflows/weekly-routine.yml`: `workflow_dispatch:` 存在
- `.github/workflows/allowlist-sweep.yml`: `workflow_dispatch:` 存在

**手動実行テスト**: 実行中

---

## 3) PR #22 のマージ可否を確定

**状態確認中**: `gh pr view 22` で詳細を取得中

---

## 4) セキュリティ／アーティファクト観察

**Extended Security RUN確認中**: `gh run list` で取得中

---

## 6) 仕上げ：最終SOT & 受付判定（DoD）

**DoDチェック**:
- [ ] 更新導線はmanualRefreshへ統一
- [ ] フィルタ更新はsetFilterのみ
- [ ] 401/403で赤バッジ＋SnackBar
- [ ] 30s タイマーは常に1本（多重起動なし）
- [ ] providers-only CI 緑 & ローカル再現OK
- [ ] ドキュメント単体で再現可（OPS_DASHBOARD_GUIDE）

**確認中**: コードベースを検索中

---

**実行完了時刻**: 2025-11-09  
**ステータス**: 🔄 **実行中**

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
