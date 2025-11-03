flowchart TB
  A[COMMON_DOCS_INDEX.md<br/>共通ドキュメント索引<br/>＝中核インデックス]:::core
  A --> B[STARLIST_OVERVIEW.md<br/>プロジェクト全体像/設計図]:::overview
  A --> C[COMPANY_SETUP_GUIDE.md<br/>会社/環境セットアップ&オンボード]:::setup
  A --> D[CHATGPT_SHARE_GUIDE.md<br/>AI共有SOP/提示順序/チェックリスト]:::share

  %% OVERVIEW の参照先（技術・機能）
  B --> B1[アーキテクチャ概要<br/>FE/BE/Supabase/Storage/Stripe]:::tech
  B --> B2[機能マップと進捗<br/>カテゴリ別ステータス]:::roadmap
  B --> B3[ディレクトリ構成ハイライト<br/>lib/server/supabase/scripts/docs]:::dirs

  %% SETUP の参照先（運用・権限）
  C --> C1[アカウント・権限チェックリスト<br/>GSuite/GitHub/Supabase/Stripe]:::ops
  C --> C2[開発環境構築手順<br/>Flutter/Node/Docker/Supabase CLI]:::ops
  C --> C3[環境変数/機密管理<br/>.env/Vault/direnv]:::ops
  C --> C4[CI/CD・QA・リリース手順]:::ops

  %% SHARE の参照先（AI運用）
  D --> D1[共有の目的定義<br/>目的/概要/対象領域の明示]:::share2
  D --> D2[優先共有Markdown一覧<br/>機能別の推奨ドキュメント]:::share2
  D --> D3[共有手順と順序<br/>概要→課題→抜粋→依頼]:::share2
  D --> D4[大容量/外部共有方針<br/>Supabase Storage doc-share]:::share2

  classDef core fill:#6a5cff,stroke:#4b3df0,color:#fff;
  classDef overview fill:#f1efff,stroke:#6a5cff,color:#333;
  classDef setup fill:#eafff7,stroke:#26a97a,color:#333;
  classDef share fill:#fff6e6,stroke:#ff9a22,color:#333;
  classDef tech fill:#eef7ff,stroke:#2b7de9,color:#333;
  classDef roadmap fill:#f9f0ff,stroke:#a24be6,color:#333;
  classDef dirs fill:#f0fbff,stroke:#00a3c4,color:#333;
  classDef ops fill:#e9fff2,stroke:#13a36e,color:#333;
  classDef share2 fill:#fff6ea,stroke:#ff9a22,color:#333;
