import 'package:flutter/foundation.dart';
import '../models/subscription_model.dart';
import '../models/transaction_model.dart';
import '../repositories/subscription_repository.dart';
import '../repositories/transaction_repository.dart';
import 'payment_service.dart';
import 'notification_service.dart';

/// サブスクリプションのライフサイクルイベントを表すenum
enum SubscriptionEvent {
  /// 作成
  created,
  
  /// 有効化
  activated,
  
  /// 更新
  renewed,
  
  /// 支払い失敗
  paymentFailed,
  
  /// キャンセル
  cancelled,
  
  /// 期限切れ
  expired,
}

/// サブスクリプションのライフサイクルを表すクラス
class SubscriptionLifecycle {
  final String id;
  final String subscriptionId;
  final SubscriptionEvent event;
  final DateTime eventDate;
  final Map<String, dynamic>? metadata;
  
  /// コンストラクタ
  SubscriptionLifecycle({
    required this.id,
    required this.subscriptionId,
    required this.event,
    required this.eventDate,
    this.metadata,
  });
  
  /// JSONからSubscriptionLifecycleを生成するファクトリメソッド
  factory SubscriptionLifecycle.fromJson(Map<String, dynamic> json) {
    return SubscriptionLifecycle(
      id: json['id'],
      subscriptionId: json['subscriptionId'],
      event: SubscriptionEvent.values.firstWhere(
        (e) => e.toString() == 'SubscriptionEvent.${json['event']}',
        orElse: () => SubscriptionEvent.created,
      ),
      eventDate: DateTime.parse(json['eventDate']),
      metadata: json['metadata'],
    );
  }
  
  /// SubscriptionLifecycleをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subscriptionId': subscriptionId,
      'event': event.toString().split('.').last,
      'eventDate': eventDate.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// サブスクリプションライフサイクル管理サービスクラス
class SubscriptionLifecycleService {
  final SubscriptionRepository _subscriptionRepository;
  final TransactionRepository _transactionRepository;
  final PaymentService _paymentService;
  final NotificationService _notificationService;
  
  /// コンストラクタ
  SubscriptionLifecycleService({
    required SubscriptionRepository subscriptionRepository,
    required TransactionRepository transactionRepository,
    required PaymentService paymentService,
    required NotificationService notificationService,
  }) : _subscriptionRepository = subscriptionRepository,
       _transactionRepository = transactionRepository,
       _paymentService = paymentService,
       _notificationService = notificationService;
  
  /// サブスクリプションを作成する
  Future<Subscription> createSubscription({
    required String userId,
    required SubscriptionPlanType planType,
    required PaymentMethodType paymentMethodType,
    required String paymentMethodId,
    bool isAutoRenew = true,
    double? discountRate,
    String? discountReason,
  }) async {
    try {
      // プラン情報を取得
      final planInfo = _getPlanInfo(planType);
      
      // 開始日と終了日を設定
      final now = DateTime.now();
      final startDate = now;
      final endDate = now.add(const Duration(days: 30)); // 30日間のサブスクリプション
      
      // 割引を適用
      final price = discountRate != null 
          ? planInfo['price'] * (1 - discountRate) 
          : planInfo['price'];
      
      // サブスクリプションを作成
      final subscription = Subscription(
        id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        planType: planType,
        startDate: startDate,
        endDate: endDate,
        isAutoRenew: isAutoRenew,
        price: price,
        status: SubscriptionStatus.pending,
        paymentMethod: paymentMethodType,
        lastBillingDate: now,
        nextBillingDate: endDate,
        discountRate: discountRate,
        discountReason: discountReason,
        createdAt: now,
        updatedAt: now,
      );
      
      // サブスクリプションを保存
      final savedSubscription = await _subscriptionRepository.saveSubscription(subscription);
      
      // 支払い処理を実行
      await _paymentService.processPayment(
        userId: userId,
        targetId: null,
        amount: price,
        currency: 'JPY',
        transactionType: TransactionType.subscription,
        methodType: paymentMethodType,
        paymentMethodId: paymentMethodId,
        metadata: {
          'subscriptionId': savedSubscription.id,
          'planType': planType.toString().split('.').last,
        },
      );
      
      // サブスクリプションのステータスを更新
      final activatedSubscription = savedSubscription.copyWith(
        status: SubscriptionStatus.active,
        updatedAt: DateTime.now(),
      );
      
      // 更新したサブスクリプションを保存
      final finalSubscription = await _subscriptionRepository.saveSubscription(activatedSubscription);
      
      // ライフサイクルイベントを記録
      await _recordLifecycleEvent(
        subscriptionId: finalSubscription.id,
        event: SubscriptionEvent.activated,
      );
      
      // ユーザーに通知
      await _notificationService.sendNotification(
        userId: userId,
        title: 'サブスクリプションが開始されました',
        body: '${planType.toString().split('.').last}プランのサブスクリプションが正常に開始されました。',
        data: {'subscriptionId': finalSubscription.id},
      );
      
      return finalSubscription;
    } catch (e) {
      debugPrint('サブスクリプション作成エラー: $e');
      rethrow;
    }
  }
  
