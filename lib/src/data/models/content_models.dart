import 'package:flutter/material.dart';

/// コンテンツタイプの列挙型
enum ContentType {
  post,      // 通常の投稿
  article,   // 記事
  video,     // 動画
  audio,     // 音声
  product,   // 商品
  event,     // イベント
  exclusive, // 限定コンテンツ
}

/// プライバシーレベルの列挙型
enum PrivacyLevel {
  public,    // 公開（全ユーザー）
  followers, // フォロワーのみ
  members,   // 会員のみ
  premium,   // プレミアム会員のみ
  private,   // 非公開（自分のみ）
}

/// コンテンツステータスの列挙型
enum ContentStatus {
  draft,     // 下書き
  scheduled, // 公開予定
  published, // 公開中
  archived,  // アーカイブ済み
}

/// コンテンツモデル
class Content {
  final String id;
  final String starId;
  final String title;
  final String? description;
  final ContentType type;
  final PrivacyLevel privacyLevel;
  final ContentStatus status;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final DateTime? publishedAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;
  final List<String> tags;
  final Map<String, bool> visibilitySettings;
  final String? thumbnailUrl;
  final String? contentUrl;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final int shareCount;

  Content({
    required this.id,
    required this.starId,
    required this.title,
    this.description,
    required this.type,
    required this.privacyLevel,
    required this.status,
    required this.createdAt,
    this.scheduledAt,
    this.publishedAt,
    required this.updatedAt,
    required this.metadata,
    required this.tags,
    required this.visibilitySettings,
    this.thumbnailUrl,
    this.contentUrl,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
  });

  /// JSONからコンテンツを作成するファクトリメソッド
  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'],
      starId: json['starId'],
      title: json['title'],
      description: json['description'],
      type: ContentType.values.firstWhere(
        (e) => e.toString() == 'ContentType.${json['type']}',
        orElse: () => ContentType.post,
      ),
      privacyLevel: PrivacyLevel.values.firstWhere(
        (e) => e.toString() == 'PrivacyLevel.${json['privacyLevel']}',
        orElse: () => PrivacyLevel.public,
      ),
      status: ContentStatus.values.firstWhere(
        (e) => e.toString() == 'ContentStatus.${json['status']}',
        orElse: () => ContentStatus.draft,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      scheduledAt: json['scheduledAt'] != null ? DateTime.parse(json['scheduledAt']) : null,
      publishedAt: json['publishedAt'] != null ? DateTime.parse(json['publishedAt']) : null,
      updatedAt: DateTime.parse(json['updatedAt']),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      tags: List<String>.from(json['tags'] ?? []),
      visibilitySettings: Map<String, bool>.from(json['visibilitySettings'] ?? {}),
      thumbnailUrl: json['thumbnailUrl'],
      contentUrl: json['contentUrl'],
      viewCount: json['viewCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      shareCount: json['shareCount'] ?? 0,
    );
  }

  /// コンテンツをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'starId': starId,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'privacyLevel': privacyLevel.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'scheduledAt': scheduledAt?.toIso8601String(),
      'publishedAt': publishedAt?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
      'tags': tags,
      'visibilitySettings': visibilitySettings,
      'thumbnailUrl': thumbnailUrl,
      'contentUrl': contentUrl,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'shareCount': shareCount,
    };
  }

  /// コンテンツのコピーを作成するメソッド
  Content copyWith({
    String? id,
    String? starId,
    String? title,
    String? description,
    ContentType? type,
    PrivacyLevel? privacyLevel,
    ContentStatus? status,
    DateTime? createdAt,
    DateTime? scheduledAt,
    DateTime? publishedAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    Map<String, bool>? visibilitySettings,
    String? thumbnailUrl,
    String? contentUrl,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    int? shareCount,
  }) {
    return Content(
      id: id ?? this.id,
      starId: starId ?? this.starId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? Map<String, dynamic>.from(this.metadata),
      tags: tags ?? List<String>.from(this.tags),
      visibilitySettings: visibilitySettings ?? Map<String, bool>.from(this.visibilitySettings),
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      contentUrl: contentUrl ?? this.contentUrl,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
    );
  }

  /// コンテンツが公開可能かどうかを確認するメソッド
  bool isPublishable() {
    return status == ContentStatus.draft || status == ContentStatus.scheduled;
  }

  /// コンテンツが編集可能かどうかを確認するメソッド
  bool isEditable() {
    return status != ContentStatus.archived;
  }

  /// コンテンツが限定コンテンツかどうかを確認するメソッド
  bool isExclusive() {
    return type == ContentType.exclusive || 
           privacyLevel == PrivacyLevel.members || 
           privacyLevel == PrivacyLevel.premium;
  }

  /// コンテンツのプライバシーレベルに基づいてアクセス可能かどうかを確認するメソッド
  bool isAccessibleTo(String? userId, {
    bool isFollowing = false,
    bool isMember = false,
    bool isPremium = false,
  }) {
    if (userId == starId) return true; // スター自身は常にアクセス可能
    
    switch (privacyLevel) {
      case PrivacyLevel.public:
        return true;
      case PrivacyLevel.followers:
        return isFollowing;
      case PrivacyLevel.members:
        return isMember || isPremium;
      case PrivacyLevel.premium:
        return isPremium;
      case PrivacyLevel.private:
        return false;
    }
  }
}

