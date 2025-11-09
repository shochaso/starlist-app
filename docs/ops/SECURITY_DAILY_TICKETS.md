# Security "戻し運用" 日次チケット雛形（UIオンリー）

**作成日**: 2025-11-09

---

## Semgrep Promote（1チケット=2ルール）

- タイトル: `chore(semgrep): promote <RULE_1>, <RULE_2> to ERROR`
- 対象: 誤検知ゼロ、変更影響小のルール
- 成果: CI green → マージ
- 添付: diff, CI run URL

---

## Trivy Config Strict（1チケット=1サービス）

- タイトル: `chore(trivy): strict on for <service>`
- 条件: Dockerfile `USER` 指定済み
- 成果: CI success
- 添付: run URL / 設定スクショ

---

## Gitleaks Allowlist 棚卸し

- タイトル: `chore(gitleaks): allowlist sweep (deadline reached)`
- 成果: 保持/削除の判断 → マージ
- 添付: 自動PRリンク / 差分スクショ

---

**作成日**: 2025-11-09  
**ステータス**: ✅ **Security日次チケット雛形完成**

