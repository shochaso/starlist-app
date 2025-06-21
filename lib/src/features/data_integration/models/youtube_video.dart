/// YouTubeの動画データを表すモデルクラス
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
  });

  factory YouTubeVideo.fromJson(Map<String, dynamic> json) {
    return YouTubeVideo(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      publishedAt: json['publishedAt'] != null 
        ? DateTime.parse(json['publishedAt']) 
        : DateTime.now(),
      channelId: json['channelId'] ?? '',
      channelTitle: json['channelTitle'] ?? '',
      viewCount: json['viewCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      duration: json['duration'] != null 
        ? Duration(seconds: json['duration']) 
        : Duration.zero,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'publishedAt': publishedAt.toIso8601String(),
      'channelId': channelId,
      'channelTitle': channelTitle,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'duration': duration.inSeconds,
    };
  }
} 