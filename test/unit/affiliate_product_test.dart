import 'package:flutter_test/flutter_test.dart';
import 'package:starlist_improved/src/features/monetization/models/affiliate_product.dart';

void main() {
  group('AffiliateProduct', () {
    test('fromJson should correctly parse JSON data', () {
      // テスト用のモックデータ
      final json = {
        'id': 'product123',
        'name': 'テスト商品',
        'description': 'これはテスト商品の説明です',
        'price': 5000.0,
        'imageUrl': 'https://example.com/image.jpg',
        'affiliateUrl': 'https://example.com/affiliate/product123',
        'commissionRate': 0.1,
        'category': 'テストカテゴリ',
        'starId': 'star123',
        'isRecommended': true,
        'purchaseCount': 100,
      };

      // モデルに変換
      final product = AffiliateProduct.fromJson(json);

      // 各フィールドが正しく変換されているか検証
      expect(product.id, 'product123');
      expect(product.name, 'テスト商品');
      expect(product.description, 'これはテスト商品の説明です');
      expect(product.price, 5000.0);
      expect(product.imageUrl, 'https://example.com/image.jpg');
      expect(product.affiliateUrl, 'https://example.com/affiliate/product123');
      expect(product.commissionRate, 0.1);
      expect(product.category, 'テストカテゴリ');
      expect(product.starId, 'star123');
      expect(product.isRecommended, true);
      expect(product.purchaseCount, 100);
    });

    test('toJson should correctly convert to JSON format', () {
      // テスト用のAffiliateProductインスタンス
      final product = AffiliateProduct(
        id: 'product123',
        name: 'テスト商品',
        description: 'これはテスト商品の説明です',
        price: 5000.0,
        imageUrl: 'https://example.com/image.jpg',
        affiliateUrl: 'https://example.com/affiliate/product123',
        commissionRate: 0.1,
        category: 'テストカテゴリ',
        starId: 'star123',
        isRecommended: true,
        purchaseCount: 100,
      );

      // JSONに変換
      final json = product.toJson();

      // 各フィールドが正しく変換されているか検証
      expect(json['id'], 'product123');
      expect(json['name'], 'テスト商品');
      expect(json['description'], 'これはテスト商品の説明です');
      expect(json['price'], 5000.0);
      expect(json['imageUrl'], 'https://example.com/image.jpg');
      expect(json['affiliateUrl'], 'https://example.com/affiliate/product123');
      expect(json['commissionRate'], 0.1);
      expect(json['category'], 'テストカテゴリ');
      expect(json['starId'], 'star123');
      expect(json['isRecommended'], true);
      expect(json['purchaseCount'], 100);
    });

    test('calculateRevenue should return correct revenue', () {
      // テスト用のAffiliateProductインスタンス
      final product = AffiliateProduct(
        id: 'product123',
        name: 'テスト商品',
        description: 'これはテスト商品の説明です',
        price: 5000.0,
        imageUrl: 'https://example.com/image.jpg',
        affiliateUrl: 'https://example.com/affiliate/product123',
        commissionRate: 0.1,
        category: 'テストカテゴリ',
        starId: 'star123',
      );

      // 収益計算
      final revenue = product.calculateRevenue();
      
      // 期待される収益: 5000.0 * 0.1 = 500.0
      expect(revenue, 500.0);
    });

    test('calculateStarShare should return 70% of revenue', () {
      // テスト用のAffiliateProductインスタンス
      final product = AffiliateProduct(
        id: 'product123',
        name: 'テスト商品',
        description: 'これはテスト商品の説明です',
        price: 5000.0,
        imageUrl: 'https://example.com/image.jpg',
        affiliateUrl: 'https://example.com/affiliate/product123',
        commissionRate: 0.1,
        category: 'テストカテゴリ',
        starId: 'star123',
      );

      // スターの取り分計算
      final starShare = product.calculateStarShare();
      
      // 期待されるスターの取り分: 500.0 * 0.7 = 350.0
      expect(starShare, 350.0);
    });

    test('calculatePlatformShare should return 30% of revenue', () {
      // テスト用のAffiliateProductインスタンス
      final product = AffiliateProduct(
        id: 'product123',
        name: 'テスト商品',
        description: 'これはテスト商品の説明です',
        price: 5000.0,
        imageUrl: 'https://example.com/image.jpg',
        affiliateUrl: 'https://example.com/affiliate/product123',
        commissionRate: 0.1,
        category: 'テストカテゴリ',
        starId: 'star123',
      );

      // プラットフォームの取り分計算
      final platformShare = product.calculatePlatformShare();
      
      // 期待されるプラットフォームの取り分: 500.0 * 0.3 = 150.0
      expect(platformShare, 150.0);
    });
  });
}
