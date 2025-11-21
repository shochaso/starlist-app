import '../services/youtube_ocr_parser_v6.dart';
import '../../providers/youtube_history_provider.dart';

class YoutubeImportItem {
  YoutubeImportItem({
    required this.id,
    required this.title,
    required this.channel,
    this.duration,
    this.viewedAt,
    this.viewCount,
    this.confidence = 1.0,
    this.videoUrl,
    this.matchScore,
    this.matchReason,
    this.enrichError,
    this.selected = false,
    this.isPublic = false,
    this.isSaved = false,
    this.isLinkLoading = false,
    this.thumbnailUrl,
  });

  factory YoutubeImportItem.fromVideoData(VideoData data) {
    final id = _stableId(data.title, data.channel);
    return YoutubeImportItem(
      id: id,
      title: data.title,
      channel: data.channel,
      duration: data.duration,
      viewedAt: data.viewedAt,
      viewCount: data.viewCount,
      confidence: data.confidence,
    );
  }

  factory YoutubeImportItem.fromHistoryItem(YouTubeHistoryItem item) {
    final id = _stableId(item.title, item.channel);
    return YoutubeImportItem(
      id: id,
      title: item.title,
      channel: item.channel,
      duration: item.duration,
      viewedAt: item.uploadTime,
      viewCount: item.viewCount ?? item.views,
      confidence: 1.0,
      videoUrl: item.url,
      isPublic: item.isPublished,
      isSaved: true,
      thumbnailUrl: item.thumbnailUrl,
    );
  }

  static String _stableId(String title, String channel) =>
      '${title.trim()}|${channel.trim()}'.toLowerCase();

  final String id;
  final String title;
  final String channel;
  final String? duration;
  final String? viewedAt;
  final String? viewCount;
  final double confidence;
  final String? thumbnailUrl;

  bool selected;
  bool isPublic;
  bool isSaved;
  bool isLinkLoading;

  String? videoUrl;
  double? matchScore;
  String? matchReason;
  String? enrichError;

  YoutubeImportItem copyWith({
    String? id,
    String? title,
    String? channel,
    String? duration,
    String? viewedAt,
    String? viewCount,
    double? confidence,
    String? videoUrl,
    double? matchScore,
    String? matchReason,
    String? enrichError,
    bool? selected,
    bool? isPublic,
    bool? isSaved,
    bool? isLinkLoading,
    String? thumbnailUrl,
  }) {
    return YoutubeImportItem(
      id: id ?? this.id,
      title: title ?? this.title,
      channel: channel ?? this.channel,
      duration: duration ?? this.duration,
      viewedAt: viewedAt ?? this.viewedAt,
      viewCount: viewCount ?? this.viewCount,
      confidence: confidence ?? this.confidence,
      videoUrl: videoUrl ?? this.videoUrl,
      matchScore: matchScore ?? this.matchScore,
      matchReason: matchReason ?? this.matchReason,
      enrichError: enrichError ?? this.enrichError,
      selected: selected ?? this.selected,
      isPublic: isPublic ?? this.isPublic,
      isSaved: isSaved ?? this.isSaved,
      isLinkLoading: isLinkLoading ?? this.isLinkLoading,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'channel': channel,
      'duration': duration,
      'viewedAt': viewedAt,
      'viewCount': viewCount,
      'confidence': confidence,
      'selected': selected,
      'isPublic': isPublic,
      'isSaved': isSaved,
      'videoUrl': videoUrl,
      'matchScore': matchScore,
      'matchReason': matchReason,
      'enrichError': enrichError,
      'isLinkLoading': isLinkLoading,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  YouTubeHistoryItem toHistoryItem() {
    return YouTubeHistoryItem(
      title: title,
      channel: channel,
      duration: duration,
      uploadTime: viewedAt,
      viewCount: viewCount,
      views: viewCount,
      addedAt: DateTime.now(),
      url: videoUrl,
      thumbnailUrl: thumbnailUrl,
      isPublished: isPublic,
    );
  }
}
