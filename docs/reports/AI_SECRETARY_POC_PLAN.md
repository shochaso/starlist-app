Status:: 
Source-of-Truth:: (TBD)
Spec-State:: 
Last-Updated:: 


# AI秘書機能 PoC実装計画

## 📅 実装スケジュール

### フェーズ1: 基盤構築（Week 1-2）
**目標:** AI秘書の基本的なデータ連携基盤を構築

#### タスク1.1: Supabaseデータ構造設計
- [ ] AI秘書用テーブル設計
  - `ai_conversations` - AI対話履歴
  - `ai_insights` - AI分析結果
  - `ai_schedules` - AI提案スケジュール
  - `ai_content_suggestions` - コンテンツ提案
- [ ] RLSポリシー設定
- [ ] Edge Functions準備

#### タスク1.2: データブリッジ実装
- [ ] Supabaseクライアント初期化
- [ ] Google Calendar API連携
- [ ] YouTube Data API連携
- [ ] データ同期サービス作成

#### タスク1.3: AI処理基盤
- [ ] OpenAI/Claude API統合
- [ ] プロンプトエンジニアリング
- [ ] レスポンスパーサー実装

### フェーズ2: スター向け機能実装（Week 3-4）
**目標:** スターがAI秘書と対話できる基本UIを実装

#### タスク2.1: AIダッシュボード画面
- [ ] `ai_secretary_screen.dart` 作成
- [ ] チャットインターフェース実装
- [ ] データカード表示コンポーネント
- [ ] Notionライクなカード配置機能

#### タスク2.2: スケジュール提案機能
- [ ] 過去の投稿データ分析
- [ ] 最適な投稿時間算出ロジック
- [ ] カレンダー統合UI
- [ ] ワンクリック承認機能

#### タスク2.3: コンテンツアドバイザー
- [ ] トレンド検出機能
- [ ] コンテンツアイデア生成
- [ ] タイトル・キャプション提案
- [ ] エンゲージメント予測

### フェーズ3: ファン向け機能実装（Week 5-6）
**目標:** ファンがAI推薦を受けられる機能を実装

#### タスク3.1: パーソナライズ推薦
- [ ] ファンの視聴履歴分析
- [ ] 推しスターの傾向分析
- [ ] クロスプラットフォーム推薦
- [ ] 推薦理由の可視化

#### タスク3.2: AI要約機能
- [ ] スター活動の自動要約
- [ ] トレンド変化の通知
- [ ] ハイライト抽出

### フェーズ4: 最適化とテスト（Week 7-8）
**目標:** パフォーマンス最適化とユーザーテスト

#### タスク4.1: パフォーマンス最適化
- [ ] API呼び出し最適化
- [ ] キャッシュ戦略実装
- [ ] レスポンス時間改善
- [ ] コスト最適化

#### タスク4.2: テストとフィードバック
- [ ] ユニットテスト作成
- [ ] 統合テスト実施
- [ ] ベータユーザーテスト
- [ ] フィードバック収集と改善

---

## 🎯 即座に着手すべきタスク

### 優先度1: Supabaseテーブル設計とマイグレーション

