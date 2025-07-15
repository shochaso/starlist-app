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
    // 公式SVGアイコンファイルパスのマッピング（実際の公式アイコンを使用）
    final iconPaths = {
      // 動画サービス（公式アイコン）
      'netflix': 'assets/icons/services/netflix.svg',
      'spotify': 'assets/icons/services/spotify.svg',
      'apple_music': 'assets/icons/services/apple_music.svg',
      'youtube': 'assets/icons/services/youtube.svg',
      'youtube_music': 'assets/icons/services/youtube_music.svg',
      'disney_plus': 'assets/icons/services/disney_plus.svg',
      'prime_video': 'assets/icons/services/prime_video.svg',
      'hulu': 'assets/icons/services/hulu.svg',
      'unext': 'assets/icons/services/unext.svg',
      'abema': 'assets/icons/services/abema.svg',
      'niconico': 'assets/icons/services/niconico.svg',
      
      // 配信サービス（公式アイコン）
      'twitch': 'assets/icons/services/twitch.svg',
      'twitcasting': 'assets/icons/services/twitcasting.svg',
      'furatch': 'assets/icons/services/furatch.svg',
      'showroom': 'assets/icons/services/showroom.svg',
      '17live': 'assets/icons/services/17live.svg',
      'line_live': 'assets/icons/services/line_live.svg',
      'mildom': 'assets/icons/services/mildom.svg',
      'pococha': 'assets/icons/services/pococha.svg',
      'palmu': 'assets/icons/services/palmu.svg',
      
      // SNS（公式アイコン）
      'instagram': 'assets/icons/services/instagram.svg',
      'tiktok': 'assets/icons/services/tiktok.svg',
      'x': 'assets/icons/services/x_twitter.svg',
      'facebook': 'assets/icons/services/facebook.svg',
      'bereal': 'assets/icons/services/bereal.svg',
      'threads': 'assets/icons/services/threads.svg',
      'snapchat': 'assets/icons/services/snapchat.svg',
      'linkedin': 'assets/icons/services/linkedin.svg',
      'linktree': 'assets/icons/services/linktree.svg',
      
      // ショッピング（公式アイコン）
      'amazon': 'assets/icons/services/amazon.svg',
      'rakuten': 'assets/icons/services/rakuten.svg',
      'zozotown': 'assets/icons/services/zozotown.svg',
      'qoo10': 'assets/icons/services/qoo10.svg',
      'yahoo_shopping': 'assets/icons/services/yahoo_shopping.svg',
      'mercari': 'assets/icons/services/mercari.svg',
      'other_ec': 'assets/icons/services/other_ec.svg',
      
      // エンタメ・その他（公式アイコン）
      'games': 'assets/icons/services/games.svg',
      'books_manga': 'assets/icons/services/books_manga.svg',
      'cinema': 'assets/icons/services/cinema.svg',
      'restaurant': 'assets/icons/services/restaurant_cafe.svg',
      'delivery': 'assets/icons/services/delivery.svg',
      'cooking': 'assets/icons/services/cooking.svg',
      'credit_card': 'assets/icons/services/credit_card.svg',
      'electronic_money': 'assets/icons/services/electronic_money.svg',
      'live_concert': 'assets/icons/services/live_concert.svg',
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
      // 動画・音楽サービス
      case 'spotify':
        return const Color(0xFF1DB954); // Spotify Green
      case 'youtube':
      case 'youtube_music':
        return Colors.white; // YouTube白背景
      case 'netflix':
        return const Color(0xFFE50914); // Netflix Red
      case 'apple_music':
        return Colors.white; // Apple Music白背景
      case 'disney_plus':
        return const Color(0xFF113CCF); // Disney+ Blue
      case 'prime_video':
        return const Color(0xFF232F3E); // Amazon Prime背景
      case 'hulu':
        return const Color(0xFF1CE783); // Hulu Green
      case 'abema':
        return Colors.white; // ABEMA白背景
      case 'niconico':
        return Colors.white; // ニコニコ白背景
      
      // SNS
      case 'instagram':
        return Colors.white; // Instagram白背景（グラデーションはSVG内）
      case 'tiktok':
        return Colors.white; // TikTok白背景
      case 'x':
        return Colors.white; // X白背景
      case 'facebook':
        return const Color(0xFF1877F2); // Facebook Blue
      case 'threads':
        return Colors.white; // Threads白背景
      case 'linkedin':
        return const Color(0xFF0077B5); // LinkedIn Blue
      
      // 配信サービス
      case 'twitch':
        return const Color(0xFF9146FF); // Twitch Purple
      case 'showroom':
        return Colors.white; // SHOWROOM白背景
      case 'pococha':
        return Colors.white; // Pococha白背景
      
      // ショッピング
      case 'amazon':
        return const Color(0xFF232F3E); // Amazon背景
      case 'rakuten':
        return const Color(0xFFBF0000); // 楽天Red
      case 'mercari':
        return const Color(0xFFFF6F00); // メルカリオレンジ
      
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
    // 動画サービス
    'netflix', 'spotify', 'apple_music', 'youtube', 'youtube_music',
    'disney_plus', 'prime_video', 'hulu', 'unext', 'abema', 'niconico',
    // 配信サービス
    'twitch', 'twitcasting', 'furatch', 'showroom', '17live', 'line_live',
    'mildom', 'pococha', 'palmu',
    // SNS
    'instagram', 'tiktok', 'x', 'facebook', 'bereal', 'threads',
    'snapchat', 'linkedin', 'linktree',
    // ショッピング
    'amazon', 'rakuten', 'zozotown', 'qoo10', 'yahoo_shopping',
    'mercari', 'other_ec',
    // エンタメ・その他
    'games', 'books_manga', 'cinema', 'restaurant', 'delivery',
    'cooking', 'credit_card', 'electronic_money', 'live_concert',
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