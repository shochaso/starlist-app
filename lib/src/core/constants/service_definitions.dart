import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// サービス定義情報を管理するクラス
/// 各サービスのID、名前、アイコン、色、カテゴリーなどを一元管理
/// MP (Material Policy) 法的安全性準拠
class ServiceDefinitions {
  // プライベートコンストラクタ（インスタンス化を防ぐ）
  ServiceDefinitions._();

  /// サービス情報を格納するマップ
  static final Map<String, ServiceDefinition> _services = {
    // SNS
    'x': ServiceDefinition(
      id: 'x',
      name: 'X (Twitter)',
      category: ServiceCategory.sns,
      icon: FontAwesomeIcons.xTwitter,
      primaryColor: const Color(0xFF000000),
      secondaryColor: const Color(0xFF1DA1F2),
      description: 'ツイート・フォロー',
      svgPath: 'assets/icons/services/x_twitter.svg',
    ),
    'facebook': ServiceDefinition(
      id: 'facebook',
      name: 'Facebook',
      category: ServiceCategory.sns,
      icon: FontAwesomeIcons.facebook,
      primaryColor: const Color(0xFF1877F2),
      secondaryColor: const Color(0xFF4267B2),
      description: '投稿・いいね',
      svgPath: 'assets/icons/services/facebook.svg',
    ),
    'instagram': ServiceDefinition(
      id: 'instagram',
      name: 'Instagram',
      category: ServiceCategory.sns,
      icon: FontAwesomeIcons.instagram,
      primaryColor: const Color(0xFFE4405F),
      secondaryColor: const Color(0xFFFCAF45),
      description: '投稿・ストーリー',
      svgPath: 'assets/icons/services/instagram.svg',
    ),
    'tiktok': ServiceDefinition(
      id: 'tiktok',
      name: 'TikTok',
      category: ServiceCategory.sns,
      icon: FontAwesomeIcons.tiktok,
      primaryColor: const Color(0xFF000000),
      secondaryColor: const Color(0xFFFF0050),
      description: 'ショート動画',
      svgPath: 'assets/icons/services/tiktok.svg',
    ),
    'snapchat': ServiceDefinition(
      id: 'snapchat',
      name: 'Snapchat',
      category: ServiceCategory.sns,
      icon: FontAwesomeIcons.snapchat,
      primaryColor: const Color(0xFFFFFC00),
      secondaryColor: const Color(0xFFFFF700),
      description: 'スナップ・ストーリー',
      svgPath: 'assets/icons/services/snapchat.svg',
    ),
    'linkedin': ServiceDefinition(
      id: 'linkedin',
      name: 'LinkedIn',
      category: ServiceCategory.sns,
      icon: FontAwesomeIcons.linkedin,
      primaryColor: const Color(0xFF0077B5),
      secondaryColor: const Color(0xFF00669C),
      description: 'ビジネスネットワーク',
      svgPath: 'assets/icons/services/linkedin.svg',
    ),

    // 動画/配信サイト
    'youtube': ServiceDefinition(
      id: 'youtube',
      name: 'YouTube',
      category: ServiceCategory.video,
      icon: FontAwesomeIcons.youtube,
      primaryColor: const Color(0xFFFF0000),
      secondaryColor: const Color(0xFFCC0000),
      description: '動画共有・ライブ配信',
      svgPath: 'assets/icons/services/youtube.svg',
    ),
    'twitch': ServiceDefinition(
      id: 'twitch',
      name: 'Twitch',
      category: ServiceCategory.streaming,
      icon: FontAwesomeIcons.twitch,
      primaryColor: const Color(0xFF9146FF),
      secondaryColor: const Color(0xFF6441A4),
      description: 'ゲーム配信・ライブストリーミング',
      svgPath: 'assets/icons/services/twitch.svg',
    ),
    'netflix': ServiceDefinition(
      id: 'netflix',
      name: 'Netflix',
      category: ServiceCategory.video,
      icon: FontAwesomeIcons.video,
      primaryColor: const Color(0xFFE50914),
      secondaryColor: const Color(0xFF221F1F),
      description: '映画・ドラマストリーミング',
      svgPath: 'assets/icons/services/netflix.svg',
    ),
    'prime_video': ServiceDefinition(
      id: 'prime_video',
      name: 'Prime Video',
      category: ServiceCategory.video,
      icon: FontAwesomeIcons.play,
      primaryColor: const Color(0xFF00A8E1),
      secondaryColor: const Color(0xFF232F3E),
      description: '映画・ドラマ・オリジナル作品',
      svgPath: 'assets/icons/services/prime_video.svg',
    ),
    'disney': ServiceDefinition(
      id: 'disney',
      name: 'Disney+',
      category: ServiceCategory.video,
      icon: FontAwesomeIcons.wandMagic,
      primaryColor: const Color(0xFF113CCF),
      secondaryColor: const Color(0xFF0652DD),
      description: 'ディズニー・マーベル・スター・ウォーズ',
      svgPath: 'assets/icons/services/disney_plus.svg',
    ),
    'abema': ServiceDefinition(
      id: 'abema',
      name: 'ABEMA',
      category: ServiceCategory.video,
      icon: FontAwesomeIcons.tv,
      primaryColor: const Color(0xFF00D4AA),
      secondaryColor: const Color(0xFF00C096),
      description: 'アニメ・バラエティ・ニュース',
      svgPath: 'assets/icons/services/abema.svg',
    ),
    'hulu': ServiceDefinition(
      id: 'hulu',
      name: 'Hulu',
      category: ServiceCategory.video,
      icon: FontAwesomeIcons.h,
      primaryColor: const Color(0xFF1CE783),
      secondaryColor: const Color(0xFF11D67A),
      description: '海外ドラマ・アニメ',
      svgPath: 'assets/icons/services/hulu.svg',
    ),
    'unext': ServiceDefinition(
      id: 'unext',
      name: 'U-NEXT',
      category: ServiceCategory.video,
      icon: FontAwesomeIcons.u,
      primaryColor: const Color(0xFF000000),
      secondaryColor: const Color(0xFF333333),
      description: '映画・アニメ・雑誌',
      svgPath: 'assets/icons/services/unext.svg',
    ),

    // 音楽
    'spotify': ServiceDefinition(
      id: 'spotify',
      name: 'Spotify',
      category: ServiceCategory.music,
      icon: FontAwesomeIcons.spotify,
      primaryColor: const Color(0xFF1DB954),
      secondaryColor: const Color(0xFF191414),
      description: '音楽ストリーミング',
      svgPath: 'assets/icons/services/spotify.svg',
    ),
    'apple_music': ServiceDefinition(
      id: 'apple_music',
      name: 'Apple Music',
      category: ServiceCategory.music,
      icon: FontAwesomeIcons.music,
      primaryColor: const Color(0xFFFA2D48),
      secondaryColor: const Color(0xFFFF6B35),
      description: '音楽ストリーミング',
      svgPath: 'assets/icons/services/apple_music.svg',
    ),
    'amazon_music': ServiceDefinition(
      id: 'amazon_music',
      name: 'Amazon Music',
      category: ServiceCategory.music,
      icon: FontAwesomeIcons.amazon,
      primaryColor: const Color(0xFF232F3E),
      secondaryColor: const Color(0xFF00A8E1),
      description: '音楽ストリーミング・プレイリスト',
      svgPath: 'assets/icons/services/amazon_music.svg',
    ),

    // ショッピング
    'amazon': ServiceDefinition(
      id: 'amazon',
      name: 'Amazon',
      category: ServiceCategory.shopping,
      icon: FontAwesomeIcons.amazon,
      primaryColor: const Color(0xFFFF9900),
      secondaryColor: const Color(0xFF232F3E),
      description: '購入履歴・お気に入り',
      svgPath: 'assets/icons/services/amazon.svg',
    ),

    // その他
    'receipt': ServiceDefinition(
      id: 'receipt',
      name: 'レシート',
      category: ServiceCategory.other,
      icon: FontAwesomeIcons.receipt,
      primaryColor: const Color(0xFF4CAF50),
      secondaryColor: const Color(0xFF45A049),
      description: '購入記録OCR',
    ),
  };

