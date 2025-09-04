import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/gacha_limits_repository.dart';
import '../models/gacha_limits_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import '../../../../providers/user_provider.dart';

/// ガチャ回数管理リポジトリのプロバイダー
final gachaLimitsRepositoryProvider = Provider<GachaLimitsRepository>((ref) {
  final supabaseService = Supabase.instance.client;
  return GachaLimitsRepository(supabaseService);
});

/// ガチャ回数統計情報のプロバイダー
final gachaAttemptsStatsProvider = FutureProvider<GachaAttemptsStats>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user.id.isEmpty) {
    return GachaAttemptsStats(
      baseAttempts: 1,
      bonusAttempts: 0,
      usedAttempts: 0,
      availableAttempts: 1,
      date: DateTime.now(),
    );
  }

  final repository = ref.watch(gachaLimitsRepositoryProvider);
  return repository.getGachaAttemptsStats(user.id);
});

/// ガチャ制限状態のプロバイダー
final gachaLimitStateProvider = Provider<GachaLimitState>((ref) {
  final user = ref.watch(currentUserProvider);
  final statsAsync = ref.watch(gachaAttemptsStatsProvider);
  
  final stats = statsAsync.maybeWhen(
    data: (data) => data,
    orElse: () => GachaAttemptsStats(
      baseAttempts: 0,
      bonusAttempts: 0,
      usedAttempts: 0,
      availableAttempts: 0,
      date: DateTime.now(),
    ),
  );

  return GachaLimitState(
    stats: stats,
    recentAdViews: [], // 必要に応じて取得
    recentHistory: [], // 必要に応じて取得
    adViewState: const AdViewInitial(),
  );
});

/// ガチャ回数消費のプロバイダー
final consumeGachaAttemptProvider = FutureProvider.family<bool, String>((ref, userId) async {
  final repository = ref.watch(gachaLimitsRepositoryProvider);
  return repository.consumeGachaAttempt(userId);
});
