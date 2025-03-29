import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;

import '../models/comment_model.dart';
import '../repositories/comment_repository.dart';
import '../../auth/repositories/user_repository.dart';
import '../../auth/providers/user_repository_provider.dart';
import '../../auth/supabase_provider.dart' as auth;
import '../../../config/providers.dart';

/// コメントリポジトリのプロバイダー
final commentRepositoryProvider = riverpod.Provider<CommentRepository>((ref) {
  final client = ref.watch(auth.supabaseClientProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  return CommentRepository(client, userRepository);
});

/// コンテンツIDに紐づくコメント一覧を取得するプロバイダー
final contentCommentsProvider = FutureProvider.family<List<CommentModel>, ContentCommentsParams>((ref, params) async {
  final repository = ref.watch(commentRepositoryProvider);
  return repository.getCommentsByContentId(
    params.contentId,
    limit: params.limit,
    offset: params.offset,
    includeUserData: params.includeUserData,
  );
});

/// コメント操作のパラメータクラス
class ContentCommentsParams {
  final String contentId;
  final int limit;
  final int offset;
  final bool includeUserData;
  
  ContentCommentsParams({
    required this.contentId,
    this.limit = 20,
    this.offset = 0,
    this.includeUserData = true,
  });
}

/// コメント管理用プロバイダー
class CommentNotifier extends StateNotifier<AsyncValue<List<CommentModel>>> {
  final CommentRepository _repository;
  final String _contentId;
  
  CommentNotifier(this._repository, this._contentId) : super(const AsyncValue.loading()) {
    loadComments();
  }
  
  /// コメントを読み込む
  Future<void> loadComments() async {
    state = const AsyncValue.loading();
    try {
      final comments = await _repository.getCommentsByContentId(_contentId);
      state = AsyncValue.data(comments);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  /// コメントを追加
  Future<CommentModel?> addComment(String userId, String text) async {
    try {
      final newComment = await _repository.addComment(
        userId: userId,
        contentId: _contentId,
        text: text,
      );
      
      if (newComment != null) {
        // 新しいコメントを先頭に追加
        state = AsyncValue.data([newComment, ...state.value ?? []]);
      }
      
      return newComment;
    } catch (e) {
      return null;
    }
  }
  
  /// コメントを更新
  Future<bool> updateComment(String commentId, String userId, String text) async {
    try {
      final success = await _repository.updateComment(
        commentId: commentId,
        userId: userId,
        text: text,
      );
      
      if (success) {
        // 更新が成功したらステートを更新
        final currentComments = state.value ?? [];
        final index = currentComments.indexWhere((comment) => comment.id == commentId);
        
        if (index >= 0) {
          final updatedComment = currentComments[index].copyWith(
            text: text,
            updatedAt: DateTime.now(),
          );
          
          final updatedComments = [...currentComments];
          updatedComments[index] = updatedComment;
          
          state = AsyncValue.data(updatedComments);
        }
      }
      
      return success;
    } catch (e) {
      return false;
    }
  }
  
  /// コメントを削除
  Future<bool> deleteComment(String commentId, String userId) async {
    try {
      final success = await _repository.deleteComment(
        commentId: commentId,
        userId: userId,
      );
      
      if (success) {
        // 削除が成功したらステートから該当コメントを削除
        final currentComments = state.value ?? [];
        state = AsyncValue.data(currentComments.where((comment) => comment.id != commentId).toList());
      }
      
      return success;
    } catch (e) {
      return false;
    }
  }
  
  /// コメントにいいねを追加
  Future<bool> likeComment(String commentId) async {
    try {
      final success = await _repository.incrementLikeCount(commentId);
      
      if (success) {
        // いいねが成功したらステートを更新
        final currentComments = state.value ?? [];
        final index = currentComments.indexWhere((comment) => comment.id == commentId);
        
        if (index >= 0) {
          final updatedComment = currentComments[index].copyWith(
            likeCount: currentComments[index].likeCount + 1,
          );
          
          final updatedComments = [...currentComments];
          updatedComments[index] = updatedComment;
          
          state = AsyncValue.data(updatedComments);
        }
      }
      
      return success;
    } catch (e) {
      return false;
    }
  }
}

/// コメント管理プロバイダー
final commentProvider = StateNotifierProvider.autoDispose.family<CommentNotifier, AsyncValue<List<CommentModel>>, String>((ref, contentId) {
  final repository = ref.watch(commentRepositoryProvider);
  return CommentNotifier(repository, contentId);
}); 