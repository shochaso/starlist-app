
/// フィルタリングレベルの列挙型
enum FilteringLevel {
  none,       // フィルタリングなし
  light,      // 軽度フィルタリング
  moderate,   // 中程度フィルタリング
  strict,     // 厳格フィルタリング
  custom,     // カスタムフィルタリング
}

/// コメントステータスの列挙型
enum CommentStatus {
  pending,    // 承認待ち
  approved,   // 承認済み
  rejected,   // 拒否
  flagged,    // フラグ付き（要確認）
  spam,       // スパム
}

/// フィルタリング設定モデル
class FilteringSettings {
  final String userId;
  final FilteringLevel generalLevel;
  final Map<String, FilteringLevel> categoryLevels;
  final List<String> customBlockedWords;
  final List<String> customAllowedWords;
  final bool enableAIFiltering;
  final bool autoRejectSpam;
  final bool requireApproval;
  final DateTime updatedAt;

  FilteringSettings({
    required this.userId,
    required this.generalLevel,
    required this.categoryLevels,
    required this.customBlockedWords,
    required this.customAllowedWords,
    required this.enableAIFiltering,
    required this.autoRejectSpam,
    required this.requireApproval,
    required this.updatedAt,
  });

  /// JSONからフィルタリング設定を作成するファクトリメソッド
  factory FilteringSettings.fromJson(Map<String, dynamic> json) {
    final categoryLevelsMap = Map<String, FilteringLevel>.from(
      (json['categoryLevels'] as Map<String, dynamic>).map((key, value) => MapEntry(
        key,
        FilteringLevel.values.firstWhere(
          (e) => e.toString() == 'FilteringLevel.$value',
          orElse: () => FilteringLevel.moderate,
        ),
      )),
    );

    return FilteringSettings(
      userId: json['userId'],
      generalLevel: FilteringLevel.values.firstWhere(
        (e) => e.toString() == 'FilteringLevel.${json['generalLevel']}',
        orElse: () => FilteringLevel.moderate,
      ),
      categoryLevels: categoryLevelsMap,
      customBlockedWords: List<String>.from(json['customBlockedWords'] ?? []),
      customAllowedWords: List<String>.from(json['customAllowedWords'] ?? []),
      enableAIFiltering: json['enableAIFiltering'] ?? true,
      autoRejectSpam: json['autoRejectSpam'] ?? true,
      requireApproval: json['requireApproval'] ?? false,
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// フィルタリング設定をJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    final categoryLevelsMap = categoryLevels.map((key, value) => 
      MapEntry(key, value.toString().split('.').last));

    return {
      'userId': userId,
      'generalLevel': generalLevel.toString().split('.').last,
      'categoryLevels': categoryLevelsMap,
      'customBlockedWords': customBlockedWords,
      'customAllowedWords': customAllowedWords,
      'enableAIFiltering': enableAIFiltering,
      'autoRejectSpam': autoRejectSpam,
      'requireApproval': requireApproval,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// フィルタリング設定のコピーを作成するメソッド
  FilteringSettings copyWith({
    String? userId,
    FilteringLevel? generalLevel,
    Map<String, FilteringLevel>? categoryLevels,
    List<String>? customBlockedWords,
    List<String>? customAllowedWords,
    bool? enableAIFiltering,
    bool? autoRejectSpam,
    bool? requireApproval,
    DateTime? updatedAt,
  }) {
    return FilteringSettings(
      userId: userId ?? this.userId,
      generalLevel: generalLevel ?? this.generalLevel,
      categoryLevels: categoryLevels ?? Map<String, FilteringLevel>.from(this.categoryLevels),
      customBlockedWords: customBlockedWords ?? List<String>.from(this.customBlockedWords),
      customAllowedWords: customAllowedWords ?? List<String>.from(this.customAllowedWords),
      enableAIFiltering: enableAIFiltering ?? this.enableAIFiltering,
      autoRejectSpam: autoRejectSpam ?? this.autoRejectSpam,
      requireApproval: requireApproval ?? this.requireApproval,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 特定のカテゴリのフィルタリングレベルを取得するメソッド
  FilteringLevel getLevelForCategory(String category) {
    return categoryLevels[category] ?? generalLevel;
  }

  /// カスタムブロック単語を追加するメソッド
  FilteringSettings addBlockedWord(String word) {
    if (customBlockedWords.contains(word)) return this;
    
    final updatedBlockedWords = List<String>.from(customBlockedWords)..add(word);
    return copyWith(
      customBlockedWords: updatedBlockedWords,
      updatedAt: DateTime.now(),
    );
  }

  /// カスタム許可単語を追加するメソッド
  FilteringSettings addAllowedWord(String word) {
    if (customAllowedWords.contains(word)) return this;
    
    final updatedAllowedWords = List<String>.from(customAllowedWords)..add(word);
    return copyWith(
      customAllowedWords: updatedAllowedWords,
      updatedAt: DateTime.now(),
    );
  }
}

/// コメントモデル
class Comment {
  final String id;
  final String contentId;
  final String? parentId;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final String text;
  final CommentStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likeCount;
  final int replyCount;
  final bool isEdited;
  final Map<String, dynamic> metadata;

  Comment({
    required this.id,
    required this.contentId,
    this.parentId,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.text,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.likeCount,
    required this.replyCount,
    required this.isEdited,
    required this.metadata,
  });

  /// JSONからコメントを作成するファクトリメソッド
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      contentId: json['contentId'],
      parentId: json['parentId'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      authorAvatarUrl: json['authorAvatarUrl'],
      text: json['text'],
      status: CommentStatus.values.firstWhere(
        (e) => e.toString() == 'CommentStatus.${json['status']}',
        orElse: () => CommentStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      likeCount: json['likeCount'] ?? 0,
      replyCount: json['replyCount'] ?? 0,
      isEdited: json['isEdited'] ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  /// コメントをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contentId': contentId,
      'parentId': parentId,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatarUrl': authorAvatarUrl,
      'text': text,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'likeCount': likeCount,
      'replyCount': replyCount,
      'isEdited': isEdited,
      'metadata': metadata,
    };
  }

  /// コメントのコピーを作成するメソッド
  Comment copyWith({
    String? id,
    String? contentId,
    String? parentId,
    String? authorId,
    String? authorName,
    String? authorAvatarUrl,
    String? text,
    CommentStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likeCount,
    int? replyCount,
    bool? isEdited,
    Map<String, dynamic>? metadata,
  }) {
    return Comment(
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      parentId: parentId ?? this.parentId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      text: text ?? this.text,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likeCount: likeCount ?? this.likeCount,
      replyCount: replyCount ?? this.replyCount,
      isEdited: isEdited ?? this.isEdited,
      metadata: metadata ?? Map<String, dynamic>.from(this.metadata),
    );
  }

  /// コメントが表示可能かどうかを確認するメソッド
  bool isVisible() {
    return status == CommentStatus.approved;
  }

  /// コメントが編集可能かどうかを確認するメソッド
  bool isEditable(String currentUserId) {
    return authorId == currentUserId && 
           status != CommentStatus.rejected && 
           status != CommentStatus.spam;
  }
}

/// コメント通知設定モデル
class CommentNotificationSettings {
  final String userId;
  final bool notifyOnNewComment;
  final bool notifyOnReply;
  final bool notifyOnLike;
  final bool notifyOnApproval;
  final bool notifyOnRejection;
  final bool emailNotifications;
  final bool pushNotifications;
  final List<String> mutedContentIds;
  final List<String> mutedUserIds;
  final DateTime updatedAt;

  CommentNotificationSettings({
    required this.userId,
    required this.notifyOnNewComment,
    required this.notifyOnReply,
    required this.notifyOnLike,
    required this.notifyOnApproval,
    required this.notifyOnRejection,
    required this.emailNotifications,
    required this.pushNotifications,
    required this.mutedContentIds,
    required this.mutedUserIds,
    required this.updatedAt,
  });

  /// JSONからコメント通知設定を作成するファクトリメソッド
  factory CommentNotificationSettings.fromJson(Map<String, dynamic> json) {
    return CommentNotificationSettings(
      userId: json['userId'],
      notifyOnNewComment: json['notifyOnNewComment'] ?? true,
      notifyOnReply: json['notifyOnReply'] ?? true,
      notifyOnLike: json['notifyOnLike'] ?? true,
      notifyOnApproval: json['notifyOnApproval'] ?? true,
      notifyOnRejection: json['notifyOnRejection'] ?? true,
      emailNotifications: json['emailNotifications'] ?? true,
      pushNotifications: json['pushNotifications'] ?? true,
      mutedContentIds: List<String>.from(json['mutedContentIds'] ?? []),
      mutedUserIds: List<String>.from(json['mutedUserIds'] ?? []),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// コメント通知設定をJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'notifyOnNewComment': notifyOnNewComment,
      'notifyOnReply': notifyOnReply,
      'notifyOnLike': notifyOnLike,
      'notifyOnApproval': notifyOnApproval,
      'notifyOnRejection': notifyOnRejection,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'mutedContentIds': mutedContentIds,
      'mutedUserIds': mutedUserIds,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// コメント通知設定のコピーを作成するメソッド
  CommentNotificationSettings copyWith({
    String? userId,
    bool? notifyOnNewComment,
    bool? notifyOnReply,
    bool? notifyOnLike,
    bool? notifyOnApproval,
    bool? notifyOnRejection,
    bool? emailNotifications,
    bool? pushNotifications,
    List<String>? mutedContentIds,
    List<String>? mutedUserIds,
    DateTime? updatedAt,
  }) {
    return CommentNotificationSettings(
      userId: userId ?? this.userId,
      notifyOnNewComment: notifyOnNewComment ?? this.notifyOnNewComment,
      notifyOnReply: notifyOnReply ?? this.notifyOnReply,
      notifyOnLike: notifyOnLike ?? this.notifyOnLike,
      notifyOnApproval: notifyOnApproval ?? this.notifyOnApproval,
      notifyOnRejection: notifyOnRejection ?? this.notifyOnRejection,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      mutedContentIds: mutedContentIds ?? List<String>.from(this.mutedContentIds),
      mutedUserIds: mutedUserIds ?? List<String>.from(this.mutedUserIds),
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// コンテンツをミュートするメソッド
  CommentNotificationSettings muteContent(String contentId) {
    if (mutedContentIds.contains(contentId)) return this;
    
    final updatedMutedContentIds = List<String>.from(mutedContentIds)..add(contentId);
    return copyWith(
      mutedContentIds: updatedMutedContentIds,
      updatedAt: DateTime.now(),
    );
  }

  /// ユーザーをミュートするメソッド
  CommentNotificationSettings muteUser(String userId) {
    if (mutedUserIds.contains(userId)) return this;
    
    final updatedMutedUserIds = List<String>.from(mutedUserIds)..add(userId);
    return copyWith(
      mutedUserIds: updatedMutedUserIds,
      updatedAt: DateTime.now(),
    );
  }

  /// 通知を受け取るべきかどうかを確認するメソッド
  bool shouldNotify({
    required String contentId,
    required String authorId,
    required CommentStatus status,
    required bool isReply,
    required bool isLike,
  }) {
    if (mutedContentIds.contains(contentId) || mutedUserIds.contains(authorId)) {
      return false;
    }
    
    if (isReply && notifyOnReply) return true;
    if (isLike && notifyOnLike) return true;
    if (status == CommentStatus.approved && notifyOnApproval) return true;
    if (status == CommentStatus.rejected && notifyOnRejection) return true;
    if (!isReply && !isLike && notifyOnNewComment) return true;
    
    return false;
  }
}
