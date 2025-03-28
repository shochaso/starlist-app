import "package:starlist/src/features/ranking/models/ranking_entry.dart";
import "package:hive/hive.dart";
import "package:supabase_flutter/supabase_flutter.dart";

abstract class RankingService {
  Future<List<RankingEntry>> getRankings(RankingType type, {int limit = 100});
  Future<RankingEntry?> getUserRanking(String userId, RankingType type);
  Future<void> updateUserScore(String userId, double score);
  Future<List<RankingEntry>> getTopUsers(RankingType type, {int limit = 10});
  Future<List<RankingEntry>> getNearbyUsers(String userId, RankingType type, {int limit = 5});
}

class RankingServiceImpl implements RankingService {
  final SupabaseClient _supabaseClient;
  final Box<dynamic> _cacheBox;
  
  RankingServiceImpl({
    required SupabaseClient supabaseClient,
    required Box<dynamic> cacheBox,
  })  : _supabaseClient = supabaseClient,
        _cacheBox = cacheBox;
  
  // キャッシュキーを生成
  String _getCacheKey(String key, RankingType type) => '${key}_${type.toString()}';
  
  // キャッシュの有効期限をチェック
  bool _isCacheValid(String cacheKey) {
    final cacheTimestamp = _cacheBox.get('${cacheKey}_timestamp');
    if (cacheTimestamp == null) return false;
    
    final timestamp = DateTime.parse(cacheTimestamp);
    final now = DateTime.now();
    
    // キャッシュの有効期限：1時間
    return now.difference(timestamp).inHours < 1;
  }
  
  // キャッシュを保存
  Future<void> _saveCache(String cacheKey, dynamic data) async {
    await _cacheBox.put(cacheKey, data);
    await _cacheBox.put('${cacheKey}_timestamp', DateTime.now().toIso8601String());
  }

