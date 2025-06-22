import 'package:flutter/foundation.dart';

/// サブスクリプションプランタイプ
enum SubscriptionPlanType {
  basic,      // ベーシック
  standard,   // スタンダード  
  premium,    // プレミアム
  ultimate,   // アルティメット
}

/// サブスクリプションステータス
enum SubscriptionStatus {
  active,     // アクティブ
  canceled,   // キャンセル済み
  pastDue,    // 支払い遅延
  unpaid,     // 未払い
  expired,    // 期限切れ
}

/// サブスクリプションプランモデル
@immutable
class SubscriptionPlan {
  final SubscriptionPlanType planType;
  final String nameJa;
  final String nameEn;
  final int priceMonthlyJpy;
  final int priceYearlyJpy;
  final int starPointsMonthly;
  final List<String> benefits;
  final List<String> removedFeatures; // 削除された機能
  final bool isPopular;
  final String? description;

  const SubscriptionPlan({
    required this.planType,
    required this.nameJa,
    required this.nameEn,
    required this.priceMonthlyJpy,
    required this.priceYearlyJpy,
    required this.starPointsMonthly,
    required this.benefits,
    this.removedFeatures = const [],
    required this.isPopular,
    this.description,
  });

  /// 年額での月額換算価格（割引適用）
  int get yearlyMonthlyEquivalent => (priceYearlyJpy / 12).round();

  /// 年額での割引額（月額×12 - 年額）
  int get yearlyDiscount => (priceMonthlyJpy * 12) - priceYearlyJpy;

  /// 年額での割引率（0.0-1.0）
  double get yearlyDiscountRate => yearlyDiscount / (priceMonthlyJpy * 12);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscriptionPlan &&
        other.planType == planType &&
        other.nameJa == nameJa &&
        other.nameEn == nameEn &&
        other.priceMonthlyJpy == priceMonthlyJpy &&
        other.priceYearlyJpy == priceYearlyJpy &&
        other.starPointsMonthly == starPointsMonthly &&
        listEquals(other.benefits, benefits) &&
        listEquals(other.removedFeatures, removedFeatures) &&
        other.isPopular == isPopular &&
        other.description == description;
  }

  @override
  int get hashCode => Object.hash(
        planType,
        nameJa,
        nameEn,
        priceMonthlyJpy,
        priceYearlyJpy,
        starPointsMonthly,
        benefits,
        removedFeatures,
        isPopular,
        description,
      );
}

/// 更新されたサブスクリプションプラン一覧
class SubscriptionPlans {
  static const List<SubscriptionPlan> allPlans = [
    SubscriptionPlan(
      planType: SubscriptionPlanType.basic,
      nameJa: 'ベーシック',
      nameEn: 'Basic',
      priceMonthlyJpy: 400,
      priceYearlyJpy: 4000, // 2ヶ月分お得
      starPointsMonthly: 1500,
      benefits: [
        '月間1,500スターP付与',
        '広告非表示',
        '毎日ピック優先表示',
        'ベーシックサポート',
      ],
      removedFeatures: [
        'クーポン機能（削除済み）',
        'コミュニティ機能（削除済み）',
      ],
      isPopular: false,
      description: 'はじめてのプレミアム体験に最適',
    ),
    SubscriptionPlan(
      planType: SubscriptionPlanType.standard,
      nameJa: 'スタンダード',
      nameEn: 'Standard',
      priceMonthlyJpy: 800,
      priceYearlyJpy: 8000, // 2ヶ月分お得
      starPointsMonthly: 3500,
      benefits: [
        '月間3,500スターP付与',
        '広告完全非表示',
        'プレミアム質問50%割引',
        '毎日ピック優先表示',
        '限定コンテンツアクセス',
        'プライオリティサポート',
      ],
      removedFeatures: [
        'クーポン機能（削除済み）',
        'コミュニティ機能（削除済み）',
      ],
      isPopular: true,
      description: '最もバランスの取れた人気プラン',
    ),
    SubscriptionPlan(
      planType: SubscriptionPlanType.premium,
      nameJa: 'プレミアム',
      nameEn: 'Premium',
      priceMonthlyJpy: 1200,
      priceYearlyJpy: 12000, // 2ヶ月分お得
      starPointsMonthly: 6000,
      benefits: [
        '月間6,000スターP付与',
        '広告完全非表示',
        'プレミアム質問無制限',
        'Super Chat20%割引',
        'スター限定配信アクセス',
        'VIP毎日ピック',
        '24時間優先サポート',
        '独占コンテンツアクセス',
      ],
      removedFeatures: [
        'クーポン機能（削除済み）',
        'コミュニティ機能（削除済み）',
      ],
      isPopular: false,
      description: '充実したプレミアム機能をフル活用',
    ),
    SubscriptionPlan(
      planType: SubscriptionPlanType.ultimate,
      nameJa: 'アルティメット',
      nameEn: 'Ultimate',
      priceMonthlyJpy: 2000,
      priceYearlyJpy: 20000, // 2ヶ月分お得
      starPointsMonthly: 12000,
      benefits: [
        '月間12,000スターP付与',
        '全機能無制限利用',
        'Super Chat30%割引',
        'VIPスター限定イベント参加',
        '専属コンシェルジュサポート',
        'カスタム機能リクエスト',
        '早期新機能アクセス',
        '特別記念品プレゼント',
      ],
      removedFeatures: [
        'クーポン機能（削除済み）',
        'コミュニティ機能（削除済み）',
      ],
      isPopular: false,
      description: '究極のStarlist体験をお楽しみください',
    ),
  ];

