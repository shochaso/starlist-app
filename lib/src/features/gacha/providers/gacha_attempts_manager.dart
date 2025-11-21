import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import '../models/gacha_limits_models.dart';
import '../data/gacha_limits_repository.dart';
import '../providers/gacha_limits_providers.dart';

/// ガチャ回数の状態
class GachaAttemptsState {
  final GachaAttemptsStats stats;
  final bool isLoading;
  final bool isValid;
  final String? error;
  final DateTime lastUpdated;

  const GachaAttemptsState({
    required this.stats,
    this.isLoading = false,
    this.isValid = true,
    this.error,
    required this.lastUpdated,
  });

  GachaAttemptsState copyWith({
    GachaAttemptsStats? stats,
    bool? isLoading,
    bool? isValid,
    String? error,
    DateTime? lastUpdated,
  }) {
    return GachaAttemptsState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      isValid: isValid ?? this.isValid,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// デフォルト状態（10回）
  static GachaAttemptsState defaultState() {
    return GachaAttemptsState(
      stats: GachaAttemptsStats(
        baseAttempts: 10,
        bonusAttempts: 0,
        usedAttempts: 0,
        availableAttempts: 10,
        date: DateTime.now(),
      ),
      isLoading: false,
      isValid: true,
      lastUpdated: DateTime.now(),
    );
  }
}

/// ガチャ回数管理のマネージャー（MPパターン）
class GachaAttemptsManager extends StateNotifier<GachaAttemptsState> {
  final GachaLimitsRepository _repository;
  final String userId;

  GachaAttemptsManager(this._repository, this.userId) : super(GachaAttemptsState.defaultState()) {
    _initializeAttempts();
  }

