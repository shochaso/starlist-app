---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



flowchart TB
  A[docs/overview/COMMON_DOCS_INDEX.md<br/>共通ドキュメント索引<br/>← 索引中心]:::core
  
  %% 凡例: エッジの意味
  %% --> : 参照関係（入出力・所有者・SOP）
  %% -.-> : 参照シェル（軽い参照）

  %% OVERVIEW
  A --> B[docs/overview/STARLIST_OVERVIEW.md<br/>プロダクト全景と要約<br/>β版: KPI表・ロードマップ表]:::overview
  A --> B0[docs/README.md<br/>運用ルール]:::overview
  A --> B1[docs/COMPANY_SETUP_GUIDE.md<br/>環境セットアップ<br/>β版: Secrets運用SOP]:::overview
  A --> D[guides/CHATGPT_SHARE_GUIDE.md<br/>AI共有SOP<br/>β版: doc-share SOP]:::share

  %% DEVELOPMENT
  A --> C[docs/development/DEVELOPMENT_GUIDE.md<br/>開発環境ガイド]:::dev
  C --> C1[環境構築/CI/CD/AI設定]:::dev

  %% ARCHITECTURE
  A --> F[docs/architecture/<br/>システム構成図群]:::arch
  F --> F1[starlist_architecture_documentation.md.docx]:::arch
  F --> F2[starlist_technical_requirements_plan.md]:::arch
  F --> F3[diagrams/<br/>ER図・Seq図・Arch図]:::arch

  %% FEATURES（Day1〜Day4）
  subgraph FE["docs/features/"]
    H1[payment_current_state.md<br/>現行決済リポート]:::feature2
    H2[design/*<br/>画面仕様群]:::feature2
    H3[day4/AUTH-OAUTH-001_impl_and_review.md]:::feature2
    H4[day4/SEC-RLS-SYNC-001.md]:::feature2
    H5[day4/UI-HOME-001.md]:::feature2
    H6[day4/QA-E2E-001.md]:::feature2
    H7[payment/PAY-STAR-SUBS-PER-STAR-PRICING.md<br/>★新:スター単位可変価格]:::feature2
    H8[auth/AUTH-OAUTH-001.md<br/>OAuth正準仕様]:::auth
  end
  A --> FE

  %% OPS（拡張）
  A --> O[docs/ops/OPS-MONITORING-001.md<br/>監視・テレメトリ正準]:::ops
  O -.-> SH[docs/features/day4/OPS-MONITORING-001.md<br/>参照シェル]:::feature
  A --> O2[docs/ops/OPS-MONITORING-002.md<br/>OPS Dashboard拡張（β）]:::ops
  O2 --> O
  O2 --> O3[docs/ops/OPS-TELEMETRY-SYNC-001.md<br/>Telemetry実シンク]:::ops
  A --> O6[docs/ops/OPS-SUMMARY-EMAIL-001.md<br/>週次メール要約]:::ops
  A --> O7[docs/ops/LAUNCH_CHECKLIST.md<br/>本番入りチェックリスト]:::ops
  A --> O8[docs/ops/AUDIT_SYSTEM_ENTERPRISE.md<br/>監査システム全体像]:::ops
  A --> O9[docs/ops/DASHBOARD_IMPLEMENTATION.md<br/>KPIダッシュボード実装]:::ops
  A --> O10[docs/ops/SSOT_RULES.md<br/>SSOTルール]:::ops
  A --> O11[docs/ops/RACI_MATRIX.md<br/>RACIマトリクス]:::ops
  A --> O12[docs/ops/RISK_REGISTER.md<br/>リスク登録票]:::ops
  A --> O13[docs/ops/RECOVERY_GUIDE.md<br/>復旧ガイド]:::ops
  A --> O14[docs/ops/SECURITY_AUDIT_GUIDE.md<br/>セキュリティ監査ガイド]:::ops
  
  %% REPORTS（拡張）
  A --> R1[docs/reports/STARLIST_DAY5_SUMMARY.md<br/>Day5進行サマリー]:::biz
  A --> R2[docs/reports/DAY11_INTEGRATION_LOG.md<br/>Day11統合ログ]:::biz
  A --> R3[docs/reports/DAY12_SOT_DIFFS.md<br/>Day12ドキュメント統合差分]:::biz
  A --> R4[docs/reports/DAY10_SOT_DIFFS.md<br/>OPS Slack Notify（Day10）]:::biz
  A --> R5[docs/reports/OPS-SUMMARY-LOGS.md<br/>OPS週次メールログ]:::biz
  A --> R6[docs/reports/AUDIT_REPORT_TEMPLATE.md<br/>監査レポートテンプレート]:::biz
  
  %% PLANNING & REPORTS
  A --> P[docs/planning/Task.md<br/>計画/タスク]:::biz
  P --> P1[docs/planning/starlist_planning.md]:::biz
  A --> R[docs/reports/STARLIST_DEVELOPMENT_SUMMARY.md<br/>進捗レポート]:::biz

  %% GUIDES
  A --> G[guides/business/<br/>ビジネス資料]:::guides
  G --> G1[starlist_monetization_plan.md]:::guides
  A --> U[guides/user-journey/<br/>カスタマージャーニー]:::guides
  A --> AI[guides/ai-integration/<br/>AI運用ガイド]:::guides

  %% LEGAL
  A --> L[docs/legal/<br/>公開文書]:::legal

  %% RELATIONSHIPS (Day4)
  H3 --> H4
  H3 --> H5
  H3 --> H6
  H4 --> H6
  H7 --> H4
  H7 --> H5
  H7 --> O
  H7 --> H6
  O --> H6
  O2 --> H6
  O3 --> O2

  %% RELATIONSHIPS (Day12拡張: 索引中心にエッジ再配線)
  %% Overview → OPS
  B --> O6
  B --> O8
  B1 --> O7
  %% Share → OPS
  D --> O6
  %% OPS内部関係
  O6 --> R5
  O8 --> O9
  O8 --> R6
  O9 --> O10
  O7 --> O11
  O7 --> O12
  O7 --> O13
  %% Reports → OPS
  R3 --> O10
  R4 --> O2
  R5 --> O6
  %% OPS → Reports（双方向）
  O6 -.-> R5
  O8 -.-> R6
  %% Architecture → Index
  F3 --> A
  %% OPS内部関係（追加）
  O4 --> O2
  O5 --> O4

  %% 凡例ブロック（色/形/ラベル意味）
  classDef core fill:#6a5cff,stroke:#4b3df0,color:#fff;
  classDef overview fill:#f1efff,stroke:#6a5cff,color:#333;
  classDef share fill:#fff6e6,stroke:#ff9a22,color:#333;
  classDef dev fill:#e3f2fd,stroke:#1976d2,color:#0d47a1;
  classDef arch fill:#ffe8f1,stroke:#d81b60,color:#6a0035;
  classDef feature fill:#e8f5e9,stroke:#2e7d32,color:#1b5e20;
  classDef feature2 fill:#f1fbf2,stroke:#43a047,color:#1b5e20;
  classDef auth fill:#f0f4ff,stroke:#4a6ee0,color:#22315c;
  classDef ops fill:#e9fff2,stroke:#13a36e,color:#333;
  classDef biz fill:#fff5e1,stroke:#f57c00,color:#5d3300;
  classDef guides fill:#fff0f5,stroke:#c2185b,color:#5d1030;
  classDef legal fill:#ede7f6,stroke:#5e35b1,color:#311b92;
  
  %% 凡例説明（コメント）
  %% core: 索引・中核ドキュメント（紫）
  %% overview: 概要・セットアップ（薄紫）
  %% share: AI共有SOP（オレンジ）
  %% dev: 開発環境ガイド（青）
  %% arch: アーキテクチャ図（ピンク）
  %% feature: 機能仕様（緑）
  %% auth: 認証関連（青紫）
  %% ops: 運用・監視（薄緑）
  %% biz: ビジネス・レポート（オレンジ）
  %% guides: ガイド・読み物（ピンク）
  %% legal: 法的文書（紫）

  H4 --> H6
  H7 --> H4
  H7 --> H5
  H7 --> O
  H7 --> H6
  O --> H6
  O2 --> H6
  O3 --> O2

  %% RELATIONSHIPS (Day12拡張: 索引中心にエッジ再配線)
  %% Overview → OPS
  B --> O6
  B --> O8
  B1 --> O7
  %% Share → OPS
  D --> O6
  %% OPS内部関係
  O6 --> R5
  O8 --> O9
  O8 --> R6
  O9 --> O10
  O7 --> O11
  O7 --> O12
  O7 --> O13
  %% Reports → OPS
  R3 --> O10
  R4 --> O2
  R5 --> O6
  %% OPS → Reports（双方向）
  O6 -.-> R5
  O8 -.-> R6
  %% Architecture → Index
  F3 --> A
  %% OPS内部関係（追加）
  O4 --> O2
  O5 --> O4

  %% 凡例ブロック（色/形/ラベル意味）
  classDef core fill:#6a5cff,stroke:#4b3df0,color:#fff;
  classDef overview fill:#f1efff,stroke:#6a5cff,color:#333;
  classDef share fill:#fff6e6,stroke:#ff9a22,color:#333;
  classDef dev fill:#e3f2fd,stroke:#1976d2,color:#0d47a1;
  classDef arch fill:#ffe8f1,stroke:#d81b60,color:#6a0035;
  classDef feature fill:#e8f5e9,stroke:#2e7d32,color:#1b5e20;
  classDef feature2 fill:#f1fbf2,stroke:#43a047,color:#1b5e20;
  classDef auth fill:#f0f4ff,stroke:#4a6ee0,color:#22315c;
  classDef ops fill:#e9fff2,stroke:#13a36e,color:#333;
  classDef biz fill:#fff5e1,stroke:#f57c00,color:#5d3300;
  classDef guides fill:#fff0f5,stroke:#c2185b,color:#5d1030;
  classDef legal fill:#ede7f6,stroke:#5e35b1,color:#311b92;
  
  %% 凡例説明（コメント）
  %% core: 索引・中核ドキュメント（紫）
  %% overview: 概要・セットアップ（薄紫）
  %% share: AI共有SOP（オレンジ）
  %% dev: 開発環境ガイド（青）
  %% arch: アーキテクチャ図（ピンク）
  %% feature: 機能仕様（緑）
  %% auth: 認証関連（青紫）
  %% ops: 運用・監視（薄緑）
  %% biz: ビジネス・レポート（オレンジ）
  %% guides: ガイド・読み物（ピンク）
  %% legal: 法的文書（紫）

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
