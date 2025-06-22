import 'package:flutter/foundation.dart';

/// 毎日ピック機能のモデル（「from Star」を削除）
/// 
/// 旧名: 毎日ピック from Star
/// 新名: 毎日ピック

/// 毎日ピックアイテムのタイプ
enum DailyPickType {
  video,        // 動画コンテンツ
  photo,        // 写真
  text,         // テキスト投稿
  live,         // ライブ配信
  announcement, // お知らせ
}

/// 毎日ピックアイテムのステータス
enum DailyPickStatus {
  draft,      // 下書き
  scheduled,  // 予約投稿
  published,  // 公開中
  expired,    // 期限切れ
  archived,   // アーカイブ
}

/// 毎日ピックアイテムモデル
@immutable
class DailyPickItem {
  final String id;
  final String starId;
  final String title;
  final String? description;
  final DailyPickType type;
  final DailyPickStatus status;
  final String? thumbnailUrl;
  final String? contentUrl;
  final List<String> tags;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final DateTime scheduledAt;
  final DateTime? publishedAt;
  final DateTime? expiresAt;
  final bool isPremiumContent;
  final int requiredStarPoints; // スターP必要数（0なら無料）
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DailyPickItem({
    required this.id,
    required this.starId,
    required this.title,
    this.description,
    required this.type,
    required this.status,
    this.thumbnailUrl,
    this.contentUrl,
    required this.tags,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    required this.scheduledAt,
    this.publishedAt,
    this.expiresAt,
    required this.isPremiumContent,
    required this.requiredStarPoints,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSONからDailyPickItemを作成
  factory DailyPickItem.fromJson(Map<String, dynamic> json) {
    return DailyPickItem(
      id: json['id'],
      starId: json['star_id'],
      title: json['title'],
      description: json['description'],
      type: DailyPickType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DailyPickType.text,
      ),
      status: DailyPickStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DailyPickStatus.draft,
      ),
      thumbnailUrl: json['thumbnail_url'],
      contentUrl: json['content_url'],
      tags: List<String>.from(json['tags'] ?? []),
      viewCount: json['view_count'] ?? 0,
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      scheduledAt: DateTime.parse(json['scheduled_at']),
      publishedAt: json['published_at'] != null ? DateTime.parse(json['published_at']) : null,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
      isPremiumContent: json['is_premium_content'] ?? false,
      requiredStarPoints: json['required_star_points'] ?? 0,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// DailyPickItemをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'star_id': starId,
      'title': title,
      'description': description,
      'type': type.name,
      'status': status.name,
      'thumbnail_url': thumbnailUrl,
      'content_url': contentUrl,
      'tags': tags,
      'view_count': viewCount,
      'like_count': likeCount,
      'comment_count': commentCount,
      'scheduled_at': scheduledAt.toIso8601String(),
      'published_at': publishedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'is_premium_content': isPremiumContent,
      'required_star_points': requiredStarPoints,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// コピーを作成
  DailyPickItem copyWith({
    String? id,
    String? starId,
    String? title,
    String? description,
    DailyPickType? type,
    DailyPickStatus? status,
    String? thumbnailUrl,
    String? contentUrl,
    List<String>? tags,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    DateTime? scheduledAt,
    DateTime? publishedAt,
    DateTime? expiresAt,
    bool? isPremiumContent,
    int? requiredStarPoints,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyPickItem(
      id: id ?? this.id,
      starId: starId ?? this.starId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      contentUrl: contentUrl ?? this.contentUrl,
      tags: tags ?? List<String>.from(this.tags),
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      publishedAt: publishedAt ?? this.publishedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isPremiumContent: isPremiumContent ?? this.isPremiumContent,
      requiredStarPoints: requiredStarPoints ?? this.requiredStarPoints,
      metadata: metadata ?? Map<String, dynamic>.from(this.metadata),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 現在公開中かどうか
  bool get isCurrentlyPublished {
    return status == DailyPickStatus.published &&
        (expiresAt == null || DateTime.now().isBefore(expiresAt!));
  }

  /// 予約投稿かどうか
  bool get isScheduled {
    return status == DailyPickStatus.scheduled &&
        DateTime.now().isBefore(scheduledAt);
  }

  /// 期限切れかどうか
  bool get isExpired {
    return expiresAt != null && DateTime.now().isAfter(expiresAt!) ||
        status == DailyPickStatus.expired;
  }

  /// 無料コンテンツかどうか
  bool get isFree => requiredStarPoints == 0;

  /// プレミアムコンテンツかどうか
  bool get isPremium => isPremiumContent || requiredStarPoints > 0;

  /// エンゲージメント率
  double get engagementRate {
    if (viewCount == 0) return 0.0;
    return (likeCount + commentCount) / viewCount;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyPickItem &&
        other.id == id &&
        other.starId == starId &&
        other.title == title &&
        other.description == description &&
        other.type == type &&
        other.status == status &&
        other.thumbnailUrl == thumbnailUrl &&
        other.contentUrl == contentUrl &&
        listEquals(other.tags, tags) &&
        other.viewCount == viewCount &&
        other.likeCount == likeCount &&
        other.commentCount == commentCount &&
        other.scheduledAt == scheduledAt &&
        other.publishedAt == publishedAt &&
        other.expiresAt == expiresAt &&
        other.isPremiumContent == isPremiumContent &&
        other.requiredStarPoints == requiredStarPoints &&
        mapEquals(other.metadata, metadata) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        starId,
        title,
        description,
        type,
        status,
        thumbnailUrl,
        contentUrl,
        tags,
        viewCount,
        likeCount,
        commentCount,
        scheduledAt,
        publishedAt,
        expiresAt,
        isPremiumContent,
        requiredStarPoints,
        metadata,
        createdAt,
        updatedAt,
      );
}

/// 毎日ピック設定モデル
@immutable
class DailyPickSettings {
  final String starId;
  final bool isEnabled;
  final DateTime? dailyPostTime; // 毎日の投稿時刻
  final int maxItemsPerDay;
  final bool allowPremiumContent;
  final int defaultStarPointCost;
  final List<String> allowedContentTypes;
  final Map<String, dynamic> notificationSettings;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DailyPickSettings({
    required this.starId,
    required this.isEnabled,
    this.dailyPostTime,
    required this.maxItemsPerDay,
    required this.allowPremiumContent,
    required this.defaultStarPointCost,
    required this.allowedContentTypes,
    required this.notificationSettings,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSONからDailyPickSettingsを作成
  factory DailyPickSettings.fromJson(Map<String, dynamic> json) {
    return DailyPickSettings(
      starId: json['star_id'],
      isEnabled: json['is_enabled'] ?? true,
      dailyPostTime: json['daily_post_time'] != null ? DateTime.parse(json['daily_post_time']) : null,
      maxItemsPerDay: json['max_items_per_day'] ?? 1,
      allowPremiumContent: json['allow_premium_content'] ?? false,
      defaultStarPointCost: json['default_star_point_cost'] ?? 0,
      allowedContentTypes: List<String>.from(json['allowed_content_types'] ?? ['text', 'photo', 'video']),
      notificationSettings: Map<String, dynamic>.from(json['notification_settings'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// DailyPickSettingsをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'star_id': starId,
      'is_enabled': isEnabled,
      'daily_post_time': dailyPostTime?.toIso8601String(),
      'max_items_per_day': maxItemsPerDay,
      'allow_premium_content': allowPremiumContent,
      'default_star_point_cost': defaultStarPointCost,
      'allowed_content_types': allowedContentTypes,
      'notification_settings': notificationSettings,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyPickSettings &&
        other.starId == starId &&
        other.isEnabled == isEnabled &&
        other.dailyPostTime == dailyPostTime &&
        other.maxItemsPerDay == maxItemsPerDay &&
        other.allowPremiumContent == allowPremiumContent &&
        other.defaultStarPointCost == defaultStarPointCost &&
        listEquals(other.allowedContentTypes, allowedContentTypes) &&
        mapEquals(other.notificationSettings, notificationSettings) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        starId,
        isEnabled,
        dailyPostTime,
        maxItemsPerDay,
        allowPremiumContent,
        defaultStarPointCost,
        allowedContentTypes,
        notificationSettings,
        createdAt,
        updatedAt,
      );
}

/// 毎日ピック統計モデル
@immutable
class DailyPickStatistics {
  final String starId;
  final DateTime date;
  final int totalItems;
  final int totalViews;
  final int totalLikes;
  final int totalComments;
  final int premiumItems;
  final int starPointsEarned;
  final Map<DailyPickType, int> itemsByType;
  final double averageEngagementRate;

  const DailyPickStatistics({
    required this.starId,
    required this.date,
    required this.totalItems,
    required this.totalViews,
    required this.totalLikes,
    required this.totalComments,
    required this.premiumItems,
    required this.starPointsEarned,
    required this.itemsByType,
    required this.averageEngagementRate,
  });

  /// 統計を計算
  factory DailyPickStatistics.fromItems(
    String starId,
    DateTime date,
    List<DailyPickItem> items,
  ) {
    final totalItems = items.length;
    final totalViews = items.fold<int>(0, (sum, item) => sum + item.viewCount);
    final totalLikes = items.fold<int>(0, (sum, item) => sum + item.likeCount);
    final totalComments = items.fold<int>(0, (sum, item) => sum + item.commentCount);
    final premiumItems = items.where((item) => item.isPremium).length;
    final starPointsEarned = items.fold<int>(0, (sum, item) => sum + item.requiredStarPoints);

    final itemsByType = <DailyPickType, int>{};
    for (final type in DailyPickType.values) {
      itemsByType[type] = items.where((item) => item.type == type).length;
    }

    final averageEngagementRate = items.isNotEmpty
        ? items.map((item) => item.engagementRate).reduce((a, b) => a + b) / items.length
        : 0.0;

    return DailyPickStatistics(
      starId: starId,
      date: date,
      totalItems: totalItems,
      totalViews: totalViews,
      totalLikes: totalLikes,
      totalComments: totalComments,
      premiumItems: premiumItems,
      starPointsEarned: starPointsEarned,
      itemsByType: itemsByType,
      averageEngagementRate: averageEngagementRate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyPickStatistics &&
        other.starId == starId &&
        other.date == date &&
        other.totalItems == totalItems &&
        other.totalViews == totalViews &&
        other.totalLikes == totalLikes &&
        other.totalComments == totalComments &&
        other.premiumItems == premiumItems &&
        other.starPointsEarned == starPointsEarned &&
        mapEquals(other.itemsByType, itemsByType) &&
        other.averageEngagementRate == averageEngagementRate;
  }

  @override
  int get hashCode => Object.hash(
        starId,
        date,
        totalItems,
        totalViews,
        totalLikes,
        totalComments,
        premiumItems,
        starPointsEarned,
        itemsByType,
        averageEngagementRate,
      );
}