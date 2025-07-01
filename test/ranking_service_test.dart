import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:starlist/src/features/ranking/models/ranking_model.dart';
import 'package:starlist/src/features/ranking/repositories/ranking_repository.dart';
import 'package:starlist/src/features/ranking/services/ranking_service.dart';
import 'package:starlist/src/core/errors/app_exceptions.dart';

@GenerateMocks([RankingRepository])
import 'ranking_service_test.mocks.dart';

void main() {
  late RankingService rankingService;
  late MockRankingRepository mockRankingRepository;

  setUp(() {
    mockRankingRepository = MockRankingRepository();
    rankingService = RankingService(mockRankingRepository);
  });

  final testRanking = RankingModel(
    id: 'test-ranking-id',
    type: RankingType.trending,
    target: RankingTarget.content,
    period: RankingPeriod.week,
    title: 'トレンドコンテンツ',
    items: [
      const RankingItemModel(
        id: 'item-1',
        rank: 1,
        type: 'video',
        title: 'テスト動画1',
        score: 100.0,
      ),
      const RankingItemModel(
        id: 'item-2',
        rank: 2,
        type: 'video',
        title: 'テスト動画2',
        score: 90.0,
      ),
    ],
    lastUpdated: DateTime.now(),
    cacheExpiry: DateTime.now().add(const Duration(hours: 1)),
  );

  group('getTrendingContent', () {
    test('正常にトレンドコンテンツを取得できる場合', () async {
      // モックの設定
      when(mockRankingRepository.getTrendingContent(
        period: anyNamed('period'),
        contentType: anyNamed('contentType'),
        limit: anyNamed('limit'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenAnswer((_) async => testRanking);

      // テスト対象メソッドの実行
      final result = await rankingService.getTrendingContent();

      // 検証
      expect(result, equals(testRanking));
      verify(mockRankingRepository.getTrendingContent(
        period: RankingPeriod.week,
        contentType: null,
        limit: 20,
        forceRefresh: false,
      )).called(1);
    });

    test('リポジトリでエラーが発生した場合、ServiceExceptionをスローする', () async {
      // モックの設定
      when(mockRankingRepository.getTrendingContent(
        period: anyNamed('period'),
        contentType: anyNamed('contentType'),
        limit: anyNamed('limit'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenThrow(DataFetchException('テストエラー'));

      // テスト対象メソッドの実行と検証
      expect(
        () => rankingService.getTrendingContent(),
        throwsA(isA<ServiceException>()),
      );
    });
  });

  group('getPopularStars', () {
    test('正常に人気スターを取得できる場合', () async {
      // モックの設定
      when(mockRankingRepository.getPopularStars(
        period: anyNamed('period'),
        category: anyNamed('category'),
        limit: anyNamed('limit'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenAnswer((_) async => testRanking);

      // テスト対象メソッドの実行
      final result = await rankingService.getPopularStars();

      // 検証
      expect(result, equals(testRanking));
      verify(mockRankingRepository.getPopularStars(
        period: RankingPeriod.week,
        category: null,
        limit: 20,
        forceRefresh: false,
      )).called(1);
    });

    test('リポジトリでエラーが発生した場合、ServiceExceptionをスローする', () async {
      // モックの設定
      when(mockRankingRepository.getPopularStars(
        period: anyNamed('period'),
        category: anyNamed('category'),
        limit: anyNamed('limit'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenThrow(DataFetchException('テストエラー'));

      // テスト対象メソッドの実行と検証
      expect(
        () => rankingService.getPopularStars(),
        throwsA(isA<ServiceException>()),
      );
    });
  });

  group('getCategoryRanking', () {
    test('正常にカテゴリランキングを取得できる場合', () async {
      // モックの設定
      when(mockRankingRepository.getCategoryRanking(
        categoryId: anyNamed('categoryId'),
        period: anyNamed('period'),
        limit: anyNamed('limit'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenAnswer((_) async => testRanking);

      // テスト対象メソッドの実行
      final result = await rankingService.getCategoryRanking(
        categoryId: 'test-category',
      );

      // 検証
      expect(result, equals(testRanking));
      verify(mockRankingRepository.getCategoryRanking(
        categoryId: 'test-category',
        period: RankingPeriod.week,
        limit: 20,
        forceRefresh: false,
      )).called(1);
    });

    test('リポジトリでエラーが発生した場合、ServiceExceptionをスローする', () async {
      // モックの設定
      when(mockRankingRepository.getCategoryRanking(
        categoryId: anyNamed('categoryId'),
        period: anyNamed('period'),
        limit: anyNamed('limit'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenThrow(DataFetchException('テストエラー'));

      // テスト対象メソッドの実行と検証
      expect(
        () => rankingService.getCategoryRanking(categoryId: 'test-category'),
        throwsA(isA<ServiceException>()),
      );
    });
  });

  group('getPersonalizedRanking', () {
    test('正常にパーソナライズドランキングを取得できる場合', () async {
      // モックの設定
      when(mockRankingRepository.getPersonalizedRanking(
        userId: anyNamed('userId'),
        period: anyNamed('period'),
        limit: anyNamed('limit'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenAnswer((_) async => testRanking);

      // テスト対象メソッドの実行
      final result = await rankingService.getPersonalizedRanking(
        userId: 'test-user',
      );

      // 検証
      expect(result, equals(testRanking));
      verify(mockRankingRepository.getPersonalizedRanking(
        userId: 'test-user',
        period: RankingPeriod.week,
        limit: 20,
        forceRefresh: false,
      )).called(1);
    });

    test('リポジトリでエラーが発生した場合、ServiceExceptionをスローする', () async {
      // モックの設定
      when(mockRankingRepository.getPersonalizedRanking(
        userId: anyNamed('userId'),
        period: anyNamed('period'),
        limit: anyNamed('limit'),
        forceRefresh: anyNamed('forceRefresh'),
      )).thenThrow(DataFetchException('テストエラー'));

      // テスト対象メソッドの実行と検証
      expect(
        () => rankingService.getPersonalizedRanking(userId: 'test-user'),
        throwsA(isA<ServiceException>()),
      );
    });
  });

  group('getPeriodDisplayName', () {
    test('各期間の表示名が正しく取得できる', () {
      expect(rankingService.getPeriodDisplayName(RankingPeriod.day), equals('今日'));
      expect(rankingService.getPeriodDisplayName(RankingPeriod.week), equals('今週'));
      expect(rankingService.getPeriodDisplayName(RankingPeriod.month), equals('今月'));
      expect(rankingService.getPeriodDisplayName(RankingPeriod.allTime), equals('全期間'));
    });
  });
}
