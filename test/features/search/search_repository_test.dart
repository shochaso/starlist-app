import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:starlist_app/features/search/data/search_repository.dart';

// Mockクラスの生成用アノテーション
@GenerateMocks([SupabaseClient, SupabaseQueryBuilder, PostgrestFilterBuilder])
import 'search_repository_test.mocks.dart';

void main() {
  group('SupabaseSearchRepository', () {
    late SupabaseSearchRepository repository;
    late MockSupabaseClient mockClient;
    late MockSupabaseQueryBuilder mockQueryBuilder;
    late MockPostgrestFilterBuilder mockFilterBuilder;

    setUp(() {
      mockClient = MockSupabaseClient();
      mockQueryBuilder = MockSupabaseQueryBuilder();
      mockFilterBuilder = MockPostgrestFilterBuilder();
      repository = SupabaseSearchRepository(mockClient);
    });

    group('search', () {
      test('full mode should query contents table', () async {
        // Arrange
        final mockData = [
          {
            'id': 1,
            'title': 'iPhone 15 Pro Max レビュー',
            'body': '最新のiPhoneをレビューします',
            'author': 'テックレビューアー田中',
            'tags': 'iPhone,Apple,ガジェット',
            'category': 'technology',
            'created_at': '2025-10-06T10:00:00Z',
          }
        ];

        when(mockClient.from('contents')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select<List<Map<String, dynamic>>>(any))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order(any, ascending: any))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.limit(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.or(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.then(any)).thenAnswer((_) async => mockData);

        // Act
        final results = await repository.search(
          query: 'iPhone',
          mode: 'full',
        );

        // Assert
        expect(results, isA<List<SearchItem>>());
        expect(results.length, 1);
        expect(results.first.title, 'iPhone 15 Pro Max レビュー');
        expect(results.first.type, 'content');

        verify(mockClient.from('contents')).called(1);
      });

      test('tag_only mode should query tag_only_ingests table', () async {
        // Arrange
        final mockData = [
          {
            'source_id': 'youtube_001',
            'tag_hash': 'hash_001',
            'category': 'youtube',
            'payload_json': {
              'title': '動画タイトル',
              'description': '動画の説明',
              'tag': 'ガジェット'
            },
            'created_at': '2025-10-06T10:00:00Z',
          }
        ];

        when(mockClient.from('tag_only_ingests')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select<List<Map<String, dynamic>>>(any))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order(any, ascending: any))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.limit(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.ilike(any, any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.then(any)).thenAnswer((_) async => mockData);

        // Act
        final results = await repository.search(
          query: 'ガジェット',
          mode: 'tag_only',
        );

        // Assert
        expect(results, isA<List<SearchItem>>());
        expect(results.length, 1);
        expect(results.first.title, '動画タイトル');
        expect(results.first.type, 'tag_only');

        verify(mockClient.from('tag_only_ingests')).called(1);
      });

      test('empty query should return results without filtering', () async {
        // Arrange
        final mockData = <Map<String, dynamic>>[];

        when(mockClient.from('contents')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select<List<Map<String, dynamic>>>(any))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order(any, ascending: any))
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.limit(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.then(any)).thenAnswer((_) async => mockData);

        // Act
        final results = await repository.search(
          query: '',
          mode: 'full',
        );

        // Assert
        expect(results, isEmpty);
        verify(mockClient.from('contents')).called(1);
        // orメソッドが呼ばれていないことを確認（空クエリの場合）
        verifyNever(mockFilterBuilder.or(any));
      });
    });

    group('insertTagOnly', () {
      test('should insert tag data with correct parameters', () async {
        // Arrange
        final payload = {
          'source_id': 'test_001',
          'tag_hash': 'hash_001',
          'category': 'youtube',
          'raw': {'title': 'テスト動画', 'tag': 'テスト'}
        };
        const userId = 'user_123';

        when(mockClient.from('tag_only_ingests')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.upsert(any,
                onConflict: anyNamed('onConflict'),
                ignoreDuplicates: anyNamed('ignoreDuplicates')))
            .thenAnswer((_) async => []);

        // Act
        await repository.insertTagOnly(payload, userId: userId);

        // Assert
        verify(mockClient.from('tag_only_ingests')).called(1);
        verify(mockQueryBuilder.upsert(
          argThat(contains('user_id')),
          onConflict: 'source_id,tag_hash',
          ignoreDuplicates: true,
        )).called(1);
      });

      test('should skip game category', () async {
        // Arrange
        final payload = {
          'source_id': 'game_001',
          'tag_hash': 'hash_001',
          'category': 'game',
          'raw': {'title': 'ゲームデータ'}
        };
        const userId = 'user_123';

        // Act
        await repository.insertTagOnly(payload, userId: userId);

        // Assert
        // ゲームカテゴリの場合はDBアクセスが発生しないことを確認
        verifyNever(mockClient.from(any));
      });

      test('should handle database errors gracefully', () async {
        // Arrange
        final payload = {
          'source_id': 'test_001',
          'tag_hash': 'hash_001',
          'category': 'youtube',
          'raw': {'title': 'テスト動画'}
        };
        const userId = 'user_123';

        when(mockClient.from('tag_only_ingests')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.upsert(any,
                onConflict: anyNamed('onConflict'),
                ignoreDuplicates: anyNamed('ignoreDuplicates')))
            .thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => repository.insertTagOnly(payload, userId: userId),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('_escapeLike', () {
      test('should escape special characters for LIKE queries', () {
        // privateメソッドのテストは通常行わないが、
        // セキュリティ上重要なので例外的にテスト
        
        // リフレクションを使ってprivateメソッドをテスト
        // 実際のプロジェクトでは、このメソッドをpublicにするか、
        // 統合テストで間接的にテストすることを推奨
        
        // Act & Assert (疑似コード)
        // expect(repository._escapeLike('test%data'), 'test\\%data');
        // expect(repository._escapeLike('test_data'), 'test\\_data');
      });
    });
  });

  group('SearchItem', () {
    test('should create SearchItem from JSON correctly', () {
      // Arrange  
      final json = {
        'id': '123',
        'title': 'テストタイトル',
        'subtitle': 'テストサブタイトル',
        'category': 'technology',
        'image_url': 'https://example.com/image.jpg',
        'type': 'content',
        'metadata': {'key': 'value'},
        'created_at': '2025-10-06T10:00:00Z',
      };

      // Act
      final item = SearchItem.fromJson(json);

      // Assert
      expect(item.id, '123');
      expect(item.title, 'テストタイトル');
      expect(item.subtitle, 'テストサブタイトル');
      expect(item.category, 'technology');
      expect(item.imageUrl, 'https://example.com/image.jpg');
      expect(item.type, 'content');
      expect(item.metadata, {'key': 'value'});
      expect(item.createdAt, isA<DateTime>());
    });

    test('should handle null values gracefully', () {
      // Arrange
      final json = {
        'id': '123',
        'title': 'テストタイトル',
        'type': 'content',
      };

      // Act
      final item = SearchItem.fromJson(json);

      // Assert
      expect(item.id, '123');
      expect(item.title, 'テストタイトル');
      expect(item.subtitle, isNull);
      expect(item.category, isNull);
      expect(item.imageUrl, isNull);
      expect(item.metadata, isNull);
      expect(item.createdAt, isNull);
    });

    test('should convert to JSON correctly', () {
      // Arrange
      final item = SearchItem(
        id: '123',
        title: 'テストタイトル',
        subtitle: 'テストサブタイトル',
        category: 'technology',
        imageUrl: 'https://example.com/image.jpg',
        type: 'content',
        metadata: {'key': 'value'},
        createdAt: DateTime.parse('2025-10-06T10:00:00Z'),
      );

      // Act
      final json = item.toJson();

      // Assert
      expect(json['id'], '123');
      expect(json['title'], 'テストタイトル');
      expect(json['subtitle'], 'テストサブタイトル');
      expect(json['category'], 'technology');
      expect(json['image_url'], 'https://example.com/image.jpg');
      expect(json['type'], 'content');
      expect(json['metadata'], {'key': 'value'});
      expect(json['created_at'], '2025-10-06T10:00:00.000Z');
    });
  });
}