import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/follow_model.dart';
import '../../auth/models/user_model.dart';
import '../../auth/repositories/user_repository.dart';

/// フォロー関係の管理を担当するリポジトリ
class FollowRepository {
  final SupabaseClient _client;
  final UserRepository _userRepository;
  final String _table = 'follows';
  
  FollowRepository(this._client, this._userRepository);
  
  /// あるユーザーがフォローしているユーザー一覧を取得
  Future<List<UserModel>> getFollowing(String userId, {int limit = 20, int offset = 0}) async {
    try {
      final data = await _client
          .from(_table)
          .select('followed_id')
          .eq('follower_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      if (data == null || data.isEmpty) {
        return [];
      }
      
      final followingIds = data.map<String>((item) => item['followed_id'] as String).toList();
      final users = <UserModel>[];
      
      // 各ユーザーの詳細情報を取得
      for (final id in followingIds) {
        final user = await _userRepository.getUserById(id);
        if (user != null) {
          users.add(user);
        }
      }
      
      return users;
    } catch (e) {
      log('フォロー中ユーザーの取得に失敗しました: $e');
      return [];
    }
  }
  
  /// あるユーザーのフォロワー一覧を取得
  Future<List<UserModel>> getFollowers(String userId, {int limit = 20, int offset = 0}) async {
    try {
      final data = await _client
          .from(_table)
          .select('follower_id')
          .eq('followed_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      if (data == null || data.isEmpty) {
        return [];
      }
      
      final followerIds = data.map<String>((item) => item['follower_id'] as String).toList();
      final users = <UserModel>[];
      
      // 各ユーザーの詳細情報を取得
      for (final id in followerIds) {
        final user = await _userRepository.getUserById(id);
        if (user != null) {
          users.add(user);
        }
      }
      
      return users;
    } catch (e) {
      log('フォロワーの取得に失敗しました: $e');
      return [];
    }
  }
  
  /// フォロワー数を取得
  Future<int> getFollowerCount(String userId) async {
    try {
      final response = await _client
          .from(_table)
          .select('*', FetchOptions(count: CountOption.exact))
          .eq('followed_id', userId)
          .execute();
      
      return response.count ?? 0;
    } catch (e) {
      log('フォロワー数の取得に失敗しました: $e');
      return 0;
    }
  }
  
  /// フォロー数を取得
  Future<int> getFollowingCount(String userId) async {
    try {
      final response = await _client
          .from(_table)
          .select('*', FetchOptions(count: CountOption.exact))
          .eq('follower_id', userId)
          .execute();
      
      return response.count ?? 0;
    } catch (e) {
      log('フォロー数の取得に失敗しました: $e');
      return 0;
    }
  }
  
  /// フォロー関係をチェック
  Future<bool> isFollowing(String followerId, String followedId) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('follower_id', followerId)
          .eq('followed_id', followedId)
          .maybeSingle();
      
      return data != null;
    } catch (e) {
      log('フォロー関係のチェックに失敗しました: $e');
      return false;
    }
  }
  
  /// ユーザーをフォロー
  Future<bool> followUser(String followerId, String followedId) async {
    // 自分自身をフォローしないようにチェック
    if (followerId == followedId) {
      return false;
    }
    
    // 既にフォローしていないかチェック
    final isAlreadyFollowing = await isFollowing(followerId, followedId);
    if (isAlreadyFollowing) {
      return true; // 既にフォローしている場合は成功と見なす
    }
    
    try {
      final id = const Uuid().v4();
      final follow = FollowModel(
        id: id,
        followerId: followerId,
        followedId: followedId,
        createdAt: DateTime.now(),
      );
      
      await _client
          .from(_table)
          .insert(follow.toJson());
      
      // フォロワー数をインクリメント
      await _client.rpc('increment_follower_count', params: {'user_id': followedId});
      
      return true;
    } catch (e) {
      log('フォローに失敗しました: $e');
      return false;
    }
  }
  
  /// フォロー解除
  Future<bool> unfollowUser(String followerId, String followedId) async {
    try {
      await _client
          .from(_table)
          .delete()
          .eq('follower_id', followerId)
          .eq('followed_id', followedId);
      
      // フォロワー数をデクリメント
      await _client.rpc('decrement_follower_count', params: {'user_id': followedId});
      
      return true;
    } catch (e) {
      log('フォロー解除に失敗しました: $e');
      return false;
    }
  }
} 