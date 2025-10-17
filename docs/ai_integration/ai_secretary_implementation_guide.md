# AI秘書実装ガイド：STARLIST適用編

## 📋 概要

**AI秘書**とは、単なるチャットAIではなく、個人や組織のデータを深く理解し、複数のサービスと連携して能動的に支援するAIシステムです。本ドキュメントでは、**Notion AI**、**MCP（Model Context Protocol）**、**Obsidian + Cursor + Git**の3層構造を通じて、STARLISTプロジェクトにどのようにAI秘書概念を適用するかを解説します。

**参考動画（想定）:**
- タイトル: 「AI秘書で生産性を10倍に：Notion/MCP/Obsidianフル活用術」
- チャンネル: Tech Productivity Lab
- 公開日: 2025年10月
- 要約: チャットAI単体ではなく、個人データ・組織データを理解し、複数ツール（Notion、Google Drive、Supabase、Calendar）と連携するAI秘書の構築方法を3段階（初心者・中級・上級）で解説。STARLISTのようなプラットフォームでスター活動管理・投稿支援・データ分析を自動化する実例を紹介。

---

## 🎯 AI秘書の本質

**従来のチャットAI:**
- 単発の質問に回答
- 文脈の記憶が限定的
- データ連携なし

**AI秘書:**
- **個人/組織データを理解**（視聴履歴、購買履歴、スケジュール、タスク）
- **複数サービスと連携**（Notion、Google Drive、Supabase、Calendar、GitHub）
- **能動的提案**（次にすべきこと、投稿ネタ、異常検知）
- **継続的学習**（ユーザーの行動パターンを理解）

---

## 🌱 初心者層：Notion AIによるAI秘書の基本構築

### 1. Notion AIの活用

**Notion**は、データベース・ページ・タスク管理を統合したツールです。**Notion AI**を組み込むことで、蓄積したデータを理解し、AI秘書として機能させられます。

#### 基本構築手順

##### ステップ1: ダッシュボード設計
- **データベース作成**
  - タスク管理DB（タイトル、期限、優先度、ステータス）
  - 知識ベースDB（カテゴリ、タグ、要約）
  - スケジュールDB（日時、イベント名、参加者）

##### ステップ2: 役割定義
- **AI秘書の役割を明確化**
  - 例: 「毎週月曜にタスクを整理し、優先順位を提案」
  - 例: 「スケジュールの空き時間に適切なタスクを推薦」
  - 例: 「過去の知識ベースから関連情報を提示」

##### ステップ3: 知識蓄積
- **データを継続的に入力**
  - 会議メモ、学習ノート、プロジェクト進捗
  - Notion AI が参照できるよう構造化

##### ステップ4: AI活用
- **Notion AIコマンド**
  - 「今週のタスクを優先度順に並べて」
  - 「先月の会議メモから重要な決定事項をまとめて」
  - 「この資料の要約を3行で」

### 2. STARLIST適用例

#### スター向けAI秘書
- **活動管理ダッシュボード**
  - Notionで視聴履歴・購買履歴・投稿予定を一元管理
  - AI秘書が「今週は動画視聴が多いので、感想投稿を提案」

- **投稿支援**
  - 過去の投稿パターンから「ファンが反応しやすいテーマ」を提案
  - 例: 「最近Netflixを多く視聴しているので、おすすめドラマ紹介が効果的です」

- **提案AI**
  - スケジュールの空き時間に「ファン交流イベント」を提案
  - データから「収益化のタイミング」をアドバイス

#### ファン向けAI秘書
- **推し活管理**
  - 推しスターの投稿・活動を Notion で追跡
  - AI秘書が「明日は推しの誕生日です。メッセージを準備しましょう」

- **おすすめコンテンツ**
  - 推しの傾向から「次に観るべき動画・買うべき商品」を提案

---

## 🔗 中級層：MCP（Model Context Protocol）連携

### 1. MCPとは

**MCP（Model Context Protocol）** は、AIモデルが複数のデータソースやサービスに接続し、統一的にコンテキストを理解するためのプロトコルです。

**主な接続先:**
- **Google Drive**: ドキュメント、スプレッドシート
- **Supabase**: リアルタイムDB、認証、ストレージ
- **Google Calendar**: スケジュール、イベント
- **GitHub**: コード、Issue、PR

### 2. MCP統合方法

