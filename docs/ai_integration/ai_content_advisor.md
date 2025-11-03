# AI Content Advisor：投稿提案AI設計

## 📋 概要

**AI Content Advisor** は、スターの行動履歴・過去投稿・ファン反応を分析し、最適な投稿内容・タイミング・フォーマットを提案するAIシステムです。単なるテンプレート提供ではなく、個々のスターの個性・ファンの嗜好を学習し、パーソナライズされた提案を行います。

---

## 🎯 目的

### スター向け
- **投稿ネタ枯渇の解消**: 日常データから自動的に投稿アイデアを生成
- **エンゲージメント最大化**: ファンが反応しやすい内容・タイミングを提案
- **効率化**: 投稿作成時間を50%削減

### ファン向け
- **質の高いコンテンツ**: AIがスターの強みを活かした投稿を促進
- **期待値管理**: 次の投稿内容を予測し、ファンの期待を高める

---

## 🏗️ アーキテクチャ

### システム構成

```
┌─────────────────────┐
│   行動データ        │ ← 視聴履歴・購買履歴・SNS活動
│ (Viewing/Purchase)  │
└──────────┬──────────┘
           │
           ↓
┌─────────────────────┐
│  Data Analyzer      │ ← パターン抽出・カテゴリ分類
└──────────┬──────────┘
           │
           ↓
┌─────────────────────┐
│   Past Posts DB     │ ← 過去投稿・ファン反応データ
└──────────┬──────────┘
           │
           ↓
┌─────────────────────┐
│  AI Content Engine  │ ← GPT/Claude で投稿案生成
│  (Edge Function)    │
└──────────┬──────────┘
           │
           ↓
┌─────────────────────┐
│  Suggestion UI      │ ← 提案表示・編集・投稿
└─────────────────────┘
```

---

## 📊 データモデル

### Supabase テーブル設計

#### posts テーブル（既存）
```sql
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  star_id UUID REFERENCES auth.users(id),
  content TEXT NOT NULL,
  category TEXT, -- 'review', 'daily', 'recommendation'
  tags TEXT[],
  created_at TIMESTAMPTZ DEFAULT NOW(),
  engagement_score FLOAT DEFAULT 0.0, -- いいね・コメント数から算出
  source_data_id UUID -- 視聴履歴や購買履歴の元データID
);
```

#### ai_content_suggestions テーブル
```sql
CREATE TABLE ai_content_suggestions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  star_id UUID REFERENCES auth.users(id),
  suggested_content TEXT NOT NULL,
  suggested_title TEXT,
  category TEXT,
  tags TEXT[],
  confidence_score FLOAT, -- 0.0 ~ 1.0
  reason TEXT, -- 提案理由
  source_data JSONB, -- 元になったデータ（視聴履歴など）
  is_used BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_suggestions_star ON ai_content_suggestions(star_id, created_at DESC);
```

#### fan_engagement_history テーブル
```sql
CREATE TABLE fan_engagement_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id UUID REFERENCES posts(id),
  fan_id UUID REFERENCES auth.users(id),
  action_type TEXT, -- 'like', 'comment', 'share', 'purchase'
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_engagement_post ON fan_engagement_history(post_id, action_type);
```

---

## 🧠 過去投稿データの分析手法

### 1. カテゴリ別成功パターン

```dart
class PostPerformanceAnalyzer {
  /// カテゴリ別の平均エンゲージメントを分析
  Future<Map<String, double>> analyzeCategoryPerformance(String starId) async {
    final posts = await supabase
        .from('posts')
        .select('category, engagement_score')
        .eq('star_id', starId);

    final categoryScores = <String, List<double>>{};

    for (final post in posts) {
      final category = post['category'] as String;
      final score = post['engagement_score'] as double;

      categoryScores.putIfAbsent(category, () => []).add(score);
    }

    // 平均スコアを計算
    return categoryScores.map((category, scores) {
      final avg = scores.reduce((a, b) => a + b) / scores.length;
      return MapEntry(category, avg);
    });
  }
}
```

