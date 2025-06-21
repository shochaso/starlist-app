import '../models/admin/analytics_model.dart';

/// 統計リポジトリの抽象インターフェース
abstract class AnalyticsRepository {
  /// ユーザー統計を取得する
  Future<UserAnalytics> getUserAnalytics(AnalyticsPeriod period, {DateTime? startDate, DateTime? endDate});
  
  /// 収益統計を取得する
  Future<RevenueAnalytics> getRevenueAnalytics(AnalyticsPeriod period, {DateTime? startDate, DateTime? endDate});
  
  /// コンテンツ統計を取得する
  Future<ContentAnalytics> getContentAnalytics(AnalyticsPeriod period, {DateTime? startDate, DateTime? endDate});
  
  /// システム統計を取得する
  Future<SystemAnalytics> getSystemAnalytics(AnalyticsPeriod period, {DateTime? startDate, DateTime? endDate});
  
  /// ダッシュボード統計を取得する
  Future<DashboardAnalytics> getDashboardAnalytics(AnalyticsPeriod period, {DateTime? startDate, DateTime? endDate});
  
  /// カスタムレポートを生成する
  Future<Map<String, dynamic>> generateCustomReport(String reportDefinition, AnalyticsPeriod period, {DateTime? startDate, DateTime? endDate});
}