/// コンテンツコレクションモデル
class ContentCollection {
  final String id;
  final String starId;
  final String title;
  final String? description;
  final List<String> contentIds;
  final PrivacyLevel privacyLevel;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? thumbnailUrl;
  final bool isDefault;
  final Map<String, bool> visibilitySettings;

  ContentCollection({
    required this.id,
    required this.starId,
    required this.title,
    this.description,
    required this.contentIds,
    required this.privacyLevel,
    required this.createdAt,
    required this.updatedAt,
    this.thumbnailUrl,
    required this.isDefault,
    required this.visibilitySettings,
  });

  /// JSONからコンテンツコレクションを作成するファクトリメソッド
  factory ContentCollection.fromJson(Map<String, dynamic> json) {
    return ContentCollection(
      id: json['id'],
      starId: json['starId'],
      title: json['title'],
      description: json['description'],
      contentIds: List<String>.from(json['contentIds'] ?? []),
      privacyLevel: PrivacyLevel.values.firstWhere(
        (e) => e.toString() == 'PrivacyLevel.${json['privacyLevel']}',
        orElse: () => PrivacyLevel.public,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      thumbnailUrl: json['thumbnailUrl'],
      isDefault: json['isDefault'] ?? false,
      visibilitySettings: Map<String, bool>.from(json['visibilitySettings'] ?? {}),
    );
  }

  /// コンテンツコレクションをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'starId': starId,
      'title': title,
      'description': description,
      'contentIds': contentIds,
      'privacyLevel': privacyLevel.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'thumbnailUrl': thumbnailUrl,
      'isDefault': isDefault,
      'visibilitySettings': visibilitySettings,
    };
  }

  /// コンテンツコレクションのコピーを作成するメソッド
  ContentCollection copyWith({
    String? id,
    String? starId,
    String? title,
    String? description,
    List<String>? contentIds,
    PrivacyLevel? privacyLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? thumbnailUrl,
    bool? isDefault,
    Map<String, bool>? visibilitySettings,
  }) {
    return ContentCollection(
      id: id ?? this.id,
      starId: starId ?? this.starId,
      title: title ?? this.title,
      description: description ?? this.description,
      contentIds: contentIds ?? List<String>.from(this.contentIds),
      privacyLevel: privacyLevel ?? this.privacyLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isDefault: isDefault ?? this.isDefault,
      visibilitySettings: visibilitySettings ?? Map<String, bool>.from(this.visibilitySettings),
    );
  }

  /// コンテンツをコレクションに追加するメソッド
  ContentCollection addContent(String contentId) {
    if (contentIds.contains(contentId)) return this;
    
    final updatedContentIds = List<String>.from(contentIds)..add(contentId);
    return copyWith(
      contentIds: updatedContentIds,
      updatedAt: DateTime.now(),
    );
  }

  /// コンテンツをコレクションから削除するメソッド
  ContentCollection removeContent(String contentId) {
    if (!contentIds.contains(contentId)) return this;
    
    final updatedContentIds = List<String>.from(contentIds)..remove(contentId);
    return copyWith(
      contentIds: updatedContentIds,
      updatedAt: DateTime.now(),
    );
  }

  /// コンテンツの順序を変更するメソッド
  ContentCollection reorderContent(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= contentIds.length || 
        newIndex < 0 || newIndex >= contentIds.length) {
      return this;
    }
    
    final updatedContentIds = List<String>.from(contentIds);
    final item = updatedContentIds.removeAt(oldIndex);
    updatedContentIds.insert(newIndex, item);
    
    return copyWith(
      contentIds: updatedContentIds,
      updatedAt: DateTime.now(),
    );
  }
}