#### ステップ1: API接続設定
```bash
# Supabase接続
export SUPABASE_URL=https://your-project.supabase.co
export SUPABASE_ANON_KEY=your-anon-key

# Google Drive API
export GOOGLE_DRIVE_CLIENT_ID=your-client-id
export GOOGLE_DRIVE_CLIENT_SECRET=your-client-secret
```

#### ステップ2: データフロー設計
1. **データ取得**: STARLISTから視聴履歴・レシート・タグ辞書を取得
2. **AI理解**: MCPがデータを構造化し、AIに提供
3. **横断活用**: 複数サービスのデータを統合して分析

#### ステップ3: 実装例
```dart
// Supabase から視聴履歴を取得
final viewHistory = await supabase
  .from('viewing_history')
  .select('*')
  .eq('user_id', currentUserId);

// AI秘書に渡すコンテキスト
final context = {
  'viewing_history': viewHistory,
  'purchase_receipts': purchaseData,
  'tag_dictionary': tagData,
};

// AI秘書が分析・提案
final suggestion = await aiSecretary.analyze(context);
```

### 3. STARLISTデータ活用フロー

#### データ取得
- **視聴履歴**: Netflix、Amazon Prime Video、YouTube
- **購買履歴**: Amazon、楽天、ZOZOTOWNのレシート
- **タグ辞書**: ユーザーが定義したカテゴリ・タグ

#### AI理解プロセス
1. MCPが **Supabase** から全データを取得
2. **Google Drive** の補助資料（メモ、画像）を参照
3. **Calendar** でスケジュールと照合

#### 横断活用例
- **スター**: 「先月の視聴データから、ファンが興味を持ちそうな商品を提案」
- **ファン**: 「推しが最近買った商品と同じカテゴリを楽天で検索」
- **分析**: 「曜日別・時間帯別の活動パターンを可視化」

---

## 🚀 上級層：Obsidian + Cursor + Git

### 1. 各ツールの役割

#### Obsidian（Markdown管理）
- **役割**: ローカルファーストの知識ベース
- **特徴**: Markdown形式、グラフビュー、双方向リンク
- **用途**: プロジェクト計画、タスク管理、アイデアメモ

#### Cursor（AIコード支援）
- **役割**: AIペアプログラミングエディタ
- **特徴**: コード生成、リファクタリング、ドキュメント作成
- **用途**: Flutter/Dart開発、Supabase連携コード生成

#### Git（バージョン管理）
- **役割**: コード・ドキュメントの履歴管理
- **特徴**: ブランチ、コミット、PR、履歴追跡
- **用途**: チーム開発、変更追跡、ロールバック

### 2. 連携構造

```
┌──────────────┐
│  Obsidian    │ ← Markdown でプロジェクト計画・タスク管理
│ (Planning)   │
└──────┬───────┘
       │
       ↓ Markdown → Code
┌──────────────┐
│   Cursor     │ ← AI でコード生成・リファクタリング
│ (Coding AI)  │
└──────┬───────┘
       │
       ↓ Commit
┌──────────────┐
│     Git      │ ← バージョン管理・履歴追跡
│  (Version)   │
└──────────────┘
```

### 3. Claude Codeを用いたCLI型AI運用

#### Claude Codeとは
- **Anthropic** が提供するCLI型AIアシスタント
- ターミナルから直接AIに指示
- コード生成・デバッグ・ドキュメント作成を自動化

#### 実装例
```bash
# タスク管理ファイルから次のタスクを抽出
claude "Task.md を読んで、優先度が高い未完了タスクを3つ挙げて"

# コード生成
claude "lib/features/ai_secretary/ にデータ分析クラスを作成して"

# デバッグ
claude "data_import_screen.dart のエラーを修正して"
```

### 4. STARLIST開発体制との親和性

#### 現在の開発体制
- **ティム（COO兼PM）**: プロジェクト管理、要件定義、戦略立案
- **マイン（実装担当）**: Flutter/Dart開発、Supabase連携、UI/UX実装

#### AI秘書の役割分担
- **ティム → Obsidian**
  - プロジェクト計画を Markdown で管理
  - タスクの優先順位を AI秘書が提案

- **マイン → Cursor**
  - ティムの計画を元にコード生成
  - AI がコードレビュー・最適化を支援

- **共同 → Git**
  - 変更履歴を追跡
  - PR で AI が技術的レビューを実施

