import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import '../models/gacha_limits_models.dart';

/// 広告サービスの抽象クラス
abstract class AdService {
  /// 広告を読み込み
  Future<void> loadAd(AdType adType);

  /// 広告を表示
  Future<AdViewResult> showAd(AdType adType);

  /// 広告が利用可能かどうか
  Future<bool> isAdAvailable(AdType adType);

  /// 広告を破棄
  Future<void> dispose();
}

/// 広告視聴の結果
class AdViewResult {
  final bool success;
  final int rewardedAttempts;
  final String? errorMessage;

  AdViewResult({
    required this.success,
    this.rewardedAttempts = 0,
    this.errorMessage,
  });
}

/// モック広告サービス（実際の広告SDKがない場合の代替）
class MockAdService implements AdService {
  final SupabaseClient _supabaseService;
  Timer? _adTimer;

  MockAdService(this._supabaseService);

  @override
  Future<void> loadAd(AdType adType) async {
    // モックなので何もしない
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<AdViewResult> showAd(AdType adType) async {
    try {
      // 事前に当日の追加回数上限(3)をチェック
      try {
        final userId = _supabaseService.auth.currentUser?.id;
        if (userId != null) {
          final stats = await _supabaseService.rpc('get_available_gacha_attempts', params: {
            'user_id_param': userId,
          });
          if (stats is Map && (stats['bonus_attempts'] as int? ?? 0) >= 3) {
            return AdViewResult(
              success: false,
              errorMessage: '本日はこれ以上回数を追加できません（上限3回）',
            );
          }
        }
      } catch (_) {}

      // 広告視聴のシミュレーション（3秒待つ）
      final completer = Completer<AdViewResult>();
      
      _adTimer?.cancel();
      _adTimer = Timer(const Duration(seconds: 3), () async {
        try {
          // 広告視聴成功を記録
          final rewardedAttempts = _getRewardedAttempts(adType);
          
          // データベースに広告視聴を記録
          await _recordAdView(adType, rewardedAttempts);
          
          completer.complete(AdViewResult(
            success: true,
            rewardedAttempts: rewardedAttempts,
          ));
        } catch (e) {
          completer.complete(AdViewResult(
            success: false,
            errorMessage: e.toString(),
          ));
        }
      });

      return completer.future;
    } catch (e) {
      return AdViewResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  @override
  Future<bool> isAdAvailable(AdType adType) async {
    // モックなので常に利用可能
    return true;
  }

  @override
  Future<void> dispose() async {
    _adTimer?.cancel();
    _adTimer = null;
  }

  /// 広告タイプに応じた報酬回数を決定
  int _getRewardedAttempts(AdType adType) {
    switch (adType) {
      case AdType.video:
        return 1; // 動画広告：1回
      case AdType.banner:
        return 1; // バナー広告：1回
      case AdType.interstitial:
        return 2; // インタースティシャル広告：2回
    }
  }

  /// 広告視聴をデータベースに記録
  Future<void> _recordAdView(AdType adType, int rewardedAttempts) async {
    final userId = _supabaseService.auth.currentUser?.id;
    if (userId == null) return;

    await _supabaseService.from('ad_views').insert({
      'user_id': userId,
      'ad_type': adType.name,
      'ad_provider': 'mock_provider',
      'ad_id': 'mock_ad_${DateTime.now().millisecondsSinceEpoch}',
      'view_duration': 30, // 30秒の視聴を想定
      'completed': true,
      'reward_attempts': rewardedAttempts,
      'viewed_at': DateTime.now().toIso8601String(),
    });

    // ガチャ回数を追加
    await _supabaseService.rpc('add_gacha_bonus_attempts', params: {
      'user_id_param': userId,
      'bonus_count': rewardedAttempts,
    });
  }
}

/// 実際の広告サービス（Google AdMobなどを使用する場合）
// class GoogleAdMobService implements AdService {
//   // Google AdMobの実装
//   // RewardedAd, InterstitialAd などの実装
// }

/// AdService のプロバイダー
final adServiceProvider = Provider<AdService>((ref) {
  final supabase = Supabase.instance.client;
  return MockAdService(supabase);
});