### 2. タグ別トレンド分析

```dart
class TagTrendAnalyzer {
  /// タグ別のトレンドを分析（最近30日）
  Future<List<TagTrend>> analyzeTrends(String starId) async {
    final posts = await supabase
        .from('posts')
        .select('tags, engagement_score, created_at')
        .eq('star_id', starId)
        .gte('created_at', DateTime.now().subtract(Duration(days: 30)).toIso8601String());

    final tagScores = <String, List<double>>{};

    for (final post in posts) {
      final tags = (post['tags'] as List).cast<String>();
      final score = post['engagement_score'] as double;

      for (final tag in tags) {
        tagScores.putIfAbsent(tag, () => []).add(score);
      }
    }

    // トレンドスコア算出（平均 × 出現頻度）
    return tagScores.entries
        .map((e) => TagTrend(
              tag: e.key,
              avgScore: e.value.reduce((a, b) => a + b) / e.value.length,
              frequency: e.value.length,
              trendScore: (e.value.reduce((a, b) => a + b) / e.value.length) * e.value.length,
            ))
        .toList()
      ..sort((a, b) => b.trendScore.compareTo(a.trendScore));
  }
}
```

---

## 🎨 ファン反応パターンの学習

### 1. エンゲージメント予測モデル

```dart
class EngagementPredictor {
  /// 投稿内容からエンゲージメントを予測
  Future<double> predictEngagement({
    required String content,
    required List<String> tags,
    required String category,
    required DateTime postTime,
  }) async {
    // 過去の類似投稿を取得
    final similarPosts = await _findSimilarPosts(content, tags, category);

    // 時間帯補正
    final hourFactor = await _getHourFactor(postTime.hour);

    // 曜日補正
    final weekdayFactor = await _getWeekdayFactor(postTime.weekday);

    // 基本スコア（類似投稿の平均）
    final baseScore = similarPosts.isEmpty
        ? 0.5
        : similarPosts.map((p) => p.engagementScore).reduce((a, b) => a + b) /
            similarPosts.length;

    // 補正後スコア
    return baseScore * hourFactor * weekdayFactor;
  }

  /// 時間帯別のエンゲージメント係数
  Future<double> _getHourFactor(int hour) async {
    final stats = await _getHourlyEngagementStats();
    return stats[hour] ?? 1.0;
  }

  /// 曜日別のエンゲージメント係数
  Future<double> _getWeekdayFactor(int weekday) async {
    final stats = await _getWeekdayEngagementStats();
    return stats[weekday] ?? 1.0;
  }
}
```

### 2. ファンセグメント分析

```dart
class FanSegmentAnalyzer {
  /// ファンをセグメント化し、嗜好を分析
  Future<Map<String, FanSegment>> analyzeFanSegments(String starId) async {
    final fans = await _getStarFans(starId);
    final engagements = await _getFanEngagements(starId);

    final segments = <String, List<Fan>>{
      'active': [],       // 週1回以上反応
      'moderate': [],     // 月1〜3回反応
      'passive': [],      // 月1回未満
    };

    for (final fan in fans) {
      final fanEngagements = engagements.where((e) => e.fanId == fan.id);
      final monthlyEngagements = fanEngagements
          .where((e) => e.createdAt.isAfter(DateTime.now().subtract(Duration(days: 30))))
          .length;

      if (monthlyEngagements >= 4) {
        segments['active']!.add(fan);
      } else if (monthlyEngagements >= 1) {
        segments['moderate']!.add(fan);
      } else {
        segments['passive']!.add(fan);
      }
    }

    return segments.map((key, fans) => MapEntry(
          key,
          FanSegment(
            name: key,
            count: fans.length,
            preferences: _analyzePreferences(fans, engagements),
          ),
        ));
  }
}
```

---

## 🕒 最適な投稿タイミング予測

### 1. ヒートマップ生成

