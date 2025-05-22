import 'package:dio/dio.dart';
import '../models/youtube_video.dart';

/// YouTubeのAPI通信を担当するサービスクラス
class YouTubeApiService {
  final String apiKey;
  final Dio dio;
  final String baseUrl = 'https://www.googleapis.com/youtube/v3';

  YouTubeApiService({
    required this.apiKey,
    Dio? dio,
  }) : this.dio = dio ?? Dio();

  /// キーワードに基づいて動画を検索
  Future<List<YouTubeVideo>> searchVideos(String query) async {
    try {
      final response = await dio.get(
        '$baseUrl/search',
        queryParameters: {
          'part': 'snippet',
          'q': query,
          'type': 'video',
          'maxResults': 20,
          'key': apiKey,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> items = data['items'];
        
        // 検索結果から動画IDを抽出
        final List<String> videoIds = items
            .map<String>((item) => item['id']['videoId'] as String)
            .toList();
        
        // 動画IDを使って詳細情報を取得
        return await getVideoDetails(videoIds);
      } else {
        throw Exception('Failed to search videos: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Search API error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// チャンネルIDに基づいてチャンネルの動画を取得
  Future<List<YouTubeVideo>> getChannelVideos(String channelId) async {
    try {
      final response = await dio.get(
        '$baseUrl/search',
        queryParameters: {
          'part': 'snippet',
          'channelId': channelId,
          'type': 'video',
          'order': 'date',
          'maxResults': 20,
          'key': apiKey,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> items = data['items'];
        
        // チャンネル動画から動画IDを抽出
        final List<String> videoIds = items
            .map<String>((item) => item['id']['videoId'] as String)
            .toList();
        
        // 動画IDを使って詳細情報を取得
        return await getVideoDetails(videoIds);
      } else {
        throw Exception('Failed to get channel videos: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Channel API error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// 関連動画を取得
  Future<List<YouTubeVideo>> getRelatedVideos(String videoId) async {
    try {
      final response = await dio.get(
        '$baseUrl/search',
        queryParameters: {
          'part': 'snippet',
          'relatedToVideoId': videoId,
          'type': 'video',
          'maxResults': 20,
          'key': apiKey,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> items = data['items'];
        
        // 関連動画から動画IDを抽出
        final List<String> videoIds = items
            .map<String>((item) => item['id']['videoId'] as String)
            .toList();
        
        // 動画IDを使って詳細情報を取得
        return await getVideoDetails(videoIds);
      } else {
        throw Exception('Failed to get related videos: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Related videos API error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// 人気動画を取得
  Future<List<YouTubeVideo>> getPopularVideos() async {
    try {
      final response = await dio.get(
        '$baseUrl/videos',
        queryParameters: {
          'part': 'snippet,contentDetails,statistics',
          'chart': 'mostPopular',
          'regionCode': 'JP',
          'maxResults': 20,
          'key': apiKey,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> items = data['items'];
        
        return _parseVideos(items);
      } else {
        throw Exception('Failed to get popular videos: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Popular videos API error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// 単一の動画詳細情報を取得
  Future<YouTubeVideo?> getVideoDetail(String videoId) async {
    try {
      final response = await dio.get(
        '$baseUrl/videos',
        queryParameters: {
          'part': 'snippet,contentDetails,statistics',
          'id': videoId,
          'key': apiKey,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> items = data['items'];
        
        if (items.isNotEmpty) {
          return _parseVideoItem(items.first);
        } else {
          return null;
        }
      } else {
        throw Exception('Failed to get video details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Video details API error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// 複数の動画IDから詳細情報を取得
  Future<List<YouTubeVideo>> getVideoDetails(List<String> videoIds) async {
    if (videoIds.isEmpty) return [];
    
    try {
      final response = await dio.get(
        '$baseUrl/videos',
        queryParameters: {
          'part': 'snippet,contentDetails,statistics',
          'id': videoIds.join(','),
          'key': apiKey,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> items = data['items'];
        
        return _parseVideos(items);
      } else {
        throw Exception('Failed to get videos details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Videos details API error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// 動画アイテムのリストをパース
  List<YouTubeVideo> _parseVideos(List<dynamic> items) {
    return items.map((item) => _parseVideoItem(item)).toList();
  }

  /// 単一の動画アイテムをパース
  YouTubeVideo _parseVideoItem(Map<String, dynamic> item) {
    final snippet = item['snippet'];
    final contentDetails = item['contentDetails'];
    final statistics = item['statistics'];
    
    // ISO 8601 形式の期間を解析 (PT1H2M3S)
    final durationStr = contentDetails['duration'] as String? ?? 'PT0S';
    final duration = _parseDuration(durationStr);
    
    return YouTubeVideo(
      id: item['id'],
      title: snippet['title'] ?? '',
      description: snippet['description'] ?? '',
      thumbnailUrl: snippet['thumbnails']['high']['url'] ?? '',
      publishedAt: DateTime.parse(snippet['publishedAt']),
      channelId: snippet['channelId'] ?? '',
      channelTitle: snippet['channelTitle'] ?? '',
      viewCount: int.tryParse(statistics['viewCount'] ?? '0') ?? 0,
      likeCount: int.tryParse(statistics['likeCount'] ?? '0') ?? 0,
      commentCount: int.tryParse(statistics['commentCount'] ?? '0') ?? 0,
      duration: duration,
    );
  }

  /// ISO 8601 形式の期間を解析
  Duration _parseDuration(String iso8601Duration) {
    final regex = RegExp(
      r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?',
      caseSensitive: false,
    );
    final match = regex.firstMatch(iso8601Duration);
    
    if (match != null) {
      final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
      final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
      final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;
      
      return Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
      );
    }
    
    return Duration.zero;
  }
} 