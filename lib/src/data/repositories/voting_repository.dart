import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/voting_models.dart';

/// 投票システムのデータアクセス層
class VotingRepository {
  final SupabaseClient _supabase;

  VotingRepository({
    required SupabaseClient supabase,
  }) : _supabase = supabase;

  /// s_pointsのレコードを確実に用意
  Future<StarPointBalance> _ensureSPointsRow(String userId) async {
    final existing = await getStarPointBalance(userId);
    if (existing != null) return existing;
    final now = DateTime.now().toIso8601String();
    final inserted = await _supabase.from('s_points').insert({
      'user_id': userId,
      'balance': 0,
      'total_earned': 0,
      'total_spent': 0,
      'created_at': now,
      'updated_at': now,
    }).select().single();
    return StarPointBalance.fromJson(inserted);
  }

  /// スターポイント残高を取得
  Future<StarPointBalance?> getStarPointBalance(String userId) async {
    try {
      final response = await _supabase
          .from('s_points')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return StarPointBalance.fromJson(response);
    } catch (e, stack) {
      // どんな理由でも安全に0で返す
      print('fetchBalance error (safe fallback to 0): $e');
      final now = DateTime.now();
      return StarPointBalance(
        id: 'temp_${userId}_${now.millisecondsSinceEpoch}',
        userId: userId, 
        balance: 0,
        totalEarned: 0,
        totalSpent: 0,
        createdAt: now,
        updatedAt: now,
      );
    }
  }