```dart
class PostTimingHeatmapGenerator {
  /// 曜日×時間帯のエンゲージメントヒートマップ
  Future<List<List<double>>> generateHeatmap(String starId) async {
    final posts = await _getPostsWithEngagement(starId);

    // 7曜日 × 24時間の2次元配列
    final heatmap = List.generate(7, (_) => List.filled(24, 0.0));
    final counts = List.generate(7, (_) => List.filled(24, 0));

    for (final post in posts) {
      final weekday = post.createdAt.weekday - 1; // 0-6
      final hour = post.createdAt.hour;

      heatmap[weekday][hour] += post.engagementScore;
      counts[weekday][hour] += 1;
    }

    // 平均化
    for (var day = 0; day < 7; day++) {
      for (var hour = 0; hour < 24; hour++) {
        if (counts[day][hour] > 0) {
          heatmap[day][hour] /= counts[day][hour];
        }
      }
    }

    return heatmap;
  }

  /// 最適な投稿時間を提案
  DateTime suggestOptimalTime(List<List<double>> heatmap, DateTime targetDate) {
    final weekday = targetDate.weekday - 1;
    final dayScores = heatmap[weekday];

    // 最もスコアが高い時間帯
    var maxScore = 0.0;
    var optimalHour = 12;

    for (var hour = 0; hour < 24; hour++) {
      if (dayScores[hour] > maxScore) {
        maxScore = dayScores[hour];
        optimalHour = hour;
      }
    }

    return DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      optimalHour,
    );
  }
}
```

### 2. リアルタイム調整

```dart
class RealtimeTimingAdjuster {
  /// 現在のファンのオンライン状況を考慮して調整
  Future<DateTime> adjustForRealtimeFanActivity({
    required DateTime suggestedTime,
    required String starId,
  }) async {
    final onlineFans = await _getOnlineFans(starId);
    final onlineRate = onlineFans.length / await _getTotalFans(starId);

    // オンライン率が高い（30%以上）なら即座に投稿を推奨
    if (onlineRate > 0.3 && DateTime.now().isBefore(suggestedTime)) {
      return DateTime.now().add(Duration(minutes: 5));
    }

    return suggestedTime;
  }
}
```

---

## 💡 コンテンツカテゴリ別推薦ロジック

### 1. カテゴリ定義

```dart
enum ContentCategory {
  review,          // レビュー（映画・ドラマ・本）
  daily,           // 日常報告
  recommendation,  // おすすめ紹介
  question,        // ファンへの質問
  announcement,    // お知らせ
  poll,            // 投票
}

class ContentCategoryDetector {
  /// 行動データからカテゴリを推定
  ContentCategory detectOptimalCategory(Map<String, dynamic> activityData) {
    final recentViewing = activityData['viewing'] as List;
    final recentPurchase = activityData['purchase'] as List;
    final lastPosts = activityData['last_posts'] as List;

    // 視聴データが多い → レビュー
    if (recentViewing.length >= 3) {
      return ContentCategory.review;
    }

    // 購買データが多い → おすすめ紹介
    if (recentPurchase.length >= 2) {
      return ContentCategory.recommendation;
    }

    // 最近投稿がない → 日常報告
    if (lastPosts.isEmpty || 
        DateTime.now().difference(lastPosts.first.createdAt).inDays >= 3) {
      return ContentCategory.daily;
    }

    // ファンとの交流が少ない → 質問投稿
    final recentEngagement = activityData['fan_engagement'] as int;
    if (recentEngagement < 10) {
      return ContentCategory.question;
    }

    return ContentCategory.daily;
  }
}
```

### 2. カテゴリ別生成ロジック

