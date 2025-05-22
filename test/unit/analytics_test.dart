import 'package:flutter_test/flutter_test.dart';
import 'package:starlist_implementation/src/features/user_experience/analytics/models/analytics_models.dart';
import 'package:starlist_implementation/src/features/user_experience/analytics/services/analytics_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  group('データ分析と統計機能のテスト', () {
    late AnalyticsService analyticsService;
    
    setUp(() {
      analyticsService = AnalyticsService();
    });
    
    test('ファン分析データが正しく取得できること', () async {
      final analytics = await analyticsService.getFanAnalytics('star_1');
      
      expect(analytics, isNotNull);
      expect(analytics.totalFollowers, greaterThan(0));
      expect(analytics.newFollowers, greaterThanOrEqualTo(0));
      expect(analytics.activeFollowersPercentage, inInclusiveRange(0.0, 1.0));
      expect(analytics.demographicData, isNotEmpty);
    });
    
    test('収益レポートデータが正しく取得できること', () async {
      final analytics = await analyticsService.getRevenueAnalytics('star_1');
      
      expect(analytics, isNotNull);
      expect(analytics.totalRevenue, greaterThanOrEqualTo(0));
      expect(analytics.monthlyRevenue, greaterThanOrEqualTo(0));
      expect(analytics.revenueBySource, isNotEmpty);
      expect(analytics.revenueHistory, isNotEmpty);
    });
    
    test('KPI分析データが正しく取得できること', () async {
      final analytics = await analyticsService.getKpiAnalytics('star_1');
      
      expect(analytics, isNotNull);
      expect(analytics.memberConversionRate, inInclusiveRange(0.0, 1.0));
      expect(analytics.memberRetentionRate, inInclusiveRange(0.0, 1.0));
      expect(analytics.engagementRate, inInclusiveRange(0.0, 1.0));
      expect(analytics.averageRevenuePerUser, greaterThanOrEqualTo(0));
    });
    
    test('レポート生成が正しく機能すること', () async {
      final report = await analyticsService.generateReport('star_1', ReportType.monthly);
      
      expect(report, isNotNull);
      expect(report.reportId, isNotEmpty);
      expect(report.reportType, ReportType.monthly);
      expect(report.generatedAt, isNotNull);
      expect(report.data, isNotEmpty);
    });
    
    test('KPI追跡が正しく機能すること', () async {
      final kpiHistory = await analyticsService.getKpiHistory('star_1', KpiType.memberConversion, 30);
      
      expect(kpiHistory, isNotNull);
      expect(kpiHistory.kpiType, KpiType.memberConversion);
      expect(kpiHistory.dataPoints, isNotEmpty);
      expect(kpiHistory.dataPoints.length, lessThanOrEqualTo(30));
    });
  });
}
