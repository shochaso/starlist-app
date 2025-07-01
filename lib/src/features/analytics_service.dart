import 'package:flutter/foundation.dart';
import '../models/admin/analytics_model.dart';
import '../repositories/admin/analytics_repository.dart';

/// 統計サービスクラス
class AnalyticsService {
  final AnalyticsRepository _repository;
  
  /// コンストラクタ
  AnalyticsService({
    required AnalyticsRepository repository,
  }) : _repository = repository;
  
  /// ユーザー統計を取得する
  Future<UserAnalytics> getUserAnalytics(AnalyticsPeriod period, {DateTime? startDate, DateTime? endDate}) async {
    try {
      return await _repository.getUserAnalytics(period, startDate: startDate, endDate: endDate);
    } catch (e) {
      debugPrint('ユーザー統計取得エラー: $e');
      rethrow;
    }
  }
  
  /// 収益統計を取得する
  Future<RevenueAnalytics> getRevenueAnalytics(AnalyticsPeriod period, {DateTime? startDate, DateTime? endDate}) async {
    try {
      return await _repository.getRevenueAnalytics(period, startDate: startDate, endDate: endDate);
    } catch (e) {
      debugPrint('収益統計取得エラー: $e');
      rethrow;
    }
  }
  
  /// コンテンツ統計を取得する
  Future<ContentAnalytics> getContentAnalytics(AnalyticsPeriod period, {DateTime? startDate, DateTime? endDate}) async {
    try {
      return await _repository.getContentAnalytics(period, startDate: startDate, endDate: endDate);
    } catch (e) {
      debugPrint('コンテンツ統計取得エラー: $e');
      rethrow;
    }
  }
  
  /// システム統計を取得する
  Future<SystemAnalytics> getSystemAnalytics(AnalyticsPeriod period, {DateTime? startDate, DateTime? endDate}) async {
    try {
      return await _repository.getSystemAnalytics(period, startDate: startDate, endDate: endDate);
    } catch (e) {
      debugPrint('システム統計取得エラー: $e');
      rethrow;
    }
  }
  
  /// ダッシュボード統計を取得する
  Future<DashboardAnalytics> getDashboardAnalytics(AnalyticsPeriod period, {DateTime? startDate, DateTime? endDate}) async {
    try {
      return await _repository.getDashboardAnalytics(period, startDate: startDate, endDate: endDate);
    } catch (e) {
      debugPrint('ダッシュボード統計取得エラー: $e');
      rethrow;
    }
  }
  
  /// カスタムレポートを生成する
  Future<Map<String, dynamic>> generateCustomReport(String reportDefinition, AnalyticsPeriod period, {DateTime? startDate, DateTime? endDate}) async {
    try {
      return await _repository.generateCustomReport(reportDefinition, period, startDate: startDate, endDate: endDate);
    } catch (e) {
      debugPrint('カスタムレポート生成エラー: $e');
      rethrow;
    }
  }
  
  /// レポートをエクスポートする
  Future<String> exportReport(String reportType, AnalyticsPeriod period, {DateTime? startDate, DateTime? endDate, String format = 'csv'}) async {
    try {
      // レポートをエクスポートしてダウンロードURLを返す
      // 実際の実装ではファイル生成とダウンロードURLの提供
      
      // このサンプルでは未実装
      throw UnimplementedError('レポートのエクスポート機能は未実装です');
    } catch (e) {
      debugPrint('レポートエクスポートエラー: $e');
      rethrow;
    }
  }
  
  /// 定期レポートをスケジュールする
  Future<bool> scheduleReport(String reportType, AnalyticsPeriod period, List<String> recipients, {String format = 'pdf'}) async {
    try {
      // 定期レポートをスケジュール
      // 実際の実装ではスケジューラーサービスを使用
      
      // このサンプルでは未実装
      throw UnimplementedError('定期レポートのスケジュール機能は未実装です');
    } catch (e) {
      debugPrint('レポートスケジュールエラー: $e');
      return false;
    }
  }
  
  /// 期間の開始日と終了日を計算する
  Map<String, DateTime> calculatePeriodDates(AnalyticsPeriod period, {DateTime? referenceDate}) {
    final now = referenceDate ?? DateTime.now();
    final startDate = _getStartDate(period, now);
    final endDate = _getEndDate(period, now);
    
    return {
      'startDate': startDate,
      'endDate': endDate,
    };
  }
  
  /// 期間の開始日を取得する
  DateTime _getStartDate(AnalyticsPeriod period, DateTime referenceDate) {
    switch (period) {
      case AnalyticsPeriod.daily:
        return DateTime(referenceDate.year, referenceDate.month, referenceDate.day);
      case AnalyticsPeriod.weekly:
        // 週の開始日（月曜日）を取得
        final weekday = referenceDate.weekday;
        return DateTime(referenceDate.year, referenceDate.month, referenceDate.day - weekday + 1);
      case AnalyticsPeriod.monthly:
        return DateTime(referenceDate.year, referenceDate.month, 1);
      case AnalyticsPeriod.quarterly:
        // 四半期の開始月を計算
        final quarterStartMonth = ((referenceDate.month - 1) ~/ 3) * 3 + 1;
        return DateTime(referenceDate.year, quarterStartMonth, 1);
      case AnalyticsPeriod.yearly:
        return DateTime(referenceDate.year, 1, 1);
      case AnalyticsPeriod.custom:
        // カスタム期間の場合はデフォルトで30日前
        return referenceDate.subtract(const Duration(days: 30));
      default:
        return DateTime(referenceDate.year, referenceDate.month, referenceDate.day);
    }
  }
  
  /// 期間の終了日を取得する
  DateTime _getEndDate(AnalyticsPeriod period, DateTime referenceDate) {
    switch (period) {
      case AnalyticsPeriod.daily:
        return DateTime(referenceDate.year, referenceDate.month, referenceDate.day, 23, 59, 59);
      case AnalyticsPeriod.weekly:
        // 週の開始日（月曜日）を取得し、7日後を終了日とする
        final weekday = referenceDate.weekday;
        final startDate = DateTime(referenceDate.year, referenceDate.month, referenceDate.day - weekday + 1);
        return DateTime(startDate.year, startDate.month, startDate.day + 6, 23, 59, 59);
      case AnalyticsPeriod.monthly:
        // 次の月の1日から1秒引いた時間（月末）
        final nextMonth = referenceDate.month == 12 
            ? DateTime(referenceDate.year + 1, 1, 1)
            : DateTime(referenceDate.year, referenceDate.month + 1, 1);
        return nextMonth.subtract(const Duration(seconds: 1));
      case AnalyticsPeriod.quarterly:
        // 四半期の開始月を計算
        final quarterStartMonth = ((referenceDate.month - 1) ~/ 3) * 3 + 1;
        // 3ヶ月後の1日から1秒引いた時間（四半期末）
        final nextQuarter = quarterStartMonth + 3 > 12
            ? DateTime(referenceDate.year + 1, (quarterStartMonth + 3) % 12, 1)
            : DateTime(referenceDate.year, quarterStartMonth + 3, 1);
        return nextQuarter.subtract(const Duration(seconds: 1));
      case AnalyticsPeriod.yearly:
        return DateTime(referenceDate.year, 12, 31, 23, 59, 59);
      case AnalyticsPeriod.custom:
        // カスタム期間の場合はデフォルトで現在時刻
        return referenceDate;
      default:
        return DateTime(referenceDate.year, referenceDate.month, referenceDate.day, 23, 59, 59);
    }
  }
}
