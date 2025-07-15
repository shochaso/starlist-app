import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reaction_model.dart';

/// リアクションサービス
/// 投稿とコメントのリアクション管理を担当
class ReactionService {
  static final _client = Supabase.instance.client;

  /// 投稿リアクション数を取得
  static Future<ReactionCountModel> getPostReactionCounts(String postId) async {
    try {
      final response = await _client.rpc(
        'get_post_reaction_counts',
        params: {'post_uuid': postId},
      );

      if (response == null) {
        return ReactionCountModel.empty;
      }

      final List<Map<String, dynamic>> results = 
          List<Map<String, dynamic>>.from(response);
      
      return ReactionCountModel.fromDatabase(results);
    } catch (e) {
      print('Error getting post reaction counts: $e');
      return ReactionCountModel.empty;
    }
  }

  /// コメントリアクション数を取得
  static Future<ReactionCountModel> getCommentReactionCounts(String commentId) async {
    try {
      final response = await _client.rpc(
        'get_comment_reaction_counts',
        params: {'comment_uuid': commentId},
      );

      if (response == null) {
        return ReactionCountModel.empty;
      }

      final List<Map<String, dynamic>> results = 
          List<Map<String, dynamic>>.from(response);
      
      return ReactionCountModel.fromDatabase(results);
    } catch (e) {
      print('Error getting comment reaction counts: $e');
      return ReactionCountModel.empty;
    }
  }

  /// ユーザーの投稿リアクション状態を取得
  static Future<UserReactionState> getUserPostReactions(
      String postId, String userId) async {
    try {
      final response = await _client.rpc(
        'get_user_post_reactions',
        params: {
          'post_uuid': postId,
          'user_uuid': userId,
        },
      );

      if (response == null) {
        return UserReactionState.empty;
      }

      final List<Map<String, dynamic>> results = 
          List<Map<String, dynamic>>.from(response);
      
      return UserReactionState.fromDatabase(results);
    } catch (e) {
      print('Error getting user post reactions: $e');
      return UserReactionState.empty;
    }
  }

  /// ユーザーのコメントリアクション状態を取得
  static Future<UserReactionState> getUserCommentReactions(
      String commentId, String userId) async {
    try {
      final response = await _client.rpc(
        'get_user_comment_reactions',
        params: {
          'comment_uuid': commentId,
          'user_uuid': userId,
        },
      );

      if (response == null) {
        return UserReactionState.empty;
      }

      final List<Map<String, dynamic>> results = 
          List<Map<String, dynamic>>.from(response);
      
      return UserReactionState.fromDatabase(results);
    } catch (e) {
      print('Error getting user comment reactions: $e');
      return UserReactionState.empty;
    }
  }

  /// 投稿リアクションを切り替え
  static Future<bool> togglePostReaction(
      String postId, String userId, ReactionType reactionType) async {
    try {
      final response = await _client.rpc(
        'toggle_post_reaction',
        params: {
          'post_uuid': postId,
          'user_uuid': userId,
          'reaction_type_param': reactionType.value,
        },
      );

      return response as bool? ?? false;
    } catch (e) {
      print('Error toggling post reaction: $e');
      rethrow;
    }
  }

  /// コメントリアクションを切り替え
  static Future<bool> toggleCommentReaction(
      String commentId, String userId, ReactionType reactionType) async {
    try {
      final response = await _client.rpc(
        'toggle_comment_reaction',
        params: {
          'comment_uuid': commentId,
          'user_uuid': userId,
          'reaction_type_param': reactionType.value,
        },
      );

      return response as bool? ?? false;
    } catch (e) {
      print('Error toggling comment reaction: $e');
      rethrow;
    }
  }

  /// 投稿リアクションのリアルタイム監視
  static Stream<List<ReactionModel>> watchPostReactions(String postId) {
    return _client
        .from('post_reactions')
        .stream(primaryKey: ['id'])
        .eq('post_id', postId)
        .map((data) => data
            .map((item) => ReactionModel.fromJson(item))
            .toList());
  }

  /// コメントリアクションのリアルタイム監視
  static Stream<List<ReactionModel>> watchCommentReactions(String commentId) {
    return _client
        .from('comment_reactions')
        .stream(primaryKey: ['id'])
        .eq('comment_id', commentId)
        .map((data) => data
            .map((item) => ReactionModel.fromJson(item))
            .toList());
  }

  /// ユーザーの投稿リアクション履歴を取得
  static Future<List<ReactionModel>> getUserPostReactionHistory(
      String userId, {int limit = 50}) async {
    try {
      final response = await _client
          .from('post_reactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return response
          .map((item) => ReactionModel.fromJson(item))
          .toList();
    } catch (e) {
      print('Error getting user post reaction history: $e');
      return [];
    }
  }

  /// ユーザーのコメントリアクション履歴を取得
  static Future<List<ReactionModel>> getUserCommentReactionHistory(
      String userId, {int limit = 50}) async {
    try {
      final response = await _client
          .from('comment_reactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return response
          .map((item) => ReactionModel.fromJson(item))
          .toList();
    } catch (e) {
      print('Error getting user comment reaction history: $e');
      return [];
    }
  }

  /// 投稿の人気リアクションを取得（上位リアクションユーザー）
  static Future<List<Map<String, dynamic>>> getTopPostReactions(
      String postId, ReactionType reactionType, {int limit = 10}) async {
    try {
      final response = await _client
          .from('post_reactions')
          .select('''
            *,
            profiles:user_id (
              id,
              username,
              full_name,
              avatar_url
            )
          ''')
          .eq('post_id', postId)
          .eq('reaction_type', reactionType.value)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting top post reactions: $e');
      return [];
    }
  }

  /// コメントの人気リアクションを取得（上位リアクションユーザー）
  static Future<List<Map<String, dynamic>>> getTopCommentReactions(
      String commentId, ReactionType reactionType, {int limit = 10}) async {
    try {
      final response = await _client
          .from('comment_reactions')
          .select('''
            *,
            profiles:user_id (
              id,
              username,
              full_name,
              avatar_url
            )
          ''')
          .eq('comment_id', commentId)
          .eq('reaction_type', reactionType.value)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting top comment reactions: $e');
      return [];
    }
  }

  /// 投稿リアクションを削除（管理者用）
  static Future<bool> deletePostReaction(String reactionId) async {
    try {
      await _client
          .from('post_reactions')
          .delete()
          .eq('id', reactionId);
      return true;
    } catch (e) {
      print('Error deleting post reaction: $e');
      return false;
    }
  }

  /// コメントリアクションを削除（管理者用）
  static Future<bool> deleteCommentReaction(String reactionId) async {
    try {
      await _client
          .from('comment_reactions')
          .delete()
          .eq('id', reactionId);
      return true;
    } catch (e) {
      print('Error deleting comment reaction: $e');
      return false;
    }
  }

  /// ユーザーの全リアクションを削除（アカウント削除時）
  static Future<bool> deleteAllUserReactions(String userId) async {
    try {
      // 投稿リアクション削除
      await _client
          .from('post_reactions')
          .delete()
          .eq('user_id', userId);

      // コメントリアクション削除
      await _client
          .from('comment_reactions')
          .delete()
          .eq('user_id', userId);

      return true;
    } catch (e) {
      print('Error deleting all user reactions: $e');
      return false;
    }
  }
}