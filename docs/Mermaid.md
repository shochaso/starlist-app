flowchart TB
  A[docs/overview/COMMON_DOCS_INDEX.md<br/>共通ドキュメント索引]:::core

  %% OVERVIEW
  A --> B[docs/overview/STARLIST_OVERVIEW.md<br/>プロダクト全景と要約]:::overview
  A --> B0[docs/overview/README.md<br/>運用ルール]:::overview
  A --> D[guides/CHATGPT_SHARE_GUIDE.md<br/>AI共有SOP]:::share

  %% DEVELOPMENT
  A --> C[docs/development/DEVELOPMENT_GUIDE.md<br/>開発環境ガイド]:::dev
  C --> C1[環境構築/CI/CD/AI設定]:::dev

  %% ARCHITECTURE
  A --> F[docs/architecture/<br/>システム構成図群]:::arch
  F --> F1[starlist_architecture_documentation.md.docx]:::arch
  F --> F2[starlist_technical_requirements_plan.md]:::arch

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

  %% OPS
  A --> O[docs/ops/OPS-MONITORING-001.md<br/>監視・テレメトリ正準]:::ops
  O -.-> SH[docs/features/day4/OPS-MONITORING-001.md<br/>参照シェル]:::feature
  A --> O2[docs/ops/OPS-MONITORING-002.md<br/>OPS Dashboard拡張（β）]:::ops
  O2 --> O
  O2 --> O3[docs/ops/OPS-TELEMETRY-SYNC-001.md<br/>Telemetry実シンク]:::ops

  %% PLANNING & REPORTS
  A --> P[docs/planning/Task.md<br/>計画/タスク]:::biz
  P --> P1[docs/planning/starlist_planning.md]:::biz
  A --> R[docs/reports/STARLIST_DEVELOPMENT_SUMMARY.md<br/>進捗レポート]:::biz
  A --> R2[docs/reports/STARLIST_DAY5_SUMMARY.md<br/>Day5進行サマリー]:::biz

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
