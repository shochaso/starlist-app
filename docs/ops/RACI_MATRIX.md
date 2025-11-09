# RACIマトリクス

**Status**: Active  
**Last Updated**: 2025-11-09  
**Owner**: Ops Team

---

<<<<<<< HEAD


| タスク | PM | SRE | Payments | Backend | QA |
|-------|----|-----|----------|---------|----|
| Go判断 | A | C | I | I | I |
| Day11実行 | C | R | I | I | I |
| Pricing監査 | I | C | R | C | I |
| バックアウト | A | R | C | C | I |

**凡例:**
- A: 最終責任（Accountable）
- R: 実行（Responsible）
- C: 協議（Consulted）
- I: 通知（Informed）


=======
## RACI定義

- **R (Responsible)**: 実行責任者
- **A (Accountable)**: 説明責任者（最終決定権）
- **C (Consulted)**: 相談先
- **I (Informed)**: 報告先

---

## Ops運用タスク

| タスク | R | A | C | I |
|--------|---|---|---|---|
| Ops週次ルーチン実行 | OPS | PM | SecOps | DevOps |
| CI監視・対応 | DevOps | OPS | SecOps | PM |
| セキュリティ復帰 | SecOps | PM | DevOps | OPS |
| 台帳運用（SOT） | QA | PM | OPS | DevOps |

---

## 詳細タスク

### Ops週次ルーチン実行

**R (Responsible)**: OPS Team
- 週次ルーチンの実行
- ログ収集・証跡管理

**A (Accountable)**: PM（ティム）
- 最終承認
- 運用方針の決定

**C (Consulted)**: SecOps
- セキュリティ観点での相談

**I (Informed)**: DevOps
- 実行結果の報告

---

### CI監視・対応

**R (Responsible)**: DevOps Team
- CIワークフローの監視
- 失敗時の対応

**A (Accountable)**: OPS Team
- CI運用の責任

**C (Consulted)**: SecOps
- セキュリティチェックの相談

**I (Informed)**: PM
- CI状態の報告

---

### セキュリティ復帰

**R (Responsible)**: SecOps Team
- Semgrep/Trivy/gitleaksの復帰実行
- セキュリティ厳格化の実施

**A (Accountable)**: PM（ティム）
- 復帰タイミングの決定
- 最終承認

**C (Consulted)**: DevOps
- インフラ観点での相談

**I (Informed)**: OPS
- 復帰結果の報告

---

### 台帳運用（SOT）

**R (Responsible)**: QA Team
- SOT台帳の更新
- 整合性検証

**A (Accountable)**: PM（ティム）
- 台帳運用方針の決定

**C (Consulted)**: OPS
- 運用観点での相談

**I (Informed)**: DevOps
- 台帳更新の報告

---

**作成日**: 2025-11-09
>>>>>>> 8abb626 (feat(ops): add ultra pack enhancements — Makefile, audit bundle, risk register, RACI matrix)