/// コンテンツスケジュールモデル
class ContentSchedule {
  final String id;
  final String starId;
  final String contentId;
  final DateTime scheduledAt;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  ContentSchedule({
    required this.id,
    required this.starId,
    required this.contentId,
    required this.scheduledAt,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  /// JSONからコンテンツスケジュールを作成するファクトリメソッド
  factory ContentSchedule.fromJson(Map<String, dynamic> json) {
    return ContentSchedule(
      id: json['id'],
      starId: json['starId'],
      contentId: json['contentId'],
      scheduledAt: DateTime.parse(json['scheduledAt']),
      isPublished: json['isPublished'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  /// コンテンツスケジュールをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'starId': starId,
      'contentId': contentId,
      'scheduledAt': scheduledAt.toIso8601String(),
      'isPublished': isPublished,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// コンテンツスケジュールのコピーを作成するメソッド
  ContentSchedule copyWith({
    String? id,
    String? starId,
    String? contentId,
    DateTime? scheduledAt,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ContentSchedule(
      id: id ?? this.id,
      starId: starId ?? this.starId,
      contentId: contentId ?? this.contentId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? Map<String, dynamic>.from(this.metadata),
    );
  }

  /// スケジュールが過去かどうかを確認するメソッド
  bool isPast() {
    return scheduledAt.isBefore(DateTime.now());
  }

  /// スケジュールが公開可能かどうかを確認するメソッド
  bool isPublishable() {
    return isPast() && !isPublished;
  }
}

/// プライバシー設定モデル
class PrivacySettings {
  final String starId;
  final Map<String, PrivacyLevel> defaultLevels;
  final Map<String, bool> visibilityToggles;
  final Map<String, List<String>> allowedUserIds;
  final Map<String, List<String>> blockedUserIds;
  final DateTime updatedAt;

  PrivacySettings({
    required this.starId,
    required this.defaultLevels,
    required this.visibilityToggles,
    required this.allowedUserIds,
    required this.blockedUserIds,
    required this.updatedAt,
  });

  /// JSONからプライバシー設定を作成するファクトリメソッド
  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    final defaultLevelsMap = Map<String, PrivacyLevel>.from(
      (json['defaultLevels'] as Map<String, dynamic>).map((key, value) => MapEntry(
        key,
        PrivacyLevel.values.firstWhere(
          (e) => e.toString() == 'PrivacyLevel.$value',
          orElse: () => PrivacyLevel.public,
        ),
      )),
    );

    return PrivacySettings(
      starId: json['starId'],
      defaultLevels: defaultLevelsMap,
      visibilityToggles: Map<String, bool>.from(json['visibilityToggles'] ?? {}),
      allowedUserIds: (json['allowedUserIds'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      ) ?? {},
      blockedUserIds: (json['blockedUserIds'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      ) ?? {},
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// プライバシー設定をJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    final defaultLevelsMap = defaultLevels.map((key, value) => 
      MapEntry(key, value.toString().split('.').last));

    return {
      'starId': starId,
      'defaultLevels': defaultLevelsMap,
      'visibilityToggles': visibilityToggles,
      'allowedUserIds': allowedUserIds,
      'blockedUserIds': blockedUserIds,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// プライバシー設定のコピーを作成するメソッド
  PrivacySettings copyWith({
    String? starId,
    Map<String, PrivacyLevel>? defaultLevels,
    Map<String, bool>? visibilityToggles,
    Map<String, List<String>>? allowedUserIds,
    Map<String, List<String>>? blockedUserIds,
    DateTime? updatedAt,
  }) {
    return PrivacySettings(
      starId: starId ?? this.starId,
      defaultLevels: defaultLevels ?? Map<String, PrivacyLevel>.from(this.defaultLevels),
      visibilityToggles: visibilityToggles ?? Map<String, bool>.from(this.visibilityToggles),
      allowedUserIds: allowedUserIds ?? Map<String, List<String>>.from(this.allowedUserIds.map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      )),
      blockedUserIds: blockedUserIds ?? Map<String, List<String>>.from(this.blockedUserIds.map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      )),
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 特定のコンテンツタイプのデフォルトプライバシーレベルを取得するメソッド
  PrivacyLevel getDefaultLevelForType(ContentType type) {
    return defaultLevels[type.toString().split('.').last] ?? PrivacyLevel.public;
  }

  /// 特定の機能の可<response clipped><NOTE>To save on context only part of this file has been shown to you. You should retry this tool after you have searched inside the file with `grep -n` in order to find the line numbers of what you are looking for.</NOTE>