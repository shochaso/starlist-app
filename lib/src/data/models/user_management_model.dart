import '../models/user_model.dart';

/// ユーザーの管理ステータスを表すenum
enum UserAdminStatus {
  /// 通常
  active,
  
  /// 一時停止
  suspended,
  
  /// 永久停止
  banned,
  
  /// 審査中
  underReview,
  
  /// 削除済み
  deleted,
}

/// ユーザー管理アクションを表すenum
enum UserAdminAction {
  /// アカウント作成
  created,
  
  /// プロフィール更新
  profileUpdated,
  
  /// ステータス変更
  statusChanged,
  
  /// 権限変更
  permissionChanged,
  
  /// ログイン
  loggedIn,
  
  /// ログアウト
  loggedOut,
  
  /// パスワードリセット
  passwordReset,
  
  /// 削除
  deleted,
}

/// ユーザー管理ログを表すクラス
class UserAdminLog {
  final String id;
  final String userId;
  final String? adminId;
  final UserAdminAction action;
  final Map<String, dynamic>? previousState;
  final Map<String, dynamic>? newState;
  final String? reason;
  final DateTime timestamp;
  
  /// コンストラクタ
  UserAdminLog({
    required this.id,
    required this.userId,
    this.adminId,
    required this.action,
    this.previousState,
    this.newState,
    this.reason,
    required this.timestamp,
  });
  
  /// JSONからUserAdminLogを生成するファクトリメソッド
  factory UserAdminLog.fromJson(Map<String, dynamic> json) {
    return UserAdminLog(
      id: json['id'],
      userId: json['userId'],
      adminId: json['adminId'],
      action: UserAdminAction.values.firstWhere(
        (e) => e.toString() == 'UserAdminAction.${json['action']}',
        orElse: () => UserAdminAction.created,
      ),
      previousState: json['previousState'],
      newState: json['newState'],
      reason: json['reason'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
  
  /// UserAdminLogをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'adminId': adminId,
      'action': action.toString().split('.').last,
      'previousState': previousState,
      'newState': newState,
      'reason': reason,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  /// 属性を変更した新しいインスタンスを作成するメソッド
  UserAdminLog copyWith({
    String? id,
    String? userId,
    String? adminId,
    UserAdminAction? action,
    Map<String, dynamic>? previousState,
    Map<String, dynamic>? newState,
    String? reason,
    DateTime? timestamp,
  }) {
    return UserAdminLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      adminId: adminId ?? this.adminId,
      action: action ?? this.action,
      previousState: previousState ?? this.previousState,
      newState: newState ?? this.newState,
      reason: reason ?? this.reason,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// ユーザー検索フィルターを表すクラス
class UserSearchFilter {
  final String? username;
  final String? email;
  final bool? isStarCreator;
  final StarRank? starRank;
  final UserAdminStatus? status;
  final DateTime? createdAfter;
  final DateTime? createdBefore;
  final int? minFollowerCount;
  final int? maxFollowerCount;
  
  /// コンストラクタ
  UserSearchFilter({
    this.username,
    this.email,
    this.isStarCreator,
    this.starRank,
    this.status,
    this.createdAfter,
    this.createdBefore,
    this.minFollowerCount,
    this.maxFollowerCount,
  });
  
  /// JSONからUserSearchFilterを生成するファクトリメソッド
  factory UserSearchFilter.fromJson(Map<String, dynamic> json) {
    return UserSearchFilter(
      username: json['username'],
      email: json['email'],
      isStarCreator: json['isStarCreator'],
      starRank: json['starRank'] != null 
          ? StarRank.values.firstWhere(
              (e) => e.toString() == 'StarRank.${json['starRank']}',
              orElse: () => StarRank.regular,
            )
          : null,
      status: json['status'] != null 
          ? UserAdminStatus.values.firstWhere(
              (e) => e.toString() == 'UserAdminStatus.${json['status']}',
              orElse: () => UserAdminStatus.active,
            )
          : null,
      createdAfter: json['createdAfter'] != null ? DateTime.parse(json['createdAfter']) : null,
      createdBefore: json['createdBefore'] != null ? DateTime.parse(json['createdBefore']) : null,
      minFollowerCount: json['minFollowerCount'],
      maxFollowerCount: json['maxFollowerCount'],
    );
  }
  
  /// UserSearchFilterをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'isStarCreator': isStarCreator,
      'starRank': starRank?.toString().split('.').last,
      'status': status?.toString().split('.').last,
      'createdAfter': createdAfter?.toIso8601String(),
      'createdBefore': createdBefore?.toIso8601String(),
      'minFollowerCount': minFollowerCount,
      'maxFollowerCount': maxFollowerCount,
    };
  }
  
  /// 属性を変更した新しいインスタンスを作成するメソッド
  UserSearchFilter copyWith({
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
      username: username ?? this.username,
      email: email ?? this.email,
      isStarCreator: isStarCreator ?? this.isStarCreator,
      starRank: starRank ?? this.starRank,
      status: status ?? this.status,
      createdAfter: createdAfter ?? this.createdAfter,
      createdBefore: createdBefore ?? this.createdBefore,
      minFollowerCount: minFollowerCount ?? this.minFollowerCount,
      maxFollowerCount: maxFollowerCount ?? this.maxFollowerCount,
    );
  }
}

/// ユーザー管理結果を表すクラス
class UserManagementResult {
  final bool success;
  final String? errorMessage;
  final User? user;
  final UserAdminLog? log;
  
  /// コンストラクタ
  UserManagementResult({
    required this.success,
    this.errorMessage,
    this.user,
    this.log,
  });
  
  /// 成功結果を作成するファクトリメソッド
  factory UserManagementResult.success({User? user, UserAdminLog? log}) {
    return UserManagementResult(
      success: true,
      user: user,
      log: log,
    );
  }
  
  /// 失敗結果を作成するファクトリメソッド
  factory UserManagementResult.failure(String errorMessage) {
    return UserManagementResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}
