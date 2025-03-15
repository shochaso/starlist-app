import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';

/// 取引リポジトリインターフェース
abstract class TransactionRepository {
  /// ユーザーの取引履歴を取得
  Future<List<TransactionModel>> getUserTransactions(String userId);
  
  /// スターの取引履歴を取得
  Future<List<TransactionModel>> getStarTransactions(String starId);
  
  /// 取引を作成
  Future<TransactionModel> createTransaction(TransactionModel transaction);
  
  /// 取引を更新
  Future<TransactionModel> updateTransaction(TransactionModel transaction);
  
  /// 取引をキャンセル
  Future<void> cancelTransaction(String transactionId);
  
  /// 取引を取得
  Future<TransactionModel?> getTransaction(String transactionId);
  
  /// サブスクリプションに関連する取引を取得
  Future<List<TransactionModel>> getSubscriptionTransactions(String subscriptionId);
}

/// Supabaseを使用した取引リポジトリの実装
class SupabaseTransactionRepository implements TransactionRepository {
  final SupabaseClient _supabaseClient;
  final String _tableName = 'transactions';
  
  SupabaseTransactionRepository(this._supabaseClient);
  
  @override
  Future<List<TransactionModel>> getUserTransactions(String userId) async {
    final response = await _supabaseClient
        .from(_tableName)
        .select()
        .eq('user_id', userId)
        .order('transaction_date', ascending: false);
    
    return response.map<TransactionModel>((data) => TransactionModel.fromMap(data)).toList();
  }
  
  @override
  Future<List<TransactionModel>> getStarTransactions(String starId) async {
    final response = await _supabaseClient
        .from(_tableName)
        .select()
        .eq('star_id', starId)
        .order('transaction_date', ascending: false);
    
    return response.map<TransactionModel>((data) => TransactionModel.fromMap(data)).toList();
  }
  
  @override
  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    final response = await _supabaseClient
        .from(_tableName)
        .insert(transaction.toMap())
        .select()
        .single();
    
    return TransactionModel.fromMap(response);
  }
  
  @override
  Future<TransactionModel> updateTransaction(TransactionModel transaction) async {
    final response = await _supabaseClient
        .from(_tableName)
        .update(transaction.toMap())
        .eq('id', transaction.id)
        .select()
        .single();
    
    return TransactionModel.fromMap(response);
  }
  
  @override
  Future<void> cancelTransaction(String transactionId) async {
    await _supabaseClient
        .from(_tableName)
        .update({
          'status': 'cancelled',
        })
        .eq('id', transactionId);
  }
  
  @override
  Future<TransactionModel?> getTransaction(String transactionId) async {
    final response = await _supabaseClient
        .from(_tableName)
        .select()
        .eq('id', transactionId)
        .maybeSingle();
    
    if (response == null) {
      return null;
    }
    
    return TransactionModel.fromMap(response);
  }
  
  @override
  Future<List<TransactionModel>> getSubscriptionTransactions(String subscriptionId) async {
    final response = await _supabaseClient
        .from(_tableName)
        .select()
        .eq('subscription_id', subscriptionId)
        .order('transaction_date', ascending: false);
    
    return response.map<TransactionModel>((data) => TransactionModel.fromMap(data)).toList();
  }
}
