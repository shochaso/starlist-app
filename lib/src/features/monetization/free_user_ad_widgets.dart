import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ad_model.dart';
import '../services/ad_service.dart';

/// 広告サービスのプロバイダー
final adServiceProvider = Provider<AdService>((ref) {
  return AdService();
});

/// ユーザータイプに基づく広告を提供するプロバイダー
final adsByUserTypeProvider = FutureProvider.family<List<AdModel>, AdRequestParams>((ref, params) async {
  final adService = ref.watch(adServiceProvider);
  return await adService.getAdsByUserType(
    params.userType,
    limit: params.limit,
    adType: params.adType,
  );
});

/// 広告リクエストパラメータ
class AdRequestParams {
  final String userType;
  final int limit;
  final AdType? adType;

  AdRequestParams({
    required this.userType,
    this.limit = 5,
    this.adType,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdRequestParams &&
        other.userType == userType &&
        other.limit == limit &&
        other.adType == adType;
  }

  @override
  int get hashCode => Object.hash(userType, limit, adType);
}

/// 無料ユーザー向け広告バナーウィジェット
class FreeUserAdBanner extends ConsumerWidget {
  final String userId;
  final AdType adType;
  final AdSize preferredSize;
  final VoidCallback? onAdClicked;

  const FreeUserAdBanner({
    Key? key,
    required this.userId,
    this.adType = AdType.banner,
    this.preferredSize = AdSize.medium,
    this.onAdClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = AdRequestParams(
      userType: UserType.free,
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
            print('Ad clicked: ${ad.targetUrl}');
          },
          child: Container(
            width: double.infinity,
            height: _getAdHeight(preferredSize),
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1.0,
              ),
            ),
            child: Stack(
              children: [
                // 広告コンテンツ
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7.0),
                    child: Image.network(
                      ad.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildFallbackAdContent(context, ad);
                      },
                    ),
                  ),
                ),
                
                // 広告ラベル
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4.0,
                      vertical: 2.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    child: const Text(
                      '広告',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.0,
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
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
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

  /// 広告サイズに基づいて高さを取得する
  double _getAdHeight(AdSize size) {
    switch (size) {
      case AdSize.small:
        return 60.0;
      case AdSize.medium:
        return 100.0;
      case AdSize.large:
        return 150.0;
      case AdSize.fullScreen:
        return 300.0;
    }
  }

  /// 画像読み込みエラー時のフォールバック広告コンテンツ
  Widget _buildFallbackAdContent(BuildContext context, AdModel ad) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            ad.title,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          Text(
            ad.description,
            style: const TextStyle(
              fontSize: 12.0,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8.0),
          Text(
            'Sponsored by ${ad.advertiserName}',
            style: TextStyle(
              fontSize: 10.0,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// 無料ユーザー向けインタースティシャル広告ウィジェット
class FreeUserInterstitialAd extends ConsumerStatefulWidget {
  final String userId;
  final VoidCallback? onAdClosed;
  final VoidCallback? onAdClicked;

  const FreeUserInterstitialAd({
    Key? key,
    required this.userId,
    this.onAdClosed,
    this.onAdClicked,
  }) : super(key: key);

  @override
  ConsumerState<FreeUserInterstitialAd> createState() => _FreeUserInterstitialAdState();
}

class _FreeUserInterstitialAdState extends ConsumerState<FreeUserInterstitialAd> {
  @override
  Widget build(BuildContext context) {
    final params = AdRequestParams(
      userType: UserType.free,
      limit: 1,
      adType: AdType.interstitial,
    );
    
    final adsAsync = ref.watch(adsByUserTypeProvider(params));

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: adsAsync.when(
        data: (ads) {
          if (ads.isEmpty) {
            // 広告がない場合はダイアログを閉じる
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pop();
              if (widget.onAdClosed != null) {
                widget.onAdClosed!();
              }
            });
            return const SizedBox.shrink();
          }

          final ad = ads.first;
          
          // 広告のインプレッションを記録
          _recordImpression(ad.id, widget.userId);
          
          return Container(
            width: double.infinity,
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Stack(
              children: [
                // 広告コンテンツ
                Positioned.fill(
                  child: Column(
                    children: [
                      // 広告画像
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              // 広告のクリックを記録
                              _recordClick(ad.id, widget.userId);
                              
                              // クリックコールバックを呼び出す
                              if (widget.onAdClicked != null) {
                                widget.onAdClicked!();
                              }
                              
                              // 実際のアプリではここで広告のターゲットURLを開く処理を追加
                              print('Interstitial ad clicked: ${ad.targetUrl}');
                              
                              // ダイアログを閉じる
                              Navigator.of(context).pop();
                              if (widget.onAdClosed != null) {
                                widget.onAdClosed!();
                              }
                            },
                            child: Image.network(
                              ad.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        ad.title,
                                        style: const TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16.0),
                                      Text(
                                        ad.description,
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      
                      // 広告情報
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ad.title,
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              ad.description,
                              style: const TextStyle(
                                fontSize: 14.0,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Sponsored by ${ad.advertiserName}',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 閉じるボタン
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      if (widget.onAdClosed != null) {
                        widget.onAdClosed!();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20.0,
                      ),
                    ),
                  ),
                ),
                
                // 広告ラベル
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: const Text(
                      '広告',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stackTrace) {
          // エラー時はダイアログを閉じる
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pop();
            if (widget.onAdClosed != null) {
              widget.onAdClosed!();
            }
          });
          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// 広告のインプレッションを記録する
  void _recordImpression(String adId, String userId) {
    final adService = ref.read(adServiceProvider);
    adService.recordImpression(adId, userId);
  }

  /// 広告のクリックを記録する
  void _recordClick(String adId, String userId) {
    final adService = ref.read(adServiceProvider);
    adService.recordClick(adId, userId);
  }
}

/// インタースティシャル広告を表示するヘルパーメソッド
void showInterstitialAd(BuildContext context, String userId, {
  VoidCallback? onAdClosed,
  VoidCallback? onAdClicked,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => FreeUserInterstitialAd(
      userId: userId,
<response clipped><NOTE>To save on context only part of this file has been shown to you. You should retry this tool after you have searched inside the file with `grep -n` in order to find the line numbers of what you are looking for.</NOTE>