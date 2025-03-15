import '../services/youtube_api_service.dart';
import '../services/spotify_api_service.dart';
import '../services/netflix_api_service.dart';
import '../services/linkedin_api_service.dart';
import '../services/twitter_api_service.dart';
import '../services/instagram_api_service.dart';
import '../../../../src/core/errors/app_exceptions.dart';

/// データ統合サービスの共通インターフェース
/// 各種APIサービスを統合し、一貫したインターフェースを提供する
class DataIntegrationService {
  final YouTubeApiService _youtubeApiService;
  final SpotifyApiService _spotifyApiService;
  final NetflixApiService _netflixApiService;
  final LinkedInApiService _linkedInApiService;
  final TwitterApiService _twitterApiService;
  final InstagramApiService _instagramApiService;

  DataIntegrationService({
    required YouTubeApiService youtubeApiService,
    required SpotifyApiService spotifyApiService,
    required NetflixApiService netflixApiService,
    required LinkedInApiService linkedInApiService,
    required TwitterApiService twitterApiService,
    required InstagramApiService instagramApiService,
  }) : _youtubeApiService = youtubeApiService,
       _spotifyApiService = spotifyApiService,
       _netflixApiService = netflixApiService,
       _linkedInApiService = linkedInApiService,
       _twitterApiService = twitterApiService,
       _instagramApiService = instagramApiService;

  /// YouTubeのデータを取得する
  Future<Map<String, dynamic>> getYouTubeData({
    required String accessToken,
    bool includeSubscriptions = true,
    bool includeWatchHistory = true,
  }) async {
    try {
      final result = <String, dynamic>{};

      if (includeSubscriptions) {
        final subscriptions = await _youtubeApiService.getSubscriptions(
          accessToken: accessToken,
        );
        result['subscriptions'] = subscriptions;
      }

      if (includeWatchHistory) {
        final watchHistory = await _youtubeApiService.getWatchHistory(
          accessToken: accessToken,
        );
        result['watch_history'] = watchHistory;
      }

      return result;
    } catch (e) {
      throw _handleIntegrationError('YouTube', e);
    }
  }

  /// Spotifyのデータを取得する
  Future<Map<String, dynamic>> getSpotifyData({
    required String accessToken,
    bool includeRecentlyPlayed = true,
    bool includeTopArtists = true,
    bool includeTopTracks = true,
    bool includePlaylists = true,
  }) async {
    try {
      final result = <String, dynamic>{};

      final profile = await _spotifyApiService.getUserProfile(
        accessToken: accessToken,
      );
      result['profile'] = profile;

      if (includeRecentlyPlayed) {
        final recentlyPlayed = await _spotifyApiService.getRecentlyPlayed(
          accessToken: accessToken,
        );
        result['recently_played'] = recentlyPlayed;
      }

      if (includeTopArtists) {
        final topArtists = await _spotifyApiService.getTopArtists(
          accessToken: accessToken,
        );
        result['top_artists'] = topArtists;
      }

      if (includeTopTracks) {
        final topTracks = await _spotifyApiService.getTopTracks(
          accessToken: accessToken,
        );
        result['top_tracks'] = topTracks;
      }

      if (includePlaylists) {
        final playlists = await _spotifyApiService.getUserPlaylists(
          accessToken: accessToken,
        );
        result['playlists'] = playlists;
      }

      return result;
    } catch (e) {
      throw _handleIntegrationError('Spotify', e);
    }
  }

  /// Netflixのデータを取得する
  Future<Map<String, dynamic>> getNetflixData({
    required String accessToken,
    bool includeViewingHistory = true,
    bool includeUserLists = true,
  }) async {
    try {
      final result = <String, dynamic>{};

      final profile = await _netflixApiService.getUserProfile(
        accessToken: accessToken,
      );
      result['profile'] = profile;

      if (includeViewingHistory) {
        final viewingHistory = await _netflixApiService.getViewingHistory(
          accessToken: accessToken,
        );
        result['viewing_history'] = viewingHistory;
      }

      if (includeUserLists) {
        final userLists = await _netflixApiService.getUserLists(
          accessToken: accessToken,
        );
        result['user_lists'] = userLists;
      }

      return result;
    } catch (e) {
      throw _handleIntegrationError('Netflix', e);
    }
  }

