---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



Status:: 
Source-of-Truth:: (TBD)
Spec-State:: 
Last-Updated:: 


# 完全ファイル管理ガイド：全ファイルの配置と管理方針

## 📋 現在のファイル全体像

### すべてのファイルの分類と配置先

---

## 🎯 カテゴリ別管理方針

### 1️⃣ ソースコード（絶対に移動しない）

```
starlist-app/
├── lib/                        # ✅ そのまま（Dartコード）
│   ├── main.dart
│   ├── features/
│   ├── core/
│   ├── providers/
│   ├── screens/
│   ├── widgets/
│   └── ...
│
├── test/                       # ✅ そのまま（テストコード）
│   ├── unit/
│   ├── widget/
│   └── integration/
```

**理由:** Flutterの実行に必須

---

### 2️⃣ アセット（絶対に移動しない）

```
starlist-app/
├── assets/                     # ✅ そのまま（画像、アイコン等）
│   ├── images/
│   ├── icons/
│   │   └── services/
│   ├── service_icons/
│   └── config/
│       └── service_icons.json
```

**理由:** `pubspec.yaml`で参照されている

---

### 3️⃣ プラットフォーム設定（絶対に移動しない）

```
starlist-app/
├── android/                    # ✅ そのまま（Androidビルド設定）
├── ios/                        # ✅ そのまま（iOSビルド設定）
├── web/                        # ✅ そのまま（Webビルド設定）
├── macos/                      # ✅ そのまま（macOSビルド設定）
├── windows/                    # ✅ そのまま（Windowsビルド設定）
└── linux/                      # ✅ そのまま（Linuxビルド設定）
```

**理由:** プラットフォーム固有の設定

---

### 4️⃣ バックエンド（そのまま or supabase/に整理）

```
starlist-app/
├── supabase/                   # ✅ そのまま（Supabase設定）
│   ├── migrations/             # データベースマイグレーション
│   ├── functions/              # Edge Functions
│   └── seed.sql                # 初期データ
│
├── db/                         # 🔄 supabase/に統合推奨
│   └── migrations/
```

**推奨アクション:**
```bash
# db/migrations を supabase/migrations に統合
mv db/migrations/* supabase/migrations/
rmdir db/migrations
rmdir db
```

---

### 5️⃣ 設定ファイル（ルートに残す）

```
starlist-app/
├── pubspec.yaml                # ✅ ルート（Flutter依存関係）
├── pubspec.lock                # ✅ ルート（バージョンロック）
├── analysis_options.yaml       # ✅ ルート（Lint設定）
├── .metadata                   # ✅ ルート（Flutter内部）
├── .flutter-plugins            # ✅ ルート（自動生成）
├── .flutter-plugins-dependencies # ✅ ルート（自動生成）
└── .packages                   # ✅ ルート（自動生成）
```

**理由:** Flutterツールが期待する場所

---

### 6️⃣ 環境変数（ルートに残す）

```
starlist-app/
├── .env                        # ✅ ルート（環境変数・Gitignore対象）
├── .env.local                  # ✅ ルート（ローカル環境変数）
├── .env.local_                 # ✅ ルート（バックアップ？）
├── .env.local x                # ✅ ルート（バックアップ？）
└── .env.example                # 🔄 docs/development/ に移動も可
```

**推奨アクション:**
```bash
# バックアップファイルを整理
rm ".env.local_" ".env.local x"  # 不要なら削除
# または
mkdir -p .env_backups
mv ".env.local_" ".env.local x" .env_backups/
```

---

### 7️⃣ Git管理ファイル（ルートに残す）

```
starlist-app/
├── .git/                       # ✅ ルート（Git履歴）
├── .gitignore                  # ✅ ルート（除外設定）
├── .gitattributes              # ✅ ルート（Git属性）
└── .githooks/                  # ✅ ルート（Gitフック）
```

**理由:** Git管理の基本

---

### 8️⃣ GitHub Actions（そのまま）

```
starlist-app/
├── .github/                    # ✅ そのまま
│   ├── workflows/
│   │   ├── ci.yml
│   │   ├── cd.yml
│   │   └── deploy.yml
│   └── PULL_REQUEST_TEMPLATE.md
```

**理由:** GitHubが期待する場所

---

### 9️⃣ スクリプト（scriptsフォルダに整理）

```
starlist-app/
├── scripts/                    # ✅ そのまま（自動化スクリプト）
│   ├── c.sh
│   ├── deploy.sh
│   ├── migrate.sh
│   └── ...
│
├── cli                         # 🔄 scripts/ に移動推奨
```

**推奨アクション:**
```bash
mv cli scripts/cli
chmod +x scripts/cli
```

---

### 🔟 ドキュメント（docs/に整理）← 今回の主題

