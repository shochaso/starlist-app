flowchart TB
  A[docs/overview/COMMON_DOCS_INDEX.md<br/>共通ドキュメント索引]:::core

  A --> B[docs/overview/STARLIST_OVERVIEW.md<br/>プロダクト全景と要約]:::overview
  A --> D[guides/CHATGPT_SHARE_GUIDE.md<br/>AI共有SOP]:::share
  A --> C[docs/development/DEVELOPMENT_GUIDE.md<br/>開発環境ガイド]:::dev
  A --> F[docs/architecture/<br/>システム構成図群]:::arch
  A --> O[docs/ops/OPS-MONITORING-001.md<br/>監視・テレメトリ正準]:::ops
  A --> P[docs/planning/Task.md<br/>計画/タスク]:::biz
  A --> R[docs/reports/STARLIST_DEVELOPMENT_SUMMARY.md<br/>進捗レポート]:::biz
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
    H9[day4/QA-E2E-AUTO-001.md<br/>⚡E2E自動化]:::feature2
  end
  A --> FE

  O -.-> SH[docs/features/day4/OPS-MONITORING-001.md<br/>Day4参照シェル]:::feature
  O --> O2[docs/ops/OPS-TELEMETRY-SYNC-001.md<br/>⚡Telemetry実シンク]:::ops
  O --> O3[docs/ops/OPS-MONITORING-002.md<br/>⚡OPSモニタリング拡張]:::ops

  H3 --> H4
  H3 --> H5
  H3 --> H6
  H4 --> H6
  H7 --> H4
  H7 --> H5
  H7 -.-> O
  H7 --> H6
  H8 --> H7
  H4 --> H7
  H5 --> H7
  H6 --> H7
  O -.-> H6
  O2 --> O
  O2 --> O3
  O3 --> O
  H9 --> O2
  H9 --> O3
  H9 --> H6
  H6 --> H9

  %% LEGEND
  subgraph LEGEND["凡例"]
    L1[実線 = 正準参照]:::legend
    L2[点線 = 参照シェル]:::legend
    L3[★ = Source of Truth]:::legend
    L4[⚡ = Telemetry Live]:::legend
    L5[◎ = E2E統合済]:::legend
  end

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
  classDef legend fill:#f5f5f5,stroke:#999,color:#333;
