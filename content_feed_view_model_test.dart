import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:starlist/src/features/content/presentation/viewmodels/content_feed_view_model.dart';
import 'package:starlist/src/shared/models/content_consumption_model.dart';

@GenerateMocks([ContentService])
void main() {
  late MockContentService mockContentService;
  late ContentFeedViewModel viewModel;

  setUp(() {
    mockContentService = MockContentService();
    viewModel = ContentFeedViewModel(contentService: mockContentService);
  });

  group('ContentFeedViewModel', () {
    test('loadContentFeed should update state correctly', () async {
      // Arrange
      final contentItems = [
        ContentConsumptionModel(
          id: '1',
          userId: 'user1',
          contentType: 'youtube',
          contentId: 'video1',
          contentTitle: 'Test Video',
          contentCreator: 'Test Creator',
          contentUrl: 'https://example.com/video1',
          contentThumbnailUrl: 'https://example.com/thumbnail1',
          contentDuration: 300,
          consumedDuration: 250,
          consumedAt: DateTime.now(),
          isPublic: true,
        ),
      ];
      
      when(mockContentService.getContentFeed(
        userId: 'user1',
        categoryId: null,
        limit: 20,
        offset: 0,
      )).thenAnswer((_) async => contentItems);
      
      // Act
      await viewModel.loadContentFeed(userId: 'user1');
      
      // Assert
      expect(viewModel.contentItems, contentItems);
      expect(viewModel.isLoading, false);
      expect(viewModel.error, null);
      verify(mockContentService.getContentFeed(
        userId: 'user1',
        categoryId: null,
        limit: 20,
        offset: 0,
      )).called(1);
    });

    test('loadContentFeed should handle errors', () async {
      // Arrange
      when(mockContentService.getContentFeed(
        userId: 'user1',
        categoryId: null,
        limit: 20,
        offset: 0,
      )).thenThrow(Exception('Network error'));
      
      // Act
      await viewModel.loadContentFeed(userId: 'user1');
      
      // Assert
      expect(viewModel.contentItems, []);
      expect(viewModel.isLoading, false);
      expect(viewModel.error, 'Exception: Network error');
      verify(mockContentService.getContentFeed(
        userId: 'user1',
        categoryId: null,
        limit: 20,
        offset: 0,
      )).called(1);
    });

    test('refreshContentFeed should call loadContentFeed with offset 0', () async {
      // Arrange
      final contentItems = [
        ContentConsumptionModel(
          id: '1',
          userId: 'user1',
          contentType: 'youtube',
          contentId: 'video1',
          contentTitle: 'Test Video',
          contentCreator: 'Test Creator',
          contentUrl: 'https://example.com/video1',
          contentThumbnailUrl: 'https://example.com/thumbnail1',
          contentDuration: 300,
          consumedDuration: 250,
          consumedAt: DateTime.now(),
          isPublic: true,
        ),
      ];
      
      when(mockContentService.getContentFeed(
        userId: 'user1',
        categoryId: null,
        limit: 20,
        offset: 0,
      )).thenAnswer((_) async => contentItems);
      
      // Act
      await viewModel.refreshContentFeed(userId: 'user1');
      
      // Assert
      expect(viewModel.contentItems, contentItems);
      expect(viewModel.isLoading, false);
      expect(viewModel.error, null);
      verify(mockContentService.getContentFeed(
        userId: 'user1',
        categoryId: null,
        limit: 20,
        offset: 0,
      )).called(1);
    });

    test('loadMoreContentItems should append new items', () async {
      // Arrange
      final initialItems = [
        ContentConsumptionModel(
          id: '1',
          userId: 'user1',
          contentType: 'youtube',
          contentId: 'video1',
          contentTitle: 'Test Video 1',
          contentCreator: 'Test Creator',
          contentUrl: 'https://example.com/video1',
          contentThumbnailUrl: 'https://example.com/thumbnail1',
          contentDuration: 300,
          consumedDuration: 250,
          consumedAt: DateTime.now(),
          isPublic: true,
        ),
      ];
      
      final moreItems = [
        ContentConsumptionModel(
          id: '2',
          userId: 'user1',
          contentType: 'youtube',
          contentId: 'video2',
          contentTitle: 'Test Video 2',
          contentCreator: 'Test Creator',
          contentUrl: 'https://example.com/video2',
          contentThumbnailUrl: 'https://example.com/thumbnail2',
          contentDuration: 400,
          consumedDuration: 350,
          consumedAt: DateTime.now(),
          isPublic: true,
        ),
      ];
      
      when(mockContentService.getContentFeed(
        userId: 'user1',
        categoryId: null,
        limit: 20,
        offset: 0,
      )).thenAnswer((_) async => initialItems);
      
      when(mockContentService.getContentFeed(
        userId: 'user1',
        categoryId: null,
        limit: 20,
        offset: 1,
      )).thenAnswer((_) async => moreItems);
      
      // Act
      await viewModel.loadContentFeed(userId: 'user1');
      await viewModel.loadMoreContentItems(userId: 'user1');
      
      // Assert
      expect(viewModel.contentItems.length, 2);
      expect(viewModel.contentItems[0].id, '1');
      expect(viewModel.contentItems[1].id, '2');
      expect(viewModel.isLoading, false);
      expect(viewModel.error, null);
      verify(mockContentService.getContentFeed(
        userId: 'user1',
        categoryId: null,
        limit: 20,
        offset: 1,
      )).called(1);
    });

    test('searchContentItems should update state correctly', () async {
      // Arrange
      final searchResults = [
        ContentConsumptionModel(
          id: '3',
          userId: 'user1',
          contentType: 'youtube',
          contentId: 'video3',
          contentTitle: 'Search Result Video',
          contentCreator: 'Test Creator',
          contentUrl: 'https://example.com/video3',
          contentThumbnailUrl: 'https://example.com/thumbnail3',
          contentDuration: 500,
          consumedDuration: 450,
          consumedAt: DateTime.now(),
          isPublic: true,
        ),
      ];
      
      when(mockContentService.searchContent(
        query: 'test search',
        categoryId: null,
        limit: 20,
        offset: 0,
      )).thenAnswer((_) async => searchResults);
      
      // Act
      await viewModel.searchContentItems(query: 'test search');
      
      // Assert
      expect(viewModel.contentItems, searchResults);
      expect(viewModel.isLoading, false);
      expect(viewModel.error, null);
      verify(mockContentService.searchContent(
        query: 'test search',
        categoryId: null,
        limit: 20,
        offset: 0,
      )).called(1);
    });
  });
}
