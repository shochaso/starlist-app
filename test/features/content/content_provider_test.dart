import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:starlist_app/src/features/content/models/content_model.dart";
import "package:starlist_app/src/features/content/providers/content_provider.dart";
import "package:starlist_app/src/features/content/services/content_service.dart";

class MockContentService extends Mock implements ContentService {}

void main() {
  late ContentProvider contentProvider;
  late MockContentService mockContentService;

  setUp(() {
    mockContentService = MockContentService();
    contentProvider = ContentProvider(mockContentService);
  });

  group("ContentProvider", () {
    test("initial state", () {
      expect(contentProvider.contents, isEmpty);
      expect(contentProvider.isLoading, isFalse);
      expect(contentProvider.error, isNull);
      expect(contentProvider.hasMore, isTrue);
    });

    test("load contents success", () async {
      final contents = [
        ContentModel(
          id: "1",
          title: "Test Content",
          description: "Test Description",
          type: ContentType.text,
          url: "https://example.com",
          authorId: "author1",
          authorName: "Test Author",
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          metadata: {},
        ),
      ];

      when(mockContentService.getContents()).thenAnswer((_) async => contents);

      await contentProvider.loadContents();

      expect(contentProvider.contents, equals(contents));
      expect(contentProvider.error, isNull);
    });

    test("load contents failure", () async {
      when(mockContentService.getContents()).thenThrow(Exception("Failed to load"));

      await contentProvider.loadContents();

      expect(contentProvider.contents, isEmpty);
      expect(contentProvider.error, isNotNull);
    });

    test("like content success", () async {
      final content = ContentModel(
        id: "1",
        title: "Test Content",
        description: "Test Description",
        type: ContentType.text,
        url: "https://example.com",
        authorId: "author1",
        authorName: "Test Author",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: {},
      );

      contentProvider = ContentProvider(mockContentService).._contents = [content];

      await contentProvider.likeContent("1");

      expect(contentProvider.contents.first.likes, equals(1));
      expect(contentProvider.error, isNull);
    });
  });
}
