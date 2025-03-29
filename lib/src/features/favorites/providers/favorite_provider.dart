import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/favorite_repository.dart';
import '../models/favorite_item_model.dart';
import '../../../features/auth/supabase_provider.dart';

/// お気に入りリポジトリプロバイダー
final favoriteRepositoryProvider = riverpod.Provider<FavoriteRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return FavoriteRepository(client);
});

/// 現在のユーザーのお気に入りプロバイダー
final userFavoritesProvider = FutureProvider.autoDispose<List<FavoriteItemModel>>((ref) async {
  final repository = ref.watch(favoriteRepositoryProvider);
  final currentUser = Supabase.instance.client.auth.currentUser;
  
  if (currentUser == null) {
    return [];
  }
  
  return await repository.getFavoritesByUserId(currentUser.id);
});

/// 特定のユーザーのお気に入りプロバイダー
final userFavoritesByIdProvider = FutureProvider.family<List<FavoriteItemModel>, String>((ref, userId) async {
  final repository = ref.watch(favoriteRepositoryProvider);
  return await repository.getFavoritesByUserId(userId);
});

/// 特定のタイプのお気に入りプロバイダー
final favoritesByTypeProvider = FutureProvider.family<List<FavoriteItemModel>, FavoriteTypeParams>((ref, params) async {
  final repository = ref.watch(favoriteRepositoryProvider);
  return await repository.getFavoritesByType(params.userId, params.itemType);
});

/// お気に入りの状態管理クラス
class FavoriteNotifier extends StateNotifier<AsyncValue<List<FavoriteItemModel>>> {
  final FavoriteRepository _repository;
  final String _userId;

  FavoriteNotifier(this._repository, this._userId) : super(const AsyncValue.loading()) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    state = const AsyncValue.loading();
    try {
      final favorites = await _repository.getFavoritesByUserId(_userId);
      state = AsyncValue.data(favorites);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// お気に入りを追加
  Future<void> addFavorite(FavoriteItemModel favorite) async {
    try {
      final newFavorite = await _repository.addFavorite(favorite);
      if (newFavorite != null) {
        state = AsyncValue.data([newFavorite, ...state.value ?? []]);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// お気に入りを削除
  Future<void> removeFavorite(String favoriteId) async {
    try {
      final success = await _repository.removeFavorite(favoriteId);
      if (success) {
        state = AsyncValue.data(
          state.value?.where((favorite) => favorite.id != favoriteId).toList() ?? []
        );
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// アイテムがお気に入りかどうかを確認
  bool isFavorite(String itemType, String itemId) {
    return state.value?.any(
      (favorite) => favorite.itemType == itemType && favorite.itemId == itemId
    ) ?? false;
  }

  /// お気に入りを更新
  Future<void> updateFavorite(FavoriteItemModel favorite) async {
    try {
      final updatedFavorite = await _repository.updateFavorite(favorite);
      if (updatedFavorite != null) {
        state = AsyncValue.data(
          state.value?.map((item) => item.id == favorite.id ? updatedFavorite : item).toList() ?? []
        );
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// お気に入りをリロード
  Future<void> reloadFavorites() async {
    await _loadFavorites();
  }
}

/// お気に入りノティファイアのプロバイダー
final favoriteNotifierProvider = StateNotifierProvider.family<FavoriteNotifier, AsyncValue<List<FavoriteItemModel>>, String>((ref, userId) {
  final repository = ref.watch(favoriteRepositoryProvider);
  return FavoriteNotifier(repository, userId);
});

/// お気に入りタイプのパラメータクラス
class FavoriteTypeParams {
  final String userId;
  final String itemType;

  FavoriteTypeParams({required this.userId, required this.itemType});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteTypeParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          itemType == other.itemType;

  @override
  int get hashCode => userId.hashCode ^ itemType.hashCode;
} 