```
starlist-app/
├── docs/                       # 📚 新規作成・整理
│   ├── planning/               # Task.md, Planning等
│   ├── architecture/           # 技術設計
│   ├── business/               # ビジネス戦略
│   ├── user-journey/           # カスタマージャーニー
│   ├── ai-integration/         # AI統合設計
│   ├── legal/                  # 利用規約、プライバシー等
│   ├── development/            # 開発ガイド
│   ├── api/                    # API仕様
│   └── reports/                # 開発レポート
│
├── repository/                 # 🔄 docs/ に統合後、削除
├── site_specification/         # 🔄 docs/design/ に移動
└── *.md（ルート直下）          # 🔄 docs/ 各カテゴリに移動
```

---

### 1️⃣1️⃣ IDE・エディタ設定（個人設定）

```
starlist-app/
├── .vscode/                    # ⚠️ 一部Gitignore推奨
│   ├── settings.json           # 個人設定 → .gitignore
│   ├── launch.json             # チーム共有OK
│   └── extensions.json         # チーム共有OK
│
├── .idea/                      # ⚠️ IntelliJ/Android Studio
│   ├── workspace.xml           # 個人設定 → .gitignore
│   └── [その他]                # 一部は共有OK
│
└── .cursor/                    # ✅ Cursor AI設定（そのまま）
```

**推奨.gitignore:**
```gitignore
# IDE個人設定
.vscode/settings.json
.idea/workspace.xml
.idea/tasks.xml
```

---

### 1️⃣2️⃣ ビルド成果物（Gitignore・削除対象）

```
starlist-app/
├── build/                      # ❌ Gitignore（ビルド成果物）
├── .dart_tool/                 # ❌ Gitignore（Dartツール）
└── coverage/                   # ❌ Gitignore（カバレッジ）
```

**理由:** 自動生成・巨大・不要

---

### 1️⃣3️⃣ その他ログ・一時ファイル

```
starlist-app/
├── logs/                       # 🔄 .gitignore 推奨
│   └── prompt_history.json
│
├── .DS_Store                   # ❌ Gitignore（macOS）
├── .coveragerc                 # ✅ ルート（カバレッジ設定）
└── docker-compose.yml          # ✅ ルート（Docker設定）
```

**推奨.gitignore:**
```gitignore
.DS_Store
logs/
*.log
```

---

## 📊 完全な推奨構造

### 最終的な理想構造

```
starlist-app/
│
├── 📱 lib/                              # ソースコード
├── 🧪 test/                             # テストコード
├── 📦 assets/                           # アセット
├── 🗄️ supabase/                         # バックエンド
│   ├── migrations/
│   └── functions/
│
├── 📚 docs/                             # ドキュメント（整理後）
│   ├── planning/
│   ├── architecture/
│   ├── business/
│   ├── user-journey/
│   ├── ai-integration/
│   ├── legal/
│   ├── development/
│   ├── api/
│   ├── reports/
│   └── design/                          # site_specification移動先
│
├── 🚀 scripts/                          # 自動化スクリプト
│   └── cli                              # cli移動先
│
├── 🔧 .github/                          # GitHub Actions
│   └── workflows/
│
├── 🔐 .env                              # 環境変数（Gitignore）
├── 📄 README.md                         # プロジェクト概要
├── 📋 CHANGELOG.md                      # 変更履歴
├── 📦 pubspec.yaml                      # Flutter依存関係
├── ⚙️ analysis_options.yaml            # Lint設定
├── 🐳 docker-compose.yml                # Docker設定
│
├── 🤖 android/                          # プラットフォーム
├── 🍎 ios/
├── 🌐 web/
├── 💻 macos/
├── 🪟 windows/
└── 🐧 linux/
```

---

## 🚀 実装手順：完全版

### ステップ1: ディレクトリ作成
```bash
cd /Users/shochaso/Downloads/starlist-app

# docs配下のカテゴリ作成
mkdir -p docs/{planning,architecture,business,user-journey,ai-integration,legal,development,api,reports,design}

# その他整理
mkdir -p .env_backups
```

