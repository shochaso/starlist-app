import '../models/admin/user_management_model.dart';
import '../models/user_model.dart';

/// ユーザー管理リポジトリの抽象インターフェース
abstract class UserManagementRepository {
  /// ユーザーを検索する
  Future<List<User>> searchUsers(UserSearchFilter filter, {int limit = 20, int offset = 0});
  
  /// ユーザー数を取得する
  Future<int> countUsers(UserSearchFilter filter);
  
  /// ユーザーのステータスを更新する
  Future<UserManagementResult> updateUserStatus(String userId, UserAdminStatus status, String adminId, String? reason);
  
  /// ユーザーの権限を更新する
  Future<UserManagementResult> updateUserPermissions(String userId, Map<String, bool> permissions, String adminId);
  
  /// ユーザーを削除する
  Future<UserManagementResult> deleteUser(String userId, String adminId, String reason);
  
  /// ユーザーの管理ログを取得する
  Future<List<UserAdminLog>> getUserAdminLogs(String userId, {int limit = 20, int offset = 0});
  
  /// 管理ログを記録する
  Future<UserAdminLog> logAdminAction(UserAdminLog log);
}
