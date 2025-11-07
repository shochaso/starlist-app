@Skip('legacy ranking stack; pending re-home')
import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:starlist_app/src/features/ranking/models/ranking_entry.dart";
import "package:starlist_app/src/features/ranking/providers/ranking_provider.dart";
import "package:starlist_app/src/features/ranking/services/ranking_service.dart";

class MockRankingService extends Mock implements RankingService {}

void main() {
  late RankingProvider provider;
  late MockRankingService mockService;

  setUp(() {
    mockService = MockRankingService();
    provider = RankingProvider(mockService);
  });

  test("initial state", () {
    expect(provider.rankings, isEmpty);
    expect(provider.userRanking, null);
    expect(provider.topUsers, isEmpty);
    expect(provider.nearbyUsers, isEmpty);
    expect(provider.isLoading, false);
    expect(provider.error, null);
  });

  test("load rankings", () async {
    final rankings = [
      RankingEntry(
        userId: "user-1",
        username: "User 1",
        rank: 1,
        score: 1000,
        lastUpdated: DateTime.now(),
      ),
      RankingEntry(
        userId: "user-2",
        username: "User 2",
        rank: 2,
        score: 900,
        lastUpdated: DateTime.now(),
      ),
    ];

    when(mockService.getRankings(RankingType.daily)).thenAnswer((_) async => rankings);

    await provider.loadRankings(RankingType.daily);

    expect(provider.rankings.length, 2);
    expect(provider.isLoading, false);
    expect(provider.error, null);
  });

  test("load user ranking", () async {
    final userRanking = RankingEntry(
      userId: "user-1",
      username: "User 1",
      rank: 1,
      score: 1000,
      lastUpdated: DateTime.now(),
    );

    when(mockService.getUserRanking("user-1", RankingType.daily)).thenAnswer((_) async => userRanking);

    await provider.loadUserRanking("user-1", RankingType.daily);

    expect(provider.userRanking, userRanking);
    expect(provider.isLoading, false);
    expect(provider.error, null);
  });

  test("update user score", () async {
    when(mockService.updateUserScore("user-1", 1000)).thenAnswer((_) async {});

    await provider.updateUserScore("user-1", 1000);

    expect(provider.isLoading, false);
    expect(provider.error, null);
  });

  test("load top users", () async {
    final topUsers = [
      RankingEntry(
        userId: "user-1",
        username: "User 1",
        rank: 1,
        score: 1000,
        lastUpdated: DateTime.now(),
      ),
      RankingEntry(
        userId: "user-2",
        username: "User 2",
        rank: 2,
        score: 900,
        lastUpdated: DateTime.now(),
      ),
    ];

    when(mockService.getTopUsers(RankingType.daily)).thenAnswer((_) async => topUsers);

    await provider.loadTopUsers(RankingType.daily);

    expect(provider.topUsers.length, 2);
    expect(provider.isLoading, false);
    expect(provider.error, null);
  });

  test("load nearby users", () async {
    final nearbyUsers = [
      RankingEntry(
        userId: "user-2",
        username: "User 2",
        rank: 2,
        score: 900,
        lastUpdated: DateTime.now(),
      ),
      RankingEntry(
        userId: "user-3",
        username: "User 3",
        rank: 3,
        score: 800,
        lastUpdated: DateTime.now(),
      ),
    ];

    when(mockService.getNearbyUsers("user-1", RankingType.daily)).thenAnswer((_) async => nearbyUsers);

    await provider.loadNearbyUsers("user-1", RankingType.daily);

    expect(provider.nearbyUsers.length, 2);
    expect(provider.isLoading, false);
    expect(provider.error, null);
  });
}
