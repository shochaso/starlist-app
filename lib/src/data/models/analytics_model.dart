
/// 統計期間を表すenum
enum AnalyticsPeriod {
  /// 日次
  daily,
  
  /// 週次
  weekly,
  
  /// 月次
  monthly,
  
  /// 四半期
  quarterly,
  
  /// 年次
  yearly,
  
  /// カスタム
  custom,
}

/// ユーザー統計を表すクラス
class UserAnalytics {
  final int totalUsers;
  final int newUsers;
  final int activeUsers;
  final int starCreators;
  final Map<String, int> usersByPlan;
  final Map<String, int> usersByRegion;
  final double retentionRate;
  final double churnRate;
  
  /// コンストラクタ
  UserAnalytics({
    required this.totalUsers,
    required this.newUsers,
    required this.activeUsers,
    required this.starCreators,
    required this.usersByPlan,
    required this.usersByRegion,
    required this.retentionRate,
    required this.churnRate,
  });
  
  /// JSONからUserAnalyticsを生成するファクトリメソッド
  factory UserAnalytics.fromJson(Map<String, dynamic> json) {
    return UserAnalytics(
      totalUsers: json['totalUsers'],
      newUsers: json['newUsers'],
      activeUsers: json['activeUsers'],
      starCreators: json['starCreators'],
      usersByPlan: Map<String, int>.from(json['usersByPlan']),
      usersByRegion: Map<String, int>.from(json['usersByRegion']),
      retentionRate: json['retentionRate'],
      churnRate: json['churnRate'],
    );
  }
  
  /// UserAnalyticsをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'newUsers': newUsers,
      'activeUsers': activeUsers,
      'starCreators': starCreators,
      'usersByPlan': usersByPlan,
      'usersByRegion': usersByRegion,
      'retentionRate': retentionRate,
      'churnRate': churnRate,
    };
  }
}

/// 収益統計を表すクラス
class RevenueAnalytics {
  final double totalRevenue;
  final double subscriptionRevenue;
  final double ticketRevenue;
  final double donationRevenue;
  final Map<String, double> revenueByPlan;
  final Map<String, double> revenueByRegion;
  final double averageRevenuePerUser;
  final double monthOverMonthGrowth;
  
  /// コンストラクタ
  RevenueAnalytics({
    required this.totalRevenue,
    required this.subscriptionRevenue,
    required this.ticketRevenue,
    required this.donationRevenue,
    required this.revenueByPlan,
    required this.revenueByRegion,
    required this.averageRevenuePerUser,
    required this.monthOverMonthGrowth,
  });
  
  /// JSONからRevenueAnalyticsを生成するファクトリメソッド
  factory RevenueAnalytics.fromJson(Map<String, dynamic> json) {
    return RevenueAnalytics(
      totalRevenue: json['totalRevenue'],
      subscriptionRevenue: json['subscriptionRevenue'],
      ticketRevenue: json['ticketRevenue'],
      donationRevenue: json['donationRevenue'],
      revenueByPlan: Map<String, double>.from(json['revenueByPlan']),
      revenueByRegion: Map<String, double>.from(json['revenueByRegion']),
      averageRevenuePerUser: json['averageRevenuePerUser'],
      monthOverMonthGrowth: json['monthOverMonthGrowth'],
    );
  }
  
  /// RevenueAnalyticsをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'totalRevenue': totalRevenue,
      'subscriptionRevenue': subscriptionRevenue,
      'ticketRevenue': ticketRevenue,
      'donationRevenue': donationRevenue,
      'revenueByPlan': revenueByPlan,
      'revenueByRegion': revenueByRegion,
      'averageRevenuePerUser': averageRevenuePerUser,
      'monthOverMonthGrowth': monthOverMonthGrowth,
    };
  }
}

/// コンテンツ統計を表すクラス
class ContentAnalytics {
  final int totalContent;
  final int newContent;
  final Map<String, int> contentByCategory;
  final Map<String, int> contentByPrivacyLevel;
  final double averageViewsPerContent;
  final double averageLikesPerContent;
  final double averageCommentsPerContent;
  final List<String> topPerformingContent;
  
  /// コンストラクタ
  ContentAnalytics({
    required this.totalContent,
    required this.newContent,
    required this.contentByCategory,
    required this.contentByPrivacyLevel,
    required this.averageViewsPerContent,
    required this.averageLikesPerContent,
    required this.averageCommentsPerContent,
    required this.topPerformingContent,
  });
  
