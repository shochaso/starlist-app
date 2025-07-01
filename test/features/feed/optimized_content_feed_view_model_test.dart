import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:starlist/src/features/feed/viewmodels/optimized_content_feed_view_model.dart';
import 'package:starlist/src/features/content/services/content_service.dart';
import 'package:starlist/src/core/cache/cache_manager.dart';
import 'package:starlist/src/core/logging/logger.dart';
import 'package:starlist/src/features/content/models/content_model.dart';

// モックの生成
@GenerateMocks([ContentService, CacheManager, Logger])
void main() {
  late OptimizedContentFeedViewModel viewModel;
  late MockContentService mockContentService;
  late MockCacheManager mockCacheManager;
  late MockLogger mockLogger;
  
  setUp(() {
    mockContentService = MockContentService();
    mockCacheManager = MockCacheManager();
    mockLogger = MockLogger();
    
    viewModel = OptimizedContentFeedViewModel(
      mockContentService,
      mockCacheManager,
      mockLogger,
    );
  });
  
  group('OptimizedContentFeedViewModel Tests', () {
    test('初期状態が正しいこと', () {
      expect(viewModel.state.contents, isEmpty);
      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.hasMore, isFalse);
      expect(viewModel.state.error, isNull);
    });
    
    test('コンテンツフィードの読み込みが正常に動作すること', () async {
      // モックデータの準備
      final mockContents = [
        ContentConsumptionModel(
          id: '1',
          title: 'テストコンテンツ1',
          description: 'テスト説明1',
          creator: UserModel(
            id: 'user1',
            username: 'testuser1',
            displayName: 'Test User 1',
            profileImageUrl: 'https://example.com/profile1.jpg',
          ),
          createdAt: DateTime.now(),
          likeCount: 10,
          commentCount: 5,
          shareCount: 2,
          isLiked: false,
        ),
        ContentConsumptionModel(
          id: '2',
          title: 'テストコンテンツ2',
          description: 'テスト説明2',
          creator: UserModel(
            id: 'user2',
            username: 'testuser2',
            displayName: 'Test User 2',
            profileImageUrl: 'https://example.com/profile2.jpg',
          ),
          createdAt: DateTime.now(),
          likeCount: 20,
          commentCount: 8,
          shareCount: 3,
          isLiked: true,
        ),
      ];
      
      // キャッシュからのデータ取得をモック
      when(mockCacheManager.get<List<ContentConsumptionModel>>('content_feed_user123_0'))
          .thenAnswer((_) async => null);
      
      // APIからのデータ取得をモック
      when(mockContentService.getContentFeed(
        userId: 'user123',
        offset: 0,
        limit: 10,
      )).thenAnswer((_) async => mockContents);
      
      // キャッシュへのデータ保存をモック
      when(mockCacheManager.set(
        'content_feed_user123_0',
        mockContents,
        expiry: anyNamed('expiry'),
      )).thenAnswer((_) async => true);
      
      // コンテンツフィードの読み込み
      await viewModel.loadContentFeed(userId: 'user123', refresh: true);
      
      // 状態の検証
      expect(viewModel.state.contents, equals(mockContents));
      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.hasMore, isFalse); // モックデータが10件未満なのでhasMoreはfalse
      expect(viewModel.state.error, isNull);
      
      // メソッド呼び出しの検証
      verify(mockCacheManager.get<List<ContentConsumptionModel>>('content_feed_user123_0')).called(1);
      verify(mockContentService.getContentFeed(
        userId: 'user123',
        offset: 0,
        limit: 10,
      )).called(1);
      verify(mockCacheManager.set(
        'content_feed_user123_0',
        mockContents,
        expiry: anyNamed('expiry'),
      )).called(1);
    });
    
    test('キャッシュからデータを取得できること', () async {
      // モックデータの準備
      final mockContents = [
        ContentConsumptionModel(
          id: '1',
          title: 'キャッシュコンテンツ1',
          description: 'キャッシュ説明1',
          creator: UserModel(
            id: 'user1',
            username: 'testuser1',
            displayName: 'Test User 1',
            profileImageUrl: 'https://example.com/profile1.jpg',
          ),
          createdAt: DateTime.now(),
          likeCount: 10,
          commentCount: 5,
          shareCount: 2,
          isLiked: false,
        ),
      ];
      
      // キャッシュからのデータ取得をモック
      when(mockCacheManager.get<List<ContentConsumptionModel>>('content_feed_user123_0'))
          .thenAnswer((_) async => mockContents);
      
      // コンテンツフィードの読み込み
      await viewModel.loadContentFeed(userId: 'user123', refresh: false);
      
      // 状態の検証
      expect(viewModel.state.contents, equals(mockContents));
      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.hasMore, isFalse);
      expect(viewModel.state.error, isNull);
      
      // メソッド呼び出しの検証
      verify(mockCacheManager.get<List<ContentConsumptionModel>>('content_feed_user123_0')).called(1);
      verifyNever(mockContentService.getContentFeed(
        userId: 'user123',
        offset: 0,
        limit: 10,
      ));
    });
    
    test('エラー時に適切に処理されること', () async {
      // キャッシュからのデータ取得をモック
      when(mockCacheManager.get<List<ContentConsumptionModel>>('content_feed_user123_0'))
          .thenAnswer((_) async => null);
      
      // APIからのデータ取得でエラーをスロー
      when(mockContentService.getContentFeed(
        userId: 'user123',
        offset: 0,
        limit: 10,
      )).thenThrow(Exception('API error'));
      
      // コンテンツフィードの読み込み
      await viewModel.loadContentFeed(userId: 'user123', refresh: true);
      
      // 状態の検証
      expect(viewModel.state.contents, isEmpty);
      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.hasMore, isFalse);
      expect(viewModel.state.error, isNotNull);
      expect(viewModel.state.error, contains('Exception: API error'));
      
      // メソッド呼び出しの検証
      verify(mockCacheManager.get<List<ContentConsumptionModel>>('content_feed_user123_0')).called(1);
      verify(mockContentService.getContentFeed(
        userId: 'user123',
        offset: 0,
        limit: 10,
      )).called(1);
      verify(mockLogger.error('Failed to load content feed', any)).called(1);
    });
    
    test('いいね機能が正常に動作すること', () async {
      // 初期状態の設定
      final initialContents = [
        ContentConsumptionModel(
          id: '1',
          title: 'テストコンテンツ1',
          description: 'テスト説明1',
          creator: UserModel(
            id: 'user1',
            username: 'testuser1',
            displayName: 'Test User 1',
            profileImageUrl: 'https://example.com/profile1.jpg',
          ),
          createdAt: DateTime.now(),
          likeCount: 10,
          commentCount: 5,
          shareCount: 2,
          isLiked: false,
        ),
      ];
      
      // 初期状態を設定
      viewModel = OptimizedContentFeedViewModel(
        mockContentService,
        mockCacheManager,
        mockLogger,
      );
      
      // プライベートフィールドを設定（テスト用）
      final state = ContentFeedState(
        contents: initialContents,
        isLoading: false,
        hasMore: false,
        error: null,
      );
      
      // リフレクションを使用してプライベートフィールドを設定
      final field = viewModel.runtimeType.toString().contains('_\$') 
          ? '_state' 
          : '_state';
      
      // 状態を設定
      viewModel.setStateForTest(state);
      
      // いいねAPIをモック
      when(mockContentService.likeContent('1'))
          .thenAnswer((_) async => true);
      
      // いいね実行
      await viewModel.likeContent('1');
      
      // 状態の検証
      expect(viewModel.state.contents.first.isLiked, isTrue);
      expect(viewModel.state.contents.first.likeCount, equals(11));
      
      // メソッド呼び出しの検証
      verify(mockContentService.likeContent('1')).called(1);
    });
  });
}

// テスト用の拡張メソッド
extension OptimizedContentFeedViewModelTestExtension on OptimizedContentFeedViewModel {
  void setStateForTest(ContentFeedState state) {
    // リフレクションを使用してプライベートフィールドを設定する代わりに
    // テスト用のメソッドを追加
    // 実際の実装では、このメソッドをOptimizedContentFeedViewModelに追加する必要がある
    // ここではモックとして示す
  }
}
