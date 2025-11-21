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

  /// 広告視聴完了とチケット付与（新RPC使用）
  Future<AdGrantResult> completeAdViewAndGrantTicket({
    required String deviceId,
    String? adViewId,
  });

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

/// 広告付与の結果（新RPC用）
class AdGrantResult {
  final bool granted;
  final int remainingToday;
  final int totalBalance;
  final String? adViewId;
  final String? errorMessage;

  AdGrantResult({
    required this.granted,
    required this.remainingToday,
    required this.totalBalance,
    this.adViewId,
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
      // 広告視聴のシミュレーション（3秒待つ）
      final completer = Completer<AdViewResult>();
      
      _adTimer?.cancel();
      _adTimer = Timer(const Duration(seconds: 3), () async {
        try {
          // 広告視聴成功
          final rewardedAttempts = _getRewardedAttempts(adType);
          
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
  Future<AdGrantResult> completeAdViewAndGrantTicket({
    required String deviceId,
    String? adViewId,
  }) async {
    final userId = _supabaseService.auth.currentUser?.id;
    if (userId == null) {
      return AdGrantResult(
        granted: false,
        remainingToday: 0,
        totalBalance: 0,
        errorMessage: 'ユーザーが認証されていません',
      );
    }

    try {
      // Get user agent and client IP (mock values for now)
      final userAgent = _getUserAgent();
      final clientIp = '127.0.0.1'; // Mock IP

      // Call the new RPC function
      final result = await _supabaseService.rpc(
        'complete_ad_view_and_grant_ticket',
        params: {
          'p_user_id': userId,
          'p_device_id': deviceId,
          'p_ad_view_id': adViewId,
          'p_user_agent': userAgent,
          'p_client_ip': clientIp,
          'p_ad_type': 'video',
          'p_ad_provider': 'mock_provider',
        },
      );

      if (result is Map<String, dynamic>) {
        final granted = result['granted'] as bool? ?? false;
        final remainingToday = result['remaining_today'] as int? ?? 0;
        final totalBalance = result['total_balance'] as int? ?? 0;
        final returnedAdViewId = result['ad_view_id'] as String?;
        final error = result['error'] as String?;

        return AdGrantResult(
          granted: granted,
          remainingToday: remainingToday,
          totalBalance: totalBalance,
          adViewId: returnedAdViewId,
          errorMessage: error,
        );
      }

      return AdGrantResult(
        granted: false,
        remainingToday: 0,
        totalBalance: 0,
        errorMessage: 'サーバーから無効な応答が返されました',
      );
    } catch (e) {
      print('Error calling complete_ad_view_and_grant_ticket: $e');
      return AdGrantResult(
        granted: false,
        remainingToday: 0,
        totalBalance: 0,
        errorMessage: 'チケット付与に失敗しました: $e',
      );
    }
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

  /// Get user agent string
  String _getUserAgent() {
    if (kIsWeb) {
      return 'Web Browser';
    }
    try {
      if (Platform.isAndroid) {
        return 'Android App';
      } else if (Platform.isIOS) {
        return 'iOS App';
      }
    } catch (_) {}
    return 'Unknown';
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
