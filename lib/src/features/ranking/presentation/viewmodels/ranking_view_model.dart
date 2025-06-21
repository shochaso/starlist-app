import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ranking_model.dart';
import '../services/ranking_service.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_message.dart';

/// ランキングビューモデルクラス
///
/// ランキング画面のUIロジックを担当します。
class RankingViewModel extends StateNotifier<RankingViewState> {
  /// ランキングサービス
  final RankingService _rankingService;

  /// コンストラクタ
  RankingViewModel(this._rankingService) : super(RankingViewState.initial());

  /// トレンドコンテンツを読み込む
  Future<void> loadTrendingContent({
    RankingPeriod period = RankingPeriod.week,
    String? contentType,
    bool refresh = false,
  }) async {
    try {
      // リフレッシュの場合はステートをリセット
      if (refresh) {
        state = state.copyWith(
          isLoadingTrending: true,
          trendingError: null,
          selectedPeriod: period,
        );
      } else if (state.isLoadingTrending) {
        // すでに読み込み中の場合は何もしない
        return;
      } else {
        // 追加読み込みの場合
        state = state.copyWith(
          isLoadingTrending: true,
          trendingError: null,
          selectedPeriod: period,
        );
      }

      final ranking = await _rankingService.getTrendingContent(
        period: period,
        contentType: contentType,
        forceRefresh: refresh,
      );

      state = state.copyWith(
        trendingRanking: ranking,
        isLoadingTrending: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingTrending: false,
        trendingError: e.toString(),
      );
    }
  }

  /// 人気スターを読み込む
  Future<void> loadPopularStars({
    RankingPeriod period = RankingPeriod.week,
    String? category,
    bool refresh = false,
  }) async {
    try {
      // リフレッシュの場合はステートをリセット
      if (refresh) {
        state = state.copyWith(
          isLoadingPopularStars: true,
          popularStarsError: null,
          selectedPeriod: period,
        );
      } else if (state.isLoadingPopularStars) {
        // すでに読み込み中の場合は何もしない
        return;
      } else {
        // 追加読み込みの場合
        state = state.copyWith(
          isLoadingPopularStars: true,
          popularStarsError: null,
          selectedPeriod: period,
        );
      }

      final ranking = await _rankingService.getPopularStars(
        period: period,
        category: category,
        forceRefresh: refresh,
      );

      state = state.copyWith(
        popularStarsRanking: ranking,
        isLoadingPopularStars: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingPopularStars: false,
        popularStarsError: e.toString(),
      );
    }
  }

  /// カテゴリ別ランキングを読み込む
  Future<void> loadCategoryRanking({
    required String categoryId,
    RankingPeriod period = RankingPeriod.week,
    bool refresh = false,
  }) async {
    try {
      // リフレッシュの場合はステートをリセット
      if (refresh) {
        state = state.copyWith(
          isLoadingCategory: true,
          categoryError: null,
          selectedPeriod: period,
        );
      } else if (state.isLoadingCategory) {
        // すでに読み込み中の場合は何もしない
        return;
      } else {
        // 追加読み込みの場合
        state = state.copyWith(
          isLoadingCategory: true,
          categoryError: null,
          selectedPeriod: period,
        );
      }

      final ranking = await _rankingService.getCategoryRanking(
        categoryId: categoryId,
        period: period,
        forceRefresh: refresh,
      );

      state = state.copyWith(
        categoryRanking: ranking,
        isLoadingCategory: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingCategory: false,
        categoryError: e.toString(),
      );
    }
  }

  /// パーソナライズドランキングを読み込む
  Future<void> loadPersonalizedRanking({
    required String userId,
    RankingPeriod period = RankingPeriod.week,
    bool refresh = false,
  }) async {
    try {
      // リフレッシュの場合はステートをリセット
      if (refresh) {
        state = state.copyWith(
          isLoadingPersonalized: true,
          personalizedError: null,
          selectedPeriod: period,
        );
      } else if (state.isLoadingPersonalized) {
        // すでに読み込み中の場合は何もしない
        return;
      } else {
        // 追加読み込みの場合
        state = state.copyWith(
          isLoadingPersonalized: true,
          personalizedError: null,
          selectedPeriod: period,
        );
      }

      final ranking = await _rankingService.getPersonalizedRanking(
        userId: userId,
        period: period,
        forceRefresh: refresh,
      );

      state = state.copyWith(
        personalizedRanking: ranking,
        isLoadingPersonalized: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingPersonalized: false,
        personalizedError: e.toString(),
      );
    }
  }

