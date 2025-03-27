# 管理者向け機能の設計

## 1. 全体アーキテクチャ

管理者向け機能は以下のレイヤーで構成します：

1. **プレゼンテーション層**：管理者用ダッシュボードUI
2. **ユースケース層**：管理機能のビジネスロジック
3. **ドメイン層**：管理関連のエンティティとビジネスルール
4. **データ層**：管理データの永続化と外部サービスとの連携

## 2. ユーザー管理ツール

### 2.1 モデル設計

```dart
// lib/src/models/admin/user_management_model.dart

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
  
  // コンストラクタ、JSONシリアライズ/デシリアライズ、copyWithメソッドなど
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
  
  // コンストラクタ、JSONシリアライズ/デシリアライズ、copyWithメソッドなど
}

/// ユーザー管理結果を表すクラス
class UserManagementResult {
  final bool success;
  final String? errorMessage;
  final User? user;
  final UserAdminLog? log;
  
  // コンストラクタ
}
```

### 2.2 リポジトリ設計

```dart
// lib/src/repositories/admin/user_management_repository.dart

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
```

### 2.3 サービス設計

```dart
// lib/src/services/admin/user_management_service.dart

/// ユーザー管理サービスクラス
class UserManagementService {
  final UserManagementRepository _repository;
  final NotificationService _notificationService;
  
  // コンストラクタ
  
  /// ユーザーを検索する
  Future<List<User>> searchUsers(UserSearchFilter filter, {int limit = 20, int offset = 0}) async {
    return await _repository.searchUsers(filter, limit: limit, offset: offset);
  }
  
  /// ユーザー数を取得する
  Future<int> countUsers(UserSearchFilter filter) async {
    return await _repository.countUsers(filter);
  }
  
  /// ユーザーのステータスを更新する
  Future<UserManagementResult> updateUserStatus(String userId, UserAdminStatus status, String adminId, String? reason) async {
    final result = await _repository.updateUserStatus(userId, status, adminId, reason);
    
    if (result.success && result.user != null) {
      // ユーザーに通知
      String message;
      switch (status) {
        case UserAdminStatus.suspended:
          message = 'アカウントが一時停止されました。理由: ${reason ?? "規約違反"}';
          break;
        case UserAdminStatus.banned:
          message = 'アカウントが永久停止されました。理由: ${reason ?? "規約違反"}';
          break;
        case UserAdminStatus.active:
          message = 'アカウントが復活しました。';
          break;
        default:
          message = 'アカウントのステータスが変更されました。';
      }
      
      await _notificationService.sendNotification(
        userId: userId,
        title: 'アカウントステータスの変更',
        body: message,
      );
    }
    
    return result;
  }
  
  /// ユーザーの権限を更新する
  Future<UserManagementResult> updateUserPermissions(String userId, Map<String, bool> permissions, String adminId) async {
    return await _repository.updateUserPermissions(userId, permissions, adminId);
  }
  
  /// ユーザーを削除する
  Future<UserManagementResult> deleteUser(String userId, String adminId, String reason) async {
    final result = await _repository.deleteUser(userId, adminId, reason);
    
    if (result.success) {
      // ユーザーに通知（メールなど外部チャネル経由）
      // 実際の実装ではメールサービスを使用
    }
    
    return result;
  }
  
  /// ユーザーの管理ログを取得する
  Future<List<UserAdminLog>> getUserAdminLogs(String userId, {int limit = 20, int offset = 0}) async {
    return await _repository.getUserAdminLogs(userId, limit: limit, offset: offset);
  }
  
  /// ユーザーデータをエクスポートする
  Future<String> exportUserData(String userId) async {
    // ユーザーデータをJSON形式でエクスポート
    // 実際の実装ではファイル生成とダウンロードURLの提供
    throw UnimplementedError();
  }
  
  /// 複数ユーザーに一括アクションを実行する
  Future<List<UserManagementResult>> bulkUserAction(List<String> userIds, UserAdminAction action, String adminId, String? reason) async {
    // 複数ユーザーに対して同じアクションを実行
    throw UnimplementedError();
  }
}
```

## 3. コンテンツモデレーション機能

### 3.1 モデル設計