  /// サービス定義を取得
  static ServiceDefinition? get(String serviceId) {
    return _services[serviceId.toLowerCase()];
  }

  /// すべてのサービスIDを取得
  static List<String> get allServiceIds => _services.keys.toList();

  /// カテゴリー別にサービスを取得
  static List<ServiceDefinition> getByCategory(ServiceCategory category) {
    return _services.values
        .where((service) => service.category == category)
        .toList();
  }

  /// カテゴリー別にグループ化されたサービスを取得
  static Map<ServiceCategory, List<ServiceDefinition>> get groupedByCategory {
    final Map<ServiceCategory, List<ServiceDefinition>> grouped = {};
    
    for (final category in ServiceCategory.values) {
      final services = getByCategory(category);
      if (services.isNotEmpty) {
        grouped[category] = services;
      }
    }
    
    return grouped;
  }

  /// サービス名を取得（後方互換性）
  static String getServiceName(String serviceId) {
    return get(serviceId)?.name ?? serviceId;
  }

  /// サービスカラーを取得（後方互換性）
  static Color getServiceColor(String serviceId) {
    return get(serviceId)?.primaryColor ?? const Color(0xFF4ECDC4);
  }

  /// サービスアイコンを取得（後方互換性）
  static IconData getServiceIcon(String serviceId) {
    return get(serviceId)?.icon ?? FontAwesomeIcons.question;
  }

  /// サービスグラデーションを取得（後方互換性）
  static LinearGradient getServiceGradient(String serviceId) {
    final service = get(serviceId);
    if (service != null) {
      return LinearGradient(
        colors: [service.primaryColor, service.secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
    );
  }
}

/// サービスカテゴリー
enum ServiceCategory {
  sns('SNS'),
  video('動画'),
  streaming('配信'),
  music('音楽'),
  shopping('ショッピング'),
  other('その他');

  final String displayName;
  const ServiceCategory(this.displayName);
}

/// サービス定義クラス
class ServiceDefinition {
  final String id;
  final String name;
  final ServiceCategory category;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final String description;
  final String? svgPath;

  const ServiceDefinition({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.description,
    this.svgPath,
  });

  /// グラデーションを生成
  LinearGradient get gradient => LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// 背景色を取得（ダークモード対応）
  Color getBackgroundColor(bool isDark) {
    if (category == ServiceCategory.sns && (id == 'x' || id == 'snapchat')) {
      return isDark ? const Color(0xFF1A1A1A) : Colors.white;
    }
    return primaryColor;
  }

  /// テキスト色を取得（背景色に応じて）
  Color getTextColor() {
    final brightness = ThemeData.estimateBrightnessForColor(primaryColor);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
}