import 'package:flutter_test/flutter_test.dart';
import 'package:starlist_implementation/src/features/user_experience/ai_recommendation/models/recommendation_models.dart';
import 'package:starlist_implementation/src/features/user_experience/ai_recommendation/services/ai_recommendation_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

class MockAiRecommendationService extends Mock implements AiRecommendationService {}

void main() {
  group('AIによるコンテンツ推奨システムのテスト', () {
    late AiRecommendationService recommendationService;
    
    setUp(() {
      recommendationService = AiRecommendationService();
    });
    
    test('レコメンデーションモデルが正しく作成されること', () {
      final recommendation = ContentRecommendation(
        id: 'rec_1',
        starId: 'star_1',
        title: 'ファッションアイテムのレビュー投稿',
        description: '最近購入した春物アイテムのレビューを投稿すると高いエンゲージメントが期待できます',
        type: RecommendationType.personalized,
        relevanceScore: 0.85,
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        metadata: {
          'basedOn': ['past_engagement', 'seasonal_trend'],
          'expectedEngagement': 'high',
        },
      );
      
      expect(recommendation.id, 'rec_1');
      expect(recommendation.starId, 'star_1');
      expect(recommendation.title, 'ファッションアイテムのレビュー投稿');
      expect(recommendation.type, RecommendationType.personalized);
      expect(recommendation.relevanceScore, 0.85);
      expect(recommendation.metadata['expectedEngagement'], 'high');
    });
    
    test('パーソナライズされた更新提案が正しく取得できること', () async {
      final recommendations = await recommendationService.getPersonalizedRecommendations('star_1', 5);
      
      expect(recommendations, isNotEmpty);
      expect(recommendations.length, lessThanOrEqualTo(5));
      expect(recommendations.first.starId, 'star_1');
      expect(recommendations.first.type, RecommendationType.personalized);
    });
    
    test('トレンド連動型提案が正しく取得できること', () async {
      final recommendations = await recommendationService.getTrendBasedRecommendations('star_1', 5);
      
      expect(recommendations, isNotEmpty);
      expect(recommendations.length, lessThanOrEqualTo(5));
      expect(recommendations.first.starId, 'star_1');
      expect(recommendations.first.type, RecommendationType.trending);
    });
    
    test('ファン反応分析が正しく取得できること', () async {
      final analysis = await recommendationService.getFanEngagementAnalysis('star_1');
      
      expect(analysis, isNotNull);
      expect(analysis.starId, 'star_1');
      expect(analysis.highEngagementContentTypes, isNotEmpty);
      expect(analysis.optimalPostingTimes, isNotEmpty);
      expect(analysis.topPerformingContent, isNotEmpty);
    });
    
    test('コンテンツパターン分析が正しく取得できること', () async {
      final analysis = await recommendationService.getContentPatternAnalysis('star_1');
      
      expect(analysis, isNotNull);
      expect(analysis.starId, 'star_1');
      expect(analysis.postingFrequency, isNotNull);
      expect(analysis.contentTypeDistribution, isNotEmpty);
      expect(analysis.seasonalPatterns, isNotEmpty);
    });
    
    test('レコメンデーションのフィードバックが正しく処理されること', () async {
      final result = await recommendationService.provideRecommendationFeedback(
        recommendationId: 'rec_1',
        wasImplemented: true,
        engagementScore: 0.75,
        feedback: '提案を実施したところ、予想通り高いエンゲージメントが得られました',
      );
      
      expect(result, isTrue);
    });
  });
}
