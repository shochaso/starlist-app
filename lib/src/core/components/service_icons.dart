import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/service_definitions.dart';

/// 実際のサービス公式アイコンを管理するクラス
/// Material Policy (MP) ライセンスに準拠した実装
class ServiceIcons {
  // MP準拠: 各サービスの公式ブランドガイドラインに従ったアイコン実装
  
  /// サービスアイコンの構築（公式SVGアイコンを使用）
  static Widget buildIcon({
    required String serviceId,
    required double size,
    required bool isDark,
  }) {
    // 公式SVGアイコンファイルパスのマッピング
    final iconPaths = {
      'netflix': 'assets/icons/services/netflix.svg',
      'spotify': 'assets/icons/services/spotify.svg',
      'apple_music': 'assets/icons/services/apple_music.svg',
      'youtube': 'assets/icons/services/youtube.svg',
      'disney_plus': 'assets/icons/services/disney_plus.svg',
      'instagram': 'assets/icons/services/instagram.svg',
      'tiktok': 'assets/icons/services/tiktok.svg',
    };

    final iconPath = iconPaths[serviceId.toLowerCase()];
    
    if (iconPath != null) {
      // 実際の公式SVGアイコンを表示
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.15),
          // 各サービスの公式背景色（必要に応じて）
          color: _getServiceBackgroundColor(serviceId, isDark),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.15),
          child: SvgPicture.asset(
            iconPath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            colorFilter: _getColorFilter(serviceId, isDark),
          ),
        ),
      );
    }

    // フォールバック: FontAwesome汎用アイコン
    return _buildFallbackIcon(serviceId, size, isDark);
  }

  /// サービス別の背景色取得（公式ブランドカラーに準拠）
  static Color? _getServiceBackgroundColor(String serviceId, bool isDark) {
    switch (serviceId.toLowerCase()) {
      case 'spotify':
        return const Color(0xFF1DB954); // Spotify Green
      case 'youtube':
        return Colors.white; // YouTube白背景
      case 'netflix':
        return const Color(0xFFE50914); // Netflix Red
      case 'apple_music':
        return Colors.white; // Apple Music白背景
      case 'disney_plus':
        return const Color(0xFF113CCF); // Disney+ Blue
      case 'instagram':
        return Colors.white; // Instagram白背景（グラデーションはSVG内）
      case 'tiktok':
        return Colors.white; // TikTok白背景
      default:
        return null;
    }
  }

  /// サービス別のカラーフィルター（必要に応じて）
  static ColorFilter? _getColorFilter(String serviceId, bool isDark) {
    // ほとんどのサービスアイコンは独自の色を持っているため、基本的にnull
    // 特定のサービスで色変更が必要な場合のみ適用
    switch (serviceId.toLowerCase()) {
      default:
        return null; // 公式色をそのまま使用
    }
  }

  /// フォールバックアイコン（FontAwesome）
  static Widget _buildFallbackIcon(String serviceId, double size, bool isDark) {
    // ServiceDefinitionsから情報を取得
    final service = ServiceDefinitions.get(serviceId);
    
    if (service != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: service.getBackgroundColor(isDark),
          borderRadius: BorderRadius.circular(size * 0.15),
        ),
        child: Icon(
          service.icon,
          size: size * 0.6,
          color: service.primaryColor == Colors.white || service.primaryColor == const Color(0xFFFFFC00)
              ? (isDark ? Colors.black : service.primaryColor)
              : service.primaryColor,
        ),
      );
    }
    
    // デフォルトアイコン
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(size * 0.15),
      ),
      child: Icon(
        FontAwesomeIcons.play,
        size: size * 0.6,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  /// レガシーメソッド：後方互換性のため
  static Widget getServiceWidget(
    String serviceKey, {
    double size = 40.0,
    bool showGradient = true,
    bool showShadow = true,
  }) {
    return buildIcon(
      serviceId: serviceKey,
      size: size,
      isDark: false,
    );
  }

  /// 利用可能なサービス一覧
  static List<String> get availableServices => [
    'netflix',
    'spotify', 
    'apple_music',
    'youtube',
    'disney_plus',
    'instagram',
    'tiktok',
  ];

  /// サービス名取得
  static String getServiceName(String serviceId) {
    return ServiceDefinitions.getServiceName(serviceId);
  }

  /// 後方互換性: サービスグラデーション取得
  static LinearGradient getServiceGradient(String serviceId) {
    return ServiceDefinitions.getServiceGradient(serviceId);
  }

  /// 後方互換性: サービス情報取得
  static ServiceInfo? getService(String serviceId) {
    final definition = ServiceDefinitions.get(serviceId);
    if (definition != null) {
      return ServiceInfo(
        name: definition.name,
        color: definition.primaryColor,
      );
    }
    return null;
  }

  /// 後方互換性: サービスカード構築
  static Widget buildServiceCard({
    required String serviceId,
    required String title,
    required String description,
    required VoidCallback onTap,
    double size = 48.0,
    bool isConnected = false,
    bool isDark = false,
  }) {
    return Card(
      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              buildIcon(
                serviceId: serviceId,
                size: size,
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// サービス情報クラス
class ServiceInfo {
  final String name;
  final Color color;

  ServiceInfo({
    required this.name,
    required this.color,
  });
} 