  /// プランタイプからプランを取得
  static SubscriptionPlan? getPlan(SubscriptionPlanType planType) {
    try {
      return allPlans.firstWhere((plan) => plan.planType == planType);
    } catch (e) {
      return null;
    }
  }

  /// 人気プランを取得
  static SubscriptionPlan get popularPlan {
    return allPlans.firstWhere((plan) => plan.isPopular);
  }

  /// プラン比較用の特典マトリックス
  static Map<String, List<bool>> get benefitMatrix {
    final features = [
      'スターP月間付与',
      '広告非表示',
      'プレミアム質問割引',
      'Super Chat割引',
      '限定コンテンツ',
      'VIP機能',
      '優先サポート',
      '独占特典',
    ];

    return {
      for (var feature in features)
        feature: allPlans.map((plan) {
          switch (feature) {
            case 'スターP月間付与':
              return plan.starPointsMonthly > 0;
            case '広告非表示':
              return plan.planType != SubscriptionPlanType.basic;
            case 'プレミアム質問割引':
              return [SubscriptionPlanType.standard, SubscriptionPlanType.premium, SubscriptionPlanType.ultimate]
                  .contains(plan.planType);
            case 'Super Chat割引':
              return [SubscriptionPlanType.premium, SubscriptionPlanType.ultimate]
                  .contains(plan.planType);
            case '限定コンテンツ':
              return [SubscriptionPlanType.standard, SubscriptionPlanType.premium, SubscriptionPlanType.ultimate]
                  .contains(plan.planType);
            case 'VIP機能':
              return [SubscriptionPlanType.premium, SubscriptionPlanType.ultimate]
                  .contains(plan.planType);
            case '優先サポート':
              return plan.planType != SubscriptionPlanType.basic;
            case '独占特典':
              return plan.planType == SubscriptionPlanType.ultimate;
            default:
              return false;
          }
        }).toList(),
    };
  }
}

/// ユーザーのサブスクリプション情報
@immutable
class UserSubscription {
  final String id;
  final String userId;
  final SubscriptionPlanType planType;
  final SubscriptionStatus status;
  final DateTime currentPeriodStart;
  final DateTime currentPeriodEnd;
  final bool isYearly;
  final int priceJpy;
  final String? paymentMethodId;
  final DateTime? canceledAt;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserSubscription({
    required this.id,
    required this.userId,
    required this.planType,
    required this.status,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    required this.isYearly,
    required this.priceJpy,
    this.paymentMethodId,
    this.canceledAt,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSONからUserSubscriptionを作成
  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'],
      userId: json['user_id'],
      planType: SubscriptionPlanType.values.firstWhere(
        (e) => e.name == json['plan_type'],
        orElse: () => SubscriptionPlanType.basic,
      ),
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SubscriptionStatus.expired,
      ),
      currentPeriodStart: DateTime.parse(json['current_period_start']),
      currentPeriodEnd: DateTime.parse(json['current_period_end']),
      isYearly: json['is_yearly'] ?? false,
      priceJpy: json['price_jpy'],
      paymentMethodId: json['payment_method_id'],
      canceledAt: json['canceled_at'] != null ? DateTime.parse(json['canceled_at']) : null,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// UserSubscriptionをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan_type': planType.name,
      'status': status.name,
      'current_period_start': currentPeriodStart.toIso8601String(),
      'current_period_end': currentPeriodEnd.toIso8601String(),
      'is_yearly': isYearly,
      'price_jpy': priceJpy,
      'payment_method_id': paymentMethodId,
      'canceled_at': canceledAt?.toIso8601String(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// プラン情報を取得
  SubscriptionPlan? get plan => SubscriptionPlans.getPlan(planType);

  /// アクティブかどうか
  bool get isActive => status == SubscriptionStatus.active;

  /// キャンセル済みかどうか
  bool get isCanceled => canceledAt != null;


  /// 期限切れまでの日数
  int get daysUntilExpiry {
    final now = DateTime.now();
    if (now.isAfter(currentPeriodEnd)) return 0;
    return currentPeriodEnd.difference(now).inDays;
  }

  /// 次回更新日
  DateTime? get nextRenewalDate {
    if (!isActive || isCanceled) return null;
    return currentPeriodEnd;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSubscription &&
        other.id == id &&
        other.userId == userId &&
        other.planType == planType &&
        other.status == status &&
        other.currentPeriodStart == currentPeriodStart &&
        other.currentPeriodEnd == currentPeriodEnd &&
        other.isYearly == isYearly &&
        other.priceJpy == priceJpy &&
        other.paymentMethodId == paymentMethodId &&
        other.canceledAt == canceledAt &&
        mapEquals(other.metadata, metadata) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        planType,
        status,
        currentPeriodStart,
        currentPeriodEnd,
        isYearly,
        priceJpy,
        paymentMethodId,
        canceledAt,
        metadata,
        createdAt,
        updatedAt,
      );
}