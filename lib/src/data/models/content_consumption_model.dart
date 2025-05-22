import 'package:flutter/foundation.dart';

/// コンテンツカテゴリを表すenum
enum ContentCategory {
  /// YouTube関連情報
  youtube,
  
  /// 音楽データ
  music,
  
  /// 映像コンテンツ
  video,
  
  /// 書籍データ
  book,
  
  /// 購入履歴
  purchase,
  
  /// アプリ使用状況
  app,
  
  /// 食事データ
  food,
}

/// プライバシーレベルを表すenum
enum PrivacyLevel {
  /// 全ユーザーに公開
  public,
  
  /// フォロワーのみに公開
  followers,
  
  /// プレミアム会員のみに公開
  premium,
  
  /// 非公開
  private,
}

/// 位置情報を表すクラス
class GeoLocation {
  final double latitude;
  final double longitude;
  final String? address;
  final String? placeName;

  GeoLocation({
    required this.latitude,
    required this.longitude,
    this.address,
    this.placeName,
  });

  /// JSONからGeoLocationを生成するファクトリメソッド
  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation(
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      placeName: json['placeName'],
    );
  }

  /// GeoLocationをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'placeName': placeName,
    };
  }

  /// 属性を変更した新しいインスタンスを作成するメソッド
  GeoLocation copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? placeName,
  }) {
    return GeoLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      placeName: placeName ?? this.placeName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeoLocation &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.address == address &&
        other.placeName == placeName;
  }

  @override
  int get hashCode => Object.hash(
        latitude,
        longitude,
        address,
        placeName,
      );
}

/// コンテンツ消費データを表すクラス
class ContentConsumption {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final ContentCategory category;
  final Map<String, dynamic> contentData;
  final PrivacyLevel privacyLevel;
  final List<String>? imageUrls;
  final List<String>? tags;
  final GeoLocation? location;
  final double? price;
  final DateTime? purchaseDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int viewCount;
  final int likeCount;
  final int commentCount;

  ContentConsumption({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.category,
    required this.contentData,
    required this.privacyLevel,
    this.imageUrls,
    this.tags,
    this.location,
    this.price,
    this.purchaseDate,
    required this.createdAt,
    required this.updatedAt,
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
  });

  /// JSONからContentConsumptionを生成するファクトリメソッド
  factory ContentConsumption.fromJson(Map<String, dynamic> json) {
    return ContentConsumption(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      category: ContentCategory.values.firstWhere(
        (e) => e.toString() == 'ContentCategory.${json['category']}',
        orElse: () => ContentCategory.purchase,
      ),
      contentData: Map<String, dynamic>.from(json['contentData']),
      privacyLevel: PrivacyLevel.values.firstWhere(
        (e) => e.toString() == 'PrivacyLevel.${json['privacyLevel']}',
        orElse: () => PrivacyLevel.private,
      ),
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      location: json['location'] != null
          ? GeoLocation.fromJson(json['location'])
          : null,
      price: json['price'],
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      viewCount: json['viewCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
    );
  }

  /// ContentConsumptionをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category.toString().split('.').last,
      'contentData': contentData,
      'privacyLevel': privacyLevel.toString().split('.').last,
      'imageUrls': imageUrls,
      'tags': tags,
      'location': location?.toJson(),
      'price': price,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'viewCount': viewCount,
      'likeCount': likeCount,
      'commentCount': commentCount,
    };
  }

  /// 属性を変更した新しいインスタンスを作成するメソッド
  ContentConsumption copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    ContentCategory? category,
    Map<String, dynamic>? contentData,
    PrivacyLevel? privacyLevel,
    List<String>? imageUrls,
    List<String>? tags,
    GeoLocation? location,
    double? price,
    DateTime? purchaseDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? viewCount,
    int? likeCount,
    int? commentCount,
  }) {
    return ContentConsumption(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      contentData: contentData ?? this.contentData,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      imageUrls: imageUrls ?? this.imageUrls,
      tags: tags ?? this.tags,
      location: location ?? this.location,
      price: price ?? this.price,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
    );
  }

  /// 指定ユーザーがアクセス可能かどうかを判定するメソッド
  bool isAccessibleBy(Map<String, dynamic> user) {
    // ユーザーIDが一致する場合は常にアクセス可能
    if (user['id'] == userId) return true;

    switch (privacyLevel) {
      case PrivacyLevel.public:
        // 公開コンテンツは誰でもアクセス可能
        return true;
      case PrivacyLevel.followers:
        // フォロワーのみアクセス可能
        // 実際の実装ではフォロワー関係を確認する必要がある
        return user['followingIds'] != null && 
               (user['followingIds'] as List<dynamic>).contains(userId);
      case PrivacyLevel.premium:
        // プレミアム会員のみアクセス可能
        return user['subscriptionPlan'] == 'premium' || 
               user['subscriptionPlan'] == 'standard';
      case PrivacyLevel.private:
        // 非公開コンテンツは作成者のみアクセス可能
        return false;
      default:
        return false;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContentConsumption &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.description == description &&
        other.category == category &&
        mapEquals(other.contentData, contentData) &&
        other.privacyLevel == privacyLevel &&
        listEquals(other.imageUrls, imageUrls) &&
        listEquals(other.tags, tags) &&
        other.location == location &&
        other.price == price &&
        other.purchaseDate == purchaseDate &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.viewCount == viewCount &&
        other.likeCount == likeCount &&
        other.commentCount == commentCount;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        title,
        description,
        category,
        contentData,
        privacyLevel,
        imageUrls,
        tags,
        location,
        price,
        purchaseDate,
        createdAt,
        updatedAt,
        viewCount,
        likeCount,
        commentCount,
      );
}
