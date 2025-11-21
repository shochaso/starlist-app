---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



# Security Hardening Roadmap

**Status**: Active  
**Last Updated**: 2025-11-09  
**Owner**: SecOps  
**Approved By**: PM

---

## 概要

このロードマップは、CI/CDパイプラインの「緑化維持」から「段階的厳格化」への移行計画を定義します。各項目は独立して実行可能で、リスクを最小化しながらセキュリティ基準を向上させます。

---

## 🎯 目標

1. **緑化維持**: CI/CDパイプラインの安定稼働を継続
2. **段階的厳格化**: 各セキュリティツールの設定を段階的に厳格化
3. **可視化**: 進捗と期限を明確に管理

---

## 📋 厳格化項目

### 1. Trivy Config 厳格化復帰

**現状**: `.trivyignore`に一時的なignore設定あり（期限コメント付き）

**復帰計画**:
- **前提条件**: Dockerfileの非root化（`USER app`）を主要サービスに横展開
- **段階**: サービス単位で`SKIP_TRIVY_CONFIG=0`に戻す
- **期限**: 各Dockerfile非root化完了後、1週間以内に復帰
- **Owner**: SecOps + DevOps
- **承認**: PM

**関連Issue**: `sec: trivy config strict re-enable (service-by-service)`

---

### 2. Semgrep ルール復帰

**現状**: `.semgrep.yml`で一部ルールがWARNING化（一時的措置）

**復帰計画**:
- **方法**: ルールID単位でWARNING→ERRORに段階復帰
- **手順**: `scripts/security/semgrep-promote.sh`を使用して小粒PR作成
- **期限**: ルールごとに個別設定（コード修正完了後、即時復帰）
- **Owner**: SecOps
- **承認**: PM

**関連Issue**: `sec: semgrep rule X restore to ERROR`

**対象ルール例**:
- `no-hardcoded-secret`: 現状ERROR（維持）
- `deno-fetch-no-http`: 現状WARNING（必要に応じてERROR復帰）

---

### 3. Gitleaks Allowlist 期限スイープ

**現状**: `.gitleaks.toml`にallowlist設定あり（期限メモ付き）

**復帰計画**:
- **方法**: 期限到来したallowlistエントリを自動検出・削除
- **自動化**: `.github/workflows/allowlist-sweep.yml`で週次実行
- **期限**: 各allowlistエントリに記載された期限日
- **Owner**: SecOps
- **承認**: PM

**関連Issue**: `sec: gitleaks allowlist cleanup (deadline sweep)`

**スイープ頻度**: 毎週月曜 00:00 UTC（09:00 JST）

---

## 📊 進捗管理

### 進捗テーブル

| 項目 | 現状 | 目標期限 | 進捗 | Owner | 承認 |
|------|------|----------|------|-------|------|
| Trivy Config | 一時ignore | サービス単位で段階復帰 | 0% | SecOps | PM |
| Semgrep Rules | 一部WARNING | ルール単位で段階復帰 | 0% | SecOps | PM |
| Gitleaks Allowlist | 期限メモ付き | 期限到来時に削除 | 0% | SecOps | PM |

### Trivy Config Strict復帰（サービス行列）

| Service                      | User非root | SKIP_TRIVY_CONFIG=0 | 備考 |
|-----------------------------|-----------:|--------------------:|------|
| cloudrun/ocr-proxy          |     ✅     |         ☐          | USER導入済。次週ON |
| edge/ops-summary-email      |     ☐      |         ☐          | USER適用後にON     |
| edge/ops-slack-summary      |     ☐      |         ☐          | 同上                 |

**復帰実行例**:
```bash
# ocr-proxy から順次
export SKIP_TRIVY_CONFIG=0
gh workflow run extended-security.yml
```

---

## 🔄 実行フロー

### フェーズ1: 準備（完了済み）
- ✅ CI/CDパイプラインの緑化
- ✅ 一時的な緩和設定の文書化
- ✅ 期限メモの追加

### フェーズ2: 前提条件整備（進行中）
- ⏳ Dockerfile非root化の横展開
- ⏳ Semgrepルールごとの修正状況確認
- ⏳ Gitleaks allowlist期限の確認

### フェーズ3: 段階的復帰（予定）
- ⏳ Trivy configのサービス単位復帰
- ⏳ Semgrepルールの個別復帰
- ⏳ Gitleaks allowlistの期限スイープ

---

## 🚨 ロールバック計画

各項目は独立してロールバック可能です：

1. **Trivy**: `.trivyignore`に該当エントリを再追加
2. **Semgrep**: `.semgrep.yml`で該当ルールをWARNINGに戻す
3. **Gitleaks**: `.gitleaks.toml`にallowlistエントリを再追加

---

## 📝 関連ドキュメント

- `.trivyignore` - Trivy ignore設定（期限コメント付き）
- `.semgrep.yml` - Semgrepルール設定
- `.gitleaks.toml` - Gitleaks allowlist設定
- `scripts/security/semgrep-promote.sh` - Semgrepルール復帰ヘルパー
- `.github/workflows/allowlist-sweep.yml` - Gitleaks allowlistスイープジョブ

---

## 🔗 GitHub Issues

以下のIssueを作成済み（進捗管理用）：

1. **Issue #36**: `sec: re-enable Trivy config (strict) service-by-service`
   - URL: https://github.com/shochaso/starlist-app/issues/36
   - 期限: 2025-12-15
   - Owner: SecOps
   - 依存: WS-G（Dockerfile非root化の横展開）

2. **Issue #37**: `sec: Semgrep rules restore to ERROR (batch-1)`
   - URL: https://github.com/shochaso/starlist-app/issues/37
   - 期限: 2025-12-20
   - Owner: SecOps
   - ツール: `scripts/security/semgrep-promote.sh`を使用

3. **Issue #38**: `sec: gitleaks allowlist deadline sweep`
   - URL: https://github.com/shochaso/starlist-app/issues/38
   - 期限: 2025-12-22
   - Owner: SecOps
   - 自動化: `.github/workflows/allowlist-sweep.yml`で週次検知

---

**作成日**: 2025-11-09  
**次回レビュー**: 2025-11-16（週次）

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
