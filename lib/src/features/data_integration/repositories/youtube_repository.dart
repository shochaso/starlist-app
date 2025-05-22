import '../models/youtube_video.dart';
import '../services/youtube_api_service.dart';

/// YouTubeのデータ取得と管理を担当するリポジトリクラス
class YouTubeRepository {
  final YouTubeApiService apiService;

  YouTubeRepository({required this.apiService});

  /// キーワードに基づいて動画を検索
  Future<List<YouTubeVideo>> searchVideos(String query) async {
    try {
      return await apiService.searchVideos(query);
    } catch (e) {
      print('Video search error: $e');
      return [];
    }
  }

  /// チャンネルIDに基づいてチャンネルの動画を取得
  Future<List<YouTubeVideo>> getChannelVideos(String channelId) async {
    try {
      return await apiService.getChannelVideos(channelId);
    } catch (e) {
      print('Channel videos error: $e');
      return [];
    }
  }

  /// 関連動画を取得
  Future<List<YouTubeVideo>> getRelatedVideos(String videoId) async {
    try {
      return await apiService.getRelatedVideos(videoId);
    } catch (e) {
      print('Related videos error: $e');
      return [];
    }
  }

  /// 人気動画を取得
  Future<List<YouTubeVideo>> getPopularVideos() async {
    try {
      return await apiService.getPopularVideos();
    } catch (e) {
      print('Popular videos error: $e');
      return [];
    }
  }

  /// 動画の詳細情報を取得
  Future<YouTubeVideo?> getVideoDetails(String videoId) async {
    try {
      return await apiService.getVideoDetail(videoId);
    } catch (e) {
      print('Video details error: $e');
      return null;
    }
  }
} 