  /// サブスクリプションを更新する
  Future<Subscription> renewSubscription(String subscriptionId) async {
    try {
      // サブスクリプションを取得
      final subscription = await _subscriptionRepository.getSubscriptionById(subscriptionId);
      
      // すでに期限切れまたはキャンセル済みの場合はエラー
      if (subscription.status == SubscriptionStatus.expired || 
          subscription.status == SubscriptionStatus.cancelled) {
        throw Exception('期限切れまたはキャンセル済みのサブスクリプションは更新できません');
      }
      
      // 新しい終了日を計算
      final newEndDate = subscription.endDate.add(const Duration(days: 30));
      
      // 支払い処理を実行
      await _paymentService.processPayment(
        userId: subscription.userId,
        targetId: null,
        amount: subscription.price,
        currency: 'JPY',
        transactionType: TransactionType.subscription,
        methodType: subscription.paymentMethod,
        paymentMethodId: subscription.id, // 実際の実装では保存された支払い方法IDを使用
        metadata: {
          'subscriptionId': subscription.id,
          'planType': subscription.planType.toString().split('.').last,
          'renewal': true,
        },
      );
      
      // サブスクリプションを更新
      final renewedSubscription = subscription.copyWith(
        endDate: newEndDate,
        lastBillingDate: DateTime.now(),
        nextBillingDate: newEndDate,
        status: SubscriptionStatus.active,
        updatedAt: DateTime.now(),
      );
      
      // 更新したサブスクリプションを保存
      final savedSubscription = await _subscriptionRepository.saveSubscription(renewedSubscription);
      
      // ライフサイクルイベントを記録
      await _recordLifecycleEvent(
        subscriptionId: savedSubscription.id,
        event: SubscriptionEvent.renewed,
      );
      
      // ユーザーに通知
      await _notificationService.sendNotification(
        userId: subscription.userId,
        title: 'サブスクリプションが更新されました',
        body: '${subscription.planType.toString().split('.').last}プランのサブスクリプションが正常に更新されました。',
        data: {'subscriptionId': savedSubscription.id},
      );
      
      return savedSubscription;
    } catch (e) {
      debugPrint('サブスクリプション更新エラー: $e');
      
      // エラーが発生した場合はライフサイクルイベントを記録
      await _recordLifecycleEvent(
        subscriptionId: subscriptionId,
        event: SubscriptionEvent.paymentFailed,
        metadata: {'error': e.toString()},
      );
      
      rethrow;
    }
  }
  
  /// サブスクリプションをキャンセルする
  Future<Subscription> cancelSubscription(String subscriptionId) async {
    try {
      // サブスクリプションを取得
      final subscription = await _subscriptionRepository.getSubscriptionById(subscriptionId);
      
      // すでに期限切れまたはキャンセル済みの場合はそのまま返す
      if (subscription.status == SubscriptionStatus.expired || 
          subscription.status == SubscriptionStatus.cancelled) {
        return subscription;
      }
      
      // サブスクリプションをキャンセル
      final cancelledSubscription = subscription.copyWith(
        isAutoRenew: false,
        status: SubscriptionStatus.cancelled,
        updatedAt: DateTime.now(),
      );
      
      // 更新したサブスクリプションを保存
      final savedSubscription = await _subscriptionRepository.saveSubscription(cancelledSubscription);
      
      // ライフサイクルイベントを記録
      await _recordLifecycleEvent(
        subscriptionId: savedSubscription.id,
        event: SubscriptionEvent.cancelled,
      );
      
      // ユーザーに通知
      await _notificationService.sendNotification(
        userId: subscription.userId,
        title: 'サブスクリプションがキャンセルされました',
        body: '${subscription.planType.toString().split('.').last}プランのサブスクリプションがキャンセルされました。現在の期間終了まではサービスをご利用いただけます。',
        data: {'subscriptionId': savedSubscription.id},
      );
      
      return savedSubscription;
    } catch (e) {
      debugPrint('サブスクリプションキャンセルエラー: $e');
      rethrow;
    }
  }
  
  /// 支払い失敗時の処理
  Future<Subscription> handlePaymentFailure(String subscriptionId) async {
    try {
      // サブスクリプションを取得
      final subscription = await _subscriptionRepository.getSubscriptionById(subscriptionId);
      
      // サブスクリプションのステータスを更新
      final updatedSubscription = subscription.copyWith(
        status: SubscriptionStatus.paymentFailed,
        updatedAt: DateTime.now(),
      );
      
      // 更新したサブスクリプションを保存
      final savedSubscription = await _subscriptionRepository.saveSubscription(updatedSubscription);
      
      // ライフサイクルイベントを記録
      await _recordLifecycleEvent(
        subscriptionId: savedSubscription.id,
        event: SubscriptionEvent.paymentFailed,
      );
      
      // ユーザーに通知
      await _notificationService.sendNotification(
        userId: subscription.userId,
        title: 'サブスクリプションの支払いに失敗しました',
        body: '${subscription.planType.toString().split('.').last}プランのサブスクリプション支払いに失敗しました。お支払い方法を更新してください。',
        data: {'subscriptionId': savedSubscription.id},
      );
      
      return savedSubscription;
    } catch (e) {
      debugPrint('支払い失敗処理エラー: $e');
      rethrow;
    }
  }
  
