import 'package:flutter/foundation.dart';
import '../models/admin/user_management_model.dart';
import '../models/user_model.dart';
import '../repositories/admin/user_management_repository.dart';
import 'notification_service.dart';

/// ユーザー管理サービスクラス
class UserManagementService {
  final UserManagementRepository _repository;
  final NotificationService _notificationService;
  
  /// コンストラクタ
  UserManagementService({
    required UserManagementRepository repository,
    required NotificationService notificationService,
  }) : _repository = repository,
       _notificationService = notificationService;
  
  /// ユーザーを検索する
  Future<List<User>> searchUsers(UserSearchFilter filter, {int limit = 20, int offset = 0}) async {
    try {
      return await _repository.searchUsers(filter, limit: limit, offset: offset);
    } catch (e) {
      debugPrint('ユーザー検索エラー: $e');
      rethrow;
    }
  }
  
  /// ユーザー数を取得する
  Future<int> countUsers(UserSearchFilter filter) async {
    try {
      return await _repository.countUsers(filter);
    } catch (e) {
      debugPrint('ユーザー数取得エラー: $e');
      rethrow;
    }
  }
  
  /// ユーザーのステータスを更新する
  Future<UserManagementResult> updateUserStatus(String userId, UserAdminStatus status, String adminId, String? reason) async {
    try {
      final result = await _repository.updateUserStatus(userId, status, adminId, reason);
      
      if (result.success && result.user != null) {
        // ユーザーに通知
        String message;
        String title;
        
        switch (status) {
          case UserAdminStatus.suspended:
            title = 'アカウントが一時停止されました';
            message = '理由: ${reason ?? "規約違反"}';
            break;
          case UserAdminStatus.banned:
            title = 'アカウントが永久停止されました';
            message = '理由: ${reason ?? "規約違反"}';
            break;
          case UserAdminStatus.active:
            title = 'アカウントが復活しました';
            message = 'アカウントが正常に復活しました。';
            break;
          case UserAdminStatus.underReview:
            title = 'アカウントが審査中です';
            message = 'アカウントが審査中です。審査が完了するまでお待ちください。';
            break;
          default:
            title = 'アカウントステータスの変更';
            message = 'アカウントのステータスが変更されました。';
        }
        
        await _notificationService.sendNotification(
          userId: userId,
          title: title,
          body: message,
          data: {'action': 'status_change', 'status': status.toString().split('.').last},
        );
      }
      
      return result;
    } catch (e) {
      debugPrint('ユーザーステータス更新エラー: $e');
      return UserManagementResult.failure(e.toString());
    }
  }
  
  /// ユーザーの権限を更新する
  Future<UserManagementResult> updateUserPermissions(String userId, Map<String, bool> permissions, String adminId) async {
    try {
      final result = await _repository.updateUserPermissions(userId, permissions, adminId);
      
      if (result.success && result.user != null) {
        // ユーザーに通知
        await _notificationService.sendNotification(
          userId: userId,
          title: '権限が更新されました',
          body: 'アカウントの権限が更新されました。',
          data: {'action': 'permissions_change'},
        );
      }
      
      return result;
    } catch (e) {
      debugPrint('ユーザー権限更新エラー: $e');
      return UserManagementResult.failure(e.toString());
    }
  }
  
  /// ユーザーを削除する
  Future<UserManagementResult> deleteUser(String userId, String adminId, String reason) async {
    try {
      // 削除前にユーザーのメールアドレスを取得（通知用）
      // 実際の実装ではユーザーリポジトリからユーザー情報を取得
      
      final result = await _repository.deleteUser(userId, adminId, reason);
      
      if (result.success) {
        // ユーザーに通知（メールなど外部チャネル経由）
        // 実際の実装ではメールサービスを使用
        debugPrint('ユーザー削除通知: userId=$userId, reason=$reason');
      }
      
      return result;
    } catch (e) {
      debugPrint('ユーザー削除エラー: $e');
      return UserManagementResult.failure(e.toString());
    }
  }
  
  /// ユーザーの管理ログを取得する
  Future<List<UserAdminLog>> getUserAdminLogs(String userId, {int limit = 20, int offset = 0}) async {
    try {
      return await _repository.getUserAdminLogs(userId, limit: limit, offset: offset);
    } catch (e) {
      debugPrint('ユーザー管理ログ取得エラー: $e');
      rethrow;
    }
  }
  
  /// ユーザーデータをエクスポートする
  Future<String> exportUserData(String userId) async {
    try {
      // ユーザーデータをJSON形式でエクスポート
      // 実際の実装ではファイル生成とダウンロードURLの提供
      
      // このサンプルでは未実装
      throw UnimplementedError('ユーザーデータのエクスポート機能は未実装です');
    } catch (e) {
      debugPrint('ユーザーデータエクスポートエラー: $e');
      rethrow;
    }
  }
  
  /// 複数ユーザーに一括アクションを実行する
  Future<List<UserManagementResult>> bulkUserAction(
    List<String> userIds, 
    UserAdminAction action, 
    String adminId, 
    String? reason
  ) async {
    try {
      final results = <UserManagementResult>[];
      
      // 各ユーザーに対してアクションを実行
      for (final userId in userIds) {
        UserManagementResult result;
        
        switch (action) {
          case UserAdminAction.statusChanged:
            // このサンプルでは一時停止に設定
            result = await updateUserStatus(userId, UserAdminStatus.suspended, adminId, reason);
            break;
          case UserAdminAction.deleted:
            result = await deleteUser(userId, adminId, reason ?? '一括削除');
            break;
          default:
            result = UserManagementResult.failure('未サポートのアクション: ${action.toString()}');
        }
        
        results.add(result);
      }
      
      return results;
    } catch (e) {
      debugPrint('一括ユーザーアクションエラー: $e');
      return userIds.map((_) => UserManagementResult.failure(e.toString())).toList();
    }
  }
  
  /// ユーザーの検索フィルターを作成する
  UserSearchFilter createSearchFilter({
    String? username,
    String? email,
    bool? isStarCreator,
    StarRank? starRank,
    UserAdminStatus? status,
    DateTime? createdAfter,
    DateTime? createdBefore,
    int? minFollowerCount,
    int? maxFollowerCount,
  }) {
    return UserSearchFilter(
      username: username,
      email: email,
      isStarCreator: isStarCreator,
      starRank: starRank,
      status: status,
      createdAfter: createdAfter,
      createdBefore: createdBefore,
      minFollowerCount: minFollowerCount,
      maxFollowerCount: maxFollowerCount,
    );
  }
}
