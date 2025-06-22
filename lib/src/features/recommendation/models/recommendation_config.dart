import 'package:flutter/foundation.dart';

/// レコメンデーション設定とパラメータ
class RecommendationConfig {
  /// 協調フィルタリングの重み
  final double collaborativeWeight;
  
  /// コンテンツベースフィルタリングの重み
  final double contentBasedWeight;
  
  /// 人気度ベースの重み
  final double popularityWeight;
  
  /// 時間減衰係数 (新しいコンテンツの重み)
  final double timeDecayFactor;
  
  /// 最小類似度閾値
  final double minSimilarityThreshold;
  
  /// 最大推薦数
  final int maxRecommendations;
  
  /// ダイバーシティ係数 (多様性を保つ)
  final double diversityFactor;
  
  /// ブースト係数設定
  final RecommendationBoosts boosts;

  const RecommendationConfig({
    this.collaborativeWeight = 0.4,
    this.contentBasedWeight = 0.3,
    this.popularityWeight = 0.2,
    this.timeDecayFactor = 0.1,
    this.minSimilarityThreshold = 0.1,
    this.maxRecommendations = 20,
    this.diversityFactor = 0.3,
    this.boosts = const RecommendationBoosts(),
  });

  /// デフォルト設定
  static const RecommendationConfig defaultConfig = RecommendationConfig();

  /// 新規ユーザー向け設定（人気度重視）
  static const RecommendationConfig newUserConfig = RecommendationConfig(
    collaborativeWeight: 0.1,
    contentBasedWeight: 0.2,
    popularityWeight: 0.6,
    timeDecayFactor: 0.1,
    diversityFactor: 0.5,
  );

  /// プレミアムユーザー向け設定（精度重視）
  static const RecommendationConfig premiumConfig = RecommendationConfig(
    collaborativeWeight: 0.5,
    contentBasedWeight: 0.4,
    popularityWeight: 0.1,
    minSimilarityThreshold: 0.2,
    maxRecommendations: 50,
    diversityFactor: 0.2,
  );

  RecommendationConfig copyWith({
    double? collaborativeWeight,
    double? contentBasedWeight,
    double? popularityWeight,
    double? timeDecayFactor,
    double? minSimilarityThreshold,
    int? maxRecommendations,
    double? diversityFactor,
    RecommendationBoosts? boosts,
  }) {
    return RecommendationConfig(
      collaborativeWeight: collaborativeWeight ?? this.collaborativeWeight,
      contentBasedWeight: contentBasedWeight ?? this.contentBasedWeight,
      popularityWeight: popularityWeight ?? this.popularityWeight,
      timeDecayFactor: timeDecayFactor ?? this.timeDecayFactor,
      minSimilarityThreshold: minSimilarityThreshold ?? this.minSimilarityThreshold,
      maxRecommendations: maxRecommendations ?? this.maxRecommendations,
      diversityFactor: diversityFactor ?? this.diversityFactor,
      boosts: boosts ?? this.boosts,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecommendationConfig &&
        other.collaborativeWeight == collaborativeWeight &&
        other.contentBasedWeight == contentBasedWeight &&
        other.popularityWeight == popularityWeight &&
        other.timeDecayFactor == timeDecayFactor &&
        other.minSimilarityThreshold == minSimilarityThreshold &&
        other.maxRecommendations == maxRecommendations &&
        other.diversityFactor == diversityFactor &&
        other.boosts == boosts;
  }

  @override
  int get hashCode {
    return Object.hash(
      collaborativeWeight,
      contentBasedWeight,
      popularityWeight,
      timeDecayFactor,
      minSimilarityThreshold,
      maxRecommendations,
      diversityFactor,
      boosts,
    );
  }
}

/// レコメンデーションブースト設定
class RecommendationBoosts {
  /// フォロー中のスターのコンテンツブースト
  final double followingBoost;
  
  /// 同じジャンルのコンテンツブースト
  final double sameGenreBoost;
  
  /// 新着コンテンツブースト
  final double newContentBoost;
  
  /// トレンドコンテンツブースト
  final double trendingBoost;
  
  /// 地域関連コンテンツブースト
  final double regionalBoost;
  
  /// プレミアムコンテンツブースト
  final double premiumBoost;

  const RecommendationBoosts({
    this.followingBoost = 1.5,
    this.sameGenreBoost = 1.2,
    this.newContentBoost = 1.1,
    this.trendingBoost = 1.3,
    this.regionalBoost = 1.1,
    this.premiumBoost = 1.4,
  });

