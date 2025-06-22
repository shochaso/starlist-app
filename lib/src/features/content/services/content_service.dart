import "../models/content_model.dart";
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

abstract class ContentService {
  Future<List<ContentModel>> getContents({int page = 1, int limit = 20});
  Future<ContentModel> getContentById(String id);
  Future<ContentModel> createContent(ContentModel content);
  Future<ContentModel> updateContent(String id, ContentModel content);
  Future<void> deleteContent(String id);
  Future<void> likeContent(String id, String userId);
  Future<void> unlikeContent(String id, String userId);
  Future<void> shareContent(String id, String userId);
  Future<String> uploadContentFile(File file, String contentType);
  Future<List<ContentModel>> searchContents(String query, {int page = 1, int limit = 20});
  Future<List<ContentModel>> getRecommendedContents(String userId, {int limit = 10});
  Future<void> reportContent(String contentId, String userId, String reason);
}

class ContentServiceImpl implements ContentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<ContentModel>> getContents({int page = 1, int limit = 20}) async {
    try {
      final offset = (page - 1) * limit;
      
      final response = await _supabase
          .from('contents')
          .select('''
            *,
            creator:profiles!creator_id(id, username, avatar_url),
            likes_count,
            comments_count,
            shares_count
          ''')
          .eq('status', 'published')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map<ContentModel>((json) => ContentModel.fromJson(json)).toList();
    } catch (e) {
      throw ContentException('コンテンツの取得に失敗しました: $e');
    }
  }

  @override
  Future<ContentModel> getContentById(String id) async {
    try {
      final response = await _supabase
          .from('contents')
          .select('''
            *,
            creator:profiles!creator_id(id, username, avatar_url),
            likes_count,
            comments_count,
            shares_count
          ''')
          .eq('id', id)
          .single();

      // 閲覧数を増加
      await _incrementViewCount(id);

      return ContentModel.fromJson(response);
    } catch (e) {
      throw ContentException('コンテンツの取得に失敗しました: $e');
    }
  }

  @override
  Future<ContentModel> createContent(ContentModel content) async {
    try {
      final contentData = content.toJson();
      contentData['created_at'] = DateTime.now().toIso8601String();
      contentData['updated_at'] = DateTime.now().toIso8601String();
      contentData['status'] = 'draft'; // デフォルトは下書き

      final response = await _supabase
          .from('contents')
          .insert(contentData)
          .select('''
            *,
            creator:profiles!creator_id(id, username, avatar_url)
          ''')
          .single();

      // コンテンツ作成でスターポイント付与
      await _awardContentCreationPoints(content.creatorId);

      return ContentModel.fromJson(response);
    } catch (e) {
      throw ContentException('コンテンツの作成に失敗しました: $e');
    }
  }

  @override
  Future<ContentModel> updateContent(String id, ContentModel content) async {
    try {
      final contentData = content.toJson();
      contentData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('contents')
          .update(contentData)
          .eq('id', id)
          .select('''
            *,
            creator:profiles!creator_id(id, username, avatar_url)
          ''')
          .single();

      return ContentModel.fromJson(response);
    } catch (e) {
      throw ContentException('コンテンツの更新に失敗しました: $e');
    }
  }

  @override
  Future<void> deleteContent(String id) async {
    try {
      // 関連する画像・動画ファイルも削除
      await _deleteContentFiles(id);

      await _supabase
          .from('contents')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw ContentException('コンテンツの削除に失敗しました: $e');
    }
  }

  @override
  Future<void> likeContent(String id, String userId) async {
    try {
      // いいねレコードを作成
      await _supabase
          .from('content_likes')
          .insert({
            'content_id': id,
            'user_id': userId,
            'created_at': DateTime.now().toIso8601String(),
          });

      // いいね数を更新
      await _supabase.rpc('increment_content_likes', params: {
        'content_id': id,
      });

      // コンテンツ作成者にスターポイント付与
      await _awardLikePoints(id);
    } catch (e) {
      if (e.toString().contains('duplicate key')) {
        throw ContentException('既にいいねしています');
      }
      throw ContentException('いいねに失敗しました: $e');
    }
  }

  @override
  Future<void> unlikeContent(String id, String userId) async {
    try {
      await _supabase
          .from('content_likes')
          .delete()
          .eq('content_id', id)
          .eq('user_id', userId);

      // いいね数を減少
      await _supabase.rpc('decrement_content_likes', params: {
        'content_id': id,
      });
    } catch (e) {
      throw ContentException('いいね取り消しに失敗しました: $e');
    }
  }

  @override
  Future<void> shareContent(String id, String userId) async {
    try {
      // シェアレコードを作成
      await _supabase
          .from('content_shares')
          .insert({
            'content_id': id,
            'user_id': userId,
            'created_at': DateTime.now().toIso8601String(),
          });

      // シェア数を更新
      await _supabase.rpc('increment_content_shares', params: {
        'content_id': id,
      });

      // シェア者にスターポイント付与
      await _awardSharePoints(userId);
    } catch (e) {
      throw ContentException('シェアに失敗しました: $e');
    }
  }

  @override
  Future<String> uploadContentFile(File file, String contentType) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final filePath = 'content_files/$contentType/$fileName';

      await _supabase.storage
          .from('contents')
          .upload(filePath, file);

      final publicUrl = _supabase.storage
          .from('contents')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw ContentException('ファイルのアップロードに失敗しました: $e');
    }
  }

  @override
  Future<List<ContentModel>> searchContents(String query, {int page = 1, int limit = 20}) async {
    try {
      final offset = (page - 1) * limit;

      final response = await _supabase
          .from('contents')
          .select('''
            *,
            creator:profiles!creator_id(id, username, avatar_url),
            likes_count,
            comments_count,
            shares_count
          ''')
          .or('title.ilike.%$query%,description.ilike.%$query%,tags.cs.{$query}')
          .eq('status', 'published')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map<ContentModel>((json) => ContentModel.fromJson(json)).toList();
    } catch (e) {
      throw ContentException('コンテンツの検索に失敗しました: $e');
    }
  }

  @override
  Future<List<ContentModel>> getRecommendedContents(String userId, {int limit = 10}) async {
    try {
      // ユーザーの興味・行動履歴に基づくレコメンデーション
      final response = await _supabase.rpc('get_recommended_contents', params: {
        'user_id': userId,
        'limit_count': limit,
      });

      return response.map<ContentModel>((json) => ContentModel.fromJson(json)).toList();
    } catch (e) {
      // フォールバック: 人気コンテンツを返す
      return await _getPopularContents(limit: limit);
    }
  }

  @override
  Future<void> reportContent(String contentId, String userId, String reason) async {
    try {
      await _supabase
          .from('content_reports')
          .insert({
            'content_id': contentId,
            'reporter_id': userId,
            'reason': reason,
            'status': 'pending',
            'created_at': DateTime.now().toIso8601String(),
          });

      // 自動モデレーション開始
      await _triggerAutoModeration(contentId);
    } catch (e) {
      throw ContentException('コンテンツの報告に失敗しました: $e');
    }
  }

  // プライベートメソッド
  Future<void> _incrementViewCount(String contentId) async {
    try {
      await _supabase.rpc('increment_content_views', params: {
        'content_id': contentId,
      });
    } catch (e) {
      // 閲覧数更新エラーは無視
      print('閲覧数更新エラー: $e');
    }
  }

  Future<void> _deleteContentFiles(String contentId) async {
    try {
      final content = await _supabase
          .from('contents')
          .select('media_urls')
          .eq('id', contentId)
          .single();

      final mediaUrls = content['media_urls'] as List<dynamic>?;
      if (mediaUrls != null) {
        for (final url in mediaUrls) {
          final fileName = Uri.parse(url).pathSegments.last;
          await _supabase.storage
              .from('contents')
              .remove(['content_files/$fileName']);
        }
      }
    } catch (e) {
      print('ファイル削除エラー: $e');
    }
  }

  Future<void> _awardContentCreationPoints(String userId) async {
    try {
      await _supabase.rpc('add_star_points', params: {
        'user_id': userId,
        'points': 50,
        'transaction_type': 'content_creation',
        'description': 'コンテンツ作成報酬',
      });
    } catch (e) {
      print('スターポイント付与エラー: $e');
    }
  }

  Future<void> _awardLikePoints(String contentId) async {
    try {
      final content = await _supabase
          .from('contents')
          .select('creator_id')
          .eq('id', contentId)
          .single();

      await _supabase.rpc('add_star_points', params: {
        'user_id': content['creator_id'],
        'points': 5,
        'transaction_type': 'content_like',
        'description': 'いいね獲得報酬',
      });
    } catch (e) {
      print('スターポイント付与エラー: $e');
    }
  }

  Future<void> _awardSharePoints(String userId) async {
    try {
      await _supabase.rpc('add_star_points', params: {
        'user_id': userId,
        'points': 10,
        'transaction_type': 'content_share',
        'description': 'コンテンツシェア報酬',
      });
    } catch (e) {
      print('スターポイント付与エラー: $e');
    }
  }

  Future<List<ContentModel>> _getPopularContents({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('contents')
          .select('''
            *,
            creator:profiles!creator_id(id, username, avatar_url),
            likes_count,
            comments_count,
            shares_count
          ''')
          .eq('status', 'published')
          .order('likes_count', ascending: false)
          .limit(limit);

      return response.map<ContentModel>((json) => ContentModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _triggerAutoModeration(String contentId) async {
    try {
      // 自動モデレーションロジック
      await _supabase.rpc('trigger_auto_moderation', params: {
        'content_id': contentId,
      });
    } catch (e) {
      print('自動モデレーションエラー: $e');
    }
  }
}

class ContentException implements Exception {
  final String message;
  ContentException(this.message);
  
  @override
  String toString() => 'ContentException: $message';
}

final contentServiceProvider = Provider<ContentService>((ref) {
  return ContentServiceImpl();
});