```dart
// lib/src/models/admin/content_moderation_model.dart

/// コンテンツモデレーションステータスを表すenum
enum ContentModerationStatus {
  /// 審査待ち
  pending,
  
  /// 承認済み
  approved,
  
  /// 拒否
  rejected,
  
  /// 削除済み
  removed,
  
  /// 自動フラグ付け
  autoFlagged,
}

/// コンテンツ報告理由を表すenum
enum ContentReportReason {
  /// 不適切なコンテンツ
  inappropriate,
  
  /// スパム
  spam,
  
  /// ハラスメント
  harassment,
  
  /// 暴力
  violence,
  
  /// 著作権侵害
  copyright,
  
  /// その他
  other,
}

/// コンテンツ報告を表すクラス
class ContentReport {
  final String id;
  final String contentId;
  final String reporterId;
  final ContentReportReason reason;
  final String? description;
  final List<String>? evidenceUrls;
  final ContentModerationStatus status;
  final String? moderatorId;
  final String? moderatorNote;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  
  // コンストラクタ、JSONシリアライズ/デシリアライズ、copyWithメソッドなど
}

/// モデレーションアクションを表すenum
enum ModerationAction {
  /// 承認
  approve,
  
  /// 拒否
  reject,
  
  /// 削除
  remove,
  
  /// 警告
  warn,
  
  /// 一時停止
  suspend,
  
  /// 永久停止
  ban,
}

/// モデレーションログを表すクラス
class ModerationLog {
  final String id;
  final String contentId;
  final String? reportId;
  final String moderatorId;
  final ModerationAction action;
  final String? reason;
  final DateTime timestamp;
  
  // コンストラクタ、JSONシリアライズ/デシリアライズ、copyWithメソッドなど
}

/// コンテンツモデレーション結果を表すクラス
class ModerationResult {
  final bool success;
  final String? errorMessage;
  final ContentReport? report;
  final ModerationLog? log;
  
  // コンストラクタ
}
```

### 3.2 リポジトリ設計

```dart
// lib/src/repositories/admin/content_moderation_repository.dart

/// コンテンツモデレーションリポジトリの抽象インターフェース
abstract class ContentModerationRepository {
  /// 報告されたコンテンツを取得する
  Future<List<ContentReport>> getReportedContent({ContentModerationStatus? status, int limit = 20, int offset = 0});
  
  /// 報告数を取得する
  Future<int> countReports({ContentModerationStatus? status});
  
  /// コンテンツ報告を作成する
  Future<ContentReport> createContentReport(ContentReport report);
  
  /// コンテンツ報告のステータスを更新する
  Future<ModerationResult> updateReportStatus(String reportId, ContentModerationStatus status, String moderatorId, String? note);
  
  /// モデレーションアクションを実行する
  Future<ModerationResult> performModerationAction(String contentId, ModerationAction action, String moderatorId, String? reason);
  
  /// モデレーションログを取得する
  Future<List<ModerationLog>> getModerationLogs(String contentId, {int limit = 20, int offset = 0});
  
  /// モデレーションログを記録する
  Future<ModerationLog> logModerationAction(ModerationLog log);
}
```

### 3.3 サービス設計

