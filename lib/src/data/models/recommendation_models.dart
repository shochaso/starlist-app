import 'package:flutter/material.dart';

/// AIコンテンツ推奨モデル
class ContentRecommendation {
  final String id;
  final String starId;
  final String title;
  final String description;
  final RecommendationType type;
  final double relevanceScore;
  final DateTime createdAt;
  final DateTime expiresAt;
  final Map<String, dynamic> metadata;
  final List<String> relatedContentIds;
  final List<String> relatedTags;
  final bool isImplemented;

  ContentRecommendation({
    required this.id,
    required this.starId,
    required this.title,
    required this.description,
    required this.type,
    required this.relevanceScore,
    required this.createdAt,
    required this.expiresAt,
    required this.metadata,
    required this.relatedContentIds,
    required this.relatedTags,
    required this.isImplemented,
  });

  /// JSONからコンテンツ推奨を作成するファクトリメソッド
  factory ContentRecommendation.fromJson(Map<String, dynamic> json) {
    return ContentRecommendation(
      id: json['id'],
      starId: json['starId'],
      title: json['title'],
      description: json['description'],
      type: RecommendationType.values.firstWhere(
        (e) => e.toString() == 'RecommendationType.${json['type']}',
        orElse: () => RecommendationType.personalized,
      ),
      relevanceScore: json['relevanceScore'] ?? 0.0,
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      relatedContentIds: List<String>.from(json['relatedContentIds'] ?? []),
      relatedTags: List<String>.from(json['relatedTags'] ?? []),
      isImplemented: json['isImplemented'] ?? false,
    );
  }

  /// コンテンツ推奨をJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'starId': starId,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'relevanceScore': relevanceScore,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'metadata': metadata,
      'relatedContentIds': relatedContentIds,
      'relatedTags': relatedTags,
      'isImplemented': isImplemented,
    };
  }

  /// コンテンツ推奨のコピーを作成するメソッド
  ContentRecommendation copyWith({
    String? id,
    String? starId,
    String? title,
    String? description,
    RecommendationType? type,
    double? relevanceScore,
    DateTime? createdAt,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
    List<String>? relatedContentIds,
    List<String>? relatedTags,
    bool? isImplemented,
  }) {
    return ContentRecommendation(
      id: id ?? this.id,
      starId: starId ?? this.starId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      relevanceScore: relevanceScore ?? this.relevanceScore,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      metadata: metadata ?? Map<String, dynamic>.from(this.metadata),
      relatedContentIds: relatedContentIds ?? List<String>.from(this.relatedContentIds),
      relatedTags: relatedTags ?? List<String>.from(this.relatedTags),
      isImplemented: isImplemented ?? this.isImplemented,
    );
  }

  /// 推奨が有効かどうかを確認するメソッド
  bool isValid() {
    return DateTime.now().isBefore(expiresAt);
  }
}

/// 推奨タイプの列挙型
enum RecommendationType {
  personalized,  // パーソナライズされた更新提案
  trending,      // トレンド連動型提案
  engagement,    // ファン反応分析に基づく提案
  seasonal,      // 季節イベント連動提案
  topical,       // 時事ネタ連動提案
  collaborative, // 協調フィルタリングに基づく提案
}

/// ファン反応分析モデル
class FanEngagementAnalysis {
  final String id;
  final String starId;
  final DateTime analyzedAt;
  final Map<String, double> contentTypeEngagement;
  final Map<String, double> topicEngagement;
  final Map<String, double> timeOfDayEngagement;
  final Map<String, double> dayOfWeekEngagement;
  final List<Map<String, dynamic>> topPerformingContent;
  final List<Map<String, dynamic>> lowPerformingContent;
  final Map<String, List<String>> recommendedTags;
  final Map<String, dynamic> insightSummary;

  FanEngagementAnalysis({
    required this.id,
    required this.starId,
    required this.analyzedAt,
    required this.contentTypeEngagement,
    required this.topicEngagement,
    required this.timeOfDayEngagement,
    required this.dayOfWeekEngagement,
    required this.topPerformingContent,
    required this.lowPerformingContent,
    required this.recommendedTags,
    required this.insightSummary,
  });

  /// JSONからファン反応分析を作成するファクトリメソッド
  factory FanEngagementAnalysis.fromJson(Map<String, dynamic> json) {
    return FanEngagementAnalysis(
      id: json['id'],
      starId: json['starId'],
      analyzedAt: DateTime.parse(json['analyzedAt']),
      contentTypeEngagement: Map<String, double>.from(json['contentTypeEngagement'] ?? {}),
      topicEngagement: Map<String, double>.from(json['topicEngagement'] ?? {}),
      timeOfDayEngagement: Map<String, double>.from(json['timeOfDayEngagement'] ?? {}),
      dayOfWeekEngagement: Map<String, double>.from(json['dayOfWeekEngagement'] ?? {}),
      topPerformingContent: List<Map<String, dynamic>>.from(json['topPerformingContent'] ?? []),
      lowPerformingContent: List<Map<String, dynamic>>.from(json['lowPerformingContent'] ?? []),
      recommendedTags: (json['recommendedTags'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      ) ?? {},
      insightSummary: Map<String, dynamic>.from(json['insightSummary'] ?? {}),
    );
  }

  /// ファン反応分析をJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'starId': starId,
      'analyzedAt': analyzedAt.toIso8601String(),
      'contentTypeEngagement': contentTypeEngagement,
      'topicEngagement': topicEngagement,
      'timeOfDayEngagement': timeOfDayEngagement,
      'dayOfWeekEngagement': dayOfWeekEngagement,
      'topPerformingContent': topPerformingContent,
      'lowPerformingContent': lowPerformingContent,
      'recommendedTags': recommendedTags,
      'insightSummary': insightSummary,
    };
  }
}

