
/// コンテンツカテゴリ
enum ContentCategory {
  youtube,    // YouTube動画
  music,      // 音楽
  purchase,   // 購入
  food,       // 食べ物
  location,   // 場所
  book,       // 本
  other       // その他
}

/// プライバシーレベル
enum PrivacyLevel {
  public,     // 公開
  followers,  // フォロワーのみ
  private,    // 非公開
  premium     // プレミアム会員のみ
}

/// 位置情報（プライバシー配慮版）
class GeoLocation {
  final double latitude;
  final double longitude;
  // final String? address; // プライバシー保護のため削除
  final String? placeName; // 店名・施設名のみ（住所情報なし）
  final String? category; // 「レストラン」「ショッピングモール」等の大分類
  
  GeoLocation({
    required this.latitude,
    required this.longitude,
    // this.address, // 削除
    this.placeName,
    this.category,
  });
  
  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation(
      latitude: json['latitude'],
      longitude: json['longitude'],
      // address: json['address'], // 削除
      placeName: json['place_name'],
      category: json['category'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      // 'address': address, // 削除
      'place_name': placeName,
      'category': category,
    };
  }
  
  /// プライバシーに配慮した表示用テキスト
  String get displayText {
    final parts = <String>[];
    if (placeName != null) parts.add(placeName!);
    if (category != null) parts.add('(${category!})');
    return parts.isNotEmpty ? parts.join(' ') : '位置情報';
  }
}

/// コンテンツ消費モデル
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
  final int? price;
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
  
  factory ContentConsumption.fromJson(Map<String, dynamic> json) {
    return ContentConsumption(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      category: ContentCategory.values.firstWhere(
        (cat) => cat.name == json['category'],
        orElse: () => ContentCategory.other,
      ),
      contentData: json['content_data'] ?? {},
      privacyLevel: PrivacyLevel.values.firstWhere(
        (lvl) => lvl.name == json['privacy_level'],
        orElse: () => PrivacyLevel.private,
      ),
      imageUrls: json['image_urls'] != null 
          ? List<String>.from(json['image_urls'])
          : null,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'])
          : null,
      location: json['location'] != null
          ? GeoLocation.fromJson(json['location'])
          : null,
      price: json['price'],
      purchaseDate: json['purchase_date'] != null
          ? DateTime.parse(json['purchase_date'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      viewCount: json['view_count'] ?? 0,
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category.name,
      'content_data': contentData,
      'privacy_level': privacyLevel.name,
      'image_urls': imageUrls,
      'tags': tags,
      'location': location?.toJson(),
      'price': price,
      'purchase_date': purchaseDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'view_count': viewCount,
      'like_count': likeCount,
      'comment_count': commentCount,
    };
  }
  
  /// アクセス権限のチェック
  bool isAccessibleBy(Map<String, dynamic> viewerData) {
    final viewerId = viewerData['id'];
    
    // コンテンツ所有者は常にアクセス可能
    if (viewerId == userId) return true;
    
    switch (privacyLevel) {
      case PrivacyLevel.public:
        return true;
      case PrivacyLevel.followers:
        // フォロワーリストに含まれているかチェック
        final followingIds = viewerData['followingIds'] as List<dynamic>?;
        return followingIds?.contains(userId) ?? false;
      case PrivacyLevel.premium:
        // プレミアム会員かチェック
        return viewerData['subscriptionPlan'] == 'premium';
      case PrivacyLevel.private:
        return false;
    }
  }
  
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
    int? price,
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
}

enum ContentType {
  youtube,
  spotify,
  netflix,
  book,
  product,
  other,
}

class ContentConsumptionModel {
  final String id;
  final String userId;
  final ContentType contentType;
  final String? contentId;
  final String title;
  final String? description;
  final String? platform;
  final String? url;
  final DateTime consumptionDate;
  final int? duration;
  final int? rating;
  final String? comment;
  final Map<String, dynamic> metadata;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContentConsumptionModel({
    required this.id,
    required this.userId,
    required this.contentType,
    this.contentId,
    required this.title,
    this.description,
    this.platform,
    this.url,
    required this.consumptionDate,
    this.duration,
    this.rating,
    this.comment,
    this.metadata = const {},
    this.isPublic = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContentConsumptionModel.fromJson(Map<String, dynamic> json) {
    return ContentConsumptionModel(
      id: json["id"] as String,
      userId: json["user_id"] as String,
      contentType: _contentTypeFromString(json["content_type"] as String),
      contentId: json["content_id"] as String?,
      title: json["title"] as String,
      description: json["description"] as String?,
      platform: json["platform"] as String?,
      url: json["url"] as String?,
      consumptionDate: DateTime.parse(json["consumption_date"] as String),
      duration: json["duration"] as int?,
      rating: json["rating"] as int?,
      comment: json["comment"] as String?,
      metadata: (json["metadata"] as Map<String, dynamic>?) ?? {},
      isPublic: json["is_public"] as bool? ?? true,
      createdAt: DateTime.parse(json["created_at"] as String),
      updatedAt: DateTime.parse(json["updated_at"] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "content_type": contentType.toString().split(".").last,
      "content_id": contentId,
      "title": title,
      "description": description,
      "platform": platform,
      "url": url,
      "consumption_date": consumptionDate.toIso8601String(),
      "duration": duration,
      "rating": rating,
      "comment": comment,
      "metadata": metadata,
      "is_public": isPublic,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
    };
  }

  static ContentType _contentTypeFromString(String type) {
    try {
      return ContentType.values.firstWhere(
        (e) => e.toString().split('.').last == type,
      );
    } catch (_) {
      return ContentType.other;
    }
  }
} 