  @override
  Future<List<RankingEntry>> getRankings(RankingType type, {int limit = 100}) async {
    final cacheKey = _getCacheKey('rankings', type);
    
    // キャッシュチェック
    if (_isCacheValid(cacheKey)) {
      final cachedData = _cacheBox.get(cacheKey);
      if (cachedData != null) {
        return (cachedData as List).map((item) => RankingEntry.fromJson(Map<String, dynamic>.from(item))).toList();
      }
    }
    
    try {
      // Supabaseからデータを取得
      final response = await _supabaseClient
          .from('rankings')
          .select()
          .eq('type', type.toString().split('.').last)
          .order('rank', ascending: true)
          .limit(limit);
      
      final List<RankingEntry> rankings = (response as List)
          .map((item) => RankingEntry.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      
      // キャッシュに保存
      await _saveCache(cacheKey, response);
      
      return rankings;
    } catch (e) {
      // エラーハンドリング
      print('ランキング取得エラー: $e');
      // キャッシュがあれば古いデータを返す
      final cachedData = _cacheBox.get(cacheKey);
      if (cachedData != null) {
        return (cachedData as List).map((item) => RankingEntry.fromJson(Map<String, dynamic>.from(item))).toList();
      }
      return [];
    }
  }

  @override
  Future<RankingEntry?> getUserRanking(String userId, RankingType type) async {
    final cacheKey = _getCacheKey('user_ranking_$userId', type);
    
    // キャッシュチェック
    if (_isCacheValid(cacheKey)) {
      final cachedData = _cacheBox.get(cacheKey);
      if (cachedData != null) {
        return RankingEntry.fromJson(Map<String, dynamic>.from(cachedData));
      }
    }
    
    try {
      // Supabaseからユーザーのランキングを取得
      final response = await _supabaseClient
          .from('rankings')
          .select()
          .eq('type', type.toString().split('.').last)
          .eq('userId', userId)
          .single();
      
      final rankingEntry = RankingEntry.fromJson(Map<String, dynamic>.from(response));
      
      // キャッシュに保存
      await _saveCache(cacheKey, response);
      
      return rankingEntry;
    } catch (e) {
      // エラーハンドリング
      print('ユーザーランキング取得エラー: $e');
      // キャッシュがあれば古いデータを返す
      final cachedData = _cacheBox.get(cacheKey);
      if (cachedData != null) {
        return RankingEntry.fromJson(Map<String, dynamic>.from(cachedData));
      }
      return null;
    }
  }

  @override
  Future<void> updateUserScore(String userId, double score) async {
    try {
      // 現在の日付を取得
      final now = DateTime.now();
      
      // ユーザーのスコアを更新（存在しない場合は作成）
      await _supabaseClient.rpc('update_user_score', params: {
        'p_user_id': userId,
        'p_score': score,
        'p_last_updated': now.toIso8601String(),
      });
      
      // キャッシュを削除して次回の取得で最新データを取得できるようにする
      final dailyKey = _getCacheKey('user_ranking_$userId', RankingType.daily);
      final weeklyKey = _getCacheKey('user_ranking_$userId', RankingType.weekly);
      final monthlyKey = _getCacheKey('user_ranking_$userId', RankingType.monthly);
      
      await _cacheBox.delete(dailyKey);
      await _cacheBox.delete(weeklyKey);
      await _cacheBox.delete(monthlyKey);
      
    } catch (e) {
      // エラーハンドリング
      print('ユーザースコア更新エラー: $e');
      throw Exception('スコアの更新に失敗しました: $e');
    }
  }

  @override
  Future<List<RankingEntry>> getTopUsers(RankingType type, {int limit = 10}) async {
    final cacheKey = _getCacheKey('top_users', type);
    
    // キャッシュチェック
    if (_isCacheValid(cacheKey)) {
      final cachedData = _cacheBox.get(cacheKey);
      if (cachedData != null) {
        return (cachedData as List).map((item) => RankingEntry.fromJson(Map<String, dynamic>.from(item))).toList();
      }
    }
    
    try {
      // Supabaseからトップユーザーを取得
      final response = await _supabaseClient
          .from('rankings')
          .select()
          .eq('type', type.toString().split('.').last)
          .order('rank', ascending: true)
          .limit(limit);
      
      final List<RankingEntry> topUsers = (response as List)
          .map((item) => RankingEntry.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      
      // キャッシュに保存
      await _saveCache(cacheKey, response);
      
      return topUsers;
    } catch (e) {
      // エラーハンドリング
      print('トップユーザー取得エラー: $e');
      // キャッシュがあれば古いデータを返す
      final cachedData = _cacheBox.get(cacheKey);
      if (cachedData != null) {
        return (cachedData as List).map((item) => RankingEntry.fromJson(Map<String, dynamic>.from(item))).toList();
      }
      return [];
    }
  }

  @override
  Future<List<RankingEntry>> getNearbyUsers(String userId, RankingType type, {int limit = 5}) async {
    final cacheKey = _getCacheKey('nearby_users_$userId', type);
    
    // キャッシュチェック
    if (_isCacheValid(cacheKey)) {
      final cachedData = _cacheBox.get(cacheKey);
      if (cachedData != null) {
        return (cachedData as List).map((item) => RankingEntry.fromJson(Map<String, dynamic>.from(item))).toList();
      }
    }
    
    try {
      // まずユーザーのランキングを取得
      final userRanking = await getUserRanking(userId, type);
      if (userRanking == null) {
        return [];
      }
      
      // ユーザーの前後のランキングを取得
      final response = await _supabaseClient.rpc(
        'get_nearby_users',
        params: {
          'p_user_rank': userRanking.rank,
          'p_type': type.toString().split('.').last,
          'p_limit': limit,
        },
      );
      
      final List<RankingEntry> nearbyUsers = (response as List)
          .map((item) => RankingEntry.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      
      // キャッシュに保存
      await _saveCache(cacheKey, response);
      
      return nearbyUsers;
    } catch (e) {
      // エラーハンドリング
      print('近隣ユーザー取得エラー: $e');
      // キャッシュがあれば古いデータを返す
      final cachedData = _cacheBox.get(cacheKey);
      if (cachedData != null) {
        return (cachedData as List).map((item) => RankingEntry.fromJson(Map<String, dynamic>.from(item))).toList();
      }
      return [];
    }
  }
}
