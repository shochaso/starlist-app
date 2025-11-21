---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# OIDC Rollout Plan

## 概要

GitHub Actions Secretsの削減とセキュリティ向上のため、OIDC（OpenID Connect）認証への移行を計画します。

## 現状の問題

- GitHub Actions Secretsに多くの認証情報を保存している
- Secretsのローテーションが困難
- 権限管理が複雑

## OIDC移行の利点

1. **Secrets削減**: 長期保存の認証情報を削減
2. **自動ローテーション**: トークンの自動更新
3. **最小権限**: 必要な権限のみを付与
4. **監査性**: 認証ログの追跡が容易

## 移行対象

### Phase 1: Cloud Provider認証
- AWS (IAM Role)
- GCP (Service Account)
- Azure (Managed Identity)

### Phase 2: 外部サービス認証
- Supabase (Service Role Key)
- Stripe (API Key)
- Resend (API Key)

### Phase 3: 内部サービス認証
- Linear API
- GitHub API (一部)

## 実装方針

### 1. GitHub Actions OIDC設定

```yaml
permissions:
  id-token: write
  contents: read
```

### 2. Cloud Provider側の設定

- IAM Role/Policyの作成
- OIDC Providerの設定
- Trust Policyの設定

### 3. ワークフロー側の変更

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::ACCOUNT:role/GitHubActionsRole
    aws-region: ap-northeast-1
```

## 移行スケジュール

- **2025-Q1**: Phase 1 (Cloud Provider)
- **2025-Q2**: Phase 2 (外部サービス)
- **2025-Q3**: Phase 3 (内部サービス)

## ロールバック計画

- Secretsを一時的に保持（移行完了まで）
- 段階的な移行で影響範囲を最小化
- 各Phase完了後に検証期間を設ける

## 参考資料

- [GitHub Actions OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [AWS IAM OIDC Provider](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
