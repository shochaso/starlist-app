import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
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
  final int remainingToday;
  final int totalBalance;
  final String? errorMessage;

  AdViewResult({
    required this.success,
    this.rewardedAttempts = 0,
    this.remainingToday = 0,
    this.totalBalance = 0,
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
      final userId = _supabaseService.auth.currentUser?.id;
      if (userId == null) {
        return AdViewResult(
          success: false,
          errorMessage: 'ユーザーがログインしていません',
        );
      }

      // 広告視聴のシミュレーション（3秒待つ）
      final completer = Completer<AdViewResult>();
      
      _adTimer?.cancel();
      _adTimer = Timer(const Duration(seconds: 3), () async {
        try {
          // Generate unique ad_view_id - let server generate if null
          // Using null will let the server's gen_random_uuid() create it
          
          // Get device identifier
          final deviceId = _getDeviceId();
          
          // Call server RPC to complete ad view and grant ticket
          final result = await _supabaseService.rpc(
            'complete_ad_view_and_grant_ticket',
            params: {
              'p_user_id': userId,
              'p_device_id': deviceId,
              'p_ad_view_id': null, // Let server generate UUID
            },
          );
          
          if (result is List && result.isNotEmpty) {
            final data = result[0] as Map<String, dynamic>;
            final granted = data['granted'] as bool;
            final remainingToday = data['remaining_today'] as int;
            final totalBalance = data['total_balance'] as int;
            
            if (granted) {
              completer.complete(AdViewResult(
                success: true,
                rewardedAttempts: 1,
                remainingToday: remainingToday,
                totalBalance: totalBalance,
              ));
            } else {
              completer.complete(AdViewResult(
                success: false,
                remainingToday: remainingToday,
                totalBalance: totalBalance,
                errorMessage: '本日はこれ以上回数を追加できません（上限3回）',
              ));
            }
          } else {
            throw Exception('Invalid RPC response');
          }
        } catch (e) {
          completer.complete(AdViewResult(
            success: false,
            errorMessage: '広告視聴の記録に失敗しました: ${e.toString()}',
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

  /// 広告タイプに応じた報酬回数を決定（レガシー、現在は使用しない）
  @Deprecated('Use server-side RPC complete_ad_view_and_grant_ticket instead')
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

  /// デバイスIDを取得
  /// 
  /// NOTE: This is a placeholder implementation. For production fraud detection,
  /// use device_info_plus package to get real device identifiers:
  /// - Android: Android ID or advertising ID
  /// - iOS: identifierForVendor or advertising ID
  /// 
  /// Current implementation uses platform + user_id which is NOT sufficient
  /// for fraud detection as all sessions from the same user will have the
  /// same device_id.
  String _getDeviceId() {
    // TODO: Implement real device fingerprinting using device_info_plus
    // For now, generate a pseudo-device ID
    if (kIsWeb) {
      return 'web_${_supabaseService.auth.currentUser?.id ?? "unknown"}';
    }
    try {
      if (Platform.isAndroid) {
        return 'android_${_supabaseService.auth.currentUser?.id ?? "unknown"}';
      } else if (Platform.isIOS) {
        return 'ios_${_supabaseService.auth.currentUser?.id ?? "unknown"}';
      }
    } catch (_) {
      // Platform not available on web
    }
    return 'unknown_${_supabaseService.auth.currentUser?.id ?? "unknown"}';
  }

  /// 広告視聴をデータベースに記録（レガシー、現在は使用しない）
  @Deprecated('Use server-side RPC complete_ad_view_and_grant_ticket instead')
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

    // ガチャ回数を追加（レガシーRPC、現在は使用しない）
    try {
      await _supabaseService.rpc('add_gacha_bonus_attempts', params: {
        'user_id_param': userId,
        'bonus_count': rewardedAttempts,
      });
    } catch (_) {
      // Legacy RPC may not exist
    }
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
