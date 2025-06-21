import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// サービスアイコンを統一管理するクラス
/// 各サービスの公式デザインガイドラインに準拠したアイコンとカラーを提供
class ServiceIcons {
  /// 正規ブランドガイドラインに基づく公式サービスデータ
  static const Map<String, ServiceIconData> _services = {
    'youtube': ServiceIconData(
      name: 'YouTube',
      color: Color(0xFFFF0000), // 公式YouTube Red
      backgroundColor: Color(0xFFFF0000),
      icon: FontAwesomeIcons.youtube,
      gradient: LinearGradient(
        colors: [Color(0xFFFF0000), Color(0xFFCC0000)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    'spotify': ServiceIconData(
      name: 'Spotify',
      color: Color(0xFF1ED760), // 公式Spotify Green
      backgroundColor: Color(0xFF191414), // 公式Spotify Dark
      icon: FontAwesomeIcons.spotify,
      gradient: LinearGradient(
        colors: [Color(0xFF1ED760), Color(0xFF1DB954)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    'instagram': ServiceIconData(
      name: 'Instagram',
      color: Color(0xFFE4405F), // 公式Instagram Pink
      backgroundColor: Color(0xFFE4405F),
      icon: FontAwesomeIcons.instagram,
      gradient: LinearGradient(
        colors: [
          Color(0xFFFDCB5C), // Yellow
          Color(0xFFE1306C), // Pink
          Color(0xFFC13584), // Purple
          Color(0xFF405DE6), // Blue
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    'tiktok': ServiceIconData(
      name: 'TikTok',
      color: Color(0xFF010101), // 公式TikTok Black
      backgroundColor: Color(0xFF010101),
      icon: FontAwesomeIcons.tiktok,
      gradient: LinearGradient(
        colors: [Color(0xFF69C9D0), Color(0xFFEE1D52)], // Turquoise to Red
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    'twitter': ServiceIconData(
      name: 'Twitter',
      color: Color(0xFF1DA1F2), // 公式Twitter Blue
      backgroundColor: Color(0xFF1DA1F2),
      icon: FontAwesomeIcons.twitter,
    ),
    'x': ServiceIconData(
      name: 'X',
      color: Color(0xFF000000), // 公式X Black
      backgroundColor: Color(0xFF000000),
      icon: FontAwesomeIcons.xTwitter,
    ),
    'facebook': ServiceIconData(
      name: 'Facebook',
      color: Color(0xFF1877F2), // 公式Facebook Blue
      backgroundColor: Color(0xFF1877F2),
      icon: FontAwesomeIcons.facebookF,
    ),
    'amazon': ServiceIconData(
      name: 'Amazon',
      color: Color(0xFFFF9900), // 公式Amazon Orange
      backgroundColor: Color(0xFFFF9900),
      icon: FontAwesomeIcons.amazon,
    ),
    'netflix': ServiceIconData(
      name: 'Netflix',
      color: Color(0xFFE50914), // 公式Netflix Red
      backgroundColor: Color(0xFF000000), // Netflix Black
      icon: Icons.movie, // FontAwesome doesn't have Netflix icon
    ),
    'google': ServiceIconData(
      name: 'Google',
      color: Color(0xFF4285F4), // 公式Google Blue
      backgroundColor: Color(0xFF4285F4),
      icon: FontAwesomeIcons.google,
      gradient: LinearGradient(
        colors: [
          Color(0xFF4285F4), // Blue
          Color(0xFFEA4335), // Red
          Color(0xFFFBBC05), // Yellow
          Color(0xFF34A853), // Green
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    'rakuten': ServiceIconData(
      name: '楽天',
      color: Color(0xFFBF0000), // 楽天レッド
      backgroundColor: Color(0xFFBF0000),
      icon: Icons.store,
    ),
    'valuecommerce': ServiceIconData(
      name: 'バリューコマース',
      color: Color(0xFF0066CC), // バリューコマースブルー
      backgroundColor: Color(0xFF0066CC),
      icon: Icons.business,
    ),
    'skyflag': ServiceIconData(
      name: 'SKYFLAG',
      color: Color(0xFF00A0E9), // スカイブルー
      backgroundColor: Color(0xFF00A0E9),
      icon: Icons.flag,
    ),
    'ironsource': ServiceIconData(
      name: 'ironSource',
      color: Color(0xFF6B46C1), // パープル
      backgroundColor: Color(0xFF6B46C1),
      icon: Icons.source,
    ),
    'linkedin': ServiceIconData(
      name: 'LinkedIn',
      color: Color(0xFF0A66C2), // 公式LinkedIn Blue
      backgroundColor: Color(0xFF0A66C2),
      icon: FontAwesomeIcons.linkedinIn,
    ),
    'discord': ServiceIconData(
      name: 'Discord',
      color: Color(0xFF5865F2), // 公式Discord Blurple
      backgroundColor: Color(0xFF5865F2),
      icon: FontAwesomeIcons.discord,
    ),
    'twitch': ServiceIconData(
      name: 'Twitch',
      color: Color(0xFF9146FF), // 公式Twitch Purple
      backgroundColor: Color(0xFF9146FF),
      icon: FontAwesomeIcons.twitch,
    ),
    'github': ServiceIconData(
      name: 'GitHub',
      color: Color(0xFF181717), // 公式GitHub Black
      backgroundColor: Color(0xFF181717),
      icon: FontAwesomeIcons.github,
    ),
    'snapchat': ServiceIconData(
      name: 'Snapchat',
      color: Color(0xFFFFFC00), // 公式Snapchat Yellow
      backgroundColor: Color(0xFFFFFC00),
      icon: FontAwesomeIcons.snapchat,
    ),
    'pinterest': ServiceIconData(
      name: 'Pinterest',
      color: Color(0xFFBD081C), // 公式Pinterest Red
      backgroundColor: Color(0xFFBD081C),
      icon: FontAwesomeIcons.pinterest,
    ),
    'reddit': ServiceIconData(
      name: 'Reddit',
      color: Color(0xFFFF4500), // 公式Reddit Orange
      backgroundColor: Color(0xFFFF4500),
      icon: FontAwesomeIcons.reddit,
    ),
    'whatsapp': ServiceIconData(
      name: 'WhatsApp',
      color: Color(0xFF25D366), // 公式WhatsApp Green
      backgroundColor: Color(0xFF25D366),
      icon: FontAwesomeIcons.whatsapp,
    ),
    'telegram': ServiceIconData(
      name: 'Telegram',
      color: Color(0xFF0088CC), // 公式Telegram Blue
      backgroundColor: Color(0xFF0088CC),
      icon: FontAwesomeIcons.telegram,
    ),
  };

  /// サービスアイコンデータを取得
  static ServiceIconData? getService(String serviceId) {
    return _services[serviceId.toLowerCase()];
  }

  /// 利用可能な全サービスを取得
  static Map<String, ServiceIconData> getAllServices() {
    return Map.from(_services);
  }

  /// サービスアイコンウィジェットを作成
  static Widget buildIcon({
    required String serviceId,
    required double size,
    required bool isDark,
  }) {
    final service = getService(serviceId);
    if (service == null) {
      return Icon(
        Icons.help_outline,
        size: size,
        color: isDark ? Colors.white70 : Colors.black54,
      );
    }

    // 特別なアイコン処理
    if (serviceId.toLowerCase() == 'youtube') {
      return _buildYouTubeIcon(size: size, isDark: isDark);
    }
    
    if (serviceId.toLowerCase() == 'instagram') {
      return _buildInstagramIcon(size: size, isDark: isDark);
    }

    if (serviceId.toLowerCase() == 'spotify') {
      return _buildSpotifyIcon(size: size, isDark: isDark);
    }

    if (serviceId.toLowerCase() == 'tiktok') {
      return _buildTikTokIcon(size: size, isDark: isDark);
    }

    // 標準アイコン
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: service.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Icon(
        service.icon,
        size: size * 0.6,
        color: service.color,
      ),
    );
  }

  // YouTube専用アイコン（公式デザイン準拠）
  static Widget _buildYouTubeIcon({required double size, required bool isDark}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFF0000), // YouTube Red
        borderRadius: BorderRadius.circular(size * 0.25), // より丸く
      ),
      child: Icon(
        FontAwesomeIcons.youtube,
        size: size * 0.6,
        color: Colors.white,
      ),
    );
  }

  // Instagram専用アイコン（公式グラデーション）
  static Widget _buildInstagramIcon({required double size, required bool isDark}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFDCB5C), // Yellow
            Color(0xFFE1306C), // Pink
            Color(0xFFC13584), // Purple
            Color(0xFF405DE6), // Blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.25), // より丸く
      ),
      child: Icon(
        FontAwesomeIcons.instagram,
        size: size * 0.6,
        color: Colors.white,
      ),
    );
  }

  // Spotify専用アイコン（公式デザイン準拠）
  static Widget _buildSpotifyIcon({required double size, required bool isDark}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1ED760), // Spotify Green
        borderRadius: BorderRadius.circular(size * 0.5), // 完全な円
      ),
      child: Icon(
        FontAwesomeIcons.spotify,
        size: size * 0.6,
        color: const Color(0xFF191414), // Spotify Dark
      ),
    );
  }

  // TikTok専用アイコン（公式デザイン準拠）
  static Widget _buildTikTokIcon({required double size, required bool isDark}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF010101), // TikTok Black
        borderRadius: BorderRadius.circular(size * 0.25), // より丸く
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Turquoise shadow
          Positioned(
            left: size * 0.1,
            child: Icon(
              FontAwesomeIcons.tiktok,
              size: size * 0.6,
              color: const Color(0xFF69C9D0), // TikTok Turquoise
            ),
          ),
          // Pink/Red main icon
          Icon(
            FontAwesomeIcons.tiktok,
            size: size * 0.6,
            color: const Color(0xFFEE1D52), // TikTok Red
          ),
        ],
      ),
    );
  }