/// トレンド分析モデル
class TrendAnalysis {
  final String id;
  final DateTime analyzedAt;
  final DateTime validUntil;
  final List<Map<String, dynamic>> currentTrends;
  final List<Map<String, dynamic>> upcomingTrends;
  final List<Map<String, dynamic>> seasonalEvents;
  final Map<String, List<String>> trendingTags;
  final Map<String, List<String>> trendingTopics;
  final Map<String, dynamic> insightSummary;

  TrendAnalysis({
    required this.id,
    required this.analyzedAt,
    required this.validUntil,
    required this.currentTrends,
    required this.upcomingTrends,
    required this.seasonalEvents,
    required this.trendingTags,
    required this.trendingTopics,
    required this.insightSummary,
  });

  /// JSONからトレンド分析を作成するファクトリメソッド
  factory TrendAnalysis.fromJson(Map<String, dynamic> json) {
    return TrendAnalysis(
      id: json['id'],
      analyzedAt: DateTime.parse(json['analyzedAt']),
      validUntil: DateTime.parse(json['validUntil']),
      currentTrends: List<Map<String, dynamic>>.from(json['currentTrends'] ?? []),
      upcomingTrends: List<Map<String, dynamic>>.from(json['upcomingTrends'] ?? []),
      seasonalEvents: List<Map<String, dynamic>>.from(json['seasonalEvents'] ?? []),
      trendingTags: (json['trendingTags'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      ) ?? {},
      trendingTopics: (json['trendingTopics'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      ) ?? {},
      insightSummary: Map<String, dynamic>.from(json['insightSummary'] ?? {}),
    );
  }

  /// トレンド分析をJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'analyzedAt': analyzedAt.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'currentTrends': currentTrends,
      'upcomingTrends': upcomingTrends,
      'seasonalEvents': seasonalEvents,
      'trendingTags': trendingTags,
      'trendingTopics': trendingTopics,
      'insightSummary': insightSummary,
    };
  }

  /// 分析が有効かどうかを確認するメソッド
  bool isValid() {
    return DateTime.now().isBefore(validUntil);
  }
}

/// コンテンツパターン分析モデル
class ContentPatternAnalysis {
  final String id;
  final String starId;
  final DateTime analyzedAt;
  final Map<String, int> contentTypeFrequency;
  final Map<String, List<String>> commonTags;
  final Map<String, TimeOfDay> postingTimePatterns;
  final Map<String, int> postingDayPatterns;
  final Map<String, double> contentLengthPatterns;
  final Map<String, List<String>> commonTopics;
  final Map<String, dynamic> insightSummary;

  ContentPatternAnalysis({
    required this.id,
    required this.starId,
    required this.analyzedAt,
    required this.contentTypeFrequency,
    required this.commonTags,
    required this.postingTimePatterns,
    required this.postingDayPatterns,
    required this.contentLengthPatterns,
    required this.commonTopics,
    required this.insightSummary,
  });

  /// JSONからコンテンツパターン分析を作成するファクトリメソッド
  factory ContentPatternAnalysis.fromJson(Map<String, dynamic> json) {
    final postingTimePatterns = <String, TimeOfDay>{};
    (json['postingTimePatterns'] as Map<String, dynamic>?)?.forEach((key, value) {
      final parts = value.toString().split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        postingTimePatterns[key] = TimeOfDay(hour: hour, minute: minute);
      }
    });

    return ContentPatternAnalysis(
      id: json['id'],
      starId: json['starId'],
      analyzedAt: DateTime.parse(json['analyzedAt']),
      contentTypeFrequency: Map<String, int>.from(json['contentTypeFrequency'] ?? {}),
      commonTags: (json['commonTags'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      ) ?? {},
      postingTimePatterns: postingTimePatterns,
      postingDayPatterns: Map<String, int>.from(json['postingDayPatterns'] ?? {}),
      contentLengthPatterns: Map<String, double>.from(json['contentLengthPatterns'] ?? {}),
      commonTopics: (json['commonTopics'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      ) ?? {},
      insightSummary: Map<String, dynamic>.from(json['insightSummary'] ?? {}),
    );
  }

  /// コンテンツパターン分析をJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    final postingTimePatternsJson = <String, String>{};
    postingTimePatterns.forEach((key, timeOfDay) {
      postingTimePatternsJson[key] = '${timeOfDay.hour}:${timeOfDay.minute}';
    });

    return {
      'id': id,
      'starId': starId,
      'analyzedAt': analyzedAt.toIso8601String(),
      'contentTypeFrequency': contentTypeFrequency,
      'commonTags': commonTags,
      'postingTimePatterns': postingTimePatternsJson,
      'postingDayPatterns': postingDayPatterns,
      'contentLengthPatterns': contentLengthPatterns,
      'commonTopics': commonTopics,
      'insightSummary': insightSummary,
    };
  }
}
