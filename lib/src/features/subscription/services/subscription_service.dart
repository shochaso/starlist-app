import "../models/subscription_model.dart";
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../payment/services/payment_service.dart';

abstract class SubscriptionService {
  Future<List<SubscriptionPlanModel>> getAvailablePlans();
  Future<SubscriptionStatusModel> getCurrentSubscription(String userId);
  Future<SubscriptionStatusModel> subscribe(String userId, String planId, String paymentMethodId);
  Future<SubscriptionStatusModel> cancelSubscription(String userId);
  Future<SubscriptionStatusModel> updateSubscription(String userId, String newPlanId);
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

      return response.map<SubscriptionPlanModel>((json) => SubscriptionPlanModel.fromJson(json)).toList();
    } catch (e) {
      throw SubscriptionException('プラン情報の取得に失敗しました: $e');
    }
  }

  @override
  Future<SubscriptionStatusModel> getCurrentSubscription(String userId) async {
    try {
      final response = await _supabase
          .from('subscriptions')
          .select('''
            *,
            plan:subscription_plans!plan_id(*)
          ''')
          .eq('user_id', userId)
          .eq('status', 'active')
          .maybeSingle();

      if (response == null) {
        return SubscriptionStatusModel.free(userId);
      }

      return SubscriptionStatusModel.fromJson(response);
    } catch (e) {
      throw SubscriptionException('サブスクリプション状況の取得に失敗しました: $e');
    }
  }

  @override
  Future<SubscriptionStatusModel> subscribe(String userId, String planId, String paymentMethodId) async {
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
      if (existingSubscription.status == 'active') {
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
          ''')
          .single();

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
      
      if (currentSubscription.status != 'active') {
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
      await _recordSubscriptionHistory(userId, 'cancelled', currentSubscription.planId);

      // キャンセル理由のアンケート送信（オプション）
      await _sendCancellationSurvey(userId);

      return SubscriptionStatusModel.fromJson(response);
    } catch (e) {
      throw SubscriptionException('サブスクリプションのキャンセルに失敗しました: $e');
    }
  }

  @override
  Future<SubscriptionStatusModel> updateSubscription(String userId, String newPlanId) async {
    try {
      final currentSubscription = await getCurrentSubscription(userId);
      
      if (currentSubscription.status != 'active') {
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
            'next_billing_date': _calculateNextBillingDate(newPlan.billingCycle),
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
      final event = payload; // JSON解析は省略
      
      // 実際の実装では、Stripeのイベントタイプに応じて処理
      // - customer.subscription.created
      // - customer.subscription.updated
      // - customer.subscription.deleted
      // - invoice.payment_succeeded
      // - invoice.payment_failed
      
      print('Subscription webhook処理: $payload');
    } catch (e) {
      throw SubscriptionException('Webhook処理エラー: $e');
    }
  }

  @override
  Future<List<SubscriptionHistoryModel>> getSubscriptionHistory(String userId) async {
    try {
      final response = await _supabase
          .from('subscription_history')
          .select('''
            *,
            plan:subscription_plans!plan_id(name, price)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map<SubscriptionHistoryModel>((json) => SubscriptionHistoryModel.fromJson(json)).toList();
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

  double _calculateProration(SubscriptionStatusModel currentSub, SubscriptionPlanModel newPlan) {
    final now = DateTime.now();
    final nextBilling = DateTime.parse(currentSub.nextBillingDate);
    final daysRemaining = nextBilling.difference(now).inDays;
    final totalDaysInCycle = 30; // 月額の場合

    final currentPlanDailyRate = currentSub.plan.price / totalDaysInCycle;
    final newPlanDailyRate = newPlan.price / totalDaysInCycle;

    final refundAmount = currentPlanDailyRate * daysRemaining;
    final chargeAmount = newPlanDailyRate * daysRemaining;

    return chargeAmount - refundAmount;
  }

  Future<void> _recordSubscriptionHistory(String userId, String action, String planId) async {
    try {
      await _supabase
          .from('subscription_history')
          .insert({
            'user_id': userId,
            'plan_id': planId,
            'action': action,
            'created_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      print('サブスクリプション履歴記録エラー: $e');
    }
  }

  Future<void> _sendCancellationSurvey(String userId) async {
    try {
      // キャンセル理由アンケートの送信
      await _supabase
          .from('cancellation_surveys')
          .insert({
            'user_id': userId,
            'status': 'pending',
            'created_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      print('キャンセルアンケート送信エラー: $e');
    }
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
  return SubscriptionServiceImpl(paymentService);
});