  RecommendationBoosts copyWith({
    double? followingBoost,
    double? sameGenreBoost,
    double? newContentBoost,
    double? trendingBoost,
    double? regionalBoost,
    double? premiumBoost,
  }) {
    return RecommendationBoosts(
      followingBoost: followingBoost ?? this.followingBoost,
      sameGenreBoost: sameGenreBoost ?? this.sameGenreBoost,
      newContentBoost: newContentBoost ?? this.newContentBoost,
      trendingBoost: trendingBoost ?? this.trendingBoost,
      regionalBoost: regionalBoost ?? this.regionalBoost,
      premiumBoost: premiumBoost ?? this.premiumBoost,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecommendationBoosts &&
        other.followingBoost == followingBoost &&
        other.sameGenreBoost == sameGenreBoost &&
        other.newContentBoost == newContentBoost &&
        other.trendingBoost == trendingBoost &&
        other.regionalBoost == regionalBoost &&
        other.premiumBoost == premiumBoost;
  }

  @override
  int get hashCode {
    return Object.hash(
      followingBoost,
      sameGenreBoost,
      newContentBoost,
      trendingBoost,
      regionalBoost,
      premiumBoost,
    );
  }
}

/// レコメンデーション結果
class RecommendationResult {
  final String contentId;
  final String contentType;
  final String starId;
  final double score;
  final String reason;
  final List<String> matchingFactors;
  final DateTime generatedAt;

  const RecommendationResult({
    required this.contentId,
    required this.contentType,
    required this.starId,
    required this.score,
    required this.reason,
    required this.matchingFactors,
    required this.generatedAt,
  });

  RecommendationResult copyWith({
    String? contentId,
    String? contentType,
    String? starId,
    double? score,
    String? reason,
    List<String>? matchingFactors,
    DateTime? generatedAt,
  }) {
    return RecommendationResult(
      contentId: contentId ?? this.contentId,
      contentType: contentType ?? this.contentType,
      starId: starId ?? this.starId,
      score: score ?? this.score,
      reason: reason ?? this.reason,
      matchingFactors: matchingFactors ?? this.matchingFactors,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecommendationResult &&
        other.contentId == contentId &&
        other.contentType == contentType &&
        other.starId == starId &&
        other.score == score &&
        other.reason == reason &&
        listEquals(other.matchingFactors, matchingFactors) &&
        other.generatedAt == generatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      contentId,
      contentType,
      starId,
      score,
      reason,
      Object.hashAll(matchingFactors),
      generatedAt,
    );
  }
}

/// ユーザー嗜好プロファイル
class UserPreferenceProfile {
  /// ジャンル別嗜好度 (0.0 - 1.0)
  final Map<String, double> genrePreferences;
  
  /// コンテンツタイプ別嗜好度
  final Map<String, double> contentTypePreferences;
  
  /// 視聴時間帯別パターン
  final Map<int, double> timeSlotPreferences;
  
  /// 購入価格帯別傾向
  final Map<String, double> priceRangePreferences;
  
  /// 地域関連嗜好度
  final Map<String, double> regionalPreferences;
  
  /// エンゲージメントパターン
  final Map<String, double> engagementPatterns;

  const UserPreferenceProfile({
    this.genrePreferences = const {},
    this.contentTypePreferences = const {},
    this.timeSlotPreferences = const {},
    this.priceRangePreferences = const {},
    this.regionalPreferences = const {},
    this.engagementPatterns = const {},
  });

  /// 空のプロファイル
  static const UserPreferenceProfile empty = UserPreferenceProfile();

  UserPreferenceProfile copyWith({
    Map<String, double>? genrePreferences,
    Map<String, double>? contentTypePreferences,
    Map<int, double>? timeSlotPreferences,
    Map<String, double>? priceRangePreferences,
    Map<String, double>? regionalPreferences,
    Map<String, double>? engagementPatterns,
  }) {
    return UserPreferenceProfile(
      genrePreferences: genrePreferences ?? this.genrePreferences,
      contentTypePreferences: contentTypePreferences ?? this.contentTypePreferences,
      timeSlotPreferences: timeSlotPreferences ?? this.timeSlotPreferences,
      priceRangePreferences: priceRangePreferences ?? this.priceRangePreferences,
      regionalPreferences: regionalPreferences ?? this.regionalPreferences,
      engagementPatterns: engagementPatterns ?? this.engagementPatterns,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPreferenceProfile &&
        mapEquals(other.genrePreferences, genrePreferences) &&
        mapEquals(other.contentTypePreferences, contentTypePreferences) &&
        mapEquals(other.timeSlotPreferences, timeSlotPreferences) &&
        mapEquals(other.priceRangePreferences, priceRangePreferences) &&
        mapEquals(other.regionalPreferences, regionalPreferences) &&
        mapEquals(other.engagementPatterns, engagementPatterns);
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(genrePreferences.entries.map((e) => Object.hash(e.key, e.value))),
      Object.hashAll(contentTypePreferences.entries.map((e) => Object.hash(e.key, e.value))),
      Object.hashAll(timeSlotPreferences.entries.map((e) => Object.hash(e.key, e.value))),
      Object.hashAll(priceRangePreferences.entries.map((e) => Object.hash(e.key, e.value))),
      Object.hashAll(regionalPreferences.entries.map((e) => Object.hash(e.key, e.value))),
      Object.hashAll(engagementPatterns.entries.map((e) => Object.hash(e.key, e.value))),
    );
  }
}