```dart
class CategoryBasedContentGenerator {
  Future<ContentSuggestion> generateForCategory({
    required ContentCategory category,
    required Map<String, dynamic> userData,
  }) async {
    switch (category) {
      case ContentCategory.review:
        return await _generateReview(userData);

      case ContentCategory.recommendation:
        return await _generateRecommendation(userData);

      case ContentCategory.daily:
        return await _generateDaily(userData);

      case ContentCategory.question:
        return await _generateQuestion(userData);

      default:
        return await _generateDefault(userData);
    }
  }

  /// レビュー投稿生成
  Future<ContentSuggestion> _generateReview(Map<String, dynamic> data) async {
    final recentViewing = data['viewing'] as List;
    final topItem = recentViewing.first;

    final aiPrompt = '''
以下の視聴データからレビュー投稿案を作成してください:

作品名: ${topItem['title']}
ジャンル: ${topItem['genre']}
視聴日: ${topItem['viewed_at']}
ユーザーの過去の好み: ${data['preferences']}

フォーマット:
- タイトル: キャッチーな見出し（20文字以内）
- 本文: 3〜4文で感想を述べる
- タグ: 関連タグ3〜5個
''';

    final aiResponse = await _callAI(aiPrompt);

    return ContentSuggestion(
      category: 'review',
      title: aiResponse['title'],
      content: aiResponse['content'],
      tags: aiResponse['tags'],
      confidenceScore: 0.85,
      reason: '最近「${topItem['title']}」を視聴したため',
      sourceData: topItem,
    );
  }

  /// おすすめ紹介生成
  Future<ContentSuggestion> _generateRecommendation(Map<String, dynamic> data) async {
    final recentPurchase = data['purchase'] as List;
    final topItem = recentPurchase.first;

    final aiPrompt = '''
以下の購買データからおすすめ紹介投稿を作成してください:

商品名: ${topItem['product_name']}
カテゴリ: ${topItem['category']}
購入日: ${topItem['purchase_date']}
価格: ${topItem['price']}円

フォーマット:
- タイトル: 商品の魅力を一言で（20文字以内）
- 本文: おすすめポイントを3つ挙げる
- タグ: 商品カテゴリ・ブランド名など
''';

    final aiResponse = await _callAI(aiPrompt);

    return ContentSuggestion(
      category: 'recommendation',
      title: aiResponse['title'],
      content: aiResponse['content'],
      tags: aiResponse['tags'],
      confidenceScore: 0.80,
      reason: '最近「${topItem['product_name']}」を購入したため',
      sourceData: topItem,
    );
  }
}
```

---

## 🎯 AIエンジン実装（Supabase Edge Function）

### 1. コンテンツ生成エンドポイント

```typescript
// supabase/functions/ai-content-generator/index.ts
import { serve } from 'https://deno.land/std/http/server.ts';
import { createClient } from '@supabase/supabase-js';

serve(async (req) => {
  const {
    star_id,
    category,
    source_data,
    user_preferences,
  } = await req.json();

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  );

  // 過去の成功投稿を取得
  const { data: successfulPosts } = await supabase
    .from('posts')
    .select('*')
    .eq('star_id', star_id)
    .gte('engagement_score', 0.7)
    .order('created_at', { ascending: false })
    .limit(10);

  // AI に投稿案を生成させる
  const aiResponse = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'x-api-key': Deno.env.get('ANTHROPIC_API_KEY')!,
      'anthropic-version': '2023-06-01',
      'content-type': 'application/json',
    },
    body: JSON.stringify({
      model: 'claude-3-5-sonnet-20241022',
      max_tokens: 2048,
      messages: [
        {
          role: 'user',
          content: `
あなたはSTARLISTのスター向けコンテンツアドバイザーです。

【スターの過去の成功投稿】
${JSON.stringify(successfulPosts, null, 2)}

【最近の行動データ】
${JSON.stringify(source_data, null, 2)}

【ユーザー嗜好】
${JSON.stringify(user_preferences, null, 2)}

【カテゴリ】
${category}

上記を踏まえ、ファンが反応しやすい投稿案を作成してください。

