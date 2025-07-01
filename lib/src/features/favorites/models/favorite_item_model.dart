import 'package:uuid/uuid.dart';

/// お気に入りアイテムを表すモデルクラス
class FavoriteItemModel {
  final String id;
  final String userId;
  final String itemType; // 'youtube', 'article', 'product', etc.
  final String itemId;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String? url;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  FavoriteItemModel({
    String? id,
    required this.userId,
    required this.itemType,
    required this.itemId,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.url,
    this.metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  /// JSONからFavoriteItemModelを作成するファクトリメソッド
  factory FavoriteItemModel.fromJson(Map<String, dynamic> json) {
    return FavoriteItemModel(
      id: json['id'],
      userId: json['user_id'],
      itemType: json['item_type'],
      itemId: json['item_id'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'],
      url: json['url'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// FavoriteItemModelからJSONを作成するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'item_type': itemType,
      'item_id': itemId,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'url': url,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// YouTubeビデオをお気に入りに追加するファクトリメソッド
  factory FavoriteItemModel.fromYouTube({
    required String userId,
    required String videoId,
    required String title,
    String? description,
    String? thumbnailUrl,
    Map<String, dynamic>? metadata,
  }) {
    return FavoriteItemModel(
      userId: userId,
      itemType: 'youtube',
      itemId: videoId,
      title: title,
      description: description,
      thumbnailUrl: thumbnailUrl,
      url: 'https://www.youtube.com/watch?v=$videoId',
      metadata: metadata,
    );
  }

  /// コピーを作成するメソッド
  FavoriteItemModel copyWith({
    String? id,
    String? userId,
    String? itemType,
    String? itemId,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? url,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FavoriteItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemType: itemType ?? this.itemType,
      itemId: itemId ?? this.itemId,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      url: url ?? this.url,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 