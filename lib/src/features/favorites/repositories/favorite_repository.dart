import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/favorite_item_model.dart';

/// お気に入りアイテムのCRUD操作を担当するリポジトリクラス
class FavoriteRepository {
  final SupabaseClient _client;
  final String _tableName = 'favorite_items'; // Supabaseのテーブル名

  FavoriteRepository(this._client);

  /// 特定のユーザーのお気に入りアイテムを取得
  Future<List<FavoriteItemModel>> getFavoritesByUserId(String userId, {int limit = 20, int offset = 0}) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      if (response != null && response is List) {
        return response.map((json) => FavoriteItemModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting favorites by user ID: $e');
      return [];
    }
  }

  /// お気に入りアイテムをIDで取得
  Future<FavoriteItemModel?> getFavoriteById(String favoriteId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', favoriteId)
          .single();
      
      if (response != null) {
        return FavoriteItemModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error getting favorite by ID: $e');
      return null;
    }
  }

  /// 特定のユーザーが特定のアイテムをお気に入りに追加しているか確認
  Future<bool> isFavorite(String userId, String itemType, String itemId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select('id')
          .eq('user_id', userId)
          .eq('item_type', itemType)
          .eq('item_id', itemId)
          .limit(1);
      
      return response != null && response is List && response.isNotEmpty;
    } catch (e) {
      print('Error checking if item is favorite: $e');
      return false;
    }
  }

  /// 新しいお気に入りアイテムを追加
  Future<FavoriteItemModel?> addFavorite(FavoriteItemModel favorite) async {
    try {
      final response = await _client
          .from(_tableName)
          .insert(favorite.toJson())
          .select()
          .single();
      
      if (response != null) {
        return FavoriteItemModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error adding favorite: $e');
      return null;
    }
  }

  /// お気に入りアイテムを更新
  Future<FavoriteItemModel?> updateFavorite(FavoriteItemModel favorite) async {
    try {
      final response = await _client
          .from(_tableName)
          .update(favorite.toJson())
          .eq('id', favorite.id)
          .select()
          .single();
      
      if (response != null) {
        return FavoriteItemModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error updating favorite: $e');
      return null;
    }
  }

  /// お気に入りアイテムを削除
  Future<bool> removeFavorite(String favoriteId) async {
    try {
      await _client
          .from(_tableName)
          .delete()
          .eq('id', favoriteId);
      
      return true;
    } catch (e) {
      print('Error removing favorite: $e');
      return false;
    }
  }

  /// ユーザーのお気に入りを特定のアイテムから削除
  Future<bool> removeFavoriteByItem(String userId, String itemType, String itemId) async {
    try {
      await _client
          .from(_tableName)
          .delete()
          .eq('user_id', userId)
          .eq('item_type', itemType)
          .eq('item_id', itemId);
      
      return true;
    } catch (e) {
      print('Error removing favorite by item: $e');
      return false;
    }
  }

  /// 特定のタイプのお気に入りを取得（YouTubeなど）
  Future<List<FavoriteItemModel>> getFavoritesByType(String userId, String itemType, {int limit = 20, int offset = 0}) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('item_type', itemType)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      if (response != null && response is List) {
        return response.map((json) => FavoriteItemModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting favorites by type: $e');
      return [];
    }
  }
} 