/// YouTubeの動画情報を表すモデルクラス
class YouTubeVideo {
  final String id;
  final String title;
  final String channelId;
  final String channelTitle;
  final String thumbnailUrl;
  final String description;
  final DateTime publishedAt;
  final int viewCount;
  final int likeCount;
  final Duration duration;

  YouTubeVideo({
    required this.id,
    required this.title,
    required this.channelId,
    required this.channelTitle,
    required this.thumbnailUrl,
    required this.description,
    required this.publishedAt,
    required this.viewCount,
    required this.likeCount,
    required this.duration,
  });

  /// JSON形式のデータからYouTubeVideoオブジェクトを生成するファクトリメソッド
  factory YouTubeVideo.fromJson(Map<String, dynamic> json) {
    // スニペット情報の取得
    final snippet = json['snippet'] ?? {};
    
    // サムネイル情報の取得（高解像度から順に試行）
    final thumbnails = snippet['thumbnails'] ?? {};
    final thumbnailUrl = thumbnails['high']?['url'] ?? 
                         thumbnails['medium']?['url'] ?? 
                         thumbnails['default']?['url'] ?? '';
    
    // 統計情報の取得
    final statistics = json['statistics'] ?? {};
    final viewCount = int.tryParse(statistics['viewCount'] ?? '0') ?? 0;
    final likeCount = int.tryParse(statistics['likeCount'] ?? '0') ?? 0;
    
    // コンテンツ詳細情報の取得
    final contentDetails = json['contentDetails'] ?? {};
    final durationString = contentDetails['duration'] ?? 'PT0S';
    
    // ISO 8601形式の期間文字列をDurationに変換
    final duration = _parseDuration(durationString);
    
    // 公開日時の解析
    DateTime publishedAt;
    try {
      publishedAt = DateTime.parse(snippet['publishedAt'] ?? '');
    } catch (e) {
      publishedAt = DateTime.now();
    }

    return YouTubeVideo(
      id: json['id'] is String ? json['id'] : json['id']?['videoId'] ?? '',
      title: snippet['title'] ?? '',
      channelId: snippet['channelId'] ?? '',
      channelTitle: snippet['channelTitle'] ?? '',
      thumbnailUrl: thumbnailUrl,
      description: snippet['description'] ?? '',
      publishedAt: publishedAt,
      viewCount: viewCount,
      likeCount: likeCount,
      duration: duration,
    );
  }

  /// ISO 8601形式の期間文字列をDurationに変換するヘルパーメソッド
  static Duration _parseDuration(String iso8601Duration) {
    // PT1H2M3S形式の文字列をパース
    final hours = RegExp(r'(\d+)H').firstMatch(iso8601Duration)?.group(1);
    final minutes = RegExp(r'(\d+)M').firstMatch(iso8601Duration)?.group(1);
    final seconds = RegExp(r'(\d+)S').firstMatch(iso8601Duration)?.group(1);
    
    return Duration(
      hours: hours != null ? int.parse(hours) : 0,
      minutes: minutes != null ? int.parse(minutes) : 0,
      seconds: seconds != null ? int.parse(seconds) : 0,
    );
  }

  /// オブジェクトをJSON形式に変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'channelId': channelId,
      'channelTitle': channelTitle,
      'thumbnailUrl': thumbnailUrl,
      'description': description,
      'publishedAt': publishedAt.toIso8601String(),
      'viewCount': viewCount,
      'likeCount': likeCount,
      'duration': duration.inSeconds,
    };
  }
}