#### ワークフロー例
1. **ティム**: Obsidian でタスク「データインポート画面のUI改善」を作成
2. **AI秘書**: 優先度を分析し「今週実装すべき」と提案
3. **マイン**: Cursor で AI にコード生成を依頼
4. **AI**: `data_import_screen.dart` のリファクタリングコードを生成
5. **マイン**: Git にコミット・プッシュ
6. **AI**: PR で「RenderFlexのオーバーフロー問題を修正してください」と提案

---

## 🎨 STARLIST適用ポイント

### 1. AI秘書構造をスター/ファンUI・UXに応用

#### スター側の体験
- **ダッシュボード**: Notionライクなカード構造で日常データを可視化
  - 視聴履歴カード、購買履歴カード、投稿予定カード
  - AIが「今週のトレンド」「ファン反応予測」を表示

- **投稿提案AI**
  - 行動履歴から「明日は映画レビューを投稿すると反応が良さそうです」
  - 過去の成功パターンを学習

- **分析レポート**
  - 週次・月次で「活動サマリー」を自動生成
  - 収益化のタイミングをAIが提案

#### ファン側の体験
- **推し理解AI**
  - 推しの傾向をAIが要約「最近はアニメと音楽に興味があります」
  - 次の投稿内容を予測「明日は新作映画のレビューが来るかも」

- **推薦システム**
  - 推しと同じ商品・コンテンツを自動推薦
  - 「推しが観たドラマTOP5」を表示

### 2. Notionライクなデータカード構造の導入

#### カード設計
```dart
class DataCard extends StatelessWidget {
  final String title;
  final String category;
  final DateTime timestamp;
  final Widget content;
  final List<String> tags;
  final VoidCallback? onTap;

  // Notionライクなカードデザイン
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // カテゴリアイコン + タイトル
              Row(
                children: [
                  Icon(getCategoryIcon(category), size: 20),
                  SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              // コンテンツ
              content,
              SizedBox(height: 12),
              // タグ + タイムスタンプ
              Row(
                children: [
                  ...tags.map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: Colors.blue.shade100,
                  )),
                  Spacer(),
                  Text(
                    formatTimestamp(timestamp),
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### STARLIST適用
- **視聴履歴カード**: Netflix/Amazon/YouTubeの視聴データを統一フォーマットで表示
- **購買履歴カード**: レシート情報を自動パース＋カード化
- **投稿カード**: スターの投稿を時系列で表示

### 3. AI機能の実装方針

#### データ収集層
```dart
// lib/features/ai_secretary/data/ai_context_collector.dart
class AiContextCollector {
  Future<Map<String, dynamic>> collectUserContext(String userId) async {
    final viewingHistory = await _getViewingHistory(userId);
    final purchaseHistory = await _getPurchaseHistory(userId);
    final posts = await _getPosts(userId);
    final schedule = await _getSchedule(userId);

    return {
      'viewing': viewingHistory,
      'purchase': purchaseHistory,
      'posts': posts,
      'schedule': schedule,
      'summary': _generateSummary(),
    };
  }
}
```

#### AI分析層
```dart
// lib/features/ai_secretary/services/ai_analyzer.dart
class AiAnalyzer {
  Future<AiSuggestion> analyzeAndSuggest(Map<String, dynamic> context) async {
    // MCPを通じてAIに送信
    final response = await _callMCP(context);

    return AiSuggestion(
      nextAction: response['next_action'],
      contentIdeas: response['content_ideas'],
      insights: response['insights'],
    );
  }
}
```

#### UI表示層
```dart
// lib/features/ai_secretary/widgets/ai_suggestion_card.dart
class AiSuggestionCard extends StatelessWidget {
  final AiSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    return DataCard(
      title: '💡 AI秘書からの提案',
      category: 'AI Suggestion',
      timestamp: DateTime.now(),
      tags: ['AI', '提案', '自動'],
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('次のアクション:', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(suggestion.nextAction),
          SizedBox(height: 12),
          Text('投稿アイデア:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...suggestion.contentIdeas.map((idea) => Text('• $idea')),
        ],
      ),
    );
  }
}
```

---

## 🔬 上級層実装詳細

### 1. Obsidian管理構造

#### ディレクトリ構成
```
obsidian-vault/
├── Projects/
│   ├── STARLIST/
│   │   ├── Planning.md          # 全体計画
│   │   ├── Task.md              # タスク管理
│   │   ├── Sprint-2025-W42.md   # スプリント計画
│   │   └── Architecture.md      # アーキテクチャ設計
├── Knowledge/
│   ├── Flutter-Best-Practices.md
│   ├── Supabase-RLS-Policies.md
│   └── AI-Integration-Patterns.md
└── Daily/
    ├── 2025-10-14.md             # デイリーログ
    └── 2025-10-15.md
