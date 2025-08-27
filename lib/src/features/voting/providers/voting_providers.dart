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

/// 残高管理のためのStateNotifierProvider（MPパターン）
final starPointBalanceNotifierProvider = StateNotifierProvider.family<StarPointBalanceNotifier, StarPointBalance?, String>((ref, userId) {
  final service = ref.watch(votingServiceProvider);
  return StarPointBalanceNotifier(service, userId);
});

/// 残高管理のためのStateNotifierProvider（MPパターン）- 改善版
final starPointBalanceManagerProvider = StateNotifierProvider.family<StarPointBalanceManager, StarPointBalanceState, String>((ref, userId) {
  final service = ref.watch(votingServiceProvider);
  return StarPointBalanceManager(service, userId);
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

/// 残高管理ノーティファイア（MPパターン）
class StarPointBalanceNotifier extends StateNotifier<StarPointBalance?> {
  final VotingService _service;
  final String _userId;

  StarPointBalanceNotifier(this._service, this._userId) : super(null) {
    _initializeBalance();
  }

  /// 初期残高を取得
  Future<void> _initializeBalance() async {
    try {
      final balance = await _service.getStarPointBalance(_userId);
      state = balance;
    } catch (e) {
      print('初期残高取得エラー: $e');
      state = null;
    }
  }

  /// 残高を更新
  Future<void> updateBalance() async {
    try {
      final balance = await _service.getStarPointBalance(_userId);
      state = balance;
    } catch (e) {
      print('残高更新エラー: $e');
    }
  }

  /// ポイントを付与
  Future<void> addPoints(int amount, String description, String sourceType) async {
    try {
      final repo = _service.repository;
      await repo.grantSPointsWithSource(_userId, amount, description, sourceType);
      
      // 付与後に残高を更新
      await updateBalance();
    } catch (e) {
      print('ポイント付与エラー: $e');
      rethrow;
    }
  }

  /// ポイントを消費
  Future<bool> spendPoints(int amount, String description, String sourceType) async {
    try {
      final repo = _service.repository;
      final success = await repo.spendSPointsGeneric(_userId, amount, description, sourceType);
      
      if (success) {
        // 消費後に残高を更新
        await updateBalance();
      }
      
      return success;
    } catch (e) {
      print('ポイント消費エラー: $e');
      return false;
    }
  }

  /// 残高を強制リフレッシュ
  Future<void> refreshBalance() async {
    await updateBalance();
  }
}

/// 残高状態クラス
class StarPointBalanceState {
  final StarPointBalance? balance;
  final bool isLoading;
  final String? error;
  final DateTime lastUpdated;

  StarPointBalanceState({
    this.balance,
    this.isLoading = false,
    this.error,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  StarPointBalanceState copyWith({
    StarPointBalance? balance,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return StarPointBalanceState(
      balance: balance ?? this.balance,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// 残高が有効かチェック
  bool get isValid => balance != null && error == null;
  
  /// 残高の値
  int get balanceValue => balance?.balance ?? 0;
}

/// 残高管理マネージャー（MPパターン）- 改善版
class StarPointBalanceManager extends StateNotifier<StarPointBalanceState> {
  final VotingService _service;
  final String _userId;

  StarPointBalanceManager(this._service, this._userId) 
      : super(StarPointBalanceState(isLoading: true)) {
    // 初期化を遅延実行して、ユーザー情報が確実に読み込まれた後に実行
    Future.microtask(() => _initializeBalance());
  }

  /// 初期残高を取得
  Future<void> _initializeBalance() async {
    try {
      print('残高管理マネージャー初期化開始: ユーザーID = $_userId');
      state = state.copyWith(isLoading: true, error: null);
      
      // ユーザーIDの妥当性チェック
      if (_userId.isEmpty) {
        print('初期残高取得エラー: ユーザーIDが空です');
        state = state.copyWith(
          isLoading: false,
          error: 'ユーザーIDが無効です',
        );
        return;
      }
      
      print('残高取得開始...');
      final balance = await _service.getStarPointBalance(_userId);
      
      if (balance != null) {
        state = state.copyWith(
          balance: balance,
          isLoading: false,
          lastUpdated: DateTime.now(),
        );
        print('初期残高取得成功: ${balance.balance} ポイント');
      } else {
        print('初期残高取得失敗: データなし - 新規ユーザーの可能性');
        // 新規ユーザーの場合は残高0として初期化
        final defaultBalance = StarPointBalance(
          id: 'temp_${_userId}_${DateTime.now().millisecondsSinceEpoch}',
          userId: _userId,
          balance: 0,
          totalEarned: 0,
          totalSpent: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        state = state.copyWith(
          balance: defaultBalance,
          isLoading: false,
          lastUpdated: DateTime.now(),
        );
        print('新規ユーザー用のデフォルト残高を設定: 0 ポイント');
      }
    } catch (e, stackTrace) {
      print('初期残高取得エラー: $e');
      print('スタックトレース: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        error: '残高取得エラー: $e',
      );
    }
  }

  /// 残高を更新
  Future<void> updateBalance() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final balance = await _service.getStarPointBalance(_userId);
      
      if (balance != null) {
        state = state.copyWith(
          balance: balance,
          isLoading: false,
          lastUpdated: DateTime.now(),
        );
        print('残高更新成功: ${balance.balance} ポイント');
      } else {
        state = state.copyWith(
          isLoading: false,
          error: '残高データが見つかりません',
        );
        print('残高更新失敗: データなし');
      }
    } catch (e) {
      print('残高更新エラー: $e');
      state = state.copyWith(
        isLoading: false,
        error: '残高更新エラー: $e',
      );
    }
  }

  /// ポイントを付与
  Future<void> addPoints(int amount, String description, String sourceType) async {
    try {
      print('ポイント付与開始: $amount ポイント, 説明: $description, ソース: $sourceType');
      
      final repo = _service.repository;
      await repo.grantSPointsWithSource(_userId, amount, description, sourceType);
      
      print('ポイント付与完了: $amount ポイント');
      
      // 付与後に残高を更新
      await updateBalance();
      
    } catch (e) {
      print('ポイント付与エラー: $e');
      state = state.copyWith(error: 'ポイント付与エラー: $e');
      rethrow;
    }
  }

  /// ポイントを消費
  Future<bool> spendPoints(int amount, String description, String sourceType) async {
    try {
      print('ポイント消費開始: $amount ポイント, 説明: $description, ソース: $sourceType');
      
      final repo = _service.repository;
      final success = await repo.spendSPointsGeneric(_userId, amount, description, sourceType);
      
      if (success) {
        print('ポイント消費完了: $amount ポイント');
        // 消費後に残高を更新
        await updateBalance();
      } else {
        print('ポイント消費失敗: 残高不足');
      }
      
      return success;
    } catch (e) {
      print('ポイント消費エラー: $e');
      state = state.copyWith(error: 'ポイント消費エラー: $e');
      return false;
    }
  }

  /// 残高を強制リフレッシュ
  Future<void> refreshBalance() async {
    print('残高強制リフレッシュ開始');
    await updateBalance();
  }

  /// エラーをクリア
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// デバッグ情報を出力
  void debugInfo() {
    print('=== 残高管理マネージャーデバッグ情報 ===');
    print('ユーザーID: $_userId');
    print('現在の状態: ${state.isLoading ? "ローディング中" : "完了"}');
    print('残高: ${state.balanceValue} ポイント');
    print('エラー: ${state.error ?? "なし"}');
    print('最終更新: ${state.lastUpdated}');
    print('========================================');
  }
}