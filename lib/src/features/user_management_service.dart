import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

abstract class UserManagementService {
  Future<Map<String, dynamic>> getUserProfile(String userId);
  Future<void> updateUserProfile(String userId, Map<String, dynamic> profileData);
  Future<void> deleteUserAccount(String userId, String reason);
  Future<void> suspendUser(String userId, String reason, DateTime? until);
  Future<void> unsuspendUser(String userId);
  Future<List<Map<String, dynamic>>> getUserActivity(String userId, {int limit = 50});
  Future<String> uploadProfileImage(String userId, File imageFile);
  Future<void> updateUserRole(String userId, String newRole);
  Future<Map<String, dynamic>> getUserStats(String userId);
  Future<void> verifyUser(String userId, String verificationType);
}

class UserManagementServiceImpl implements UserManagementService {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('''
            *,
            subscription:subscriptions!inner(
              status,
              plan:subscription_plans!inner(name, features)
            ),
            star_points:star_point_balances(balance),
            stats:user_stats(*)
          ''')
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      throw UserManagementException('ユーザープロフィールの取得に失敗しました: $e');
    }
  }

  @override
  Future<void> updateUserProfile(String userId, Map<String, dynamic> profileData) async {
    try {
      // プロフィール更新前の検証
      await _validateProfileData(profileData);

      profileData['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('profiles')
          .update(profileData)
          .eq('id', userId);

      // プロフィール更新履歴記録
      await _recordProfileUpdate(userId, profileData);

      // プロフィール完成度チェックとポイント付与
      await _checkProfileCompleteness(userId);
    } catch (e) {
      throw UserManagementException('プロフィールの更新に失敗しました: $e');
    }
  }

  @override
  Future<void> deleteUserAccount(String userId, String reason) async {
    try {
      // アカウント削除前の確認
      final userProfile = await getUserProfile(userId);
      
      // アクティブなサブスクリプションがある場合は先にキャンセル
      if (userProfile['subscription']?['status'] == 'active') {
        await _cancelActiveSubscription(userId);
      }

      // ユーザーデータの段階的削除
      await _softDeleteUserData(userId, reason);

      // 削除スケジュール設定（30日後に完全削除）
      await _scheduleAccountDeletion(userId);

      // アカウント削除通知
      await _notifyAccountDeletion(userId, reason);
    } catch (e) {
      throw UserManagementException('アカウントの削除に失敗しました: $e');
    }
  }

  @override
  Future<void> suspendUser(String userId, String reason, DateTime? until) async {
    try {
      await _supabase
          .from('profiles')
          .update({
            'status': 'suspended',
            'suspended_until': until?.toIso8601String(),
            'suspension_reason': reason,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      // 停止履歴記録
      await _recordUserSuspension(userId, reason, until);

      // 停止通知送信
      await _notifyUserSuspension(userId, reason, until);
    } catch (e) {
      throw UserManagementException('ユーザーの停止に失敗しました: $e');
    }
  }

  @override
  Future<void> unsuspendUser(String userId) async {
    try {
      await _supabase
          .from('profiles')
          .update({
            'status': 'active',
            'suspended_until': null,
            'suspension_reason': null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      // 停止解除履歴記録
      await _recordUserUnsuspension(userId);

      // 停止解除通知送信
      await _notifyUserUnsuspension(userId);
    } catch (e) {
      throw UserManagementException('ユーザーの停止解除に失敗しました: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserActivity(String userId, {int limit = 50}) async {
    try {
      final activities = <Map<String, dynamic>>[];

      // コンテンツ活動
      final contentActivity = await _supabase
          .from('contents')
          .select('id, title, created_at, type')
          .eq('creator_id', userId)
          .order('created_at', ascending: false)
          .limit(limit ~/ 3);

      activities.addAll(contentActivity.map((item) => {
        ...item,
        'activity_type': 'content_created',
      }));

      // インタラクション活動
      final interactionActivity = await _supabase
          .from('content_likes')
          .select('content_id, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit ~/ 3);

      activities.addAll(interactionActivity.map((item) => {
        ...item,
        'activity_type': 'content_liked',
      }));

      // 決済活動
      final paymentActivity = await _supabase
          .from('payments')
          .select('id, amount, status, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit ~/ 3);

      activities.addAll(paymentActivity.map((item) => {
        ...item,
        'activity_type': 'payment_made',
      }));

      // 時系列でソート
      activities.sort((a, b) => 
        DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at'])));

      return activities.take(limit).toList();
    } catch (e) {
      throw UserManagementException('ユーザー活動の取得に失敗しました: $e');
    }
  }

  @override
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      // 画像ファイルの検証
      await _validateImageFile(imageFile);

      final fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'profile_images/$fileName';

      await _supabase.storage
          .from('avatars')
          .upload(filePath, imageFile);

      final publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(filePath);

      // プロフィール画像URLを更新
      await _supabase
          .from('profiles')
          .update({
            'avatar_url': publicUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      return publicUrl;
    } catch (e) {
      throw UserManagementException('プロフィール画像のアップロードに失敗しました: $e');
    }
  }

  @override
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      // ロール変更権限チェック
      await _validateRoleChange(userId, newRole);

      await _supabase
          .from('profiles')
          .update({
            'role': newRole,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      // ロール変更履歴記録
      await _recordRoleChange(userId, newRole);

      // ロール変更通知
      await _notifyRoleChange(userId, newRole);
    } catch (e) {
      throw UserManagementException('ユーザーロールの更新に失敗しました: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final stats = await _supabase
          .from('user_stats')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (stats == null) {
        // 統計データを新規作成
        return await _generateUserStats(userId);
      }

      return stats;
    } catch (e) {
      throw UserManagementException('ユーザー統計の取得に失敗しました: $e');
    }
  }

  @override
  Future<void> verifyUser(String userId, String verificationType) async {
    try {
      await _supabase
          .from('user_verifications')
          .upsert({
            'user_id': userId,
            'verification_type': verificationType,
            'verified_at': DateTime.now().toIso8601String(),
            'status': 'verified',
          });

      // プロフィールに認証バッジを追加
      await _supabase
          .from('profiles')
          .update({
            'is_verified': true,
            'verification_badges': [verificationType],
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      // 認証完了でスターポイント付与
      await _awardVerificationPoints(userId, verificationType);
    } catch (e) {
      throw UserManagementException('ユーザー認証に失敗しました: $e');
    }
  }

  // プライベートメソッド
  Future<void> _validateProfileData(Map<String, dynamic> profileData) async {
    // プロフィールデータの検証ロジック
    if (profileData.containsKey('username')) {
      final username = profileData['username'];
      if (username.length < 3 || username.length > 20) {
        throw UserManagementException('ユーザー名は3-20文字である必要があります');
      }
    }
  }

  Future<void> _recordProfileUpdate(String userId, Map<String, dynamic> changes) async {
    try {
      await _supabase
          .from('profile_update_history')
          .insert({
            'user_id': userId,
            'changes': changes,
            'updated_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      print('プロフィール更新履歴記録エラー: $e');
    }
  }

  Future<void> _checkProfileCompleteness(String userId) async {
    try {
      final profile = await _supabase
          .from('profiles')
          .select('username, bio, avatar_url, location')
          .eq('id', userId)
          .single();

      int completeness = 0;
      if (profile['username']?.isNotEmpty == true) completeness += 25;
      if (profile['bio']?.isNotEmpty == true) completeness += 25;
      if (profile['avatar_url']?.isNotEmpty == true) completeness += 25;
      if (profile['location']?.isNotEmpty == true) completeness += 25;

      if (completeness == 100) {
        // プロフィール完成でスターポイント付与
        await _supabase.rpc('add_star_points', params: {
          'user_id': userId,
          'points': 100,
          'transaction_type': 'profile_complete',
          'description': 'プロフィール完成報酬',
        });
      }
    } catch (e) {
      print('プロフィール完成度チェックエラー: $e');
    }
  }

  Future<void> _cancelActiveSubscription(String userId) async {
    // アクティブなサブスクリプションをキャンセル
    await _supabase
        .from('subscriptions')
        .update({
          'status': 'cancelled',
          'cancelled_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', userId)
        .eq('status', 'active');
  }

  Future<void> _softDeleteUserData(String userId, String reason) async {
    // ソフト削除（データを匿名化）
    await _supabase
        .from('profiles')
        .update({
          'status': 'deleted',
          'deletion_reason': reason,
          'deleted_at': DateTime.now().toIso8601String(),
          'username': 'deleted_user',
          'email': null,
          'bio': null,
        })
        .eq('id', userId);
  }

  Future<void> _scheduleAccountDeletion(String userId) async {
    final deletionDate = DateTime.now().add(const Duration(days: 30));
    
    await _supabase
        .from('scheduled_deletions')
        .insert({
          'user_id': userId,
          'scheduled_for': deletionDate.toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
        });
  }

  Future<void> _notifyAccountDeletion(String userId, String reason) async {
    // アカウント削除通知の送信
    print('アカウント削除通知送信: $userId, 理由: $reason');
  }

  Future<void> _recordUserSuspension(String userId, String reason, DateTime? until) async {
    await _supabase
        .from('user_suspension_history')
        .insert({
          'user_id': userId,
          'reason': reason,
          'suspended_until': until?.toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
        });
  }

  Future<void> _notifyUserSuspension(String userId, String reason, DateTime? until) async {
    print('ユーザー停止通知: $userId, 理由: $reason, 期限: $until');
  }

  Future<void> _recordUserUnsuspension(String userId) async {
    await _supabase
        .from('user_suspension_history')
        .insert({
          'user_id': userId,
          'action': 'unsuspended',
          'created_at': DateTime.now().toIso8601String(),
        });
  }

  Future<void> _notifyUserUnsuspension(String userId) async {
    print('ユーザー停止解除通知: $userId');
  }

  Future<void> _validateImageFile(File imageFile) async {
    final fileSize = await imageFile.length();
    if (fileSize > 5 * 1024 * 1024) { // 5MB制限
      throw UserManagementException('画像ファイルは5MB以下である必要があります');
    }
  }

  Future<void> _validateRoleChange(String userId, String newRole) async {
    final validRoles = ['user', 'star', 'moderator', 'admin'];
    if (!validRoles.contains(newRole)) {
      throw UserManagementException('無効なロールです: $newRole');
    }
  }

  Future<void> _recordRoleChange(String userId, String newRole) async {
    await _supabase
        .from('role_change_history')
        .insert({
          'user_id': userId,
          'new_role': newRole,
          'changed_at': DateTime.now().toIso8601String(),
        });
  }

  Future<void> _notifyRoleChange(String userId, String newRole) async {
    print('ロール変更通知: $userId -> $newRole');
  }

  Future<Map<String, dynamic>> _generateUserStats(String userId) async {
    // ユーザー統計データを生成
    final contentCount = await _supabase
        .from('contents')
        .select('id')
        .eq('creator_id', userId)
        .count();

    final likesReceived = await _supabase.rpc('get_user_likes_received', params: {
      'user_id': userId,
    });

    final stats = {
      'user_id': userId,
      'content_count': contentCount,
      'likes_received': likesReceived,
      'followers_count': 0,
      'following_count': 0,
      'created_at': DateTime.now().toIso8601String(),
    };

    await _supabase
        .from('user_stats')
        .insert(stats);

    return stats;
  }

  Future<void> _awardVerificationPoints(String userId, String verificationType) async {
    final points = verificationType == 'identity' ? 500 : 100;
    
    await _supabase.rpc('add_star_points', params: {
      'user_id': userId,
      'points': points,
      'transaction_type': 'verification_complete',
      'description': '認証完了報酬 ($verificationType)',
    });
  }
}

class UserManagementException implements Exception {
  final String message;
  UserManagementException(this.message);
  
  @override
  String toString() => 'UserManagementException: $message';
}

final userManagementServiceProvider = Provider<UserManagementService>((ref) {
  return UserManagementServiceImpl();
});
