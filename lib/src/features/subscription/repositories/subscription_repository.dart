import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/subscription_model.dart';
import '../models/subscription_plan_model.dart';

class SubscriptionRepository {
  final SupabaseClient _client;
  final String _subscriptionsTable = 'subscriptions';
  final String _plansTable = 'subscription_plans';
  
  SubscriptionRepository(this._client);
  
  /// 特定のユーザーのアクティブなサブスクリプション一覧取得
  Future<List<SubscriptionModel>> getActiveSubscriptions(String userId) async {
    try {
      final data = await _client
          .from(_subscriptionsTable)
          .select()
          .eq('user_id', userId)
          .eq('status', 'active');
      
      return List<Map<String, dynamic>>.from(data)
          .map((item) => SubscriptionModel.fromJson(item))
          .toList();
    } catch (e) {
      log('アクティブなサブスクリプション一覧の取得に失敗しました: $e');
      return [];
    }
  }
  
  /// 特定のスターのサブスクライバー一覧取得
  Future<List<SubscriptionModel>> getStarSubscribers(String starId) async {
    try {
      final data = await _client
          .from(_subscriptionsTable)
          .select()
          .eq('star_id', starId)
          .eq('status', 'active');
      
      return List<Map<String, dynamic>>.from(data)
          .map((item) => SubscriptionModel.fromJson(item))
          .toList();
    } catch (e) {
      log('スターのサブスクライバー一覧の取得に失敗しました: $e');
      return [];
    }
  }
  
  /// サブスクリプションプラン一覧取得
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans() async {
    try {
      final data = await _client
          .from(_plansTable)
          .select()
          .eq('is_active', true)
          .order('price');
      
      return List<Map<String, dynamic>>.from(data)
          .map((item) => SubscriptionPlanModel.fromJson(item))
          .toList();
    } catch (e) {
      log('サブスクリプションプラン一覧の取得に失敗しました: $e');
      return [];
    }
  }
  
  /// サブスクリプション作成
  Future<SubscriptionModel?> createSubscription({
    required String userId,
    required String starId,
    required String planId,
  }) async {
    try {
      final newId = const Uuid().v4();
      final now = DateTime.now();
      
      // プランの情報を取得してend_dateを計算
      final planData = await _client
          .from(_plansTable)
          .select()
          .eq('id', planId)
          .single();
      
      final plan = SubscriptionPlanModel.fromJson(planData);
      
      // 期間の計算（月額か年額か）
      final DateTime endDate = plan.interval == SubscriptionInterval.monthly
          ? DateTime(now.year, now.month + 1, now.day)
          : DateTime(now.year + 1, now.month, now.day);
          
      final subscription = {
        'id': newId,
        'user_id': userId,
        'star_id': starId,
        'plan_id': planId,
        'status': 'active',
        'start_date': now.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'auto_renew': true,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      
      await _client
          .from(_subscriptionsTable)
          .insert(subscription);
      
      return SubscriptionModel.fromJson(subscription);
    } catch (e) {
      log('サブスクリプションの作成に失敗しました: $e');
      return null;
    }
  }
  
  /// サブスクリプションのキャンセル
  Future<bool> cancelSubscription(String subscriptionId) async {
    try {
      final now = DateTime.now();
      
      await _client
          .from(_subscriptionsTable)
          .update({
            'status': 'canceled',
            'auto_renew': false,
            'updated_at': now.toIso8601String(),
          })
          .eq('id', subscriptionId);
      
      return true;
    } catch (e) {
      log('サブスクリプションのキャンセルに失敗しました: $e');
      return false;
    }
  }
  
  /// サブスクリプションの状態確認
  Future<bool> checkSubscriptionStatus(String userId, String starId) async {
    try {
      final data = await _client
          .from(_subscriptionsTable)
          .select()
          .eq('user_id', userId)
          .eq('star_id', starId)
          .eq('status', 'active');
      
      return data.isNotEmpty;
    } catch (e) {
      log('サブスクリプション状態の確認に失敗しました: $e');
      return false;
    }
  }
} 