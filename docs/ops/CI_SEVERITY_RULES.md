# CI 重大度ルール（赤/黄/緑）

## 概要

CIジョブの結果を重大度に応じて分類し、適切な対応を定義します。

## 重大度分類

| 重大度 | 色 | 意味 | 対応 | 例 |
|--------|-----|------|------|-----|
| **Critical** | 🔴 赤 | 即座に対応が必要 | マージブロック、即時修正 | セキュリティ脆弱性、ビルド失敗 |
| **Warning** | 🟡 黄 | 注意が必要だがマージ可能 | 次回PRで修正 | リンター警告、非推奨API使用 |
| **Info** | 🟢 緑 | 問題なし | 対応不要 | すべてのチェック通過 |

## 各CIジョブの重大度ルール

### Security Audit (`security-audit.yml`)

| チェック | Critical | Warning | Info |
|---------|----------|---------|------|
| `pnpm audit` | 高/中脆弱性 | 低脆弱性 | 脆弱性なし |
| `dart pub outdated` | 重大な更新漏れ | 軽微な更新漏れ | 最新 |
| `Semgrep` | Critical/High | Medium/Low | 問題なし |
| `Gitleaks` | 新規シークレット検出 | 既知の例外 | 検出なし |
| `Trivy` | Critical/High | Medium/Low | 問題なし |

### Extended Security (`extended-security.yml`)

| チェック | Critical | Warning | Info |
|---------|----------|---------|------|
| `Gitleaks` | 新規シークレット検出 | 既知の例外 | 検出なし |
| `Semgrep` | Critical/High | Medium/Low | 問題なし |
| `Trivy` | Critical/High | Medium/Low | 問題なし |
| `RLS Audit` | RLS無効テーブル | RLS有効だがポリシーなし | すべてRLS有効 |

### Docs Link Check (`docs-link-check.yml`)

| チェック | Critical | Warning | Info |
|---------|----------|---------|------|
| `markdown-link-check` | 外部リンク切れ（5件以上） | 外部リンク切れ（1-4件） | リンク切れなし |
| `docs:preflight` | 更新日付/差分ログ失敗 | 警告のみ | 成功 |

### Lint (`lint.yml`)

| チェック | Critical | Warning | Info |
|---------|----------|---------|------|
| `pnpm lint` | エラー | 警告 | 問題なし |
| `dart analyze` | エラー | 警告 | 問題なし |

## マージポリシー

### Critical（赤）の場合

- **マージブロック**: PRをマージできない
- **対応**: 即座に修正し、再実行
- **例外**: 緊急リリースの場合のみ、承認者の明示的な承認が必要

### Warning（黄）の場合

- **マージ可能**: PRをマージできるが、次回PRで修正が必要
- **対応**: Issueを作成し、次回PRで対応
- **例外**: 既知の問題で、修正計画がある場合はマージ可能

### Info（緑）の場合

- **マージ可能**: 問題なし、即座にマージ可能

## 例外管理

### 既知の問題

| ID | 問題 | 重大度 | 対応期限 | 責任者 |
|----|------|--------|----------|--------|
| CI-001 | リンター警告（非推奨API） | Warning | 2025-12-31 | Backend |
| CI-002 | 低脆弱性（pnpm audit） | Warning | 2025-12-31 | SRE |

### 緊急リリース

緊急リリースの場合、Criticalでもマージ可能（承認者の明示的な承認が必要）:
1. Issueを作成し、緊急リリースの理由を記載
2. 承認者（PM/SRE）の承認を得る
3. PRに「緊急リリース承認済み」ラベルを付与
4. マージ後、即座に修正PRを作成

## 参考

- `.github/workflows/security-audit.yml` - セキュリティ監査ワークフロー
- `.github/workflows/extended-security.yml` - 拡張セキュリティワークフロー
- `.github/workflows/docs-link-check.yml` - ドキュメントリンクチェックワークフロー
- `docs/ops/GITLEAKS_EXCEPTIONS.md` - Gitleaks例外管理表

---