  /// ランキング期間を変更
  void changePeriod(RankingPeriod period) {
    state = state.copyWith(selectedPeriod: period);
    
    // 現在表示中のランキングを更新
    if (state.trendingRanking != null) {
      loadTrendingContent(period: period, refresh: true);
    }
    
    if (state.popularStarsRanking != null) {
      loadPopularStars(period: period, refresh: true);
    }
    
    if (state.categoryRanking != null) {
      loadCategoryRanking(
        categoryId: state.categoryRanking!.id,
        period: period,
        refresh: true,
      );
    }
    
    if (state.personalizedRanking != null && state.userId != null) {
      loadPersonalizedRanking(
        userId: state.userId!,
        period: period,
        refresh: true,
      );
    }
  }

  /// ユーザーIDを設定
  void setUserId(String userId) {
    state = state.copyWith(userId: userId);
  }

  /// ランキング期間の表示名を取得
  String getPeriodDisplayName(RankingPeriod period) {
    return _rankingService.getPeriodDisplayName(period);
  }
}

/// ランキングビュー状態クラス
class RankingViewState {
  /// トレンドランキング
  final RankingModel? trendingRanking;
  
  /// 人気スターランキング
  final RankingModel? popularStarsRanking;
  
  /// カテゴリランキング
  final RankingModel? categoryRanking;
  
  /// パーソナライズドランキング
  final RankingModel? personalizedRanking;
  
  /// 選択中のランキング期間
  final RankingPeriod selectedPeriod;
  
  /// ユーザーID
  final String? userId;
  
  /// トレンド読み込み中かどうか
  final bool isLoadingTrending;
  
  /// 人気スター読み込み中かどうか
  final bool isLoadingPopularStars;
  
  /// カテゴリ読み込み中かどうか
  final bool isLoadingCategory;
  
  /// パーソナライズド読み込み中かどうか
  final bool isLoadingPersonalized;
  
  /// トレンドエラー
  final String? trendingError;
  
  /// 人気スターエラー
  final String? popularStarsError;
  
  /// カテゴリエラー
  final String? categoryError;
  
  /// パーソナライズドエラー
  final String? personalizedError;
  
  /// 最終更新日時
  final DateTime? lastUpdated;

  /// コンストラクタ
  const RankingViewState({
    this.trendingRanking,
    this.popularStarsRanking,
    this.categoryRanking,
    this.personalizedRanking,
    required this.selectedPeriod,
    this.userId,
    required this.isLoadingTrending,
    required this.isLoadingPopularStars,
    required this.isLoadingCategory,
    required this.isLoadingPersonalized,
    this.trendingError,
    this.popularStarsError,
    this.categoryError,
    this.personalizedError,
    this.lastUpdated,
  });

  /// 初期状態を作成
  factory RankingViewState.initial() {
    return const RankingViewState(
      selectedPeriod: RankingPeriod.week,
      isLoadingTrending: false,
      isLoadingPopularStars: false,
      isLoadingCategory: false,
      isLoadingPersonalized: false,
    );
  }

  /// 新しい状態をコピーして作成
  RankingViewState copyWith({
    RankingModel? trendingRanking,
    RankingModel? popularStarsRanking,
    RankingModel? categoryRanking,
    RankingModel? personalizedRanking,
    RankingPeriod? selectedPeriod,
    String? userId,
    bool? isLoadingTrending,
    bool? isLoadingPopularStars,
    bool? isLoadingCategory,
    bool? isLoadingPersonalized,
    String? trendingError,
    String? popularStarsError,
    String? categoryError,
    String? personalizedError,
    DateTime? lastUpdated,
  }) {
    return RankingViewState(
      trendingRanking: trendingRanking ?? this.trendingRanking,
      popularStarsRanking: popularStarsRanking ?? this.popularStarsRanking,
      categoryRanking: categoryRanking ?? this.categoryRanking,
      personalizedRanking: personalizedRanking ?? this.personalizedRanking,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      userId: userId ?? this.userId,
      isLoadingTrending: isLoadingTrending ?? this.isLoadingTrending,
      isLoadingPopularStars: isLoadingPopularStars ?? this.isLoadingPopularStars,
      isLoadingCategory: isLoadingCategory ?? this.isLoadingCategory,
      isLoadingPersonalized: isLoadingPersonalized ?? this.isLoadingPersonalized,
      trendingError: trendingError,
      popularStarsError: popularStarsError,
      categoryError: categoryError,
      personalizedError: personalizedError,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// ランキングビューモデルプロバイダー
final rankingViewModelProvider = StateNotifierProvider<RankingViewModel, RankingViewState>((ref) {
  final rankingService = ref.watch(rankingServiceProvider);
  return RankingViewModel(rankingService);
});