  /// 期限切れサブスクリプションを処理する
  Future<void> processExpiredSubscriptions() async {
    try {
      // 期限切れのサブスクリプションを取得
      final now = DateTime.now();
      final expiredSubscriptions = await _subscriptionRepository.getExpiredSubscriptions(now);
      
      for (final subscription in expiredSubscriptions) {
        // 自動更新が有効な場合は更新を試みる
        if (subscription.isAutoRenew) {
          try {
            await renewSubscription(subscription.id);
          } catch (e) {
            // 更新に失敗した場合は支払い失敗として処理
            await handlePaymentFailure(subscription.id);
          }
        } else {
          // 自動更新が無効な場合は期限切れとして処理
          final expiredSubscription = subscription.copyWith(
            status: SubscriptionStatus.expired,
            updatedAt: now,
          );
          
          // 更新したサブスクリプションを保存
          final savedSubscription = await _subscriptionRepository.saveSubscription(expiredSubscription);
          
          // ライフサイクルイベントを記録
          await _recordLifecycleEvent(
            subscriptionId: savedSubscription.id,
            event: SubscriptionEvent.expired,
          );
          
          // ユーザーに通知
          await _notificationService.sendNotification(
            userId: subscription.userId,
            title: 'サブスクリプションが期限切れになりました',
            body: '${subscription.planType.toString().split('.').last}プランのサブスクリプションが期限切れになりました。引き続きサービスをご利用いただくには、サブスクリプションを更新してください。',
            data: {'subscriptionId': savedSubscription.id},
          );
        }
      }
    } catch (e) {
      debugPrint('期限切れサブスクリプション処理エラー: $e');
      rethrow;
    }
  }
  
  /// 更新リマインダーを送信する
  Future<void> sendRenewalReminders() async {
    try {
      // 3日以内に期限切れになるサブスクリプションを取得
      final now = DateTime.now();
      final threeDaysLater = now.add(const Duration(days: 3));
      final subscriptions = await _subscriptionRepository.getSubscriptionsExpiringBefore(threeDaysLater);
      
      for (final subscription in subscriptions) {
        // 自動更新が有効な場合はリマインダーを送信
        if (subscription.isAutoRenew) {
          await _notificationService.sendNotification(
            userId: subscription.userId,
            title: 'サブスクリプションの自動更新が近づいています',
            body: '${subscription.planType.toString().split('.').last}プランのサブスクリプションは3日以内に自動更新されます。',
            data: {'subscriptionId': subscription.id},
          );
        } else {
          // 自動更新が無効な場合は期限切れリマインダーを送信
          await _notificationService.sendNotification(
            userId: subscription.userId,
            title: 'サブスクリプションの期限切れが近づいています',
            body: '${subscription.planType.toString().split('.').last}プランのサブスクリプションは3日以内に期限切れになります。引き続きサービスをご利用いただくには、サブスクリプションを更新してください。',
            data: {'subscriptionId': subscription.id},
          );
        }
      }
    } catch (e) {
      debugPrint('更新リマインダー送信エラー: $e');
      rethrow;
    }
  }
  
  /// サブスクリプションプランの情報を取得する
  Map<String, dynamic> _getPlanInfo(SubscriptionPlanType planType) {
    switch (planType) {
      case SubscriptionPlanType.free:
        return {'price': 0, 'name': '無料プラン'};
      case SubscriptionPlanType.light:
        return {'price': 980, 'name': 'ライトプラン'};
      case SubscriptionPlanType.standard:
        return {'price': 1980, 'name': 'スタンダードプラン'};
      case SubscriptionPlanType.premium:
        return {'price': 2980, 'name': 'プレミアムプラン'};
      default:
        return {'price': 0, 'name': '無料プラン'};
    }
  }
  
  /// ライフサイクルイベントを記録する
  Future<void> _recordLifecycleEvent({
    required String subscriptionId,
    required SubscriptionEvent event,
    Map<String, dynamic>? metadata,
  }) async {
    final lifecycleEvent = SubscriptionLifecycle(
      id: 'event_${DateTime.now().millisecondsSinceEpoch}',
      subscriptionId: subscriptionId,
      event: event,
      eventDate: DateTime.now(),
      metadata: metadata,
    );
    
    // 実際の実装ではライフサイクルイベントをデータベースに保存
    debugPrint('ライフサイクルイベント記録: ${lifecycleEvent.toJson()}');
  }
}
