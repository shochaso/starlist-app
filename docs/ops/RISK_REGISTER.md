# リスクレジスタ

**Status**: Active  
**Last Updated**: 2025-11-09  
**Owner**: Ops Team

---

## リスク一覧

### RISK-001: CI赤化

**説明**: Extended Securityワークフローが失敗し、CIが赤化する

**影響**: 
- PRマージがブロックされる
- 開発フローの停滞

**確率**: 中
**影響度**: 高

**対策**:
- 失敗時の自動切り分けスクリプト（`scripts/ops/collect-weekly-proof.sh`）
- ログ末尾120行の自動抽出
- 代表的エラーの暫定回避手順（`docs/ops/ROLLBACK_PROCEDURES.md`）

**ステータス**: 対策済み

---

### RISK-002: Link Check不安定

**説明**: Markdown Link Checkが不安定で、CIが失敗する

**影響**:
- ドキュメント更新のブロック
- リンク切れの検出漏れ

**確率**: 中
**影響度**: 中

**対策**:
- `scripts/docs/update-mlc.js`で自動更新
- `.mlc.json`のretry設定（`retryOn429: true`, `retryCount: 3`）
- 暫定回避手順（`docs/ops/ROLLBACK_PROCEDURES.md`）

**ステータス**: 対策済み

---

### RISK-003: gitleaks擬陽性

**説明**: gitleaksが誤検知し、CIが失敗する

**影響**:
- セキュリティチェックの信頼性低下
- 開発フローの停滞

**確率**: 低
**影響度**: 中

**対策**:
- `.gitleaks.toml` allowlistに期限コメントで一時登録
- `allowlist-sweep.yml`で週次自動刈り取り
- 期限到来時に自動PR作成

**ステータス**: 対策済み

---

## リスク管理プロセス

1. **リスク識別**: 週次ルーチンで自動検出
2. **リスク評価**: 確率×影響度で優先順位付け
3. **リスク対策**: 自動化スクリプト・手順書で対応
4. **リスク監視**: 週次証跡収集で追跡

---

**作成日**: 2025-11-09
