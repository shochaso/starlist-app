import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/content_consumption_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/app_exceptions.dart';

/// コンテンツリポジトリクラス
/// 
/// コンテンツデータの取得・保存を担当します。
class ContentRepository {
  /// APIクライアント
  final ApiClient _apiClient;

  /// コンストラクタ
  ContentRepository(this._apiClient);

  /// コンテンツフィードを取得
  Future<List<ContentConsumptionModel>> getContentFeed({
    required String userId,
    int limit = 20,
    int offset = 0,
    ContentType? contentType,
    bool includePrivate = false,
  }) async {
    try {
      final response = await _apiClient.get(
        '/content/feed',
        queryParameters: {
          'user_id': userId,
          'limit': limit,
          'offset': offset,
          if (contentType != null) 'content_type': contentType.toString().split('.').last,
          'include_private': includePrivate,
        },
      );

      final List<dynamic> data = response['data'];
      return data.map((item) => ContentConsumptionModel.fromJson(item)).toList();
    } catch (e) {
      throw DataFetchException('コンテンツフィードの取得に失敗しました: $e');
    }
  }

  /// 特定のユーザーのコンテンツを取得
  Future<List<ContentConsumptionModel>> getUserContent({
    required String userId,
    int limit = 20,
    int offset = 0,
    ContentType? contentType,
    bool includePrivate = false,
  }) async {
    try {
      final response = await _apiClient.get(
        '/content/user/$userId',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          if (contentType != null) 'content_type': contentType.toString().split('.').last,
          'include_private': includePrivate,
        },
      );

      final List<dynamic> data = response['data'];
      return data.map((item) => ContentConsumptionModel.fromJson(item)).toList();
    } catch (e) {
      throw DataFetchException('ユーザーコンテンツの取得に失敗しました: $e');
    }
  }

  /// カテゴリ別コンテンツを取得
  Future<List<ContentConsumptionModel>> getCategoryContent({
    required ContentType contentType,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _apiClient.get(
        '/content/category/${contentType.toString().split('.').last}',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      final List<dynamic> data = response['data'];
      return data.map((item) => ContentConsumptionModel.fromJson(item)).toList();
    } catch (e) {
      throw DataFetchException('カテゴリコンテンツの取得に失敗しました: $e');
    }
  }

  /// 人気コンテンツを取得
  Future<List<ContentConsumptionModel>> getTrendingContent({
    int limit = 20,
    int offset = 0,
    ContentType? contentType,
  }) async {
    try {
      final response = await _apiClient.get(
        '/content/trending',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          if (contentType != null) 'content_type': contentType.toString().split('.').last,
        },
      );

      final List<dynamic> data = response['data'];
      return data.map((item) => ContentConsumptionModel.fromJson(item)).toList();
    } catch (e) {
      throw DataFetchException('人気コンテンツの取得に失敗しました: $e');
    }
  }

  /// コンテンツを検索
  Future<List<ContentConsumptionModel>> searchContent({
    required String query,
    int limit = 20,
    int offset = 0,
    ContentType? contentType,
  }) async {
    try {
      final response = await _apiClient.get(
        '/content/search',
        queryParameters: {
          'query': query,
          'limit': limit,
          'offset': offset,
          if (contentType != null) 'content_type': contentType.toString().split('.').last,
        },
      );

      final List<dynamic> data = response['data'];
      return data.map((item) => ContentConsumptionModel.fromJson(item)).toList();
    } catch (e) {
      throw DataFetchException('コンテンツ検索に失敗しました: $e');
    }
  }

  /// コンテンツの詳細を取得
  Future<ContentConsumptionModel> getContentDetail(String contentId) async {
    try {
      final response = await _apiClient.get('/content/$contentId');
      return ContentConsumptionModel.fromJson(response['data']);
    } catch (e) {
      throw DataFetchException('コンテンツ詳細の取得に失敗しました: $e');
    }
  }

  /// コンテンツを作成
  Future<ContentConsumptionModel> createContent(ContentConsumptionModel content) async {
    try {
      final response = await _apiClient.post(
        '/content',
        data: content.toJson(),
      );
      return ContentConsumptionModel.fromJson(response['data']);
    } catch (e) {
      throw DataSaveException('コンテンツの作成に失敗しました: $e');
    }
  }

  /// コンテンツを更新
  Future<ContentConsumptionModel> updateContent(ContentConsumptionModel content) async {
    try {
      final response = await _apiClient.put(
        '/content/${content.id}',
        data: content.toJson(),
      );
      return ContentConsumptionModel.fromJson(response['data']);
    } catch (e) {
      throw DataSaveException('コンテンツの更新に失敗しました: $e');
    }
  }

  /// コンテンツを削除
  Future<void> deleteContent(String contentId) async {
    try {
      await _apiClient.delete('/content/$contentId');
    } catch (e) {
      throw DataDeleteException('コンテンツの削除に失敗しました: $e');
    }
  }

  /// コンテンツにいいねする
  Future<void> likeContent(String contentId) async {
    try {
      await _apiClient.post('/content/$contentId/like');
    } catch (e) {
      throw ActionFailedException('いいねに失敗しました: $e');
    }
  }

  /// コンテンツのいいねを取り消す
  Future<void> unlikeContent(String contentId) async {
    try {
      await _apiClient.delete('/content/$contentId/like');
    } catch (e) {
      throw ActionFailedException('いいね取り消しに失敗しました: $e');
    }
  }

  /// コンテンツにコメントする
  Future<void> commentOnContent(String contentId, String comment) async {
    try {
      await _apiClient.post(
        '/content/$contentId/comment',
        data: {'comment': comment},
      );
    } catch (e) {
      throw ActionFailedException('コメントに失敗しました: $e');
    }
  }

  /// コンテンツを共有する
  Future<void> shareContent(String contentId) async {
    try {
      await _apiClient.post('/content/$contentId/share');
    } catch (e) {
      throw ActionFailedException('共有に失敗しました: $e');
    }
  }
}

/// コンテンツリポジトリプロバイダー
final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ContentRepository(apiClient);
});
