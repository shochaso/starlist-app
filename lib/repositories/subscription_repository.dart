import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subscription_model.dart';

/// サブスクリプションリポジトリインターフェース
abstract class SubscriptionRepository {
  /// ユーザーのサブスクリプション一覧を取得
  Future<List<SubscriptionModel>> getUserSubscriptions(String userId);
  
  /// スターのサブスクリプション一覧を取得
  Future<List<SubscriptionModel>> getStarSubscriptions(String starId);
  
  /// サブスクリプションを作成
  Future<SubscriptionModel> createSubscription(SubscriptionModel subscription);
  
  /// サブスクリプションを更新
  Future<SubscriptionModel> updateSubscription(SubscriptionModel subscription);
  
  /// サブスクリプションをキャンセル
  Future<void> cancelSubscription(String subscriptionId);
  
  /// サブスクリプションを取得
  Future<SubscriptionModel?> getSubscription(String subscriptionId);
}

/// Supabaseを使用したサブスクリプションリポジトリの実装
class SupabaseSubscriptionRepository implements SubscriptionRepository {
  final SupabaseClient _supabaseClient;
  final String _tableName = 'subscriptions';
  
  SupabaseSubscriptionRepository(this._supabaseClient);
  
  @override
  Future<List<SubscriptionModel>> getUserSubscriptions(String userId) async {
    final response = await _supabaseClient
        .from(_tableName)
        .select()
        .eq('user_id', userId)
        .order('start_date', ascending: false);
    
    return response.map<SubscriptionModel>((data) => SubscriptionModel.fromMap(data)).toList();
  }
  
  @override
  Future<List<SubscriptionModel>> getStarSubscriptions(String starId) async {
    final response = await _supabaseClient
        .from(_tableName)
        .select()
        .eq('star_id', starId)
        .order('start_date', ascending: false);
    
    return response.map<SubscriptionModel>((data) => SubscriptionModel.fromMap(data)).toList();
  }
  
  @override
  Future<SubscriptionModel> createSubscription(SubscriptionModel subscription) async {
    final response = await _supabaseClient
        .from(_tableName)
        .insert(subscription.toMap())
        .select()
        .single();
    
    return SubscriptionModel.fromMap(response);
  }
  
  @override
  Future<SubscriptionModel> updateSubscription(SubscriptionModel subscription) async {
    final response = await _supabaseClient
        .from(_tableName)
        .update(subscription.toMap())
        .eq('id', subscription.id)
        .select()
        .single();
    
    return SubscriptionModel.fromMap(response);
  }
  
  @override
  Future<void> cancelSubscription(String subscriptionId) async {
    await _supabaseClient
        .from(_tableName)
        .update({
          'status': 'cancelled',
          'auto_renew': false,
          'end_date': DateTime.now().toIso8601String(),
        })
        .eq('id', subscriptionId);
  }
  
  @override
  Future<SubscriptionModel?> getSubscription(String subscriptionId) async {
    final response = await _supabaseClient
        .from(_tableName)
        .select()
        .eq('id', subscriptionId)
        .maybeSingle();
    
    if (response == null) {
      return null;
    }
    
    return SubscriptionModel.fromMap(response);
  }
}
