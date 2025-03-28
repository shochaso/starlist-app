import "package:flutter/foundation.dart";
import "package:starlist/src/features/ranking/models/ranking_entry.dart";
import "package:starlist/src/features/ranking/services/ranking_service.dart";

class RankingProvider extends ChangeNotifier {
  final RankingService _rankingService;
  List<RankingEntry> _rankings = [];
  RankingEntry? _userRanking;
  List<RankingEntry> _topUsers = [];
  List<RankingEntry> _nearbyUsers = [];
  bool _isLoading = false;
  String? _error;

  RankingProvider(this._rankingService);

  List<RankingEntry> get rankings => _rankings;
  RankingEntry? get userRanking => _userRanking;
  List<RankingEntry> get topUsers => _topUsers;
  List<RankingEntry> get nearbyUsers => _nearbyUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRankings(RankingType type, {int limit = 100}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _rankings = await _rankingService.getRankings(type, limit: limit);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserRanking(String userId, RankingType type) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _userRanking = await _rankingService.getUserRanking(userId, type);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserScore(String userId, double score) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _rankingService.updateUserScore(userId, score);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTopUsers(RankingType type, {int limit = 10}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _topUsers = await _rankingService.getTopUsers(type, limit: limit);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNearbyUsers(String userId, RankingType type, {int limit = 5}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _nearbyUsers = await _rankingService.getNearbyUsers(userId, type, limit: limit);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
