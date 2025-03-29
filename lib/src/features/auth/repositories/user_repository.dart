import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

/// ユーザーデータの取得と管理を担当するリポジトリクラス
class UserRepository {
  final SupabaseClient _client;
  final String _tableName = 'users'; // Supabaseのテーブル名

  UserRepository(this._client);

  /// ユーザーIDに基づいてユーザー情報を取得
  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', userId)
          .single();
      
      if (response != null) {
        return UserModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  /// ユーザー名に基づいてユーザー情報を取得
  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('username', username)
          .single();
      
      if (response != null) {
        return UserModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error getting user by username: $e');
      return null;
    }
  }

  /// 新しいユーザーを作成
  Future<UserModel?> createUser(UserModel user) async {
    try {
      final response = await _client
          .from(_tableName)
          .insert(user.toJson())
          .select()
          .single();
      
      if (response != null) {
        return UserModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  /// ユーザー情報を更新
  Future<UserModel?> updateUser(UserModel user) async {
    try {
      final response = await _client
          .from(_tableName)
          .update(user.toJson())
          .eq('id', user.id)
          .select()
          .single();
      
      if (response != null) {
        return UserModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error updating user: $e');
      return null;
    }
  }

  /// ユーザー情報を削除
  Future<bool> deleteUser(String userId) async {
    try {
      await _client
          .from(_tableName)
          .delete()
          .eq('id', userId);
      
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  /// スタークリエイターのリストを取得
  Future<List<UserModel>> getStarCreators({int limit = 10, int offset = 0}) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('is_star_creator', true)
          .order('follower_count', ascending: false)
          .range(offset, offset + limit - 1);
      
      if (response != null && response is List) {
        return response.map((json) => UserModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting star creators: $e');
      return [];
    }
  }

  /// フォロワー数でランク付けされたトップユーザーを取得
  Future<List<UserModel>> getTopUsersByFollowers({int limit = 10}) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .order('follower_count', ascending: false)
          .limit(limit);
      
      if (response != null && response is List) {
        return response.map((json) => UserModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting top users by followers: $e');
      return [];
    }
  }

  /// 認証ユーザーのプロファイルを取得または作成
  Future<UserModel?> getOrCreateCurrentUserProfile() async {
    try {
      final authUser = _client.auth.currentUser;
      if (authUser == null) return null;

      // 既存のプロファイルを探す
      final existingUser = await getUserById(authUser.id);
      if (existingUser != null) return existingUser;

      // 新しいプロファイルを作成
      final newUser = UserModel(
        id: authUser.id,
        email: authUser.email ?? '',
        username: authUser.userMetadata?['username'] ?? '',
        displayName: authUser.userMetadata?['display_name'] ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await createUser(newUser);
    } catch (e) {
      print('Error getting or creating user profile: $e');
      return null;
    }
  }
} 