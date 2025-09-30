import 'package:flutter/material.dart';

/// 投稿の種類
enum PostType {
  youtube('YouTube'),
  shopping('ショッピング'),
  music('音楽'),
  food('グルメ'),
  lifestyle('ライフスタイル'),
  other('その他');

  const PostType(this.displayName);
  final String displayName;
}

/// アクセス権限レベル
enum AccessLevel {
  public('公開'),
  light('ライト会員以上'),
  standard('スタンダード会員以上'),
  premium('プレミアム会員以上');

  const AccessLevel(this.displayName);
  final String displayName;
}

/// 投稿データモデル
class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final Color authorColor;
  final String title;
  final String? description;
  final PostType type;
  final AccessLevel accessLevel;
  final DateTime createdAt;
  final Map<String, dynamic> content;
  final List<String> tags;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;

  const PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.authorColor,
    required this.title,
    this.description,
    required this.type,
    required this.accessLevel,
    required this.createdAt,
    required this.content,
    this.tags = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
  });

  /// YouTube投稿用のファクトリー
  factory PostModel.youtubePost({
    required String id,
    required String authorId,
    required String authorName,
    required String authorAvatar,
    required Color authorColor,
    required String title,
    String? description,
    required List<Map<String, dynamic>> videos,
    List<String> tags = const [],
  }) {
    return PostModel(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      authorColor: authorColor,
      title: title,
      description: description,
      type: PostType.youtube,
      accessLevel: AccessLevel.public, // YouTube投稿は公開
      createdAt: DateTime.now(),
      content: {
        'videos': videos,
        'totalDuration': _calculateTotalDuration(videos),
      },
      tags: tags,
    );
  }

  /// ショッピング投稿用のファクトリー
  factory PostModel.shoppingPost({
    required String id,
    required String authorId,
    required String authorName,
    required String authorAvatar,
    required Color authorColor,
    required String title,
    String? description,
    required List<Map<String, dynamic>> items,
    required AccessLevel accessLevel,
    List<String> tags = const [],
  }) {
    return PostModel(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      authorColor: authorColor,
      title: title,
      description: description,
      type: PostType.shopping,
      accessLevel: accessLevel,
      createdAt: DateTime.now(),
      content: {
        'items': items,
        'totalAmount': _calculateTotalAmount(items),
      },
      tags: tags,
    );
  }

  /// 総再生時間計算
  static String _calculateTotalDuration(List<Map<String, dynamic>> videos) {
    int totalMinutes = 0;
    for (final video in videos) {
      final duration = video['duration'] as String?;
      if (duration != null) {
        totalMinutes += _parseDuration(duration);
      }
    }
    
    if (totalMinutes >= 60) {
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      return '$hours時間$minutes分';
    }
    return '$totalMinutes分';
  }

  /// 総購入金額計算
  static int _calculateTotalAmount(List<Map<String, dynamic>> items) {
    return items.fold<int>(0, (sum, item) {
      final price = item['price'] as int? ?? 0;
      return sum + price;
    });
  }

  /// 時間文字列をパース
  static int _parseDuration(String duration) {
    final parts = duration.split(':');
    if (parts.length == 2) {
      return int.tryParse(parts[0]) ?? 0;
    } else if (parts.length == 3) {
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      return hours * 60 + minutes;
    }
    return 0;
  }

  /// 投稿のコピーを作成
  PostModel copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    Color? authorColor,
    String? title,
    String? description,
    PostType? type,
    AccessLevel? accessLevel,
    DateTime? createdAt,
    Map<String, dynamic>? content,
    List<String>? tags,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
  }) {
    return PostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      authorColor: authorColor ?? this.authorColor,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      accessLevel: accessLevel ?? this.accessLevel,
      createdAt: createdAt ?? this.createdAt,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  /// JSON形式に変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'authorColor': authorColor.value,
      'title': title,
      'description': description,
      'type': type.name,
      'accessLevel': accessLevel.name,
      'createdAt': createdAt.toIso8601String(),
      'content': content,
      'tags': tags,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'isLiked': isLiked,
    };
  }

  /// JSONから作成
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      authorAvatar: json['authorAvatar'],
      authorColor: Color(json['authorColor']),
      title: json['title'],
      description: json['description'],
      type: PostType.values.firstWhere((e) => e.name == json['type']),
      accessLevel: AccessLevel.values.firstWhere((e) => e.name == json['accessLevel']),
      createdAt: DateTime.parse(json['createdAt']),
      content: json['content'],
      tags: List<String>.from(json['tags']),
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }

  /// 時間の経過表示
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'たった今';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      return '${createdAt.month}/${createdAt.day}';
    }
  }

  /// アクセス権限チェック
  bool canAccess(AccessLevel userLevel) {
    return userLevel.index >= accessLevel.index;
  }
}