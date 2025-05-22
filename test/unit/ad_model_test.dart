import 'package:flutter_test/flutter_test.dart';
import 'package:starlist_improved/src/features/monetization/models/ad_model.dart';

void main() {
  group('AdModel', () {
    test('fromJson should correctly parse JSON data', () {
      // テスト用のモックデータ
      final json = {
        'id': 'ad123',
        'title': 'テスト広告',
        'description': 'これはテスト広告の説明です',
        'imageUrl': 'https://example.com/ad.jpg',
        'targetUrl': 'https://example.com/landing',
        'advertiserName': 'テスト広告主',
        'type': 'banner',
        'size': 'medium',
        'targetUserTypes': ['free', 'standard'],
        'cpmRate': 300.0,
        'cpcRate': 50.0,
      };

      // モデルに変換
      final ad = AdModel.fromJson(json);

      // 各フィールドが正しく変換されているか検証
      expect(ad.id, 'ad123');
      expect(ad.title, 'テスト広告');
      expect(ad.description, 'これはテスト広告の説明です');
      expect(ad.imageUrl, 'https://example.com/ad.jpg');
      expect(ad.targetUrl, 'https://example.com/landing');
      expect(ad.advertiserName, 'テスト広告主');
      expect(ad.type, AdType.banner);
      expect(ad.size, AdSize.medium);
      expect(ad.targetUserTypes, ['free', 'standard']);
      expect(ad.cpmRate, 300.0);
      expect(ad.cpcRate, 50.0);
    });

    test('toJson should correctly convert to JSON format', () {
      // テスト用のAdModelインスタンス
      final ad = AdModel(
        id: 'ad123',
        title: 'テスト広告',
        description: 'これはテスト広告の説明です',
        imageUrl: 'https://example.com/ad.jpg',
        targetUrl: 'https://example.com/landing',
        advertiserName: 'テスト広告主',
        type: AdType.banner,
        size: AdSize.medium,
        targetUserTypes: ['free', 'standard'],
        cpmRate: 300.0,
        cpcRate: 50.0,
      );

      // JSONに変換
      final json = ad.toJson();

      // 各フィールドが正しく変換されているか検証
      expect(json['id'], 'ad123');
      expect(json['title'], 'テスト広告');
      expect(json['description'], 'これはテスト広告の説明です');
      expect(json['imageUrl'], 'https://example.com/ad.jpg');
      expect(json['targetUrl'], 'https://example.com/landing');
      expect(json['advertiserName'], 'テスト広告主');
      expect(json['type'], 'banner');
      expect(json['size'], 'medium');
      expect(json['targetUserTypes'], ['free', 'standard']);
      expect(json['cpmRate'], 300.0);
      expect(json['cpcRate'], 50.0);
    });

    test('shouldShowToUserType should return correct boolean value', () {
      // テスト用のAdModelインスタンス
      final ad = AdModel(
        id: 'ad123',
        title: 'テスト広告',
        description: 'これはテスト広告の説明です',
        imageUrl: 'https://example.com/ad.jpg',
        targetUrl: 'https://example.com/landing',
        advertiserName: 'テスト広告主',
        type: AdType.banner,
        size: AdSize.medium,
        targetUserTypes: ['free', 'standard'],
        cpmRate: 300.0,
        cpcRate: 50.0,
      );

      // ユーザータイプに基づく表示判定
      expect(ad.shouldShowToUserType('free'), true);
      expect(ad.shouldShowToUserType('standard'), true);
      expect(ad.shouldShowToUserType('premium'), false);
      expect(ad.shouldShowToUserType('star'), false);
    });

    test('calculateImpressionRevenue should return correct revenue', () {
      // テスト用のAdModelインスタンス
      final ad = AdModel(
        id: 'ad123',
        title: 'テスト広告',
        description: 'これはテスト広告の説明です',
        imageUrl: 'https://example.com/ad.jpg',
        targetUrl: 'https://example.com/landing',
        advertiserName: 'テスト広告主',
        type: AdType.banner,
        size: AdSize.medium,
        targetUserTypes: ['free', 'standard'],
        cpmRate: 300.0,
        cpcRate: 50.0,
      );

      // インプレッション収益計算
      final revenue = ad.calculateImpressionRevenue(1000);
      
      // 期待される収益: 300.0 * 1000 / 1000 = 300.0
      expect(revenue, 300.0);
    });

    test('calculateClickRevenue should return correct revenue', () {
      // テスト用のAdModelインスタンス
      final ad = AdModel(
        id: 'ad123',
        title: 'テスト広告',
        description: 'これはテスト広告の説明です',
        imageUrl: 'https://example.com/ad.jpg',
        targetUrl: 'https://example.com/landing',
        advertiserName: 'テスト広告主',
        type: AdType.banner,
        size: AdSize.medium,
        targetUserTypes: ['free', 'standard'],
        cpmRate: 300.0,
        cpcRate: 50.0,
      );

      // クリック収益計算
      final revenue = ad.calculateClickRevenue(10);
      
      // 期待される収益: 50.0 * 10 = 500.0
      expect(revenue, 500.0);
    });

    test('UserType constants should have correct values', () {
      expect(UserType.free, 'free');
      expect(UserType.standard, 'standard');
      expect(UserType.premium, 'premium');
      expect(UserType.star, 'star');
    });
  });
}
