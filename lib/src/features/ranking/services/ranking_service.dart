import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ranking_model.dart';
import '../repositories/ranking_repository.dart';
import '../../../../core/errors/app_exceptions.dart';

/// ランキングサービスクラス
///
/// ランキング関連のビジネスロジックを担当します。
class RankingService {
  /// ランキングリポジトリ
  final RankingRepository _rankingRepository;

  /// コンストラクタ
  RankingService(this._rankingRepository);

  /// トレンドコンテンツを取得
  Future<RankingModel> getTrendingContent({
    RankingPeriod period = RankingPeriod.week,
    String? contentType,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    try {
      return await _rankingRepository.getTrendingContent(
        period: period,
        contentType: contentType,
        limit: limit,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      throw ServiceException('トレンドコンテンツの取得に失敗しました: $e');
    }
  }

  /// 人気スターを取得
  Future<RankingModel> getPopularStars({
    RankingPeriod period = RankingPeriod.week,
    String? category,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    try {
      return await _rankingRepository.getPopularStars(
        period: period,
        category: category,
        limit: limit,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      throw ServiceException('人気スターの取得に失敗しました: $e');
    }
  }

  /// カテゴリ別ランキングを取得
  Future<RankingModel> getCategoryRanking({
    required String categoryId,
    RankingPeriod period = RankingPeriod.week,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    try {
      return await _rankingRepository.getCategoryRanking(
        categoryId: categoryId,
        period: period,
        limit: limit,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      throw ServiceException('カテゴリランキングの取得に失敗しました: $e');
    }
  }

  /// ユーザーのパーソナライズドランキングを取得
  Future<RankingModel> getPersonalizedRanking({
    required String userId,
    RankingPeriod period = RankingPeriod.week,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    try {
      return await _rankingRepository.getPersonalizedRanking(
        userId: userId,
        period: period,
        limit: limit,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      throw ServiceException('パーソナライズドランキングの取得に失敗しました: $e');
    }
  }

  /// ランキング期間の表示名を取得
  String getPeriodDisplayName(RankingPeriod period) {
    switch (period) {
      case RankingPeriod.day:
        return '今日';
      case RankingPeriod.week:
        return '今週';
      case RankingPeriod.month:
        return '今月';
      case RankingPeriod.allTime:
        return '全期間';
    }
  }
}

/// ランキングサービスプロバイダー
final rankingServiceProvider = Provider<RankingService>((ref) {
  final rankingRepository = ref.watch(rankingRepositoryProvider);
  return RankingService(rankingRepository);
});
