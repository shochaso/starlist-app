import 'package:flutter/foundation.dart';

/// Amazon購入カテゴリ
enum AmazonPurchaseCategory {
  books,           // 本・雑誌
  electronics,     // 家電・PC
  clothing,        // ファッション
  home,           // ホーム・キッチン
  beauty,         // ビューティー
  sports,         // スポーツ・アウトドア
  toys,           // おもちゃ・ゲーム
  food,           // 食品・飲料
  automotive,     // 車・バイク
  health,         // ヘルス・ケア
  music,          // 音楽
  video,          // 映画・TV
  software,       // ソフトウェア
  pet,            // ペット用品
  baby,           // ベビー用品
  industrial,     // 産業・研究開発
  other,          // その他
}

/// Amazon購入モデル
@immutable
class AmazonPurchase {
  final String id;
  final String userId;
  final String orderId;
  final String productId;
  final String productName;
  final String? productBrand;
  final double price;
  final String currency;
  final int quantity;
  final AmazonPurchaseCategory category;
  final DateTime purchaseDate;
  final DateTime? deliveryDate;
  final String? imageUrl;
  final String? productUrl;
  final String? reviewId;
  final double? rating;
  final String? reviewText;
  final bool isReturned;
  final bool isRefunded;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AmazonPurchase({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.productId,
    required this.productName,
    this.productBrand,
    required this.price,
    required this.currency,
    required this.quantity,
    required this.category,
    required this.purchaseDate,
    this.deliveryDate,
    this.imageUrl,
    this.productUrl,
    this.reviewId,
    this.rating,
    this.reviewText,
    required this.isReturned,
    required this.isRefunded,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSONからAmazonPurchaseを作成
  factory AmazonPurchase.fromJson(Map<String, dynamic> json) {
    return AmazonPurchase(
      id: json['id'],
      userId: json['user_id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      productName: json['product_name'],
      productBrand: json['product_brand'],
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] ?? 'JPY',
      quantity: json['quantity'] ?? 1,
      category: _parsePurchaseCategory(json['category']),
      purchaseDate: DateTime.parse(json['purchase_date']),
      deliveryDate: json['delivery_date'] != null ? DateTime.parse(json['delivery_date']) : null,
      imageUrl: json['image_url'],
      productUrl: json['product_url'],
      reviewId: json['review_id'],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewText: json['review_text'],
      isReturned: json['is_returned'] ?? false,
      isRefunded: json['is_refunded'] ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// AmazonPurchaseをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'product_brand': productBrand,
      'price': price,
      'currency': currency,
      'quantity': quantity,
      'category': _categoryToString(category),
      'purchase_date': purchaseDate.toIso8601String(),
      'delivery_date': deliveryDate?.toIso8601String(),
      'image_url': imageUrl,
      'product_url': productUrl,
      'review_id': reviewId,
      'rating': rating,
      'review_text': reviewText,
      'is_returned': isReturned,
      'is_refunded': isRefunded,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// コピーを作成
  AmazonPurchase copyWith({
    String? id,
    String? userId,
    String? orderId,
    String? productId,
    String? productName,
    String? productBrand,
    double? price,
    String? currency,
    int? quantity,
    AmazonPurchaseCategory? category,
    DateTime? purchaseDate,
    DateTime? deliveryDate,
    String? imageUrl,
    String? productUrl,
    String? reviewId,
    double? rating,
    String? reviewText,
    bool? isReturned,
    bool? isRefunded,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AmazonPurchase(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productBrand: productBrand ?? this.productBrand,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      imageUrl: imageUrl ?? this.imageUrl,
      productUrl: productUrl ?? this.productUrl,
      reviewId: reviewId ?? this.reviewId,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      isReturned: isReturned ?? this.isReturned,
      isRefunded: isRefunded ?? this.isRefunded,
      metadata: metadata ?? Map<String, dynamic>.from(this.metadata),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// カテゴリ文字列を解析
  static AmazonPurchaseCategory _parsePurchaseCategory(String? category) {
    if (category == null) return AmazonPurchaseCategory.other;
    
    switch (category.toLowerCase()) {
      case 'books':
        return AmazonPurchaseCategory.books;
      case 'electronics':
        return AmazonPurchaseCategory.electronics;
      case 'clothing':
        return AmazonPurchaseCategory.clothing;
      case 'home':
        return AmazonPurchaseCategory.home;
      case 'beauty':
        return AmazonPurchaseCategory.beauty;
      case 'sports':
        return AmazonPurchaseCategory.sports;
      case 'toys':
        return AmazonPurchaseCategory.toys;
      case 'food':
        return AmazonPurchaseCategory.food;
      case 'automotive':
        return AmazonPurchaseCategory.automotive;
      case 'health':
        return AmazonPurchaseCategory.health;
      case 'music':
        return AmazonPurchaseCategory.music;
      case 'video':
        return AmazonPurchaseCategory.video;
      case 'software':
        return AmazonPurchaseCategory.software;
      case 'pet':
        return AmazonPurchaseCategory.pet;
      case 'baby':
        return AmazonPurchaseCategory.baby;
      case 'industrial':
        return AmazonPurchaseCategory.industrial;
      default:
        return AmazonPurchaseCategory.other;
    }
  }

  /// カテゴリを文字列に変換
  static String _categoryToString(AmazonPurchaseCategory category) {
    switch (category) {
      case AmazonPurchaseCategory.books:
        return 'books';
      case AmazonPurchaseCategory.electronics:
        return 'electronics';
      case AmazonPurchaseCategory.clothing:
        return 'clothing';
      case AmazonPurchaseCategory.home:
        return 'home';
      case AmazonPurchaseCategory.beauty:
        return 'beauty';
      case AmazonPurchaseCategory.sports:
        return 'sports';
      case AmazonPurchaseCategory.toys:
        return 'toys';
      case AmazonPurchaseCategory.food:
        return 'food';
      case AmazonPurchaseCategory.automotive:
        return 'automotive';
      case AmazonPurchaseCategory.health:
        return 'health';
      case AmazonPurchaseCategory.music:
        return 'music';
      case AmazonPurchaseCategory.video:
        return 'video';
      case AmazonPurchaseCategory.software:
        return 'software';
      case AmazonPurchaseCategory.pet:
        return 'pet';
      case AmazonPurchaseCategory.baby:
        return 'baby';
      case AmazonPurchaseCategory.industrial:
        return 'industrial';
      case AmazonPurchaseCategory.other:
        return 'other';
    }
  }

  /// 合計金額（数量含む）
  double get totalAmount => price * quantity;

  /// フォーマット済み金額
  String get formattedPrice => _formatPrice(price, currency);

  /// フォーマット済み合計金額
  String get formattedTotalAmount => _formatPrice(totalAmount, currency);

  /// 金額フォーマット
  static String _formatPrice(double price, String currency) {
    final currencySymbols = {
      'JPY': '¥',
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
    };

    final symbol = currencySymbols[currency] ?? currency;
    
    String formattedAmount;
    if (currency == 'JPY') {
      formattedAmount = price.toInt().toString();
    } else {
      formattedAmount = price.toStringAsFixed(2);
    }
    
    final parts = formattedAmount.split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    
    if (parts.length > 1) {
      return '$symbol$integerPart.${parts[1]}';
    } else {
      return '$symbol$integerPart';
    }
  }

  /// カテゴリの日本語名
  String get categoryDisplayName {
    switch (category) {
      case AmazonPurchaseCategory.books:
        return '本・雑誌';
      case AmazonPurchaseCategory.electronics:
        return '家電・PC';
      case AmazonPurchaseCategory.clothing:
        return 'ファッション';
      case AmazonPurchaseCategory.home:
        return 'ホーム・キッチン';
      case AmazonPurchaseCategory.beauty:
        return 'ビューティー';
      case AmazonPurchaseCategory.sports:
        return 'スポーツ・アウトドア';
      case AmazonPurchaseCategory.toys:
        return 'おもちゃ・ゲーム';
      case AmazonPurchaseCategory.food:
        return '食品・飲料';
      case AmazonPurchaseCategory.automotive:
        return '車・バイク';
      case AmazonPurchaseCategory.health:
        return 'ヘルス・ケア';
      case AmazonPurchaseCategory.music:
        return '音楽';
      case AmazonPurchaseCategory.video:
        return '映画・TV';
      case AmazonPurchaseCategory.software:
        return 'ソフトウェア';
      case AmazonPurchaseCategory.pet:
        return 'ペット用品';
      case AmazonPurchaseCategory.baby:
        return 'ベビー用品';
      case AmazonPurchaseCategory.industrial:
        return '産業・研究開発';
      case AmazonPurchaseCategory.other:
        return 'その他';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AmazonPurchase &&
        other.id == id &&
        other.userId == userId &&
        other.orderId == orderId &&
        other.productId == productId &&
        other.productName == productName &&
        other.productBrand == productBrand &&
        other.price == price &&
        other.currency == currency &&
        other.quantity == quantity &&
        other.category == category &&
        other.purchaseDate == purchaseDate &&
        other.deliveryDate == deliveryDate &&
        other.imageUrl == imageUrl &&
        other.productUrl == productUrl &&
        other.reviewId == reviewId &&
        other.rating == rating &&
        other.reviewText == reviewText &&
        other.isReturned == isReturned &&
        other.isRefunded == isRefunded &&
        mapEquals(other.metadata, metadata) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        orderId,
        productId,
        productName,
        productBrand,
        price,
        currency,
        quantity,
        category,
        purchaseDate,
        deliveryDate,
        imageUrl,
        productUrl,
        reviewId,
        rating,
        reviewText,
        isReturned,
        isRefunded,
        metadata,
        createdAt,
        updatedAt,
      );
}

/// Amazon購入統計モデル
@immutable
class AmazonPurchaseStats {
  final int totalPurchases;
  final double totalSpent;
  final String currency;
  final Map<AmazonPurchaseCategory, int> purchasesByCategory;
  final Map<AmazonPurchaseCategory, double> spentByCategory;
  final Map<String, double> spentByMonth;
  final List<String> topBrands;
  final double averageOrderValue;
  final int totalReturns;
  final int totalRefunds;
  final DateTime periodStart;
  final DateTime periodEnd;

  const AmazonPurchaseStats({
    required this.totalPurchases,
    required this.totalSpent,
    required this.currency,
    required this.purchasesByCategory,
    required this.spentByCategory,
    required this.spentByMonth,
    required this.topBrands,
    required this.averageOrderValue,
    required this.totalReturns,
    required this.totalRefunds,
    required this.periodStart,
    required this.periodEnd,
  });

  /// 統計をJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'total_purchases': totalPurchases,
      'total_spent': totalSpent,
      'currency': currency,
      'purchases_by_category': purchasesByCategory.map(
        (key, value) => MapEntry(AmazonPurchase._categoryToString(key), value),
      ),
      'spent_by_category': spentByCategory.map(
        (key, value) => MapEntry(AmazonPurchase._categoryToString(key), value),
      ),
      'spent_by_month': spentByMonth,
      'top_brands': topBrands,
      'average_order_value': averageOrderValue,
      'total_returns': totalReturns,
      'total_refunds': totalRefunds,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
    };
  }
}

/// Amazon購入フィルターモデル
@immutable
class AmazonPurchaseFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<AmazonPurchaseCategory>? categories;
  final double? minPrice;
  final double? maxPrice;
  final List<String>? brands;
  final bool? hasReview;
  final bool? excludeReturned;
  final String? searchQuery;

  const AmazonPurchaseFilter({
    this.startDate,
    this.endDate,
    this.categories,
    this.minPrice,
    this.maxPrice,
    this.brands,
    this.hasReview,
    this.excludeReturned,
    this.searchQuery,
  });

  /// フィルターをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'categories': categories?.map((c) => AmazonPurchase._categoryToString(c)).toList(),
      'min_price': minPrice,
      'max_price': maxPrice,
      'brands': brands,
      'has_review': hasReview,
      'exclude_returned': excludeReturned,
      'search_query': searchQuery,
    };
  }

  /// フィルターが適用されているかどうか
  bool get hasFilters {
    return startDate != null ||
           endDate != null ||
           categories != null ||
           minPrice != null ||
           maxPrice != null ||
           brands != null ||
           hasReview != null ||
           excludeReturned != null ||
           (searchQuery != null && searchQuery!.isNotEmpty);
  }
}