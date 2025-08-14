import "package:starlist_app/src/features/youtube/models/youtube_video.dart";

abstract class YouTubeService {
  Future<List<YouTubeVideo>> searchVideos(String query, {int maxResults = 10});
  Future<YouTubeVideo> getVideoDetails(String videoId);
  Future<List<YouTubeVideo>> getChannelVideos(String channelId, {int maxResults = 10});
  Future<List<YouTubeVideo>> getRelatedVideos(String videoId, {int maxResults = 10});
  Future<List<YouTubeVideo>> getPopularVideos({int maxResults = 10});
  Future<void> handleWebhook(String payload);
}

class YouTubeServiceImpl implements YouTubeService {
  @override
  Future<List<YouTubeVideo>> searchVideos(String query, {int maxResults = 10}) async {
    // TODO: Implement video search
    throw UnimplementedError();
  }

  @override
  Future<YouTubeVideo> getVideoDetails(String videoId) async {
    // TODO: Implement video details retrieval
    throw UnimplementedError();
  }

  @override
  Future<List<YouTubeVideo>> getChannelVideos(String channelId, {int maxResults = 10}) async {
    // TODO: Implement channel videos retrieval
    throw UnimplementedError();
  }

  @override
  Future<List<YouTubeVideo>> getRelatedVideos(String videoId, {int maxResults = 10}) async {
    // TODO: Implement related videos retrieval
    throw UnimplementedError();
  }

  @override
  Future<List<YouTubeVideo>> getPopularVideos({int maxResults = 10}) async {
    // TODO: Implement popular videos retrieval
    throw UnimplementedError();
  }

  @override
  Future<void> handleWebhook(String payload) async {
    // TODO: Implement webhook handling
    throw UnimplementedError();
  }
}