出力形式（JSON）:
{
  "title": "キャッチーなタイトル（20文字以内）",
  "content": "本文（200〜400文字）",
  "tags": ["タグ1", "タグ2", "タグ3"],
  "confidence_score": 0.85,
  "reason": "提案理由"
}
          `,
        },
      ],
    }),
  });

  const result = await aiResponse.json();
  const suggestion = JSON.parse(result.content[0].text);

  // Supabase に保存
  await supabase.from('ai_content_suggestions').insert({
    star_id,
    suggested_title: suggestion.title,
    suggested_content: suggestion.content,
    category,
    tags: suggestion.tags,
    confidence_score: suggestion.confidence_score,
    reason: suggestion.reason,
    source_data,
  });

  return new Response(JSON.stringify(suggestion), {
    headers: { 'Content-Type': 'application/json' },
  });
});
```

---

## 🎨 UI実装

### 1. コンテンツ提案画面

```dart
class AiContentAdvisorScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(contentSuggestionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('💡 AI投稿アドバイザー'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => ref.refresh(contentSuggestionsProvider),
          ),
        ],
      ),
      body: suggestions.when(
        data: (data) => ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final suggestion = data[index];
            return ContentSuggestionCard(
              suggestion: suggestion,
              onUse: () => _usesuggestion(context, ref, suggestion),
              onEdit: () => _editSuggestion(context, ref, suggestion),
              onDismiss: () => _dismissSuggestion(ref, suggestion),
            );
          },
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
      ),
    );
  }
}
```

### 2. 提案カード

```dart
class ContentSuggestionCard extends StatelessWidget {
  final ContentSuggestion suggestion;
  final VoidCallback onUse;
  final VoidCallback onEdit;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー：カテゴリ + 信頼度
            Row(
              children: [
                Chip(
                  label: Text(suggestion.category),
                  backgroundColor: _getCategoryColor(suggestion.category),
                ),
                Spacer(),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _getConfidenceColor(suggestion.confidenceScore),
                  child: Text(
                    '${(suggestion.confidenceScore * 100).toInt()}%',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // タイトル
            Text(
              suggestion.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 12),

            // 本文プレビュー
            Text(
              suggestion.content,
              style: TextStyle(fontSize: 14, height: 1.5),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 16),

            // タグ
            Wrap(
              spacing: 8,
              children: suggestion.tags.map((tag) => Chip(
                label: Text(tag, style: TextStyle(fontSize: 12)),
                backgroundColor: Colors.blue.shade50,
              )).toList(),
            ),

            SizedBox(height: 16),

            // AI提案理由
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, size: 16, color: Colors.amber.shade700),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion.reason,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // アクションボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: onDismiss,
                  icon: Icon(Icons.close),
                  label: Text('却下'),
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: Icon(Icons.edit),
                      label: Text('編集'),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: onUse,
                      icon: Icon(Icons.send),
                      label: Text('投稿する'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 📈 学習・改善サイクル

### 1. フィードバックループ

```dart
class ContentAdvisorLearningEngine {
  /// 投稿結果からAIモデルを改善
  Future<void> learnFromResult({
    required String suggestionId,
    required String postId,
  }) async {
    // 投稿の実際のエンゲージメントを取得
    final post = await supabase
        .from('posts')
        .select('engagement_score')
        .eq('id', postId)
        .single();

    final actualScore = post['engagement_score'] as double;

    // 提案時の予測スコアを取得
    final suggestion = await supabase
        .from('ai_content_suggestions')
        .select('confidence_score, category, tags')
        .eq('id', suggestionId)
        .single();

    final predictedScore = suggestion['confidence_score'] as double;

    // 予測精度を記録
    await supabase.from('ai_learning_feedback').insert({
      'suggestion_id': suggestionId,
      'post_id': postId,
      'predicted_score': predictedScore,
      'actual_score': actualScore,
      'accuracy': 1.0 - (predictedScore - actualScore).abs(),
      'category': suggestion['category'],
      'tags': suggestion['tags'],
    });

    // 精度が低い場合、Edge Function に学習指示
    if ((predictedScore - actualScore).abs() > 0.2) {
      await _triggerModelRetraining(suggestion['category']);
    }
  }
}
```

### 2. A/Bテスト

```dart
class ContentABTester {
  /// 2つの投稿案でA/Bテストを実施
  Future<ContentSuggestion> runABTest({
    required ContentSuggestion variantA,
    required ContentSuggestion variantB,
    required String starId,
  }) async {
    // ファンを2グループに分割
    final fans = await _getStarFans(starId);
    final groupA = fans.take(fans.length ~/ 2).toList();
    final groupB = fans.skip(fans.length ~/ 2).toList();

    // グループAにvariantAを表示、グループBにvariantBを表示
    final resultsA = await _showToGroup(variantA, groupA);
    final resultsB = await _showToGroup(variantB, groupB);

    // エンゲージメントを比較
    if (resultsA.avgEngagement > resultsB.avgEngagement) {
      return variantA;
    } else {
      return variantB;
    }
  }
}
```

---

## 🎬 実装例：動画レビュー投稿

### ワークフロー

1. **データ収集**: スターがNetflixで「ハウス・オブ・カード」を視聴
2. **AI分析**: 
   - ジャンル: 政治ドラマ
   - 過去の投稿: 政治系コンテンツのエンゲージメントが高い
   - ファン層: 30代・ビジネスパーソンが多い
3. **提案生成**:
   ```
   タイトル: 「権力の裏側を描く傑作：ハウス・オブ・カード」
   本文: 政治の駆け引きをリアルに描いたNetflixオリジナル。
        主人公の冷徹な戦略に引き込まれます。
        ビジネスにも通じる交渉術が学べる作品です！
   タグ: #Netflix #政治ドラマ #ハウスオブカード #おすすめ #海外ドラマ
   信頼度: 87%
   理由: 過去の政治系投稿の平均エンゲージメントは0.85。
         ファンの30%がビジネス系コンテンツに反応。
   ```
4. **最適タイミング**: 木曜20時（ファンのアクティブ時間帯ピーク）

---

## 🔧 Riverpod状態管理

### Provider定義

```dart
// lib/features/ai_content_advisor/providers/content_suggestions_provider.dart

