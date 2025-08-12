import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_icons/simple_icons.dart';
import '../constants/service_definitions.dart';
import 'package:flutter/services.dart' show rootBundle;

/// 実際のサービス公式アイコンを管理するクラス
/// Material Policy (MP) ライセンスに準拠した実装
class ServiceIcons {
  // MP準拠: 各サービスの公式ブランドガイドラインに従ったアイコン実装
  
  static String _normalizeServiceId(String rawId) {
    final id = rawId.toLowerCase();
    switch (id) {
      case 'amazon_prime':
      case 'amazonprime':
      case 'prime':
        return 'prime_video';
      case 'x_twitter':
        return 'x';
      default:
        return id;
    }
  }

  /// サービスアイコンの構築（公式SVGアイコンを使用）
  static Widget buildIcon({
    required String serviceId,
    required double size,
    required bool isDark,
  }) {
    // 特別扱いなし（まずは同梱の公式SVGを優先）
    final preferRemote = <String, bool>{};
    final id = _normalizeServiceId(serviceId);

    // ユーザー要望: SimpleIcons を優先採用（安定表示 & ブランド一貫性）
    const preferSimpleIcon = <String>{
      'youtube', 'prime_video', 'amazon', 'spotify', 'netflix',
      'apple_music'
    };
    if (preferSimpleIcon.contains(id)) {
      return _buildSimpleIcon(id: id, size: size, isDark: isDark);
    }

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
      'amazon_music': 'assets/icons/services/amazon_music.svg',
      
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
    final iconPath = iconPaths[id];
    if (preferRemote[id] == true) {
      // 公式CDNのベクターロゴを強制使用
      return _buildRemoteLogo(serviceId: id, size: size, isDark: isDark);
    }
    
    // 1) アセットが存在する場合はそれを使用
    if (iconPath != null) {
      return _buildSvgWithFallback(iconPath: iconPath, serviceId: id, size: size, isDark: isDark);
    }
    // 2) アセット未定義のサービスはリモートロゴ(CDN/Clearbit)にフォールバック
    return _buildRemoteLogo(serviceId: id, size: size, isDark: isDark);
  }

  static Widget _buildSimpleIcon({
    required String id,
    required double size,
    required bool isDark,
  }) {
    final simpleIconMap = <String, IconData>{
      'youtube': SimpleIcons.youtube,
      'amazon': SimpleIcons.amazon,
      'spotify': SimpleIcons.spotify,
      'netflix': SimpleIcons.netflix,
      'prime_video': SimpleIcons.primevideo,
      'apple_music': SimpleIcons.applemusic,
    };
    final brandColors = <String, Color>{
      'youtube': const Color(0xFFFF0000),
      'amazon': const Color(0xFFFF9900),
      'spotify': const Color(0xFF1DB954),
      'netflix': const Color(0xFFE50914),
      'prime_video': const Color(0xFF00A8E1),
      'apple_music': const Color(0xFFFA57C1),
    };
    final iconData = simpleIconMap[id];
    final color = brandColors[id] ?? (isDark ? Colors.white : Colors.black);
    if (iconData != null) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Icon(iconData, size: size * 0.82, color: color),
        ),
      );
    }
    // 万一未定義なら従来フォールバック
    return _buildFallbackIcon(id, size, isDark);
  }

  /// アセット→CDN(Simple Icons)→Clearbitの順でロゴを解決
  static Widget _buildSvgWithFallback({
    required String iconPath,
    required String serviceId,
    required double size,
    required bool isDark,
  }) {
    return FutureBuilder<bool>(
      future: _assetIsValidSvg(iconPath),
      builder: (context, snapshot) {
        final exists = snapshot.data == true;
        final borderRadius = BorderRadius.circular(size * 0.15);
        final bg = Colors.transparent; // 背景色は透明にしてロゴの可視性を担保
        
        if (exists) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(borderRadius: borderRadius, color: bg),
            child: ClipRRect(
              borderRadius: borderRadius,
              child: SvgPicture.asset(
                iconPath,
                width: size,
                height: size,
                fit: BoxFit.contain,
              ),
            ),
          );
        }
        // アセットが無い場合は最後にフォールバックアイコン
        return _buildFallbackIcon(serviceId, size, isDark);
      },
    );
  }

  /// 廃止: ネットワークフォールバックは使用しない（RLS要件によりローカルアセット限定）
  static Widget _buildRemoteLogo({
    required String serviceId,
    required double size,
    required bool isDark,
  }) {
    return _buildFallbackIcon(serviceId, size, isDark);
  }

  static Future<bool> _assetIsValidSvg(String assetPath) async {
    try {
      final content = await rootBundle.loadString(assetPath);
      return content.contains('<svg');
    } catch (_) {
      return false;
    }
  }

  /// サービス別の背景色取得（公式ブランドカラーに準拠）
  static Color? _getServiceBackgroundColor(String serviceId, bool isDark) {
    switch (serviceId.toLowerCase()) {
      // 動画・音楽サービス
      case 'spotify':
        return const Color(0xFF1DB954); // Spotify Green
      case 'youtube':
      case 'youtube_music':
        return null; // 背景は透明
      case 'netflix':
        return null; // 透明
      case 'apple_music':
        return null;
      case 'disney_plus':
        return null;
      case 'prime_video':
        return null;
      case 'hulu':
        return null;
      case 'abema':
        return null;
      case 'niconico':
        return null;
      
      // SNS
      case 'instagram':
        return null;
      case 'tiktok':
        return null;
      case 'x':
        return null;
      case 'facebook':
        return null;
      case 'threads':
        return null;
      case 'linkedin':
        return null;
      
      // 配信サービス
      case 'twitch':
        return null;
      case 'showroom':
        return null;
      case 'pococha':
        return null;
      
      // ショッピング
      case 'amazon':
        return null;
      case 'rakuten':
        return null;
      case 'mercari':
        return null;
      
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
    // 1) SimpleIcons でブランドロゴを優先表示（ローカルパッケージのためネットワーク非依存）
    final id = _normalizeServiceId(serviceId);
    final simpleIconMap = <String, IconData>{
      'youtube': SimpleIcons.youtube,
      'amazon': SimpleIcons.amazon,
      'spotify': SimpleIcons.spotify,
      'netflix': SimpleIcons.netflix,
      'prime_video': SimpleIcons.primevideo,
      'amazon_prime': SimpleIcons.primevideo,
    };
    final brandColors = <String, Color>{
      'youtube': const Color(0xFFFF0000),
      'amazon': const Color(0xFFFF9900),
      'spotify': const Color(0xFF1DB954),
      'netflix': const Color(0xFFE50914),
      'prime_video': const Color(0xFF00A8E1),
      'amazon_prime': const Color(0xFF00A8E1),
    };

    final iconData = simpleIconMap[id];
    if (iconData != null) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Icon(
            iconData,
            size: size * 0.82,
            color: brandColors[id] ?? (isDark ? Colors.white : Colors.black87),
          ),
        ),
      );
    }

    // 2) ServiceDefinitions に定義があればそのアイコンを使用
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

    // 3) デフォルトのプレイアイコン
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