/// ジャンル分類タクソノミー v1
/// 
/// 各サービス・プラットフォームのコンテンツを統一的なジャンルで分類
/// 検索、フィルタリング、レコメンデーション機能で使用
class GenreTaxonomyV1 {
  final Map<String, CategoryData> categories;

  const GenreTaxonomyV1({
    required this.categories,
  });

  factory GenreTaxonomyV1.fromJson(Map<String, dynamic> json) {
    return GenreTaxonomyV1(
      categories: (json['genre_taxonomy_v1'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, CategoryData.fromJson(value)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'genre_taxonomy_v1': categories.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }

  /// 指定されたカテゴリのデータを取得
  CategoryData? getCategory(String categoryKey) {
    return categories[categoryKey];
  }

  /// 全ジャンルのリストを取得（検索用）
  List<Genre> getAllGenres() {
    return categories.values
        .expand((category) => category.genres)
        .toList();
  }

  /// サービス名でジャンルを検索
  List<Genre> getGenresByService(String serviceName) {
    return categories.values
        .where((category) => category.services.contains(serviceName))
        .expand((category) => category.genres)
        .toList();
  }

  /// ジャンルスラッグで検索
  Genre? getGenreBySlug(String slug) {
    for (final category in categories.values) {
      final genre = category.genres.firstWhere(
        (g) => g.slug == slug,
        orElse: () => throw StateError('Genre not found'),
      );
      if (genre.slug == slug) return genre;
    }
    return null;
  }
}

class CategoryData {
  final List<String> services;
  final List<Genre> genres;
  final Map<String, List<Genre>>? serviceOverrides;

  const CategoryData({
    required this.services,
    required this.genres,
    this.serviceOverrides,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      services: List<String>.from(json['services']),
      genres: (json['genres'] as List)
          .map((g) => Genre.fromJson(g))
          .toList(),
      serviceOverrides: json['service_overrides'] != null
          ? (json['service_overrides'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                (value as List).map((g) => Genre.fromJson(g)).toList(),
              ),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'services': services,
      'genres': genres.map((g) => g.toJson()).toList(),
      if (serviceOverrides != null)
        'service_overrides': serviceOverrides!.map(
          (key, value) => MapEntry(key, value.map((g) => g.toJson()).toList()),
        ),
    };
  }

  /// 指定されたサービスのジャンルを取得（オーバーライド含む）
  List<Genre> getGenresForService(String serviceName) {
    final baseGenres = genres;
    
    if (serviceOverrides != null && serviceOverrides!.containsKey(serviceName)) {
      // オーバーライドがある場合は、基本ジャンル + オーバーライドジャンル
      return [...baseGenres, ...serviceOverrides![serviceName]!];
    }
    
    return baseGenres;
  }
}

class Genre {
  final String slug;
  final String label;

  const Genre({
    required this.slug,
    required this.label,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      slug: json['slug'],
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'label': label,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Genre && other.slug == slug;
  }

  @override
  int get hashCode => slug.hashCode;

  @override
  String toString() => 'Genre(slug: $slug, label: $label)';
}

/// デフォルトのジャンルタクソノミーデータ
class DefaultGenreTaxonomy {
  static const GenreTaxonomyV1 data = GenreTaxonomyV1(
    categories: {
      'video': CategoryData(
        services: ['prime_video', 'netflix', 'unext', 'hulu_jp'],
        genres: [
          Genre(slug: 'anime', label: 'アニメ'),
          Genre(slug: 'drama_jp', label: '国内ドラマ'),
          Genre(slug: 'drama_overseas', label: '海外ドラマ'),
          Genre(slug: 'variety', label: 'バラエティ'),
          Genre(slug: 'movie', label: '映画'),
          Genre(slug: 'documentary', label: 'ドキュメンタリー'),
          Genre(slug: 'reality', label: 'リアリティ'),
          Genre(slug: 'kids_family', label: 'キッズ/ファミリー'),
          Genre(slug: 'sports', label: 'スポーツ'),
          Genre(slug: 'horror', label: 'ホラー'),
        ],
        serviceOverrides: {
          'unext': [Genre(slug: 'anime_deep', label: '深夜アニメ')],
          'hulu_jp': [Genre(slug: 'ntv_drama', label: '日テレ系ドラマ')],
        },
      ),
      'shopping': CategoryData(
        services: ['rakuten', 'amazon', 'yahoo_shopping'],
        genres: [
          Genre(slug: 'electronics', label: '家電/ガジェット'),
          Genre(slug: 'fashion', label: 'ファッション'),
          Genre(slug: 'beauty', label: 'コスメ/ビューティー'),
          Genre(slug: 'home_kitchen', label: '日用品/キッチン'),
          Genre(slug: 'grocery', label: '食品'),
          Genre(slug: 'hobby', label: 'ホビー/玩具'),
          Genre(slug: 'sports_outdoor', label: 'スポーツ/アウトドア'),
          Genre(slug: 'pet', label: 'ペット'),
          Genre(slug: 'baby', label: 'ベビー/マタニティ'),
          Genre(slug: 'books', label: '本/Kindle'),
        ],
      ),
      'food_delivery': CategoryData(
        services: ['ubereats', 'demaecan'],
        genres: [
          Genre(slug: 'japanese', label: '和食'),
          Genre(slug: 'chinese', label: '中華'),
          Genre(slug: 'korean', label: '韓国'),
          Genre(slug: 'italian', label: 'イタリアン'),
          Genre(slug: 'curry', label: 'カレー'),
          Genre(slug: 'burger', label: 'バーガー'),
          Genre(slug: 'pizza', label: 'ピザ'),
          Genre(slug: 'ramen', label: 'ラーメン'),
          Genre(slug: 'sushi', label: '寿司'),
          Genre(slug: 'cafe_sweets', label: 'カフェ/スイーツ'),
        ],
      ),
      'convenience_store': CategoryData(
        services: ['seven', 'familymart', 'lawson', 'daily_yamazaki', 'ministop'],
        genres: [
          Genre(slug: 'onigiri', label: 'おにぎり'),
          Genre(slug: 'bento', label: '弁当'),
          Genre(slug: 'sandwich', label: 'サンド/パン'),
          Genre(slug: 'instant_noodles', label: 'カップ麺'),
          Genre(slug: 'sweets', label: 'スイーツ'),
          Genre(slug: 'drink', label: '飲料'),
          Genre(slug: 'coffee', label: 'コーヒー'),
          Genre(slug: 'alcohol', label: 'アルコール'),
          Genre(slug: 'frozen', label: '冷凍食品'),
          Genre(slug: 'hot_snack', label: 'ホットスナック'),
        ],
      ),
      'music': CategoryData(
        services: ['amazon_music', 'spotify', 'apple_music'],
        genres: [
          Genre(slug: 'jpop', label: 'J-POP'),
          Genre(slug: 'rock', label: 'ロック'),
          Genre(slug: 'hiphop', label: 'ヒップホップ'),
          Genre(slug: 'edm', label: 'EDM'),
          Genre(slug: 'idol', label: 'アイドル'),
          Genre(slug: 'vocaloid', label: 'ボカロ'),
          Genre(slug: 'anime_song', label: 'アニソン'),
          Genre(slug: 'jazz', label: 'ジャズ'),
          Genre(slug: 'classical', label: 'クラシック'),
          Genre(slug: 'kpop', label: 'K-POP'),
        ],
      ),
      'game_play': CategoryData(
        services: ['steam', 'psn', 'nintendo'],
        genres: [
          Genre(slug: 'action', label: 'アクション'),
          Genre(slug: 'rpg', label: 'RPG'),
          Genre(slug: 'fps_tps', label: 'FPS/TPS'),
          Genre(slug: 'battle_royale', label: 'バトロワ'),
          Genre(slug: 'sports', label: 'スポーツ'),
          Genre(slug: 'racing', label: 'レース'),
          Genre(slug: 'simulation', label: 'シミュレーション'),
          Genre(slug: 'strategy', label: 'ストラテジー'),
          Genre(slug: 'puzzle', label: 'パズル'),
          Genre(slug: 'adventure', label: 'アドベンチャー'),
        ],
      ),
      'mobile_apps': CategoryData(
        services: ['ios_appstore', 'android_playstore'],
        genres: [
          Genre(slug: 'productivity', label: '仕事効率化'),
          Genre(slug: 'sns', label: 'SNS'),
          Genre(slug: 'finance', label: 'ファイナンス'),
          Genre(slug: 'shopping', label: 'ショッピング'),
          Genre(slug: 'health_fitness', label: '健康/フィットネス'),
          Genre(slug: 'education', label: '教育'),
          Genre(slug: 'photo_video', label: '写真/動画'),
          Genre(slug: 'entertainment', label: 'エンタメ'),
          Genre(slug: 'travel', label: '旅行'),
          Genre(slug: 'news', label: 'ニュース'),
        ],
      ),
      'screen_time': CategoryData(
        services: ['ios_screentime', 'android_digital_wellbeing'],
        genres: [
          Genre(slug: 'focus_days', label: '集中日'),
          Genre(slug: 'binge_hours', label: '使い過ぎ時間帯'),
          Genre(slug: 'notifications_high', label: '通知多め'),
          Genre(slug: 'social_heavy', label: 'SNS多用'),
          Genre(slug: 'video_heavy', label: '動画多用'),
          Genre(slug: 'gaming_heavy', label: 'ゲーム多用'),
          Genre(slug: 'work_heavy', label: '仕事アプリ多用'),
        ],
      ),
      'fashion': CategoryData(
        services: ['zozo', 'uniqlo', 'gu', 'shein', 'wear_log'],
        genres: [
          Genre(slug: 'tops', label: 'トップス'),
          Genre(slug: 'bottoms', label: 'ボトムス'),
          Genre(slug: 'outer', label: 'アウター'),
          Genre(slug: 'shoes', label: 'シューズ'),
          Genre(slug: 'bag', label: 'バッグ'),
          Genre(slug: 'accessory', label: 'アクセサリー'),
          Genre(slug: 'casual', label: 'カジュアル'),
          Genre(slug: 'street', label: 'ストリート'),
          Genre(slug: 'minimal', label: 'ミニマル'),
          Genre(slug: 'business', label: 'ビジネス'),
        ],
      ),
      'book': CategoryData(
        services: ['amazon_books', 'kindle', 'rakuten_books', 'bookwalker', 'booklive', 'audible'],
        genres: [
          Genre(slug: 'fiction', label: '小説/フィクション'),
          Genre(slug: 'nonfiction', label: 'ノンフィクション'),
          Genre(slug: 'business', label: 'ビジネス'),
          Genre(slug: 'selfhelp', label: '自己啓発'),
          Genre(slug: 'technology', label: 'テクノロジー'),
          Genre(slug: 'comics_manga', label: '漫画'),
          Genre(slug: 'light_novel', label: 'ラノベ'),
          Genre(slug: 'literature', label: '文学'),
          Genre(slug: 'history', label: '歴史'),
          Genre(slug: 'biography', label: '伝記'),
        ],
      ),
    },
  );
}


