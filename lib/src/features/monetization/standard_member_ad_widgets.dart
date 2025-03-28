import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ad_model.dart';
import '../services/ad_service.dart';
import 'free_user_ad_widgets.dart';

/// スタンダード会員向け広告バナーウィジェット
class StandardMemberAdBanner extends ConsumerWidget {
  final String userId;
  final AdType adType;
  final AdSize preferredSize;
  final VoidCallback? onAdClicked;
  final bool showAds; // 広告表示フラグ（一部の画面では非表示にする場合）

  const StandardMemberAdBanner({
    Key? key,
    required this.userId,
    this.adType = AdType.banner,
    this.preferredSize = AdSize.small, // スタンダード会員は小さいサイズをデフォルトに
    this.onAdClicked,
    this.showAds = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 広告表示フラグがfalseの場合は何も表示しない
    if (!showAds) {
      return const SizedBox.shrink();
    }

    final params = AdRequestParams(
      userType: UserType.standard,
      limit: 1,
      adType: adType,
    );
    
    final adsAsync = ref.watch(adsByUserTypeProvider(params));

    return adsAsync.when(
      data: (ads) {
        if (ads.isEmpty) {
          return const SizedBox.shrink(); // 広告がない場合は何も表示しない
        }

        final ad = ads.first;
        
        // 広告のインプレッションを記録
        _recordImpression(ref, ad.id, userId);
        
        return GestureDetector(
          onTap: () {
            // 広告のクリックを記録
            _recordClick(ref, ad.id, userId);
            
            // クリックコールバックを呼び出す
            if (onAdClicked != null) {
              onAdClicked!();
            }
            
            // 実際のアプリではここで広告のターゲットURLを開く処理を追加
            print('Standard member ad clicked: ${ad.targetUrl}');
          },
          child: Container(
            width: double.infinity,
            height: _getAdHeight(preferredSize),
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey[100], // 無料ユーザーより薄い背景色
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1.0,
              ),
            ),
            child: Stack(
              children: [
                // 広告コンテンツ
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7.0),
                    child: Row(
                      children: [
                        // 広告画像（小さめ）
                        SizedBox(
                          width: 80,
                          child: Image.network(
                            ad.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.image, size: 24),
                                ),
                              );
                            },
                          ),
                        ),
                        
                        // 広告テキスト
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  ad.title,
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  ad.description,
                                  style: const TextStyle(
                                    fontSize: 10.0,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 広告ラベル
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4.0,
                      vertical: 1.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    child: const Text(
                      '広告',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        width: double.infinity,
        height: _getAdHeight(preferredSize),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
            ),
          ),
        ),
      ),
      error: (error, stackTrace) => const SizedBox.shrink(), // エラー時は何も表示しない
    );
  }

  /// 広告のインプレッションを記録する
  void _recordImpression(WidgetRef ref, String adId, String userId) {
    final adService = ref.read(adServiceProvider);
    adService.recordImpression(adId, userId);
  }

  /// 広告のクリックを記録する
  void _recordClick(WidgetRef ref, String adId, String userId) {
    final adService = ref.read(adServiceProvider);
    adService.recordClick(adId, userId);
  }

  /// 広告サイズに基づいて高さを取得する（スタンダード会員は小さめ）
  double _getAdHeight(AdSize size) {
    switch (size) {
      case AdSize.small:
        return 40.0; // 無料ユーザーより小さいサイズ
      case AdSize.medium:
        return 60.0;
      case AdSize.large:
        return 80.0;
      case AdSize.fullScreen:
        return 200.0;
    }
  }
}

/// 広告表示ポリシーを管理するクラス
class AdDisplayPolicy {
  /// スタンダード会員が特定の画面で広告を表示すべきかどうかを判定する
  static bool shouldShowAdsToStandardMember(String screenName) {
    // スタンダード会員に広告を表示する画面のリスト
    final screensWithAds = [
      'home_screen',
      'search_screen',
      'feed_screen',
    ];
    
    // スタンダード会員に広告を表示しない画面のリスト
    final screensWithoutAds = [
      'profile_screen',
      'settings_screen',
      'star_detail_screen',
      'premium_content_screen',
    ];
    
    // リストに含まれる場合は対応する値を返す
    if (screensWithAds.contains(screenName)) {
      return true;
    }
    if (screensWithoutAds.contains(screenName)) {
      return false;
    }
    
    // デフォルトでは50%の確率で広告を表示（ランダム要素を入れる例）
    return DateTime.now().millisecondsSinceEpoch % 2 == 0;
  }
  
  /// スタンダード会員がアプリ使用中にインタースティシャル広告を表示すべきかどうかを判定する
  static bool shouldShowInterstitialToStandardMember(int sessionDurationMinutes) {
    // スタンダード会員には30分に1回だけインタースティシャル広告を表示
    return sessionDurationMinutes >= 30 && sessionDurationMinutes % 30 == 0;
  }
}

/// 会員タイプに基づいて適切な広告ウィジェットを返すファクトリ
class AdWidgetFactory {
  /// ユーザータイプに基づいて適切な広告バナーウィジェットを返す
  static Widget createAdBanner({
    required String userId,
    required String userType,
    required String screenName,
    AdType adType = AdType.banner,
    VoidCallback? onAdClicked,
  }) {
    if (userType == UserType.free) {
      // 無料ユーザーには常に広告を表示
      return FreeUserAdBanner(
        userId: userId,
        adType: adType,
        preferredSize: AdSize.medium,
        onAdClicked: onAdClicked,
      );
    } else if (userType == UserType.standard) {
      // スタンダード会員には画面に応じて広告を表示
      final showAds = AdDisplayPolicy.shouldShowAdsToStandardMember(screenName);
      return StandardMemberAdBanner(
        userId: userId,
        adType: adType,
        preferredSize: AdSize.small,
        onAdClicked: onAdClicked,
        showAds: showAds,
      );
    } else {
      // プレミアム会員やスターには広告を表示しない
      return const SizedBox.shrink();
    }
  }
  
  /// ユーザータイプに基づいてインタースティシャル広告を表示するかどうかを判定し、表示する
  static void showInterstitialAdIfNeeded({
    required BuildContext context,
    required String userId,
    required String userType,
    required int sessionDurationMinutes,
    VoidCallback? onAdClosed,
    VoidCallback? onAdClicked,
  }) {
    if (userType == UserType.free) {
      // 無料ユーザーには15分ごとにインタースティシャル広告を表示
      if (sessionDurationMinutes % 15 == 0 && sessionDurationMinutes > 0) {
        showInterstitialAd(
          context,
          userId,
          onAdClosed: onAdClosed,
          onAdClicked: onAdClicked,
        );
      }
    } else if (userType == UserType.standard) {
      // スタンダード会員には30分に1回だけインタースティシャル広告を表示
      if (AdDisplayPolicy.shouldShowInterstitialToStandardMember(sessionDurationMinutes)) {
        showInterstitialAd(
          context,
          userId,
          onAdClosed: onAdClosed,
          onAdClicked: onAdClicked,
        );
      }
    }
    // プレミアム会員やスターにはインタースティシャル広告を表示しない
  }
}
