
/// アフィリエイト商品を表すモデルクラス
class AffiliateProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String affiliateUrl;
  final double commissionRate; // コミッション率（0.0〜1.0）
  final String category;
  final String starId; // 推薦するスターのID
  final bool isRecommended; // スターのおすすめ商品かどうか
  final int purchaseCount; // 購入数

  AffiliateProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.affiliateUrl,
    required this.commissionRate,
    required this.category,
    required this.starId,
    this.isRecommended = false,
    this.purchaseCount = 0,
  });

  /// JSON形式のデータからAffiliateProductオブジェクトを生成するファクトリメソッド
  factory AffiliateProduct.fromJson(Map<String, dynamic> json) {
    return AffiliateProduct(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      affiliateUrl: json['affiliateUrl'] ?? '',
      commissionRate: (json['commissionRate'] ?? 0.0).toDouble(),
      category: json['category'] ?? '',
      starId: json['starId'] ?? '',
      isRecommended: json['isRecommended'] ?? false,
      purchaseCount: json['purchaseCount'] ?? 0,
    );
  }

  /// オブジェクトをJSON形式に変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'affiliateUrl': affiliateUrl,
      'commissionRate': commissionRate,
      'category': category,
      'starId': starId,
      'isRecommended': isRecommended,
      'purchaseCount': purchaseCount,
    };
  }

  /// 商品の収益を計算するメソッド
  double calculateRevenue() {
    return price * commissionRate;
  }

  /// スターの取り分を計算するメソッド（70%）
  double calculateStarShare() {
    return calculateRevenue() * 0.7;
  }

  /// プラットフォームの取り分を計算するメソッド（30%）
  double calculatePlatformShare() {
    return calculateRevenue() * 0.3;
  }
}
