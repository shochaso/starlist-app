import '../models/subscription_plan_model.dart';
import '../models/subscription_status.dart';
import '../models/subscription_history_model.dart';
import '../models/subscription_models.dart' as subscription_data;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../payment/services/payment_service.dart';

const String _kStripeSecretKeyForSubscription =
    String.fromEnvironment('STRIPE_SECRET_KEY');

abstract class SubscriptionService {
  Future<List<SubscriptionPlanModel>> getAvailablePlans();
  Future<SubscriptionStatusModel> getCurrentSubscription(String userId);
  Future<SubscriptionStatusModel> subscribe(
      String userId, String planId, String paymentMethodId);
  Future<SubscriptionStatusModel> cancelSubscription(String userId);
  Future<SubscriptionStatusModel> updateSubscription(
      String userId, String newPlanId);
  Future<void> handleWebhook(String payload);
  Future<List<SubscriptionHistoryModel>> getSubscriptionHistory(String userId);
}

class SubscriptionServiceImpl implements SubscriptionService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final PaymentService _paymentService;

  SubscriptionServiceImpl(this._paymentService);

  @override
  Future<List<SubscriptionPlanModel>> getAvailablePlans() async {
    try {
      final response = await _supabase
          .from('subscription_plans')
          .select()
          .eq('is_active', true)
          .order('price', ascending: true);

      return response
          .map<SubscriptionPlanModel>(
              (json) => SubscriptionPlanModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('[SubscriptionService] プラン取得に失敗したためローカル定義を利用します: $e');
      return _buildLocalPlans();
    }
  }

  @override
  Future<SubscriptionStatusModel> getCurrentSubscription(String userId) async {
    try {
      final response = await _supabase.from('subscriptions').select('''
            *,
            plan:subscription_plans!plan_id(*)
          ''').eq('user_id', userId).eq('status', 'active').maybeSingle();

      if (response == null) {
        return SubscriptionStatusModel.free(userId);
      }

      return SubscriptionStatusModel.fromJson(response);
    } catch (e) {
      throw SubscriptionException('サブスクリプション状況の取得に失敗しました: $e');
    }
  }

  @override
  Future<SubscriptionStatusModel> subscribe(
      String userId, String planId, String paymentMethodId) async {
    try {
      // プラン情報取得
      final planResponse = await _supabase
          .from('subscription_plans')
          .select()
          .eq('id', planId)
          .single();

      final plan = SubscriptionPlanModel.fromJson(planResponse);

      // 既存のアクティブなサブスクリプションをチェック
      final existingSubscription = await getCurrentSubscription(userId);
      if (existingSubscription.status == SubscriptionStatus.active) {
        throw SubscriptionException('既にアクティブなサブスクリプションがあります');
      }

      // 決済処理
      final payment = await _paymentService.createPayment(
        userId: userId,
        amount: plan.price,
        currency: 'jpy',
        paymentMethodId: paymentMethodId,
        metadata: {
          'subscription_plan_id': planId,
          'subscription_type': 'new',
        },
      );

      // サブスクリプション作成
      final subscriptionData = {
        'user_id': userId,
        'plan_id': planId,
        'status': 'pending',
        'payment_id': payment.id,
        'start_date': DateTime.now().toIso8601String(),
        'next_billing_date': _calculateNextBillingDate(plan.billingCycle),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final subscriptionResponse = await _supabase
          .from('subscriptions')
          .insert(subscriptionData)
          .select('''
            *,
            plan:subscription_plans!plan_id(*)
          ''').single();

      // サブスクリプション履歴記録
      await _recordSubscriptionHistory(userId, 'subscribed', planId);

      return SubscriptionStatusModel.fromJson(subscriptionResponse);
    } catch (e) {
      throw SubscriptionException('サブスクリプションの開始に失敗しました: $e');
    }
  }

  @override
  Future<SubscriptionStatusModel> cancelSubscription(String userId) async {
    try {
      final currentSubscription = await getCurrentSubscription(userId);

      if (currentSubscription.status != SubscriptionStatus.active) {
        throw SubscriptionException('キャンセル可能なサブスクリプションがありません');
      }

      // サブスクリプションをキャンセル状態に更新
      final response = await _supabase
          .from('subscriptions')
          .update({
            'status': 'cancelled',
            'cancelled_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('status', 'active')
          .select('''
            *,
            plan:subscription_plans!plan_id(*)
          ''')
          .single();

      // サブスクリプション履歴記録
      await _recordSubscriptionHistory(
          userId, 'cancelled', currentSubscription.planId);

      // キャンセル理由のアンケート送信（オプション）
      await _sendCancellationSurvey(userId);

      return SubscriptionStatusModel.fromJson(response);
    } catch (e) {
      throw SubscriptionException('サブスクリプションのキャンセルに失敗しました: $e');
    }
  }

  @override
  Future<SubscriptionStatusModel> updateSubscription(
      String userId, String newPlanId) async {
    try {
      final currentSubscription = await getCurrentSubscription(userId);

      if (currentSubscription.status != SubscriptionStatus.active) {
        throw SubscriptionException('アップグレード可能なサブスクリプションがありません');
      }

      // 新しいプラン情報取得
      final newPlanResponse = await _supabase
          .from('subscription_plans')
          .select()
          .eq('id', newPlanId)
          .single();

      final newPlan = SubscriptionPlanModel.fromJson(newPlanResponse);

      // プロレーション計算
      final prorationAmount = _calculateProration(currentSubscription, newPlan);

      // 差額決済（必要な場合）
      if (prorationAmount > 0) {
        await _paymentService.createPayment(
          userId: userId,
          amount: prorationAmount,
          currency: 'jpy',
          paymentMethodId: currentSubscription.paymentMethodId ?? '',
          metadata: {
            'subscription_plan_id': newPlanId,
            'subscription_type': 'upgrade',
            'proration_amount': prorationAmount.toString(),
          },
        );
      }

      // サブスクリプション更新
      final response = await _supabase
          .from('subscriptions')
          .update({
            'plan_id': newPlanId,
            'next_billing_date':
                _calculateNextBillingDate(newPlan.billingCycle),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('status', 'active')
          .select('''
            *,
            plan:subscription_plans!plan_id(*)
          ''')
          .single();

      // サブスクリプション履歴記録
      await _recordSubscriptionHistory(userId, 'upgraded', newPlanId);

      return SubscriptionStatusModel.fromJson(response);
    } catch (e) {
      throw SubscriptionException('サブスクリプションの更新に失敗しました: $e');
    }
  }

  @override
  Future<void> handleWebhook(String payload) async {
    try {
      // Stripe Webhookからのサブスクリプション状態更新
      debugPrint('Subscription webhook処理(ログのみ): $payload');
    } catch (e) {
      throw SubscriptionException('Webhook処理エラー: $e');
    }
  }

  @override
  Future<List<SubscriptionHistoryModel>> getSubscriptionHistory(
      String userId) async {
    try {
      final response = await _supabase.from('subscription_history').select('''
            *,
            plan:subscription_plans!plan_id(name, price)
          ''').eq('user_id', userId).order('created_at', ascending: false);

      return response
          .map<SubscriptionHistoryModel>(
              (json) => SubscriptionHistoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw SubscriptionException('サブスクリプション履歴の取得に失敗しました: $e');
    }
  }

  // プライベートメソッド
  String _calculateNextBillingDate(String billingCycle) {
    final now = DateTime.now();
    DateTime nextBilling;

    switch (billingCycle) {
      case 'monthly':
        nextBilling = DateTime(now.year, now.month + 1, now.day);
        break;
      case 'yearly':
        nextBilling = DateTime(now.year + 1, now.month, now.day);
        break;
      case 'weekly':
        nextBilling = now.add(const Duration(days: 7));
        break;
      default:
        nextBilling = DateTime(now.year, now.month + 1, now.day);
    }

    return nextBilling.toIso8601String();
  }

  double _calculateProration(
      SubscriptionStatusModel currentSub, SubscriptionPlanModel newPlan) {
    if (currentSub.nextBillingDate == null) {
      return newPlan.price;
    }

    final now = DateTime.now();
    final nextBilling = currentSub.nextBillingDate!;
    final daysRemaining = nextBilling.difference(now).inDays;
    const totalDaysInCycle = 30; // 月額の場合

    final currentPlanPrice =
        (currentSub.metadata['price'] as num?)?.toDouble() ?? newPlan.price;
    final currentPlanDailyRate = currentPlanPrice / totalDaysInCycle;
    final newPlanDailyRate = newPlan.price / totalDaysInCycle;

    final refundAmount = currentPlanDailyRate * daysRemaining;
    final chargeAmount = newPlanDailyRate * daysRemaining;

    return chargeAmount - refundAmount;
  }

  Future<void> _recordSubscriptionHistory(
      String userId, String action, String planId) async {
    try {
      await _supabase.from('subscription_history').insert({
        'user_id': userId,
        'plan_id': planId,
        'action': action,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('サブスクリプション履歴記録エラー: $e');
    }
  }

  Future<void> _sendCancellationSurvey(String userId) async {
    try {
      // キャンセル理由アンケートの送信
      await _supabase.from('cancellation_surveys').insert({
        'user_id': userId,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('キャンセルアンケート送信エラー: $e');
    }
  }
}

List<SubscriptionPlanModel> _buildLocalPlans() {
  final now = DateTime.now();
  final List<SubscriptionPlanModel> plans = [];

  for (final plan in subscription_data.SubscriptionPlans.allPlans) {
    final baseFeatures = <String, dynamic>{
      'plan_type': plan.planType.toString().split('.').last,
      'benefits': plan.benefits,
      'removed_features': plan.removedFeatures,
      'star_points_monthly': plan.starPointsMonthly,
      'name_en': plan.nameEn,
      'is_popular': plan.isPopular,
      if (plan.description != null) 'description': plan.description,
    };

    if (plan.planType == subscription_data.SubscriptionPlanType.free) {
      plans.add(
        SubscriptionPlanModel(
          id: 'free',
          name: plan.nameJa,
          description: plan.description,
          price: 0,
          currency: 'JPY',
          interval: SubscriptionInterval.monthly,
          features: {
            ...baseFeatures,
            'billing_cycle': 'monthly',
          },
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
      );
      continue;
    }

    plans.add(
      SubscriptionPlanModel(
        id: '${plan.planType.name}_monthly',
        name: plan.nameJa,
        description: plan.description,
        price: plan.priceMonthlyJpy.toDouble(),
        currency: 'JPY',
        interval: SubscriptionInterval.monthly,
        features: {
          ...baseFeatures,
          'billing_cycle': 'monthly',
        },
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    );

    plans.add(
      SubscriptionPlanModel(
        id: '${plan.planType.name}_yearly',
        name: '${plan.nameJa}（年額）',
        description: plan.description,
        price: plan.priceYearlyJpy.toDouble(),
        currency: 'JPY',
        interval: SubscriptionInterval.yearly,
        features: {
          ...baseFeatures,
          'billing_cycle': 'yearly',
          'yearly_discount': plan.yearlyDiscount,
          'yearly_discount_rate':
              plan.priceMonthlyJpy == 0 ? 0 : plan.yearlyDiscountRate,
        },
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  return plans;
}

DateTime? _nextBillingDateForInterval(
    SubscriptionInterval interval, DateTime reference) {
  switch (interval) {
    case SubscriptionInterval.monthly:
      return DateTime(reference.year, reference.month + 1, reference.day);
    case SubscriptionInterval.yearly:
      return DateTime(reference.year + 1, reference.month, reference.day);
  }
}

class MockSubscriptionService implements SubscriptionService {
  MockSubscriptionService(this._paymentService) : _plans = _buildLocalPlans();

  final PaymentService _paymentService;
  final List<SubscriptionPlanModel> _plans;
  final Map<String, SubscriptionStatusModel> _subscriptions = {};
  final Map<String, List<SubscriptionHistoryModel>> _history = {};

  @override
  Future<List<SubscriptionPlanModel>> getAvailablePlans() async => _plans;

  @override
  Future<SubscriptionStatusModel> getCurrentSubscription(String userId) async {
    return _subscriptions[userId] ?? SubscriptionStatusModel.free(userId);
  }

  @override
  Future<SubscriptionStatusModel> subscribe(
      String userId, String planId, String paymentMethodId) async {
    final plan = _plans.firstWhere(
      (p) => p.id == planId,
      orElse: () => throw SubscriptionException('プランが見つかりません: $planId'),
    );

    final existing = _subscriptions[userId];
    if (existing != null && existing.isActive) {
      throw SubscriptionException('既にアクティブなサブスクリプションがあります');
    }

    if (plan.price > 0) {
      await _paymentService.createPayment(
        userId: userId,
        amount: plan.price,
        currency: plan.currency,
        paymentMethodId: paymentMethodId,
        metadata: {
          'subscription_plan_id': plan.id,
          'subscription_type': 'mock',
        },
      );
    }

    final now = DateTime.now();
    final status = SubscriptionStatusModel(
      id: 'mock-sub-${now.microsecondsSinceEpoch}',
      userId: userId,
      planId: plan.id,
      status: SubscriptionStatus.active,
      startDate: now,
      endDate: null,
      nextBillingDate: _nextBillingDateForInterval(plan.interval, now),
      paymentMethodId: plan.price > 0 ? paymentMethodId : null,
      metadata: {
        'plan_name': plan.name,
        'plan_interval': plan.interval.toString().split('.').last,
        'price': plan.price,
        'currency': plan.currency,
        'features': plan.features,
      },
    );

    _subscriptions[userId] = status;
    _addHistory(userId, plan, 'subscribed');
    return status;
  }

  @override
  Future<SubscriptionStatusModel> cancelSubscription(String userId) async {
    final current = _subscriptions[userId];
    if (current == null || !current.isActive) {
      throw SubscriptionException('キャンセル可能なサブスクリプションがありません');
    }

    final updated = current.copyWith(
      status: SubscriptionStatus.canceled,
      endDate: DateTime.now(),
      nextBillingDate: null,
    );
    _subscriptions[userId] = updated;

    final plan = _plans.firstWhere(
      (p) => p.id == updated.planId,
      orElse: () => _plans.first,
    );
    _addHistory(userId, plan, 'cancelled');
    return updated;
  }

  @override
  Future<SubscriptionStatusModel> updateSubscription(
      String userId, String newPlanId) async {
    final current = _subscriptions[userId];
    if (current == null || !current.isActive) {
      throw SubscriptionException('アップグレード可能なサブスクリプションがありません');
    }

    final newPlan = _plans.firstWhere(
      (p) => p.id == newPlanId,
      orElse: () => throw SubscriptionException('プランが見つかりません: $newPlanId'),
    );

    if (newPlan.price > 0) {
      await _paymentService.createPayment(
        userId: userId,
        amount: newPlan.price,
        currency: newPlan.currency,
        paymentMethodId: current.paymentMethodId ?? 'mock_method',
        metadata: {
          'subscription_plan_id': newPlan.id,
          'subscription_type': 'mock_upgrade',
        },
      );
    }

    final updated = current.copyWith(
      planId: newPlan.id,
      nextBillingDate:
          _nextBillingDateForInterval(newPlan.interval, DateTime.now()),
      metadata: {
        ...current.metadata,
        'plan_name': newPlan.name,
        'plan_interval': newPlan.interval.toString().split('.').last,
        'price': newPlan.price,
        'currency': newPlan.currency,
      },
    );

    _subscriptions[userId] = updated;
    _addHistory(userId, newPlan, 'updated');
    return updated;
  }

  @override
  Future<void> handleWebhook(String payload) async {
    // モックでは処理なし
  }

  @override
  Future<List<SubscriptionHistoryModel>> getSubscriptionHistory(
      String userId) async {
    return List<SubscriptionHistoryModel>.from(_history[userId] ?? const []);
  }

  void _addHistory(String userId, SubscriptionPlanModel plan, String action) {
    final entry = SubscriptionHistoryModel(
      id: 'mock-history-${DateTime.now().microsecondsSinceEpoch}',
      userId: userId,
      planId: plan.id,
      action: action,
      createdAt: DateTime.now(),
      metadata: {
        'plan_name': plan.name,
        'plan_interval': plan.interval.toString().split('.').last,
        'price': plan.price,
      },
    );

    _history.putIfAbsent(userId, () => []).insert(0, entry);
  }
}

class SubscriptionException implements Exception {
  final String message;
  SubscriptionException(this.message);

  @override
  String toString() => 'SubscriptionException: $message';
}

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  final paymentService = ref.read(paymentServiceProvider);
  if (_kStripeSecretKeyForSubscription.isEmpty) {
    debugPrint('[SubscriptionService] Stripeキーが設定されていないため、モックサービスを利用します。');
    return MockSubscriptionService(paymentService);
  }
  return SubscriptionServiceImpl(paymentService);
});
