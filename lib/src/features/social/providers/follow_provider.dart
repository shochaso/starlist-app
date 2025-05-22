import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import '../repositories/follow_repository.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/user_repository_provider.dart';
import '../../auth/supabase_provider.dart' as auth;

/// フォローリポジトリのプロバイダー
final followRepositoryProvider = riverpod.Provider<FollowRepository>((ref) {
  final client = ref.watch(auth.supabaseClientProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  return FollowRepository(client, userRepository);
});

/// フォロワー数のプロバイダー
final followerCountProvider = FutureProvider.family<int, String>((ref, userId) async {
  final repository = ref.watch(followRepositoryProvider);
  return repository.getFollowerCount(userId);
});

/// フォロー数のプロバイダー
final followingCountProvider = FutureProvider.family<int, String>((ref, userId) async {
  final repository = ref.watch(followRepositoryProvider);
  return repository.getFollowingCount(userId);
});

/// フォロー中のユーザー一覧プロバイダー
final followingProvider = FutureProvider.family<List<UserModel>, FollowParams>((ref, params) async {
  final repository = ref.watch(followRepositoryProvider);
  return repository.getFollowing(
    params.userId,
    limit: params.limit,
    offset: params.offset,
  );
});

/// フォロワー一覧プロバイダー
final followersProvider = FutureProvider.family<List<UserModel>, FollowParams>((ref, params) async {
  final repository = ref.watch(followRepositoryProvider);
  return repository.getFollowers(
    params.userId,
    limit: params.limit,
    offset: params.offset,
  );
});

/// フォロー状態チェックプロバイダー
final isFollowingProvider = FutureProvider.family<bool, FollowRelationParams>((ref, params) async {
  final repository = ref.watch(followRepositoryProvider);
  return repository.isFollowing(params.followerId, params.followedId);
});

/// フォロー関連パラメータクラス
class FollowParams {
  final String userId;
  final int limit;
  final int offset;
  
  FollowParams({
    required this.userId,
    this.limit = 20,
    this.offset = 0,
  });
}

/// フォロー関係パラメータクラス
class FollowRelationParams {
  final String followerId;
  final String followedId;
  
  FollowRelationParams({
    required this.followerId,
    required this.followedId,
  });
}

/// フォロー操作を管理するNotifier
class FollowControllerNotifier extends StateNotifier<AsyncValue<void>> {
  final FollowRepository _repository;
  
  FollowControllerNotifier(this._repository) : super(const AsyncValue.data(null));
  
  /// ユーザーをフォロー
  Future<bool> followUser(String followerId, String followedId) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.followUser(followerId, followedId);
      state = const AsyncValue.data(null);
      return result;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }
  
  /// フォロー解除
  Future<bool> unfollowUser(String followerId, String followedId) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.unfollowUser(followerId, followedId);
      state = const AsyncValue.data(null);
      return result;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }
}

/// フォロー操作のプロバイダー
final followControllerProvider = StateNotifierProvider<FollowControllerNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(followRepositoryProvider);
  return FollowControllerNotifier(repository);
}); 