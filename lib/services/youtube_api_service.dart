import 'dart:convert';
import 'package:http/http.dart' as http;

class YouTubeApiService {
  final String _apiKey;
  final _baseUrl = 'https://www.googleapis.com/youtube/v3';
  final _httpClient = http.Client();

  YouTubeApiService(this._apiKey);

  // 動画詳細情報の取得
  Future<Map<String, dynamic>?> getVideoDetails(String videoId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/videos?part=snippet,contentDetails,statistics&id=$videoId&key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          return data['items'][0];
        }
      }
      return null;
    } catch (e) {
      print('YouTube API エラー: $e');
      return null;
    }
  }

  // カテゴリ別の人気動画を取得
  Future<List<Map<String, dynamic>>> getPopularVideosByCategory(String categoryId, {int maxResults = 10}) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/videos?part=snippet,contentDetails,statistics&chart=mostPopular&videoCategoryId=$categoryId&maxResults=$maxResults&key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['items'] ?? []);
      }
      return [];
    } catch (e) {
      print('YouTube API エラー: $e');
      return [];
    }
  }

  // 動画検索
  Future<List<Map<String, dynamic>>> searchVideos(String query, {int maxResults = 10}) async {
    // 実装を追加
  }
} 