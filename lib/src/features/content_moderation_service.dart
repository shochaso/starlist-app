import 'package:flutter/foundation.dart';
import '../models/admin/content_moderation_model.dart';
import '../models/admin/user_management_model.dart';
import '../repositories/admin/content_moderation_repository.dart';
import 'notification_service.dart';
import 'admin/user_management_service.dart';

/// コンテンツモデレーションサービスクラス
class ContentModerationService {
  final ContentModerationRepository _repository;
  final NotificationService _notificationService;
  final UserManagementService _userManagementService;
  
  /// コンストラクタ
  ContentModerationService({
    required ContentModerationRepository repository,
    required NotificationService notificationService,
    required UserManagementService userManagementService,
  }) : _repository = repository,
       _notificationService = notificationService,
       _userManagementService = userManagementService;
  
  /// 報告されたコンテンツを取得する
  Future<List<ContentReport>> getReportedContent({ContentModerationStatus? status, int limit = 20, int offset = 0}) async {
    try {
      return await _repository.getReportedContent(status: status, limit: limit, offset: offset);
    } catch (e) {
      debugPrint('報告コンテンツ取得エラー: $e');
      rethrow;
    }
  }
  
  /// 報告数を取得する
  Future<int> countReports({ContentModerationStatus? status}) async {
    try {
      return await _repository.countReports(status: status);
    } catch (e) {
      debugPrint('報告数取得エラー: $e');
      rethrow;
    }
  }
  
  /// コンテンツ報告を作成する
  Future<ContentReport> reportContent({
    required String contentId,
    required String reporterId,
    required ContentReportReason reason,
    String? description,
    List<String>? evidenceUrls,
  }) async {
    try {
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
      
      final savedReport = await _repository.createContentReport(report);
      
      // 管理者に通知（実際の実装では管理者通知システムを使用）
      debugPrint('新しいコンテンツ報告: ${savedReport.toJson()}');
      
      return savedReport;
    } catch (e) {
      debugPrint('コンテンツ報告作成エラー: $e');
      rethrow;
    }
  }
  
  /// コンテンツ報告を承認する
  Future<ModerationResult> approveReport(String reportId, String moderatorId, String? note) async {
    try {
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
    } catch (e) {
      debugPrint('報告承認エラー: $e');
      return ModerationResult.failure(e.toString());
    }
  }
  
  /// コンテンツ報告を拒否する
  Future<ModerationResult> rejectReport(String reportId, String moderatorId, String? note) async {
    try {
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
    } catch (e) {
      debugPrint('報告拒否エラー: $e');
      return ModerationResult.failure(e.toString());
    }
  }
  
  /// コンテンツを削除する
  Future<ModerationResult> removeContent(String contentId, String moderatorId, String reason) async {
    try {
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
    } catch (e) {
      debugPrint('コンテンツ削除エラー: $e');
      return ModerationResult.failure(e.toString());
    }
  }
  
  /// ユーザーに警告を送信する
  Future<ModerationResult> warnUser(String contentId, String userId, String moderatorId, String reason) async {
    try {
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
    } catch (e) {
      debugPrint('ユーザー警告エラー: $e');
      return ModerationResult.failure(e.toString());
    }
  }
  
  /// ユーザーを一時停止する
  Future<ModerationResult> suspendUser(String contentId, String userId, String moderatorId, String reason, int durationDays) async {
    try {
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
    } catch (e) {
      debugPrint('ユーザー一時停止エラー: $e');
      return ModerationResult.failure(e.toString());
    }
  }
  
  /// ユーザーを永久停止する
  Future<ModerationResult> banUser(String contentId, String userId, String moderatorId, String reason) async {
    try {
      final result = await _repository.performModerationAction(
        contentId,
        ModerationAction.ban,
        moderatorId,
        reason,
      );
      
      if (result.success) {
        // ユーザー管理サービスでユーザーを永久停止
        await _userManagementService.updateUserStatus(
          userId,
          UserAdminStatus.banned,
          moderatorId,
          reason,
        );
      }
      
      return result;
    } catch (e) {
      debugPrint('ユーザー永久停止エラー: $e');
      return ModerationResult.failure(e.toString());
    }
  }
  
  /// モデレーションログを取得する
  Future<List<ModerationLog>> getModerationLogs(String contentId, {int limit = 20, int offset = 0}) async {
    try {
      return await _repository.getModerationLogs(contentId, limit: limit, offset: offset);
    } catch (e) {
      debugPrint('モデレーションログ取得エラー: $e');
      rethrow;
    }
  }
  
  /// 自動モデレーションを実行する
  Future<void> performAutoModeration(String contentId, String contentText) async {
    try {
      // 禁止ワードリスト（実際の実装ではデータベースから取得）
      final bannedWords = ['禁止ワード1', '禁止ワード2', '禁止ワード3'];
      
      // 禁止ワードのチェック
      final containsBannedWord = bannedWords.any((word) => contentText.toLowerCase().contains(word.toLowerCase()));
      
      if (containsBannedWord) {
        // 自動フラグ付け
        await _repository.performModerationAction(
          contentId,
          ModerationAction.remove,
          'system',
          '禁止ワードを含むコンテンツの自動削除',
        );
        
        // コンテンツ作成者に通知
        final contentOwnerId = await _getContentOwnerId(contentId);
        if (contentOwnerId != null) {
          await _notificationService.sendNotification(
            userId: contentOwnerId,
            title: 'コンテンツが自動削除されました',
            body: 'あなたのコンテンツが禁止ワードを含むため自動削除されました。',
            data: {'contentId': contentId},
          );
        }
      }
    } catch (e) {
      debugPrint('自動モデレーションエラー: $e');
    }
  }
  
  /// コンテンツ所有者IDを取得する（実際の実装ではコンテンツリポジトリから取得）
  Future<String?> _getContentOwnerId(String contentId) async {
    // 実際の実装ではコンテンツリポジトリからコンテンツを取得してユーザーIDを返す
    return 'mock_user_id';
  }
}
