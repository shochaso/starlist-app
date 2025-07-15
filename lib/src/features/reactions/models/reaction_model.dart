import 'package:flutter/foundation.dart';

/// リアクションタイプ列挙型
enum ReactionType {
  like('like', '👍'),
  heart('heart', '❤️');

  const ReactionType(this.value, this.emoji);
  
  final String value;
  final String emoji;
  
  static ReactionType fromValue(String value) {
    return values.firstWhere(
      (type) => type.value == value,
      orElse: () => ReactionType.like,
    );
  }
}

/// リアクションモデル
@immutable
class ReactionModel {
  const ReactionModel({
    required this.id,
    required this.userId,
    required this.postId,
    this.commentId,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String postId;
  final String? commentId;
  final ReactionType type;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// JSONからReactionModelを作成
  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      postId: json['post_id'] as String,
      commentId: json['comment_id'] as String?,
      type: ReactionType.fromValue(json['reaction_type'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// ReactionModelをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'post_id': postId,
      'comment_id': commentId,
      'reaction_type': type.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 投稿リアクションかどうか
  bool get isPostReaction => commentId == null;

  /// コメントリアクションかどうか
  bool get isCommentReaction => commentId != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReactionModel &&
        other.id == id &&
        other.userId == userId &&
        other.postId == postId &&
        other.commentId == commentId &&
        other.type == type &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        postId,
        commentId,
        type,
        createdAt,
        updatedAt,
      );

  @override
  String toString() {
    return 'ReactionModel(id: $id, userId: $userId, postId: $postId, commentId: $commentId, type: $type, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// リアクション数集計モデル
@immutable
class ReactionCountModel {
  const ReactionCountModel({
    required this.like,
    required this.heart,
  });

  final int like;
  final int heart;

  /// 空のリアクション数
  static const ReactionCountModel empty = ReactionCountModel(
    like: 0,
    heart: 0,
  );

  /// データベース結果からReactionCountModelを作成
  factory ReactionCountModel.fromDatabase(List<Map<String, dynamic>> results) {
    int likeCount = 0;
    int heartCount = 0;

    for (final result in results) {
      final type = result['reaction_type'] as String;
      final count = result['count'] as int;

      switch (type) {
        case 'like':
          likeCount = count;
          break;
        case 'heart':
          heartCount = count;
          break;
      }
    }

    return ReactionCountModel(
      like: likeCount,
      heart: heartCount,
    );
  }

  /// 特定のリアクションタイプの数を取得
  int getCount(ReactionType type) {
    switch (type) {
      case ReactionType.like:
        return like;
      case ReactionType.heart:
        return heart;
    }
  }

  /// 全リアクション数
  int get total => like + heart;

  /// リアクションがあるかどうか
  bool get hasReactions => total > 0;

  /// copyWithメソッド
  ReactionCountModel copyWith({
    int? like,
    int? heart,
  }) {
    return ReactionCountModel(
      like: like ?? this.like,
      heart: heart ?? this.heart,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReactionCountModel &&
        other.like == like &&
        other.heart == heart;
  }

  @override
  int get hashCode => Object.hash(like, heart);

  @override
  String toString() {
    return 'ReactionCountModel(like: $like, heart: $heart)';
  }
}

/// ユーザーリアクション状態モデル
@immutable
class UserReactionState {
  const UserReactionState({
    required this.hasLiked,
    required this.hasHearted,
  });

  final bool hasLiked;
  final bool hasHearted;

  /// 空のユーザーリアクション状態
  static const UserReactionState empty = UserReactionState(
    hasLiked: false,
    hasHearted: false,
  );

  /// データベース結果からUserReactionStateを作成
  factory UserReactionState.fromDatabase(List<Map<String, dynamic>> results) {
    bool hasLiked = false;
    bool hasHearted = false;

    for (final result in results) {
      final type = result['reaction_type'] as String;
      switch (type) {
        case 'like':
          hasLiked = true;
          break;
        case 'heart':
          hasHearted = true;
          break;
      }
    }

    return UserReactionState(
      hasLiked: hasLiked,
      hasHearted: hasHearted,
    );
  }

  /// 特定のリアクションタイプを持っているかどうか
  bool hasReaction(ReactionType type) {
    switch (type) {
      case ReactionType.like:
        return hasLiked;
      case ReactionType.heart:
        return hasHearted;
    }
  }

  /// リアクションを切り替え
  UserReactionState toggleReaction(ReactionType type) {
    switch (type) {
      case ReactionType.like:
        return copyWith(hasLiked: !hasLiked);
      case ReactionType.heart:
        return copyWith(hasHearted: !hasHearted);
    }
  }

  /// copyWithメソッド
  UserReactionState copyWith({
    bool? hasLiked,
    bool? hasHearted,
  }) {
    return UserReactionState(
      hasLiked: hasLiked ?? this.hasLiked,
      hasHearted: hasHearted ?? this.hasHearted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserReactionState &&
        other.hasLiked == hasLiked &&
        other.hasHearted == hasHearted;
  }

  @override
  int get hashCode => Object.hash(hasLiked, hasHearted);

  @override
  String toString() {
    return 'UserReactionState(hasLiked: $hasLiked, hasHearted: $hasHearted)';
  }
}