  /// 初期化（サーバーから状態を取得）
  Future<void> _initializeAttempts() async {
    if (userId.isEmpty) {
      print('GachaAttemptsManager: userId is empty, using default state');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      print('GachaAttemptsManager: Initializing attempts for user $userId');
      
      // サーバーから最新の状態を取得（自動10回設定は削除）
      final result = await Supabase.instance.client.rpc(
        'get_user_gacha_state',
        params: {'p_user_id': userId},
      );
      
      if (result is List && result.isNotEmpty) {
        final data = result[0] as Map<String, dynamic>;
        final balance = data['balance'] as int? ?? 0;
        final todayGranted = data['today_granted'] as int? ?? 0;
        
        final stats = GachaAttemptsStats(
          baseAttempts: 0, // No longer auto-granting 10 base attempts
          bonusAttempts: balance,
          usedAttempts: 0,
          availableAttempts: balance,
          date: DateTime.now(),
        );
        
        state = state.copyWith(
          stats: stats,
          isLoading: false,
          isValid: true,
          error: null,
          lastUpdated: DateTime.now(),
        );
        
        print('GachaAttemptsManager: Successfully initialized - balance: $balance, today_granted: $todayGranted');
      } else {
        // No data yet, start with 0 balance
        state = state.copyWith(
          stats: GachaAttemptsStats(
            baseAttempts: 0,
            bonusAttempts: 0,
            usedAttempts: 0,
            availableAttempts: 0,
            date: DateTime.now(),
          ),
          isLoading: false,
          isValid: true,
          error: null,
          lastUpdated: DateTime.now(),
        );
        print('GachaAttemptsManager: Initialized with 0 balance');
      }
      
      debugInfo();
    } catch (e) {
      print('GachaAttemptsManager: Failed to initialize attempts: $e');
      
      // エラー時は0からスタート
      state = state.copyWith(
        stats: GachaAttemptsStats(
          baseAttempts: 0,
          bonusAttempts: 0,
          usedAttempts: 0,
          availableAttempts: 0,
          date: DateTime.now(),
        ),
        isLoading: false,
        isValid: false,
        error: 'ガチャ回数の取得に失敗しました: $e',
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// ガチャ回数を消費
  Future<bool> consumeAttempt() async {
    if (state.stats.availableAttempts <= 0) {
      print('GachaAttemptsManager: No attempts available');
      return false;
    }

    try {
      print('GachaAttemptsManager: Consuming attempt for user $userId');
      
      // 1. サーバー側で回数を消費
      final success = await _repository.consumeGachaAttempt(userId);
      
      if (success) {
        // 2. ローカル状態を即座に更新
        final newStats = GachaAttemptsStats(
          baseAttempts: state.stats.baseAttempts,
          bonusAttempts: state.stats.bonusAttempts,
          usedAttempts: state.stats.usedAttempts + 1,
          availableAttempts: state.stats.availableAttempts - 1,
          date: state.stats.date,
        );
        
        state = state.copyWith(
          stats: newStats,
          lastUpdated: DateTime.now(),
        );
        
        print('GachaAttemptsManager: Successfully consumed attempt, remaining: ${newStats.availableAttempts}');
        return true;
      } else {
        print('GachaAttemptsManager: Server refused to consume attempt');
        await refreshAttempts(); // サーバーから最新状態を取得
        return false;
      }
    } catch (e) {
      print('GachaAttemptsManager: Failed to consume attempt: $e');
      return false;
    }
  }

  /// ボーナス回数を追加（広告視聴）
  Future<bool> addBonusAttempts(int count) async {
    try {
      print('GachaAttemptsManager: Adding $count bonus attempts for user $userId');
      
      // 1. 広告視聴をシミュレート（実際のad_serviceから呼ばれる想定）
      await Future.delayed(const Duration(seconds: 3));
      
      // 2. サーバー側でボーナス回数を追加
      final client = Supabase.instance.client;
      await client.rpc('add_gacha_bonus_attempts', params: {
        'user_id_param': userId,
        'bonus_count': count,
      });
      
      // 3. 最新統計を取得して状態更新
      await refreshAttempts();
      
      print('GachaAttemptsManager: Successfully added $count bonus attempts');
      return true;
    } catch (e) {
      print('GachaAttemptsManager: Failed to add bonus attempts: $e');
      
      // エラー時もローカルで加算（UX優先）
      final newBonusAttempts = (state.stats.bonusAttempts + count).clamp(0, 3);
      final newStats = GachaAttemptsStats(
        baseAttempts: state.stats.baseAttempts,
        bonusAttempts: newBonusAttempts,
        usedAttempts: state.stats.usedAttempts,
        availableAttempts: state.stats.baseAttempts + newBonusAttempts - state.stats.usedAttempts,
        date: state.stats.date,
      );
      
      state = state.copyWith(
        stats: newStats,
        isValid: false,
        error: 'ボーナス回数の追加に失敗しました（ローカルで仮適用）',
        lastUpdated: DateTime.now(),
      );
      
      return false;
    }
  }

  /// 統計を更新
  Future<void> refreshAttempts() async {
    try {
      print('GachaAttemptsManager: Refreshing attempts for user $userId');
      
      // サーバーから最新の状態を取得
      final result = await Supabase.instance.client.rpc(
        'get_user_gacha_state',
        params: {'p_user_id': userId},
      );
      
      if (result is List && result.isNotEmpty) {
        final data = result[0] as Map<String, dynamic>;
        final balance = data['balance'] as int? ?? 0;
        final todayGranted = data['today_granted'] as int? ?? 0;
        
        final stats = GachaAttemptsStats(
          baseAttempts: 0,
          bonusAttempts: balance,
          usedAttempts: 0,
          availableAttempts: balance,
          date: DateTime.now(),
        );
        
        state = state.copyWith(
          stats: stats,
          isValid: true,
          error: null,
          lastUpdated: DateTime.now(),
        );
        
        print('GachaAttemptsManager: Refreshed - balance: $balance, today_granted: $todayGranted');
      } else {
        // Fallback to legacy repository method if RPC not available
        final stats = await _repository.getGachaAttemptsStats(userId);
        state = state.copyWith(
          stats: stats,
          isValid: true,
          error: null,
          lastUpdated: DateTime.now(),
        );
        print('GachaAttemptsManager: Refreshed attempts (legacy): $stats');
      }
    } catch (e) {
      print('GachaAttemptsManager: Failed to refresh attempts: $e');
      
      state = state.copyWith(
        isValid: false,
        error: 'ガチャ回数の更新に失敗しました',
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// エラーをクリア
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  /// デバッグ情報を出力
  void debugInfo() {
    print('=== GachaAttemptsManager Debug Info ===');
    print('User ID: $userId');
    print('State: ${state.stats}');
    print('Loading: ${state.isLoading}');
    print('Valid: ${state.isValid}');
    print('Error: ${state.error}');
    print('Last Updated: ${state.lastUpdated}');
    print('Available Attempts: ${state.stats.availableAttempts}');
    print('=====================================');
  }

  /// 手動で10回にリセット（テスト用・レガシー）
  @Deprecated('Base attempts are no longer auto-granted')
  Future<void> resetToTenAttempts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      print('GachaAttemptsManager: Legacy resetToTenAttempts called for user $userId');
      
      // Try legacy method
      await _repository.setTodayBaseAttempts(userId, 10);
      await refreshAttempts();
      
      print('GachaAttemptsManager: Successfully reset to 10 attempts (legacy)');
      state = state.copyWith(isLoading: false);

    } catch (e) {
      final errorMessage = 'Failed to reset attempts: $e';
      print('GachaAttemptsManager: $errorMessage');
      state = state.copyWith(
        isLoading: false,
        isValid: false,
        error: errorMessage,
      );
    }
  }
}

/// ガチャ回数マネージャーのプロバイダー
final gachaAttemptsManagerProvider = StateNotifierProvider.family<GachaAttemptsManager, GachaAttemptsState, String>((ref, userId) {
  final repository = ref.watch(gachaLimitsRepositoryProvider);
  return GachaAttemptsManager(repository, userId);
});

/// 簡単にアクセスするためのプロバイダー
final currentUserGachaAttemptsProvider = Provider<GachaAttemptsState>((ref) {
  final user = Supabase.instance.client.auth.currentUser;
  if (user?.id == null) {
    return GachaAttemptsState.defaultState();
  }
  
  return ref.watch(gachaAttemptsManagerProvider(user!.id));
}); 