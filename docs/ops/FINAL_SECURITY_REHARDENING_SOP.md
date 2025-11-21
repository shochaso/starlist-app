---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# セキュリティ"戻し運用"SOP（UIオンリー）

**目的**: 緑化を維持しながら段階的に強度を復帰する。常に「小さく戻して緑で着地」を原則とする。

**作成日**: 2025-11-09

---

## Semgrep（週2–3本）

### 手順

1. **ルール選定**：直近7日で誤検出がない / 変更影響が小さいものを2件
2. **PR作成**：タイトル `chore(semgrep): promote <rule1>, <rule2> to ERROR`
3. **CI success を確認** → マージ
4. **週報に記録**（ルールID / 影響ファイル / 備考）

### PR本文テンプレート

```
## 目的
Semgrepルールを段階的にERRORへ昇格（緑化維持）

## 対象ルール
- rule1: <説明>
- rule2: <説明>

## 影響範囲
- ファイル数: <n>
- 変更内容: <説明>

## DoD
- [ ] CI success
- [ ] 影響ファイルの確認済み
- [ ] 週報に記録済み
```

---

## Trivy Config（サービス行列）

### 手順

1. `USER` 指定済みサービスから1件選ぶ
2. ワークフロー設定で strict をON
3. success を確認 → 行列に✅
4. 失敗時は当日無理に通さず、別サービスへスイッチ

### サービス行列（例）

| サービス | USER指定 | Strict ON | 備考 |
|---------|---------|-----------|------|
| cloudrun/ocr-proxy | ✅ | ✅ | 完了 |
| edge/ops-summary-email | ✅ | ⏳ | 次回 |
| edge/ops-slack-summary | ✅ | ⏳ | 次回 |

---

## Gitleaks Allowlist（自動棚卸し）

- 期限到来のAllowlistは自動PRが来る
- UIで差分確認 → 妥当なら削除/維持を判断 → マージ

### レビューポイント

- 期限が過ぎているか
- 該当シークレットが実際に存在するか
- 削除しても問題ないか

---

**作成日**: 2025-11-09  
**ステータス**: ✅ **セキュリティ"戻し運用"SOP完成**

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