```

#### タスクフォーマット
```markdown
## 優先タスク

- [ ] データインポート画面のUI改善 #ui #priority-high
  - 状態: 🔄 進行中
  - 担当: マイン
  - 期限: 2025-10-20
  - 依存: ServiceIconRegistry完成

- [ ] AI投稿提案機能の実装 #ai #feature
  - 状態: 📋 計画中
  - 担当: マイン
  - 期限: 2025-10-25
  - 依存: データ収集API完成
```

### 2. Cursor AI活用

#### コード生成例
```
User: "lib/features/ai_secretary/screens/ にAI提案画面を作成。
      Riverpod で状態管理、Supabase からデータ取得、
      Notionライクなカードデザインで。"

Cursor AI:
✅ ai_suggestion_screen.dart を生成
✅ AiSuggestionProvider を Riverpod で実装
✅ SupabaseからAIコンテキストを取得するRepository作成
✅ DataCard ウィジェットで統一デザイン実装
```

#### リファクタリング例
```
User: "data_import_screen.dart のRenderFlexオーバーフロー問題を修正"

Cursor AI:
✅ Column を ListView に変更
✅ Flexible/Expanded で柔軟なレイアウトに
✅ スクロール可能に修正
```

### 3. Git連携ワークフロー

#### ブランチ戦略
```bash
main                  # プロダクション
├── develop           # 開発統合ブランチ
├── feature/ai-secretary       # AI秘書機能
├── feature/data-import-ui     # データインポートUI
└── fix/renderflex-overflow    # バグ修正
```

#### コミットメッセージ規約
```
feat(ai): AI投稿提案機能を追加
fix(ui): RenderFlexオーバーフロー問題を修正
docs(ai): AI秘書実装ガイドを追加
test(ai): AI分析ロジックのテストを追加
chore(assets): サービスアイコンを追加
```

#### AI支援のPRレビュー
```markdown
## PR: AI投稿提案機能の実装

### 変更内容
- AiSuggestionScreen 追加
- AiAnalyzer サービス実装
- Supabase連携Repository作成

