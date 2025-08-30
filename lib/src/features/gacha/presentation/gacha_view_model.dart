import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/gacha_limits_providers.dart';import '../../voting/providers/voting_providers.dart';
import '../../../../providers/user_provider.dart';

import '../models/gacha_models_simple.dart';
import '../domain/draw_gacha_usecase.dart';
import '../services/gacha_sound_service.dart';
import '../providers/gacha_attempts_manager.dart';

/// ガチャのビューモデル
class GachaViewModel extends StateNotifier<GachaState> {
  final DrawGachaUsecase _drawGachaUsecase;
  final GachaSoundService _soundService;
  final Ref _ref;

  GachaViewModel(this._drawGachaUsecase, this._soundService, this._ref) : super(GachaStateFactory.initial);

  /// ガチャを引く
  Future<void> draw() async {
    // ローディング中の場合は重複実行を防ぐ
    bool isLoading = false;
    state.when(
      initial: () => isLoading = false,
      loading: () => isLoading = true,
      success: (_, __, ___) => isLoading = false,
      error: (_) => isLoading = false,
    );
    if (isLoading) return;

    // 事前チェックはUI側のMPマネージャーが実施するためここでは行わない

    state = GachaStateFactory.loading;
    _soundService.playGachaSequence();

    try {
      // 1. ポイント付与「前」の残高を取得
      final user = _ref.read(currentUserProvider);
      final userId = user.id;

      // awaitと.futureを使って非同期処理の結果を安全に待つ
      int previousBalance = 0;
      try {
        final balance = await _ref.read(userStarPointBalanceProvider(userId).future);
        previousBalance = balance?.balance ?? 0;
      } catch (e) {
        // Supabase未初期化やネットワーク不通でもガチャ自体は継続
        print('Failed to fetch star point balance, fallback to 0: $e');
        previousBalance = 0;
      }

      // 2. ガチャアニメーションの時間を考慮した実行
      await Future.delayed(const Duration(milliseconds: 3500));
      final result = await _drawGachaUsecase.execute();

      // 2.5 回数消費はUI側のマネージャーで既に実施済み。ここでは行わない。

      // 3. 獲得ポイントを計算
      final gainedAmount = result.when(
        point: (amount) => amount,
        ticket: (type, name, color) => 500, // 仮のポイント
      );

      // 4. 残高マネージャーを介して即時加算（DB失敗でもUIは反映）
      try {
        final balanceManager = _ref.read(starPointBalanceManagerProvider(userId).notifier);
        await balanceManager.addPoints(gainedAmount, 'ガチャ獲得', 'gacha');
        balanceManager.debugInfo();

        // 従来のプロバイダーも無効化（互換性のため）
        _ref.invalidate(userStarPointBalanceProvider(userId));
        _ref.invalidate(currentUserStarPointBalanceProvider(userId));
      } catch (e) {
        print('balanceManager.addPoints failed: $e');
      }

      // 5. 新しい残高を計算（UI用ローカル値）
      final newBalance = previousBalance + gainedAmount;

      // 6. 成功状態を更新
      state = GachaStateFactory.success(result, previousBalance, newBalance);

      // 7. 成功後、回数/残高を同期（MPマネージャーに任せる）
      try {
        final manager = _ref.read(gachaAttemptsManagerProvider(userId).notifier);
        await manager.refreshAttempts();
      } catch (e) {}
      _ref.invalidate(gachaAttemptsStatsProvider);

      // 8. ガチャ履歴を記録（失敗は握り潰し）
      try {
        final limitsRepo = _ref.read(gachaLimitsRepositoryProvider);
        final Map<String, dynamic> resultJson = result.when(
          point: (amount) => {
            'type': 'point',
            'amount': amount,
          },
          ticket: (type, name, color) => {
            'type': 'ticket',
            'ticketType': type,
            'displayName': name,
          },
        );
        await limitsRepo.recordGachaResult(userId, resultJson, 1, 'normal');
      } catch (e) {
        print('recordGachaResult failed: $e');
      }

    } catch (e, stackTrace) {
      print('---------- GachaViewModel Error ----------');
      print(e);
      print(stackTrace);
      print('----------------------------------------');
      state = GachaStateFactory.error('エラーが発生しました。時間をおいて再度お試しください。');
    }
  }

  /// ポイント付与処理
  Future<void> _applyGachaReward(GachaResult result, String userId) async {
    // 未ログイン/未初期化時はDB処理をスキップ
    if (userId.isEmpty) {
      print('Skip DB reward apply: empty userId (likely not logged in).');
      return;
    }

    try {
      final repo = _ref.read(votingRepositoryProvider);
      await result.when(
        point: (amount) async {
          await repo.grantSPointsWithSource(userId, amount, 'ガチャ獲得', 'gacha');
        },
        ticket: (ticketType, displayName, color) async {
          final amount = ticketType == 'gold' ? 1200 : 500;
          await repo.grantSPointsWithSource(userId, amount, '$displayName（ガチャ）', 'gacha');
        },
      );
      
      // 新しい残高管理マネージャーを使用して残高を更新
      final balanceManager = _ref.read(starPointBalanceManagerProvider(userId).notifier);
      await balanceManager.refreshBalance();
      
      // デバッグ情報を出力
      balanceManager.debugInfo();
      
      // 従来のプロバイダーも無効化（互換性のため）
      _ref.invalidate(userStarPointBalanceProvider(userId));
      _ref.invalidate(currentUserStarPointBalanceProvider(userId));
    } catch (e) {
      // DB付与に失敗してもアプリの進行は止めない
      print('Failed to apply gacha reward to DB: $e');
      // ここでは例外を再スローしない
    }
  }

  /// 状態をリセット
  void reset() {
    state = GachaStateFactory.initial;
  }
}