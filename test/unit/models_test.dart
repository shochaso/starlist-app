import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:starlist_app/src/models/user_model.dart';
import 'package:starlist_app/src/models/content_consumption_model.dart';
import 'package:starlist_app/src/models/subscription_model.dart';
import 'package:starlist_app/src/models/fan_star_relationship_model.dart';
import 'package:starlist_app/src/models/transaction_model.dart';

void main() {
  group('User Model Tests', () {
    test('User serialization and deserialization', () {
      final user = User(
        id: 'user123',
        username: 'testuser',
        email: 'test@example.com',
        displayName: 'Test User',
        profileImageUrl: 'https://example.com/profile.jpg',
        bio: 'This is a test user',
        isStarCreator: true,
        followerCount: 1000,
        starRank: StarRank.platinum,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 3, 15),
        socialLinks: {'twitter': '@testuser', 'instagram': '@testuser'},
        preferences: UserPreferences(
          darkMode: true,
          notificationsEnabled: true,
          privacySettings: {'showEmail': false, 'showActivity': true},
          language: 'ja',
        ),
      );

      final json = user.toJson();
      final deserializedUser = User.fromJson(json);

      expect(deserializedUser.id, equals(user.id));
      expect(deserializedUser.username, equals(user.username));
      expect(deserializedUser.email, equals(user.email));
      expect(deserializedUser.displayName, equals(user.displayName));
      expect(deserializedUser.profileImageUrl, equals(user.profileImageUrl));
      expect(deserializedUser.bio, equals(user.bio));
      expect(deserializedUser.isStarCreator, equals(user.isStarCreator));
      expect(deserializedUser.followerCount, equals(user.followerCount));
      expect(deserializedUser.starRank, equals(user.starRank));
      expect(deserializedUser.createdAt, equals(user.createdAt));
      expect(deserializedUser.updatedAt, equals(user.updatedAt));
      expect(deserializedUser.socialLinks, equals(user.socialLinks));
      expect(deserializedUser.preferences?.darkMode, equals(user.preferences?.darkMode));
    });

    test('User revenue share calculation', () {
      final regularUser = User(
        id: 'user1',
        username: 'regular',
        email: 'regular@example.com',
        displayName: 'Regular User',
        starRank: StarRank.regular,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final platinumUser = User(
        id: 'user2',
        username: 'platinum',
        email: 'platinum@example.com',
        displayName: 'Platinum User',
        starRank: StarRank.platinum,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final superUser = User(
        id: 'user3',
        username: 'super',
        email: 'super@example.com',
        displayName: 'Super User',
        starRank: StarRank.super,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(regularUser.getRevenueShare(), equals(0.80));
      expect(platinumUser.getRevenueShare(), equals(0.82));
      expect(superUser.getRevenueShare(), equals(0.85));
    });
  });

  group('Content Consumption Model Tests', () {
    test('ContentConsumption serialization and deserialization', () {
      final content = ContentConsumption(
        id: 'content123',
        userId: 'user123',
        title: 'Test Content',
        description: 'This is a test content',
        category: ContentCategory.food,
        contentData: {
          'restaurant': 'Test Restaurant',
          'dish': 'Test Dish',
          'price': 1500,
        },
        privacyLevel: PrivacyLevel.followers,
        imageUrls: ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'],
        tags: ['food', 'restaurant', 'dinner'],
        location: GeoLocation(
          latitude: 35.6812,
          longitude: 139.7671,
          address: 'Tokyo, Japan',
          placeName: 'Test Restaurant',
        ),
        price: 1500,
        purchaseDate: DateTime(2025, 3, 15),
        createdAt: DateTime(2025, 3, 15, 18, 30),
        updatedAt: DateTime(2025, 3, 15, 18, 30),
        viewCount: 100,
        likeCount: 50,
        commentCount: 10,
      );

      final json = content.toJson();
      final deserializedContent = ContentConsumption.fromJson(json);

      expect(deserializedContent.id, equals(content.id));
      expect(deserializedContent.userId, equals(content.userId));
      expect(deserializedContent.title, equals(content.title));
      expect(deserializedContent.description, equals(content.description));
      expect(deserializedContent.category, equals(content.category));
      expect(deserializedContent.contentData['restaurant'], equals(content.contentData['restaurant']));
      expect(deserializedContent.privacyLevel, equals(content.privacyLevel));
      expect(deserializedContent.imageUrls, equals(content.imageUrls));
      expect(deserializedContent.tags, equals(content.tags));
      expect(deserializedContent.location?.latitude, equals(content.location?.latitude));
      expect(deserializedContent.price, equals(content.price));
      expect(deserializedContent.purchaseDate, equals(content.purchaseDate));
      expect(deserializedContent.createdAt, equals(content.createdAt));
      expect(deserializedContent.updatedAt, equals(content.updatedAt));
      expect(deserializedContent.viewCount, equals(content.viewCount));
      expect(deserializedContent.likeCount, equals(content.likeCount));
      expect(deserializedContent.commentCount, equals(content.commentCount));
    });

    test('ContentConsumption access control', () {
      final content = ContentConsumption(
        id: 'content123',
        userId: 'user123',
        title: 'Test Content',
        category: ContentCategory.food,
        contentData: {'test': 'data'},
        privacyLevel: PrivacyLevel.followers,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 同じユーザーは常にアクセス可能
      expect(content.isAccessibleBy({'id': 'user123'}), isTrue);
      
      // フォロワーはアクセス可能
      expect(content.isAccessibleBy({
        'id': 'follower1',
        'followingIds': ['user123', 'other_user']
      }), isTrue);
      
      // フォロワーでないユーザーはアクセス不可
      expect(content.isAccessibleBy({
        'id': 'non_follower',
        'followingIds': ['other_user']
      }), isFalse);
      
      // プライバシーレベルを変更してテスト
      final publicContent = content.copyWith(privacyLevel: PrivacyLevel.public);
      expect(publicContent.isAccessibleBy({'id': 'anyone'}), isTrue);
      
      final premiumContent = content.copyWith(privacyLevel: PrivacyLevel.premium);
      expect(premiumContent.isAccessibleBy({
        'id': 'premium_user',
        'subscriptionPlan': 'premium'
      }), isTrue);
      expect(premiumContent.isAccessibleBy({
        'id': 'free_user',
        'subscriptionPlan': 'free'
      }), isFalse);
      
      final privateContent = content.copyWith(privacyLevel: PrivacyLevel.private);
      expect(privateContent.isAccessibleBy({'id': 'user123'}), isTrue);
      expect(privateContent.isAccessibleBy({'id': 'other_user'}), isFalse);
    });
  });

  group('Subscription Model Tests', () {
    test('Subscription serialization and deserialization', () {
      final subscription = Subscription(
        id: 'sub123',
        userId: 'user123',
        planType: SubscriptionPlanType.premium,
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 12, 31),
        isAutoRenew: true,
        price: 2980,
        status: SubscriptionStatus.active,
        paymentMethod: PaymentMethod.creditCard,
        lastBillingDate: DateTime(2025, 3, 1),
        nextBillingDate: DateTime(2025, 4, 1),
        discountRate: 0.1,
        discountReason: '年間契約割引',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 3, 1),
      );

      final json = subscription.toJson();
      final deserializedSubscription = Subscription.fromJson(json);

      expect(deserializedSubscription.id, equals(subscription.id));
      expect(deserializedSubscription.userId, equals(subscription.userId));
      expect(deserializedSubscription.planType, equals(subscription.planType));
      expect(deserializedSubscription.startDate, equals(subscription.startDate));
      expect(deserializedSubscription.endDate, equals(subscription.endDate));
      expect(deserializedSubscription.isAutoRenew, equals(subscription.isAutoRenew));
      expect(deserializedSubscription.price, equals(subscription.price));
      expect(deserializedSubscription.status, equals(subscription.status));
      expect(deserializedSubscription.paymentMethod, equals(subscription.paymentMethod));
      expect(deserializedSubscription.lastBillingDate, equals(subscription.lastBillingDate));
      expect(deserializedSubscription.nextBillingDate, equals(subscription.nextBillingDate));
      expect(deserializedSubscription.discountRate, equals(subscription.discountRate));
      expect(deserializedSubscription.discountReason, equals(subscription.discountReason));
      expect(deserializedSubscription.createdAt, equals(subscription.createdAt));
      expect(deserializedSubscription.updatedAt, equals(subscription.updatedAt));
    });

    test('Subscription status and price calculation', () {
      final now = DateTime.now();
      final activeSubscription = Subscription(
        id: 'sub1',
        userId: 'user1',
        planType: SubscriptionPlanType.premium,
        startDate: now.subtract(const Duration(days: 30)),
        endDate: now.add(const Duration(days: 30)),
        isAutoRenew: true,
        price: 2980,
        status: SubscriptionStatus.active,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 30)),
      );

      final expiredSubscription = Subscription(
        id: 'sub2',
        userId: 'user2',
        planType: SubscriptionPlanType.standard,
        startDate: now.subtract(const Duration(days: 60)),
        endDate: now.subtract(const Duration(days: 30)),
        isAutoRenew: false,
        price: 1980,
        status: SubscriptionStatus.expired,
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 30)),
      );

      final discountedSubscription = Subscription(
        id: 'sub3',
        userId: 'user3',
        planType: SubscriptionPlanType.premium,
        startDate: now.subtract(const Duration(days: 30)),
        endDate: now.add(const Duration(days: 335)),
        isAutoRenew: true,
        price: 2980,
        status: SubscriptionStatus.active,
        discountRate: 0.2,
        discountReason: '年間契約割引',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 30)),
      );

      expect(activeSubscription.isActive(), isTrue);
      expect(expiredSubscription.isActive(), isFalse);
      expect(activeSubscription.daysUntilExpiration(), equals(30));
      expect(expiredSubscription.daysUntilExpiration(), equals(0));
      expect(activeSubscription.calculateMonthlyPrice(), equals(2980));
      expect(discountedSubscription.calculateMonthlyPrice(), equals(2384)); // 2980 * 0.8
    });
  });

  group('FanStarRelationship Model Tests', () {
    test('FanStarRelationship serialization and deserialization', () {
      final relationship = FanStarRelationship(
        id: 'rel123',
        fanId: 'fan123',
        starId: 'star123',
        relationshipType: RelationshipType.premium,
        startDate: DateTime(2025, 1, 1),
        lastInteractionDate: DateTime(2025, 3, 15),
        totalSpent: 15000,
        ticketBalance: {
          'bronze': 5,
          'silver': 2,
        },
        badges: [
          Badge(
            id: 'badge1',
            name: 'ロイヤルファン',
            description: '1年以上の継続支援',
            iconUrl: 'https://example.com/badge1.png',
            acquiredAt: DateTime(2025, 1, 1),
          ),
          Badge(
            id: 'badge2',
            name: 'トップサポーター',
            description: '累計10,000円以上の支援',
            iconUrl: 'https://example.com/badge2.png',
            acquiredAt: DateTime(2025, 2, 15),
          ),
        ],
        notes: 'VIPファン',
        isNotificationEnabled: true,
        customSettings: {'favoriteContent': 'food'},
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 3, 15),
      );

      final json = relationship.toJson();
      final deserializedRelationship = FanStarRelationship.fromJson(json);

      expect(deserializedRelationship.id, equals(relationship.id));
      expect(deserializedRelationship.fanId, equals(relationship.fanId));
      expect(deserializedRelationship.starId, equals(relationship.starId));
      expect(deserializedRelationship.relationshipType, equals(relationship.relationshipType));
      expect(deserializedRelationship.startDate, equals(relationship.startDate));
      expect(deserializedRelationship.lastInteractionDate, equals(relationship.lastInteractionDate));
      expect(deserializedRelationship.totalSpent, equals(relationship.totalSpent));
      expect(deserializedRelationship.ticketBalance, equals(relationship.ticketBalance));
      expect(deserializedRelationship.badges?.length, equals(relationship.badges?.length));
      expect(deserializedRelationship.badges?[0].name, equals(relationship.badges?[0].name));
      expect(deserializedRelationship.notes, equals(relationship.notes));
      expect(deserializedRelationship.isNotificationEnabled, equals(relationship.isNotificationEnabled));
      expect(deserializedRelationship.customSettings, equals(relationship.customSettings));
      expect(deserializedRelationship.createdAt, equals(relationship.createdAt));
      expect(deserializedRelationship.updatedAt, equals(relationship.updatedAt));
    });

    test('FanStarRelationship ticket management', () {
      final relationship = FanStarRelationship(
        id: 'rel123',
        fanId: 'fan123',
        starId: 'star123',
        relationshipType: RelationshipType.standard,
        startDate: DateTime(2025, 1, 1),
        ticketBalance: {
          'bronze': 3,
          'silver': 1,
        },
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 3, 15),
      );

      // チケット追加テスト
      relationship.addTickets('bronze', 2);
      expect(relationship.ticketBalance['bronze'], equals(5));

      relationship.addTickets('silver', 3);
      expect(relationship.ticketBalance['silver'], equals(4));

      // 新しいタイプのチケット追加
      relationship.addTickets('gold', 1);
      expect(relationship.ticketBalance['gold'], equals(1));

      // チケット使用テスト
      expect(relationship.useTickets('bronze', 2), isTrue);
      expect(relationship.ticketBalance['bronze'], equals(3));

      // 残高不足の場合
      expect(relationship.useTickets('silver', 5), isFalse);
      expect(relationship.ticketBalance['silver'], equals(4)); // 変更なし

      // 存在しないチケットタイプ
      expect(relationship.useTickets('platinum', 1), isFalse);
    });
  });

  group('Transaction Model Tests', () {
    test('Transaction serialization and deserialization', () {
      final transaction = Transaction(
        id: 'tx123',
        userId: 'user123',
        targetId: 'star123',
        amount: 1500,
        currency: 'JPY',
        type: TransactionType.donation,
        status: TransactionStatus.completed,
        paymentMethod: 'creditCard',
        description: 'ライブ配信への投げ銭',
        metadata: {'liveId': 'live123', 'message': 'いつも応援しています！'},
        receiptUrl: 'https://example.com/receipt123.pdf',
        createdAt: DateTime(2025, 3, 15, 20, 30),
        updatedAt: DateTime(2025, 3, 15, 20, 30),
      );

      final json = transaction.toJson();
      final deserializedTransaction = Transaction.fromJson(json);

      expect(deserializedTransaction.id, equals(transaction.id));
      expect(deserializedTransaction.userId, equals(transaction.userId));
      expect(deserializedTransaction.targetId, equals(transaction.targetId));
      expect(deserializedTransaction.amount, equals(transaction.amount));
      expect(deserializedTransaction.currency, equals(transaction.currency));
      expect(deserializedTransaction.type, equals(transaction.type));
      expect(deserializedTransaction.status, equals(transaction.status));
      expect(deserializedTransaction.paymentMethod, equals(transaction.paymentMethod));
      expect(deserializedTransaction.description, equals(transaction.description));
      expect(deserializedTransaction.metadata?['liveId'], equals(transaction.metadata?['liveId']));
      expect(deserializedTransaction.receiptUrl, equals(transaction.receiptUrl));
      expect(deserializedTransaction.createdAt, equals(transaction.createdAt));
      expect(deserializedTransaction.updatedAt, equals(transaction.updatedAt));
    });

    test('Transaction status and formatting', () {
      final completedTransaction = Transaction(
        id: 'tx1',
        userId: 'user1',
        amount: 1500,
        currency: 'JPY',
        type: TransactionType.ticket,
        status: TransactionStatus.completed,
        paymentMethod: 'creditCard',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final pendingTransaction = Transaction(
        id: 'tx2',
        userId: 'user2',
        amount: 29.99,
        currency: 'USD',
        type: TransactionType.subscription,
        status: TransactionStatus.pending,
        paymentMethod: 'paypal',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final euroTransaction = Transaction(
        id: 'tx3',
        userId: 'user3',
        amount: 19.99,
        currency: 'EUR',
        type: TransactionType.subscription,
        status: TransactionStatus.completed,
        paymentMethod: 'creditCard',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(completedTransaction.isSuccessful(), isTrue);
      expect(pendingTransaction.isSuccessful(), isFalse);
      
      expect(completedTransaction.getFormattedAmount(), equals('¥1,500'));
      expect(pendingTransaction.getFormattedAmount(), equals('\$29.99'));
      expect(euroTransaction.getFormattedAmount(), equals('€19.99'));
    });
  });

  group('Model Integration Tests', () {
    test('User and ContentConsumption relationship', () {
      final user = User(
        id: 'user123',
        username: 'testuser',
        email: 'test@example.com',
        displayName: 'Test User',
        isStarCreator: true,
        starRank: StarRank.platinum,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final content = ContentConsumption(
        id: 'content123',
        userId: user.id, // ユーザーIDで関連付け
        title: 'Test Content',
        category: ContentCategory.food,
        contentData: {'test': 'data'},
        privacyLevel: PrivacyLevel.public,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(content.userId, equals(user.id));
    });

    test('User and Subscription relationship', () {
      final user = User(
        id: 'user123',
        username: 'testuser',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final subscription = Subscription(
        id: 'sub123',
        userId: user.id, // ユーザーIDで関連付け
        planType: SubscriptionPlanType.premium,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        isAutoRenew: true,
        price: 2980,
        status: SubscriptionStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(subscription.userId, equals(user.id));
    });

    test('Fan and Star relationship', () {
      final fan = User(
        id: 'fan123',
        username: 'fan',
        email: 'fan@example.com',
        displayName: 'Fan User',
        isStarCreator: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final star = User(
        id: 'star123',
        username: 'star',
        email: 'star@example.com',
        displayName: 'Star User',
        isStarCreator: true,
        starRank: StarRank.platinum,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final relationship = FanStarRelationship(
        id: 'rel123',
        fanId: fan.id, // ファンIDで関連付け
        starId: star.id, // スターIDで関連付け
        relationshipType: RelationshipType.premium,
        startDate: DateTime.now(),
        ticketBalance: {'bronze': 5, 'silver': 2},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(relationship.fanId, equals(fan.id));
      expect(relationship.starId, equals(star.id));
    });

    test('User and Transaction relationship', () {
      final user = User(
        id: 'user123',
        username: 'testuser',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final star = User(
        id: 'star123',
        username: 'star',
        email: 'star@example.com',
        displayName: 'Star User',
        isStarCreator: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final transaction = Transaction(
        id: 'tx123',
        userId: user.id, // ユーザーIDで関連付け
        targetId: star.id, // スターIDで関連付け
        amount: 1000,
        currency: 'JPY',
        type: TransactionType.donation,
        status: TransactionStatus.completed,
        paymentMethod: 'creditCard',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(transaction.userId, equals(user.id));
      expect(transaction.targetId, equals(star.id));
    });
  });
}
