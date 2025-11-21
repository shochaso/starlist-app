---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



flowchart TB
  A[docs/overview/COMMON_DOCS_INDEX.md<br/>共通ドキュメント索引]:::core

  A --> B[docs/overview/STARLIST_OVERVIEW.md<br/>プロダクト全景と要約]:::overview
  A --> D[guides/CHATGPT_SHARE_GUIDE.md<br/>AI共有SOP]:::share
  A --> C[docs/development/DEVELOPMENT_GUIDE.md<br/>開発環境ガイド]:::dev
  A --> F[docs/architecture/<br/>システム構成図群]:::arch
  A --> O[docs/ops/OPS-MONITORING-001.md<br/>監視・テレメトリ正準]:::ops
  A --> P[docs/planning/Task.md<br/>計画/タスク]:::biz
  A --> R[docs/reports/STARLIST_DEVELOPMENT_SUMMARY.md<br/>進捗レポート]:::biz
  A --> R2[docs/reports/STARLIST_DAY5_SUMMARY.md<br/>Day5進行サマリー]:::biz
  A --> G[guides/business/<br/>ビジネス戦略]:::guides
  A --> U[guides/user-journey/<br/>カスタマージャーニー]:::guides

  subgraph FE["docs/features/"]
    H1[payment_current_state.md]:::feature2
    H7[payment/PAY-STAR-SUBS-PER-STAR-PRICING.md]:::feature2
    H3[day4/AUTH-OAUTH-001_impl_and_review.md]:::feature2
    H4[day4/SEC-RLS-SYNC-001.md]:::feature2
    H5[day4/UI-HOME-001.md]:::feature2
    H6[day4/QA-E2E-001.md]:::feature2
    H8[auth/AUTH-OAUTH-001.md]:::auth
  end
  A --> FE

  O -.-> SH[docs/features/day4/OPS-MONITORING-001.md<br/>Day4参照シェル]:::feature

  H3 --> H4
  H3 --> H5
  H3 --> H6
  H4 --> H6
  H7 --> H4
  H7 --> H5
  H7 --> O
  H7 --> H6
  O --> H6

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

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
