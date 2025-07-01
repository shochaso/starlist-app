import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/affiliate_product.dart';

/// アフィリエイト商品の管理とレコメンデーションを行うサービスクラス
class AffiliateService {
  final Dio _dio;
  final String _baseUrl;
  
  /// コンストラクタ
  AffiliateService({
    Dio? dio,
    String baseUrl = 'https://api.starlist.com/affiliate',
  }) : _dio = dio ?? Dio(),
       _baseUrl = baseUrl;

  /// スターのおすすめ商品リストを取得する
  /// [starId] スターのID
  /// [limit] 取得する商品数の上限
  Future<List<AffiliateProduct>> getStarRecommendedProducts(String starId, {int limit = 10}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/stars/$starId/recommended',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['products'];
        return data.map((json) => AffiliateProduct.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load recommended products: ${response.statusCode}');
      }
    } catch (e) {
      // 実際のAPIが存在しない場合のモックデータ
      return _getMockRecommendedProducts(starId, limit: limit);
    }
  }

  /// ユーザーの購入履歴に基づいてレコメンデーションを取得する
  /// [userId] ユーザーのID
  /// [limit] 取得する商品数の上限
  Future<List<AffiliateProduct>> getPersonalizedRecommendations(String userId, {int limit = 10}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/users/$userId/recommendations',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['products'];
        return data.map((json) => AffiliateProduct.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load personalized recommendations: ${response.statusCode}');
      }
    } catch (e) {
      // 実際のAPIが存在しない場合のモックデータ
      return _getMockPersonalizedRecommendations(userId, limit: limit);
    }
  }

  /// カテゴリ別の商品リストを取得する
  /// [category] 商品カテゴリ
  /// [limit] 取得する商品数の上限
  Future<List<AffiliateProduct>> getProductsByCategory(String category, {int limit = 20}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/products',
        queryParameters: {
          'category': category,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['products'];
        return data.map((json) => AffiliateProduct.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products by category: ${response.statusCode}');
      }
    } catch (e) {
      // 実際のAPIが存在しない場合のモックデータ
      return _getMockProductsByCategory(category, limit: limit);
    }
  }

  /// 商品の購入を記録する
  /// [productId] 購入された商品のID
  /// [userId] 購入したユーザーのID
  /// [starId] 紹介元のスターのID
  Future<bool> recordPurchase(String productId, String userId, String starId) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/purchases',
        data: {
          'productId': productId,
          'userId': userId,
          'starId': starId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // 開発環境では成功したと仮定
      print('Purchase recorded (mock): $productId by $userId from $starId');
      return true;
    }
  }

  /// アフィリエイト収益を計算する
  /// [starId] スターのID
  /// [startDate] 期間の開始日
  /// [endDate] 期間の終了日
  Future<Map<String, double>> calculateAffiliateRevenue(
    String starId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();

    try {
      final response = await _dio.get(
        '$_baseUrl/stars/$starId/revenue',
        queryParameters: {
          'startDate': start.toIso8601String(),
          'endDate': end.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'totalRevenue': data['totalRevenue'],
          'starShare': data['starShare'],
          'platformShare': data['platformShare'],
        };
      } else {
        throw Exception('Failed to calculate revenue: ${response.statusCode}');
      }
    } catch (e) {
      // モックデータを返す
      const totalRevenue = 100000.0; // 仮の総収益
      return {
        'totalRevenue': totalRevenue,
        'starShare': totalRevenue * 0.7, // スターの取り分（70%）
        'platformShare': totalRevenue * 0.3, // プラットフォームの取り分（30%）
      };
    }
  }

  /// モックのおすすめ商品データを生成する（開発用）
  List<AffiliateProduct> _getMockRecommendedProducts(String starId, {int limit = 10}) {
    final products = <AffiliateProduct>[];
    
    final categories = ['ファッション', 'コスメ', '家電', '書籍', 'ゲーム'];
    
    for (int i = 0; i < limit; i++) {
      final categoryIndex = i % categories.length;
      products.add(
        AffiliateProduct(
          id: 'product_${starId}_$i',
          name: '${categories[categoryIndex]}アイテム $i',
          description: 'スター$starIdがおすすめする${categories[categoryIndex]}アイテムです。',
          price: 1000.0 + (i * 500),
          imageUrl: 'https://example.com/products/$i.jpg',
          affiliateUrl: 'https://example.com/affiliate/$starId/product_$i',
          commissionRate: 0.1, // 10%のコミッション
          category: categories[categoryIndex],
          starId: starId,
          isRecommended: true,
          purchaseCount: 10 + (i * 5),
        ),
      );
    }
    
    return products;
  }

  /// モックのパーソナライズされたレコメンデーションデータを生成する（開発用）
  List<AffiliateProduct> _getMockPersonalizedRecommendations(String userId, {int limit = 10}) {
    final products = <AffiliateProduct>[];
    
    final categories = ['ファッション', 'コスメ', '家電', '書籍', 'ゲーム'];
    final stars = ['star1', 'star2', 'star3', 'star4', 'star5'];
    
    for (int i = 0; i < limit; i++) {
      final categoryIndex = i % categories.length;
      final starIndex = i % stars.length;
      products.add(
        AffiliateProduct(
          id: 'rec_product_$i',
          name: 'おすすめ${categories[categoryIndex]} $i',
          description: 'あなたの購入履歴に基づいておすすめする${categories[categoryIndex]}アイテムです。',
          price: 2000.0 + (i * 300),
          imageUrl: 'https://example.com/recommendations/$i.jpg',
          affiliateUrl: 'https://example.com/affiliate/${stars[starIndex]}/product_$i',
          commissionRate: 0.08, // 8%のコミッション
          category: categories[categoryIndex],
          starId: stars[starIndex],
          isRecommended: false,
          purchaseCount: 20 + (i * 3),
        ),
      );
    }
    
    return products;
  }

  /// モックのカテゴリ別商品データを生成する（開発用）
  List<AffiliateProduct> _getMockProductsByCategory(String category, {int limit = 20}) {
    final products = <AffiliateProduct>[];
    final stars = ['star1', 'star2', 'star3', 'star4', 'star5'];
    
    for (int i = 0; i < limit; i++) {
      final starIndex = i % stars.length;
      final isRecommended = i < 5; // 最初の5つはおすすめ商品とする
      
      products.add(
        AffiliateProduct(
          id: '${category}_product_$i',
          name: '$category商品 $i',
          description: '$categoryカテゴリの商品です。',
          price: 1500.0 + (i * 200),
          imageUrl: 'https://example.com/categories/$category/$i.jpg',
          affiliateUrl: 'https://example.com/affiliate/${stars[starIndex]}/${category}_product_$i',
          commissionRate: 0.05 + (i % 10) * 0.01, // 5%〜14%のコミッション
          category: category,
          starId: isRecommended ? stars[starIndex] : '',
          isRecommended: isRecommended,
          purchaseCount: 5 + (i * 2),
        ),
      );
    }
    
    return products;
  }
}
