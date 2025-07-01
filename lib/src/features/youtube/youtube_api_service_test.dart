import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:starlist/src/features/data_integration/services/youtube_api_service.dart';

import 'youtube_api_service_test.mocks.dart';

// モックの生成
@GenerateMocks([Dio])
void main() {
  group('YouTubeApiService', () {
    late MockDio mockDio;
    late YouTubeApiService apiService;

    setUp(() {
      mockDio = MockDio();
      apiService = YouTubeApiService(
        apiKey: 'test_api_key',
        dio: mockDio,
      );
    });

    test('searchVideos should return list of videos', () async {
      // モックレスポンスの設定
      when(mockDio.get(
        'https://www.googleapis.com/youtube/v3/search',
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
        data: {
          'items': [
            {
              'id': {
                'videoId': 'test_video_id_1',
              },
              'snippet': {
                'title': 'Test Video 1',
                'channelId': 'test_channel_id_1',
                'channelTitle': 'Test Channel 1',
                'description': 'Test description 1',
                'publishedAt': '2023-01-01T12:00:00Z',
                'thumbnails': {
                  'high': {
                    'url': 'https://example.com/thumbnail1.jpg',
                  },
                },
              },
            },
            {
              'id': {
                'videoId': 'test_video_id_2',
              },
              'snippet': {
                'title': 'Test Video 2',
                'channelId': 'test_channel_id_2',
                'channelTitle': 'Test Channel 2',
                'description': 'Test description 2',
                'publishedAt': '2023-01-02T12:00:00Z',
                'thumbnails': {
                  'high': {
                    'url': 'https://example.com/thumbnail2.jpg',
                  },
                },
              },
            },
          ],
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ));

      // 動画詳細情報のモックレスポンス
      when(mockDio.get(
        'https://www.googleapis.com/youtube/v3/videos',
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
        data: {
          'items': [
            {
              'id': 'test_video_id_1',
              'snippet': {
                'title': 'Test Video 1',
                'channelId': 'test_channel_id_1',
                'channelTitle': 'Test Channel 1',
                'description': 'Test description 1',
                'publishedAt': '2023-01-01T12:00:00Z',
                'thumbnails': {
                  'high': {
                    'url': 'https://example.com/thumbnail1.jpg',
                  },
                },
              },
              'statistics': {
                'viewCount': '1000',
                'likeCount': '100',
                'commentCount': '50',
              },
              'contentDetails': {
                'duration': 'PT1M30S',
              },
            },
            {
              'id': 'test_video_id_2',
              'snippet': {
                'title': 'Test Video 2',
                'channelId': 'test_channel_id_2',
                'channelTitle': 'Test Channel 2',
                'description': 'Test description 2',
                'publishedAt': '2023-01-02T12:00:00Z',
                'thumbnails': {
                  'high': {
                    'url': 'https://example.com/thumbnail2.jpg',
                  },
                },
              },
              'statistics': {
                'viewCount': '2000',
                'likeCount': '200',
                'commentCount': '100',
              },
              'contentDetails': {
                'duration': 'PT2M30S',
              },
            },
          ],
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ));

      // テスト実行
      final videos = await apiService.searchVideos('test query');

      // 検証
      expect(videos.length, 2);
      expect(videos[0].id, 'test_video_id_1');
      expect(videos[0].title, 'Test Video 1');
      expect(videos[0].viewCount, 1000);
      expect(videos[0].duration, const Duration(minutes: 1, seconds: 30));
      
      expect(videos[1].id, 'test_video_id_2');
      expect(videos[1].title, 'Test Video 2');
      expect(videos[1].viewCount, 2000);
      expect(videos[1].duration, const Duration(minutes: 2, seconds: 30));
    });

    test('getVideoDetails should return list of video details', () async {
      // モックレスポンスの設定
      when(mockDio.get(
        'https://www.googleapis.com/youtube/v3/videos',
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
        data: {
          'items': [
            {
              'id': 'test_video_id',
              'snippet': {
                'title': 'Test Video',
                'channelId': 'test_channel_id',
                'channelTitle': 'Test Channel',
                'description': 'Test description',
                'publishedAt': '2023-01-01T12:00:00Z',
                'thumbnails': {
                  'high': {
                    'url': 'https://example.com/thumbnail.jpg',
                  },
                },
              },
              'statistics': {
                'viewCount': '1000',
                'likeCount': '100',
                'commentCount': '50',
              },
              'contentDetails': {
                'duration': 'PT1M30S',
              },
            },
          ],
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ));

      // テスト実行
      final videos = await apiService.getVideoDetails(['test_video_id']);

      // 検証
      expect(videos.length, 1);
      expect(videos[0].id, 'test_video_id');
      expect(videos[0].title, 'Test Video');
      expect(videos[0].channelId, 'test_channel_id');
      expect(videos[0].channelTitle, 'Test Channel');
      expect(videos[0].description, 'Test description');
      expect(videos[0].thumbnailUrl, 'https://example.com/thumbnail.jpg');
      expect(videos[0].viewCount, 1000);
      expect(videos[0].likeCount, 100);
      expect(videos[0].commentCount, 50);
      expect(videos[0].duration, const Duration(minutes: 1, seconds: 30));
    });

    test('getVideoDetail should return single video details', () async {
      // モックレスポンスの設定
      when(mockDio.get(
        'https://www.googleapis.com/youtube/v3/videos',
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
        data: {
          'items': [
            {
              'id': 'test_video_id',
              'snippet': {
                'title': 'Test Video',
                'channelId': 'test_channel_id',
                'channelTitle': 'Test Channel',
                'description': 'Test description',
                'publishedAt': '2023-01-01T12:00:00Z',
                'thumbnails': {
                  'high': {
                    'url': 'https://example.com/thumbnail.jpg',
                  },
                },
              },
              'statistics': {
                'viewCount': '1000',
                'likeCount': '100',
                'commentCount': '50',
              },
              'contentDetails': {
                'duration': 'PT1M30S',
              },
            },
          ],
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ));

      // テスト実行
      final video = await apiService.getVideoDetail('test_video_id');

      // 検証
      expect(video, isNotNull);
      expect(video?.id, 'test_video_id');
      expect(video?.title, 'Test Video');
      expect(video?.viewCount, 1000);
      expect(video?.duration, const Duration(minutes: 1, seconds: 30));
    });

    // エラーケースのテスト
    test('searchVideos should throw exception on error', () async {
      // エラーレスポンスの設定
      when(mockDio.get(
        'https://www.googleapis.com/youtube/v3/search',
        queryParameters: anyNamed('queryParameters'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'Test error',
        type: DioExceptionType.badResponse,
      ));

      // テスト実行と検証
      expect(() => apiService.searchVideos('test query'), throwsException);
    });

    test('getChannelVideos should return list of videos', () async {
      // モックレスポンスの設定
      when(mockDio.get(
        'https://www.googleapis.com/youtube/v3/search',
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
        data: {
          'items': [
            {
              'id': {
                'videoId': 'test_video_id_1',
              },
              'snippet': {
                'title': 'Test Video 1',
                'channelId': 'test_channel_id_1',
                'channelTitle': 'Test Channel 1',
                'description': 'Test description 1',
                'publishedAt': '2023-01-01T12:00:00Z',
                'thumbnails': {
                  'high': {
                    'url': 'https://example.com/thumbnail1.jpg',
                  },
                },
              },
            },
          ],
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ));

      // 動画詳細情報のモックレスポンス
      when(mockDio.get(
        'https://www.googleapis.com/youtube/v3/videos',
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
        data: {
          'items': [
            {
              'id': 'test_video_id_1',
              'snippet': {
                'title': 'Test Video 1',
                'channelId': 'test_channel_id_1',
                'channelTitle': 'Test Channel 1',
                'description': 'Test description 1',
                'publishedAt': '2023-01-01T12:00:00Z',
                'thumbnails': {
                  'high': {
                    'url': 'https://example.com/thumbnail1.jpg',
                  },
                },
              },
              'statistics': {
                'viewCount': '1000',
                'likeCount': '100',
                'commentCount': '50',
              },
              'contentDetails': {
                'duration': 'PT1M30S',
              },
            },
          ],
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ));

      // テスト実行
      final videos = await apiService.getChannelVideos('test_channel_id_1');

      // 検証
      expect(videos.length, 1);
      expect(videos[0].id, 'test_video_id_1');
      expect(videos[0].title, 'Test Video 1');
      expect(videos[0].channelId, 'test_channel_id_1');
    });

    test('getPopularVideos should return list of videos', () async {
      // モックレスポンスの設定
      when(mockDio.get(
        'https://www.googleapis.com/youtube/v3/videos',
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
        data: {
          'items': [
            {
              'id': 'test_video_id_1',
              'snippet': {
                'title': 'Test Video 1',
                'channelId': 'test_channel_id_1',
                'channelTitle': 'Test Channel 1',
                'description': 'Test description 1',
                'publishedAt': '2023-01-01T12:00:00Z',
                'thumbnails': {
                  'high': {
                    'url': 'https://example.com/thumbnail1.jpg',
                  },
                },
              },
              'statistics': {
                'viewCount': '1000',
                'likeCount': '100',
                'commentCount': '50',
              },
              'contentDetails': {
                'duration': 'PT1M30S',
              },
            },
          ],
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ));

      // テスト実行
      final videos = await apiService.getPopularVideos();

      // 検証
      expect(videos.length, 1);
      expect(videos[0].id, 'test_video_id_1');
      expect(videos[0].title, 'Test Video 1');
    });
  });
}
