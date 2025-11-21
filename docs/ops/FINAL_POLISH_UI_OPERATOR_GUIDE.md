---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# 最終仕上げ・UIオンリー実行オペレーターガイド（10×拡張）

本ガイドは、GitHub UI / エディタのみで「週次WF通電 → Ops健康度更新 → SOT整合 → セキュリティ復帰 → ブランチ保護 → 監査証跡作成」までを確実に完了させるための運用書です。

**作成日**: 2025-11-09

---

## フェーズと合格ライン（DoD）

### 1) 週次WF通電

- Actions で `weekly-routine` / `allowlist-sweep` を Run → 両方 **success**
- Artifacts を1件DL（監査保管）

**詳細手順**: `docs/ops/RUN_WORKFLOW_GUIDE.md` を参照

---

### 2) Ops健康度更新

- `docs/overview/STARLIST_OVERVIEW.md` を UI編集
- `CI=OK / Reports=<最新> / Gitleaks=0 / LinkErr=0` で保存

---

### 3) SOT整合（自動→微修正）

- Actions: **Docs Link Check = success**
- 失敗時は該当SOTに `merged: <PR URL> (YYYY-MM-DD HH:mm JST)` を追記→保存

**SOT追記フォーマット**:
```
merged: https://github.com/shochaso/starlist-app/pull/39 (2025-11-09 14:32 JST)
```

---

### 4) セキュリティ「戻し運用」

- Semgrep：**2ルール**だけ ERROR に昇格するPRを作成（テンプレ参照）
- Trivy（Config）：`USER`指定済みのサービスから**1件** strict ON（失敗したら別サービス）

**詳細手順**: `docs/ops/FINAL_SECURITY_REHARDENING_SOP.md` を参照

---

### 5) ブランチ保護

- Settings→Branches→main
- 必須チェック：`extended-security` / `Docs Link Check`（＋週次WF推奨）
- Linear history=ON / Squash only=ON
- ダミーPRで「未合格時マージ不可」を確認

---

### 6) 監査証跡

- Securityタブ（SARIF）スクショ
- Actions（Artifacts）DL
- `FINAL_COMPLETION_REPORT.md` に記録（テンプレ参照）

**詳細手順**: `docs/ops/FINAL_COMPLETION_REPORT_TEMPLATE.md` を参照

---

## よくある詰まりと対処

### rg-guard

コメント内の `Image.asset` 等の**文字列**が検知 → 「Asset-based image loaders」に表現変更

**詳細**: `docs/ops/QUICK_FIX_PRESETS.md` を参照

---

### Link Check

`.mlc.json` の ignore / retry を維持（既存方針）

**詳細**: `docs/ops/QUICK_FIX_PRESETS.md` を参照

---

### Gitleaks

期限付き allowlist（週次の sweep が棚卸し）

**詳細**: `docs/ops/QUICK_FIX_PRESETS.md` を参照

---

### Trivy(Config)

Dockerfile `USER` 指定済サービスから順次ON

**詳細**: `docs/ops/FINAL_SECURITY_REHARDENING_SOP.md` を参照

---

**作成日**: 2025-11-09  
**ステータス**: ✅ **UIオンリー実行オペレーターガイド完成**

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
