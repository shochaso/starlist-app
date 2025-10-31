@Skip('legacy youtube provider tests; pending migration')
import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:starlist_app/src/features/youtube/models/youtube_video.dart";
import "package:starlist_app/src/features/youtube/providers/youtube_provider.dart";
import "package:starlist_app/src/features/youtube/services/youtube_service.dart";

class MockYouTubeService extends Mock implements YouTubeService {}

void main() {
  late YouTubeProvider provider;
  late MockYouTubeService mockService;

  setUp(() {
    mockService = MockYouTubeService();
    provider = YouTubeProvider(mockService);
  });

  test("initial state", () {
    expect(provider.searchResults, isEmpty);
    expect(provider.currentVideo, null);
    expect(provider.channelVideos, isEmpty);
    expect(provider.relatedVideos, isEmpty);
    expect(provider.popularVideos, isEmpty);
    expect(provider.isLoading, false);
    expect(provider.error, null);
  });

  test("search videos", () async {
    final videos = [
      YouTubeVideo(
        id: "video-1",
        title: "Video 1",
        description: "Description 1",
        thumbnailUrl: "https://example.com/thumb1.jpg",
        publishedAt: DateTime.now(),
        channelId: "channel-1",
        channelTitle: "Channel 1",
        viewCount: 1000,
        likeCount: 100,
        commentCount: 50,
        duration: const Duration(minutes: 5),
      ),
      YouTubeVideo(
        id: "video-2",
        title: "Video 2",
        description: "Description 2",
        thumbnailUrl: "https://example.com/thumb2.jpg",
        publishedAt: DateTime.now(),
        channelId: "channel-2",
        channelTitle: "Channel 2",
        viewCount: 2000,
        likeCount: 200,
        commentCount: 100,
        duration: const Duration(minutes: 10),
      ),
    ];

    when(mockService.searchVideos("test")).thenAnswer((_) async => videos);

    await provider.searchVideos("test");

    expect(provider.searchResults.length, 2);
    expect(provider.isLoading, false);
    expect(provider.error, null);
  });

  test("load video details", () async {
    final video = YouTubeVideo(
      id: "video-1",
      title: "Video 1",
      description: "Description 1",
      thumbnailUrl: "https://example.com/thumb1.jpg",
      publishedAt: DateTime.now(),
      channelId: "channel-1",
      channelTitle: "Channel 1",
      viewCount: 1000,
      likeCount: 100,
      commentCount: 50,
      duration: const Duration(minutes: 5),
    );

    when(mockService.getVideoDetails("video-1")).thenAnswer((_) async => video);

    await provider.loadVideoDetails("video-1");

    expect(provider.currentVideo, video);
    expect(provider.isLoading, false);
    expect(provider.error, null);
  });

  test("load channel videos", () async {
    final videos = [
      YouTubeVideo(
        id: "video-1",
        title: "Video 1",
        description: "Description 1",
        thumbnailUrl: "https://example.com/thumb1.jpg",
        publishedAt: DateTime.now(),
        channelId: "channel-1",
        channelTitle: "Channel 1",
        viewCount: 1000,
        likeCount: 100,
        commentCount: 50,
        duration: const Duration(minutes: 5),
      ),
      YouTubeVideo(
        id: "video-2",
        title: "Video 2",
        description: "Description 2",
        thumbnailUrl: "https://example.com/thumb2.jpg",
        publishedAt: DateTime.now(),
        channelId: "channel-1",
        channelTitle: "Channel 1",
        viewCount: 2000,
        likeCount: 200,
        commentCount: 100,
        duration: const Duration(minutes: 10),
      ),
    ];

    when(mockService.getChannelVideos("channel-1")).thenAnswer((_) async => videos);

    await provider.loadChannelVideos("channel-1");

    expect(provider.channelVideos.length, 2);
    expect(provider.isLoading, false);
    expect(provider.error, null);
  });

  test("load related videos", () async {
    final videos = [
      YouTubeVideo(
        id: "video-2",
        title: "Video 2",
        description: "Description 2",
        thumbnailUrl: "https://example.com/thumb2.jpg",
        publishedAt: DateTime.now(),
        channelId: "channel-2",
        channelTitle: "Channel 2",
        viewCount: 2000,
        likeCount: 200,
        commentCount: 100,
        duration: const Duration(minutes: 10),
      ),
      YouTubeVideo(
        id: "video-3",
        title: "Video 3",
        description: "Description 3",
        thumbnailUrl: "https://example.com/thumb3.jpg",
        publishedAt: DateTime.now(),
        channelId: "channel-3",
        channelTitle: "Channel 3",
        viewCount: 3000,
        likeCount: 300,
        commentCount: 150,
        duration: const Duration(minutes: 15),
      ),
    ];

    when(mockService.getRelatedVideos("video-1")).thenAnswer((_) async => videos);

    await provider.loadRelatedVideos("video-1");

    expect(provider.relatedVideos.length, 2);
    expect(provider.isLoading, false);
    expect(provider.error, null);
  });

  test("load popular videos", () async {
    final videos = [
      YouTubeVideo(
        id: "video-1",
        title: "Video 1",
        description: "Description 1",
        thumbnailUrl: "https://example.com/thumb1.jpg",
        publishedAt: DateTime.now(),
        channelId: "channel-1",
        channelTitle: "Channel 1",
        viewCount: 1000,
        likeCount: 100,
        commentCount: 50,
        duration: const Duration(minutes: 5),
      ),
      YouTubeVideo(
        id: "video-2",
        title: "Video 2",
        description: "Description 2",
        thumbnailUrl: "https://example.com/thumb2.jpg",
        publishedAt: DateTime.now(),
        channelId: "channel-2",
        channelTitle: "Channel 2",
        viewCount: 2000,
        likeCount: 200,
        commentCount: 100,
        duration: const Duration(minutes: 10),
      ),
    ];

    when(mockService.getPopularVideos()).thenAnswer((_) async => videos);

    await provider.loadPopularVideos();

    expect(provider.popularVideos.length, 2);
    expect(provider.isLoading, false);
    expect(provider.error, null);
  });
}
