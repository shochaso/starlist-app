import 'package:flutter/material.dart';
import '../../../shared/models/subscription_model.dart';
import '../../../shared/models/user_model.dart';

/// サブスクリプション機能のビューモデル
/// サブスクリプションの状態管理と操作を担当する
class SubscriptionViewModel extends ChangeNotifier {
  final SubscriptionService _subscriptionService;
  
  List<SubscriptionModel> _activeSubscriptions = [];
  List<SubscriptionTierModel> _availableTiers = [];
  UserModel? _selectedStar;
  bool _isLoading = false;
  String? _error;
  
  SubscriptionViewModel({
    required SubscriptionService subscriptionService,
  }) : _subscriptionService = subscriptionService;
  
  /// アクティブなサブスクリプションのリスト
  List<SubscriptionModel> get activeSubscriptions => _activeSubscriptions;
  
  /// 利用可能なサブスクリプションティアのリスト
  List<SubscriptionTierModel> get availableTiers => _availableTiers;
  
  /// 選択されたスター
  UserModel? get selectedStar => _selectedStar;
  
  /// 読み込み中かどうか
  bool get isLoading => _isLoading;
  
  /// エラーメッセージ
  String? get error => _error;
  
  /// アクティブなサブスクリプションを読み込む
  Future<void> loadActiveSubscriptions() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final subscriptions = await _subscriptionService.getActiveSubscriptions();
      
      _activeSubscriptions = subscriptions;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// スターのサブスクリプションティアを読み込む
  Future<void> loadStarSubscriptionTiers(String starId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final star = await _subscriptionService.getStarProfile(starId);
      _selectedStar = star;
      
      final tiers = await _subscriptionService.getStarSubscriptionTiers(starId);
      
      _availableTiers = tiers;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// サブスクリプションを購入する
  Future<bool> purchaseSubscription({
    required String starId,
    required int tierId,
    required String paymentMethod,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final success = await _subscriptionService.purchaseSubscription(
        starId: starId,
        tierId: tierId,
        paymentMethod: paymentMethod,
      );
      
      if (success) {
        await loadActiveSubscriptions();
      }
      
      _isLoading = false;
      notifyListeners();
      
      return success;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// サブスクリプションをキャンセルする
  Future<bool> cancelSubscription(String subscriptionId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final success = await _subscriptionService.cancelSubscription(subscriptionId);
      
      if (success) {
        await loadActiveSubscriptions();
      }
      
      _isLoading = false;
      notifyListeners();
      
      return success;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// サブスクリプションを更新する
  Future<bool> updateSubscription({
    required String subscriptionId,
    required int newTierId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final success = await _subscriptionService.updateSubscription(
        subscriptionId: subscriptionId,
        newTierId: newTierId,
      );
      
      if (success) {
        await loadActiveSubscriptions();
      }
      
      _isLoading = false;
      notifyListeners();
      
      return success;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}

/// サブスクリプションティアモデル
class SubscriptionTierModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String billingCycle;
  final List<String> benefits;
  
  SubscriptionTierModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.billingCycle,
    required this.benefits,
  });
}

/// サブスクリプションサービスのインターフェース
/// サブスクリプションデータの取得と操作を担当する
abstract class SubscriptionService {
  /// アクティブなサブスクリプションを取得する
  Future<List<SubscriptionModel>> getActiveSubscriptions();
  
  /// スターのプロフィールを取得する
  Future<UserModel> getStarProfile(String starId);
  
  /// スターのサブスクリプションティアを取得する
  Future<List<SubscriptionTierModel>> getStarSubscriptionTiers(String starId);
  
  /// サブスクリプションを購入する
  Future<bool> purchaseSubscription({
    required String starId,
    required int tierId,
    required String paymentMethod,
  });
  
  /// サブスクリプションをキャンセルする
  Future<bool> cancelSubscription(String subscriptionId);
  
  /// サブスクリプションを更新する
  Future<bool> updateSubscription({
    required String subscriptionId,
    required int newTierId,
  });
}
