import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/star_profile_model.dart';

class StarRepository {
  final SupabaseClient _client;
  final String _table = 'star_profiles';
  
  StarRepository(this._client);
  
  /// スタープロフィールの取得
  Future<StarProfileModel?> getStarProfile(String userId) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .single();
      
      return StarProfileModel.fromJson(data);
    } catch (e) {
      log('スタープロフィールの取得に失敗しました: $e');
      return null;
    }
  }
  
  /// カテゴリー別のスタープロフィール一覧の取得
  Future<List<StarProfileModel>> getStarsByCategory({
    StarCategory? category,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = _client
          .from(_table)
          .select();
      
      if (category != null) {
        query = query.eq('category', category.toString().split('.').last);
      }
      
      final data = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      return List<Map<String, dynamic>>.from(data)
          .map((item) => StarProfileModel.fromJson(item))
          .toList();
    } catch (e) {
      log('スタープロフィール一覧の取得に失敗しました: $e');
      return [];
    }
  }
  
  /// スタープロフィールの作成
  Future<StarProfileModel?> createStarProfile(StarProfileModel profile) async {
    try {
      final newId = const Uuid().v4();
      final now = DateTime.now();
      
      final newProfile = StarProfileModel(
        id: newId,
        userId: profile.userId,
        category: profile.category,
        description: profile.description,
        paidFollowerCount: profile.paidFollowerCount,
        starRank: profile.starRank,
        revenueShareRate: profile.revenueShareRate,
        verified: profile.verified,
        createdAt: now,
        updatedAt: now,
      );
      
      await _client
          .from(_table)
          .insert(newProfile.toJson());
      
      return newProfile;
    } catch (e) {
      log('スタープロフィールの作成に失敗しました: $e');
      return null;
    }
  }
  
  /// スタープロフィールの更新
  Future<bool> updateStarProfile(StarProfileModel profile) async {
    try {
      final now = DateTime.now();
      
      final updatedProfile = profile.toJson();
      updatedProfile['updated_at'] = now.toIso8601String();
      
      await _client
          .from(_table)
          .update(updatedProfile)
          .eq('id', profile.id);
      
      return true;
    } catch (e) {
      log('スタープロフィールの更新に失敗しました: $e');
      return false;
    }
  }
  
  /// スタープロフィールの削除
  Future<bool> deleteStarProfile(String id) async {
    try {
      await _client
          .from(_table)
          .delete()
          .eq('id', id);
      
      return true;
    } catch (e) {
      log('スタープロフィールの削除に失敗しました: $e');
      return false;
    }
  }
  
  /// 人気のスターの取得（有料フォロワー数順）
  Future<List<StarProfileModel>> getPopularStars({
    int limit = 10,
  }) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .order('paid_follower_count', ascending: false)
          .limit(limit);
      
      return List<Map<String, dynamic>>.from(data)
          .map((item) => StarProfileModel.fromJson(item))
          .toList();
    } catch (e) {
      log('人気スター一覧の取得に失敗しました: $e');
      return [];
    }
  }
} 