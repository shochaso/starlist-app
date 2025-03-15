import 'package:flutter/foundation.dart';
import 'user_model.dart';

/// コンテンツ消費モデルクラス
class ContentConsumptionModel {
  /// コンテンツ消費ID
  final String id;
  
  /// ユーザーID（スター）
  final String userId;
  
  /// コンテンツタイプ
  final ContentType contentType;
  
  /// コンテンツタイトル
  final String title;
  
  /// コンテンツの説明
  final String? description;
  
  /// コンテンツURL
  final String? contentUrl;
  
  /// コンテンツID（外部サービスのID）
  final String? externalId;
  
  /// コンテンツ提供元
  final String? source;
  
  /// コンテンツ画像URL
  final String? imageUrl;
  
  /// コンテンツカテゴリ
  final List<String>? categories;
  
  /// タグ
  final List<String>? tags;
  
  /// メタデータ
  final Map<String, dynamic>? metadata;
  
  /// 消費日時
  final DateTime consumedAt;
  
  /// 公開日時
  final DateTime? publishedAt;
  
  /// プライバシーレベル
  final PrivacyLevel privacyLevel;
  
  /// いいね数
  final int likeCount;
  
  /// コメント数
  final int commentCount;
  
  /// 作成日時
  final DateTime createdAt;
  
  /// 更新日時
  final DateTime updatedAt;
  
  /// コンストラクタ
  ContentConsumptionModel({
    required this.id,
    required this.userId,
    required this.contentType,
    required this.title,
    this.description,
    this.contentUrl,
    this.externalId,
    this.source,
    this.imageUrl,
    this.categories,
    this.tags,
    this.metadata,
    required this.consumedAt,
    this.publishedAt,
    required this.privacyLevel,
    this.likeCount = 0,
    this.commentCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// JSONからContentConsumptionModelを作成
  factory ContentConsumptionModel.fromJson(Map<String, dynamic> json) {
    return ContentConsumptionModel(
      id: json['id'],
      userId: json['user_id'],
      contentType: ContentType.values.firstWhere(
        (type) => type.toString().split('.').last == json['content_type'],
        orElse: () => ContentType.other,
      ),
      title: json['title'],
      description: json['description'],
      contentUrl: json['content_url'],
      externalId: json['external_id'],
      source: json['source'],
      imageUrl: json['image_url'],
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      metadata: json['metadata'],
      consumedAt: DateTime.parse(json['consumed_at']),
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'])
          : null,
      privacyLevel: PrivacyLevel.values.firstWhere(
        (level) => level.toString().split('.').last == json['privacy_level'],
        orElse: () => PrivacyLevel.private,
      ),
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  /// ContentConsumptionModelをJSONに変換
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'user_id': userId,
      'content_type': contentType.toString().split('.').last,
      'title': title,
      'description': description,
      'content_url': contentUrl,
      'external_id': externalId,
      'source': source,
      'image_url': imageUrl,
      'categories': categories,
      'tags': tags,
      'metadata': metadata,
      'consumed_at': consumedAt.toIso8601String(),
      'privacy_level': privacyLevel.toString().split('.').last,
      'like_count': likeCount,
      'comment_count': commentCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    
    if (publishedAt != null) {
      data['published_at'] = publishedAt!.toIso8601String();
    }
    
    return data;
  }
  
  /// ContentConsumptionModelをコピーして新しいインスタンスを作成
  ContentConsumptionModel copyWith({
    String? id,
    String? userId,
    ContentType? contentType,
    String? title,
    String? description,
    String? contentUrl,
    String? externalId,
    String? source,
    String? imageUrl,
    List<String>? categories,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    DateTime? consumedAt,
    DateTime? publishedAt,
    PrivacyLevel? privacyLevel,
    int? likeCount,
    int? commentCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContentConsumptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contentType: contentType ?? this.contentType,
      title: title ?? this.title,
      description: description ?? this.description,
      contentUrl: contentUrl ?? this.contentUrl,
      externalId: externalId ?? this.externalId,
      source: source ?? this.source,
      imageUrl: imageUrl ?? this.imageUrl,
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      consumedAt: consumedAt ?? this.consumedAt,
      publishedAt: publishedAt ?? this.publishedAt,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ContentConsumptionModel &&
        other.id == id &&
        other.userId == userId &&
        other.contentType == contentType &&
        other.title == title &&
        other.description == description &&
        other.contentUrl == contentUrl &&
        other.externalId == externalId &&
        other.source == source &&
        other.imageUrl == imageUrl &&
        listEquals(other.categories, categories) &&
        listEquals(other.tags, tags) &&
        mapEquals(other.metadata, metadata) &&
        other.consumedAt == consumedAt &&
        other.publishedAt == publishedAt &&
        other.privacyLevel == privacyLevel &&
        other.likeCount == likeCount &&
        other.commentCount == commentCount &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        contentType.hashCode ^
        title.hashCode ^
        description.hashCode ^
        contentUrl.hashCode ^
        externalId.hashCode ^
        source.hashCode ^
        imageUrl.hashCode ^
        categories.hashCode ^
        tags.hashCode ^
        metadata.hashCode ^
        consumedAt.hashCode ^
        publishedAt.hashCode ^
        privacyLevel.hashCode ^
        likeCount.hashCode ^
        commentCount.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
  
  @override
  String toString() {
    return 'ContentConsumptionModel(id: $id, userId: $userId, contentType: $contentType, title: $title, consumedAt: $consumedAt)';
  }
}

/// コンテンツタイプ
enum ContentType {
  /// YouTube動画
  youtubeVideo,
  
  /// 音楽
  music,
  
  /// 映像コンテンツ
  video,
  
  /// 書籍
  book,
  
  /// 購入商品
  purchase,
  
  /// アプリ
  app,
  
  /// 食事
  food,
  
  /// その他
  other,
}

/// プライバシーレベル
enum PrivacyLevel {
  /// 公開（全員に公開）
  public,
  
  /// 限定公開（サブスクリプションユーザーのみ）
  limited,
  
  /// 非公開（自分のみ）
  private,
}
