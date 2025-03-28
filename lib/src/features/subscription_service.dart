import '../models/subscription_model.dart';
import '../repositories/subscription_repository.dart';

/// サブスクリプションサービスのインターフェース
abstract class SubscriptionService {
  /// 指定されたユーザーIDのすべてのサブスクリプションを取得
  Future<List<Subscription>> getUserSubscriptions(String userId);
  
  /// 指定されたスターIDのすべてのサブスクリプションを取得
  Future<List<Subscription>> getStarSubscriptions(String starId);
  
  /// 新しいサブスクリプションを作成
  Future<Subscription> createSubscription({
    required String userId,
    required String? starId,
    required List<String>? starIds,
    required SubscriptionType type,
    required SubscriptionPeriod period,
    required double price,
    required bool autoRenew,
  });
  
  /// サブスクリプションを更新（自動更新）
  Future<Subscription> renewSubscription(String subscriptionId);
  
  /// サブスクリプションをキャンセル（自動更新を無効化）
  Future<Subscription> cancelSubscription(String subscriptionId);
  
  /// サブスクリプションをアップグレード
  Future<Subscription> upgradeSubscription(String subscriptionId, SubscriptionType newType);
  
  /// サブスクリプションをダウングレード
  Future<Subscription> downgradeSubscription(String subscriptionId, SubscriptionType newType);
  
  /// サブスクリプションの期間を変更（月額から年額、またはその逆）
  Future<Subscription> changeSubscriptionPeriod(String subscriptionId, SubscriptionPeriod newPeriod);
  
  /// ユーザーのアクティブなサブスクリプションを確認
  Future<bool> hasActiveSubscription(String userId, String starId);
  
  /// ユーザーのサブスクリプションタイプを確認
  Future<SubscriptionType?> getUserSubscriptionType(String userId, String starId);
  
  /// 間もなく期限切れになるサブスクリプションの通知を送信
  Future<void> notifySubscriptionsAboutToExpire(int daysThreshold);
  
  /// 期限切れのサブスクリプションを処理
  Future<void> processExpiredSubscriptions();
}

/// サブスクリプションサービスの実装クラス
class SubscriptionServiceImpl implements SubscriptionService {
  final SubscriptionRepository _repository;
  
  SubscriptionServiceImpl(this._repository);
  
  @override
  Future<List<Subscription>> getUserSubscriptions(String userId) async {
    return await _repository.getSubscriptionsByUserId(userId);
  }
  
  @override
  Future<List<Subscription>> getStarSubscriptions(String starId) async {
    return await _repository.getSubscriptionsByStarId(starId);
  }
  
  @override
  Future<Subscription> createSubscription({
    required String userId,
    required String? starId,
    required List<String>? starIds,
    required SubscriptionType type,
    required SubscriptionPeriod period,
    required double price,
    required bool autoRenew,
  }) async {
    // サブスクリプション期間の計算
    final now = DateTime.now();
    final endDate = period == SubscriptionPeriod.monthly
        ? DateTime(now.year, now.month + 1, now.day)
        : DateTime(now.year + 1, now.month, now.day);
    
    // 新しいサブスクリプションオブジェクトの作成
    final subscription = Subscription(
      id: '', // リポジトリで生成される
      userId: userId,
      starId: starId,
      starIds: starIds,
      type: type,
      period: period,
      startDate: now,
      endDate: endDate,
      isActive: true,
      price: price,
      autoRenew: autoRenew,
      createdAt: now,
      updatedAt: now,
    );
    
    // リポジトリを通じてサブスクリプションを作成
    return await _repository.createSubscription(subscription);
  }
  
  @override
  Future<Subscription> renewSubscription(String subscriptionId) async {
    return await _repository.renewSubscription(subscriptionId);
  }
  
  @override
  Future<Subscription> cancelSubscription(String subscriptionId) async {
    return await _repository.cancelSubscription(subscriptionId);
  }
  
  @override
  Future<Subscription> upgradeSubscription(String subscriptionId, SubscriptionType newType) async {
    // 現在のサブスクリプションを取得
    final subscription = await _repository.getSubscriptionById(subscriptionId);
    if (subscription == null) {
      throw Exception('Subscription not found');
    }
    
    // 新しいタイプが現在のタイプよりも上位であることを確認
    if (newType.index <= subscription.type.index) {
      throw Exception('New subscription type must be higher than current type');
    }
    
    // 新しい価格を計算（実際のアプリケーションでは価格テーブルから取得）
    double newPrice;
    switch (newType) {
      case SubscriptionType.light:
        newPrice = 500.0; // 例: ライトプランは500円/月
        break;
      case SubscriptionType.standard:
        newPrice = 1000.0; // 例: スタンダードプランは1000円/月
        break;
      case SubscriptionType.premium:
        newPrice = 2000.0; // 例: プレミアムプランは2000円/月
        break;
      default:
        newPrice = 0.0; // 無料プラン
    }
    
    // 年間契約の場合は12ヶ月分の15%割引を適用
    if (subscription.period == SubscriptionPeriod.yearly) {
      newPrice = newPrice * 12 * 0.85;
    }
    
    // サブスクリプションを更新
    final updatedSubscription = subscription.copyWith(
      type: newType,
      price: newPrice,
      updatedAt: DateTime.now(),
    );
    
    return await _repository.updateSubscription(updatedSubscription);
  }
  
