class SubscriptionService {
  final SupabaseClient _supabase;
  final PaymentService _paymentService;

  SubscriptionService(this._supabase, this._paymentService);

  // 現在のサブスクリプション情報の取得
  Future<SubscriptionModel?> getCurrentSubscription() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('subscriptions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return SubscriptionModel.fromMap(response);
    } catch (e) {
      print('サブスクリプション情報取得エラー: $e');
      return null;
    }
  }

  // サブスクリプションのアップグレード
  Future<bool> upgradeSubscription(String planId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // 決済処理
      final paymentResult = await _paymentService.processPayment(planId);
      if (!paymentResult.success) return false;

      // サブスクリプション情報更新
      await _supabase.from('subscriptions').insert({
        'user_id': userId,
        'plan_id': planId,
        'status': 'active',
        'payment_id': paymentResult.paymentId,
        'start_date': DateTime.now().toIso8601String(),
        'end_date': DateTime.now().add(Duration(days: 30)).toIso8601String(),
      });

      // ユーザー情報更新
      await _supabase.from('users').update({
        'subscription_status': 'premium',
      }).eq('id', userId);

      return true;
    } catch (e) {
      print('サブスクリプションアップグレードエラー: $e');
      return false;
    }
  }
  
  // サブスクリプションのキャンセル
  Future<bool> cancelSubscription() async {
    // 実装を追加
  }
} 