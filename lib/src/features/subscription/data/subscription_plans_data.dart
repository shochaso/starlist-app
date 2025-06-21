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

  /// ライトプラン
  static final SubscriptionPlan lightPlan = SubscriptionPlan(
    id: 'light_monthly',
    name: 'ライトプラン',
    description: '月額料金でライト機能へのアクセス',
    price: 980,
    currency: 'JPY',
    billingPeriod: const Duration(days: 30),
    features: [
      '詳細なランキングデータへのアクセス',
      'コンテンツへのアクセス（標準）',
      '広告表示の軽減',
      'プロフィールカスタマイズ',
    ],
    isPopular: true,
    metadata: {
      'savePercent': 0,
      'trialDays': 7, // 7日間無料トライアル
    },
  );

  /// スタンダードプラン
  static final SubscriptionPlan standardPlan = SubscriptionPlan(
    id: 'standard_monthly',
    name: 'スタンダードプラン',
    description: '月額料金でスタンダード機能へのアクセス',
    price: 1980,
    currency: 'JPY',
    billingPeriod: const Duration(days: 30),
    features: [
      '詳細なランキングデータへのアクセス',
      'すべてのコンテンツへのアクセス',
      '広告なしでの利用',
      'プロフィールカスタマイズ',
      'スター評価の詳細分析',
    ],
    isPopular: false,
    metadata: {
      'savePercent': 0,
      'trialDays': 7, // 7日間無料トライアル
    },
  );

  /// プレミアムプラン
  static final SubscriptionPlan premiumPlan = SubscriptionPlan(
    id: 'premium_monthly',
    name: 'プレミアムプラン',
    description: '月額料金でプレミアム機能へのアクセス',
    price: 2980,
    currency: 'JPY',
    billingPeriod: const Duration(days: 30),
    features: [
      '詳細なランキングデータへのアクセス',
      'すべてのコンテンツへのアクセス',
      '広告なしでの利用',
      'プロフィールカスタマイズ',
      'スター評価の詳細分析',
      'プレミアムサポート',
      '限定イベントへの招待',
      'VIPステータス',
    ],
    isPopular: false,
    metadata: {
      'savePercent': 0,
      'trialDays': 14, // 14日間無料トライアル
    },
  );

  /// 利用可能なすべてのプラン
  static List<SubscriptionPlan> get allPlans => [
    freePlan,
    lightPlan,
    standardPlan,
    premiumPlan,
  ];
} 