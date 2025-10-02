class Star {
  final String id;
  final String name;
  final List<String> platforms; // YouTuber, ミュージシャン, アイドルなど
  final List<String> genres; // 音楽, ゲーム, 料理など
  final String rank; // 全体的なランク
  final int followers;
  final String imageUrl;
  final Map<String, GenreRating> genreRatings; // 各ジャンルでの評価
  final bool isVerified; // 認証済みかどうか
  final List<SocialAccount> socialAccounts; // 連携済みSNSアカウント
  final String? description; // スターの自己紹介やキャッチフレーズ

  Star({
    required this.id,
    required this.name,
    required this.platforms,
    required this.genres,
    required this.rank,
    required this.followers,
    required this.imageUrl,
    this.genreRatings = const {},
    this.isVerified = false,
    this.socialAccounts = const [],
    this.description, // descriptionをコンストラクタに追加
  });

  factory Star.fromJson(Map<String, dynamic> json) {
    // ジャンル評価のデシリアライズ
    Map<String, GenreRating> ratings = {};
    if (json['genre_ratings'] != null) {
      (json['genre_ratings'] as Map<String, dynamic>).forEach((key, value) {
        ratings[key] = GenreRating.fromJson(value);
      });
    }
    
    // ソーシャルアカウントのデシリアライズ
    List<SocialAccount> accounts = [];
    if (json['social_accounts'] != null) {
      for (var account in json['social_accounts']) {
        accounts.add(SocialAccount.fromJson(account));
      }
    }
    
    return Star(
      id: json['id'],
      name: json['name'],
      platforms: List<String>.from(json['platforms'] ?? []),
      genres: List<String>.from(json['genres'] ?? []),
      rank: json['rank'],
      followers: json['followers'],
      imageUrl: json['image_url'],
      genreRatings: ratings,
      isVerified: json['is_verified'] ?? false,
      socialAccounts: accounts,
      description: json['description'], // descriptionをデシリアライズに追加
    );
  }

  Map<String, dynamic> toJson() {
    // ジャンル評価のシリアライズ
    Map<String, dynamic> ratingsJson = {};
    genreRatings.forEach((key, value) {
      ratingsJson[key] = value.toJson();
    });
    
    // ソーシャルアカウントのシリアライズ
    List<Map<String, dynamic>> accountsJson = [];
    for (var account in socialAccounts) {
      accountsJson.add(account.toJson());
    }
    
    return {
      'id': id,
      'name': name,
      'platforms': platforms,
      'genres': genres,
      'rank': rank,
      'followers': followers,
      'image_url': imageUrl,
      'genre_ratings': ratingsJson,
      'is_verified': isVerified,
      'social_accounts': accountsJson,
      'description': description, // descriptionをシリアライズに追加
    };
  }
  
  // 特定のジャンルでのレベルを取得
  int getLevelForGenre(String genre) {
    if (genreRatings.containsKey(genre)) {
      return genreRatings[genre]!.level;
    }
    return 0;
  }
  
  // 特定のジャンルでのポイントを取得
  int getPointsForGenre(String genre) {
    if (genreRatings.containsKey(genre)) {
      return genreRatings[genre]!.points;
    }
    return 0;
  }
}

// ジャンルごとの評価クラス
class GenreRating {
  final int level; // ジャンルでのレベル（1-10）
  final int points; // ジャンルでのポイント
  final DateTime lastUpdated; // 最終更新日
  
  GenreRating({
    required this.level,
    required this.points,
    required this.lastUpdated,
  });
  
  factory GenreRating.fromJson(Map<String, dynamic> json) {
    return GenreRating(
      level: json['level'],
      points: json['points'],
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'points': points,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}

// ソーシャルアカウント連携クラス
class SocialAccount {
  final String platform; // Twitter, Instagram, YouTube など
  final String username;
  final String url;
  final bool isVerified; // このアカウントが認証済みかどうか
  final DateTime verifiedAt; // 認証された日時
  
  SocialAccount({
    required this.platform,
    required this.username,
    required this.url,
    this.isVerified = false,
    DateTime? verifiedAt,
  }) : verifiedAt = verifiedAt ?? DateTime.now();
  
  factory SocialAccount.fromJson(Map<String, dynamic> json) {
    return SocialAccount(
      platform: json['platform'],
      username: json['username'],
      url: json['url'],
      isVerified: json['is_verified'] ?? false,
      verifiedAt: json['verified_at'] != null 
          ? DateTime.parse(json['verified_at']) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'username': username,
      'url': url,
      'is_verified': isVerified,
      'verified_at': isVerified ? verifiedAt.toIso8601String() : null,
    };
  }
} 