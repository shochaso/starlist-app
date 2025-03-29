import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/youtube_video.dart';

/// YouTubeのAPI通信を担当するサービスクラス
class YouTubeApiService {
  final String apiKey;
  final String baseUrl = 'https://www.googleapis.com/youtube/v3';

  YouTubeApiService({required this.apiKey});

  /// キーワードに基づいて動画を検索
  Future<List<YouTubeVideo>> searchVideos(String query) async {
    final url = '$baseUrl/search?part=snippet&q=$query&type=video&maxResults=20&key=$apiKey';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        
        // 検索結果から動画IDを抽出
        final List<String> videoIds = items
            .map<String>((item) => item['id']['videoId'] as String)
            .toList();
        
        // 動画IDを使って詳細情報を取得
        return await _getVideosDetails(videoIds);
      } else {
        throw Exception('Failed to search videos: ${response.statusCode}');
      }
    } catch (e) {
      print('Search API error: $e');
      return [];
    }
  }

  /// チャンネルIDに基づいてチャンネルの動画を取得
  Future<List<YouTubeVideo>> getChannelVideos(String channelId) async {
    final url = '$baseUrl/search?part=snippet&channelId=$channelId&type=video&order=date&maxResults=20&key=$apiKey';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        
        // チャンネル動画から動画IDを抽出
        final List<String> videoIds = items
            .map<String>((item) => item['id']['videoId'] as String)
            .toList();
        
        // 動画IDを使って詳細情報を取得
        return await _getVideosDetails(videoIds);
      } else {
        throw Exception('Failed to get channel videos: ${response.statusCode}');
      }
    } catch (e) {
      print('Channel API error: $e');
      return [];
    }
  }

  /// 関連動画を取得
  Future<List<YouTubeVideo>> getRelatedVideos(String videoId) async {
    final url = '$baseUrl/search?part=snippet&relatedToVideoId=$videoId&type=video&maxResults=20&key=$apiKey';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        
        // 関連動画から動画IDを抽出
        final List<String> videoIds = items
            .map<String>((item) => item['id']['videoId'] as String)
            .toList();
        
        // 動画IDを使って詳細情報を取得
        return await _getVideosDetails(videoIds);
      } else {
        throw Exception('Failed to get related videos: ${response.statusCode}');
      }
    } catch (e) {
      print('Related videos API error: $e');
      return [];
    }
  }

  /// 人気動画を取得
  Future<List<YouTubeVideo>> getPopularVideos() async {
    final url = '$baseUrl/videos?part=snippet,contentDetails,statistics&chart=mostPopular&regionCode=JP&maxResults=20&key=$apiKey';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        
        return _parseVideos(items);
      } else {
        throw Exception('Failed to get popular videos: ${response.statusCode}');
      }
    } catch (e) {
      print('Popular videos API error: $e');
      return [];
    }
  }

  /// 動画の詳細情報を取得
  Future<YouTubeVideo?> getVideoDetails(String videoId) async {
    final url = '$baseUrl/videos?part=snippet,contentDetails,statistics&id=$videoId&key=$apiKey';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        
        if (items.isNotEmpty) {
          return _parseVideoItem(items.first);
        } else {
          return null;
        }
      } else {
        throw Exception('Failed to get video details: ${response.statusCode}');
      }
    } catch (e) {
      print('Video details API error: $e');
      return null;
    }
  }

  /// 複数の動画IDから詳細情報を取得
  Future<List<YouTubeVideo>> _getVideosDetails(List<String> videoIds) async {
    if (videoIds.isEmpty) return [];
    
    final joinedIds = videoIds.join(',');
    final url = '$baseUrl/videos?part=snippet,contentDetails,statistics&id=$joinedIds&key=$apiKey';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        
        return _parseVideos(items);
      } else {
        throw Exception('Failed to get videos details: ${response.statusCode}');
      }
    } catch (e) {
      print('Videos details API error: $e');
      return [];
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