  /// JSONからContentAnalyticsを生成するファクトリメソッド
  factory ContentAnalytics.fromJson(Map<String, dynamic> json) {
    return ContentAnalytics(
      totalContent: json['totalContent'],
      newContent: json['newContent'],
      contentByCategory: Map<String, int>.from(json['contentByCategory']),
      contentByPrivacyLevel: Map<String, int>.from(json['contentByPrivacyLevel']),
      averageViewsPerContent: json['averageViewsPerContent'],
      averageLikesPerContent: json['averageLikesPerContent'],
      averageCommentsPerContent: json['averageCommentsPerContent'],
      topPerformingContent: List<String>.from(json['topPerformingContent']),
    );
  }
  
  /// ContentAnalyticsをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'totalContent': totalContent,
      'newContent': newContent,
      'contentByCategory': contentByCategory,
      'contentByPrivacyLevel': contentByPrivacyLevel,
      'averageViewsPerContent': averageViewsPerContent,
      'averageLikesPerContent': averageLikesPerContent,
      'averageCommentsPerContent': averageCommentsPerContent,
      'topPerformingContent': topPerformingContent,
    };
  }
}

/// システム統計を表すクラス
class SystemAnalytics {
  final double averageResponseTime;
  final int totalApiCalls;
  final int errorCount;
  final double serverUptime;
  final Map<String, int> apiCallsByEndpoint;
  final Map<String, int> errorsByType;
  
  /// コンストラクタ
  SystemAnalytics({
    required this.averageResponseTime,
    required this.totalApiCalls,
    required this.errorCount,
    required this.serverUptime,
    required this.apiCallsByEndpoint,
    required this.errorsByType,
  });
  
  /// JSONからSystemAnalyticsを生成するファクトリメソッド
  factory SystemAnalytics.fromJson(Map<String, dynamic> json) {
    return SystemAnalytics(
      averageResponseTime: json['averageResponseTime'],
      totalApiCalls: json['totalApiCalls'],
      errorCount: json['errorCount'],
      serverUptime: json['serverUptime'],
      apiCallsByEndpoint: Map<String, int>.from(json['apiCallsByEndpoint']),
      errorsByType: Map<String, int>.from(json['errorsByType']),
    );
  }
  
  /// SystemAnalyticsをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'averageResponseTime': averageResponseTime,
      'totalApiCalls': totalApiCalls,
      'errorCount': errorCount,
      'serverUptime': serverUptime,
      'apiCallsByEndpoint': apiCallsByEndpoint,
      'errorsByType': errorsByType,
    };
  }
}

/// ダッシュボード統計を表すクラス
class DashboardAnalytics {
  final UserAnalytics userAnalytics;
  final RevenueAnalytics revenueAnalytics;
  final ContentAnalytics contentAnalytics;
  final SystemAnalytics systemAnalytics;
  final DateTime generatedAt;
  final AnalyticsPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  
  /// コンストラクタ
  DashboardAnalytics({
    required this.userAnalytics,
    required this.revenueAnalytics,
    required this.contentAnalytics,
    required this.systemAnalytics,
    required this.generatedAt,
    required this.period,
    required this.startDate,
    required this.endDate,
  });
  
  /// JSONからDashboardAnalyticsを生成するファクトリメソッド
  factory DashboardAnalytics.fromJson(Map<String, dynamic> json) {
    return DashboardAnalytics(
      userAnalytics: UserAnalytics.fromJson(json['userAnalytics']),
      revenueAnalytics: RevenueAnalytics.fromJson(json['revenueAnalytics']),
      contentAnalytics: ContentAnalytics.fromJson(json['contentAnalytics']),
      systemAnalytics: SystemAnalytics.fromJson(json['systemAnalytics']),
      generatedAt: DateTime.parse(json['generatedAt']),
      period: AnalyticsPeriod.values.firstWhere(
        (e) => e.toString() == 'AnalyticsPeriod.${json['period']}',
        orElse: () => AnalyticsPeriod.daily,
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }
  
  /// DashboardAnalyticsをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'userAnalytics': userAnalytics.toJson(),
      'revenueAnalytics': revenueAnalytics.toJson(),
      'contentAnalytics': contentAnalytics.toJson(),
      'systemAnalytics': systemAnalytics.toJson(),
      'generatedAt': generatedAt.toIso8601String(),
      'period': period.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}