### ステップ2: ドキュメント移動
```bash
# Planning
mv Task.md docs/planning/
mv starlist_planning.md docs/planning/
mv "Starlist まとめ.md" docs/planning/

# Architecture
mv starlist_architecture_documentation.md* docs/architecture/
mv starlist_technical_requirements_plan.md docs/architecture/

# Business
mv starlist_positioning.md docs/business/
mv starlist_target_analysis.md docs/business/
mv starlist_monetization_plan.md docs/business/
mv starlist_risk_analysis.md docs/business/
mv "starlist_market opportunities and growth strategies.md" docs/business/
mv starlist_updated_star_ranking.md docs/business/

# User Journey
mv "Starlist Customer Journey Map (Star Regisration).md" docs/user-journey/
mv "starlist customer journey map (Fan Registration).md" docs/user-journey/

# AI Integration
mv ai_integration/* docs/ai-integration/
rmdir ai_integration

# Legal
mv ガイドライン/* docs/legal/
rmdir ガイドライン

# Development
mv DEVELOPMENT_GUIDE.md docs/development/
mv DEPLOYMENT_CHECKLIST.md docs/development/
mv TROUBLESHOOTING.md docs/development/
mv ICON_MANAGEMENT.md docs/development/
mv .env.example docs/development/

# API
mv SUPABASE_RLS_REVIEW.md docs/api/
mv PAYMENT_SYSTEM_INTEGRATION_STRATEGY.md docs/api/

# Reports
mv STARLIST_DEVELOPMENT_SUMMARY.md docs/reports/
mv AI_SECRETARY_POC_PLAN.md docs/reports/
mv MIGRATION_REPORT.md docs/reports/
mv IDEAL_PROJECT_STRUCTURE.md docs/reports/
mv FLUTTER_COMPATIBILITY_CHECK.md docs/reports/

# Design
mv site_specification docs/design/site_specification

# その他
mv CLAUDE.md docs/development/
mv Claude_code.md docs/development/
mv GEMINI.md docs/development/
mv HANAYAMA_MIZUKI_ACCOUNT.md docs/development/
mv codex_request_history.md docs/development/
mv STARLIST_未実装機能リスト.md docs/planning/

# README（ルートに残す）
mv starlist_README.md README.md
mv starlist-rules.md docs/development/
```

### ステップ3: 旧ディレクトリ削除
```bash
# repositoryフォルダは統合後削除
rm -rf repository

# 環境変数バックアップの整理
mv ".env.local_" ".env.local x" .env_backups/ 2>/dev/null || true
```

### ステップ4: スクリプト整理
```bash
# cliをscripts/に移動
mv cli scripts/cli 2>/dev/null || true
chmod +x scripts/cli 2>/dev/null || true
```

### ステップ5: 各docsフォルダにREADME作成
```bash
# 各カテゴリにインデックスREADMEを作成
echo "# Planning Documents" > docs/planning/README.md
echo "# Architecture Documents" > docs/architecture/README.md
echo "# Business Strategy Documents" > docs/business/README.md
echo "# User Journey Maps" > docs/user-journey/README.md
echo "# AI Integration Documents" > docs/ai-integration/README.md
echo "# Legal Documents" > docs/legal/README.md
echo "# Development Guides" > docs/development/README.md
echo "# API Documentation" > docs/api/README.md
echo "# Reports & Analysis" > docs/reports/README.md
echo "# Design Specifications" > docs/design/README.md
```

### ステップ6: .gitignore更新
```bash
cat >> .gitignore << 'EOF'

# Environment backups
.env_backups/

# Logs
logs/
*.log

# macOS
.DS_Store

# IDE個人設定
.vscode/settings.json
.idea/workspace.xml
.idea/tasks.xml
EOF
```

### ステップ7: Git commit
```bash
git add .
git commit -m "docs: プロジェクト構造を整理

- docs/配下にカテゴリ別ドキュメント整理
- scripts/にスクリプト統合
- .gitignore更新
- 各カテゴリにREADME追加"
```

---

## ✅ 整理後の状態チェックリスト

### Flutterプロジェクトとして正常動作
- [ ] `flutter pub get` が成功
- [ ] `flutter run` が成功
- [ ] `flutter test` が成功
- [ ] `flutter build web --release` が成功

### ドキュメント整理
- [ ] `docs/planning/` に計画ドキュメント
- [ ] `docs/architecture/` に技術設計
- [ ] `docs/business/` にビジネス戦略
- [ ] `docs/ai-integration/` にAI設計
- [ ] `docs/legal/` に法的文書
- [ ] `docs/development/` に開発ガイド

### Git管理
- [ ] `.gitignore` が適切に設定
- [ ] 不要なファイルが除外されている
- [ ] Git履歴が保持されている

---

## 🎯 この管理方針の利点

### 開発者
- ✅ ファイル検索が高速
- ✅ プロジェクト構造が明確
- ✅ 新メンバーのオンボーディングが容易

### PM
- ✅ ドキュメントが体系的
- ✅ 計画とコードが同期
- ✅ 進捗管理が容易

### チーム全体
- ✅ 情報の所在が明確
- ✅ ドキュメント更新漏れが減少
- ✅ プロフェッショナルな印象

---

## 🚀 今すぐ実行しますか？

上記のステップをそのまま実行すれば、プロジェクトが理想的な状態になります。

**実行する場合は「実行」と言ってください！**

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
