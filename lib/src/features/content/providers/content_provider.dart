import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import '../../../config/providers.dart';
import '../models/content_consumption_model.dart';
import '../repositories/content_repository.dart';

/// コンテンツリポジトリプロバイダ
final contentRepositoryProvider = riverpod.Provider<ContentRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ContentRepository(client);
});

/// ユーザーのコンテンツ消費履歴プロバイダ
final userContentConsumptionsProvider = FutureProvider.family<List<ContentConsumption>, UserContentParams>((ref, params) async {
  final repository = ref.watch(contentRepositoryProvider);
  return repository.getUserContentConsumptions(
    userId: params.userId,
    category: params.category,
    limit: params.limit,
    offset: params.offset,
  );
});

/// カテゴリ別消費数プロバイダ
final userContentCategoryCountsProvider = FutureProvider.family<Map<ContentCategory, int>, String>((ref, userId) async {
  final repository = ref.watch(contentRepositoryProvider);
  return repository.getUserContentCategoryCounts(userId);
});

/// 公開コンテンツプロバイダ
final publicContentConsumptionsProvider = FutureProvider.family<List<ContentConsumption>, PublicContentParams>((ref, params) async {
  final repository = ref.watch(contentRepositoryProvider);
  return repository.getPublicContentConsumptions(
    category: params.category,
    limit: params.limit,
    offset: params.offset,
    searchQuery: params.searchQuery,
  );
});

/// 人気コンテンツプロバイダ
final popularContentConsumptionsProvider = FutureProvider.family<List<ContentConsumption>, ContentCategoryParams>((ref, params) async {
  final repository = ref.watch(contentRepositoryProvider);
  return repository.getPopularContentConsumptions(
    category: params.category,
    limit: params.limit,
    offset: params.offset,
  );
});

/// 特定コンテンツプロバイダ
final contentConsumptionProvider = FutureProvider.family<ContentConsumption?, String>((ref, id) async {
  final repository = ref.watch(contentRepositoryProvider);
  return repository.getContentConsumptionById(id);
});

/// コンテンツ管理プロバイダー
class ContentProvider extends StateNotifier<AsyncValue<List<ContentConsumption>>> {
  final ContentRepository _repository;
  final String _userId;
  
  ContentProvider(this._repository, this._userId) : super(const AsyncValue.loading()) {
    loadUserContent();
  }
  
  /// ユーザーのコンテンツを読み込む
  Future<void> loadUserContent({ContentCategory? category}) async {
    state = const AsyncValue.loading();
    try {
      final contents = await _repository.getUserContentConsumptions(
        userId: _userId,
        category: category,
      );
      state = AsyncValue.data(contents);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  /// 新しいコンテンツを作成
  Future<ContentConsumption?> createContent(ContentConsumption content) async {
    try {
      final newContent = await _repository.createContentConsumption(content);
      if (newContent != null) {
        state = AsyncValue.data([newContent, ...state.value ?? []]);
      }
      return newContent;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }
  
  /// コンテンツを更新
  Future<bool> updateContent(ContentConsumption content) async {
    try {
      final success = await _repository.updateContentConsumption(content);
      if (success) {
        final currentContents = state.value ?? [];
        final index = currentContents.indexWhere((c) => c.id == content.id);
        
        if (index >= 0) {
          final updatedContents = [...currentContents];
          updatedContents[index] = content;
          state = AsyncValue.data(updatedContents);
        }
      }
      return success;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
  
  /// コンテンツを削除
  Future<bool> deleteContent(String id) async {
    try {
      final success = await _repository.deleteContentConsumption(id);
      if (success) {
        final currentContents = state.value ?? [];
        state = AsyncValue.data(currentContents.where((c) => c.id != id).toList());
      }
      return success;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
  
  /// YouTubeビデオを保存
  Future<ContentConsumption?> saveYouTubeVideo({
    required String videoId,
    required String title,
    required String thumbnailUrl,
    String? description,
    PrivacyLevel privacyLevel = PrivacyLevel.public,
  }) async {
    try {
      final content = await _repository.saveYouTubeContent(
        userId: _userId,
        videoId: videoId,
        title: title,
        thumbnailUrl: thumbnailUrl,
        description: description,
        privacyLevel: privacyLevel,
      );
      
      if (content != null) {
        state = AsyncValue.data([content, ...state.value ?? []]);
      }
      
      return content;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }
}

/// コンテンツプロバイダの状態
final contentProvider = StateNotifierProvider.autoDispose.family<ContentProvider, AsyncValue<List<ContentConsumption>>, String>((ref, userId) {
  final repository = ref.watch(contentRepositoryProvider);
  return ContentProvider(repository, userId);
});

/// ユーザーコンテンツのパラメータクラス
class UserContentParams {
  final String userId;
  final ContentCategory? category;
  final int limit;
  final int offset;
  
  UserContentParams({
    required this.userId,
    this.category,
    this.limit = 20,
    this.offset = 0,
  });
}

/// 公開コンテンツのパラメータクラス
class PublicContentParams {
  final ContentCategory? category;
  final int limit;
  final int offset;
  final String? searchQuery;
  
  PublicContentParams({
    this.category,
    this.limit = 20,
    this.offset = 0,
    this.searchQuery,
  });
}

/// コンテンツカテゴリパラメータクラス
class ContentCategoryParams {
  final ContentCategory? category;
  final int limit;
  final int offset;
  
  ContentCategoryParams({
    this.category,
    this.limit = 20,
    this.offset = 0,
  });
}