  /// スターポイント取引履歴を取得
  Future<List<StarPointTransaction>> getStarPointTransactions(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('s_point_transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map<StarPointTransaction>((json) => StarPointTransaction.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get star point transactions: $e');
    }
  }

  /// アクティブな投票投稿を取得
  Future<List<VotingPost>> getActiveVotingPosts({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('voting_posts')
          .select()
          .eq('is_active', true)
          .or('expires_at.is.null,expires_at.gt.${DateTime.now().toIso8601String()}')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map<VotingPost>((json) => VotingPost.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get active voting posts: $e');
    }
  }

  /// 特定のスターの投票投稿を取得
  Future<List<VotingPost>> getVotingPostsByStar(
    String starId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('voting_posts')
          .select()
          .eq('star_id', starId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map<VotingPost>((json) => VotingPost.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get voting posts by star: $e');
    }
  }

  /// 投票投稿を作成
  Future<VotingPost> createVotingPost({
    required String starId,
    required String title,
    String? description,
    required String optionA,
    required String optionB,
    String? optionAImageUrl,
    String? optionBImageUrl,
    int votingCost = 1,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final data = {
        'star_id': starId,
        'title': title,
        'description': description,
        'option_a': optionA,
        'option_b': optionB,
        'option_a_image_url': optionAImageUrl,
        'option_b_image_url': optionBImageUrl,
        'voting_cost': votingCost,
        'expires_at': expiresAt?.toIso8601String(),
        'metadata': metadata ?? {},
      };

      final response = await _supabase
          .from('voting_posts')
          .insert(data)
          .select()
          .single();

      return VotingPost.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create voting post: $e');
    }
  }

  /// 投票投稿を更新
  Future<VotingPost> updateVotingPost(
    String votingPostId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _supabase
          .from('voting_posts')
          .update(updates)
          .eq('id', votingPostId)
          .select()
          .single();

      return VotingPost.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update voting post: $e');
    }
  }

  /// 投票を実行
  Future<Map<String, dynamic>> castVote(
    String votingPostId,
    VoteOption selectedOption,
  ) async {
    try {
      final response = await _supabase.rpc('cast_vote', params: {
        'p_voting_post_id': votingPostId,
        'p_selected_option': selectedOption == VoteOption.A ? 'A' : 'B',
      });

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Failed to cast vote: $e');
    }
  }

  /// ユーザーの投票履歴を取得
  Future<List<Vote>> getUserVotes(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('votes')
          .select()
          .eq('user_id', userId)
          .order('voted_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map<Vote>((json) => Vote.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get user votes: $e');
    }
  }

  /// 特定の投票投稿に対するユーザーの投票を取得
  Future<Vote?> getUserVoteForPost(
    String userId,
    String votingPostId,
  ) async {
    try {
      final response = await _supabase
          .from('votes')
          .select()
          .eq('user_id', userId)
          .eq('voting_post_id', votingPostId)
          .maybeSingle();

      if (response == null) return null;
      return Vote.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get user vote for post: $e');
    }
  }

  /// 投票投稿を削除（非アクティブ化）
  Future<void> deactivateVotingPost(String votingPostId) async {
    try {
      await _supabase
          .from('voting_posts')
          .update({'is_active': false})
          .eq('id', votingPostId);
    } catch (e) {
      throw Exception('Failed to deactivate voting post: $e');
    }
  }

  /// リアルタイム投票更新を監視
  Stream<VotingPost> watchVotingPost(String votingPostId) {
    return _supabase
        .from('voting_posts')
        .stream(primaryKey: ['id'])
        .eq('id', votingPostId)
        .map((List<Map<String, dynamic>> data) {
          if (data.isEmpty) {
            throw Exception('Voting post not found');
          }
          return VotingPost.fromJson(data.first);
        });
  }

  /// スターポイント残高のリアルタイム更新を監視
  Stream<StarPointBalance> watchStarPointBalance(String userId) {
    return _supabase
        .from('s_points')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((List<Map<String, dynamic>> data) {
          if (data.isEmpty) {
            throw Exception('Star point balance not found');
          }
          return StarPointBalance.fromJson(data.first);
        });
  }

  /// スターポイントを手動で付与（管理者用）
  Future<void> grantSPoints(
    String userId,
    int amount,
    String description,
  ) async {
    try {
      await _supabase.from('s_point_transactions').insert({
        'user_id': userId,
        'amount': amount,
        'transaction_type': 'bonus',
        'source_type': 'admin',
        'description': description,
      });

      final currentBalance = await _ensureSPointsRow(userId);
      await _supabase
          .from('s_points')
          .update({
            'balance': currentBalance.balance + amount,
            'total_earned': currentBalance.totalEarned + amount,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to grant star points: $e');
    }
  }

  /// 任意ソースでスターポイントを付与（購入/ガチャなど）
  Future<void> grantSPointsWithSource(
    String userId,
    int amount,
    String description,
    String sourceType,
  ) async {
    try {
      await _supabase.from('s_point_transactions').insert({
        'user_id': userId,
        'amount': amount,
        'transaction_type': 'bonus',
        'source_type': sourceType, // e.g. 'purchase' or 'admin'
        'description': description,
      });

      final currentBalance = await _ensureSPointsRow(userId);
      await _supabase
          .from('s_points')
          .update({
            'balance': currentBalance.balance + amount,
            'total_earned': currentBalance.totalEarned + amount,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
      
      // 更新後に少し待ってから確認（確実性のため）
      await Future.delayed(const Duration(milliseconds: 100));
      
      // 更新が確実に行われたか確認
      final updatedBalance = await getStarPointBalance(userId);
      if (updatedBalance != null && updatedBalance.balance != currentBalance.balance + amount) {
        print('Warning: Balance update may not have been applied correctly');
      }
    } catch (e) {
      throw Exception('Failed to grant star points with source: $e');
    }
  }

  /// 任意用途でスターポイントを消費（コンテンツ解放など）
  Future<bool> spendSPointsGeneric(
    String userId,
    int spendAmount,
    String description,
    String sourceType,
  ) async {
    try {
      final currentBalance = await _ensureSPointsRow(userId);
      if (currentBalance.balance < spendAmount) {
        return false;
      }

      await _supabase.from('s_point_transactions').insert({
        'user_id': userId,
        'amount': -spendAmount,
        'transaction_type': 'spent',
        'source_type': sourceType,
        'description': description,
      });

      await _supabase
          .from('s_points')
          .update({
            'balance': currentBalance.balance - spendAmount,
            'total_spent': currentBalance.totalSpent + spendAmount,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      return true;
    } catch (e) {
      throw Exception('Failed to spend star points: $e');
    }
  }

  /// 日次ログインボーナススターポイントを付与
  Future<bool> grantDailyLoginBonus(String userId) async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      
      // 今日既にボーナスを受け取っているかチェック
      final existingBonus = await _supabase
          .from('s_point_transactions')
          .select()
          .eq('user_id', userId)
          .eq('source_type', 'daily_login')
          .gte('created_at', '${today}T00:00:00.000Z')
          .lt('created_at', '${today}T23:59:59.999Z')
          .maybeSingle();

      if (existingBonus != null) {
        return false; // 既に受け取り済み
      }

      // ボーナスを付与
      const bonusAmount = 10;
      await grantSPointsWithSource(userId, bonusAmount, '日次ログインボーナス', 'daily_login');
      return true;
    } catch (e) {
      throw Exception('Failed to grant daily login bonus: $e');
    }
  }
}