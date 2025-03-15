import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:starlist/src/features/data_integration/services/data_integration_service.dart';
import 'package:starlist/src/features/data_integration/services/youtube_api_service.dart';
import 'package:starlist/src/features/data_integration/services/spotify_api_service.dart';
import 'package:starlist/src/features/data_integration/services/netflix_api_service.dart';
import 'package:starlist/src/features/data_integration/services/linkedin_api_service.dart';
import 'package:starlist/src/features/data_integration/services/twitter_api_service.dart';
import 'package:starlist/src/features/data_integration/services/instagram_api_service.dart';

@GenerateMocks([
  YouTubeApiService,
  SpotifyApiService,
  NetflixApiService,
  LinkedInApiService,
  TwitterApiService,
  InstagramApiService,
])
void main() {
  late MockYouTubeApiService mockYouTubeApiService;
  late MockSpotifyApiService mockSpotifyApiService;
  late MockNetflixApiService mockNetflixApiService;
  late MockLinkedInApiService mockLinkedInApiService;
  late MockTwitterApiService mockTwitterApiService;
  late MockInstagramApiService mockInstagramApiService;
  late DataIntegrationService dataIntegrationService;

  setUp(() {
    mockYouTubeApiService = MockYouTubeApiService();
    mockSpotifyApiService = MockSpotifyApiService();
    mockNetflixApiService = MockNetflixApiService();
    mockLinkedInApiService = MockLinkedInApiService();
    mockTwitterApiService = MockTwitterApiService();
    mockInstagramApiService = MockInstagramApiService();
    
    dataIntegrationService = DataIntegrationService(
      youtubeApiService: mockYouTubeApiService,
      spotifyApiService: mockSpotifyApiService,
      netflixApiService: mockNetflixApiService,
      linkedInApiService: mockLinkedInApiService,
      twitterApiService: mockTwitterApiService,
      instagramApiService: mockInstagramApiService,
    );
  });

  group('DataIntegrationService', () {
    test('getYouTubeData should return combined data from YouTube API', () async {
      // Arrange
      final subscriptionsData = {'items': []};
      final watchHistoryData = {'items': []};
      
      when(mockYouTubeApiService.getSubscriptions(accessToken: 'test_token'))
          .thenAnswer((_) async => subscriptionsData);
      when(mockYouTubeApiService.getWatchHistory(accessToken: 'test_token'))
          .thenAnswer((_) async => watchHistoryData);
      
      // Act
      final result = await dataIntegrationService.getYouTubeData(
        accessToken: 'test_token',
      );
      
      // Assert
      expect(result, {
        'subscriptions': subscriptionsData,
        'watch_history': watchHistoryData,
      });
      verify(mockYouTubeApiService.getSubscriptions(accessToken: 'test_token')).called(1);
      verify(mockYouTubeApiService.getWatchHistory(accessToken: 'test_token')).called(1);
    });

    test('getSpotifyData should return combined data from Spotify API', () async {
      // Arrange
      final profileData = {'id': 'user123'};
      final recentlyPlayedData = {'items': []};
      final topArtistsData = {'items': []};
      final topTracksData = {'items': []};
      final playlistsData = {'items': []};
      
      when(mockSpotifyApiService.getUserProfile(accessToken: 'test_token'))
          .thenAnswer((_) async => profileData);
      when(mockSpotifyApiService.getRecentlyPlayed(accessToken: 'test_token'))
          .thenAnswer((_) async => recentlyPlayedData);
      when(mockSpotifyApiService.getTopArtists(accessToken: 'test_token'))
          .thenAnswer((_) async => topArtistsData);
      when(mockSpotifyApiService.getTopTracks(accessToken: 'test_token'))
          .thenAnswer((_) async => topTracksData);
      when(mockSpotifyApiService.getUserPlaylists(accessToken: 'test_token'))
          .thenAnswer((_) async => playlistsData);
      
      // Act
      final result = await dataIntegrationService.getSpotifyData(
        accessToken: 'test_token',
      );
      
      // Assert
      expect(result, {
        'profile': profileData,
        'recently_played': recentlyPlayedData,
        'top_artists': topArtistsData,
        'top_tracks': topTracksData,
        'playlists': playlistsData,
      });
      verify(mockSpotifyApiService.getUserProfile(accessToken: 'test_token')).called(1);
      verify(mockSpotifyApiService.getRecentlyPlayed(accessToken: 'test_token')).called(1);
      verify(mockSpotifyApiService.getTopArtists(accessToken: 'test_token')).called(1);
      verify(mockSpotifyApiService.getTopTracks(accessToken: 'test_token')).called(1);
      verify(mockSpotifyApiService.getUserPlaylists(accessToken: 'test_token')).called(1);
    });

    test('getLinkedInData should return profile data from LinkedIn API', () async {
      // Arrange
      final profileData = {'data': {'firstName': 'John', 'lastName': 'Doe'}};
      
      when(mockLinkedInApiService.getUserProfile(username: 'johndoe'))
          .thenAnswer((_) async => profileData);
      
      // Act
      final result = await dataIntegrationService.getLinkedInData(
        username: 'johndoe',
      );
      
      // Assert
      expect(result, {
        'profile': profileData,
      });
      verify(mockLinkedInApiService.getUserProfile(username: 'johndoe')).called(1);
    });

    test('getAllContentConsumptionData should return data from all platforms', () async {
      // Arrange
      when(mockYouTubeApiService.getSubscriptions(accessToken: 'youtube_token'))
          .thenAnswer((_) async => {'items': []});
      when(mockYouTubeApiService.getWatchHistory(accessToken: 'youtube_token'))
          .thenAnswer((_) async => {'items': []});
      
      when(mockSpotifyApiService.getUserProfile(accessToken: 'spotify_token'))
          .thenAnswer((_) async => {'id': 'user123'});
      when(mockSpotifyApiService.getRecentlyPlayed(accessToken: 'spotify_token'))
          .thenAnswer((_) async => {'items': []});
      when(mockSpotifyApiService.getTopArtists(accessToken: 'spotify_token'))
          .thenAnswer((_) async => {'items': []});
      when(mockSpotifyApiService.getTopTracks(accessToken: 'spotify_token'))
          .thenAnswer((_) async => {'items': []});
      when(mockSpotifyApiService.getUserPlaylists(accessToken: 'spotify_token'))
          .thenAnswer((_) async => {'items': []});
      
      when(mockNetflixApiService.getUserProfile(accessToken: 'netflix_token'))
          .thenAnswer((_) async => {'profile': 'user123'});
      when(mockNetflixApiService.getViewingHistory(accessToken: 'netflix_token'))
          .thenAnswer((_) async => {'viewingHistory': []});
      when(mockNetflixApiService.getUserLists(accessToken: 'netflix_token'))
          .thenAnswer((_) async => {'lists': []});
      
      when(mockLinkedInApiService.getUserProfile(username: 'johndoe'))
          .thenAnswer((_) async => {'data': {'firstName': 'John'}});
      
      when(mockTwitterApiService.getUserInfo(username: 'johndoe'))
          .thenAnswer((_) async => {'data': {'username': 'johndoe'}});
      when(mockTwitterApiService.getUserTweets(userId: 'user123'))
          .thenAnswer((_) async => {'data': {'tweets': []}});
      when(mockTwitterApiService.getUserFollowers(userId: 'user123'))
          .thenAnswer((_) async => {'data': {'followers': []}});
      when(mockTwitterApiService.getUserFollowing(userId: 'user123'))
          .thenAnswer((_) async => {'data': {'following': []}});
      
      when(mockInstagramApiService.getUserProfile())
          .thenAnswer((_) async => {'data': {'username': 'johndoe'}});
      when(mockInstagramApiService.getUserMedia())
          .thenAnswer((_) async => {'data': {'media': []}});
      
      // Act
      final result = await dataIntegrationService.getAllContentConsumptionData(
        youtubeAccessToken: 'youtube_token',
        spotifyAccessToken: 'spotify_token',
        netflixAccessToken: 'netflix_token',
        linkedInUsername: 'johndoe',
        twitterUsername: 'johndoe',
        twitterUserId: 'user123',
      );
      
      // Assert
      expect(result.containsKey('youtube'), true);
      expect(result.containsKey('spotify'), true);
      expect(result.containsKey('netflix'), true);
      expect(result.containsKey('linkedin'), true);
      expect(result.containsKey('twitter'), true);
    });
  });
}
