import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 最適化された画像ウィジェット
class OptimizedNetworkImage extends StatelessWidget {
  /// 画像URL
  final String imageUrl;
  
  /// プレースホルダーウィジェット
  final Widget? placeholder;
  
  /// エラーウィジェット
  final Widget? errorWidget;
  
  /// フィットタイプ
  final BoxFit fit;
  
  /// 幅
  final double? width;
  
  /// 高さ
  final double? height;
  
  /// コンストラクタ
  const OptimizedNetworkImage({
    super.key,
    required this.imageUrl,
    this.placeholder,
    this.errorWidget,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });
  
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, url) => placeholder ?? const Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => errorWidget ?? const Center(
        child: Icon(Icons.error),
      ),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
      memCacheWidth: _calculateMemCacheWidth(width),
      memCacheHeight: _calculateMemCacheHeight(height),
      maxWidthDiskCache: 800, // ディスクキャッシュの最大幅
      maxHeightDiskCache: 800, // ディスクキャッシュの最大高さ
    );
  }
  
  /// メモリキャッシュの幅を計算
  int? _calculateMemCacheWidth(double? width) {
    if (width == null) return null;
    
    // デバイスの画面密度を考慮
    final pixelRatio = WidgetsBinding.instance.window.devicePixelRatio;
    return (width * pixelRatio).round();
  }
  
  /// メモリキャッシュの高さを計算
  int? _calculateMemCacheHeight(double? height) {
    if (height == null) return null;
    
    // デバイスの画面密度を考慮
    final pixelRatio = WidgetsBinding.instance.window.devicePixelRatio;
    return (height * pixelRatio).round();
  }
}