#### 1. AI秘書用データベーススキーマ
```sql
-- AI対話履歴テーブル
CREATE TABLE ai_conversations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  user_type TEXT CHECK (user_type IN ('star', 'fan')),
  message TEXT NOT NULL,
  response TEXT NOT NULL,
  context JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- AI分析結果テーブル
CREATE TABLE ai_insights (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  star_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  insight_type TEXT CHECK (insight_type IN ('engagement', 'trend', 'schedule', 'content')),
  title TEXT NOT NULL,
  summary TEXT NOT NULL,
  details JSONB,
  priority INTEGER DEFAULT 0,
  is_read BOOLEAN DEFAULT FALSE,
  valid_until TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- AI提案スケジュールテーブル
CREATE TABLE ai_schedules (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  star_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  suggested_time TIMESTAMP WITH TIME ZONE NOT NULL,
  content_type TEXT NOT NULL,
  reason TEXT NOT NULL,
  estimated_engagement INTEGER,
  status TEXT CHECK (status IN ('pending', 'approved', 'rejected', 'completed')) DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- AIコンテンツ提案テーブル
CREATE TABLE ai_content_suggestions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  star_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  content_type TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  keywords TEXT[],
  estimated_engagement INTEGER,
  trend_relevance INTEGER,
  status TEXT CHECK (status IN ('new', 'in_progress', 'published', 'rejected')) DEFAULT 'new',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLSポリシー設定
ALTER TABLE ai_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_insights ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_content_suggestions ENABLE ROW LEVEL SECURITY;

-- ユーザーは自分のデータのみアクセス可能
CREATE POLICY "Users can view own conversations"
  ON ai_conversations FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own conversations"
  ON ai_conversations FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Stars can view own insights"
  ON ai_insights FOR SELECT
  USING (auth.uid() = star_id);

CREATE POLICY "Stars can view own schedules"
  ON ai_schedules FOR SELECT
  USING (auth.uid() = star_id);

CREATE POLICY "Stars can update own schedules"
  ON ai_schedules FOR UPDATE
  USING (auth.uid() = star_id);

CREATE POLICY "Stars can view own content suggestions"
  ON ai_content_suggestions FOR SELECT
  USING (auth.uid() = star_id);

CREATE POLICY "Stars can update own content suggestions"
  ON ai_content_suggestions FOR UPDATE
  USING (auth.uid() = star_id);
```

### 優先度2: Flutter側のデータモデル作成

#### 2. Dartモデルクラス
```dart
// lib/features/ai_secretary/models/ai_conversation.dart
class AiConversation {
  final String id;
  final String userId;
  final String userType;
  final String message;
  final String response;
  final Map<String, dynamic>? context;
  final DateTime createdAt;

  AiConversation({
    required this.id,
    required this.userId,
    required this.userType,
    required this.message,
    required this.response,
    this.context,
    required this.createdAt,
  });

  factory AiConversation.fromJson(Map<String, dynamic> json) {
    return AiConversation(
      id: json['id'],
      userId: json['user_id'],
      userType: json['user_type'],
      message: json['message'],
      response: json['response'],
      context: json['context'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_type': userType,
      'message': message,
      'response': response,
      'context': context,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// lib/features/ai_secretary/models/ai_insight.dart
class AiInsight {
  final String id;
  final String starId;
  final String insightType;
  final String title;
  final String summary;
  final Map<String, dynamic>? details;
  final int priority;
  final bool isRead;
  final DateTime? validUntil;
  final DateTime createdAt;

  AiInsight({
    required this.id,
    required this.starId,
    required this.insightType,
    required this.title,
    required this.summary,
    this.details,
    required this.priority,
    required this.isRead,
    this.validUntil,
    required this.createdAt,
  });

  factory AiInsight.fromJson(Map<String, dynamic> json) {
    return AiInsight(
      id: json['id'],
      starId: json['star_id'],
      insightType: json['insight_type'],
      title: json['title'],
      summary: json['summary'],
      details: json['details'],
      priority: json['priority'],
      isRead: json['is_read'],
      validUntil: json['valid_until'] != null 
          ? DateTime.parse(json['valid_until']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// lib/features/ai_secretary/models/ai_schedule.dart
class AiSchedule {
  final String id;
  final String starId;
  final DateTime suggestedTime;
  final String contentType;
  final String reason;
  final int? estimatedEngagement;
  final String status;
  final DateTime createdAt;

  AiSchedule({
    required this.id,
    required this.starId,
    required this.suggestedTime,
    required this.contentType,
    required this.reason,
    this.estimatedEngagement,
    required this.status,
    required this.createdAt,
  });

  factory AiSchedule.fromJson(Map<String, dynamic> json) {
    return AiSchedule(
      id: json['id'],
      starId: json['star_id'],
      suggestedTime: DateTime.parse(json['suggested_time']),
      contentType: json['content_type'],
      reason: json['reason'],
      estimatedEngagement: json['estimated_engagement'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// lib/features/ai_secretary/models/ai_content_suggestion.dart
class AiContentSuggestion {
  final String id;
  final String starId;
  final String contentType;
  final String title;
  final String description;
  final List<String> keywords;
  final int? estimatedEngagement;
  final int? trendRelevance;
  final String status;
  final DateTime createdAt;

  AiContentSuggestion({
    required this.id,
    required this.starId,
    required this.contentType,
    required this.title,
    required this.description,
    required this.keywords,
    this.estimatedEngagement,
    this.trendRelevance,
    required this.status,
    required this.createdAt,
  });

  factory AiContentSuggestion.fromJson(Map<String, dynamic> json) {
    return AiContentSuggestion(
      id: json['id'],
      starId: json['star_id'],
      contentType: json['content_type'],
      title: json['title'],
      description: json['description'],
      keywords: List<String>.from(json['keywords'] ?? []),
      estimatedEngagement: json['estimated_engagement'],
      trendRelevance: json['trend_relevance'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
```