```dart
// lib/src/services/admin/content_moderation_service.dart

/// コンテンツモデレーションサービスクラス
class ContentModerationService {
  final ContentModerationRepository _repository;
  final NotificationService _notificationService;
  final UserManagementService _userManagementService;
  
  // コンストラクタ
  
  /// 報告されたコンテンツを取得する
  Future<List<ContentReport>> getReportedContent({ContentModerationStatus? status, int limit = 20, int offset = 0}) async {
    return await _repository.getReportedContent(status: status, limit: limit, offset: offset);
  }
  
  /// 報告数を取得する
  Future<int> countReports({ContentModerationStatus? status}) async {
    return await _repository.countReports(status: status);
  }
  
  /// コンテンツ報告を作成する
  Future<ContentReport> reportContent({
    required String contentId,
    required String reporterId,
    required ContentReportReason reason,
    String? description,
    List<String>? evidenceUrls,
  }) async {
    final report = ContentReport(
      id: 'report_${DateTime.now().millisecondsSinceEpoch}',
      contentId: contentId,
      reporterId: reporterId,
      reason: reason,
      description: description,
      evidenceUrls: evidenceUrls,
      status: ContentModerationStatus.pending,
      createdAt: DateTime.now(),
    );
    
    return await _repository.createContentReport(report);
  }
  
  /// コンテンツ報告を承認する
  Future<ModerationResult> approveReport(String reportId, String moderatorId, String? note) async {
    final result = await _repository.updateReportStatus(
      reportId,
      ContentModerationStatus.approved,
      moderatorId,
      note,
    );
    
    if (result.success && result.report != null) {
      // コンテンツを削除
      await _repository.performModerationAction(
        result.report!.contentId,
        ModerationAction.remove,
        moderatorId,
        'Report approved: ${note ?? "Violation of community guidelines"}',
      );
      
      // コンテンツ作成者に通知
      // 実際の実装ではコンテンツからユーザーIDを取得
      final contentOwnerId = await _getContentOwnerId(result.report!.contentId);
      if (contentOwnerId != null) {
        await _notificationService.sendNotification(
          userId: contentOwnerId,
          title: 'コンテンツが削除されました',
          body: 'あなたのコンテンツがコミュニティガイドラインに違反したため削除されました。',
          data: {'contentId': result.report!.contentId},
        );
      }
      
      // 報告者に通知
      await _notificationService.sendNotification(
        userId: result.report!.reporterId,
        title: '報告が承認されました',
        body: 'あなたの報告に基づき、コンテンツが削除されました。ご協力ありがとうございます。',
        data: {'reportId': reportId},
      );
    }
    
    return result;
  }
  
  /// コンテンツ報告を拒否する
  Future<ModerationResult> rejectReport(String reportId, String moderatorId, String? note) async {
    final result = await _repository.updateReportStatus(
      reportId,
      ContentModerationStatus.rejected,
      moderatorId,
      note,
    );
    
    if (result.success && result.report != null) {
      // 報告者に通知
      await _notificationService.sendNotification(
        userId: result.report!.reporterId,
        title: '報告が拒否されました',
        body: 'あなたの報告を確認しましたが、コミュニティガイドラインに違反するコンテンツではないと判断しました。',
        data: {'reportId': reportId},
      );
    }
    
    return result;
  }
  
  /// コンテンツを削除する
  Future<ModerationResult> removeContent(String contentId, String moderatorId, String reason) async {
    final result = await _repository.performModerationAction(
      contentId,
      ModerationAction.remove,
      moderatorId,
      reason,
    );
    
    if (result.success) {
      // コンテンツ作成者に通知
      final contentOwnerId = await _getContentOwnerId(contentId);
      if (contentOwnerId != null) {
        await _notificationService.sendNotification(
          userId: contentOwnerId,
          title: 'コンテンツが削除されました',
          body: 'あなたのコンテンツが削除されました。理由: $reason',
          data: {'contentId': contentId},
        );
      }
    }
    
    return result;
  }
  
  /// ユーザーに警告を送信する
  Future<ModerationResult> warnUser(String contentId, String userId, String moderatorId, String reason) async {
    final result = await _repository.performModerationAction(
      contentId,
      ModerationAction.warn,
      moderatorId,
      reason,
    );
    
    if (result.success) {
      // ユーザーに通知
      await _notificationService.sendNotification(
        userId: userId,
        title: '警告: コミュニティガイドライン違反',
        body: '警告: あなたのコンテンツがコミュニティガイドラインに違反しています。理由: $reason',
        data: {'contentId': contentId},
      );
    }
    
    return result;
  }
  
  /// ユーザーを一時停止する
  Future<ModerationResult> suspendUser(String contentId, String userId, String moderatorId, String reason, int durationDays) async {
    final result = await _repository.performModerationAction(
      contentId,
      ModerationAction.suspend,
      moderatorId,
      reason,
    );
    
    if (result.success) {
      // ユーザー管理サービスでユーザーを一時停止
      await _userManagementService.updateUserStatus(
        userId,
        UserAdminStatus.suspended,
        moderatorId,
        reason,
      );
    }
    
    return result;
  }
  
  /// モデレーションログを取得する
  Future<List<ModerationLog>> getModerationLogs(String contentId, {int limit = 20, int offset = 0}) async {
    return await _repository.getModerationLogs(contentId, limit: limit, offset: offset);
  }
  
  /// コンテンツ所有者IDを取得する（実際の実装ではコンテンツリポジトリから取得）
  Future<String?> _getContentOwnerId(String contentId) async {
    // 実際の実装ではコンテンツリポジトリからコンテンツを取得してユーザーIDを返す
    return 'mock_user_id';
  }
}
```

