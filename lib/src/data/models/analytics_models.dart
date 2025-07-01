
/// ファン分析データモデル
class FanAnalyticsData {
  final String starId;
  final int totalFans;
  final int activeFans;
  final int newFans;
  final int loyalFans;
  final Map<String, int> fansByTier;
  final Map<String, int> fansByRegion;
  final Map<String, int> fansByAge;
  final Map<String, int> fansByGender;
  final Map<String, double> engagementRates;
  final Map<String, double> retentionRates;
  final List<Map<String, dynamic>> topFans;

  FanAnalyticsData({
    required this.starId,
    required this.totalFans,
    required this.activeFans,
    required this.newFans,
    required this.loyalFans,
    required this.fansByTier,
    required this.fansByRegion,
    required this.fansByAge,
    required this.fansByGender,
    required this.engagementRates,
    required this.retentionRates,
    required this.topFans,
  });

  /// JSONからファン分析データを作成するファクトリメソッド
  factory FanAnalyticsData.fromJson(Map<String, dynamic> json) {
    return FanAnalyticsData(
      starId: json['starId'],
      totalFans: json['totalFans'] ?? 0,
      activeFans: json['activeFans'] ?? 0,
      newFans: json['newFans'] ?? 0,
      loyalFans: json['loyalFans'] ?? 0,
      fansByTier: Map<String, int>.from(json['fansByTier'] ?? {}),
      fansByRegion: Map<String, int>.from(json['fansByRegion'] ?? {}),
      fansByAge: Map<String, int>.from(json['fansByAge'] ?? {}),
      fansByGender: Map<String, int>.from(json['fansByGender'] ?? {}),
      engagementRates: Map<String, double>.from(json['engagementRates'] ?? {}),
      retentionRates: Map<String, double>.from(json['retentionRates'] ?? {}),
      topFans: List<Map<String, dynamic>>.from(json['topFans'] ?? []),
    );
  }

  /// ファン分析データをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'starId': starId,
      'totalFans': totalFans,
      'activeFans': activeFans,
      'newFans': newFans,
      'loyalFans': loyalFans,
      'fansByTier': fansByTier,
      'fansByRegion': fansByRegion,
      'fansByAge': fansByAge,
      'fansByGender': fansByGender,
      'engagementRates': engagementRates,
      'retentionRates': retentionRates,
      'topFans': topFans,
    };
  }
}

/// 収益レポートモデル
class RevenueReport {
  final String starId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalRevenue;
  final Map<String, double> revenueBySource;
  final Map<String, double> revenueByMonth;
  final Map<String, double> revenueByProduct;
  final double platformFee;
  final double netRevenue;
  final double projectedRevenue;
  final double growthRate;

  RevenueReport({
    required this.starId,
    required this.startDate,
    required this.endDate,
    required this.totalRevenue,
    required this.revenueBySource,
    required this.revenueByMonth,
    required this.revenueByProduct,
    required this.platformFee,
    required this.netRevenue,
    required this.projectedRevenue,
    required this.growthRate,
  });

  /// JSONから収益レポートを作成するファクトリメソッド
  factory RevenueReport.fromJson(Map<String, dynamic> json) {
    return RevenueReport(
      starId: json['starId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalRevenue: json['totalRevenue'] ?? 0.0,
      revenueBySource: Map<String, double>.from(json['revenueBySource'] ?? {}),
      revenueByMonth: Map<String, double>.from(json['revenueByMonth'] ?? {}),
      revenueByProduct: Map<String, double>.from(json['revenueByProduct'] ?? {}),
      platformFee: json['platformFee'] ?? 0.0,
      netRevenue: json['netRevenue'] ?? 0.0,
      projectedRevenue: json['projectedRevenue'] ?? 0.0,
      growthRate: json['growthRate'] ?? 0.0,
    );
  }

  /// 収益レポートをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'starId': starId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalRevenue': totalRevenue,
      'revenueBySource': revenueBySource,
      'revenueByMonth': revenueByMonth,
      'revenueByProduct': revenueByProduct,
      'platformFee': platformFee,
      'netRevenue': netRevenue,
      'projectedRevenue': projectedRevenue,
      'growthRate': growthRate,
    };
  }
}

/// KPI追跡データモデル
class KpiTrackingData {
  final String starId;
  final DateTime date;
  final Map<String, double> conversionRates;
  final Map<String, double> retentionRates;
  final Map<String, double> engagementRates;
  final Map<String, double> revenueMetrics;
  final Map<String, double> growthMetrics;
  final Map<String, double> audienceMetrics;

  KpiTrackingData({
    required this.starId,
    required this.date,
    required this.conversionRates,
    required this.retentionRates,
    required this.engagementRates,
    required this.revenueMetrics,
    required this.growthMetrics,
    required this.audienceMetrics,
  });

  /// JSONからKPI追跡データを作成するファクトリメソッド
  factory KpiTrackingData.fromJson(Map<String, dynamic> json) {
    return KpiTrackingData(
      starId: json['starId'],
      date: DateTime.parse(json['date']),
      conversionRates: Map<String, double>.from(json['conversionRates'] ?? {}),
      retentionRates: Map<String, double>.from(json['retentionRates'] ?? {}),
      engagementRates: Map<String, double>.from(json['engagementRates'] ?? {}),
      revenueMetrics: Map<String, double>.from(json['revenueMetrics'] ?? {}),
      growthMetrics: Map<String, double>.from(json['growthMetrics'] ?? {}),
      audienceMetrics: Map<String, double>.from(json['audienceMetrics'] ?? {}),
    );
  }

  /// KPI追跡データをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'starId': starId,
      'date': date.toIso8601String(),
      'conversionRates': conversionRates,
      'retentionRates': retentionRates,
      'engagementRates': engagementRates,
      'revenueMetrics': revenueMetrics,
      'growthMetrics': growthMetrics,
      'audienceMetrics': audienceMetrics,
    };
  }
}
