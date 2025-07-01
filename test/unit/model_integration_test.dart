import 'package:flutter_test/flutter_test.dart';
import '../lib/src/models/user_model.dart';
import '../lib/src/models/content_consumption_model.dart';
import '../lib/src/models/subscription_model.dart';
import '../lib/src/models/fan_star_relationship_model.dart';
import '../lib/src/models/transaction_model.dart';
import '../lib/src/models/admin/user_management_model.dart';
import '../lib/src/models/admin/content_moderation_model.dart';
import '../lib/src/models/legal/legal_compliance_model.dart';
import '../lib/src/services/integration/model_integration_service.dart';

void main() {
  group('ModelIntegrationService', () {
    late ModelIntegrationService integrationService;
    
    setUp(() {
      integrationService = ModelIntegrationService();
    });
    
    group('ユーザー管理統合', () {
      test('getUserAdminStatus - ユーザーの管理ステータスを正しく取得', () {
        // アクティブユーザー
        final activeUser = User(
          id: 'user1',
          username: 'activeuser',
          email: 'active@example.com',
          createdAt: DateTime.now(),
          isStarCreator: false,
          starRank: StarRank.regular,
          isSuspended: false,
          isUnderReview: false,
          isDeleted: false,
        );
        
        // 一時停止ユーザー
        final suspendedUser = User(
          id: 'user2',
          username: 'suspendeduser',
          email: 'suspended@example.com',
          createdAt: DateTime.now(),
          isStarCreator: false,
          starRank: StarRank.regular,
          isSuspended: true,
          isUnderReview: false,
          isDeleted: false,
        );
        
        // 審査中ユーザー
        final reviewUser = User(
          id: 'user3',
          username: 'reviewuser',
          email: 'review@example.com',
          createdAt: DateTime.now(),
          isStarCreator: false,
          starRank: StarRank.regular,
          isSuspended: false,
          isUnderReview: true,
          isDeleted: false,
        );
        
        // 削除済みユーザー
        final deletedUser = User(
          id: 'user4',
          username: 'deleteduser',
          email: 'deleted@example.com',
          createdAt: DateTime.now(),
          isStarCreator: false,
          starRank: StarRank.regular,
          isSuspended: false,
          isUnderReview: false,
          isDeleted: true,
        );
        
        expect(integrationService.getUserAdminStatus(activeUser), equals(UserAdminStatus.active));
        expect(integrationService.getUserAdminStatus(suspendedUser), equals(UserAdminStatus.suspended));
        expect(integrationService.getUserAdminStatus(reviewUser), equals(UserAdminStatus.underReview));
        expect(integrationService.getUserAdminStatus(deletedUser), equals(UserAdminStatus.deleted));
      });
      
      test('applyAdminStatusToUser - 管理ステータスをユーザーに正しく適用', () {
        // 基本ユーザー
        final baseUser = User(
          id: 'user1',
          username: 'testuser',
          email: 'test@example.com',
          createdAt: DateTime.now(),
          isStarCreator: false,
          starRank: StarRank.regular,
          isSuspended: false,
          isUnderReview: false,
          isDeleted: false,
        );
        
        // 一時停止ステータスを適用
        final suspendedUser = integrationService.applyAdminStatusToUser(baseUser, UserAdminStatus.suspended);
        expect(suspendedUser.isSuspended, isTrue);
        expect(suspendedUser.isUnderReview, isFalse);
        expect(suspendedUser.isDeleted, isFalse);
        
        // 審査中ステータスを適用
        final reviewUser = integrationService.applyAdminStatusToUser(baseUser, UserAdminStatus.underReview);
        expect(reviewUser.isSuspended, isFalse);
        expect(reviewUser.isUnderReview, isTrue);
        expect(reviewUser.isDeleted, isFalse);
        
        // 削除済みステータスを適用
        final deletedUser = integrationService.applyAdminStatusToUser(baseUser, UserAdminStatus.deleted);
        expect(deletedUser.isDeleted, isTrue);
      });
    });
    
    group('コンテンツモデレーション統合', () {
      test('getContentModerationStatus - コンテンツのモデレーションステータスを正しく取得', () {
        // 承認済みコンテンツ
        final approvedContent = ContentConsumption(
          id: 'content1',
          userId: 'user1',
          category: ConsumptionCategory.youtube,
          title: '承認済みコンテンツ',
          privacyLevel: PrivacyLevel.public,
          createdAt: DateTime.now(),
          isPending: false,
          isRejected: false,
          isRemoved: false,
          isAutoFlagged: false,
        );
        
        // 審査中コンテンツ
        final pendingContent = ContentConsumption(
          id: 'content2',
          userId: 'user1',
          category: ConsumptionCategory.youtube,
          title: '審査中コンテンツ',
          privacyLevel: PrivacyLevel.public,
          createdAt: DateTime.now(),
          isPending: true,
          isRejected: false,
          isRemoved: false,
          isAutoFlagged: false,
        );
        
        // 拒否されたコンテンツ
        final rejectedContent = ContentConsumption(
          id: 'content3',
          userId: 'user1',
          category: ConsumptionCategory.youtube,
          title: '拒否されたコンテンツ',
          privacyLevel: PrivacyLevel.public,
          createdAt: DateTime.now(),
          isPending: false,
          isRejected: true,
          isRemoved: false,
          isAutoFlagged: false,
        );
        
        expect(integrationService.getContentModerationStatus(approvedContent), equals(ContentModerationStatus.approved));
        expect(integrationService.getContentModerationStatus(pendingContent), equals(ContentModerationStatus.pending));
        expect(integrationService.getContentModerationStatus(rejectedContent), equals(ContentModerationStatus.rejected));
      });
      
      test('applyModerationStatusToContent - モデレーションステータスをコンテンツに正しく適用', () {
        // 基本コンテンツ
        final baseContent = ContentConsumption(
          id: 'content1',
          userId: 'user1',
          category: ConsumptionCategory.youtube,
          title: 'テストコンテンツ',
          privacyLevel: PrivacyLevel.public,
          createdAt: DateTime.now(),
          isPending: false,
          isRejected: false,
          isRemoved: false,
          isAutoFlagged: false,
        );
        
        // 審査中ステータスを適用
        final pendingContent = integrationService.applyModerationStatusToContent(baseContent, ContentModerationStatus.pending);
        expect(pendingContent.isPending, isTrue);
        expect(pendingContent.isRejected, isFalse);
        expect(pendingContent.isRemoved, isFalse);
        
        // 拒否ステータスを適用
        final rejectedContent = integrationService.applyModerationStatusToContent(baseContent, ContentModerationStatus.rejected);
        expect(rejectedContent.isPending, isFalse);
        expect(rejectedContent.isRejected, isTrue);
        expect(rejectedContent.isRemoved, isFalse);
        
        // 削除ステータスを適用
        final removedContent = integrationService.applyModerationStatusToContent(baseContent, ContentModerationStatus.removed);
        expect(removedContent.isPending, isFalse);
        expect(removedContent.isRejected, isFalse);
        expect(removedContent.isRemoved, isTrue);
      });
    });
    
    group('収益分析統合', () {
      test('getRevenueAnalyticsFromSubscription - サブスクリプションから収益分析データを正しく取得', () {
        final subscriptions = [
          Subscription(
            id: 'sub1',
            userId: 'user1',
            planType: PlanType.free,
            startDate: DateTime.now(),
            monthlyPrice: 0,
            isActive: true,
          ),
          Subscription(
            id: 'sub2',
            userId: 'user2',
            planType: PlanType.light,
            startDate: DateTime.now(),
            monthlyPrice: 980,
            isActive: true,
          ),
          Subscription(
            id: 'sub3',
            userId: 'user3',
            planType: PlanType.standard,
            startDate: DateTime.now(),
            monthlyPrice: 1980,
            isActive: true,
          ),
          Subscription(
            id: 'sub4',
            userId: 'user4',
            planType: PlanType.premium,
            startDate: DateTime.now(),
            monthlyPrice: 2980,
            isActive: true,
          ),
        ];
        
        final analytics = integrationService.getRevenueAnalyticsFromSubscription(subscriptions);
        
        expect(analytics['totalRevenue'], equals(0 + 980 + 1980 + 2980));
        expect(analytics['revenueByPlan']['free'], equals(0));
        expect(analytics['revenueByPlan']['light'], equals(980));
        expect(analytics['revenueByPlan']['standard'], equals(1980));
        expect(analytics['revenueByPlan']['premium'], equals(2980));
        expect(analytics['averageRevenuePerUser'], equals((0 + 980 + 1980 + 2980) / 4));
      });
      
      test('getRevenueAnalyticsFromTransactions - トランザクションから収益分析データを正しく取得', () {
        final transactions = [
          Transaction(
            id: 'trans1',
            userId: 'user1',
            type: TransactionType.subscription,
            amount: 1980,
            currency: 'JPY',
            status: TransactionStatus.completed,
            createdAt: DateTime.now(),
          ),
          Transaction(
            id: 'trans2',
            userId: 'user2',
            type: TransactionType.ticket,
            amount: 500,
            currency: 'JPY',
            status: TransactionStatus.completed,
            createdAt: DateTime.now(),
          ),
          Transaction(
            id: 'trans3',
            userId: 'user3',
            type: TransactionType.donation,
            amount: 1000,
            currency: 'JPY',
            status: TransactionStatus.completed,
            createdAt: DateTime.now(),
          ),
          Transaction(
            id: 'trans4',
            userId: 'user4',
            type: TransactionType.refund,
            amount: 500,
            currency: 'JPY',
            status: TransactionStatus.completed,
            createdAt: DateTime.now(),
          ),
        ];
        
        final analytics = integrationService.getRevenueAnalyticsFromTransactions(transactions);
        
        expect(analytics['totalRevenue'], equals(1980 + 500 + 1000 - 500));
        expect(analytics['subscriptionRevenue'], equals(1980));
        expect(analytics['ticketRevenue'], equals(500));
        expect(analytics['donationRevenue'], equals(1000));
      });
    });
    
    group('法的コンプライアンス統合', () {
      test('applyTermsConsentToUser - 利用規約同意情報をユーザーに正しく適用', () {
        // 基本ユーザー
        final baseUser = User(
          id: 'user1',
          username: 'testuser',
          email: 'test@example.com',
          createdAt: DateTime.now(),
          isStarCreator: false,
          starRank: StarRank.regular,
          termsAccepted: false,
        );
        
        const termsVersion = '1.0';
        final consentDate = DateTime.now();
        
        // 利用規約同意情報を適用
        final updatedUser = integrationService.applyTermsConsentToUser(baseUser, termsVersion, consentDate);
        
        expect(updatedUser.termsAccepted, isTrue);
        expect(updatedUser.termsVersion, equals(termsVersion));
        expect(updatedUser.termsAcceptedAt, equals(consentDate));
      });
      
      test('applyAgeRestrictionToContent - 年齢制限をコンテンツに正しく適用', () {
        // 基本コンテンツ
        final baseContent = ContentConsumption(
          id: 'content1',
          userId: 'user1',
          category: ConsumptionCategory.youtube,
          title: 'テストコンテンツ',
          privacyLevel: PrivacyLevel.public,
          createdAt: DateTime.now(),
        );
        
        // 成人向け制限を適用
        final adultContent = integrationService.applyAgeRestrictionToContent(baseContent, ContentAgeRestriction.adult);
        
        expect(adultContent.ageRestriction, equals('adult'));
      });
    });
  });
}
