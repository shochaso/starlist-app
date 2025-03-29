import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../supabase_provider.dart';

/// ユーザーリポジトリのプロバイダー
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return UserRepository(client);
});

/// 現在のユーザープロファイルのプロバイダー
final currentUserProfileProvider = FutureProvider<UserModel?>((ref) async {
  final userRepository = ref.watch(userRepositoryProvider);
  return await userRepository.getOrCreateCurrentUserProfile();
});

/// ユーザープロファイルのプロバイダー
final userProfileProvider = FutureProvider.family<UserModel?, String>((ref, userId) async {
  final userRepository = ref.watch(userRepositoryProvider);
  return await userRepository.getUserById(userId);
});

/// フォロワー数トップのユーザープロバイダー
final topUsersByFollowersProvider = FutureProvider<List<UserModel>>((ref) async {
  final userRepository = ref.watch(userRepositoryProvider);
  return await userRepository.getTopUsersByFollowers();
});

/// スタークリエイターのプロバイダー
final starCreatorsProvider = FutureProvider<List<UserModel>>((ref) async {
  final userRepository = ref.watch(userRepositoryProvider);
  return await userRepository.getStarCreators();
});

/// ユーザープロバイダークラス
class UserProvider extends StateNotifier<AsyncValue<UserModel?>> {
  final UserRepository _repository;

  UserProvider(this._repository) : super(const AsyncValue.loading()) {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.getOrCreateCurrentUserProfile();
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// ユーザープロファイルを更新
  Future<void> updateUserProfile(UserModel user) async {
    state = const AsyncValue.loading();
    try {
      final updatedUser = await _repository.updateUser(user);
      state = AsyncValue.data(updatedUser);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// プロフィール画像を更新
  Future<void> updateProfileImage(String userId, String imageUrl) async {
    state = const AsyncValue.loading();
    try {
      final user = state.value;
      if (user != null) {
        final updatedUser = user.copyWith(profileImageUrl: imageUrl);
        final result = await _repository.updateUser(updatedUser);
        state = AsyncValue.data(result);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// ユーザーの表示名を更新
  Future<void> updateDisplayName(String userId, String displayName) async {
    state = const AsyncValue.loading();
    try {
      final user = state.value;
      if (user != null) {
        final updatedUser = user.copyWith(displayName: displayName);
        final result = await _repository.updateUser(updatedUser);
        state = AsyncValue.data(result);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// ユーザーのバイオを更新
  Future<void> updateBio(String userId, String bio) async {
    state = const AsyncValue.loading();
    try {
      final user = state.value;
      if (user != null) {
        final updatedUser = user.copyWith(bio: bio);
        final result = await _repository.updateUser(updatedUser);
        state = AsyncValue.data(result);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// ユーザー名を更新
  Future<void> updateUsername(String userId, String username) async {
    state = const AsyncValue.loading();
    try {
      // ユーザー名の重複チェック
      final existingUser = await _repository.getUserByUsername(username);
      if (existingUser != null && existingUser.id != userId) {
        throw Exception('このユーザー名は既に使用されています');
      }

      final user = state.value;
      if (user != null) {
        final updatedUser = user.copyWith(username: username);
        final result = await _repository.updateUser(updatedUser);
        state = AsyncValue.data(result);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// ユーザー設定を更新
  Future<void> updatePreferences(UserPreferences preferences) async {
    state = const AsyncValue.loading();
    try {
      final user = state.value;
      if (user != null) {
        final updatedUser = user.copyWith(preferences: preferences);
        final result = await _repository.updateUser(updatedUser);
        state = AsyncValue.data(result);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

/// ユーザープロバイダーを作成するプロバイダー
final userProvider = StateNotifierProvider<UserProvider, AsyncValue<UserModel?>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserProvider(repository);
}); 