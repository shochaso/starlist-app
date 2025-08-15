import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repositories/voting_repository.dart';
import '../../../data/models/voting_models.dart';
import '../services/voting_service.dart';

/// SupabaseClient プロバイダー
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// VotingRepositoryのプロバイダー
final votingRepositoryProvider = Provider<VotingRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return VotingRepository(supabase: supabaseClient);
});

/// VotingServiceのプロバイダー
final votingServiceProvider = Provider<VotingService>((ref) {
  final repository = ref.watch(votingRepositoryProvider);
  return VotingService(repository: repository);
});

/// 現在のユーザーのスターP残高プロバイダー
final currentUserStarPointBalanceProvider = StreamProvider.family<StarPointBalance?, String>((ref, userId) {
  final service = ref.watch(votingServiceProvider);
  return service.watchStarPointBalance(userId).handleError((error, stackTrace) {
    // エラーハンドリング - ログを出力して null を返す
    print('スターP残高取得エラー: $error');
    return null;
  });
});

/// 現在のユーザーのスターP残高（一回限り取得）
final userStarPointBalanceProvider = FutureProvider.family<StarPointBalance?, String>((ref, userId) async {
  final service = ref.watch(votingServiceProvider);
  try {
    return await service.getStarPointBalance(userId);
  } catch (e) {
    print('スターP残高取得エラー: $e');
    return null;
  }
});

/// アクティブな投票投稿プロバイダー
final activeVotingPostsProvider = FutureProvider.autoDispose<List<VotingPost>>((ref) async {
  final service = ref.watch(votingServiceProvider);
  try {
    return await service.getActiveVotingPosts();
  } catch (e) {
    print('アクティブ投票投稿取得エラー: $e');
    return [];
  }
});

/// 特定スターの投票投稿プロバイダー
final starVotingPostsProvider = FutureProvider.family.autoDispose<List<VotingPost>, String>((ref, starId) async {
  final service = ref.watch(votingServiceProvider);
  try {
    return await service.getVotingPostsByStar(starId);
  } catch (e) {
    print('スター投票投稿取得エラー: $e');
    return [];
  }
});

/// 特定の投票投稿のリアルタイム監視プロバイダー
final votingPostStreamProvider = StreamProvider.family<VotingPost?, String>((ref, votingPostId) {
  final service = ref.watch(votingServiceProvider);
  return service.watchVotingPost(votingPostId).handleError((error, stackTrace) {
    print('投票投稿監視エラー: $error');
    return null;
  });
});

/// ユーザーの投票履歴プロバイダー
final userVotesProvider = FutureProvider.family.autoDispose<List<Vote>, String>((ref, userId) async {
  final service = ref.watch(votingServiceProvider);
  try {
    return await service.getUserVotes(userId);
  } catch (e) {
    print('ユーザー投票履歴取得エラー: $e');
    return [];
  }
});

/// 特定投票投稿に対するユーザーの投票プロバイダー
final userVoteForPostProvider = FutureProvider.family.autoDispose<Vote?, UserVoteQuery>((ref, query) async {
  final service = ref.watch(votingServiceProvider);
  try {
    return await service.getUserVoteForPost(query.userId, query.votingPostId);
  } catch (e) {
    print('ユーザー投票取得エラー: $e');
    return null;
  }
});

/// スターP取引履歴プロバイダー
final starPointTransactionsProvider = FutureProvider.family.autoDispose<List<StarPointTransaction>, String>((ref, userId) async {
  final service = ref.watch(votingServiceProvider);
  try {
    return await service.getStarPointTransactions(userId);
  } catch (e) {
    print('スターP取引履歴取得エラー: $e');
    return [];
  }
});

/// 投票実行アクションプロバイダー
final voteActionProvider = Provider<VoteActionNotifier>((ref) {
  final service = ref.watch(votingServiceProvider);
  return VoteActionNotifier(service);
});

/// 投票投稿作成アクションプロバイダー
final createVotingPostActionProvider = Provider<CreateVotingPostNotifier>((ref) {
  final service = ref.watch(votingServiceProvider);
  return CreateVotingPostNotifier(service);
});

/// 日次ログインボーナスアクションプロバイダー
final dailyBonusActionProvider = Provider<DailyBonusNotifier>((ref) {
  final service = ref.watch(votingServiceProvider);
  return DailyBonusNotifier(service);
});

// === Notifierクラス群 ===

/// ユーザー投票クエリクラス
class UserVoteQuery {
  final String userId;
  final String votingPostId;

  UserVoteQuery({
    required this.userId,
    required this.votingPostId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserVoteQuery &&
        other.userId == userId &&
        other.votingPostId == votingPostId;
  }

  @override
  int get hashCode => Object.hash(userId, votingPostId);
}

/// 投票実行ノーティファイア
class VoteActionNotifier extends StateNotifier<AsyncValue<VotingResult?>> {
  final VotingService _service;

  VoteActionNotifier(this._service) : super(const AsyncValue.data(null));

  /// 投票を実行
  Future<void> castVote(
    String userId,
    String votingPostId,
    VoteOption selectedOption,
  ) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await _service.castVote(userId, votingPostId, selectedOption);
      state = AsyncValue.data(result);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 状態をリセット
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// 投票投稿作成ノーティファイア
class CreateVotingPostNotifier extends StateNotifier<AsyncValue<VotingPost?>> {
  final VotingService _service;

  CreateVotingPostNotifier(this._service) : super(const AsyncValue.data(null));

  /// 投票投稿を作成
  Future<void> createVotingPost({
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
    state = const AsyncValue.loading();
    
    try {
      final post = await _service.createVotingPost(
        starId: starId,
        title: title,
        description: description,
        optionA: optionA,
        optionB: optionB,
        optionAImageUrl: optionAImageUrl,
        optionBImageUrl: optionBImageUrl,
        votingCost: votingCost,
        expiresAt: expiresAt,
        metadata: metadata,
      );
      state = AsyncValue.data(post);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 状態をリセット
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// 日次ボーナスノーティファイア
class DailyBonusNotifier extends StateNotifier<AsyncValue<DailyBonusResult?>> {
  final VotingService _service;

  DailyBonusNotifier(this._service) : super(const AsyncValue.data(null));

  /// 日次ログインボーナスを申請
  Future<void> claimDailyBonus(String userId) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await _service.grantDailyLoginBonus(userId);
      state = AsyncValue.data(result);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 状態をリセット
  void reset() {
    state = const AsyncValue.data(null);
  }
}