  /// グラデーションバージョンのサービスアイコン
  static Widget buildGradientIcon({
    required String serviceId,
    required double size,
    required bool isDark,
  }) {
    final service = getService(serviceId);
    if (service == null || service.gradient == null) {
      return buildIcon(serviceId: serviceId, size: size, isDark: isDark);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: service.gradient,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Icon(
        service.icon,
        size: size * 0.6,
        color: Colors.white,
      ),
    );
  }

  /// カスタムサービスアイコンカード
  static Widget buildServiceCard({
    required String serviceId,
    required String title,
    required String description,
    required VoidCallback onTap,
    required bool isConnected,
    required bool isDark,
  }) {
    final service = getService(serviceId);
    if (service == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isConnected 
                    ? service.color.withOpacity(0.3)
                    : (isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
                width: isConnected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : Colors.black).withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: service.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: buildIcon(
                      serviceId: serviceId,
                      size: 28,
                      isDark: false,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isConnected ? service.color : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: service.color,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isConnected ? '接続済み' : '接続',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isConnected ? Colors.white : service.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static List<String> getAllServiceIds() {
    return _services.keys.toList();
  }

  static LinearGradient getServiceGradient(String serviceId) {
    final service = getService(serviceId);
    return service?.gradient ?? LinearGradient(
      colors: [
        service?.color ?? const Color(0xFF4ECDC4),
        (service?.color ?? const Color(0xFF4ECDC4)).withOpacity(0.7),
      ],
    );
  }
}

/// サービスアイコンデータクラス
class ServiceIconData {
  final String name;
  final Color color;
  final Color backgroundColor;
  final IconData icon;
  final LinearGradient? gradient;

  const ServiceIconData({
    required this.name,
    required this.color,
    required this.backgroundColor,
    required this.icon,
    this.gradient,
  });
} 