  @override
  Future<Subscription> downgradeSubscription(String subscriptionId, SubscriptionType newType) async {
    // 現在のサブスクリプションを取得
    final subscription = await _repository.getSubscriptionById(subscriptionId);
    if (subscription == null) {
      throw Exception('Subscription not found');
    }
    
    // 新しいタイプが現在のタイプよりも下位であることを確認
    if (newType.index >= subscription.type.index) {
      throw Exception('New subscription type must be lower than current type');
    }
    
    // 新しい価格を計算（実際のアプリケーションでは価格テーブルから取得）
    double newPrice;
    switch (newType) {
      case SubscriptionType.light:
        newPrice = 500.0; // 例: ライトプランは500円/月
        break;
      case SubscriptionType.standard:
        newPrice = 1000.0; // 例: スタンダードプランは1000円/月
        break;
      case SubscriptionType.premium:
        newPrice = 2000.0; // 例: プレミアムプランは2000円/月
        break;
      default:
        newPrice = 0.0; // 無料プラン
    }
    
    // 年間契約の場合は12ヶ月分の15%割引を適用
    if (subscription.period == SubscriptionPeriod.yearly) {
      newPrice = newPrice * 12 * 0.85;
    }
    
    // サブスクリプションを更新（次の更新日から適用）
    final updatedSubscription = subscription.copyWith(
      type: newType,
      price: newPrice,
      updatedAt: DateTime.now(),
    );
    
    return await _repository.updateSubscription(updatedSubscription);
  }
  
  @override
  Future<Subscription> changeSubscriptionPeriod(String subscriptionId, SubscriptionPeriod newPeriod) async {
    // 現在のサブスクリプションを取得
    final subscription = await _repository.getSubscriptionById(subscriptionId);
    if (subscription == null) {
      throw Exception('Subscription not found');
    }
    
    // 期間が同じ場合は何もしない
    if (subscription.period == newPeriod) {
      return subscription;
    }
    
    // 新しい価格と終了日を計算
    double newPrice = subscription.price;
    DateTime newEndDate;
    final now = DateTime.now();
    
    if (newPeriod == SubscriptionPeriod.yearly) {
      // 月額から年額への変更: 12ヶ月分の15%割引を適用
      newPrice = (subscription.price * 12) * 0.85;
      newEndDate = DateTime(now.year + 1, now.month, now.day);
    } else {
      // 年額から月額への変更: 年額÷12で月額を計算
      newPrice = subscription.price / (12 * 0.85);
      newEndDate = DateTime(now.year, now.month + 1, now.day);
    }
    
    // サブスクリプションを更新
    final updatedSubscription = subscription.copyWith(
      period: newPeriod,
      price: newPrice,
      startDate: now,
      endDate: newEndDate,
      updatedAt: now,
    );
    
    return await _repository.updateSubscription(updatedSubscription);
  }
  
  @override
  Future<bool> hasActiveSubscription(String userId, String starId) async {
    // ユーザーのアクティブなサブスクリプションを取得
    final subscriptions = await _repository.getActiveSubscriptionsByUserId(userId);
    
    // 指定されたスターIDに対するアクティブなサブスクリプションがあるか確認
    return subscriptions.any((subscription) => 
      subscription.starId == starId || 
      (subscription.starIds != null && subscription.starIds!.contains(starId))
    );
  }
  
  @override
  Future<SubscriptionType?> getUserSubscriptionType(String userId, String starId) async {
    // ユーザーのアクティブなサブスクリプションを取得
    final subscriptions = await _repository.getActiveSubscriptionsByUserId(userId);
    
    // 指定されたスターIDに対するアクティブなサブスクリプションを検索
    for (final subscription in subscriptions) {
      if (subscription.starId == starId || 
          (subscription.starIds != null && subscription.starIds!.contains(starId))) {
        return subscription.type;
      }
    }
    
    // アクティブなサブスクリプションが見つからない場合はnullを返す
    return null;
  }
  
  @override
  Future<void> notifySubscriptionsAboutToExpire(int daysThreshold) async {
    // 間もなく期限切れになるサブスクリプションを取得
    final subscriptions = await _repository.getSubscriptionsAboutToExpire(daysThreshold);
    
    // 各サブスクリプションに対して通知を送信
    for (final subscription in subscriptions) {
      // TODO: 通知サービスを使用して通知を送信
      print('Subscription ${subscription.id} for user ${subscription.userId} is about to expire on ${subscription.endDate}');
    }
  }
  
  @override
  Future<void> processExpiredSubscriptions() async {
    // 期限切れのサブスクリプションを取得
    final expiredSubscriptions = await _repository.getExpiredSubscriptions();
    
    // 各期限切れサブスクリプションを処理
    for (final subscription in expiredSubscriptions) {
      if (subscription.autoRenew) {
        // 自動更新が有効な場合は更新
        try {
          await renewSubscription(subscription.id);
          // TODO: 更新成功の通知を送信
        } catch (e) {
          // 更新に失敗した場合（支払い失敗など）
          // TODO: 更新失敗の通知を送信
          print('Failed to renew subscription ${subscription.id}: $e');
        }
      } else {
        // 自動更新が無効な場合は非アクティブに設定
        final updatedSubscription = subscription.copyWith(
          isActive: false,
          updatedAt: DateTime.now(),
        );
        await _repository.updateSubscription(updatedSubscription);
        // TODO: 期限切れの通知を送信
      }
    }
  }
}
