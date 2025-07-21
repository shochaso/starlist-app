import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import '../models/reaction_model.dart';
import '../services/reaction_service.dart';

/// リアクション状態管理
class ReactionNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  ReactionNotifier() : super(const AsyncValue.loading());

  /// 投稿リアクションデータを取得
  Future<void> loadPostReactions(String postId, String? userId) async {
    try {
      state = const AsyncValue.loading();
      
      final futures = await Future.wait([
        ReactionService.getPostReactionCounts(postId),
        if (userId != null) 
          ReactionService.getUserPostReactions(postId, userId)
        else
          Future.value(UserReactionState.empty),
      ]);

      final reactionCounts = futures[0] as ReactionCountModel;
      final userReactionState = futures[1] as UserReactionState;

      state = AsyncValue.data({
        'counts': reactionCounts,
        'userState': userReactionState,
        'postId': postId,
        'userId': userId,
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// コメントリアクションデータを取得
  Future<void> loadCommentReactions(String commentId, String? userId) async {
    try {
      state = const AsyncValue.loading();
      
      final futures = await Future.wait([
        ReactionService.getCommentReactionCounts(commentId),
        if (userId != null) 
          ReactionService.getUserCommentReactions(commentId, userId)
        else
          Future.value(UserReactionState.empty),
      ]);

      final reactionCounts = futures[0] as ReactionCountModel;
      final userReactionState = futures[1] as UserReactionState;

      state = AsyncValue.data({
        'counts': reactionCounts,
        'userState': userReactionState,
        'commentId': commentId,
        'userId': userId,
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 投稿リアクションを切り替え
  Future<void> togglePostReaction(
      String postId, String userId, ReactionType reactionType) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      // 楽観的更新
      final currentCounts = currentState['counts'] as ReactionCountModel;
      final currentUserState = currentState['userState'] as UserReactionState;
      
      final wasActive = currentUserState.hasReaction(reactionType);
      final newUserState = currentUserState.toggleReaction(reactionType);
      
      // カウントを更新
      final newCounts = _updateReactionCount(currentCounts, reactionType, !wasActive);
      
      state = AsyncValue.data({
        ...currentState,
        'counts': newCounts,
        'userState': newUserState,
      });

      // サーバーに送信
      await ReactionService.togglePostReaction(postId, userId, reactionType);
      
      // 最新データを再取得
      await loadPostReactions(postId, userId);
    } catch (error, stackTrace) {
      // エラー時は元の状態に戻す
      state = AsyncValue.data(currentState);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// コメントリアクションを切り替え
  Future<void> toggleCommentReaction(
      String commentId, String userId, ReactionType reactionType) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      // 楽観的更新
      final currentCounts = currentState['counts'] as ReactionCountModel;
      final currentUserState = currentState['userState'] as UserReactionState;
      
      final wasActive = currentUserState.hasReaction(reactionType);
      final newUserState = currentUserState.toggleReaction(reactionType);
      
      // カウントを更新
      final newCounts = _updateReactionCount(currentCounts, reactionType, !wasActive);
      
      state = AsyncValue.data({
        ...currentState,
        'counts': newCounts,
        'userState': newUserState,
      });

      // サーバーに送信
      await ReactionService.toggleCommentReaction(commentId, userId, reactionType);
      
      // 最新データを再取得
      await loadCommentReactions(commentId, userId);
    } catch (error, stackTrace) {
      // エラー時は元の状態に戻す
      state = AsyncValue.data(currentState);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// リアクション数を更新（楽観的更新用）
  ReactionCountModel _updateReactionCount(
      ReactionCountModel currentCounts, ReactionType reactionType, bool isAdd) {
    final delta = isAdd ? 1 : -1;
    
    switch (reactionType) {
      case ReactionType.like:
        return currentCounts.copyWith(
          like: (currentCounts.like + delta).clamp(0, double.infinity).toInt(),
        );
      case ReactionType.heart:
        return currentCounts.copyWith(
          heart: (currentCounts.heart + delta).clamp(0, double.infinity).toInt(),
        );
    }
  }
}

/// リアクションプロバイダー
final reactionProvider = StateNotifierProvider<ReactionNotifier, AsyncValue<Map<String, dynamic>>>(
  (ref) => ReactionNotifier(),
);

/// 投稿リアクションプロバイダー（特定の投稿用）
final postReactionProvider = StateNotifierProvider.family<ReactionNotifier, AsyncValue<Map<String, dynamic>>, String>(
  (ref, postId) => ReactionNotifier(),
);

/// コメントリアクションプロバイダー（特定のコメント用）
final commentReactionProvider = StateNotifierProvider.family<ReactionNotifier, AsyncValue<Map<String, dynamic>>, String>(
  (ref, commentId) => ReactionNotifier(),
);

/// 現在のユーザーIDプロバイダー
final currentUserIdProvider = Provider<String?>((ref) {
  final user = Supabase.instance.client.auth.currentUser;
  return user?.id;
});

/// 投稿リアクションウォッチャー（リアルタイム更新）
final postReactionWatcherProvider = StreamProvider.family<List<ReactionModel>, String>(
  (ref, postId) => ReactionService.watchPostReactions(postId),
);

/// コメントリアクションウォッチャー（リアルタイム更新）
final commentReactionWatcherProvider = StreamProvider.family<List<ReactionModel>, String>(
  (ref, commentId) => ReactionService.watchCommentReactions(commentId),
);

/// ユーザーリアクション履歴プロバイダー
final userReactionHistoryProvider = FutureProvider.family<List<ReactionModel>, String>(
  (ref, userId) async {
    final postReactions = await ReactionService.getUserPostReactionHistory(userId);
    final commentReactions = await ReactionService.getUserCommentReactionHistory(userId);
    
    // 作成日時でソート
    final allReactions = [...postReactions, ...commentReactions];
    allReactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return allReactions;
  },
);

/// 投稿の人気リアクションプロバイダー
final topPostReactionsProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>(
  (ref, params) async {
    final postId = params['postId'] as String;
    final reactionType = params['reactionType'] as ReactionType;
    final limit = params['limit'] as int? ?? 10;
    
    return ReactionService.getTopPostReactions(postId, reactionType, limit: limit);
  },
);

/// コメントの人気リアクションプロバイダー
final topCommentReactionsProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>(
  (ref, params) async {
    final commentId = params['commentId'] as String;
    final reactionType = params['reactionType'] as ReactionType;
    final limit = params['limit'] as int? ?? 10;
    
    return ReactionService.getTopCommentReactions(commentId, reactionType, limit: limit);
  },
);

/// リアクション統計プロバイダー
final reactionStatsProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, postId) async {
    final counts = await ReactionService.getPostReactionCounts(postId);
    final topLikes = await ReactionService.getTopPostReactions(postId, ReactionType.like, limit: 5);
    final topHearts = await ReactionService.getTopPostReactions(postId, ReactionType.heart, limit: 5);
    
    return {
      'counts': counts,
      'topLikes': topLikes,
      'topHearts': topHearts,
      'total': counts.total,
      'likePercentage': counts.total > 0 ? (counts.like / counts.total * 100) : 0,
      'heartPercentage': counts.total > 0 ? (counts.heart / counts.total * 100) : 0,
    };
  },
);

/// リアクション集計プロバイダー（複数投稿用）
final multiPostReactionStatsProvider = FutureProvider.family<Map<String, ReactionCountModel>, List<String>>(
  (ref, postIds) async {
    final Map<String, ReactionCountModel> stats = {};
    
    for (final postId in postIds) {
      try {
        final counts = await ReactionService.getPostReactionCounts(postId);
        stats[postId] = counts;
      } catch (e) {
        stats[postId] = ReactionCountModel.empty;
      }
    }
    
    return stats;
  },
);