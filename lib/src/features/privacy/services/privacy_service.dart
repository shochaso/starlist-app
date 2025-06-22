import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

abstract class PrivacyService {
  Future<Map<String, dynamic>> getPrivacySettings(String userId);
  Future<void> updatePrivacySettings(String userId, Map<String, dynamic> settings);
  Future<void> deleteUserData(String userId);
  Future<String> exportUserData(String userId);
  Future<void> updateConsent(String userId, String consentType, bool granted);
  Future<List<Map<String, dynamic>>> getDataProcessingActivities(String userId);
  Future<void> requestDataDeletion(String userId, String reason);
}

class PrivacyServiceImpl implements PrivacyService {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<Map<String, dynamic>> getPrivacySettings(String userId) async {
    try {
      final response = await _supabase
          .from('privacy_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        // デフォルトプライバシー設定を作成
        return await _createDefaultPrivacySettings(userId);
      }

      return response;
    } catch (e) {
      throw PrivacyException('プライバシー設定の取得に失敗しました: $e');
    }
  }

  @override
  Future<void> updatePrivacySettings(String userId, Map<String, dynamic> settings) async {
    try {
      settings['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('privacy_settings')
          .upsert({
            'user_id': userId,
            ...settings,
          });

      // プライバシー設定変更のログ記録
      await _logPrivacyChange(userId, 'settings_updated', settings);
    } catch (e) {
      throw PrivacyException('プライバシー設定の更新に失敗しました: $e');
    }
  }

  @override
  Future<void> deleteUserData(String userId) async {
    try {
      // データ削除の段階的実行
      await _deleteUserContent(userId);
      await _deleteUserInteractions(userId);
      await _deleteUserPayments(userId);
      await _deleteUserProfile(userId);
      await _deleteUserAuth(userId);

      // 削除完了のログ記録
      await _logPrivacyChange(userId, 'data_deleted', {'timestamp': DateTime.now().toIso8601String()});
    } catch (e) {
      throw PrivacyException('ユーザーデータの削除に失敗しました: $e');
    }
  }

  @override
  Future<String> exportUserData(String userId) async {
    try {
      final userData = <String, dynamic>{};

      // プロフィール情報
      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      userData['profile'] = profile;

      // コンテンツ
      final contents = await _supabase
          .from('contents')
          .select()
          .eq('creator_id', userId);
      userData['contents'] = contents;

      // 決済履歴
      final payments = await _supabase
          .from('payments')
          .select()
          .eq('user_id', userId);
      userData['payments'] = payments;

      // インタラクション履歴
      final interactions = await _getUserInteractions(userId);
      userData['interactions'] = interactions;

      // サブスクリプション履歴
      final subscriptions = await _supabase
          .from('subscription_history')
          .select()
          .eq('user_id', userId);
      userData['subscriptions'] = subscriptions;

      // プライバシー設定
      final privacySettings = await getPrivacySettings(userId);
      userData['privacy_settings'] = privacySettings;

      // JSON形式でエクスポート
      final exportData = json.encode(userData);
      
      // エクスポートファイルをストレージに保存
      final fileName = 'user_data_export_${userId}_${DateTime.now().millisecondsSinceEpoch}.json';
      await _supabase.storage
          .from('user_exports')
          .uploadBinary(fileName, utf8.encode(exportData));

      final downloadUrl = _supabase.storage
          .from('user_exports')
          .getPublicUrl(fileName);

      // エクスポート履歴記録
      await _logPrivacyChange(userId, 'data_exported', {'file_name': fileName});

      return downloadUrl;
    } catch (e) {
      throw PrivacyException('ユーザーデータのエクスポートに失敗しました: $e');
    }
  }

  @override
  Future<void> updateConsent(String userId, String consentType, bool granted) async {
    try {
      await _supabase
          .from('user_consents')
          .upsert({
            'user_id': userId,
            'consent_type': consentType,
            'granted': granted,
            'granted_at': granted ? DateTime.now().toIso8601String() : null,
            'updated_at': DateTime.now().toIso8601String(),
          });

      // 同意変更のログ記録
      await _logPrivacyChange(userId, 'consent_updated', {
        'consent_type': consentType,
        'granted': granted,
      });
    } catch (e) {
      throw PrivacyException('同意設定の更新に失敗しました: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getDataProcessingActivities(String userId) async {
    try {
      final activities = await _supabase
          .from('data_processing_logs')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(100);

      return List<Map<String, dynamic>>.from(activities);
    } catch (e) {
      throw PrivacyException('データ処理活動の取得に失敗しました: $e');
    }
  }

  @override
  Future<void> requestDataDeletion(String userId, String reason) async {
    try {
      await _supabase
          .from('data_deletion_requests')
          .insert({
            'user_id': userId,
            'reason': reason,
            'status': 'pending',
            'requested_at': DateTime.now().toIso8601String(),
          });

      // 削除リクエストの通知
      await _notifyDataDeletionRequest(userId, reason);
    } catch (e) {
      throw PrivacyException('データ削除リクエストの送信に失敗しました: $e');
    }
  }

  // プライベートメソッド
  Future<Map<String, dynamic>> _createDefaultPrivacySettings(String userId) async {
    final defaultSettings = {
      'user_id': userId,
      'profile_visibility': 'public',
      'allow_data_collection': true,
      'allow_marketing_emails': false,
      'allow_analytics': true,
      'allow_personalization': true,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _supabase
        .from('privacy_settings')
        .insert(defaultSettings);

    return defaultSettings;
  }

  Future<void> _deleteUserContent(String userId) async {
    // ユーザーのコンテンツを削除
    await _supabase
        .from('contents')
        .delete()
        .eq('creator_id', userId);
  }

  Future<void> _deleteUserInteractions(String userId) async {
    // いいね、コメント、シェアなどを削除
    await _supabase.from('content_likes').delete().eq('user_id', userId);
    await _supabase.from('content_comments').delete().eq('user_id', userId);
    await _supabase.from('content_shares').delete().eq('user_id', userId);
  }

  Future<void> _deleteUserPayments(String userId) async {
    // 決済情報を匿名化（完全削除ではなく）
    await _supabase
        .from('payments')
        .update({'user_id': 'deleted_user'})
        .eq('user_id', userId);
  }

  Future<void> _deleteUserProfile(String userId) async {
    await _supabase
        .from('profiles')
        .delete()
        .eq('id', userId);
  }

  Future<void> _deleteUserAuth(String userId) async {
    // Supabase Authからユーザーを削除
    await _supabase.auth.admin.deleteUser(userId);
  }

  Future<Map<String, dynamic>> _getUserInteractions(String userId) async {
    final likes = await _supabase
        .from('content_likes')
        .select()
        .eq('user_id', userId);

    final comments = await _supabase
        .from('content_comments')
        .select()
        .eq('user_id', userId);

    final shares = await _supabase
        .from('content_shares')
        .select()
        .eq('user_id', userId);

    return {
      'likes': likes,
      'comments': comments,
      'shares': shares,
    };
  }

  Future<void> _logPrivacyChange(String userId, String action, Map<String, dynamic> details) async {
    try {
      await _supabase
          .from('privacy_logs')
          .insert({
            'user_id': userId,
            'action': action,
            'details': details,
            'created_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      print('プライバシーログ記録エラー: $e');
    }
  }

  Future<void> _notifyDataDeletionRequest(String userId, String reason) async {
    try {
      // 管理者への通知
      await _supabase
          .from('admin_notifications')
          .insert({
            'type': 'data_deletion_request',
            'user_id': userId,
            'message': 'ユーザーからデータ削除リクエストがありました',
            'details': {'reason': reason},
            'created_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      print('削除リクエスト通知エラー: $e');
    }
  }
}

class PrivacyException implements Exception {
  final String message;
  PrivacyException(this.message);
  
  @override
  String toString() => 'PrivacyException: $message';
}

final privacyServiceProvider = Provider<PrivacyService>((ref) {
  return PrivacyServiceImpl();
});
