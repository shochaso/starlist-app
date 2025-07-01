import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../lib/src/services/admin/user_management_service.dart';
import '../lib/src/services/admin/content_moderation_service.dart';
import '../lib/src/services/admin/analytics_service.dart';
import '../lib/src/services/legal/legal_compliance_service.dart';
import '../lib/src/services/legal/age_verification_service.dart';
import '../lib/src/services/legal/copyright_protection_service.dart';
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
  group('管理・運用機能のサービステスト', () {
    late MockUserManagementRepository userManagementRepository;
    late MockContentModerationRepository contentModerationRepository;
    late MockAnalyticsRepository analyticsRepository;
    late MockLegalComplianceRepository legalComplianceRepository;
    late MockAgeVerificationRepository ageVerificationRepository;
    late MockCopyrightProtectionRepository copyrightProtectionRepository;
    late MockNotificationService notificationService;
    
    setUp(() {
      userManagementRepository = MockUserManagementRepository();
      contentModerationRepository = MockContentModerationRepository();
      analyticsRepository = MockAnalyticsRepository();
      legalComplianceRepository = MockLegalComplianceRepository();
      ageVerificationRepository = MockAgeVerificationRepository();
      copyrightProtectionRepository = MockCopyrightProtectionRepository();
      notificationService = MockNotificationService();
    });
    
    // ユーザー管理サービスのテスト
    group('UserManagementService', () {
      late UserManagementService userManagementService;
      
      setUp(() {
        userManagementService = UserManagementService(
          repository: userManagementRepository,
          notificationService: notificationService,
        );
      });
      
      test('updateUserStatus - ユーザーステータス更新と通知送信', () async {
        // モックの設定
        const userId = 'user123';
        const adminId = 'admin123';
        const reason = 'ガイドライン違反';
        final status = UserAdminStatus.suspended;
        
        final user = User(
          id: userId,
          username: 'testuser',
          email: 'test@example.com',
          createdAt: DateTime.now(),
          isStarCreator: false,
          starRank: StarRank.regular,
        );
        
        final log = UserAdminLog(
          id: 'log123',
          userId: userId,
          adminId: adminId,
          action: UserAdminAction.statusChanged,
          previousState: {'status': 'active'},
          newState: {'status': 'suspended'},
          reason: reason,
          timestamp: DateTime.now(),
        );
        
        final result = UserManagementResult(
          success: true,
          user: user,
          log: log,
        );
        
        // モックの振る舞いを設定
        when(userManagementRepository.updateUserStatus(userId, status, adminId, reason))
            .thenAnswer((_) async => result);
        
        when(notificationService.sendNotification(
          userId: userId,
          title: anyNamed('title'),
          body: anyNamed('body'),
          data: anyNamed('data'),
        )).thenAnswer((_) async => true);
        
        // テスト実行
        final actualResult = await userManagementService.updateUserStatus(userId, status, adminId, reason);
        
        // 検証
        expect(actualResult.success, isTrue);
        expect(actualResult.user, equals(user));
        expect(actualResult.log, equals(log));
        
        // リポジトリメソッドが呼ばれたことを検証
        verify(userManagementRepository.updateUserStatus(userId, status, adminId, reason)).called(1);
        
        // 通知が送信されたことを検証
        verify(notificationService.sendNotification(
          userId: userId,
          title: anyNamed('title'),
          body: anyNamed('body'),
          data: anyNamed('data'),
        )).called(1);
      });
    });
    
    // コンテンツモデレーションサービスのテスト
    group('ContentModerationService', () {
      late ContentModerationService contentModerationService;
      
      setUp(() {
        contentModerationService = ContentModerationService(
          repository: contentModerationRepository,
          notificationService: notificationService,
          userManagementService: UserManagementService(
            repository: userManagementRepository,
            notificationService: notificationService,
          ),
        );
      });
      
      test('approveReport - 報告承認と通知送信', () async {
        // モックの設定
        const reportId = 'report123';
        const moderatorId = 'admin123';
        const note = 'コミュニティガイドライン違反';
        
        final report = ContentReport(
          id: reportId,
          contentId: 'content123',
          reporterId: 'reporter123',
          reason: ContentReportReason.inappropriate,
          status: ContentModerationStatus.approved,
          moderatorId: moderatorId,
          moderatorNote: note,
          createdAt: DateTime.now(),
          resolvedAt: DateTime.now(),
        );
        
        final log = ModerationLog(
          id: 'log123',
          contentId: 'content123',
          reportId: reportId,
          moderatorId: moderatorId,
          action: ModerationAction.remove,
          reason: note,
          timestamp: DateTime.now(),
        );
        
        final result = ModerationResult(
          success: true,
          report: report,
          log: log,
        );
        
        // モックの振る舞いを設定
        when(contentModerationRepository.updateReportStatus(reportId, ContentModerationStatus.approved, moderatorId, note))
            .thenAnswer((_) async => result);
        
        when(contentModerationRepository.performModerationAction(
          any,
          any,
          any,
          any,
        )).thenAnswer((_) async => result);
        
        when(notificationService.sendNotification(
          userId: any,
          title: anyNamed('title'),
          body: anyNamed('body'),
          data: anyNamed('data'),
        )).thenAnswer((_) async => true);
        
        // テスト実行
        final actualResult = await contentModerationService.approveReport(reportId, moderatorId, note);
        
        // 検証
        expect(actualResult.success, isTrue);
        expect(actualResult.report, equals(report));
        
        // リポジトリメソッドが呼ばれたことを検証
        verify(contentModerationRepository.updateReportStatus(reportId, ContentModerationStatus.approved, moderatorId, note)).called(1);
      });
    });
    
    // 統計ダッシュボードサービスのテスト
    group('AnalyticsService', () {
      late AnalyticsService analyticsService;
      
      setUp(() {
        analyticsService = AnalyticsService(
          repository: analyticsRepository,
        );
      });
      
      test('calculatePeriodDates - 期間の開始日と終了日の計算', () {
        // テスト用の参照日
        final referenceDate = DateTime(2025, 3, 15);
        
        // 日次期間のテスト
        final dailyDates = analyticsService.calculatePeriodDates(AnalyticsPeriod.daily, referenceDate: referenceDate);
        expect(dailyDates['startDate'], equals(DateTime(2025, 3, 15)));
        expect(dailyDates['endDate'], equals(DateTime(2025, 3, 15, 23, 59, 59)));
        
        // 週次期間のテスト
        final weeklyDates = analyticsService.calculatePeriodDates(AnalyticsPeriod.weekly, referenceDate: referenceDate);
        // 3月15日は土曜日（weekday=6）、週の開始は月曜日（weekday=1）なので、3月10日から
        expect(weeklyDates['startDate'], equals(DateTime(2025, 3, 10)));
        expect(weeklyDates['endDate'], equals(DateTime(2025, 3, 16, 23, 59, 59)));
        
        // 月次期間のテスト
        final monthlyDates = analyticsService.calculatePeriodDates(AnalyticsPeriod.monthly, referenceDate: referenceDate);
        expect(monthlyDates['startDate'], equals(DateTime(2025, 3, 1)));
        expect(monthlyDates['endDate'], equals(DateTime(2025, 3, 31, 23, 59, 59)));
        
        // 年次期間のテスト
        final yearlyDates = analyticsService.calculatePeriodDates(AnalyticsPeriod.yearly, referenceDate: referenceDate);
        expect(yearlyDates['startDate'], equals(DateTime(2025, 1, 1)));
        expect(yearlyDates['endDate'], equals(DateTime(2025, 12, 31, 23, 59, 59)));
      });
    });
    
    // 法的コンプライアンスサービスのテスト
    group('LegalComplianceService', () {
      late LegalComplianceService legalComplianceService;
      
      setUp(() {
        legalComplianceService = LegalComplianceService(
          repository: legalComplianceRepository,
          notificationService: notificationService,
        );
      });
      
      test('createTermsVersion - 新しい利用規約バージョンの作成', () async {
        // モックの設定
        const version = '1.0';
        const content = '利用規約の内容...';
        final effectiveDate = DateTime(2025, 4, 1);
        
        final termsVersion = TermsVersion(
          id: 'terms123',
          version: version,
          effectiveDate: effectiveDate,
          content: content,
          isCurrent: true,
        );
        
        // モックの振る舞いを設定
        when(legalComplianceRepository.createTermsVersion(any))
            .thenAnswer((_) async => termsVersion);
        
        // テスト実行
        final createdTerms = await legalComplianceService.createTermsVersion(version, content, effectiveDate);
        
        // 検証
        expect(createdTerms.version, equals(version));
        expect(createdTerms.content, equals(content));
        expect(createdTerms.effectiveDate, equals(effectiveDate));
        expect(createdTerms.isCurrent, isTrue);
        
        // リポジトリメソッドが呼ばれたことを検証
        verify(legalComplianceRepository.createTermsVersion(any)).called(1);
      });
    });
    
    // 年齢確認サービスのテスト
    group('AgeVerificationService', () {
      late AgeVerificationService ageVerificationService;
      
      setUp(() {
        ageVerificationService = AgeVerificationService(
          repository: ageVerificationRepository,
          notificationService: notificationService,
        );
      });
      
      test('createSelfDeclarationVerification - 自己申告による年齢確認', () async {
        // モックの設定
        const userId = 'user123';
        final birthDate = DateTime(2000, 1, 1); // 25歳
        
        final verification = AgeVerification(
          id: 'age123',
          userId: userId,
          method: AgeVerificationMethod.selfDeclaration,
          status: AgeVerificationStatus.verified,
          verificationDate: DateTime.now(),
          expirationDate: DateTime.now().add(const Duration(days: 365)),
          verificationData: '{"birthDate": "${birthDate.toIso8601String()}", "age": 25}',
        );
        
        // モックの振る舞いを設定
        when(ageVerificationRepository.createAgeVerification(any))
            .thenAnswer((_) async => verification);
        
        // テスト実行
        final createdVerification = await ageVerificationService.createSelfDeclarationVerification(userId, birthDate);
        
        // 検証
        expect(createdVerification.userId, equals(userId));
        expect(createdVerification.method, equals(AgeVerificationMethod.selfDeclaration));
        expect(createdVerification.status, equals(AgeVerificationStatus.verified));
        expect(createdVerification.expirationDate, isNotNull);
        
        // リポジトリメソッドが呼ばれたことを検証
        verify(ageVerificationRepository.createAgeVerification(any)).called(1);
      });
      
      test('canAccessContent - コンテンツアクセス確認', () async {
        // モックの設定
        const userId = 'user123';
        
        final verification = AgeVerification(
          id: 'age123',
          userId: userId,
          method: AgeVerificationMethod.selfDeclaration,
          status: AgeVerificationStatus.verified,
          verificationDate: DateTime.now(),
          expirationDate: DateTime.now().add(const Duration(days: 365)),
        );
        
        // モックの振る舞いを設定
        when(ageVerificationRepository.getUserAgeVerification(userId))
            .thenAnswer((_) async => verification);
        
        // テスト実行 - 全年齢コンテンツ
        final canAccessGeneral = await ageVerificationService.canAccessContent(userId, ContentAgeRestriction.general);
        expect(canAccessGeneral, isTrue);
        
        // テスト実行 - 成人向けコンテンツ
        final canAccessAdult = await ageVerificationService.canAccessContent(userId, ContentAgeRestriction.adult);
        expect(canAccessAdult, isTrue);
        
        // リポジトリメソッドが呼ばれたことを検証
        verify(ageVerificationRepository.getUserAgeVerification(userId)).called(1);
      });
    });
    
    // 著作権保護サービスのテスト
    group('CopyrightProtectionService', () {
      late CopyrightProtectionService copyrightProtectionService;
      
      setUp(() {
        copyrightProtectionService = CopyrightProtectionService(
          repository: copyrightProtectionRepository,
          notificationService: notificationService,
        );
      });
      
      test('createStandardCopyrightProtection - 標準著作権保護の作成', () async {
        // モックの設定
        const contentId = 'content123';
        const ownerId = 'user123';
        
        final protection = CopyrightProtection(
          id: 'copyright123',
          contentId: contentId,
          ownerId: ownerId,
          protectionType: CopyrightProtectionType.standard,
          fingerprint: 'fingerprint123',
          createdAt: DateTime.now(),
        );
        
        // モックの振る舞いを設定
        when(copyrightProtectionRepository.createCopyrightProtection(any))
            .thenAnswer((_) async => protection);
        
        // テスト実行
        final createdProtection = await copyrightProtectionService.createStandardCopyrightProtection(contentId, ownerId);
        
        // 検証
        expect(createdProtection.contentId, equals(contentId));
        expect(createdProtection.ownerId, equals(ownerId));
        expect(createdProtection.protectionType, equals(CopyrightProtectionType.standard));
        expect(createdProtection.fingerprint, isNotNull);
        
        // リポジトリメソッドが呼ばれたことを検証
        verify(copyrightProtectionRepository.createCopyrightProtection(any)).called(1);
      });
    });
  });
}