final contentSuggestionsProvider = FutureProvider.autoDispose<List<ContentSuggestion>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];

  final service = ref.watch(contentAdvisorServiceProvider);
  return await service.getSuggestions(userId);
});

final contentAdvisorServiceProvider = Provider<ContentAdvisorService>((ref) {
  return ContentAdvisorService(
    supabase: ref.watch(supabaseClientProvider),
  );
});
```

### サービス実装

```dart
class ContentAdvisorService {
  final SupabaseClient supabase;

  ContentAdvisorService({required this.supabase});

  /// AI提案を取得
  Future<List<ContentSuggestion>> getSuggestions(String starId) async {
    // 行動データを収集
    final context = await _collectContext(starId);

    // Edge Function で AI生成
    final response = await supabase.functions.invoke(
      'ai-content-generator',
      body: {
        'star_id': starId,
        'context': context,
      },
    );

    final suggestions = (response.data as List)
        .map((json) => ContentSuggestion.fromJson(json))
        .toList();

    return suggestions;
  }

  /// 提案を投稿として使用
  Future<void> useSuggestion({
    required String suggestionId,
    String? editedContent,
  }) async {
    final suggestion = await supabase
        .from('ai_content_suggestions')
        .select()
        .eq('id', suggestionId)
        .single();

    // 投稿作成
    final post = await supabase.from('posts').insert({
      'star_id': suggestion['star_id'],
      'content': editedContent ?? suggestion['suggested_content'],
      'category': suggestion['category'],
      'tags': suggestion['tags'],
      'source_data_id': suggestion['source_data']?['id'],
    }).select().single();

    // 提案を使用済みにマーク
    await supabase
        .from('ai_content_suggestions')
        .update({'is_used': true})
        .eq('id', suggestionId);

    // 学習データとして記録
    await _recordUsage(suggestionId, post['id']);
  }
}
```

---

## 📊 分析ダッシュボード

### コンテンツパフォーマンスビュー

```dart
class ContentPerformanceDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(contentStatsProvider);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📊 コンテンツパフォーマンス', style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),

            SizedBox(height: 20),

            // カテゴリ別成功率
            _buildCategoryChart(stats.categoryPerformance),

            SizedBox(height: 20),

            // AI提案の精度
            _buildMetric(
              icon: Icons.psychology,
              label: 'AI提案精度',
              value: '${(stats.aiAccuracy * 100).toInt()}%',
              subtitle: '過去30日の平均',
            ),

            // 投稿採用率
            _buildMetric(
              icon: Icons.check_circle,
              label: 'AI提案採用率',
              value: '${(stats.suggestionUsageRate * 100).toInt()}%',
              subtitle: '提案のうち実際に投稿した割合',
            ),

            // 平均エンゲージメント向上率
            _buildMetric(
              icon: Icons.trending_up,
              label: 'エンゲージメント向上',
              value: '+${(stats.engagementImprovement * 100).toInt()}%',
              subtitle: 'AI提案使用前後の比較',
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🧪 テスト

### 1. コンテンツ生成テスト

```dart
void main() {
  group('ContentAdvisorService', () {
    test('視聴履歴からレビュー提案を生成', () async {
      final service = ContentAdvisorService(supabase: mockSupabase);

      final context = {
        'viewing': [
          {'title': 'Breaking Bad', 'genre': 'crime'},
        ],
      };

      final suggestions = await service.generateSuggestions(
        starId: 'test-star-id',
        context: context,
      );

      expect(suggestions.length, greaterThan(0));
      expect(suggestions.first.category, 'review');
      expect(suggestions.first.tags, contains('crime'));
    });
  });
}
```

### 2. エンゲージメント予測精度テスト

```dart
void main() {
  test('エンゲージメント予測が80%以上の精度', () async {
    final predictor = EngagementPredictor();
    final testCases = await _getTestPosts(); // 実際の投稿データ

    var totalError = 0.0;

    for (final post in testCases) {
      final predicted = await predictor.predictEngagement(
        content: post.content,
        tags: post.tags,
        category: post.category,
        postTime: post.createdAt,
      );

      final actual = post.engagementScore;
      totalError += (predicted - actual).abs();
    }

    final avgError = totalError / testCases.length;
    expect(avgError, lessThan(0.2)); // 誤差20%未満
  });
}
```

---

## 🚀 実装ロードマップ

### Week 1: 基盤構築
- [ ] Supabase テーブル作成
- [ ] ContentAdvisorService 実装
- [ ] 基本UI実装

### Week 2: AI統合
- [ ] Edge Function デプロイ（ai-content-generator）
- [ ] Claude API 連携
- [ ] コンテンツ生成ロジック実装

### Week 3: 分析・学習
- [ ] PostPerformanceAnalyzer 実装
- [ ] EngagementPredictor 実装
- [ ] フィードバックループ実装

### Week 4: 最適化・テスト
- [ ] A/Bテスト機能実装
- [ ] パフォーマンスダッシュボード実装
- [ ] ユニットテスト・統合テスト完了

---

## 🎯 成功指標

- **投稿頻度**: 20%増加
- **平均エンゲージメント**: 30%向上
- **AI提案採用率**: 60%以上
- **投稿作成時間**: 50%削減
- **ファン満足度**: 4.5/5.0以上

---

## 📚 関連ドキュメント

- `ai_secretary_implementation_guide.md`: AI秘書全体設計
- `ai_scheduler_model.md`: スケジュール連携
- `ai_data_bridge.md`: データ連携技術詳細

---

**作成日**: 2025年10月15日  
**最終更新**: 2025年10月15日  
**バージョン**: 1.0.0  
**担当**: AI開発チーム（ティム＋マイン＋Claude）


