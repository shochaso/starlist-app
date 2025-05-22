import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../lib/src/models/admin/user_management_model.dart';
import '../lib/src/models/admin/content_moderation_model.dart';
import '../lib/src/models/admin/analytics_model.dart';
import '../lib/src/models/legal/legal_compliance_model.dart';

// モックリポジトリクラス
class MockUserManagementRepository extends Mock {}
class MockContentModerationRepository extends Mock {}
class MockAnalyticsRepository extends Mock {}
class MockLegalComplianceRepository extends Mock {}
class MockAgeVerificationRepository extends Mock {}
class MockCopyrightProtectionRepository extends Mock {}
class MockNotificationService extends Mock {}

void main() {
  group('管理・運用機能のテスト', () {
    // ユーザー管理モデルのテスト
    group('ユーザー管理モデル', () {
      test('UserAdminLog - JSONシリアライズ/デシリアライズ', () {
        final log = UserAdminLog(
          id: 'log123',
          userId: 'user123',
          adminId: 'admin123',
          action: UserAdminAction.statusChanged,
          previousState: {'status': 'active'},
          newState: {'status': 'suspended'},
          reason: 'ガイドライン違反',
          timestamp: DateTime(2025, 3, 27),
        );
        
        final json = log.toJson();
        final fromJson = UserAdminLog.fromJson(json);
        
        expect(fromJson.id, equals(log.id));
        expect(fromJson.userId, equals(log.userId));
        expect(fromJson.adminId, equals(log.adminId));
        expect(fromJson.action, equals(log.action));
        expect(fromJson.reason, equals(log.reason));
        expect(fromJson.timestamp, equals(log.timestamp));
      });
      
      test('UserSearchFilter - copyWith', () {
        final filter = UserSearchFilter(
          username: 'test',
          email: 'test@example.com',
        );
        
        final updated = filter.copyWith(
          isStarCreator: true,
          starRank: StarRank.platinum,
        );
        
        expect(updated.username, equals('test'));
        expect(updated.email, equals('test@example.com'));
        expect(updated.isStarCreator, isTrue);
        expect(updated.starRank, equals(StarRank.platinum));
      });
    });
    
    // コンテンツモデレーションモデルのテスト
    group('コンテンツモデレーションモデル', () {
      test('ContentReport - JSONシリアライズ/デシリアライズ', () {
        final report = ContentReport(
          id: 'report123',
          contentId: 'content123',
          reporterId: 'user123',
          reason: ContentReportReason.inappropriate,
          description: '不適切なコンテンツです',
          status: ContentModerationStatus.pending,
          createdAt: DateTime(2025, 3, 27),
        );
        
        final json = report.toJson();
        final fromJson = ContentReport.fromJson(json);
        
        expect(fromJson.id, equals(report.id));
        expect(fromJson.contentId, equals(report.contentId));
        expect(fromJson.reporterId, equals(report.reporterId));
        expect(fromJson.reason, equals(report.reason));
        expect(fromJson.description, equals(report.description));
        expect(fromJson.status, equals(report.status));
        expect(fromJson.createdAt, equals(report.createdAt));
      });
      
      test('ModerationResult - 成功/失敗ファクトリメソッド', () {
        final successResult = ModerationResult.success(
          report: ContentReport(
            id: 'report123',
            contentId: 'content123',
            reporterId: 'user123',
            reason: ContentReportReason.inappropriate,
            status: ContentModerationStatus.approved,
            createdAt: DateTime(2025, 3, 27),
          ),
        );
        
        final failureResult = ModerationResult.failure('エラーが発生しました');
        
        expect(successResult.success, isTrue);
        expect(successResult.report, isNotNull);
        
        expect(failureResult.success, isFalse);
        expect(failureResult.errorMessage, equals('エラーが発生しました'));
      });
    });
    
    // 統計ダッシュボードモデルのテスト
    group('統計ダッシュボードモデル', () {
      test('DashboardAnalytics - JSONシリアライズ/デシリアライズ', () {
        final userAnalytics = UserAnalytics(
          totalUsers: 1000,
          newUsers: 50,
          activeUsers: 500,
          starCreators: 100,
          usersByPlan: {'free': 500, 'premium': 500},
          usersByRegion: {'japan': 800, 'other': 200},
          retentionRate: 0.8,
          churnRate: 0.2,
        );
        
        final revenueAnalytics = RevenueAnalytics(
          totalRevenue: 1000000,
          subscriptionRevenue: 800000,
          ticketRevenue: 150000,
          donationRevenue: 50000,
          revenueByPlan: {'free': 0, 'premium': 1000000},
          revenueByRegion: {'japan': 800000, 'other': 200000},
          averageRevenuePerUser: 1000,
          monthOverMonthGrowth: 0.05,
        );
        
        final contentAnalytics = ContentAnalytics(
          totalContent: 5000,
          newContent: 200,
          contentByCategory: {'video': 3000, 'audio': 2000},
          contentByPrivacyLevel: {'public': 4000, 'private': 1000},
          averageViewsPerContent: 500,
          averageLikesPerContent: 50,
          averageCommentsPerContent: 10,
          topPerformingContent: ['content1', 'content2', 'content3'],
        );
        
        final systemAnalytics = SystemAnalytics(
          averageResponseTime: 0.2,
          totalApiCalls: 1000000,
          errorCount: 1000,
          serverUptime: 0.999,
          apiCallsByEndpoint: {'users': 500000, 'content': 500000},
          errorsByType: {'404': 500, '500': 500},
        );
        
        final dashboardAnalytics = DashboardAnalytics(
          userAnalytics: userAnalytics,
          revenueAnalytics: revenueAnalytics,
          contentAnalytics: contentAnalytics,
          systemAnalytics: systemAnalytics,
          generatedAt: DateTime(2025, 3, 27),
          period: AnalyticsPeriod.monthly,
          startDate: DateTime(2025, 3, 1),
          endDate: DateTime(2025, 3, 31),
        );
        
        final json = dashboardAnalytics.toJson();
        final fromJson = DashboardAnalytics.fromJson(json);
        
        expect(fromJson.userAnalytics.totalUsers, equals(userAnalytics.totalUsers));
        expect(fromJson.revenueAnalytics.totalRevenue, equals(revenueAnalytics.totalRevenue));
        expect(fromJson.contentAnalytics.totalContent, equals(contentAnalytics.totalContent));
        expect(fromJson.systemAnalytics.totalApiCalls, equals(systemAnalytics.totalApiCalls));
        expect(fromJson.period, equals(dashboardAnalytics.period));
        expect(fromJson.startDate, equals(dashboardAnalytics.startDate));
        expect(fromJson.endDate, equals(dashboardAnalytics.endDate));
      });
    });
    
    // 法的コンプライアンスモデルのテスト
    group('法的コンプライアンスモデル', () {
      test('TermsVersion - JSONシリアライズ/デシリアライズ', () {
        final terms = TermsVersion(
          id: 'terms123',
          version: '1.0',
          effectiveDate: DateTime(2025, 3, 27),
          content: '利用規約の内容...',
          isCurrent: true,
        );
        
        final json = terms.toJson();
        final fromJson = TermsVersion.fromJson(json);
        
        expect(fromJson.id, equals(terms.id));
        expect(fromJson.version, equals(terms.version));
        expect(fromJson.effectiveDate, equals(terms.effectiveDate));
        expect(fromJson.content, equals(terms.content));
        expect(fromJson.isCurrent, equals(terms.isCurrent));
      });
      
      test('AgeVerification - copyWith', () {
        final verification = AgeVerification(
          id: 'age123',
          userId: 'user123',
          method: AgeVerificationMethod.selfDeclaration,
          status: AgeVerificationStatus.pending,
        );
        
        final updated = verification.copyWith(
          status: AgeVerificationStatus.verified,
          verificationDate: DateTime(2025, 3, 27),
        );
        
        expect(updated.id, equals(verification.id));
        expect(updated.userId, equals(verification.userId));
        expect(updated.method, equals(verification.method));
        expect(updated.status, equals(AgeVerificationStatus.verified));
        expect(updated.verificationDate, equals(DateTime(2025, 3, 27)));
      });
      
      test('CopyrightProtection - JSONシリアライズ/デシリアライズ', () {
        final protection = CopyrightProtection(
          id: 'copyright123',
          contentId: 'content123',
          ownerId: 'user123',
          protectionType: CopyrightProtectionType.standard,
          fingerprint: 'fingerprint123',
          createdAt: DateTime(2025, 3, 27),
        );
        
        final json = protection.toJson();
        final fromJson = CopyrightProtection.fromJson(json);
        
        expect(fromJson.id, equals(protection.id));
        expect(fromJson.contentId, equals(protection.contentId));
        expect(fromJson.ownerId, equals(protection.ownerId));
        expect(fromJson.protectionType, equals(protection.protectionType));
        expect(fromJson.fingerprint, equals(protection.fingerprint));
        expect(fromJson.createdAt, equals(protection.createdAt));
      });
    });
  });
}
