import '../models/youtube_video.dart';
import '../services/youtube_api_service.dart';

/// YouTubeデータにアクセスするためのリポジトリクラス
class YouTubeRepository {
  final YouTubeApiService _apiService;

  /// コンストラクタ
  YouTubeRepository({required YouTubeApiService apiService}) 
      : _apiService = apiService;

  /// 動画を検索する
  /// [query] 検索クエリ
  /// [maxResults] 取得する最大結果数
  Future<List<YouTubeVideo>> searchVideos(String query, {int maxResults = 10}) async {
    return await _apiService.searchVideos(query, maxResults: maxResults);
  }

  /// 指定された動画IDの詳細情報を取得する
  /// [videoIds] 動画IDのリスト
  Future<List<YouTubeVideo>> getVideoDetails(List<String> videoIds) async {
    return await _apiService.getVideoDetails(videoIds);
  }

  /// チャンネルの最新動画を取得する
  /// [channelId] YouTubeチャンネルID
  /// [maxResults] 取得する最大結果数
  Future<List<YouTubeVideo>> getChannelVideos(String channelId, {int maxResults = 10}) async {
    return await _apiService.getChannelVideos(channelId, maxResults: maxResults);
  }

  /// ユーザーの視聴履歴を取得する（認証が必要）
  Future<List<YouTubeVideo>> getWatchHistory() async {
    return await _apiService.getWatchHistory();
  }

  /// API制限なしで動画情報を取得する
  /// [videoId] 動画ID
  Future<YouTubeVideo?> getVideoInfoWithoutApiKey(String videoId) async {
    return await _apiService.getVideoInfoWithoutApiKey(videoId);
  }
}
