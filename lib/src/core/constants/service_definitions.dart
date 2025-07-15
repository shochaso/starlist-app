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
    'niconico': ServiceDefinition(
      id: 'niconico',
      name: 'ニコニコ動画',
      category: ServiceCategory.video,
      icon: FontAwesomeIcons.video,
      primaryColor: const Color(0xFF252525),
      secondaryColor: const Color(0xFF666666),
      description: '動画共有・コメント・生放送',
      svgPath: 'assets/icons/services/niconico.svg',
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
    'showroom': ServiceDefinition(
      id: 'showroom',
      name: 'SHOWROOM',
      category: ServiceCategory.streaming,
      icon: FontAwesomeIcons.video,
      primaryColor: const Color(0xFFFF6B9D),
      secondaryColor: const Color(0xFFFF1744),
      description: 'ライブ配信・バーチャルライブ',
      svgPath: 'assets/icons/services/showroom.svg',
    ),
    'furatch': ServiceDefinition(
      id: 'furatch',
      name: 'ふわっち',
      category: ServiceCategory.streaming,
      icon: FontAwesomeIcons.cloudSun,
      primaryColor: const Color(0xFF87CEEB),
      secondaryColor: const Color(0xFF4682B4),
      description: 'ライブ配信・雑談',
      svgPath: 'assets/icons/services/furatch.svg',
    ),
    '17live': ServiceDefinition(
      id: '17live',
      name: '17LIVE',
      category: ServiceCategory.streaming,
      icon: FontAwesomeIcons.heart,
      primaryColor: const Color(0xFFFF6B6B),
      secondaryColor: const Color(0xFFFF5252),
      description: 'ライブ配信・ギフト',
      svgPath: 'assets/icons/services/17live.svg',
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
    'rakuten': ServiceDefinition(
      id: 'rakuten',
      name: '楽天市場',
      category: ServiceCategory.shopping,
      icon: FontAwesomeIcons.shoppingCart,
      primaryColor: const Color(0xFFBF0000),
      secondaryColor: const Color(0xFF8B0000),
      description: '購入履歴・楽天ポイント',
      svgPath: 'assets/icons/services/rakuten.svg',
    ),
    'yahoo_shopping': ServiceDefinition(
      id: 'yahoo_shopping',
      name: 'Yahoo!ショッピング',
      category: ServiceCategory.shopping,
      icon: FontAwesomeIcons.yahoo,
      primaryColor: const Color(0xFFFF0033),
      secondaryColor: const Color(0xFFCC0029),
      description: '購入履歴・PayPayポイント',
      svgPath: 'assets/icons/services/yahoo_shopping.svg',
    ),
    'mercari': ServiceDefinition(
      id: 'mercari',
      name: 'メルカリ',
      category: ServiceCategory.shopping,
      icon: FontAwesomeIcons.store,
      primaryColor: const Color(0xFFFF5722),
      secondaryColor: const Color(0xFFE64A19),
      description: '売買履歴・出品',
      svgPath: 'assets/icons/services/mercari.svg',
    ),
    'zozotown': ServiceDefinition(
      id: 'zozotown',
      name: 'ZOZOTOWN',
      category: ServiceCategory.shopping,
      icon: FontAwesomeIcons.tshirt,
      primaryColor: const Color(0xFF000000),
      secondaryColor: const Color(0xFF333333),
      description: 'ファッション購入履歴',
      svgPath: 'assets/icons/services/zozotown.svg',
    ),
    'qoo10': ServiceDefinition(
      id: 'qoo10',
      name: 'Qoo10',
      category: ServiceCategory.shopping,
      icon: FontAwesomeIcons.shoppingBag,
      primaryColor: const Color(0xFFFF6600),
      secondaryColor: const Color(0xFFE55A00),
      description: '購入履歴・Qポイント',
      svgPath: 'assets/icons/services/qoo10.svg',
    ),
    'youtube_music': ServiceDefinition(
      id: 'youtube_music',
      name: 'YouTube Music',
      category: ServiceCategory.music,
      icon: FontAwesomeIcons.music,
      primaryColor: const Color(0xFFFF0000),
      secondaryColor: const Color(0xFFCC0000),
      description: '音楽ストリーミング・プレイリスト',
      svgPath: 'assets/icons/services/youtube_music.svg',
    ),
    'bereal': ServiceDefinition(
      id: 'bereal',
      name: 'BeReal',
      category: ServiceCategory.sns,
      icon: FontAwesomeIcons.camera,
      primaryColor: const Color(0xFF000000),
      secondaryColor: const Color(0xFF333333),
      description: '毎日の写真・リアルタイム',
      svgPath: 'assets/icons/services/bereal.svg',
    ),
    'threads': ServiceDefinition(
      id: 'threads',
      name: 'Threads',
      category: ServiceCategory.sns,
      icon: FontAwesomeIcons.at,
      primaryColor: const Color(0xFF000000),
      secondaryColor: const Color(0xFF333333),
      description: 'テキスト投稿・会話',
      svgPath: 'assets/icons/services/threads.svg',
    ),
    'linktree': ServiceDefinition(
      id: 'linktree',
      name: 'Linktree',
      category: ServiceCategory.sns,
      icon: FontAwesomeIcons.link,
      primaryColor: const Color(0xFF39e09b),
      secondaryColor: const Color(0xFF2bc57a),
      description: 'リンクまとめ・プロフィール',
      svgPath: 'assets/icons/services/linktree.svg',
    ),
    'twitcasting': ServiceDefinition(
      id: 'twitcasting',
      name: 'ツイキャス',
      category: ServiceCategory.streaming,
      icon: FontAwesomeIcons.video,
      primaryColor: const Color(0xFF00bfff),
      secondaryColor: const Color(0xFF0099cc),
      description: 'ライブ配信・コメント',
      svgPath: 'assets/icons/services/twitcasting.svg',
    ),
    'palmu': ServiceDefinition(
      id: 'palmu',
      name: 'Palmu',
      category: ServiceCategory.streaming,
      icon: FontAwesomeIcons.video,
      primaryColor: const Color(0xFF9c27b0),
      secondaryColor: const Color(0xFF7b1fa2),
      description: 'ライブ配信・コミュニティ',
      svgPath: 'assets/icons/services/palmu.svg',
    ),
    'line_live': ServiceDefinition(
      id: 'line_live',
      name: 'LINE LIVE',
      category: ServiceCategory.streaming,
      icon: FontAwesomeIcons.video,
      primaryColor: const Color(0xFF00bcd4),
      secondaryColor: const Color(0xFF0097a7),
      description: 'ライブ配信・LINEコイン',
      svgPath: 'assets/icons/services/line_live.svg',
    ),
    'mildom': ServiceDefinition(
      id: 'mildom',
      name: 'Mildom',
      category: ServiceCategory.streaming,
      icon: FontAwesomeIcons.gamepad,
      primaryColor: const Color(0xFF6441a5),
      secondaryColor: const Color(0xFF4c2d7a),
      description: 'ゲーム配信・投げ銭',
      svgPath: 'assets/icons/services/mildom.svg',
    ),
    'live_concert': ServiceDefinition(
      id: 'live_concert',
      name: 'ライブ・コンサート',
      category: ServiceCategory.music,
      icon: FontAwesomeIcons.microphone,
      primaryColor: const Color(0xFF9c27b0),
      secondaryColor: const Color(0xFF7b1fa2),
      description: 'コンサート・ライブ参加履歴',
      svgPath: 'assets/icons/services/live_concert.svg',
    ),
    'other_ec': ServiceDefinition(
      id: 'other_ec',
      name: 'その他EC',
      category: ServiceCategory.shopping,
      icon: FontAwesomeIcons.store,
      primaryColor: const Color(0xFFff9800),
      secondaryColor: const Color(0xFFe68900),
      description: 'その他ECサイト購入履歴',
      svgPath: 'assets/icons/services/other_ec.svg',
    ),

    // グルメ・食事
    'tabelog': ServiceDefinition(
      id: 'tabelog',
      name: '食べログ',
      category: ServiceCategory.food,
      icon: FontAwesomeIcons.utensils,
      primaryColor: const Color(0xFFFF6600),
      secondaryColor: const Color(0xFFE55A00),
      description: 'レストラン・レビュー',
      svgPath: 'assets/icons/services/restaurant_cafe.svg',
    ),
    'gurunavi': ServiceDefinition(
      id: 'gurunavi',
      name: 'ぐるなび',
      category: ServiceCategory.food,
      icon: FontAwesomeIcons.pizzaSlice,
      primaryColor: const Color(0xFF00A0E9),
      secondaryColor: const Color(0xFF0080C7),
      description: 'レストラン・予約',
      svgPath: 'assets/icons/services/restaurant_cafe.svg',
    ),
    'hotpepper': ServiceDefinition(
      id: 'hotpepper',
      name: 'ホットペッパー',
      category: ServiceCategory.food,
      icon: FontAwesomeIcons.fire,
      primaryColor: const Color(0xFFFF6600),
      secondaryColor: const Color(0xFFE55A00),
      description: 'グルメ・クーポン',
      svgPath: 'assets/icons/services/restaurant_cafe.svg',
    ),
    'ubereats': ServiceDefinition(
      id: 'ubereats',
      name: 'Uber Eats',
      category: ServiceCategory.food,
      icon: FontAwesomeIcons.truck,
      primaryColor: const Color(0xFF000000),
      secondaryColor: const Color(0xFF333333),
      description: 'フードデリバリー',
      svgPath: 'assets/icons/services/delivery.svg',
    ),

    // ゲーム・エンタメ
    'steam': ServiceDefinition(
      id: 'steam',
      name: 'Steam',
      category: ServiceCategory.gaming,
      icon: FontAwesomeIcons.steam,
      primaryColor: const Color(0xFF1B2838),
      secondaryColor: const Color(0xFF2A475E),
      description: 'PCゲーム・購入履歴',
      svgPath: 'assets/icons/services/games.svg',
    ),
    'playstation': ServiceDefinition(
      id: 'playstation',
      name: 'PlayStation',
      category: ServiceCategory.gaming,
      icon: FontAwesomeIcons.playstation,
      primaryColor: const Color(0xFF003087),
      secondaryColor: const Color(0xFF0070D1),
      description: 'ゲーム・トロフィー',
      svgPath: 'assets/icons/services/games.svg',
    ),
    'nintendo': ServiceDefinition(
      id: 'nintendo',
      name: 'Nintendo',
      category: ServiceCategory.gaming,
      icon: FontAwesomeIcons.gamepad,
      primaryColor: const Color(0xFFE60012),
      secondaryColor: const Color(0xFF0066CC),
      description: 'ゲーム・マイニンテンドー',
      svgPath: 'assets/icons/services/games.svg',
    ),

    // 読書・学習
    'kindle': ServiceDefinition(
      id: 'kindle',
      name: 'Kindle',
      category: ServiceCategory.books,
      icon: FontAwesomeIcons.bookOpen,
      primaryColor: const Color(0xFF232F3E),
      secondaryColor: const Color(0xFF00A8E1),
      description: '電子書籍・読書履歴',
      svgPath: 'assets/icons/services/books_manga.svg',
    ),
    'bookwalker': ServiceDefinition(
      id: 'bookwalker',
      name: 'BookWalker',
      category: ServiceCategory.books,
      icon: FontAwesomeIcons.book,
      primaryColor: const Color(0xFF00A0E9),
      secondaryColor: const Color(0xFF0080C7),
      description: 'ライトノベル・マンガ',
      svgPath: 'assets/icons/services/books_manga.svg',
    ),

    // 購入・決済
    'credit_card': ServiceDefinition(
      id: 'credit_card',
      name: 'クレジットカード',
      category: ServiceCategory.payment,
      icon: FontAwesomeIcons.creditCard,
      primaryColor: const Color(0xFF4caf50),
      secondaryColor: const Color(0xFF45a049),
      description: 'クレジットカード利用履歴',
      svgPath: 'assets/icons/services/credit_card.svg',
    ),
    'electronic_money': ServiceDefinition(
      id: 'electronic_money',
      name: '電子マネー',
      category: ServiceCategory.payment,
      icon: FontAwesomeIcons.mobileAlt,
      primaryColor: const Color(0xFF2196f3),
      secondaryColor: const Color(0xFF1976d2),
      description: '電子マネー利用履歴',
      svgPath: 'assets/icons/services/electronic_money.svg',
    ),

    // エンタメ
    'games': ServiceDefinition(
      id: 'games',
      name: 'ゲーム',
      category: ServiceCategory.entertainment,
      icon: FontAwesomeIcons.gamepad,
      primaryColor: const Color(0xFF673ab7),
      secondaryColor: const Color(0xFF512da8),
      description: 'ゲーム・プレイ履歴',
      svgPath: 'assets/icons/services/games.svg',
    ),
    'books_manga': ServiceDefinition(
      id: 'books_manga',
      name: '書籍・漫画',
      category: ServiceCategory.entertainment,
      icon: FontAwesomeIcons.book,
      primaryColor: const Color(0xFFff9800),
      secondaryColor: const Color(0xFFf57c00),
      description: '書籍・漫画購入履歴',
      svgPath: 'assets/icons/services/books_manga.svg',
    ),
    'cinema': ServiceDefinition(
      id: 'cinema',
      name: '映画館',
      category: ServiceCategory.entertainment,
      icon: FontAwesomeIcons.film,
      primaryColor: const Color(0xFFe91e63),
      secondaryColor: const Color(0xFFc2185b),
      description: '映画館・チケット購入履歴',
      svgPath: 'assets/icons/services/cinema.svg',
    ),
    'restaurant_cafe': ServiceDefinition(
      id: 'restaurant_cafe',
      name: 'レストラン・カフェ',
      category: ServiceCategory.food,
      icon: FontAwesomeIcons.utensils,
      primaryColor: const Color(0xFF795548),
      secondaryColor: const Color(0xFF5d4037),
      description: 'レストラン・カフェ利用履歴',
      svgPath: 'assets/icons/services/restaurant_cafe.svg',
    ),
    'delivery': ServiceDefinition(
      id: 'delivery',
      name: 'デリバリー',
      category: ServiceCategory.food,
      icon: FontAwesomeIcons.truck,
      primaryColor: const Color(0xFF4caf50),
      secondaryColor: const Color(0xFF45a049),
      description: 'デリバリー・配達履歴',
      svgPath: 'assets/icons/services/delivery.svg',
    ),
    'cooking': ServiceDefinition(
      id: 'cooking',
      name: '自炊',
      category: ServiceCategory.food,
      icon: FontAwesomeIcons.fire,
      primaryColor: const Color(0xFFff5722),
      secondaryColor: const Color(0xFFe64a19),
      description: '自炊・レシピ・食材購入',
      svgPath: 'assets/icons/services/cooking.svg',
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
      svgPath: 'assets/icons/services/credit_card.svg',
    ),
    'pixiv': ServiceDefinition(
      id: 'pixiv',
      name: 'pixiv',
      category: ServiceCategory.other,
      icon: FontAwesomeIcons.palette,
      primaryColor: const Color(0xFF0096FA),
      secondaryColor: const Color(0xFF0078D4),
      description: 'イラスト・創作',
      svgPath: 'assets/icons/services/other_ec.svg',
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
  food('グルメ・食事'),
  gaming('ゲーム'),
  books('読書'),
  payment('購入・決済'),
  entertainment('エンタメ'),
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