**Last Updated**: 2025-11-08
**Maintainer**: SRE Team


## 概要

CIジョブの結果を重大度に応じて分類し、適切な対応を定義します。

## 重大度分類

| 重大度 | 色 | 意味 | 対応 | 例 |
|--------|-----|------|------|-----|
| **Critical** | 🔴 赤 | 即座に対応が必要 | マージブロック、即時修正 | セキュリティ脆弱性、ビルド失敗 |
| **Warning** | 🟡 黄 | 注意が必要だがマージ可能 | 次回PRで修正 | リンター警告、非推奨API使用 |
| **Info** | 🟢 緑 | 問題なし | 対応不要 | すべてのチェック通過 |

## 各CIジョブの重大度ルール

### Security Audit (`security-audit.yml`)

| チェック | Critical | Warning | Info |
|---------|----------|---------|------|
| `pnpm audit` | 高/中脆弱性 | 低脆弱性 | 脆弱性なし |
| `dart pub outdated` | 重大な更新漏れ | 軽微な更新漏れ | 最新 |
| `Semgrep` | Critical/High | Medium/Low | 問題なし |
| `Gitleaks` | 新規シークレット検出 | 既知の例外 | 検出なし |
| `Trivy` | Critical/High | Medium/Low | 問題なし |

### Extended Security (`extended-security.yml`)

| チェック | Critical | Warning | Info |
|---------|----------|---------|------|
| `Gitleaks` | 新規シークレット検出 | 既知の例外 | 検出なし |
| `Semgrep` | Critical/High | Medium/Low | 問題なし |
| `Trivy` | Critical/High | Medium/Low | 問題なし |
| `RLS Audit` | RLS無効テーブル | RLS有効だがポリシーなし | すべてRLS有効 |

### Docs Link Check (`docs-link-check.yml`)

| チェック | Critical | Warning | Info |
|---------|----------|---------|------|
| `markdown-link-check` | 外部リンク切れ（5件以上） | 外部リンク切れ（1-4件） | リンク切れなし |
| `docs:preflight` | 更新日付/差分ログ失敗 | 警告のみ | 成功 |

### Lint (`lint.yml`)

| チェック | Critical | Warning | Info |
|---------|----------|---------|------|
| `pnpm lint` | エラー | 警告 | 問題なし |
| `dart analyze` | エラー | 警告 | 問題なし |

## マージポリシー

### Critical（赤）の場合

- **マージブロック**: PRをマージできない
- **対応**: 即座に修正し、再実行
- **例外**: 緊急リリースの場合のみ、承認者の明示的な承認が必要

### Warning（黄）の場合

- **マージ可能**: PRをマージできるが、次回PRで修正が必要
- **対応**: Issueを作成し、次回PRで対応
- **例外**: 既知の問題で、修正計画がある場合はマージ可能

### Info（緑）の場合

- **マージ可能**: 問題なし、即座にマージ可能

## 例外管理

### 既知の問題

| ID | 問題 | 重大度 | 対応期限 | 責任者 |
|----|------|--------|----------|--------|
| CI-001 | リンター警告（非推奨API） | Warning | 2025-12-31 | Backend |
| CI-002 | 低脆弱性（pnpm audit） | Warning | 2025-12-31 | SRE |

### 緊急リリース

緊急リリースの場合、Criticalでもマージ可能（承認者の明示的な承認が必要）:
1. Issueを作成し、緊急リリースの理由を記載
2. 承認者（PM/SRE）の承認を得る
3. PRに「緊急リリース承認済み」ラベルを付与
4. マージ後、即座に修正PRを作成

## 参考

- `.github/workflows/security-audit.yml` - セキュリティ監査ワークフロー
- `.github/workflows/extended-security.yml` - 拡張セキュリティワークフロー
- `.github/workflows/docs-link-check.yml` - ドキュメントリンクチェックワークフロー
- `docs/ops/GITLEAKS_EXCEPTIONS.md` - Gitleaks例外管理表

---

**Last Updated**: 2025-11-08
**Maintainer**: SRE Team

