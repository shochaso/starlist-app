enum RankingType {
  daily,
  weekly,
  monthly,
  yearly,
  allTime,
}

class RankingEntry {
  final String userId;
  final String username;
  final String? avatarUrl;
  final int rank;
  final double score;
  final DateTime lastUpdated;
  final Map<String, dynamic> metadata;

  RankingEntry({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.rank,
    required this.score,
    required this.lastUpdated,
    this.metadata = const {},
  });

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    return RankingEntry(
      userId: json["userId"] as String,
      username: json["username"] as String,
      avatarUrl: json["avatarUrl"] as String?,
      rank: json["rank"] as int,
      score: (json["score"] as num).toDouble(),
      lastUpdated: DateTime.parse(json["lastUpdated"] as String),
      metadata: json["metadata"] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "username": username,
      "avatarUrl": avatarUrl,
      "rank": rank,
      "score": score,
      "lastUpdated": lastUpdated.toIso8601String(),
      "metadata": metadata,
    };
  }

  RankingEntry copyWith({
    String? userId,
    String? username,
    String? avatarUrl,
    int? rank,
    double? score,
    DateTime? lastUpdated,
    Map<String, dynamic>? metadata,
  }) {
    return RankingEntry(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rank: rank ?? this.rank,
      score: score ?? this.score,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      metadata: metadata ?? this.metadata,
    );
  }
}