### 優先度3: リポジトリとサービス作成

#### 3. AI秘書リポジトリ
```dart
// lib/features/ai_secretary/repositories/ai_secretary_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ai_conversation.dart';
import '../models/ai_insight.dart';
import '../models/ai_schedule.dart';
import '../models/ai_content_suggestion.dart';

class AiSecretaryRepository {
  final SupabaseClient _supabase;

  AiSecretaryRepository(this._supabase);

  // 対話履歴の取得
  Future<List<AiConversation>> getConversations(String userId) async {
    final response = await _supabase
        .from('ai_conversations')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);
    
    return (response as List)
        .map((json) => AiConversation.fromJson(json))
        .toList();
  }

  // 新しい対話を保存
  Future<AiConversation> saveConversation({
    required String userId,
    required String userType,
    required String message,
    required String response,
    Map<String, dynamic>? context,
  }) async {
    final data = {
      'user_id': userId,
      'user_type': userType,
      'message': message,
      'response': response,
      'context': context,
    };

    final result = await _supabase
        .from('ai_conversations')
        .insert(data)
        .select()
        .single();

    return AiConversation.fromJson(result);
  }

  // AI分析結果の取得
  Future<List<AiInsight>> getInsights(String starId) async {
    final response = await _supabase
        .from('ai_insights')
        .select()
        .eq('star_id', starId)
        .order('priority', ascending: false)
        .order('created_at', ascending: false);
    
    return (response as List)
        .map((json) => AiInsight.fromJson(json))
        .toList();
  }

  // AI提案スケジュールの取得
  Future<List<AiSchedule>> getSchedules(String starId) async {
    final response = await _supabase
        .from('ai_schedules')
        .select()
        .eq('star_id', starId)
        .order('suggested_time', ascending: true);
    
    return (response as List)
        .map((json) => AiSchedule.fromJson(json))
        .toList();
  }

  // スケジュールステータス更新
  Future<void> updateScheduleStatus(String scheduleId, String status) async {
    await _supabase
        .from('ai_schedules')
        .update({'status': status})
        .eq('id', scheduleId);
  }

  // コンテンツ提案の取得
  Future<List<AiContentSuggestion>> getContentSuggestions(String starId) async {
    final response = await _supabase
        .from('ai_content_suggestions')
        .select()
        .eq('star_id', starId)
        .order('trend_relevance', ascending: false)
        .order('created_at', ascending: false);
    
    return (response as List)
        .map((json) => AiContentSuggestion.fromJson(json))
        .toList();
  }

  // コンテンツ提案ステータス更新
  Future<void> updateContentSuggestionStatus(
      String suggestionId, String status) async {
    await _supabase
        .from('ai_content_suggestions')
        .update({'status': status})
        .eq('id', suggestionId);
  }
}
```

---

## 🚀 次の具体的アクション

### 今すぐ実行すべきこと：

1. **Supabaseマイグレーションファイル作成**
   ```bash
   # 新しいマイグレーションファイルを作成
   touch supabase/migrations/20251015_create_ai_secretary_tables.sql
   ```

2. **Flutter側のディレクトリ構造作成**
   ```bash
   mkdir -p lib/features/ai_secretary/{models,repositories,services,screens,widgets,providers}
   ```

3. **必要な依存関係の追加**
   ```yaml
   # pubspec.yaml に追加
   dependencies:
     http: ^1.1.0
     # AI API用（OpenAI, Anthropic Claudeなど）
   ```

4. **環境変数設定**
   ```bash
   # .env ファイルに追加
   OPENAI_API_KEY=your_key_here
   # または
   ANTHROPIC_API_KEY=your_key_here
   ```

実装を開始しますか？どのタスクから始めたいか指示してください！