## 4. システム全体の統計ダッシュボード

### 4.1 モデル設計

```dart
// lib/src/models/admin/analytics_model.dart

/// 統計期間を表すenum
enum AnalyticsPeriod {
  /// 日次
  daily,
  
  /// 週次
  weekly,
  
  /// 月次
  monthly,
  
  /// 四半期
  quarterly,
  
  /// 年次
  yearly,
  
  /// カスタム
  custom,
}

/// ユーザー統計を表すクラス
class UserAnalytics {
  final int totalUsers;
  final int newUsers;
  final int activeUsers;
  final int starCreators;
  final Map<String, int> usersByPlan;
  final Map<String, int> usersByRegion;
  final double retentionRate;
  final double churnRate;
  
  // コンストラクタ、JSONシリアライズ/デシリアライズなど
}

/// 収益統計を表すクラス
class RevenueAnalytics {
  final double totalRevenue;
  final double subscriptionRevenue;
  final double ticketRevenue;
  final double donationRevenue;
  final Map<String, double> revenueByPlan;
  final Map<String, double> revenueByRegion;
  final double averageRevenuePerUser;
  final double monthOverMonthGrowth;
  
  // コンストラクタ、JSONシリアライズ/デシリアライズなど
}

/// コンテンツ統計を表すクラス
class ContentAnalytics {
  final int totalContent;
  final int newContent;
  final Map<String, int> contentByCategory;
  final Map<String, int> contentByPrivacyLevel;
  final double averageViewsPerContent;
  final double averageLikesPerContent;
  final double averageCommentsPerContent;
  final List<String> topPerformingContent;
  
  // コンストラクタ、JSONシリアライズ/デシリアライズなど
}

/// システム統計を表すクラス
class SystemAnalytics {
  final double averageResponseTime;
  final int totalApiCalls;
  final int errorCount;
  final double serverUptime;
  final Map<String, int> apiCallsByEndpoint;
  final Map<String, int> errorsByType;
  
  // コンストラクタ、JSONシリアライズ/デシリアライズなど
}

/// ダッシュボード統計を表すクラス
class DashboardAnalytics {
  final UserAnalytics userAnalytics;
  final RevenueAnalytics revenueAnalytics;
  final ContentAnalytics contentAnalytics;
  final SystemAnalytics systemAnalytics;
  final DateTime generatedAt;
  final AnalyticsPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  
  // コンストラクタ、JSONシリアライズ/デシリアライズなど
}
```

### 4.2 リポジトリ設計

```dart
// lib/src/repositories/admin/analytics_repository.dart

/// 統計リポジトリの抽象インターフェース
abstract class AnalyticsRepository {
  /// ユーザー統計を取得する
  Future<UserAnalytics> getUserAnalytics(AnalyticsPeriod period, {DateTime? startDate, DateTime? endDate});
  
  /// 収益統計を取得する
  Future<RevenueAnalytics> getRevenueAnalytics(AnalyticsPeriod period, {DateTime? startDate, DateTime? endDate});
  
  /// コンテンツ統計を取得する
  Future<ContentAnalytics> getContentAnalytics(AnalyticsPeriod period, {DateTime? startDate, DateTime? endDate});
  
  /// システム統計を取得する
  Future<SystemAnalytics> getSystemAnalytics(AnalyticsPeriod period, {DateTime? startDate, DateTime? endDate});
  
  /// ダッシュボード統計を取得する
  Future<DashboardAnaly<response clipped><NOTE>To save on context only part of this file has been shown to you. You should retry this tool after you have searched inside the file with `grep -n` in order to find the line numbers of what you are looking for.</NOTE>