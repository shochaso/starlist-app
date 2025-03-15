import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:starlist/src/core/network/api_client.dart';
import 'package:starlist/src/features/data_integration/services/data_integration_service.dart';
import 'package:starlist/src/features/data_integration/services/youtube_api_service.dart';
import 'package:starlist/src/features/data_integration/domain/data_integration_manager.dart';

// ApiClientのモック
class MockApiClient extends Mock implements ApiClient {}

// HTTPクライアントのモック
class MockHttpClient extends Mock implements http.Client {}

// YouTubeApiServiceのモック
class MockYouTubeApiService extends Mock implements YouTubeApiService {}

void main() {
  group('YouTubeApiService Tests', () {
    late MockApiClient mockApiClient;
    late YouTubeApiService youtubeService;

    setUp(() {
      mockApiClient = MockApiClient();
      youtubeService = YouTubeApiService(
        accessToken: 'test_token',
        apiClient: mockApiClient,
      );
    });

    test('isAuthenticated returns true when access token is set', () async {
      final result = await youtubeService.isAuthenticated();
      expect(result, true);
    });

    test('getUserProfile returns user profile data', () async {
      // モックレスポンスの設定
      when(mockApiClient.get(
        '/channels',
        headers: anyNamed('headers'),
        queryParams: anyNamed('queryParams'),
      )).thenAnswer((_) async => {
        'items': [
          {
            'id': 'channel123',
            'snippet': {
              'title': 'Test Channel',
              'description': 'Test Description',
              'thumbnails': {
                'default': {
                  'url': 'https://example.com/thumbnail.jpg',
                },
              },
            },
            'statistics': {
              'subscriberCount': '1000',
              'videoCount': '50',
              'viewCount': '10000',
            },
          },
        ],
      });

      final result = await youtubeService.getUserProfile();
      
      expect(result['id'], 'channel123');
      expect(result['title'], 'Test Channel');
      expect(result['subscriberCount'], '1000');
    });

    test('getContentConsumptionData returns watch history', () async {
      // 視聴履歴のモックレスポンス
      when(mockApiClient.get(
        '/activities',
        headers: anyNamed('headers'),
        queryParams: anyNamed('queryParams'),
      )).thenAnswer((_) async => {
        'items': [
          {
            'snippet': {
              'type': 'watch',
              'publishedAt': '2023-01-01T00:00:00Z',
            },
            'contentDetails': {
              'upload': {
                'videoId': 'video123',
              },
            },
          },
        ],
      });

      // 動画詳細のモックレスポンス
      when(mockApiClient.get(
        '/videos',
        headers: anyNamed('headers'),
        queryParams: anyNamed('queryParams'),
      )).thenAnswer((_) async => {
        'items': [
          {
            'snippet': {
              'title': 'Test Video',
              'description': 'Test Video Description',
              'channelTitle': 'Test Channel',
              'publishedAt': '2023-01-01T00:00:00Z',
              'thumbnails': {
                'medium': {
                  'url': 'https://example.com/thumbnail.jpg',
                },
              },
            },
            'statistics': {
              'viewCount': '5000',
              'likeCount': '100',
            },
            'contentDetails': {
              'duration': 'PT10M30S',
            },
          },
        ],
      });

      final result = await youtubeService.getContentConsumptionData();
      
      expect(result.length, 1);
      expect(result[0]['id'], 'video123');
      expect(result[0]['title'], 'Test Video');
      expect(result[0]['type'], 'video');
    });
  });

  group('DataIntegrationManager Tests', () {
    late DataIntegrationManager manager;
    late MockYouTubeApiService mockYoutubeService;

    setUp(() {
      mockYoutubeService = MockYouTubeApiService();
      manager = DataIntegrationManager();
      
      // YouTubeサービスを登録
      when(mockYoutubeService.serviceName).thenReturn('YouTube');
      manager.registerService(mockYoutubeService);
    });

    test('getUserProfile delegates to the correct service', () async {
      when(mockYoutubeService.getUserProfile()).thenAnswer((_) async => {
        'id': 'channel123',
        'title': 'Test Channel',
      });

      final result = await manager.getUserProfile('YouTube');
      
      verify(mockYoutubeService.getUserProfile()).called(1);
      expect(result['id'], 'channel123');
    });

    test('getContentConsumptionData delegates to the correct service', () async {
      when(mockYoutubeService.getContentConsumptionData(
        startDate: anyNamed('startDate'),
        endDate: anyNamed('endDate'),
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenAnswer((_) async => [
        {
          'id': 'video123',
          'title': 'Test Video',
        }
      ]);

      final result = await manager.getContentConsumptionData(
        'YouTube',
        limit: 10,
      );
      
      verify(mockYoutubeService.getContentConsumptionData(
        limit: 10,
      )).called(1);
      expect(result.length, 1);
      expect(result[0]['id'], 'video123');
    });

    test('getIntegratedContentData integrates data from multiple services', () async {
      when(mockYoutubeService.getContentConsumptionData(
        startDate: anyNamed('startDate'),
        endDate: anyNamed('endDate'),
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenAnswer((_) async => [
        {
          'id': 'video123',
          'title': 'Test Video',
          'source': 'YouTube',
        }
      ]);

      final result = await manager.getIntegratedContentData(
        serviceNames: ['YouTube'],
      );
      
      expect(result.keys, contains('YouTube'));
      expect(result['YouTube']!.length, 1);
      expect(result['YouTube']![0]['id'], 'video123');
    });
  });
}
