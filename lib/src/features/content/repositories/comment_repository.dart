import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/comment_model.dart';
import '../../auth/models/user_model.dart';
import '../../auth/repositories/user_repository.dart';

/// コメントの管理を担当するリポジトリ
class CommentRepository {
  final SupabaseClient _client;
  final UserRepository _userRepository;
  final String _table = 'comments';
  
  CommentRepository(this._client, this._userRepository);
  
  /// 指定されたコンテンツに対するコメントを取得
  Future<List<CommentModel>> getCommentsByContentId(
    String contentId, {
    int limit = 20,
    int offset = 0,
    bool includeUserData = true,
  }) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('content_id', contentId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      if (data.isEmpty) {
        return [];
      }
      
      final comments = <CommentModel>[];
      
      for (final item in data) {
        UserModel? user;
        
        if (includeUserData) {
          user = await _userRepository.getUserById(item['user_id']);
        }
        
        comments.add(CommentModel.fromJson(item, user: user));
      }
      
      return comments;
    } catch (e) {
      log('コメントの取得に失敗しました: $e');
      return [];
    }
  }
  
  /// コメントを追加
  Future<CommentModel?> addComment({
    required String userId,
    required String contentId,
    required String text,
  }) async {
    try {
      final id = const Uuid().v4();
      final now = DateTime.now();
      
      final comment = CommentModel(
        id: id,
        userId: userId,
        contentId: contentId,
        text: text,
        createdAt: now,
        updatedAt: now,
      );
      
      await _client
          .from(_table)
          .insert(comment.toJson());
      
      // ユーザー情報も取得
      final user = await _userRepository.getUserById(userId);
      
      // コンテンツのコメント数をインクリメント
      await _client.rpc('increment_comment_count', params: {'content_id': contentId});
      
      return comment.copyWith(user: user);
    } catch (e) {
      log('コメントの追加に失敗しました: $e');
      return null;
    }
  }
  
  /// コメントを更新
  Future<bool> updateComment({
    required String commentId,
    required String userId,
    required String text,
  }) async {
    try {
      // 更新前にコメントの所有者を確認
      final existingComment = await _client
          .from(_table)
          .select()
          .eq('id', commentId)
          .single();
      
      if (existingComment['user_id'] != userId) {
        log('コメントが見つからないか、更新権限がありません');
        return false;
      }
      
      await _client
          .from(_table)
          .update({
            'text': text,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', commentId);
      
      return true;
    } catch (e) {
      log('コメントの更新に失敗しました: $e');
      return false;
    }
  }
  
  /// コメントを削除
  Future<bool> deleteComment({
    required String commentId, 
    required String userId,
  }) async {
    try {
      // 削除前にコメントの所有者を確認
      final existingComment = await _client
          .from(_table)
          .select()
          .eq('id', commentId)
          .single();
      
      final String contentId = existingComment['content_id'];
      
      // 自分のコメントか確認（管理者権限も後で追加可能）
      if (existingComment['user_id'] != userId) {
        log('コメントの削除権限がありません');
        return false;
      }
      
      await _client
          .from(_table)
          .delete()
          .eq('id', commentId);
      
      // コンテンツのコメント数をデクリメント
      await _client.rpc('decrement_comment_count', params: {'content_id': contentId});
      
      return true;
    } catch (e) {
      log('コメントの削除に失敗しました: $e');
      return false;
    }
  }
  
  /// コメントのいいね数をインクリメント
  Future<bool> incrementLikeCount(String commentId) async {
    try {
      await _client.rpc('increment_comment_like_count', params: {'comment_id': commentId});
      return true;
    } catch (e) {
      log('コメントのいいね数の更新に失敗しました: $e');
      return false;
    }
  }
} 