### AI秘書のレビュー結果
✅ コード品質: 良好
⚠️ テストカバレッジ: 65%（目標80%）
💡 提案: エラーハンドリングを追加してください
```

---

## 📊 実装ロードマップ

### Phase 1: 基盤構築（2週間）

#### Week 1
- [ ] `docs/ai_integration/` ディレクトリ作成
- [ ] AI秘書アーキテクチャ設計ドキュメント作成
- [ ] Supabase テーブル設計（`ai_contexts`, `ai_suggestions`）

#### Week 2
- [ ] `lib/features/ai_secretary/` ディレクトリ作成
- [ ] データ収集クラス実装（`AiContextCollector`）
- [ ] 基本的なUI実装（`AiSuggestionScreen`）

### Phase 2: MCP連携（2週間）

#### Week 3
- [ ] Supabase Edge Functions でAI分析エンドポイント作成
- [ ] Google Drive API 連携実装
- [ ] Calendar API 連携実装

#### Week 4
- [ ] データ横断分析ロジック実装
- [ ] リアルタイム更新対応（Supabase Realtime）
- [ ] ユニットテスト追加

### Phase 3: 高度な機能（2週間）

#### Week 5
- [ ] 投稿提案AI実装（過去パターン学習）
- [ ] 異常検知機能（通常パターンからの逸脱を検出）
- [ ] スケジュール最適化提案

#### Week 6
- [ ] ファン向けAI推薦システム
- [ ] 収益化タイミング提案AI
- [ ] パフォーマンス最適化

---

## 📁 技術ドキュメント

本ガイドに関連する詳細技術ドキュメントは以下に配置されます：

### 1. ai_scheduler_model.md
**概要**: スケジュール自動連携の設計・実装
**内容**:
- Google Calendar API 連携方法
- Supabase でのスケジュールデータ管理
- AI による空き時間最適化アルゴリズム
- スター/ファンのスケジュール同期

### 2. ai_content_advisor.md
**概要**: 投稿提案AIの設計・実装
**内容**:
- 過去投稿データの分析手法
- ファン反応パターンの学習アルゴリズム
- 最適な投稿タイミング予測
- コンテンツカテゴリ別の推薦ロジック

### 3. ai_data_bridge.md
**概要**: Supabase/MCP接続技術ノート
**内容**:
- MCP プロトコルの実装詳細
- Supabase Edge Functions での AI処理
- データパイプライン設計（収集→変換→分析→提示）
- セキュリティ・プライバシー考慮事項

---

## 🎯 PoC（概念実証）計画

### 目的
AI秘書モデルをSTARLISTのスター・ファン双方の体験に落とし込み、実用性を検証

### 実装スコープ

#### スター向けPoC
1. **視聴履歴からの投稿提案**
   - Netflix/YouTube の視聴データを分析
   - 「今週は韓国ドラマを多く視聴 → ドラマレビュー投稿を提案」

2. **収益化タイミング提案**
   - アクティビティパターンを分析
   - 「フォロワー増加率が高い → サブスクプラン開始のタイミング」

#### ファン向けPoC
1. **推しのトレンド要約**
   - 推しの最近の投稿・視聴・購買を分析
   - 「推しは今、〇〇に夢中です」

2. **おすすめコンテンツ**
   - 推しと同じカテゴリの商品・動画を推薦
   - 「推しが観たドラマ、あなたも楽しめるかも」

### 成功指標
- **スター**: 投稿頻度20%増加、収益化開始率30%向上
- **ファン**: 推し活満足度スコア4.5/5.0以上、購買転換率15%向上

### タイムライン
- **Week 1-2**: スター向けPoC実装
- **Week 3-4**: ファン向けPoC実装
- **Week 5**: ユーザーテスト実施
- **Week 6**: フィードバック反映・改善

---

## 🔧 実装チェックリスト

### 基盤
- [ ] `docs/ai_integration/` ディレクトリ作成 ✅
- [ ] `lib/features/ai_secretary/` ディレクトリ作成
- [ ] Supabase テーブル設計完了
- [ ] MCP接続設定完了

### データ収集
- [ ] AiContextCollector 実装
- [ ] Supabase Repository 実装
- [ ] Google Drive 連携実装
- [ ] Calendar 連携実装

### AI分析
- [ ] AiAnalyzer サービス実装
- [ ] Edge Functions でAI処理エンドポイント作成
- [ ] データ横断分析ロジック実装

### UI/UX
- [ ] AiSuggestionScreen 実装
- [ ] DataCard ウィジェット実装
- [ ] Notionライクなダッシュボード実装
- [ ] レスポンシブデザイン対応

### テスト
- [ ] ユニットテスト（カバレッジ80%以上）
- [ ] 統合テスト
- [ ] E2Eテスト
- [ ] パフォーマンステスト

---

## 🚀 次のステップ

1. **技術ドキュメントの作成**
   - `ai_scheduler_model.md`
   - `ai_content_advisor.md`
   - `ai_data_bridge.md`

2. **PoC実装開始**
   - スター向け投稿提案AI
   - ファン向け推しトレンド要約

3. **Obsidian + Cursor + Git 環境整備**
   - Obsidian vault セットアップ
   - Cursor拡張設定
   - Git hooks でAIレビュー自動化

4. **チーム運用開始**
   - ティム: Obsidian でプロジェクト管理
   - マイン: Cursor でAI支援開発
   - AI秘書: 継続的な提案・分析

---

## 📚 参考資料

### 外部リンク
- **Notion API**: https://developers.notion.com/
- **MCP仕様**: https://modelcontextprotocol.io/
- **Supabase Edge Functions**: https://supabase.com/docs/guides/functions
- **Obsidian**: https://obsidian.md/
- **Cursor**: https://cursor.sh/

### STARLISTドキュメント
- `Planning.md`: プロジェクト全体計画
- `Task.md`: 現在のタスク一覧
- `docs/features/search_repository_implementation.md`: 検索機能実装ガイド

---

**作成日**: 2025年10月15日  
**最終更新**: 2025年10月15日  
**バージョン**: 1.0.0  
**担当**: AI開発チーム（ティム＋マイン＋Claude）

