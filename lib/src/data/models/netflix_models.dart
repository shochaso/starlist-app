import 'package:flutter/foundation.dart';

/// Netflix視聴履歴の種類
enum NetflixContentType {
  movie,          // 映画
  series,         // シリーズ
  documentary,    // ドキュメンタリー
  anime,          // アニメ
  standup,        // スタンダップコメディ
  kids,           // キッズ
  reality,        // リアリティ番組
  other,          // その他
}

/// Netflix視聴状態
enum NetflixWatchStatus {
  completed,      // 完了
  inProgress,     // 視聴中
  watchlist,      // マイリスト
  stopped,        // 途中停止
}

/// Netflix視聴履歴モデル
@immutable
class NetflixViewingHistory {
  final String id;
  final String userId;
  final String contentId;
  final String title;
  final String? subtitle;  // エピソードタイトルなど
  final NetflixContentType contentType;
  final String? genre;
  final String? description;
  final int? releaseYear;
  final String? imageUrl;
  final String? netflixUrl;
  final DateTime watchedAt;
  final Duration? watchDuration;
  final Duration? totalDuration;
  final NetflixWatchStatus watchStatus;
  final double? progressPercentage;
  final int? rating;
  final String? review;
  final int? seasonNumber;
  final int? episodeNumber;
  final String? director;
  final List<String> cast;
  final List<String> genres;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NetflixViewingHistory({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.title,
    this.subtitle,
    required this.contentType,
    this.genre,
    this.description,
    this.releaseYear,
    this.imageUrl,
    this.netflixUrl,
    required this.watchedAt,
    this.watchDuration,
    this.totalDuration,
    required this.watchStatus,
    this.progressPercentage,
    this.rating,
    this.review,
    this.seasonNumber,
    this.episodeNumber,
    this.director,
    required this.cast,
    required this.genres,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSONからNetflixViewingHistoryを作成
  factory NetflixViewingHistory.fromJson(Map<String, dynamic> json) {
    return NetflixViewingHistory(
      id: json['id'],
      userId: json['user_id'],
      contentId: json['content_id'],
      title: json['title'],
      subtitle: json['subtitle'],
      contentType: _parseContentType(json['content_type']),
      genre: json['genre'],
      description: json['description'],
      releaseYear: json['release_year'],
      imageUrl: json['image_url'],
      netflixUrl: json['netflix_url'],
      watchedAt: DateTime.parse(json['watched_at']),
      watchDuration: json['watch_duration'] != null ? Duration(seconds: json['watch_duration']) : null,
      totalDuration: json['total_duration'] != null ? Duration(seconds: json['total_duration']) : null,
      watchStatus: _parseWatchStatus(json['watch_status']),
      progressPercentage: json['progress_percentage']?.toDouble(),
      rating: json['rating'],
      review: json['review'],
      seasonNumber: json['season_number'],
      episodeNumber: json['episode_number'],
      director: json['director'],
      cast: List<String>.from(json['cast'] ?? []),
      genres: List<String>.from(json['genres'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// NetflixViewingHistoryをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content_id': contentId,
      'title': title,
      'subtitle': subtitle,
      'content_type': _contentTypeToString(contentType),
      'genre': genre,
      'description': description,
      'release_year': releaseYear,
      'image_url': imageUrl,
      'netflix_url': netflixUrl,
      'watched_at': watchedAt.toIso8601String(),
      'watch_duration': watchDuration?.inSeconds,
      'total_duration': totalDuration?.inSeconds,
      'watch_status': _watchStatusToString(watchStatus),
      'progress_percentage': progressPercentage,
      'rating': rating,
      'review': review,
      'season_number': seasonNumber,
      'episode_number': episodeNumber,
      'director': director,
      'cast': cast,
      'genres': genres,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// コピーを作成
  NetflixViewingHistory copyWith({
    String? id,
    String? userId,
    String? contentId,
    String? title,
    String? subtitle,
    NetflixContentType? contentType,
    String? genre,
    String? description,
    int? releaseYear,
    String? imageUrl,
    String? netflixUrl,
    DateTime? watchedAt,
    Duration? watchDuration,
    Duration? totalDuration,
    NetflixWatchStatus? watchStatus,
    double? progressPercentage,
    int? rating,
    String? review,
    int? seasonNumber,
    int? episodeNumber,
    String? director,
    List<String>? cast,
    List<String>? genres,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NetflixViewingHistory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contentId: contentId ?? this.contentId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      contentType: contentType ?? this.contentType,
      genre: genre ?? this.genre,
      description: description ?? this.description,
      releaseYear: releaseYear ?? this.releaseYear,
      imageUrl: imageUrl ?? this.imageUrl,
      netflixUrl: netflixUrl ?? this.netflixUrl,
      watchedAt: watchedAt ?? this.watchedAt,
      watchDuration: watchDuration ?? this.watchDuration,
      totalDuration: totalDuration ?? this.totalDuration,
      watchStatus: watchStatus ?? this.watchStatus,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      director: director ?? this.director,
      cast: cast ?? List<String>.from(this.cast),
      genres: genres ?? List<String>.from(this.genres),
      metadata: metadata ?? Map<String, dynamic>.from(this.metadata),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// コンテンツタイプ文字列を解析
  static NetflixContentType _parseContentType(String? type) {
    if (type == null) return NetflixContentType.other;
    
    switch (type.toLowerCase()) {
      case 'movie':
        return NetflixContentType.movie;
      case 'series':
        return NetflixContentType.series;
      case 'documentary':
        return NetflixContentType.documentary;
      case 'anime':
        return NetflixContentType.anime;
      case 'standup':
        return NetflixContentType.standup;
      case 'kids':
        return NetflixContentType.kids;
      case 'reality':
        return NetflixContentType.reality;
      default:
        return NetflixContentType.other;
    }
  }

  /// コンテンツタイプを文字列に変換
  static String _contentTypeToString(NetflixContentType type) {
    switch (type) {
      case NetflixContentType.movie:
        return 'movie';
      case NetflixContentType.series:
        return 'series';
      case NetflixContentType.documentary:
        return 'documentary';
      case NetflixContentType.anime:
        return 'anime';
      case NetflixContentType.standup:
        return 'standup';
      case NetflixContentType.kids:
        return 'kids';
      case NetflixContentType.reality:
        return 'reality';
      case NetflixContentType.other:
        return 'other';
    }
  }

  /// 視聴状態文字列を解析
  static NetflixWatchStatus _parseWatchStatus(String? status) {
    if (status == null) return NetflixWatchStatus.completed;
    
    switch (status.toLowerCase()) {
      case 'completed':
        return NetflixWatchStatus.completed;
      case 'in_progress':
        return NetflixWatchStatus.inProgress;
      case 'watchlist':
        return NetflixWatchStatus.watchlist;
      case 'stopped':
        return NetflixWatchStatus.stopped;
      default:
        return NetflixWatchStatus.completed;
    }
  }

  /// 視聴状態を文字列に変換
  static String _watchStatusToString(NetflixWatchStatus status) {
    switch (status) {
      case NetflixWatchStatus.completed:
        return 'completed';
      case NetflixWatchStatus.inProgress:
        return 'in_progress';
      case NetflixWatchStatus.watchlist:
        return 'watchlist';
      case NetflixWatchStatus.stopped:
        return 'stopped';
    }
  }

  /// 完全タイトル（シーズン・エピソード情報含む）
  String get fullTitle {
    if (contentType == NetflixContentType.series && seasonNumber != null && episodeNumber != null) {
      final season = 'S${seasonNumber.toString().padLeft(2, '0')}';
      final episode = 'E${episodeNumber.toString().padLeft(2, '0')}';
      return '$title $season$episode${subtitle != null ? ': $subtitle' : ''}';
    }
    return subtitle != null ? '$title: $subtitle' : title;
  }

  /// コンテンツタイプの日本語名
  String get contentTypeDisplayName {
    switch (contentType) {
      case NetflixContentType.movie:
        return '映画';
      case NetflixContentType.series:
        return 'シリーズ';
      case NetflixContentType.documentary:
        return 'ドキュメンタリー';
      case NetflixContentType.anime:
        return 'アニメ';
      case NetflixContentType.standup:
        return 'スタンダップコメディ';
      case NetflixContentType.kids:
        return 'キッズ';
      case NetflixContentType.reality:
        return 'リアリティ番組';
      case NetflixContentType.other:
        return 'その他';
    }
  }

  /// 視聴状態の日本語名
  String get watchStatusDisplayName {
    switch (watchStatus) {
      case NetflixWatchStatus.completed:
        return '視聴完了';
      case NetflixWatchStatus.inProgress:
        return '視聴中';
      case NetflixWatchStatus.watchlist:
        return 'マイリスト';
      case NetflixWatchStatus.stopped:
        return '途中停止';
    }
  }

  /// 視聴進捗を計算
  double get calculatedProgress {
    if (progressPercentage != null) return progressPercentage! / 100;
    if (watchDuration != null && totalDuration != null && totalDuration!.inSeconds > 0) {
      return watchDuration!.inSeconds / totalDuration!.inSeconds;
    }
    return watchStatus == NetflixWatchStatus.completed ? 1.0 : 0.0;
  }

  /// 視聴時間の文字列表現
  String get watchDurationString {
    if (watchDuration == null) return '-';
    
    final hours = watchDuration!.inHours;
    final minutes = (watchDuration!.inMinutes % 60);
    
    if (hours > 0) {
      return '$hours時間$minutes分';
    } else {
      return '$minutes分';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NetflixViewingHistory &&
        other.id == id &&
        other.userId == userId &&
        other.contentId == contentId &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.contentType == contentType &&
        other.watchedAt == watchedAt &&
        other.watchStatus == watchStatus &&
        listEquals(other.cast, cast) &&
        listEquals(other.genres, genres) &&
        mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        contentId,
        title,
        subtitle,
        contentType,
        watchedAt,
        watchStatus,
        cast,
        genres,
        metadata,
      );
}

/// Netflix視聴統計モデル
@immutable
class NetflixViewingStats {
  final int totalItems;
  final Duration totalWatchTime;
  final Map<NetflixContentType, int> itemsByType;
  final Map<NetflixContentType, Duration> timeByType;
  final Map<String, int> itemsByGenre;
  final Map<String, Duration> timeByGenre;
  final List<String> topGenres;
  final List<String> topCast;
  final List<String> topDirectors;
  final Map<int, int> itemsByYear;
  final double averageRating;
  final int totalRatings;
  final DateTime periodStart;
  final DateTime periodEnd;

  const NetflixViewingStats({
    required this.totalItems,
    required this.totalWatchTime,
    required this.itemsByType,
    required this.timeByType,
    required this.itemsByGenre,
    required this.timeByGenre,
    required this.topGenres,
    required this.topCast,
    required this.topDirectors,
    required this.itemsByYear,
    required this.averageRating,
    required this.totalRatings,
    required this.periodStart,
    required this.periodEnd,
  });

  /// 統計をJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'total_items': totalItems,
      'total_watch_time_seconds': totalWatchTime.inSeconds,
      'items_by_type': itemsByType.map(
        (key, value) => MapEntry(NetflixViewingHistory._contentTypeToString(key), value),
      ),
      'time_by_type_seconds': timeByType.map(
        (key, value) => MapEntry(NetflixViewingHistory._contentTypeToString(key), value.inSeconds),
      ),
      'items_by_genre': itemsByGenre,
      'time_by_genre_seconds': timeByGenre.map((key, value) => MapEntry(key, value.inSeconds)),
      'top_genres': topGenres,
      'top_cast': topCast,
      'top_directors': topDirectors,
      'items_by_year': itemsByYear.map((key, value) => MapEntry(key.toString(), value)),
      'average_rating': averageRating,
      'total_ratings': totalRatings,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
    };
  }

  /// 視聴時間の文字列表現
  String get totalWatchTimeString {
    final hours = totalWatchTime.inHours;
    final minutes = (totalWatchTime.inMinutes % 60);
    
    if (hours > 24) {
      final days = hours ~/ 24;
      final remainingHours = hours % 24;
      return '$days日$remainingHours時間$minutes分';
    } else if (hours > 0) {
      return '$hours時間$minutes分';
    } else {
      return '$minutes分';
    }
  }
}

/// Netflix視聴履歴フィルターモデル
@immutable
class NetflixViewingFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<NetflixContentType>? contentTypes;
  final List<String>? genres;
  final List<NetflixWatchStatus>? watchStatuses;
  final int? minRating;
  final int? maxRating;
  final String? searchQuery;
  final int? releaseYearStart;
  final int? releaseYearEnd;

  const NetflixViewingFilter({
    this.startDate,
    this.endDate,
    this.contentTypes,
    this.genres,
    this.watchStatuses,
    this.minRating,
    this.maxRating,
    this.searchQuery,
    this.releaseYearStart,
    this.releaseYearEnd,
  });

  /// フィルターをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'content_types': contentTypes?.map((c) => NetflixViewingHistory._contentTypeToString(c)).toList(),
      'genres': genres,
      'watch_statuses': watchStatuses?.map((s) => NetflixViewingHistory._watchStatusToString(s)).toList(),
      'min_rating': minRating,
      'max_rating': maxRating,
      'search_query': searchQuery,
      'release_year_start': releaseYearStart,
      'release_year_end': releaseYearEnd,
    };
  }

  /// フィルターが適用されているかどうか
  bool get hasFilters {
    return startDate != null ||
           endDate != null ||
           contentTypes != null ||
           genres != null ||
           watchStatuses != null ||
           minRating != null ||
           maxRating != null ||
           (searchQuery != null && searchQuery!.isNotEmpty) ||
           releaseYearStart != null ||
           releaseYearEnd != null;
  }

  /// コピーを作成
  NetflixViewingFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    List<NetflixContentType>? contentTypes,
    List<String>? genres,
    List<NetflixWatchStatus>? watchStatuses,
    int? minRating,
    int? maxRating,
    String? searchQuery,
    int? releaseYearStart,
    int? releaseYearEnd,
  }) {
    return NetflixViewingFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      contentTypes: contentTypes ?? this.contentTypes,
      genres: genres ?? this.genres,
      watchStatuses: watchStatuses ?? this.watchStatuses,
      minRating: minRating ?? this.minRating,
      maxRating: maxRating ?? this.maxRating,
      searchQuery: searchQuery ?? this.searchQuery,
      releaseYearStart: releaseYearStart ?? this.releaseYearStart,
      releaseYearEnd: releaseYearEnd ?? this.releaseYearEnd,
    );
  }
}