import '../models/subscription_plan.dart';

/// Starlistアプリのサブスクリプションプラン定義
class SubscriptionPlansData {
  /// 無料プラン
  static final SubscriptionPlan freePlan = SubscriptionPlan(
    id: 'free',
    name: '無料プラン',
    description: '基本的な機能を無料で利用できます',
    price: 0,
    currency: 'JPY',
    billingPeriod: const Duration(days: 0), // 無期限
    features: [
      '基本的なランキング表示',
      '限定コンテンツへのアクセス（一部）',
      '広告付きでの利用',
    ],
    isPopular: false,
  );

  /// 月額プラン
  static final SubscriptionPlan monthlyPlan = SubscriptionPlan(
    id: 'premium_monthly',
    name: 'プレミアム月額',
    description: '月額料金でプレミアム機能へのアクセス',
    price: 980,
    currency: 'JPY',
    billingPeriod: const Duration(days: 30),
    features: [
      '詳細なランキングデータへのアクセス',
      'すべてのコンテンツへのアクセス',
      '広告なしでの利用',
      'プロフィールカスタマイズ',
      'スター評価の詳細分析',
    ],
    isPopular: true,
    metadata: {
      'savePercent': 0,
      'trialDays': 7, // 7日間無料トライアル
    },
  );

  /// 年額プラン
  static final SubscriptionPlan yearlyPlan = SubscriptionPlan(
    id: 'premium_yearly',
    name: 'プレミアム年額',
    description: '年間契約でお得なプレミアム機能へのアクセス',
    price: 9800,
    currency: 'JPY',
    billingPeriod: const Duration(days: 365),
    features: [
      '詳細なランキングデータへのアクセス',
      'すべてのコンテンツへのアクセス',
      '広告なしでの利用',
      'プロフィールカスタマイズ',
      'スター評価の詳細分析',
      'プレミアムサポート',
      '限定イベントへの招待',
    ],
    isPopular: false,
    metadata: {
      'savePercent': 17, // 月額比で17%お得
      'trialDays': 14, // 14日間無料トライアル
    },
  );

  /// 利用可能なすべてのプラン
  static List<SubscriptionPlan> get allPlans => [
    freePlan,
    monthlyPlan,
    yearlyPlan,
  ];
} 