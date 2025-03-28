import "package:starlist/src/features/ranking/models/ranking_entry.dart";

abstract class RankingService {
  Future<List<RankingEntry>> getRankings(RankingType type, {int limit = 100});
  Future<RankingEntry?> getUserRanking(String userId, RankingType type);
  Future<void> updateUserScore(String userId, double score);
  Future<List<RankingEntry>> getTopUsers(RankingType type, {int limit = 10});
  Future<List<RankingEntry>> getNearbyUsers(String userId, RankingType type, {int limit = 5});
}

class RankingServiceImpl implements RankingService {
  @override
  Future<List<RankingEntry>> getRankings(RankingType type, {int limit = 100}) async {
    // TODO: Implement rankings retrieval
    throw UnimplementedError();
  }

  @override
  Future<RankingEntry?> getUserRanking(String userId, RankingType type) async {
    // TODO: Implement user ranking retrieval
    throw UnimplementedError();
  }

  @override
  Future<void> updateUserScore(String userId, double score) async {
    // TODO: Implement user score update
    throw UnimplementedError();
  }

  @override
  Future<List<RankingEntry>> getTopUsers(RankingType type, {int limit = 10}) async {
    // TODO: Implement top users retrieval
    throw UnimplementedError();
  }

  @override
  Future<List<RankingEntry>> getNearbyUsers(String userId, RankingType type, {int limit = 5}) async {
    // TODO: Implement nearby users retrieval
    throw UnimplementedError();
  }
}
