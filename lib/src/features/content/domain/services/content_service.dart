import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/content_repository.dart';
import '../../../../shared/models/content_consumption_model.dart';
import '../../../../core/errors/app_exceptions.dart';

/// コンテンツサービスクラス
/// 
/// コンテンツ関連のビジネスロジックを担当します。
class ContentService {
  /// コンテンツリポジトリ
  final ContentRepository _contentRepository;

  /// コンストラクタ
  ContentService(this._contentRepository);

  /// コンテンツフィードを取得
  Future<List<ContentConsumptionModel>> getContentFeed({
    required String userId,
    int limit = 20,
    int offset = 0,
    ContentType? contentType,
    bool includePrivate = false,
  }) async {
    try {
      return await _contentRepository.getContentFeed(
        userId: userId,
        limit: limit,
        offset: offset,
        contentType: contentType,
        includePrivate: includePrivate,
      );
    } catch (e) {
      throw ServiceException('コンテンツフィードの取得に失敗しました: $e');
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
      return await _contentRepository.getUserContent(
        userId: userId,
        limit: limit,
        offset: offset,
        contentType: contentType,
        includePrivate: includePrivate,
      );
    } catch (e) {
      throw ServiceException('ユーザーコンテンツの取得に失敗しました: $e');
    }
  }

  /// カテゴリ別コンテンツを取得
  Future<List<ContentConsumptionModel>> getCategoryContent({
    required ContentType contentType,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      return await _contentRepository.getCategoryContent(
        contentType: contentType,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      throw ServiceException('カテゴリコンテンツの取得に失敗しました: $e');
    }
  }

  /// 人気コンテンツを取得
  Future<List<ContentConsumptionModel>> getTrendingContent({
    int limit = 20,
    int offset = 0,
    ContentType? contentType,
  }) async {
    try {
      return await _contentRepository.getTrendingContent(
        limit: limit,
        offset: offset,
        contentType: contentType,
      );
    } catch (e) {
      throw ServiceException('人気コンテンツの取得に失敗しました: $e');
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
      // 検索クエリが空の場合は空のリストを返す
      if (query.trim().isEmpty) {
        return [];
      }
      
      return await _contentRepository.searchContent(
        query: query,
        limit: limit,
        offset: offset,
        contentType: contentType,
      );
    } catch (e) {
      throw ServiceException('コンテンツ検索に失敗しました: $e');
    }
  }

  /// コンテンツの詳細を取得
  Future<ContentConsumptionModel> getContentDetail(String contentId) async {
    try {
      return await _contentRepository.getContentDetail(contentId);
    } catch (e) {
      throw ServiceException('コンテンツ詳細の取得に失敗しました: $e');
    }
  }

  /// コンテンツを作成
  Future<ContentConsumptionModel> createContent(ContentConsumptionModel content) async {
    try {
      // バリデーション
      _validateContent(content);
      
      return await _contentRepository.createContent(content);
    } catch (e) {
      throw ServiceException('コンテンツの作成に失敗しました: $e');
    }
  }

  /// コンテンツを更新
  Future<ContentConsumptionModel> updateContent(ContentConsumptionModel content) async {
    try {
      // バリデーション
      _validateContent(content);
      
      return await _contentRepository.updateContent(content);
    } catch (e) {
      throw ServiceException('コンテンツの更新に失敗しました: $e');
    }
  }

  /// コンテンツを削除
  Future<void> deleteContent(String contentId) async {
    try {
      await _contentRepository.deleteContent(contentId);
    } catch (e) {
      throw ServiceException('コンテンツの削除に失敗しました: $e');
    }
  }

  /// コンテンツにいいねする
  Future<void> likeContent(String contentId) async {
    try {
      await _contentRepository.likeContent(contentId);
    } catch (e) {
      throw ServiceException('いいねに失敗しました: $e');
    }
  }

  /// コンテンツのいいねを取り消す
  Future<void> unlikeContent(String contentId) async {
    try {
      await _contentRepository.unlikeContent(contentId);
    } catch (e) {
      throw ServiceException('いいね取り消しに失敗しました: $e');
    }
  }

  /// コンテンツにコメントする
  Future<void> commentOnContent(String contentId, String comment) async {
    try {
      // コメントが空でないことを確認
      if (comment.trim().isEmpty) {
        throw ValidationException('コメントを入力してください');
      }
      
      await _contentRepository.commentOnContent(contentId, comment);
    } catch (e) {
      throw ServiceException('コメントに失敗しました: $e');
    }
  }

  /// コンテンツを共有する
  Future<void> shareContent(String contentId) async {
    try {
      await _contentRepository.shareContent(contentId);
    } catch (e) {
      throw ServiceException('共有に失敗しました: $e');
    }
  }

  /// コンテンツのバリデーション
  void _validateContent(ContentConsumptionModel content) {
    if (content.title.trim().isEmpty) {
      throw ValidationException('タイトルを入力してください');
    }
    
    if (content.contentType == null) {
      throw ValidationException('コンテンツタイプを選択してください');
    }
    
    if (content.userId == null || content.userId!.trim().isEmpty) {
      throw ValidationException('ユーザーIDが無効です');
    }
  }

  /// コンテンツタイプからカテゴリ名を取得
  String getContentTypeName(ContentType type) {
    switch (type) {
      case ContentType.youtube:
        return 'YouTube';
      case ContentType.spotify:
        return '音楽';
      case ContentType.netflix:
        return '映像';
      case ContentType.book:
        return '書籍';
      case ContentType.shopping:
        return 'ショッピング';
      case ContentType.app:
        return 'アプリ';
      case ContentType.food:
        return '食事';
      default:
        return 'その他';
    }
  }

  /// コンテンツタイプからアイコンを取得
  IconData getContentTypeIcon(ContentType type) {
    switch (type) {
      case ContentType.youtube:
        return Icons.play_circle_filled;
      case ContentType.spotify:
        return Icons.music_note;
      case ContentType.netflix:
        return Icons.movie;
      case ContentType.book:
        return Icons.book;
      case ContentType.shopping:
        return Icons.shopping_bag;
      case ContentType.app:
        return Icons.apps;
      case ContentType.food:
        return Icons.restaurant;
      default:
        return Icons.category;
    }
  }

  /// コンテンツタイプから色を取得
  Color getContentTypeColor(ContentType type) {
    switch (type) {
      case ContentType.youtube:
        return Colors.red;
      case ContentType.spotify:
        return Colors.green;
      case ContentType.netflix:
        return Colors.purple;
      case ContentType.book:
        return Colors.blue;
      case ContentType.shopping:
        return Colors.orange;
      case ContentType.app:
        return Colors.teal;
      case ContentType.food:
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}

/// コンテンツサービスプロバイダー
final contentServiceProvider = Provider<ContentService>((ref) {
  final contentRepository = ref.watch(contentRepositoryProvider);
  return ContentService(contentRepository);
});
