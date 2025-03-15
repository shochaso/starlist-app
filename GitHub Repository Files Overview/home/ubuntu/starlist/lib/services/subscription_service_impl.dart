import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subscription_model.dart';
import '../repositories/subscription_repository.dart';

/// サブスクリプションサービスインターフェース
abstract class SubscriptionService {
  /// ユーザーのサブスクリプション一覧を取得
  Future<List<SubscriptionModel>> getUserSubscriptions(String userId);
  
  /// スターのサブスクリプション一覧を取得
  Future<List<SubscriptionModel>> getStarSubscriptions(String starId);
  
  /// サブスクリプションを作成
  Future<SubscriptionModel> createSubscription({
    required String userId,
    required String starId,
    required String planId,
    required double amount,
    required String currency,
    required String paymentMethod,
    bool autoRenew = true,
    Map<String, dynamic>? metadata,
  });
  
  /// サブスクリプションを更新
  Future<SubscriptionModel> updateSubscription(SubscriptionModel subscription);
  
  /// サブスクリプションをキャンセル
  Future<void> cancelSubscription(String subscriptionId);
  
  /// サブスクリプションを取得
  Future<SubscriptionModel?> getSubscription(String subscriptionId);
  
  /// サブスクリプションの更新
  Future<SubscriptionModel> renewSubscription(String subscriptionId);
}

/// サブスクリプションサービスの実装
class SubscriptionServiceImpl implements SubscriptionService {
  final SubscriptionRepository _subscriptionRepository;
  
  SubscriptionServiceImpl(this._subscriptionRepository);
  
  @override
  Future<List<SubscriptionModel>> getUserSubscriptions(String userId) {
    return _subscriptionRepository.getUserSubscriptions(userId);
  }
  
  @override
  Future<List<SubscriptionModel>> getStarSubscriptions(String starId) {
    return _subscriptionRepository.getStarSubscriptions(starId);
  }
  
  @override
  Future<SubscriptionModel> createSubscription({
    required String userId,
    required String starId,
    required String planId,
    required double amount,
    required String currency,
    required String paymentMethod,
    bool autoRenew = true,
    Map<String, dynamic>? metadata,
  }) async {
    final now = DateTime.now();
    // 1ヶ月後の日付を計算
    final endDate = DateTime(now.year, now.month + 1, now.day);
    
    final subscription = SubscriptionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // 実際の実装ではUUIDなどを使用
      userId: userId,
      starId: starId,
      planId: planId,
      startDate: now,
      endDate: endDate,
      status: 'active',
      amount: amount,
      currency: currency,
      paymentMethod: paymentMethod,
      autoRenew: autoRenew,
      metadata: metadata,
    );
    
    return _subscriptionRepository.createSubscription(subscription);
  }
  
  @override
  Future<SubscriptionModel> updateSubscription(SubscriptionModel subscription) {
    return _subscriptionRepository.updateSubscription(subscription);
  }
  
  @override
  Future<void> cancelSubscription(String subscriptionId) {
    return _subscriptionRepository.cancelSubscription(subscriptionId);
  }
  
  @override
  Future<SubscriptionModel?> getSubscription(String subscriptionId) {
    return _subscriptionRepository.getSubscription(subscriptionId);
  }
  
  @override
  Future<SubscriptionModel> renewSubscription(String subscriptionId) async {
    final subscription = await _subscriptionRepository.getSubscription(subscriptionId);
    
    if (subscription == null) {
      throw Exception('Subscription not found');
    }
    
    if (subscription.status != 'active') {
      throw Exception('Cannot renew inactive subscription');
    }
    
    final now = DateTime.now();
    final currentEndDate = subscription.endDate ?? now;
    // 現在の終了日から1ヶ月後の日付を計算
    final newEndDate = DateTime(currentEndDate.year, currentEndDate.month + 1, currentEndDate.day);
    
    final updatedSubscription = subscription.copyWith(
      endDate: newEndDate,
    );
    
    return _subscriptionRepository.updateSubscription(updatedSubscription);
  }
}