  /// LinkedInのデータを取得する
  Future<Map<String, dynamic>> getLinkedInData({
    required String username,
  }) async {
    try {
      final result = <String, dynamic>{};

      final profile = await _linkedInApiService.getUserProfile(
        username: username,
      );
      result['profile'] = profile;

      return result;
    } catch (e) {
      throw _handleIntegrationError('LinkedIn', e);
    }
  }

  /// Twitterのデータを取得する
  Future<Map<String, dynamic>> getTwitterData({
    required String username,
    required String userId,
    bool includeTweets = true,
    bool includeFollowers = true,
    bool includeFollowing = true,
  }) async {
    try {
      final result = <String, dynamic>{};

      final userInfo = await _twitterApiService.getUserInfo(
        username: username,
      );
      result['user_info'] = userInfo;

      if (includeTweets) {
        final tweets = await _twitterApiService.getUserTweets(
          userId: userId,
        );
        result['tweets'] = tweets;
      }

      if (includeFollowers) {
        final followers = await _twitterApiService.getUserFollowers(
          userId: userId,
        );
        result['followers'] = followers;
      }

      if (includeFollowing) {
        final following = await _twitterApiService.getUserFollowing(
          userId: userId,
        );
        result['following'] = following;
      }

      return result;
    } catch (e) {
      throw _handleIntegrationError('Twitter', e);
    }
  }

  /// Instagramのデータを取得する
  Future<Map<String, dynamic>> getInstagramData({
    bool includeMedia = true,
  }) async {
    try {
      final result = <String, dynamic>{};

      final profile = await _instagramApiService.getUserProfile();
      result['profile'] = profile;

      if (includeMedia) {
        final media = await _instagramApiService.getUserMedia();
        result['media'] = media;
      }

      return result;
    } catch (e) {
      throw _handleIntegrationError('Instagram', e);
    }
  }

  /// 全てのプラットフォームからユーザーのコンテンツ消費データを取得する
  Future<Map<String, dynamic>> getAllContentConsumptionData({
    String? youtubeAccessToken,
    String? spotifyAccessToken,
    String? netflixAccessToken,
    String? linkedInUsername,
    String? twitterUsername,
    String? twitterUserId,
    String? instagramAccessToken,
  }) async {
    final result = <String, dynamic>{};

    try {
      if (youtubeAccessToken != null) {
        result['youtube'] = await getYouTubeData(
          accessToken: youtubeAccessToken,
        );
      }

      if (spotifyAccessToken != null) {
        result['spotify'] = await getSpotifyData(
          accessToken: spotifyAccessToken,
        );
      }

      if (netflixAccessToken != null) {
        result['netflix'] = await getNetflixData(
          accessToken: netflixAccessToken,
        );
      }

      if (linkedInUsername != null) {
        result['linkedin'] = await getLinkedInData(
          username: linkedInUsername,
        );
      }

      if (twitterUsername != null && twitterUserId != null) {
        result['twitter'] = await getTwitterData(
          username: twitterUsername,
          userId: twitterUserId,
        );
      }

      if (instagramAccessToken != null) {
        _instagramApiService = InstagramApiService(
          accessToken: instagramAccessToken,
        );
        result['instagram'] = await getInstagramData();
      }

      return result;
    } catch (e) {
      throw _handleIntegrationError('All Platforms', e);
    }
  }

  /// 統合エラーを処理する
  Exception _handleIntegrationError(String platform, dynamic error) {
    if (error is AppException) {
      return error;
    } else {
      return ApiException(
        message: '$platform integration error: ${error.toString()}',
        details: error.toString(),
      );
    }
  }
}
