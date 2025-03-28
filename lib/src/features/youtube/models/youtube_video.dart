class YouTubeVideo {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final DateTime publishedAt;
  final String channelId;
  final String channelTitle;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final Duration duration;
  final Map<String, dynamic> metadata;

  YouTubeVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.publishedAt,
    required this.channelId,
    required this.channelTitle,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    required this.duration,
    this.metadata = const {},
  });

  factory YouTubeVideo.fromJson(Map<String, dynamic> json) {
    return YouTubeVideo(
      id: json["id"] as String,
      title: json["title"] as String,
      description: json["description"] as String,
      thumbnailUrl: json["thumbnailUrl"] as String,
      publishedAt: DateTime.parse(json["publishedAt"] as String),
      channelId: json["channelId"] as String,
      channelTitle: json["channelTitle"] as String,
      viewCount: json["viewCount"] as int,
      likeCount: json["likeCount"] as int,
      commentCount: json["commentCount"] as int,
      duration: Duration(seconds: json["duration"] as int),
      metadata: json["metadata"] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "thumbnailUrl": thumbnailUrl,
      "publishedAt": publishedAt.toIso8601String(),
      "channelId": channelId,
      "channelTitle": channelTitle,
      "viewCount": viewCount,
      "likeCount": likeCount,
      "commentCount": commentCount,
      "duration": duration.inSeconds,
      "metadata": metadata,
    };
  }

  YouTubeVideo copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnailUrl,
    DateTime? publishedAt,
    String? channelId,
    String? channelTitle,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    Duration? duration,
    Map<String, dynamic>? metadata,
  }) {
    return YouTubeVideo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      channelId: channelId ?? this.channelId,
      channelTitle: channelTitle ?? this.channelTitle,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      duration: duration ?? this.duration,
      metadata: metadata ?? this.metadata,
    );
  }
}
